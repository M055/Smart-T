function [maskblob reverseMaskblob] = CreateMaskbolb(imgSize, bgcolor)
% Aslin baby lab experiment
% Author: Johnny, 3/31/2008

    % We create a Color(RGB)+Alpha matrix for use as transparency mask:
    % Layer 1-3 (Color) is filled with 'backgroundcolor'.
    transLayer=4;
    maskblob=ones(imgSize+2, imgSize+2, transLayer) * bgcolor(1);
    maskblob(:,:,2)=bgcolor(2);
    maskblob(:,:,3)=bgcolor(3);
    % Layer 2 (Transparency aka Alpha) is filled with circle transparency mask.
    radius = round(imgSize/2);
    [x,y] = meshgrid(-radius:radius, -radius:radius);
    [r,c] = find(x.*x+y.*y>radius*radius);
    reverseMaskblob = maskblob;
    maskblob(:,:,transLayer)=0; % complete transparency
    reverseMaskblob(:,:,transLayer)=255; % opaque
    for j=1:length(r)
        maskblob(r(j),c(j),transLayer)=255; % opaque
        reverseMaskblob(r(j),c(j),transLayer)=0; % complete transparency
    end
end