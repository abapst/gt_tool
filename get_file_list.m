function [ filenames ] = get_file_list( path,ext )

filenames = dir([path,'\*',ext]);
filenames = sortrows({filenames(:).name}');

end

