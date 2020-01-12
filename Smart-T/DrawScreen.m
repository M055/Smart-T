function vbl = DrawScreen(curRect, imgIndex, imgShape, drawImg, structNum, maskNum, eyePosition, vbl, debugStr, playMovie, mo_var_blankISI)
% Aslin baby lab experiment
% Author: Johnny, 3/10/2008
%MO: added mo_var_blankISI to function parameters

% We repeat to call DrawScreen
global debug scr mask obswin structure path img movie

if ~exist('debugStr')
    debugStr{1} = '';
    debugStr{2} = '';
elseif isempty(debugStr)
    debugStr{1} = '';
    debugStr{2} = '';
end

if ~exist('playMovie')
    playMovie = false;
end

%MO: added this IF..
if ~exist('mo_var_blankISI')
    mo_var_blankISI = false;
end

curRect = cast(curRect, 'double');
try
    % This script calls Psychtoolbox commands available only in OpenGL-based
    % versions of the Psychtoolbox. (So far, the OS X Psychtoolbox is the
    % only OpenGL-based Psychtoolbox.)  The Psychtoolbox command AssertOpenGL will issue
    % an error message if someone tries to execute this script on a computer without
    % an OpenGL Psychtoolbox
    AssertOpenGL;

    % Enable alpha blending with proper blend-function.
    Screen('BlendFunction', scr.winPrt, GL_ONE, GL_ZERO);
    if mo_var_blankISI %MO: this condition takes priority
        Screen('FillRect', scr.winPrt, [scr.bgcolor 0]); % draw background color with alpha = 0
    else
        if structure(structNum).useBackgroundImg
            %By default 'DrawTexture', alpha = 255; Here we set the alpha = 0 in background.
            Screen('DrawTexture', scr.winPrt, img(structure(structNum).backgroundImgNum).originalFoveatex, img(structure(structNum).backgroundImgNum).originalTRect, scr.rect, 0, 1, 0);
        else
            Screen('FillRect', scr.winPrt, [scr.bgcolor 0]); % draw background color with alpha = 0
        end

        if drawImg
            if imgShape == 1 %circle
                % Now, we set the circle area to alpha = 255;
                Screen('FillArc', scr.winPrt, [0 0 0 255], curRect, 0, 360); % set alpha = 255 for circle
                Screen('BlendFunction', scr.winPrt, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA); % draw everything on alpha = 255
            else % square
                %Screen('BlendFunction', scr.winPrt, GL_ONE, GL_ZERO);
                %MO: Prev line commented out
                Screen('BlendFunction', scr.winPrt, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);%MO: this line added
            end
            Screen('DrawTexture', scr.winPrt, img(imgIndex).foveatex, img(imgIndex).tRect, curRect);
        end

        % Enable alpha blending with proper blend-function.
        Screen('BlendFunction', scr.winPrt, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        if structure(structNum).useForegroundImg
            % This image show up infront. It will depend on alpha value of the foreground image to show up all or part of image infront.
            Screen('DrawTexture', scr.winPrt, img(structure(structNum).foregroundImgNum).originalFoveatex, img(structure(structNum).foregroundImgNum).originalTRect, scr.rect);
        else
            %draw mask
            Screen('FillPoly', scr.winPrt, mask(maskNum).color, [mask(maskNum).x; mask(maskNum).y]');
        end
    end

    texture = 0;
    if playMovie
        %Screen('BlendFunction', scr.winPrt, GL_ONE, GL_ZERO);
        [texture pts] = Screen('GetMovieImage', scr.winPrt, movie(structure(structNum).movieNum).mvPrt, 1);
        if texture>0
            if structure(structNum).movieShape == 1 %circle
                Screen('BlendFunction', scr.winPrt, GL_ZERO, GL_SRC_COLOR); %srcfactor=(0 0 0 0) and destfactor=(1 1 1 0) that keep original dest color and set alpha to 0
                Screen('FillRect', scr.winPrt, [255 255 255 0], structure(structNum).movieLocationRect); % set alpha = 0 for square
                % Now, we set the circle area to alpha = 255;
                Screen('BlendFunction', scr.winPrt, GL_ONE, GL_ZERO);
                Screen('FillArc', scr.winPrt, [0 0 0 255], structure(structNum).movieLocationRect, 0, 360); % set alpha = 255 for circle
                Screen('BlendFunction', scr.winPrt, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA); % draw everything on alpha = 255
            else % square
                Screen('BlendFunction', scr.winPrt, GL_ONE, GL_ZERO);
            end
            Screen('DrawTexture', scr.winPrt, texture, movie(structure(structNum).movieNum).drawRect, structure(structNum).movieLocationRect);
        end
    end

    if debug
        Screen('BlendFunction', scr.winPrt, GL_ONE, GL_ZERO);
        x = []; y = [];
        for i = 1:length(path)
            for j = 1:length(path(i).x)-1
                x = [x path(i).x(j) path(i).x(j+1)];
                y = [y path(i).y(j) path(i).y(j+1)];
            end
            Screen('DrawLines', scr.winPrt, [x;y], [], [0 0 255])
        end
        for i = 1:length(obswin)
            Screen('FrameRect', scr.winPrt,[255 255 255],cast(obswin(i).rect,'double'));
        end
        Screen('DrawDots',scr.winPrt, [path(structure(structNum).pathNum).x;path(structure(structNum).pathNum).y], 5, [255 0 0], [], 0);
        Screen('DrawDots',scr.winPrt, eyePosition, 5, [255 255 0], [], 1);
        Screen('DrawText',scr.winPrt, sprintf('Mouse position: (x,y) = (%d,%d)',eyePosition), 20, 20);
        Screen('DrawText',scr.winPrt, debugStr{1}, 20, 40);
        Screen('DrawText',scr.winPrt, debugStr{2}, 20, 60);
        vbl=Screen('Flip', scr.winPrt, vbl + 0.5*scr.ifi);
    else
        vbl=Screen('Flip', scr.winPrt, vbl + 0.5*scr.ifi);
    end

    if texture>0
        Screen('Close', texture);
    end


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