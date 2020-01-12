function SetDefualtPara()
% Aslin baby lab experiment
% Author: Johnny, 3/10/2008

    global smarttVersion debug connTobii connNIRS SerialOTNum NIRSMACHINE scr mask obswin loom moveObj sound img randomSet path structure phase EYETRACKER movie
    %MO: added connNIRS SerialOTNum NIRSMACHINE above
    
    smarttVersion = 4.6;%MO: added
    debug = 1;
    connTobii = 0;
    connNIRS = 0; %MO: added
    SerialOTNum = 1;
    NIRSMACHINE = 0;
    EYETRACKER = 0;

    % screen default parameters
    scr.screens = Screen('Screens');
    scr.screenNumber = max(scr.screens);
    scr.black = BlackIndex(scr.screenNumber);
    scr.white = WhiteIndex(scr.screenNumber);
    scr.gray = GrayIndex(scr.screenNumber);
    scr.bgcolor = [scr.gray scr.gray scr.gray];
    scr.rect = Screen('Rect', scr.screenNumber);
    if debug % use half screen
        %scr.rect = [0 0 round(scr.rect(3)/2) round(scr.rect(4)/2)]; % upper left and lower right corner
        scr.rect = [0 0 1280 1024]; % upper left and lower right corner
        %scr.rect = [0 0 600 600]; % upper left and lower right corner
    end
    scr.width = scr.rect(3);
    scr.height = scr.rect(4);
    scr.numberOfBuffers = 2; %doublebuffer
    scr.winPrt = [];
    scr.TobiiIPaddress = '173.194.33.104'; %MO: this is the Google IP ;)
    scr.TobiiPortNum = '4455';

    % mask default parameters
    w = scr.width; h = scr.height; s = h*0.3;
    mask(1).x = round([w/2-s/2 w/2-s/2 w/2-s*3/2 w/2-s*3/2 w/2+s*3/2 w/2+s*3/2 w/2+s/2 w/2+s/2]); 
    mask(1).y = round([h/2-s h/2 h/2 h/2+s h/2+s h/2 h/2 h/2-s]);
    mask(1).color = (scr.black - scr.bgcolor)/2 + scr.bgcolor;
    mask(1).opaqueStart = 50; % 50% - total transparent and 255 - opaque
    mask(1).opaqueIncStep = 10;
    mask(1).opaqueEnd = 100;
    
    mask(2).x = round([w/2-s*3/2 w/2-s*3/2 w/2-s/2 w/2-s/2 w/2-s*3/2 w/2-s*3/2 w/2+s*3/2 w/2+s*3/2 w/2+s/2 w/2+s/2 w/2+s*3/2 w/2+s*3/2 w/2+s/2 w/2+s/2 w/2-s/2 w/2-s/2]);
    mask(2).y = round([h/2-s*3/2 h/2-s/4 h/2-s/4 h/2+s/2 h/2+s/2 h/2+s h/2+s h/2+s/2 h/2+s/2 h/2-s/4 h/2-s/4 h/2-s*3/2 h/2-s*3/2 h/2-s*3/4 h/2-s*3/4 h/2-s*3/2]);
    mask(2).color = mask(1).color;
    

    % observation windows parameters
    obswin(1).width = round(w/2-s/2);
    obswin(1).height = round(h/2);
    obswin(1).upperLeftCorner = [0 0];
    obswin(2).width = obswin(1).width;
    obswin(2).height = obswin(1).height;
    obswin(2).upperLeftCorner = [round(w/2+s/2) 0];
    obswin(3).width = scr.width;
    obswin(3).height = scr.height;
    obswin(3).upperLeftCorner = [0 0];

    % image files
    img(1).filename = 'blue.png';
    img(2).filename = 'red.png';
    img(3).filename = 'grass1.png';
    
    % movie files 
    %(media files are handled by use of Apples Quicktime-7 API) Screen('OpenMovie'..)
    movie(1).filename = 'babylaugh.mov';
    
    % sound files
    sound(1).filename = 'Look.wav';
    sound(2).filename = 'Ooh.wav';
    sound(3).filename = 'Wow.wav';
    
    % sound random set
    randomSet(1).soundFiles = 1:length(sound);
    
    % loom effect
    loom(1).growSize = 150; % 1.5 * original size 
    loom(1).duration = 1; % seconds

    % path
    path(1).x = round([w/2 w/2 w/2-s]);
    path(1).y = round([(3*h+2*s)/4 h/2+s/2 h/2-s/2]);
    path(1).soundEffect(1:length(path(1).x)) = (length(path(1).x)+2)*ones(1,length(path(1).x));
    path(1).loomEffect(1:length(path(1).x)) = (length(path(1).x)+2)*ones(1,length(path(1).x));
    path(2).x = round([w/2 w/2 w/2+s]);
    path(2).y = path(1).y;
    path(3).x = round([w/2 w/2 w/2-s]);
    path(3).y = round([(3*h+2*s)/4 h/2+s/8 h/2+s/8]);
    path(4).x = round([w/2 w/2 w/2+s]);
    path(4).y = round([(3*h+2*s)/4 h/2+s/8 h/2+s/8]);
    path(5).x = round([w/2 w/2 w/2]);
    path(5).y = round([(3*h+2*s)/4 h/2+s/8 h/2-s*9/8]);
    for i = 1:length(path) % set all for none effect
        path(i).soundEffect = (length(sound)+2)*ones(1,length(path(i).x));
        path(i).loomEffect = (length(loom)+2)*ones(1,length(path(i).x));
        path(i).soundRandomSetIndex = ones(1,length(path(i).x)); % default 1st set
        path(i).waitAttention = zeros(1,length(path(i).x)); % default not wait for attention
        path(i).attentionWin = ones(1,length(path(i).x)); % default 1st observation window
        path(i).objSizeRatio = ones(1,length(path(i).x)); % default ratio = 1
        path(i).objSpeedRatio = ones(1,length(path(i).x)-1); % default ratio = 1
    end
    
    % moving object parameters  
    moveObj.type = 2; % 1=circle, 2=square
    moveObj.size = round((h/2-s)*4/5);
    moveObj.img(1).filename = 'blue.png';
    moveObj.img(2).filename = 'red.png';
    moveObj.speed = 200; % pixels per second
    moveObj.path(1).x = round([w/2 w/2 w/2-s]);
    moveObj.path(1).y = round([(3*h+2*s)/4 h/2+s/2 h/2-s/2]);
    moveObj.path(2).x = round([w/2 w/2 w/2+s]);
    moveObj.path(2).y = moveObj.path(1).y;
    
    % sequence structure
    structure(1).pathNum = 1;   % path#
    structure(1).maskNum = 1;
    structure(1).imgNum = 1;    
    structure(1).imgShape = 2; % 1=circle, 2=square
    structure(1).imgSize = round((h/2-s)*4/5);
    structure(1).imgMoveSpeed = 200; % pixels per second
    structure(1).foregroundImgNum = 1;
    structure(1).backgroundImgNum = 1;
    structure(1).useForegroundImg = 0;
    structure(1).useBackgroundImg = 0;
    structure(2).pathNum = 2;   % path# or random = 0 or None = -1
    structure(2).maskNum = 1;
    structure(2).imgNum = 2;    
    structure(2).imgShape = 2; % 1=circle, 2=square
    structure(2).imgSize = round((h/2-s)*4/5);
    structure(2).imgMoveSpeed = 200; % pixels per second
    structure(2).foregroundImgNum = 1;
    structure(2).backgroundImgNum = 1;
    structure(2).useForegroundImg = 0;
    structure(2).useBackgroundImg = 0;
    for i=1:length(structure)
        structure(i).useRewardMovie = false;
        structure(i).movieNum = 1;
        structure(i).movieShape = 1;
        structure(i).movieCenter = [scr.width/2.0 scr.height/2.0];
        structure(i).movieWidth = 150;
        structure(i).movieDuration = 10; %s
        structure(i).movieDelay = 0.5; %s
    end

    % structure quitting condition
    structure(1).interestNodes = [1 length(path(structure(1).pathNum).x)];
    structure(1).correctObsWins = 1;
    structure(1).incorrectObsWins = 2;
    structure(1).requireLooking = 20; % require looking % for a good trial
    structure(1).lookScrTime = 200; % ms, require looking at screen time for a good trial.
    structure(1).validityLevel = 2;
    structure(2).interestNodes = [2 length(path(structure(2).pathNum).x)];
    structure(2).correctObsWins = 2;
    structure(2).incorrectObsWins = 1;
    structure(2).requireLooking = 20;
    structure(2).validityLevel = 2;
    structure(2).lookScrTime = 200;
        
    % phase
    phase(1).trialNum = 6; 
    phase(1).waitTime1 = 1;%MO: these two modified; WAS: phase(1).waitTime = 1;
    phase(1).waitTime2 = 1;
    phase(1).maxTime = 300; %sec
    phase(1).structNum = [1 2]; % repeat in order = 1 2;
    phase(1).random = false;
    phase(1).structWeight = [7 3]; % fixed random weight
%    phase(1).structPercentage = [70 30]; % fixed random percentage
    phase(1).fixPercentage = false;
    phase(1).blankISI = false;
    phase(1).maskOpaqueStart = 50; % 50% - total transparent and 255 - opaque
    phase(1).maskOpaqueIncStep = 10;
    phase(1).maskOpaqueEnd = 100;
    phase(2).trialNum = 100; 
    phase(2).waitTime1 = 1;%MO: these two modified; WAS: phase(2).waitTime = 1;
    phase(2).waitTime2 = 1;
    phase(2).maxTime = 300; %sec
    phase(2).structNum = [1 2]; % repeat in order = 1 2;
    phase(2).random = false;
    phase(2).structWeight = [7 3]; % fixed random weight
%    phase(2).structPercentage = [70 30]; % fixed random percentage
    phase(2).fixPercentage = false;
    phase(2).blankISI = false;
    phase(2).maskOpaqueStart = 100; % 50% - total transparent and 255 - opaque
    phase(2).maskOpaqueIncStep = 10;
    phase(2).maskOpaqueEnd = 100;
    
    % phase quitting condition
    NONE = 0;
    TOTAL_LOOK = 1;
    FIRST_LOOK = 2;
    TTEST = 3;
    AND = 1;
    OR = 2;
    phase(1).useQuittingCond = false;
    phase(1).useTotalTrials = false;
    phase(1).interestStructs = [1]; 
    phase(1).numOfLastTrial = [5 5 5];
    phase(1).totalLook.lookPercentage = 60; % how many percentage time of correct/(corr+incorr) obs win looking at monitor.
    phase(1).firstLook.numOfCorrLook = 3;
    phase(1).ttest.mean = 50;
    phase(1).ttest.alpha = 0.05;
    phase(1).conditions = [1 2 3]; % if conditions = [1 3 0] then 0 is not a condition.
    phase(1).logics = [OR AND];
    phase(2).useQuittingCond = false;
    phase(2).useTotalTrials = false;
    phase(2).interestStructs = [1]; 
    phase(2).numOfLastTrial = [5 5 5];
    phase(2).totalLook.lookPercentage = 60; % how many percentage time of correct/(corr+incorr) obs win looking at monitor.
    phase(2).firstLook.numOfCorrLook = 3;
    phase(2).ttest.mean = 50;
    phase(2).ttest.alpha = 0.05;
    phase(2).conditions = [1 3 0]; % if conditions = [1 3 0] then 0 is NONE condition.
    phase(2).logics = [OR NONE];
    
end