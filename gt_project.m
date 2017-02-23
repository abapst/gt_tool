function gt_project(varargin)

    set(0,'units','pixels');
    screen = get(0,'screensize');
    sidebarW = screen(3)/10;
    figX = screen(3)/20;
    figY = figX;
    buttonH = sidebarW/6;
    figH = 17*buttonH;
    barHeight = 20;
    
    global imH;
    global imW;
    global IS_BUTTON_DOWN;
    global RECT_START_COORD;
    global RECT_END_COORD;
    global CURRENT_RECT;
    global SELECTED_BOX;
    global RECT_HANDLES;
    RECT_HANDLES = [];
    global BOXES;
    global axH;
    global axW;
    global gtdata;
    global LABELCHOICE;
    LABELCHOICE = 0;
    
    global fontsize_infotext;
    if screen(3) > 1920
        fontsize_infotext = 11;
    else
        fontsize_infotext = 8;
    end
    
    global ADJUST; % fine adjustment step size for boxes 
    ADJUST = 2;
    
    global CURRENT_LABEL;
    
    CURRENT_RECT = [];
    BOXES = [];
    
    guiObject = varargin{1};
    guiObject.save_choice = 0; % CANCEL by default
    
    % Create and then hide the UI as it is being constructed
    guiObject.fProject = figure('Visible','off','Units','Pixels',...
               'Position',[figX,figY,sidebarW,figH],...
               'NumberTitle','off',...
               'MenuBar','none','ToolBar','auto',...
               'WindowButtonDownFcn', @MouseDownImg,...
               'WindowButtonUpFcn', @MouseUpImg,...
               'WindowButtonMotionFcn',@MouseOverImg);
           
    % Construct the components.
    hlogo = axes('Units','Pixels',...
                 'Position',[0,figH-2*buttonH,sidebarW,2*buttonH]);
    himg = axes('Units','Pixels',...
                'Position',[sidebarW,barHeight,1,1]);
    hbar = axes('Units','Pixels',...
                    'Position',[sidebarW,0,1,1]);
    hnewp = uicontrol('Style','pushbutton','String','New Project',...
            'Position',[0,figH-3*buttonH,sidebarW,buttonH],'FontSize',20,...
            'Callback',{@new_Callback});
    hsavep = uicontrol('Style','pushbutton','String','Save Project',...
            'Position',[0,figH-4*buttonH,sidebarW,buttonH],'FontSize',20,...
            'Callback',{@save_Callback});
    hloadp = uicontrol('Style','pushbutton','String','Load Project',...
             'Position',[0,figH-5*buttonH,sidebarW,buttonH],'FontSize',20,...
             'Callback',{@load_Callback});
    hprev = uicontrol('Style','pushbutton','String','<PREV',...
             'Position',[0,0,sidebarW/2,2*buttonH],'FontSize',20,...
             'Callback',{@prev_Callback});
    hnext = uicontrol('Style','pushbutton','String','NEXT>',...
             'Position',[sidebarW/2,0,sidebarW/2,2*buttonH],'FontSize',20,...
             'Callback',{@next_Callback});
    hstep1 = uicontrol('Style','text','String','Step: ',...
             'Position',[0,figH-6*buttonH,sidebarW/2,buttonH],...
             'FontSize',20,...
             'HorizontalAlignment','right');
    hstep2 = uicontrol('Style','edit',...
             'Position',[sidebarW/2,figH-6*buttonH,sidebarW/4,buttonH],...
             'String','1',...
             'FontSize',20,...
             'HorizontalAlignment','left',...
             'Callback',{@step_Callback});
    hcurrframe1 = uicontrol('Style','text','String','Frame: ',...
             'Position',[0,2*buttonH,sidebarW/2,buttonH],...
             'FontSize',20,...
             'HorizontalAlignment','right');
    hcurrframe2 = uicontrol('Style','text','String','--/--',...
             'ForegroundColor','r',...
             'Position',[sidebarW/2,2*buttonH,sidebarW/2,buttonH],...
             'FontSize',20,...
             'HorizontalAlignment','left');
    hfilename = uicontrol('Style','text','String','--',...
             'BackgroundColor','b',...
             'ForegroundColor','w',...
             'HorizontalAlignment','left',...
             'FontSize',11,...
             'Position',[sidebarW+10,2,4*sidebarW,barHeight-2]);
    hxytext = uicontrol('Style','text','String','',...
             'BackgroundColor','b',...
             'ForegroundColor','w',...
             'HorizontalAlignment','right',...
             'FontSize',11,...
             'Position',[0,2,sidebarW,barHeight-2]);
    hinfotext = uicontrol(...
             'Style','text',...
             'HorizontalAlignment','left',...
             'String',{'  Keyboard Shortcuts:',...
                       '  ---------------------------------',...
                       '',...
                       '  q: quit',...
                       '',...
                       '  C: clear all boxes',...
                       '',...
                       '  space: cycle boxes',...
                       '',...
                       '  left,right: browse frames',...
                       '',...
                       '  ctrl: select label for current box',...
                       '',...
                       '  w,a,s,d: move box edges inwards',...
                       '',...
                       '  W,A,S,D: move box edges outwards'},...
             'FontSize',fontsize_infotext,...
             'Position',[0,figH-7*buttonH,sidebarW,7*buttonH]);
    
    % keypress function
    set(guiObject.fProject,'WindowKeyPressFcn',@KeyPress);
         
    % load logo image
    [logo,~,alpha] = imread('assets\logo.png');
    imlogo = imshow(logo,'Parent',hlogo);
    set(imlogo,'alphadata',alpha);

    % load first image and save file structure
    guiObject.project = parse_filename(guiObject);
    gtdata = guiObject.project.gtdata;
    
    % initialize and populate labels list
    hlabels = uicontrol(...
        'Style','popupmenu',...
        'String',guiObject.project.labels,...
        'Position',[0,0,0,0],...
        'FontSize',12,...
        'Callback',{@popuplabels_callback},...
        'Visible','off');
    
    % set field values from loaded project
    set(hstep2,'String',num2str(guiObject.project.step));
    
    % load first image
    load_first;
    
    % Make the UI visible
    guiObject.fProject.Name = 'Ground Truth Tool 1.0';
    guiObject.fProject.Visible = 'on';
        
    function KeyPress(~,eventData)
        char = native2unicode(get(guiObject.fProject,'CurrentCharacter'));
        if strcmp(eventData.Key,'leftarrow')
            load_prev;
        elseif strcmp(eventData.Key,'rightarrow')
            load_next;
        elseif strcmp(eventData.Key,'q')
            choice = save_query;
            if choice ~= 0
                closereq;
            end
        elseif strcmp(char,'a')
            if ~isempty(BOXES)
                pos = get(RECT_HANDLES(SELECTED_BOX).handle,'Position');
                lpos = get(RECT_HANDLES(SELECTED_BOX).label,'Position');
                pos(3) = pos(3) - ADJUST;
                set(RECT_HANDLES(SELECTED_BOX).handle,'Position',pos);
                set(RECT_HANDLES(SELECTED_BOX).label,'Position',lpos);
                BOXES(SELECTED_BOX).pos = pos;
            end
        elseif strcmp(char,'A')
            if ~isempty(BOXES)
                pos = get(RECT_HANDLES(SELECTED_BOX).handle,'Position');
                lpos = get(RECT_HANDLES(SELECTED_BOX).label,'Position');
                pos(1) = pos(1) - ADJUST;
                pos(3) = pos(3) + ADJUST;
                lpos(1) = lpos(1) - ADJUST;
                set(RECT_HANDLES(SELECTED_BOX).handle,'Position',pos);
                set(RECT_HANDLES(SELECTED_BOX).label,'Position',lpos);
                BOXES(SELECTED_BOX).pos = pos;
            end
        elseif strcmp(char,'d')
            if ~isempty(BOXES)
                pos = get(RECT_HANDLES(SELECTED_BOX).handle,'Position');
                lpos = get(RECT_HANDLES(SELECTED_BOX).label,'Position');
                pos(1) = pos(1) + ADJUST;
                pos(3) = pos(3) - ADJUST;
                lpos(1) = lpos(1) + ADJUST;
                set(RECT_HANDLES(SELECTED_BOX).handle,'Position',pos);
                set(RECT_HANDLES(SELECTED_BOX).label,'Position',lpos);
                BOXES(SELECTED_BOX).pos = pos;
            end
        elseif strcmp(char,'D')
            if ~isempty(BOXES)
                pos = get(RECT_HANDLES(SELECTED_BOX).handle,'Position');
                lpos = get(RECT_HANDLES(SELECTED_BOX).label,'Position');
                pos(3) = pos(3) + ADJUST;
                set(RECT_HANDLES(SELECTED_BOX).handle,'Position',pos);
                set(RECT_HANDLES(SELECTED_BOX).label,'Position',lpos);
                BOXES(SELECTED_BOX).pos = pos;
            end
        elseif strcmp(char,'w')
            if ~isempty(BOXES)
                pos = get(RECT_HANDLES(SELECTED_BOX).handle,'Position');
                lpos = get(RECT_HANDLES(SELECTED_BOX).label,'Position');
                pos(4) = pos(4) - ADJUST;
                set(RECT_HANDLES(SELECTED_BOX).handle,'Position',pos);
                set(RECT_HANDLES(SELECTED_BOX).label,'Position',lpos);
                BOXES(SELECTED_BOX).pos = pos;
            end
        elseif strcmp(char,'W')
            if ~isempty(BOXES)
                pos = get(RECT_HANDLES(SELECTED_BOX).handle,'Position');
                lpos = get(RECT_HANDLES(SELECTED_BOX).label,'Position');
                pos(2) = pos(2) - ADJUST;
                lpos(2) = lpos(2) + ADJUST;
                pos(4) = pos(4) + ADJUST;
                set(RECT_HANDLES(SELECTED_BOX).handle,'Position',pos);
                set(RECT_HANDLES(SELECTED_BOX).label,'Position',lpos);
                BOXES(SELECTED_BOX).pos = pos;
            end
        elseif strcmp(char,'s')
            if ~isempty(BOXES)
                pos = get(RECT_HANDLES(SELECTED_BOX).handle,'Position');
                lpos = get(RECT_HANDLES(SELECTED_BOX).label,'Position');
                pos(2) = pos(2) + ADJUST;
                lpos(2) = lpos(2) - ADJUST;
                pos(4) = pos(4) - ADJUST;
                set(RECT_HANDLES(SELECTED_BOX).handle,'Position',pos);
                set(RECT_HANDLES(SELECTED_BOX).label,'Position',lpos);
                BOXES(SELECTED_BOX).pos = pos;
            end
        elseif strcmp(char,'S')
            if ~isempty(BOXES)
                pos = get(RECT_HANDLES(SELECTED_BOX).handle,'Position');
                lpos = get(RECT_HANDLES(SELECTED_BOX).label,'Position');
                pos(4) = pos(4) + ADJUST;
                set(RECT_HANDLES(SELECTED_BOX).handle,'Position',pos);
                set(RECT_HANDLES(SELECTED_BOX).label,'Position',lpos);
                BOXES(SELECTED_BOX).pos = pos;
            end
        elseif strcmp(char,'C')
            clear_im;
            BOXES = [];
        elseif strcmp(eventData.Key,'control')
            if ~LABELCHOICE
                LABELCHOICE = 1;
                pos = get(RECT_HANDLES(SELECTED_BOX).handle,'Position');
                set(hlabels,'Position',[(axW/imW)*pos(1)+sidebarW,(axH+2*barHeight)-(axH/imH)*pos(2),130,0]);
                if ~isempty(BOXES(SELECTED_BOX).label)
                    set(hlabels,'Value',find(strcmp(guiObject.project.labels,BOXES(SELECTED_BOX).label)));
                end
                set(RECT_HANDLES(SELECTED_BOX).label,'Visible','off');
                set(hlabels,'Visible','on');
                set(hlabels,'enable','on');
                uicontrol(hlabels);
            else
                LABELCHOICE = 0;
                label = guiObject.project.labels(CURRENT_LABEL);
                set(hlabels,'Value',CURRENT_LABEL);
                BOXES(SELECTED_BOX).label = label;
                set(RECT_HANDLES(SELECTED_BOX).label,'String',label);
                set(hlabels,'Visible','off');
                set(hlabels,'enable','off');
                set(RECT_HANDLES(SELECTED_BOX).label,'Visible','on');
            end
        elseif strcmp(eventData.Key,'space')
            if ~isempty(BOXES)
                set(RECT_HANDLES(SELECTED_BOX).handle,'EdgeColor','r');
                set(RECT_HANDLES(SELECTED_BOX).label,'BackgroundColor','r');
                increment_selected;
                set(RECT_HANDLES(SELECTED_BOX).handle,'EdgeColor','g');
                set(RECT_HANDLES(SELECTED_BOX).label,'BackgroundColor','g');
            end
        elseif strcmp(eventData.Key,'delete')
            % delete selected rectangle
            if ~isempty(BOXES)
                delete(RECT_HANDLES(SELECTED_BOX).handle);
                delete(RECT_HANDLES(SELECTED_BOX).label);
                RECT_HANDLES(SELECTED_BOX) = [];
                BOXES(SELECTED_BOX) = [];
                if ~isempty(BOXES)
                    SELECTED_BOX = length(BOXES);
                    set(RECT_HANDLES(SELECTED_BOX).handle,'EdgeColor','g');
                    set(RECT_HANDLES(SELECTED_BOX).label,'BackgroundColor','g');
                else
                    BOXES = [];
                    RECT_HANDLES = [];
                end
                set(guiObject.fProject,'Name','Ground Truth Tool 1.0 (UNSAVED CHANGES)'); 
            end
        end
    end
    
    function redraw_gui(im)
        imH = size(im,1);
        imW = size(im,2);
        axH = min(imH,0.8*screen(4)); % size of axes to accomodate image
        axW = min(imW,0.8*screen(3));
        currH = max(axH+barHeight,figH);
        set(guiObject.fProject,'Position',[figX,figY,sidebarW+axW,currH]);
        set(himg,'Position',[sidebarW,barHeight,axW,axH]);
        set(hbar,'Position',[sidebarW,0,axW,barHeight],...
                 'XLim',[1,axW],'YLim',[1,barHeight]);
        % draw rectangle on bottom bar
        rectangle(...
            'Parent',hbar,...
            'Position',[0,0,axW,barHeight],...
            'EdgeColor','b',...
            'FaceColor','b');
        set(hlogo,'Position',[0,currH-2*buttonH,sidebarW,2*buttonH]);
        set(hnewp,'Position',[0,currH-3*buttonH,sidebarW,buttonH]);
        set(hsavep,'Position',[0,currH-4*buttonH,sidebarW,buttonH]);
        set(hloadp,'Position',[0,currH-5*buttonH,sidebarW,buttonH]);
        set(hstep1,'Position',[0,currH-6*buttonH,sidebarW/2,buttonH]);
        set(hstep2,'Position',[sidebarW/2,currH-6*buttonH,sidebarW/4,buttonH]);
        set(hinfotext,'Position',[0,currH-14*buttonH,sidebarW,7*buttonH]);
        set(hxytext,'Position',[axW,2,sidebarW,barHeight-2]);
        set(hcurrframe2,'String',sprintf('%d/%d',guiObject.project.current,guiObject.project.nframes));
        set_filename;
        imshow(im,'Parent',himg);
        clear_im;
        draw_boxes;
    end

    % NEW PROJECT BUTTON
    function new_Callback(~,~)
        choice = save_query;
        if choice == 0
            return;
        elseif choice == 1;
            [filename,pathname] = uigetfile({'*.avi;*.mp4;*.jpg;*.png;*.txt',...
                                         '(*.mp4,*.avi,*.jpg,*.png,*.txt)'},...
                                         'Select a video, image, or .txt to open');
            if ~filename
                return;
            end
            closereq;
            gt_project(strcat(pathname,filename));
        end
    end

    % SAVE PROJECT button
    function save_Callback(~,~)
        save_noquery;
    end

    % LOAD PROJECT button
    function load_Callback(~,~)
        choice = save_query;
        if choice == 0
            return;
        elseif choice == 1
            [filename,pathname] = uigetfile('*.mat','Select a .mat file to open');
            if ~filename
                return;
            end
            closereq;
            gt_project(strcat(pathname,filename));
        end
    end

    % PREV button
    function prev_Callback(~,~)
        load_prev;
    end

    % NEXT button
    function next_Callback(~,~)
        load_next;
    end

    % step edit box
    function step_Callback(~,~)
        guiObject.project.step = str2double(get(hstep2,'String'));
        set(guiObject.fProject,'Name','Ground Truth Tool 1.0 (UNSAVED CHANGES)'); 
    end

    % MOUSE OVER
    function MouseOverImg(~,~)
         point = round(get(himg,'CurrentPoint'));
         pfig = round(get(guiObject.fProject,'CurrentPoint'));
         bounds = get(himg,'position');
         lx = bounds(1);
         ly = bounds(2);
         lw = bounds(3);
         lh = bounds(4);
         if pfig(1) >= lx && pfig(1) <= (lx+lw) && pfig(2) >= ly && pfig(2) <= (ly+lh)
             set(hxytext,'String',sprintf('x: %d, y: %d',point(1,1),point(1,2))); 
             if ~isempty(IS_BUTTON_DOWN) && IS_BUTTON_DOWN
                 RECT_END_COORD = [point(1,1) point(1,2)];
                 x = RECT_START_COORD(1);
                 y = RECT_START_COORD(2);
                 w = RECT_END_COORD(1)-x;
                 h = RECT_END_COORD(2)-y;
                 
                 if w>0 && h>0
                     if isempty(CURRENT_RECT)
                         CURRENT_RECT = rectangle(...
                             'Parent',himg,...
                             'Position',[x,y,w,h],...
                             'EdgeColor','y',...
                             'LineStyle','--');
                     else
                         set(CURRENT_RECT,...
                             'Parent',himg,...
                             'Position',[x,y,w,h],...
                             'LineWidth',1,...
                             'EdgeColor','y',...
                             'LineStyle','--');
                     end
                 end
             end
         else
             set(hxytext,'String','');
         end
    end

    % MOUSE UP
    function MouseUpImg(~,~)
        IS_BUTTON_DOWN = false;  
        pos = get(CURRENT_RECT,'Position');
        
        % Don't do anything if the mouse hasn't moved much (to prevent
        % accidental clicks)
        if isempty(pos)
            return;
        elseif sqrt(pos(3)^2+pos(4)^2) <= 10
            return;
        end
        
        set(CURRENT_RECT,...
            'EdgeColor','g',...
            'LineStyle','-',...
            'LineWidth',2);
        if isempty(BOXES)
            BOXES = struct('pos',pos,'label',[]);
            RECT_HANDLES = struct('handle',CURRENT_RECT,'label',[]);
            RECT_HANDLES.label = uicontrol(...
                'Style','text',...
                'BackgroundColor','g',...
                'ForegroundColor','k',...
                'HorizontalAlignment','left',...
                'FontSize',12,...
                'Position',[(axW/imW)*pos(1)+sidebarW-1,(axH+barHeight)-(axH/imH)*pos(2),120,20],...
                'String','',...
                'Visible','off');
        else
            BOXES(end+1).pos = pos;
            set(RECT_HANDLES(end).handle,'EdgeColor','r');
            set(RECT_HANDLES(end).label,'BackgroundColor','r');
            RECT_HANDLES(end+1).handle = CURRENT_RECT;
            RECT_HANDLES(end).label = uicontrol(...
                'Style','text',...
                'BackgroundColor','g',...
                'ForegroundColor','k',...
                'HorizontalAlignment','left',...
                'FontSize',12,...
                'Position',[(axW/imW)*pos(1)+sidebarW-1,(axH+barHeight)-(axH/imH)*pos(2),120,20],...
                'String','',...
                'Visible','off');
        end
        SELECTED_BOX = length(BOXES);
        CURRENT_RECT = [];

        set(guiObject.fProject,'Name','Ground Truth Tool 1.0 (UNSAVED CHANGES)'); 
    end

    % MOUSE DOWN
    function MouseDownImg(~,~)
        IS_BUTTON_DOWN = true;
        % get top left corner of rectangle
        pfig = round(get(guiObject.fProject,'CurrentPoint'));
        point = round(get(himg,'CurrentPoint'));
        bounds = get(himg,'Position');
        lx = bounds(1);
        ly = bounds(2);
        lw = bounds(3);
        lh = bounds(4);
        if pfig(1) >= lx && pfig(1) <= (lx+lw) && pfig(2) >= ly && pfig(2) <= (ly+lh)
            RECT_START_COORD = [point(1,1) point(1,2)];
        end
    end

    % POPUP LABELS
    function popuplabels_callback(~,~)
        CURRENT_LABEL = get(hlabels,'Value');
    end

    % read next image and draw on axes
    function load_next
        % copy back boxes of current frame before proceeding
        gtdata(guiObject.project.current).frame = BOXES;
        im = load_next_im(guiObject);
        if isempty(im)
            return;
        end
        % read in boxes of current frame
        BOXES = gtdata(guiObject.project.current).frame;
        redraw_gui(im);
    end

    % read previous image and draw on axes
    function load_prev
        % copy back boxes of current frame before proceeding
        gtdata(guiObject.project.current).frame = BOXES;
        im = load_prev_im(guiObject);
        if isempty(im)
            return;
        end
        % read in boxes of current frame
        BOXES = gtdata(guiObject.project.current).frame;
        redraw_gui(im);
    end

    % load first image and draw on axes
    function load_first
        im = load_first_im(guiObject);
        if isempty(im)
            return;
        end
        BOXES = gtdata(guiObject.project.current).frame;
        redraw_gui(im);
    end

    % Save project
    function [choice] = save_query
        gt_savequery(guiObject);
        uiwait(guiObject.fProject);
        % don't do anything
        if guiObject.save_choice == 0
            choice = 0;
            return;
        % don't save project
        elseif guiObject.save_choice == 1
            choice = 1;
            return;
        % save project
        elseif guiObject.save_choice == 2
            choice = 2;
            if isempty(guiObject.project.savename)
                [savename,savepath] = uiputfile('*.mat','Save project file as');
                guiObject.project.savename = [savepath,savename];
            end
            project = guiObject.project;
            gtdata(guiObject.project.current).frame = BOXES;
            project.gtdata = gtdata;
            save(guiObject.project.savename,'project');
            set(guiObject.fProject,'Name','Ground Truth Tool 1.0'); 
        end
    end

    function save_noquery
        if isempty(guiObject.project.savename)
            [savename,savepath] = uiputfile('*.mat','Save project file as');
            guiObject.project.savename = [savepath,savename];
        end
        project = guiObject.project;
        gtdata(guiObject.project.current).frame = BOXES;
        project.gtdata = gtdata;
        save(guiObject.project.savename,'project');
        set(guiObject.fProject,'Name','Ground Truth Tool 1.0'); 
    end

    % set filename field
    function set_filename
        if ~isempty(guiObject.project.videoreader)
            set(hfilename,'String',[guiObject.project.path,'\',guiObject.project.filenames{1}]);
        else
            set(hfilename,'String',[guiObject.project.path,'\',guiObject.project.filenames{guiObject.project.current}]);
        end
    end

    function draw_boxes
        RECT_HANDLES = [];
        if ~isempty(BOXES)
            for ii = 1:length(BOXES)
                pos = BOXES(ii).pos;
                label = BOXES(ii).label;
                RECT_HANDLES(ii).handle = rectangle(...
                    'Parent',himg,...
                    'Position',pos,...
                    'LineWidth',2,...
                    'EdgeColor','r');
                RECT_HANDLES(ii).label = uicontrol(...
                     'Style','text',...
                     'BackgroundColor','r',...
                     'ForegroundColor','k',...
                     'HorizontalAlignment','left',...
                     'FontSize',12,...
                     'Position',[(axW/imW)*pos(1)+sidebarW-1,(axH+barHeight)-(axH/imH)*pos(2),120,20],...
                     'String','',...
                     'Visible','off');
                if ~isempty(label)
                    set(RECT_HANDLES(ii).label,'String',label);
                    set(RECT_HANDLES(ii).label,'Visible','on');
                end
            end
            SELECTED_BOX = length(BOXES);
            set(RECT_HANDLES(SELECTED_BOX).handle,'EdgeColor','g');
            set(RECT_HANDLES(SELECTED_BOX).label,'BackgroundColor','g');
        end
    end

    function clear_im
        if ~isempty(RECT_HANDLES)
            for ii = 1:length(RECT_HANDLES)
                delete(RECT_HANDLES(ii).handle);
                delete(RECT_HANDLES(ii).label);
            end
        end
    end

    function increment_selected
        SELECTED_BOX = mod(SELECTED_BOX+1,length(BOXES));
        if SELECTED_BOX == 0
            SELECTED_BOX = length(BOXES);
        end
    end
end