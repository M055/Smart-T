function TobiiCommand(file)
% Aslin baby lab experiment
% Author: Johnny, 3/10/2008

    %global debug connTobii scr mask obswin moveObj gui
    
    %reset random seed by us
    x = GetSecs;
    rand('twister', (x-floor(x))*10^6); 
    
    SetDefualtPara;
    
    if nargin == 1
        Error = ReadParaFile(file);
        if Error
            return;
        end
    elseif (nargin > 1)
        disp('Error using TobiiCommand! ==> TobiiCommand(file)');
        return
    end
    
    % Reset other parameters
    InitPara;
    
    % Start the experiment
    InitTobii;
    InitSoundEffect();
    vbl = CreateStimulationWin();
    DoExperiment(vbl);
    
    clear all
end