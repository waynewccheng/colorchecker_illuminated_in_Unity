for i = 1:7
    im = stitch_group(i);
    
    subplot(2,4,i)
    image(im)
    axis off
    axis image
    title(sprintf('Image #%d',i))
end

i = 0;
im = stitch_group(i);

subplot(2,4,8)
image(im)
axis off
axis image
title('Truth')
