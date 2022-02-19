%% Clear Workspace
clear

%% Initialize some stuffs
A = {[4.25 4.25], [4.25 4.25], [1 5], [1 5]};
B = {[0.5 0.5], [0.5 2], [0.5 0.5], [0.5 2]};
E = {[8 12], [8 8], [8 8], [8 12]};
Nu = {[2 5], [2 5], [2 5], [2 5]};
learnA = [false, false, true, true];
learnB = [false, true, false, true];
learnE = [true, false, false, true];
learnNu = [true, true, true, true];


for i = 1:length(A)
%% Data Generation
intervals = [A{i}       % amplitude
             B{i}       % magnetic field
             E{i}       % energy (bigger than 1)
             200 200     % smo (smaller than 400)
             Nu{i}       % nu exponent of Gaussian or Lorentzian
             40  40      % ld
             1   1       % ni density
             ];
         
nImages = 50000;
nPlots = 50; % number of potentials plotted   

rawDataFilename = generatedata(intervals, nImages, nPlots);

disp(strcat("The raw data has been saved at ", rawDataFilename));

%% Data Formatting

saveVariables = [learnA(i)    % amplitude
                 learnB(i)    % magnetic field
                 learnE(i)    % energy
                 false        % smo
                 learnNu(i)   % nu
                 false        % ld
                 false        % ni
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

end