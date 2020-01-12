function ErrorCode = TobiiInit( hostName, portName, win, res)
% This is a matlab function that initialises Tobii Connection 
% Calibrate Eye Tracker and subscribe gaze data
%
% hostName is the IP address of the PC running the TET server
% win is the handle of the window that has been initialised with the
% psychtoolbox
% res is a vector with the width and the height of the win in pixels
%
% ErrorCode returns 1 if there is an error or 0 if no error
% has occured

%try max_wait times
%each time wait for tim_interv secs before try again 
max_wait = 60; 
tim_interv = 1;

%calibration points in X,Y coordinates
pos = [0.2 0.2;...
    0.5 0.2;
    0.8 0.2;
    0.2 0.5;
    0.5 0.5;
    0.8 0.5;
    0.2 0.8;
    0.5 0.8;
    0.8 0.8];
numpoints = length(pos);

%this call is important because it loads the 'GetSecs' mex file!
%without this call the talk2tobii mex file will crash
GetSecs();

%find indexes for correspond keys
ESCAPE=KbName('Escape');

try
    ifi = Screen('GetFlipInterval',win,100);

    %% try to connect to the eyeTracker
    talk2tobii('CONNECT',hostName, portName);

    %check status of TETAPI
    cond_res = check_status(2, max_wait, tim_interv,1);
    tmp = find(cond_res==0);
    if( ~isempty(tmp) )
        error('check_status has failed');
    end


    %% monitor/find eyes
    talk2tobii('START_TRACKING');
    %check status of TETAPI
    cond_res = check_status(7, max_wait, tim_interv,1);
    tmp = find(cond_res==0);
    if( ~isempty(tmp) )
        error('check_status has failed');
    end

    flagNotBreak = 0;
    disp('Press Esc to start calibration');
    while ~flagNotBreak
        eyeTrack = talk2tobii('GET_SAMPLE');
        DrawEyes(win, eyeTrack(9), eyeTrack(10), eyeTrack(11), eyeTrack(12), eyeTrack(8), eyeTrack(7));

        if( IsKey(ESCAPE) )
            flagNotBreak = 1;
            if( flagNotBreak )
                break;
            end
        end
    end

    talk2tobii('STOP_TRACKING');

    %% start calibration
    %display stimulus in the four corners of the screen
    totTime = 4;        % swirl total display time during calibration
    calib_not_suc = 1;
    while calib_not_suc
        talk2tobii('START_CALIBRATION',pos,0,'./calibrFileTest.txt');
        
        %% It is wrong to try to check the status here because the
        %% eyetracker waits for an 'ADD_CALIBRATION_POINT' and 'DREW_POINT'.

        for i=1:numpoints
            position = pos(i,:);
            %            disp(position);
            when0 = GetSecs()+ifi;
            talk2tobii('ADD_CALIBRATION_POINT');
            StimulusOnsetTime=swirl(win,totTime,ifi,when0,position,1);
            talk2tobii('DREW_POINT');
        end
        
        cond_res = check_status(11, 90, 1, 1);
        tmp = find(cond_res==0);
        if( ~isempty(tmp) )
            error('check_status has failed- CAIBRATION');
        end

        %check quality of calibration
        quality = talk2tobii('CALIBRATION_ANALYSIS');
                
        %++code should be added here to display and check the quality of the
        %calibration
        
        %choose if you want to redo the calibration
        %disp('Press space to resume calibration or q to exit calibration and continue tracking');
        tt= input('press "C" and "ENTER" to resume calibration or any other key to continue\n','s');
        if( strcmpi(tt,'C') )
            calib_not_suc = 1;
        else
            calib_not_suc = 0;
        end

    end
    disp('EndOfCalibration');
    
        
    Screen('TextSize', win,50);
    Screen('DrawText', win, '+',res(1)/2,res(2)/2,[255 0 0]);
    Screen('Flip', win );
    
    talk2tobii('RECORD');    
    talk2tobii('START_TRACKING');

    %check status of TETAPI
    cond_res = check_status(7, max_wait, tim_interv,1);
    tmp = find(cond_res==0);
    if( ~isempty(tmp) )
        error('check_status has failed');
    end
    
    ErrorCode = 0;
    
catch
    ErrorCode = 1;
    rethrow(lasterror);
    talk2tobii('STOP_TRACKING');
    talk2tobii('DISCONNECT');
end

return;



function ctrl=IsKey(key)
    global KEYBOARD;
    [keyIsDown,secs,keyCode]=PsychHID('KbCheck', KEYBOARD);
    if ~isnumeric(key)
        kc = KbName(key);
    else
        kc = key;
    end;
    ctrl=keyCode(kc);
return
