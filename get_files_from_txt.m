function [ filenames ] = get_files_from_txt( filename )

fd = fopen(filename,'r');

ext = fgetl(fd);
line = fgetl(fd);
filenames = {};
cnt = 1;

while ischar(line)
    filenames{cnt} = [line,ext];
    cnt = cnt + 1;
    line = fgetl(fd);
end
fclose(fd);

filenames = filenames';

end

