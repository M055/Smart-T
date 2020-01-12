function vbl = CreateStimulationWin()
% Aslin baby lab experiment
% Author: Johnny, 3/10/2008

% We will setup one time stuff of screen
    global debug scr mask loom img path structure phase movie
    
    try
        % This script calls Psychtoolbox commands available only in OpenGL-based
        % versions of the Psychtoolbox. (So far, the OS X Psychtoolbox is the
        % only OpenGL-based Psychtoolbox.)  The Psychtoolbox command AssertOpenGL will issue
        % an error message if someone tries to execute this script on a computer without
        % an OpenGL Psychtoolbox
        AssertOpenGL;

        % Open double-buffered onscreen window
        if ~isempty(scr.winPrt)
            Screen('CloseAll');
            scr.winPrt = [];
        end
        
        [scr.winPrt, scr.winRect] = Screen('OpenWindow', scr.screenNumber, scr.bgcolor,scr.rect,[], scr.numberOfBuffers);
        
        scr.fps=Screen('FrameRate',scr.winPrt);      % frames per second

        scr.ifi=Screen('GetFlipInterval', scr.winPrt);
        if scr.fps==0
           scr.fps=1/scr.ifi;
        end;
        
        % texture of cirlce or square
        for i=1:length(img)
            img(i).foveatex=Screen('MakeTexture', scr.winPrt, img(i).data);
            %img(i).brightFoveatex=Screen('MakeTexture', scr.winPrt, img(i).data*1.2);
            img(i).tRect=Screen('Rect', img(i).foveatex);
            % In foreground and back ground image, we use original size of image.
            img(i).originalFoveatex=Screen('MakeTexture', scr.winPrt, img(i).originalData);
            img(i).originalTRect=Screen('Rect', img(i).originalFoveatex);
        end
        
        % Set transparent ration on mask (RGBA where A is alpha)
        mask(structure(phase(1).structNum(1)).maskNum).color(4) = scr.white*phase(1).maskOpaqueStart/100;
        
        % Open movie file and retrieve basic info about movie:
        for i=1:length(movie)
            [movie(i).mvPrt movie(i).duration movie(i).fps imgw imgh] = Screen('OpenMovie', scr.winPrt, movie(i).filename);
            movie(i).orginalRect = [0 0 imgw imgh];
            movie(i).drawRect = FindMaxSquareInRect([0 0 imgw imgh]);
        end
               
        if debug
            Priority(0);
        else
            HideCursor;	% Hide the mouse cursor
            Priority(MaxPriority(scr.winPrt));
        end

        % Do initial flip...
        vbl=Screen('Flip', scr.winPrt);
        
        imgSize = structure(phase(1).structNum(1)).imgSize;
        center = [path(structure(phase(1).structNum(1)).pathNum).x(1) path(structure(phase(1).structNum(1)).pathNum).y(1)];
        curRect = round([center(1)-imgSize/2 center(2)-imgSize/2 center(1)+imgSize/2 center(2)+imgSize/2]);
        imgNum = structure(phase(1).structNum(1)).imgNum;
        if imgNum > length(img) %random
          imgNum = ceil(length(img)*rand);
        end
        if debug
            vbl = DrawScreen(curRect, imgNum, structure(phase(1).structNum(1)).imgShape, true, phase(1).structNum(1), structure(phase(1).structNum(1)).maskNum, [0 0], vbl);
        else
            vbl = DrawScreen(curRect, imgNum, structure(phase(1).structNum(1)).imgShape, false, phase(1).structNum(1), structure(phase(1).structNum(1)).maskNum, [0 0], vbl);
        end
        % Start Experiment
        %DoExperiment(vbl);
    catch
        %this "catch" section executes in case of an error in the "try" section
        %above.  Importantly, it closes the onscreen window if its open.
        CloseOpenAL;
        Screen('CloseAll');
        ShowCursor;
        Priority(0);
        psychrethrow(psychlasterror);
    end %try..catch..
end