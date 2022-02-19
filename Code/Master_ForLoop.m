%% Clear Workspace
clear

%% Initialize some stuffs
B = linspace(0, 3, 31);
A = linspace(1, 5, 61);
E = linspace(5, 12, 40);
accuracy = zeros(1,length(A));

num = 0;

for i = 1:length(A)
%% Data Generation
intervals = [A(i)   A(i)       % amplitude
             0.5   0.5       % magnetic field
             8   8       % energy (bigger than 1)
             200 200     % smo (smaller than 400)
             2   3       % nu exponent of Gaussian or Lorentzian
             40  40      % ld
             1   1       % ni density
             ];
         
nImages = 50000;
nPlots = 0; % number of potentials plotted   

rawDataFilename = generatedata(intervals, nImages, nPlots);

disp(strcat("The raw data has been saved at ", rawDataFilename));

%% Data Formatting
saveVariables = [true    % amplitude
                 false     % magnetic field
                 false    % energy
                 false    % smo
                 true    % nu
                 false    % ld
                 false    % ni
                 ];

trainRatio = 0.7;   % ratio of images for training
valRatio   = 0.1;   % ratio of images for validation
testRatio  = 0.2;   % ratio of images for testing

formattedDataFilename = formatdata(rawDataFilename, saveVariables, ...
    trainRatio, valRatio, testRatio);

disp(strcat("The formatted data has been saved at ", formattedDataFilename));

%% Sort Shape
[sortedDataFilename, result] = trainqcnnclass(formattedDataFilename);
disp(strcat("The sorted data has been saved at ", sortedDataFilename));
accuracy(i) = result; %%%%%%%%%%%%%%%%%%%
num = num + 1

end

figure
plot(B, accuracy)
ylabel('Accuracy')
xlabel('B')




 
% %% Train QCNN
% networkFilename = trainqcnn(sortedDataFilename);
% 
% disp(strcat("The trained network has been saved at ", networkFilename));
% 
% %% Plot Data
% plotdata(networkFilename);
