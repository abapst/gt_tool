function [ img ] = load_next_im(guiObject)

    project = guiObject.project;

    path = project.path;
    n = project.current;
    nFrames = project.nframes;
    step = project.step;

    % read next frame
    if n+step <= nFrames
        if ~isempty(project.videoreader)
            img = read(project.videoreader,n+step);
        else
            img = imread([path, '\', project.filenames{n+step}]);
        end
        project.current = n+step;
    else
        img = [];
    end
    
    guiObject.project = project;
    
end

