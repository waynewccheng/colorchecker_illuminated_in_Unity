%% for Andrea's ACM submission

%% reorganized for Andrea's ACM submission
% 7-9-2019
% 7-10-2019 changed to IPO model
%
% file/folder structure:
%  .\process\dE_self_reference_white    -- this file
%  .\input                              -- input images
%  .\output                             -- results

%% modified to use a single reference white for 7 configurations
% 7-11-2019

function dE_ACM

%% machine-dependent variables
pathnameinput = '..\\input\\';                      % input path
pathnameoutput = '..\\output\\';                    % output path

%% constants
image_dim = 1024;
group_no_max = 7;
patch_no_max = 24;
patch_no_white = 0;

%% deliverables
lab_truth = zeros(patch_no_max,3);
lab_measure = zeros(group_no_max,patch_no_max,3);
dE = zeros(group_no_max,patch_no_max);


%% main

%
% calculate the truth (Group #0)
%
lab_truth = do_truth;

%
% calculate the measured patches (Group #1-7)
%
for i = 1:group_no_max
    lab_measure(i,:,:) = do_measure(i);
end

%
% calculate dE between Group #i and Group #0
%
for i = 1:group_no_max
    lab_sample = squeeze(lab_measure(i,:,:));
    dE(i,:) = lab2dE76(lab_truth,lab_sample);
end

%
% save the data
%
save(sprintf('%s\\results',pathnameoutput),'lab_truth','lab_measure','dE') % in Matlab

xlswrite(sprintf('%s\\dE.xls',pathnameoutput),dE')           % in Excel


return

%
% use Group #0 -- Unity input -- as the truth
% convert using sRGB model because it is the truth
% should be uniform images
% return a 24x3 matrix
%
    function lab = do_truth
        
        lab = zeros(patch_no_max,3);              % return data
        
        group_no = 0;                             % use Group #0
        for patch_no = 1:patch_no_max             % for each patch in ColorChecker from 1 to 24
            
            rgb_lin = get_rgb(group_no,patch_no); % read pixels
            
            % use sRGB model to convert RGB to CIELAB
            lab_lin = rgb2lab(rgb_lin,'ColorSpace','srgb','WhitePoint','d50');
            
            lab_mean = mean(lab_lin,1);    % take average of the uniform image
            
            lab(patch_no,:) = lab_mean;
            
        end
    end

%
% calculate Group #i -- Unity output
% convert RGB to LAB
% use patch #0 as the reference white
% return a 24x3 matrix
%
    function lab = do_measure (group_no)
        
        lab = zeros(patch_no_max,3);              % return data
        
        %
        % get CIEXYZ of the reference white
        %
        rgb_lin0 = get_rgb(group_no,patch_no_white);
        
        xyz_lin0 = calc_rgb_to_xyz(rgb_lin0);
        
        xyz0 = calc_xyz_roi(xyz_lin0);
        
        for patch_no = 1:patch_no_max             % for each patch in ColorChecker from 1 to 24
            
            %
            % get CIEXYZ of the patch
            %
            rgb_lin = get_rgb(group_no,patch_no);
            
            xyz_lin = calc_rgb_to_xyz(rgb_lin);
            
            xyz = calc_xyz_roi(xyz_lin);
            
            %
            % calculate CIELAB using WCC's code
            %
            lab(patch_no,:) = XYZ2lab(xyz,xyz0);
            
        end
        
    end


%
% read the pixels of one patch
% return a 1D vector
%
    function rgb_lin = get_rgb (group_no, patch_no)
        fn = sprintf('%s\\Group%d_ (%d).png',pathnameinput,group_no,patch_no);  % construct filename
        rgb = imread(fn);
        
        rgb_lin = reshape(rgb,size(rgb,1)*size(rgb,2),3);
    end

%
% convert RGB to XYZ
% use Matlab funciton -- need to verify again
% 
    function xyz = calc_rgb_to_xyz (rgb)
        xyz = rgb2xyz(rgb,'ColorSpace','srgb','WhitePoint','d50');
    end

%
% average all pixels in the ROI in the CIEXYZ space
% for now the ROI is the whole patch
% input is k*3
%
    function xyz = calc_xyz_roi (xyz_lin)
        xyz = mean(xyz_lin,1);
    end

end


%
% deltaE
%
function dE = lab2dE76 (lab1,lab2)

dE = sum((lab1 - lab2).^ 2,2).^0.5;

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
