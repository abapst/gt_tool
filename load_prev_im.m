function [ img ] = load_prev_im(guiObject)

    project = guiObject.project;

    path = project.path;
    n = project.current;
    step = project.step;
    
    % read previous frame
    if n-step > 0
        if ~isempty(project.videoreader)
            img = read(project.videoreader,n-step);
        else
            img = imread([path, '\', project.filenames{n-step}]);
        end
        project.current = n-step;
    else
        img = [];
    end
   
    guiObject.project = project;
end

