function plotDis(loadFilename)
%% Loading data
load(loadFilename,...
    'predY', 'yTest',...
    'saveVariables', 'intervals', 'names', ...
    'trainedCNN');
%% Sorting data and distribute into blocks
resolution = 100;
min_y = intervals(saveVariables, 1);
max_y = intervals(saveVariables, 2);
interval_y = max_y - min_y;
includedNames = names(saveVariables);

for iName = 1:length(includedNames)
    [ySorted(:,iName), index] = sort(yTest(:,iName));
    yDivided(:,:,iName) = reshape(ySorted(:,iName),...
        [resolution, length(yTest(:,iName))/resolution]);
    %% Passing the value for the new xTest array
    xSorted = zeros(24, 48, 1, length(yTest));
    for i = 1 : length(index)
        xSorted(:,:,:,i) =  xTest(:,:,:,index(i));
    end
    xDivided = reshape(xSorted,...
        [24, 48, resolution, length(yTest(:,iName))/resolution]);
    
    %% Now to the y
    for ii = 1 : size(yDivided, 2)
        result = predict(trainedCNN, ...
            permute(xDivided(:,:,:,ii), [1 2 4 3])); 
        yPred(:,ii,iName) = result(:,iName); 
    end
    
    for jj = 1 : size(yPred,2)
        Dis(1,jj,iName) = mean(abs(yPred(:,jj,iName) - ...
            yDivided(:,jj,iName)));
    end
    x(:,:,iName) = linspace(0, 1, length(yTest(:,iName))/resolution);
    plot(x(1,:,iName), Dis(1,:,iName))
    clear index xSorted xDivided
end

%% Plotting
for iName = 1: length(includedNames)
    if (iName == 1)
        plot(x(1,:,iName), Dis(1,:,iName))
        hold on
    elseif (iName == 2)
        plot((x(1,:,iName)), ...
            (Dis(1,:,iName) + Dis(1,:,iName - 1)))
        hold on
    elseif (iName == 3)
        plot((x(1,:,iName)), ...
            (Dis(1,:,iName) + Dis(1,:,iName - 1) + Dis(1,:,iName - 2)))
        hold on
    else
        plot((x(1,:,iName)), ...
            (Dis(1,:,iName) + Dis(1,:,iName - 1) + ...
            Dis(1,:,iName - 2) + Dis(1,:,iName - 3)))
        hold on
    end
end


end

