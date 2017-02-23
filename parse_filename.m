function [project] = parse_filename( guiObject )

[path,name,ext] = fileparts(guiObject.mediafile);

% initialize project structure
project = struct(...
    'gtdata',struct('frame',[]),...
    'labels',[],...
    'path',path,...
    'filenames',[],...
    'savename',[],...
    'videoreader',[],...
    'nframes',[],...
    'current',1,...
    'step',1);

% reading new project as a list of images from directory with same
% extension as selected image
if strcmp(ext,'.jpg') || strcmp(ext,'.png')
    project.filenames = get_file_list(path,ext);
    project.nframes = length(project.filenames);
    project.gtdata = repmat(project.gtdata,project.nframes,1);
    project.labels = get_list_from_txt(guiObject.labelfile);
% reading new project as a video
elseif strcmp(ext,'.mp4') || strcmp(ext,'.avi')
    project.filenames = {[name,ext]};
    project.videoreader = VideoReader(guiObject.mediafile);
    project.nframes = project.videoreader.NumberOfFrames;
    project.gtdata = repmat(project.gtdata,project.nframes,1);
    project.labels = get_list_from_txt(guiObject.labelfile);
% reading new project as a list of image filenames
elseif strcmp(ext,'.txt')
    project.filenames = get_files_from_txt(guiObject.mediafile);
    project.nframes = length(project.filenames);
    project.gtdata = repmat(project.gtdata,project.nframes,1);
    project.labels = get_list_from_txt(guiObject.labelfile);
% loading a previous project into workspace
elseif strcmp(ext,'.mat')
    load(guiObject.mediafile);
end

end