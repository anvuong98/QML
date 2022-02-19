%% Clear Workspace
clear

%% Data Generation
intervals = [5   5       % amplitude
             1   1       % magnetic field
             8   8       % energy (bigger than 1)
             200 200     % smo (smaller than 400)
             3   5       % nu exponent of Gaussian or Lorentzian
             40  40      % ld
             1   1       % ni density
             ];
         
nImages = 50000;
nPlots = 50; % number of potentials plotted   

rawDataFilename = generatedata(intervals, nImages, nPlots);

disp(strcat("The raw data has been saved at ", rawDataFilename));

%% Data Formatting
saveVariables = [false    % amplitude
                 false    % magnetic field
                 false    % energy
                 false    % smo
                 true     % nu
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
sortedDataFilename = trainqcnnclass(formattedDataFilename);

disp(strcat("The sorted data has been saved at ", sortedDataFilename));

%% Train QCNN
networkFilename = trainqcnn(sortedDataFilename);

disp(strcat("The trained network has been saved at ", networkFilename));

%% Plot Data
plotdata(networkFilename);
