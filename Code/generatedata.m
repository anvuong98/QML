function [saveFilename] = generatedata(intervals, nImages, nPlots)

range = nImages / nPlots;
names = {'A', 'B', 'En', 'smo', 'nu', 'ld', 'ni' };
         
shapeFactor = [0 1];  % 0 for Gaussian, 1 for Lorenztian
shapeName = {'Gaussian', 'Lorentzian'};

h = 24;
w = 48;

%% Compute Random Values
y = rand(nImages, size(intervals, 1));
yScaled = zeros(nImages, size(intervals+1, 1));

for iDim = 1:size(intervals, 1)
    yScaled(:, iDim) = ...
        (intervals(iDim, 2) - intervals(iDim, 1)) * y(:, iDim) + ...
        intervals(iDim, 1);
end
shapeIndex = randi(2,nImages,1) - 1 ; 

%% Generate LDOS
LDOST = zeros([h w 1 nImages], 'double');
%%%%%MUST FIX THE TITLE 
for iImage = 1:nImages
    [LDOST(:,:,1,iImage),U] = ...
        generateldos(yScaled(iImage, 1), ...
                     yScaled(iImage, 2), ...
                     yScaled(iImage, 3), ...
                     yScaled(iImage, 4), ...
                     yScaled(iImage, 5), ...
                     yScaled(iImage, 6), ...
                     yScaled(iImage, 7), ...
                     shapeIndex(iImage, 1));
     if nPlots > 0 && mod(iImage/range,1) == 0
         figure(1);pause(0)
         subplot(2,1,1);surf(LDOST(:,:,iImage));shading interp;...
             view(0,90);colorbar;
         subplot(2,1,2);surf(U);shading interp;view(0,90);colorbar;
         precision = 3;
         titileCellArray = cell(1, length(names) +  1);
         titleCellArray{1} = strcat('N=', num2str(iImage));
         for iName = 1:length(names)
             titleCellArray{iName+1} = ...
               strcat(names{iName}, '=', num2str(yScaled(iImage,iName),3));
         end
         title(join(titleCellArray, ' '))
     end
end

%% Name File 
shortNames = ['A', 'B', 'E', 'S', 'N', 'L', 'D'];

saveFilename = generatefilename( ...
    strcat('RawData/', ...
    shortNames(diff(intervals, 1, 2) ~= 0), ...
    '_', ...
    num2str(floor(nImages/1000)), ...
    '_R'), '.mat');


%% Save data
save(saveFilename, ...
     'names', 'nImages', 'intervals', ...
     'LDOST', 'y', 'h', 'w', 'nImages', ...
     'shapeFactor','shapeIndex','shapeName')
 