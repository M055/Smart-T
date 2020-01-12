function InitTobii

global connTobii EYETRACKER scr

EYETRACKER = 0;
if connTobii
%     Error = TobiiInit( '169.254.9.248', '4455', scr.winPrt, scr.winRect(3:4));
%     if Error
%         error('Initialize Tobii fail!');
%     else
%         EYETRACKER = 1;
%     end

    %this call is important because it loads the 'GetSecs' mex file!
    %without this call the talk2tobii mex file will crash
    GetSecs();

    try
        talk2tobii('CONNECT',scr.TobiiIPaddress, scr.TobiiPortNum);
        pause(2);
        talk2tobii('START_TRACKING');
        pause(2);
        % It synchronises the host pc time to the TETserver.
        TALK2TOBII('SYNCHRONISE');
        EYETRACKER = 1;
    catch
        if IsOSX
            talk2tobii('STOP_TRACKING');
            talk2tobii('DISCONNECT');
        end
        error('Initialize Tobii fail!');
        EYETRACKER = 0;
    end
    
end
