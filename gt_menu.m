function gt_menu

    set(0,'units','pixels');
    screen = get(0,'screensize');
    figW = screen(3)/10;
    figX = screen(3)/4;
    figY = figX;
    buttonH = figW/6;
    figH = 4*buttonH;
    
    guiObject = gui_object; % Class container for entire program
    
    % Create and then hide the UI as it is being constructed
    guiObject.fMenu = figure('Visible','off','Units','Pixels',...
               'Position',[figX,figY,figW,figH],...
               'NumberTitle','off',...
               'MenuBar','none','Toolbar','auto');
    
    % Construct the components.
    hlogo = axes('Units','Pixels','Position',[0,figH-2*buttonH,figW,2*buttonH]);
    hnew = uicontrol('Style','pushbutton','String','New Project',...
             'Position',[0,figH-3*buttonH,figW,buttonH],'FontSize',20,...
             'TooltipString','Start a new project by opening an image or video',...
             'Callback',{@new_Callback});
    hload = uicontrol('Style','pushbutton','String','Load Project',...
             'Position',[0,figH-4*buttonH,figW,buttonH],'FontSize',20,...
             'TooltipString','Load a saved project',...
             'Callback',{@load_Callback});
    
    % load logo image
    [logo,~,alpha] = imread('assets\logo.png');
    imlogo = imshow(logo,'Parent',hlogo);
    set(imlogo,'alphadata',alpha);
    
    % Make the UI visible.
    guiObject.fMenu.Name = 'Ground Truth Tool 1.0';
    movegui(guiObject.fMenu,'center');
    guiObject.fMenu.Visible = 'on';

    function new_Callback(~,~)
        [filename,filepath] = uigetfile({'*.avi;*.mp4;*.jpg;*.png;*.txt',...
                                     '(*.mp4,*.avi,*.jpg,*.png,*.txt)'},...
                                     'Select a video, image, or .txt to open');
        if ~filename
            return;
        end   
        [labelname,labelpath] = uigetfile('*.txt',...
                                     'Select a .txt labels file');
        if ~labelname
            return;
        end
        closereq;
        guiObject.mediafile = strcat(filepath,filename);
        guiObject.labelfile = strcat(labelpath,labelname);
        gt_project(guiObject);
    end

    function load_Callback(~,~)
        [filename,pathname] = uigetfile('*.mat','Select a .mat file to open');
        if ~filename
            return;
        end
        closereq;
        guiObject.mediafile = strcat(pathname,filename);
        gt_project(guiObject);
    end
end