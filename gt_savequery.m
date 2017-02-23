function gt_savequery(varargin)

    set(0,'units','pixels');
    screen = get(0,'screensize');
    figW = screen(3)/10;
    figX = screen(3)/4;
    figY = figX;
    buttonH = figW/6;
    figH = 2*buttonH;
    
    guiObject = varargin{1};
    
    % Create and then hide the UI as it is being constructed
    f = figure('Visible','off','Units','Pixels',...
               'Position',[figX,figY,figW,figH],...
               'NumberTitle','off',...
               'MenuBar','none','ToolBar','auto');
    
    % Construct the components.
    htext = uicontrol('Style','text',...
             'String','Save current project before continuing?',...
             'Position',[0,figH-buttonH,figW,buttonH],...
             'FontSize',12);
    hyes = uicontrol('Style','pushbutton','String','Yes',...
            'Position',[0,figH-2*buttonH,figW/3,buttonH],'FontSize',16,...
            'Callback',{@yes_Callback});
    hno = uicontrol('Style','pushbutton','String','No',...
             'Position',[figW/3,figH-2*buttonH,figW/3,buttonH],'FontSize',16,...
             'Callback',{@no_Callback});
    hcancel = uicontrol('Style','pushbutton','String','Cancel',...
             'Position',[2*figW/3,figH-2*buttonH,figW/3,buttonH],'FontSize',16,...
             'Callback',{@cancel_Callback});
    
    % Make the UI visible.
    f.Name = 'Ground Truth Tool 1.0';
    movegui(f,'center');
    f.Visible = 'on';

    function yes_Callback(source,eventdata)
        guiObject.save_choice = 2;
        closereq;
        uiresume(guiObject.fProject);
    end

    function no_Callback(source,eventdata)
        guiObject.save_choice = 1;
        closereq;
        uiresume(guiObject.fProject);
    end

    function cancel_Callback(source,eventdata)
        guiObject.save_choice = 0;
        closereq;
        uiresume(guiObject.fProject);
    end
end