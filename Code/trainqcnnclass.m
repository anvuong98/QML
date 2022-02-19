function [saveFilename, result] = trainqcnnclass(loadFilename) %%get rid of result
%% Load Data
load(loadFilename, ...
     'saveVariables', 'names', ...
     'intervals', 'outDim', ...
     'xTrain', 'yTrain', 'yClassTrain',...
     'xVal', 'yVal', 'yClassVal',...
     'xTest', 'yTest', 'yClassTest',...
     'shape','shapeIndex',...
     'h', 'w', ...
     'nImages')
 
%% specify training parameters
mod = 1;
%%%%%% Bring back training-progress 
options = trainingOptions('sgdm',...
    'Plots','none',...
    'ExecutionEnvironment','auto',...
    'Verbose',0,...
    'VerboseFrequency',200,...
    'Shuffle','every-epoch',...
    'InitialLearnRate',0.1,... 
    'LearnRateSchedule','piecewise',...
    'LearnRateDropFactor',0.9,...
    'LearnRateDropPeriod',1/mod,...
    'L2Regularization',0.001,...
    'Momentum',0.9,...
    'ValidationData',{xVal,yClassVal},...
    'ValidationFrequency',100/mod,...
    'ValidationPatience',Inf,...
    'MaxEpochs',100,... 
    'MiniBatchSize',100*mod);

%% specify network architecture
layers = [
    imageInputLayer([h w 1],'Normalization','none')
    
    convolution2dLayer(5,64,'Padding',2)
    batchNormalizationLayer  
    leakyReluLayer
    dropoutLayer
%   maxPooling2dLayer(3,'Stride',2)
    averagePooling2dLayer(4,'Stride',2)
    
    convolution2dLayer(5,128,'Padding',2)
    batchNormalizationLayer  
    leakyReluLayer
    dropoutLayer
%   maxPooling2dLayer(3,'Stride',2)
    averagePooling2dLayer(4,'Stride',2)
    
    convolution2dLayer(5,256,'Padding',2)
    batchNormalizationLayer  
    leakyReluLayer
    dropoutLayer
%   maxPooling2dLayer(3,'Stride',2)
    averagePooling2dLayer(4,'Stride',2)
    
    fullyConnectedLayer(64)
    softmaxLayer
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer];

% layers = [
%     imageInputLayer([h w 1],'Normalization','none')
%     
%     convolution2dLayer(5,128,'Padding',2)
%     batchNormalizationLayer  
%     leakyReluLayer
%     dropoutLayer
%   maxPooling2dLayer(3,'Stride',2)
%     averagePooling2dLayer(4,'Stride',2)
%     
%     convolution2dLayer(5,64,'Padding',2)
%     batchNormalizationLayer  
%     leakyReluLayer
%     dropoutLayer
%   maxPooling2dLayer(3,'Stride',2)
%     averagePooling2dLayer(4,'Stride',2)
%     
%     convolution2dLayer(5,32,'Padding',2)
%     batchNormalizationLayer  
%     leakyReluLayer
%     dropoutLayer
%   maxPooling2dLayer(3,'Stride',2)
%     averagePooling2dLayer(4,'Stride',2)
%     
%     fullyConnectedLayer(2)
%     softmaxLayer
%     classificationLayer];

%% train the network
trainedCNN = trainNetwork(xTrain, yClassTrain, layers, options);

%% analyse the result
predYClass = predict(trainedCNN, xTest);
[m,n] = size(predYClass);
for lorde=1:m
        index(lorde) = find((predYClass(lorde,:) - ...
            max(predYClass(lorde,:))) == 0);
end
final = 0;
for lana = 1:length(index)
    if (index(lana)-1) == shapeIndex(lana)
    final = final +1;
    end
end
result = final/length(index)

%% Format Data
trainG = [];
trainL = [];
for i = 1:length(yClassTrain) 
    if (yClassTrain(i) == 'Gaussian')
        trainG = horzcat(trainG, i);
    else
        trainL = horzcat(trainL, i);
    end
end
xTrain0 = xTrain(:,:,:,trainG);
yTrain0 = yTrain(trainG,:);
xTrain1 = xTrain(:,:,:,trainL);
yTrain1 = yTrain(trainL,:);



valG = [];
valL = [];
for i = 1:length(yClassVal)
   if (yClassVal(i) == 'Gaussian')
       valG = horzcat(valG, i);
   else
       valL = horzcat(valL, i);
   end
end
xVal0 = xVal(:,:,:,valG);
yVal0 = yVal(valG,:);
xVal1 = xVal(:,:,:,valL);
yVal1 = yVal(valL,:);



testG = [];
testL = [];
for i = 1:length(yClassTest)
    if (index(i) == 1)
       testG = horzcat(testG,i);
    else
       testL = horzcat(testL, i); 
    end
end
xTest0 = xTest(:,:,:,testG);
yTest0 = yTest(testG,:); 
xTest1 = xTest(:,:,:,testL);
yTest1 = yTest(testL,:);

%% Name File
shortNames = ['A', 'B', 'E', 'S', 'N', 'L', 'D'];

saveFilename = generatefilename(...
    strcat('ShapeSorted/', ...
           shortNames(diff(intervals, 1, 2) ~= 0), ...
           '_', ...
           shortNames(saveVariables), ...
           '_', ...
           num2str(floor(nImages/1000)), ...
           '_S'), '.mat');


%% Save data
save(saveFilename, ...
     'saveVariables', 'names', ...
     'intervals', 'outDim', ...
     'xTrain0', 'yTrain0',...
     'xTrain1', 'yTrain1',...
     'xVal0', 'yVal0',...
     'xVal1', 'yVal1',...
     'xTest0', 'yTest0',...
     'xTest1', 'yTest1',...
     'result', ...
     'h', 'w', ...
     'nImages', ...
     'trainedCNN', ...
     'result')

end