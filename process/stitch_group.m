function canvas = stitch_group (group_no)

%% machine-dependent variables
pathnameinput = '..\\input\\';                      % input path
pathnameoutput = '..\\output\\';                    % output path

%% constants
image_dim = 1024;
group_no_max = 7;
patch_no_max = 24;
patch_no_white = 0;

canvas = uint8(zeros(image_dim*4,image_dim*6,3));

for patch_no = 0:patch_no_max             % for each patch in ColorChecker from 1 to 24
    
    fn = sprintf('%s\\Group%d_ (%d).png',pathnameinput,group_no,patch_no);
    rgb = imread(fn);
    
    if patch_no == 0
        idx = 24
    else
        idx = patch_no - 1; % 0-23
    end
    
    row = uint16(floor(idx/6));
    col = uint16(mod(idx,6));
    
    x1 = 1 + col*image_dim;
    x2 = x1 + image_dim-1;
    y1 = 1 + row*image_dim;
    y2 = y1 + image_dim-1;
    
    
    canvas(y1:y2,x1:x2,:) = rgb;
    
    if 0
        subplot(4,7,patch_no)
        image(rgb)
        axis off
        axis image
    end
end

if 0
    image(canvas)
    axis off
    axis image
end

end

