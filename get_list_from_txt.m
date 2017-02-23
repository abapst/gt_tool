function [ list ] = get_list_from_txt( filename )

fd = fopen(filename,'r');
line = fgetl(fd);
list = {};
cnt = 1;

while ischar(line)
    list{cnt} = line;
    cnt = cnt + 1;
    line = fgetl(fd);
end
fclose(fd);

list = list';

end

