function [ img ] = load_first_im(guiObject)

    project = guiObject.project;

    path = project.path;
    n = project.current;

    % load first frame
    if n == 1
        if ~isempty(project.videoreader)
            img = read(project.videoreader,1);
        else
            img = imread([path, '\', project.filenames{1}]);
        end
    elseif n > 1
        if ~isempty(project.videoreader)
            img = read(project.videoreader,n);
        else
            img = imread([path, '\', project.filenames{n}]);
        end
    else
        img = [];
    end
    
    guiObject.project = project;
    
end

