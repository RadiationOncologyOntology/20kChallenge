function printCrop(filename, filetype, resolution, imageWhiteMargin)

% check if whiteMargin is valid
if imageWhiteMargin<=0 || mod(imageWhiteMargin, 1)
    error('White margin for saving figure is not a positive whole number (%f)', imageWhiteMargin);
end

% save image file using print()
print(filename, filetype, resolution);
pause(1);

% read image file we just saved
im = imread(filename);

% convert to double and sum
imArray = double(im);
imArray = sum(imArray, 3);

% sum over columns and rows
imArraySumCol = sum(imArray, 2);
imArraySumRow = sum(imArray, 1);

% find first/last non-white pixels
cropTop = find(imArraySumCol ~= 255*3*length(imArraySumRow),1,'first');
cropBottom = find(imArraySumCol ~= 255*3*length(imArraySumRow),1,'last');

cropLeft = find(imArraySumRow ~= 255*3*length(imArraySumCol),1,'first');
cropRight = find(imArraySumRow ~= 255*3*length(imArraySumCol),1,'last');

% make sure we don't exceed image boundaries 
cropTop = max([cropTop 1]);
cropBottom = min([cropBottom size(im,1)]);

cropLeft = max([cropLeft 1]);
cropRight = min([cropRight size(im, 2)]);

% crop the image
imageCropped = im(cropTop:cropBottom, cropLeft:cropRight, :);

% add white margin around image
imageCroppedWhiteMargin = 255*ones(size(imageCropped)+2*imageWhiteMargin*[1 1 0],'uint8');
imageCroppedWhiteMargin((1:size(imageCropped,1))+imageWhiteMargin, (1:size(imageCropped,2))+imageWhiteMargin,:) = imageCropped;

% % debug
% figure;
% image(imageCroppedWhiteMargin)

% save image
imwrite(imageCroppedWhiteMargin, filename);