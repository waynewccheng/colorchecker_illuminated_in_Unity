%% Create a 24-patch ColorChecker as an image file as well as an image matrix
% 6-29-2018: reviewed
% 7-16-2014: reviewed

function im = lab2colorchecker24 (lab24x3)

% if the RGB matrix is not given, use the data provided by X-Rite

if nargin ~= 1
    
    rgb24x3 = [
        115 82  68;
        194 150 130;
        98  122 157;
        87  108 67;
        133 128 177;
        103 189 170;
        
        214 126 44;
        80  91  166;
        193 90  99;
        94  60  108;
        157 188 64;
        224 163 46;
        
        56  61  150;
        70  148 73;
        175 54  60;
        231 199 31;
        187 86  149;
        8   133 161;
        
        243 243 242;
        200 200 200;
        160 160 160;
        122 122 121;
        85  85  85;
        52  52  52
        ];
    
else

    rgb24x3 = lab2rgb(lab24x3,'ColorSpace','srgb','WhitePoint','d65');
    
end

% define the dimensions
number_of_patches_x = 6;
number_of_patches_y = 4;

% size of each patch
dx = 100;
dy = 100;

% canvas
im = zeros(dy*number_of_patches_y,dx*number_of_patches_x,3);

% for each color
for i=0:23
    y = floor(i/number_of_patches_x);
    x = mod(i,number_of_patches_x);
    for j=1:3
        im(dy*y+1:dy*(y+1),dx*x+1:dx*(x+1),j) = rgb24x3(i+1,j);
    end;
end

% show the image
image(im)
axis image
axis off

% create an image file
imwrite(im,'colorchecker24.tif');

end