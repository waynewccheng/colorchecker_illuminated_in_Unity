%% for Andrea's CIE poster
% using corresponding pixel as reference white
% 6-6-2019

%% reorganized for Andrea's ACM submission
% 7-9-2019
% 7-10-2019 changed to IPO model
%
% file/folder structure:
%  .\process\dE_self_reference_white    -- this file
%  .\input                              -- input images
%  .\output                             -- results



function dE_self_reference_white

%% machine-dependent variables
pathnameinput = '..\\input\\';                      % input path
pathnameoutput = '..\\output\\';                    % output path

image_dim = 1024;

ddE = zeros(4,24,image_dim,image_dim);          % for dE, 2D
ddE_lin = zeros(4,24,image_dim*image_dim);      % for dE, 1D

for group_no = 1:4                  % for each group from 1 to 4
    
    for patch_no = 1:24             % for each patch in ColorChecker from 1 to 24
        
        % get the output from Unity
        
        if group_no == 2                        % new setting changed naming convention for Group 2
            fn_out = sprintf('%s\\Group%dv2_ (%d).png',pathnameinput,group_no,patch_no);
        else
            fn_out = sprintf('%s\\Group%d_ (%d).png',pathnameinput,group_no,patch_no);
        end
        
        im_out = imread(fn_out);
        
        
        % convert to CIELAB using sRGB
        % assuming sRGB and d50 for Unity
        lab = rgb2lab(im_out,'ColorSpace','srgb','WhitePoint','d50');
        lab_lin = reshape(lab,size(im_out,1)*size(im_out,2),3);
        
        
        %% build input patch (i.e., the reference white)
        % use self -- reference to the center pixel of the same image
        % notice that we are not using Group #0 as the reference
        % modify this part to pick your reference white
        im_in = im_out;
        
        % condition the reference
        center_rgb = squeeze(im_in(image_dim/2,image_dim/2,:));    % the center pixel
        im_in(:,:,1) = center_rgb(1);
        im_in(:,:,2) = center_rgb(2);
        im_in(:,:,3) = center_rgb(3);
        im_in_lin = reshape(im_in,size(im_in,1)*size(im_in,2),3);
        
        % convert to CIELAB using sRGB
        % equivalent to using an sRGB display without any rendering
        lab0 = rgb2lab(im_in,'ColorSpace','srgb','WhitePoint','d50');
        lab0_lin = rgb2lab(im_in_lin,'ColorSpace','srgb','WhitePoint','d50');
        
        %% calculate the color differences
        % use the simplest dE formula here
        % modify this part to use dE94 or dE00
        dE_lin = lab2dE76(lab_lin,lab0_lin);
        
        dE = reshape(dE_lin,size(im_in,1),size(im_in,2));
        
        % save the result in a big matrix for reporting
        ddE(group_no,patch_no,:,:) = dE;
        ddE_lin(group_no,patch_no,:) = dE_lin;
        
        
        
        %% visualization
        
        clf
        
        % 1st row
        subplot(3,5,1)
        image(im_in), axis image, axis off
        title('Input')
        
        %         subplot(3,5,2)
        %         image(im_in_ref), axis image, axis off
        %         title('Input Ref')
        
        subplot(3,5,3)
        show_plot(lab0(:,:,1),'L*')
        
        subplot(3,5,4)
        show_plot(lab0(:,:,2),'a*')
        
        subplot(3,5,5)
        show_plot(lab0(:,:,3),'b*')
        
        % 2nd row
        subplot(3,5,6)
        image(im_out), axis image, axis off
        title('Output')
        
        %         subplot(3,5,7)
        %         image(im_out_ref), axis image, axis off
        %         title('Output Ref')
        
        subplot(3,5,8)
        show_plot(lab(:,:,1),'L*')
        
        subplot(3,5,9)
        show_plot(lab(:,:,2),'a*')
        
        subplot(3,5,10)
        show_plot(lab(:,:,3),'b*')
        
        % 3rd row
        subplot(3,5,11)
        show_plot(dE,'{\Delta}E')
        
        subplot(3,5,13)
        show_plot(lab(:,:,1)-lab0(:,:,1),'{\Delta}L*')
        
        subplot(3,5,14)
        show_plot(lab(:,:,2)-lab0(:,:,2),'{\Delta}a*')
        
        subplot(3,5,15)
        show_plot(lab(:,:,3)-lab0(:,:,3),'{\Delta}b*')
        
        % capture the figure
        saveas(gcf,sprintf('%s\\G%dP%d.png',pathnameoutput,group_no,patch_no))
        
    end
    
end

%% save the dE data from the first half
save(sprintf('%s\\dEresult',pathnameoutput),'ddE','ddE_lin')

% so new analysis does not need to recompute dE and can start here
load(sprintf('%s\\dEresult',pathnameoutput),'ddE_lin')

%% visualization with a boxplot
clf

for i = 1:4
    a = squeeze(ddE_lin(i,:,:));
    subplot(2,2,i)
    boxplot(a')
    axis([1 24 0 30])
    title(sprintf('Group %d',i))
end

% capture the figure
saveas(gcf,sprintf('%s\\Finding Self Boxplot.png',pathnameoutput))

return



    function show_plot (data, name)
        % data: 2D array of either L*, a*, or b*
        % intended to show the Lab values with pseudocolor
        % use an interval [range_min,range_max] to scale the data
        range_max = 100;
        range_min = -100;
        
        % create my own heatmap as "colorim"
        data_1d = reshape(data,size(data,1)*size(data,2),1);
        colorim_1d = zeros(size(data_1d,1),3);
        
        % show negative values in red
        mask_negative = data_1d(:,1) < 0;
        mask_data = data_1d(mask_negative,1);
        colorim_1d(mask_negative,1) = (-mask_data-range_min)/(range_max-range_min)*255;
        
        % show positive values in green
        mask_data = data_1d(~mask_negative,1);
        colorim_1d(~mask_negative,2) = (mask_data-range_min)/(range_max-range_min)*255;
        
        colorim = reshape(colorim_1d,size(data,1),size(data,2),3);
        
        image(uint8(colorim)), axis image, axis off
        
        % also report the mean to identify uniform patterns
        mn = mean(mean(data));
        title(sprintf('%s=%.2f',name,mn))
    end

end

%
% deltaE
%
function dE = lab2dE76 (lab1,lab2)

dE = sum((lab1 - lab2).^ 2,2).^0.5;

end


%
% convert an RGB image to CIELAB
% im is the target image in RGB 
% im_ref if the reference white in RGB 
function lab_lin = images2lab (im, im_ref)

% convert RGB to XYZ for im
im_1d = reshape(im,size(im,1)*size(im,2),3);
xyz_1d = rgb2xyz(im_1d,'ColorSpace','srgb','WhitePoint','d50');

% convert RGB to XYZ for im_ref
im_ref_1d = reshape(im_ref,size(im_ref,1)*size(im_ref,2),3);
xyz_ref_1d = rgb2xyz(im_ref_1d,'ColorSpace','srgb','WhitePoint','d50');

% convert XYZ to LAB
lab_lin = XYZ2lab(xyz_1d,xyz_ref_1d);
lab = reshape(lab_lin,size(im,1),size(im,2),3);

if 0
    % visualize for debugging
    xyz1 = reshape(xyz1_1d,size(im1,1),size(im1,2),3);
    xyz2 = reshape(xyz2_1d,size(im1,1),size(im1,2),3);
    
    subplot(1,3,1)
    imagesc(xyz1(:,:,2)), axis image, axis off
    
    subplot(1,3,2)
    imagesc(xyz2(:,:,2)), axis image, axis off
    
    subplot(1,3,3)
    imagesc(lab(:,:,1)), axis image, axis off
end

end

%%
%
% CIEXYZ to CIELAB
%
function ret = XYZ2lab (XYZ, XYZ_white)
% XYZ is k-by-3
% XYZ_white is k-by-3

k = size(XYZ,1);
XYZn = XYZ_white;
XYZ_over_XYZn = XYZ./XYZn;

lstar = 116 * helpf(XYZ_over_XYZn(:,2)) - 16;
astar = 500 * (helpf(XYZ_over_XYZn(:,1)) - helpf(XYZ_over_XYZn(:,2)));
bstar = 200 * (helpf(XYZ_over_XYZn(:,2)) - helpf(XYZ_over_XYZn(:,3)));

ret=[lstar astar bstar];

%
% out-of-range check
%
%     if lstar > 100
%         ['exceeding in xyz2lab']
%         [x y z xn yn zn lstar astar bstar]
%         lstar = 100;
%     end

return

    function ys = helpf (t)
        % conditional mask
        t_greater = (t > power(6/29,3));
        
        % conditional assignment
        t(t_greater) = t(t_greater) .^ (1/3);
        t(~t_greater) = t(~t_greater) * (((29/6)^2)/3) + 4/29;
        
        ys = t;
    end

end

