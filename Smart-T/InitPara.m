function InitPara
% Aslin baby lab experiment
% Author: Johnny, 3/10/2008

% Reset Parameters
% After input, we need recalculate some parameter
global debug connTobii connNIRS SerialOTNum NIRSMACHINE scr mask obswin loom sound randomSet img path structure phase experimentData movie
%MO: connNIRS SerialOTNum NIRSMACHINE added above
    
    % experimentData will save to .mat file
%     experimentData.debug = debug;
%     experimentData.connTobii = connTobii;
%     experimentData.scr = scr;
%     experimentData.mask = mask;
%     experimentData.obswin = obswin;
%     experimentData.loom = loom;
%     experimentData.sound = sound;
%     experimentData.randomSet = randomSet;
%     experimentData.img = img;
%     experimentData.path = path;
%     experimentData.structure = structure;
    experimentData.phase = phase;
    save('experimentData.mat', 'experimentData');
    
    % screen rect
    scr.rect = [scr.rect(1:2) scr.rect(1:2)+[scr.width scr.height]];

    % observation windows rect
    for i=1:length(obswin)
         obswin(i).rect = [obswin(i).upperLeftCorner obswin(i).upperLeftCorner(1)+obswin(i).width ...
                         obswin(i).upperLeftCorner(2)+obswin(i).height];
    end

    % find distance between the nodes of path
    for i=1:length(path)
        path(i).distance = sqrt(diff(path(i).x).*diff(path(i).x) + diff(path(i).y).*diff(path(i).y));
    end
    
    % read image and crop to square
    for i = 1:length(img)
    %MO: the next few added
    [ALimdata ALmap ALalfa] = imread(img(i).filename);
    if not(isempty(ALalfa))
        ALimdata(:,:,4) = ALalfa(:,:);
    else
        ALimdata(:,:,4) = ones(size(squeeze(ALimdata(:,:,1)))).*255;
    end
    img(i).data = ALimdata;
    %MO: this commented out:img(i).data = imread(img(i).filename);
        % In foreground and back ground image, we use original size of image.
        img(i).originalData = img(i).data;

        % crop image to square and maketexture
        [iy, ix, id]=size(img(i).data);

        if ix>iy
            cl=round((ix-iy)/2);
            cr=(ix-iy)-cl;
        else
            cl=0;
            cr=0;
        end
        if iy>ix
            ct=round((iy-ix)/2);
            cb=(iy-ix)-ct;
        else
            ct=0;
            cb=0;
        end

        % imdata is the cropped version of the image.
        img(i).data=img(i).data(1+ct:iy-cb, 1+cl:ix-cr,:);
    end
    
    for i = 1:length(phase)
        phase(i).structCounter = zeros(1,length(phase(i).structNum));
    end
    
    for pi = 1:length(phase)
        phase(pi).structPercentage = 100*phase(pi).structWeight./sum(phase(pi).structWeight);
    end
    
    % Create a TempTrialData directory for each trialData
    experimentData.tempTrialDataDir = './TempTrialData';
    if exist(experimentData.tempTrialDataDir,'dir')
        error('TempTrialData already exists! Please save the data for last crash or delete whole directory!');
    else
        status = mkdir(experimentData.tempTrialDataDir);
        if status == false
            error('Cannot ')
        end
    end
    
    % Create the movie square location
    for i=1:length(structure)
        structure(i).movieLocationRect = [  structure(i).movieCenter(1) - structure(i).movieWidth/2.0 ... %left
                                            structure(i).movieCenter(2) - structure(i).movieWidth/2.0 ... %top
                                            structure(i).movieCenter(1) + structure(i).movieWidth/2.0 ... %right
                                            structure(i).movieCenter(2) + structure(i).movieWidth/2.0]; %bottom
    end
    
    % experimentData will save to .mat file
    parameters.debug = debug;
    parameters.connTobii = connTobii;
parameters.connNIRS = connNIRS; %MO: added
parameters.SerialOTNum = SerialOTNum; %MO: added
    parameters.scr = scr;
    parameters.mask = mask;
    parameters.obswin = obswin;
    parameters.loom = loom;
    parameters.sound = sound;
    parameters.randomSet = randomSet;
    parameters.img = img;
    parameters.movie = movie;
    parameters.path = path;
    parameters.structure = structure;
    save([experimentData.tempTrialDataDir '/parameters.mat'], 'parameters');
end
