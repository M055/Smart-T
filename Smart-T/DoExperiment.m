function DoExperiment(vbl)
% Aslin baby lab experiment
% Author: Johnny, 3/10/2008

% Control the experiment
global debug connNIRS SerialOTNum NIRSMACHINE scr mask obswin loom sound randomSet img path structure phase EYETRACKER experimentData movie
%MO: connNIRS SerialOTNum NIRSMACHINE added above

%MO:Define serial writeouts
otst=char([double('ST') 13]);
oted=char([double('ED') 13]);
ot01=char([double('F1') 13]);
ot02=char([double('F2') 13]);
ot03=char([double('F3') 13]);
ot04=char([double('F4') 13]);
ot05=char([double('F5') 13]);
ot06=char([double('F6') 13]);
ot07=char([double('F7') 13]);
ot08=char([double('F8') 13]);
ot09=char([double('F9') 13]);

% collect data per frame constant
IN_WHOLE_SCR = 1;
CURR_NODE_NUM = 2;
LEYE_VALIDITY = 3;
REYE_VALIDITY = 4;

% phase quitting condition constant
NONE = 0;
TOTAL_LOOK = 1;
FIRST_LOOK = 2;
TTEST = 3;
AND = 1;
OR = 2;
quittingCriterion = zeros(1,3);

% Save data - file name
outPicDir = './';
trackFileName = fullfile(outPicDir,'Tracking.txt');
eventFileName = fullfile(outPicDir,'events.txt');

% This function global data
suspension = false; % for pause/start the object(image) movement
loop = true;        % for jump out all the loops and stop the experiment
trialData = [];     % record all the data for each trial 
goToNextPhase = false; % this will be true after press nextPhaseKey

% keyboard control
KbName('UnifyKeyNames');
escapeKey = KbName('ESCAPE');   % stop the experiment
startKey = KbName('s');         % start/pause the experiment
keepGoingKey = KbName('g');     % keep going when waitForAttention in the experiment
nextPhaseKey = KbName('p');     % go to next phase in the experiment

mx=-1; my=-1;   % eyes or mouse position

debugStr = '';

preTobiiTime = -1;

% Wait until all keys are released.
while KbCheck; WaitSecs(0.1); end; 

% Wait for starting the experiment
while 1
    % Check the state of the keyboard.
    [ keyIsDown, seconds, keyCode ] = KbCheck;

    % If the user is pressing a key, then display its code number and name.
    if keyIsDown
        if keyCode(escapeKey)
            % Finish the experiment
            CloseAll();
            return;
        end

        % Start the experiment
        if keyCode(startKey)
            break;
        end

        % If the user holds down a key, KbCheck will report multiple events.
        % To condense multiple 'keyDown' events into a single event, we wait until all
        % keys have been released.
        while KbCheck; end
    end
end

% Wait until all keys are released.
while KbCheck; WaitSecs(0.1); end;

% Start experiment
try
    if(connNIRS)
        try
            SerialComm( 'open', SerialOTNum, '9600,n,8,1' );
            NIRSMACHINE = 1;
        catch
            warning('Initialize NIRS machine fail!');
            Beeper('low',.5,.5);
            NIRSMACHINE = 0;
        end
            if(NIRSMACHINE);
                SerialComm( 'write', SerialOTNum, otst ); 
                pause(15);
            end
    end
    
  if(EYETRACKER) 
      talk2tobii('RECORD');
  end
  
  phaseNum = 1;
  while (phaseNum <= length(phase) && loop)
    phase(phaseNum).phaseStartTime = GetSecs();
    
    goodTrialNum = 0;
    trialNum = 1;
    nextPhase = false;
    quittingCriterion = zeros(1,3); % reset quitting criterion to false.
    [maxLastTrialNum quitLastTrialNum] = FindMaxLastTrialNum(phaseNum);
    while loop
      if goToNextPhase == true % manually press 'p' and go to next phase
          goToNextPhase = false;
              break;
          end
      if phase(phaseNum).useQuittingCond % use quitting condition
          if nextPhase % fullfil all condition
              break;
          end
          % if use total trial, then check and quit, even if it doeen't fulfill all condition
          if phase(phaseNum).useTotalTrials && trialNum > phase(phaseNum).trialNum
              break;
          end
      elseif (trialNum > phase(phaseNum).trialNum || GetSecs()-phase(phaseNum).phaseStartTime > phase(phaseNum).maxTime)
          break;
      end

      % Initialize for each Trial 
      % One trial means that the moving object go through the whole current path.
      if phase(phaseNum).random || phase(phaseNum).fixPercentage
          if phase(phaseNum).useQuittingCond % if use quitting condition, always random
              structIndex = ceil(length(phase(phaseNum).structNum)*rand);
          else 
              structIndex = SetStructIndex(phaseNum, phase(phaseNum).trialNum);
          end
      else % in order
          structIndex = mod(trialNum-1, length(phase(phaseNum).structNum))+1;
      end
      maskNum = structure(phase(phaseNum).structNum(structIndex)).maskNum;
      imgMoveSpeed = structure(phase(phaseNum).structNum(structIndex)).imgMoveSpeed;
      pathNum = structure(phase(phaseNum).structNum(structIndex)).pathNum;
      imgSize = structure(phase(phaseNum).structNum(structIndex)).imgSize;
      imgNum = structure(phase(phaseNum).structNum(structIndex)).imgNum;
      imgShape = structure(phase(phaseNum).structNum(structIndex)).imgShape;
      frameNum = 0;
      preNode = 0;

      if imgNum > length(img) %random
          imgNum = ceil(length(img)*rand);
      end
      
%      maxLastTrialNum = 0;
%       for i=1:length(phase(phaseNum).conditions)
%           if phase(phaseNum).conditions(i) ~= 0 % not a none condition
%               if maxLastTrialNum < phase(phaseNum).numOfLastTrial(phase(phaseNum).conditions(i))
%                   maxLastTrialNum = phase(phaseNum).numOfLastTrial(phase(phaseNum).conditions(i));
%               end
%           end
%       end

      %Save each trial data
      trialData = [];
      experimentData.phase(phaseNum).trial(trialNum).structNum = phase(phaseNum).structNum(structIndex);
      experimentData.phase(phaseNum).trial(trialNum).imgNum = imgNum;
      experimentData.phase(phaseNum).trial(trialNum).startTime = GetSecs();
      
      trackEyeNum = 1;
      while loop
            % Let the mask change from transparent to opaque gradually.
            opaquePercentage = phase(phaseNum).maskOpaqueStart+phase(phaseNum).maskOpaqueIncStep*(trialNum-1);
            if opaquePercentage >= phase(phaseNum).maskOpaqueEnd
                mask(maskNum).color(4) = scr.white*phase(phaseNum).maskOpaqueEnd/100;
                experimentData.phase(phaseNum).trial(trialNum).opaquePercentage = phase(phaseNum).maskOpaqueEnd;
            else
                mask(maskNum).color(4) = scr.white*opaquePercentage/100;
                experimentData.phase(phaseNum).trial(trialNum).opaquePercentage = opaquePercentage;
            end
            
            % Find where should draw the object.
            [currNode center currObjSize] = findMoveObjCenter(frameNum, imgMoveSpeed, scr.fps, pathNum, imgSize);
            
            % At each node, we add sound and/or loom effect at the beginning.
            if preNode < currNode
                
                %MO: send a mark for this node {mocheck}
                currOTmark=mod(currNode-1,9)+1;
                eval(['currOTmark=ot0' num2str(currOTmark) ';']);
                if(NIRSMACHINE); SerialComm( 'write', SerialOTNum, currOTmark); end; 	
                
                waitForAttention = true;
                keepGoing = false; % This is for keyboard input 'g' and then quit the waitForAttention.
                while waitForAttention && ~keepGoing
                    % If we do not wait for attention on this node, we will only do effect once when this node has effect.
                    % If we wait for attention on this node, then the effect is continuous until gaze point in observation window.
                    waitForAttention = path(pathNum).waitAttention(currNode);
                    % Add Sound Effect
                    if path(pathNum).soundEffect(currNode) < length(sound)+2 % not none effect
                        if path(pathNum).soundEffect(currNode) == length(sound)+1 % random effect
                            %soundIndex = ceil(length(sound)*rand);
                            randomSetIndex = path(pathNum).soundRandomSetIndex(currNode);
                            soundIndex = randomSet(randomSetIndex).soundFiles(ceil(length(randomSet(randomSetIndex).soundFiles)*rand));
                        else
                            soundIndex = path(pathNum).soundEffect(currNode);
                        end
                        alSourcePlay(sound(soundIndex).source);
                    end


                    %curRect = round([center(1)-imgSize/2 center(2)-imgSize/2 center(1)+imgSize/2 center(2)+imgSize/2]);
                    curRect = round([center(1)-currObjSize/2 center(2)-currObjSize/2 center(1)+currObjSize/2 center(2)+currObjSize/2]);
                    vbl = DrawScreen(curRect, imgNum, imgShape, true, phase(phaseNum).structNum(structIndex), maskNum, [mx my], vbl, debugStr);
                    [mx my] = TrackEye(currNode, center, vbl, path(pathNum).waitAttention(currNode), currObjSize);
                    % If we don't use loom effect, we need check the gaze point here.
                    if waitForAttention && IsInRect(mx, my, obswin(path(pathNum).attentionWin(currNode)).rect)
                        waitForAttention = false;
                    end
                    
                    % Add Loom Effect
                    if path(pathNum).loomEffect(currNode) < length(loom)+2 % not none effect
                        if path(pathNum).loomEffect(currNode) == length(loom)+1 % random effect
                            loomIndex = ceil(length(loom)*rand);
                        else
                            loomIndex = path(pathNum).loomEffect(currNode);
                        end

                        totalFrame = round(scr.fps*loom(loomIndex).duration/2);

                        for i=1:totalFrame
                            newImgSize = currObjSize*(1+(loom(loomIndex).growSize/100 - 1)*i/totalFrame);
                            curRect = round([center(1)-newImgSize/2 center(2)-newImgSize/2 center(1)+newImgSize/2 center(2)+newImgSize/2]);
                            vbl = DrawScreen(curRect, imgNum, imgShape, true, phase(phaseNum).structNum(structIndex), maskNum, [mx my], vbl, debugStr);
                            [mx my] = TrackEye(currNode, center, vbl, path(pathNum).waitAttention(currNode), newImgSize);
                            if waitForAttention && IsInRect(mx, my, obswin(path(pathNum).attentionWin(currNode)).rect)
                                waitForAttention = false;
                            end
                            if keepGoing == false
                                keepGoing = IsKeepGoing();
                            end
                        end

                        for i=totalFrame:-1:1
                            newImgSize = currObjSize*(1+(loom(loomIndex).growSize/100 - 1)*i/totalFrame);
                            curRect = round([center(1)-newImgSize/2 center(2)-newImgSize/2 center(1)+newImgSize/2 center(2)+newImgSize/2]);
                            vbl = DrawScreen(curRect, imgNum, imgShape, true, phase(phaseNum).structNum(structIndex), maskNum, [mx my], vbl, debugStr);
                            [mx my] = TrackEye(currNode, center, vbl, path(pathNum).waitAttention(currNode), newImgSize);
                            if waitForAttention && IsInRect(mx, my, obswin(path(pathNum).attentionWin(currNode)).rect)
                                waitForAttention = false;
                            end
                            if keepGoing == false
                                keepGoing = IsKeepGoing();
                            end
                        end
                    end % end of loom effect
                    
                    % Check the state of the keyboard.
                    [ keyIsDown, seconds, keyCode ] = KbCheck;
                    % If the user is pressing a key, then display its code number and name.
                    if keyIsDown
                        if keyCode(escapeKey)
                            loop = false;
                            break;
                        end
                        if keyCode(keepGoingKey)
                            break; % keep going even if eyes don't look at the observation windows.
                        end
                        % If the user holds down a key, KbCheck will report multiple events.
                        % To condense multiple 'keyDown' events into a single event, we wait until all
                        % keys have been released.
                        %while KbCheck; end
                    end
                end % end of while waitForAttention && ~keepGoing
            end
            
            preNode = currNode;
            
            
            % Draw everything now
            %curRect = round([center(1)-imgSize/2 center(2)-imgSize/2 center(1)+imgSize/2 center(2)+imgSize/2]);
            curRect = round([center(1)-currObjSize/2 center(2)-currObjSize/2 center(1)+currObjSize/2 center(2)+currObjSize/2]);
            vbl = DrawScreen(curRect, imgNum, imgShape, true, phase(phaseNum).structNum(structIndex), maskNum, [mx my], vbl, debugStr);
            [mx my] = TrackEye(currNode, center, vbl, 0, currObjSize);
            
            % Object go to the end of path. Then start next trial.
            if currNode >= length(path(pathNum).x)
                break;
            end
            
            % If not suspension, increase the number of next frame
            if ~suspension
                frameNum = frameNum+1;
            end

            % Check the state of the keyboard.
            [ keyIsDown, seconds, keyCode ] = KbCheck;

            % If the user is pressing a key, then display its code number and name.
            if keyIsDown

                % Note that we use find(keyCode) because keyCode is an array.
                % See 'help KbCheck'
                % fprintf('You pressed key %i which is %s\n', find(keyCode), KbName(keyCode));

                if keyCode(escapeKey)
                    loop = false;
                    break;
                end

                if keyCode(startKey)
                    suspension = ~suspension;
                end
                
                if keyCode(nextPhaseKey)
                    goToNextPhase = true;
                end

                % If the user holds down a key, KbCheck will report multiple events.
                % To condense multiple 'keyDown' events into a single event, we wait until all
                % keys have been released.
                %while KbCheck; end
            end
      end 

      if structure(phase(phaseNum).structNum(structIndex)).useRewardMovie && loop
        currTime = GetSecs();
        vbl = DrawScreen(curRect, imgNum, imgShape, false, phase(phaseNum).structNum(structIndex), maskNum, [mx my], vbl, debugStr, false);
        [mx my] = TrackEye(-1, [-1 -1], vbl, 0, -1); % TrackEye(currNode, center, vbl, waitForAttention, objSize)
        while GetSecs()-currTime < structure(phase(phaseNum).structNum(structIndex)).movieDelay
          WaitSecs(scr.ifi);
          [mx my] = TrackEye(-1, [-1 -1], vbl, 0, -1);
        end
        
        % Seek to start of movie (timeindex 0):
        Screen('SetMovieTimeIndex', movie(structure(phase(phaseNum).structNum(structIndex)).movieNum).mvPrt, 0);
        % Start playback of movie. This will start
        % the realtime playback clock and playback of audio tracks, if any.
        % Play 'movie', at a playbackrate = 1, with endless loop=1 and
        % 1.0 == 100% audio volume.
        Screen('PlayMovie', movie(structure(phase(phaseNum).structNum(structIndex)).movieNum).mvPrt, 1, 1, 1.0);
        currTime = GetSecs();
        while GetSecs()-currTime < structure(phase(phaseNum).structNum(structIndex)).movieDuration
            vbl = DrawScreen(curRect, imgNum, imgShape, false, phase(phaseNum).structNum(structIndex), maskNum, [mx my], vbl, debugStr, true);
            [mx my] = TrackEye(-1, [-1 -1], vbl, 0, -1); % TrackEye(currNode, center, vbl, waitForAttention, objSize)
        end
        % Done. Stop playback.
        Screen('PlayMovie', movie(structure(phase(phaseNum).structNum(structIndex)).movieNum).mvPrt, 0);
      end
       
      % end of trial and wait 
      % we will use this time to calculate
      currTime = GetSecs();
      vbl = DrawScreen(curRect, imgNum, imgShape, false, phase(phaseNum).structNum(structIndex), maskNum, [mx my], vbl, debugStr);
      [mx my] = TrackEye(0, [-1 -1], vbl, 0, -1);
      % If we use quitting condition, then we need calculate current data.
      if phase(phaseNum).useQuittingCond && loop
          debugStr1 = '';
          debugStr2 = '';
          debugStr3 = '';
          SI = phase(phaseNum).structNum(structIndex);
          % only do something if it is an interesting structure
          experimentData.phase(phaseNum).trial(trialNum).isInterestStruct = false;
          if ~isempty( find(phase(phaseNum).interestStructs == SI) )
              experimentData.phase(phaseNum).trial(trialNum).isInterestStruct = true;

              % find total look observation windows
              % obsWinsIndex - column index of interested correct or
              % incorrect windows
              obsWinsIndex = union(structure(SI).correctObsWins, structure(SI).incorrectObsWins);
              % ms, how long baby look at screen of interested nodes.
              rowIndex = find(  trialData.IsInObsWins(:,length(obswin)+CURR_NODE_NUM) >= structure(SI).interestNodes(1)...
                              & trialData.IsInObsWins(:,length(obswin)+CURR_NODE_NUM) < structure(SI).interestNodes(2)...
                              & trialData.IsInObsWins(:,length(obswin)+IN_WHOLE_SCR) == 1);
              experimentData.phase(phaseNum).trial(trialNum).lookScrTime = 1000*length(rowIndex)/scr.fps; %ms
              % rowIndex - row index of interesting nodes that eye is in whole screen and validity is satisfy.
              rowIndex = find(  trialData.IsInObsWins(:,length(obswin)+CURR_NODE_NUM) >= structure(SI).interestNodes(1)...
                              & trialData.IsInObsWins(:,length(obswin)+CURR_NODE_NUM) < structure(SI).interestNodes(2)...
                              & trialData.IsInObsWins(:,length(obswin)+IN_WHOLE_SCR) == 1 ...
                              & ...
                               (trialData.IsInObsWins(:,length(obswin)+LEYE_VALIDITY) <= structure(SI).validityLevel ...
                              | trialData.IsInObsWins(:,length(obswin)+REYE_VALIDITY) <= structure(SI).validityLevel) ...
                                );
              % obsWinLook - eye look at any corr/incorr observation windows within rowIndex
              obsWinLook = any(trialData.IsInObsWins(rowIndex,obsWinsIndex),2);
              experimentData.phase(phaseNum).trial(trialNum).totalLookObsWins = sum(obsWinLook)/length(rowIndex);
              experimentData.phase(phaseNum).trial(trialNum).isGoodTrial = false;
              if experimentData.phase(phaseNum).trial(trialNum).totalLookObsWins >= structure(SI).requireLooking/100 ...
                      && experimentData.phase(phaseNum).trial(trialNum).lookScrTime >= structure(SI).lookScrTime
                   experimentData.phase(phaseNum).trial(trialNum).isGoodTrial = true;
                   goodTrialNum = goodTrialNum + 1;
              end
              
              debugStr1 = sprintf('LookScr=%.0fms, ObWs/Whole=%.3f, Good=%d|%d'...
                      ,experimentData.phase(phaseNum).trial(trialNum).lookScrTime ...
                      ,experimentData.phase(phaseNum).trial(trialNum).totalLookObsWins...
                      ,experimentData.phase(phaseNum).trial(trialNum).isGoodTrial...
                      ,goodTrialNum);
                  
              % only count when it is a good trial.
              if experimentData.phase(phaseNum).trial(trialNum).isGoodTrial
                  % save information for first look 
                  experimentData.phase(phaseNum).trial(trialNum).firstLookObsWin = 0;
                  experimentData.phase(phaseNum).trial(trialNum).isCorrFirstLook = false;
                  firstRowIndex = rowIndex(find(obsWinLook, 1)); % Now we have original row number of IsInObsWins
                  if ~isempty(firstRowIndex)
                      tmp = trialData.IsInObsWins(firstRowIndex,:); % Get whole row
                      for io=1:length(obsWinsIndex) % find which obs win first look
                          if tmp(obsWinsIndex(io)) == 1
                               experimentData.phase(phaseNum).trial(trialNum).firstLookObsWin = obsWinsIndex(io);
                               if ~isempty(find(structure(SI).correctObsWins == obsWinsIndex(io)))
                                   experimentData.phase(phaseNum).trial(trialNum).isCorrFirstLook = true;
                               end
                               break;
                          end
                      end
                  end
                  % save information for total look and ttest
                  corrObsWinLook = any( trialData.IsInObsWins(rowIndex, structure(SI).correctObsWins), 2 );
                  experimentData.phase(phaseNum).trial(trialNum).corrObsWinRatio = sum(corrObsWinLook)/sum(obsWinLook);

                  debugStr2 = sprintf('FirstLook=%d|%d, CorrObWs%%=%.3f'...
                      ,experimentData.phase(phaseNum).trial(trialNum).firstLookObsWin...
                      ,experimentData.phase(phaseNum).trial(trialNum).isCorrFirstLook...
                      ,experimentData.phase(phaseNum).trial(trialNum).corrObsWinRatio...
                      );
              end
          end
          
          % If good trials more than or equal to last trials, check the condition. If OK, go to next phase.
          if goodTrialNum >= maxLastTrialNum
              ti = trialNum; % reverse counter
              ai = 0; bi = 0; ci = 0;
              sumOfTotalLookingRatio = 0;
              totalCorrFirstLook = 0;
              ttestValues = [];
              finishedLastNtrialCal = [0 0 0];
              while ti > 0
                  if experimentData.phase(phaseNum).trial(ti).isInterestStruct && experimentData.phase(phaseNum).trial(ti).isGoodTrial
                      % Total look criterion
                      if ~finishedLastNtrialCal(TOTAL_LOOK)
                          if ai < phase(phaseNum).numOfLastTrial(TOTAL_LOOK)
                              sumOfTotalLookingRatio = sumOfTotalLookingRatio + experimentData.phase(phaseNum).trial(ti).corrObsWinRatio;
                              ai = ai + 1;
                          end
                          if ai == phase(phaseNum).numOfLastTrial(TOTAL_LOOK)
                              experimentData.phase(phaseNum).trial(trialNum).criterion.totalLookPercentage = sumOfTotalLookingRatio/phase(phaseNum).numOfLastTrial(TOTAL_LOOK);
                              % If TOTAL_LOOK match the criterion before, we don't check again and it always pass.
                              if quittingCriterion(TOTAL_LOOK) == true || sumOfTotalLookingRatio/phase(phaseNum).numOfLastTrial(TOTAL_LOOK) >= phase(phaseNum).totalLook.lookPercentage/100
                                  experimentData.phase(phaseNum).trial(trialNum).criterion.isCorr(TOTAL_LOOK) = true;
                                  quittingCriterion(TOTAL_LOOK) = true;
                              else
                                  experimentData.phase(phaseNum).trial(trialNum).criterion.isCorr(TOTAL_LOOK) = false;
                              end
                              finishedLastNtrialCal(TOTAL_LOOK) = true; % stop to get in again
                          elseif  ai == maxLastTrialNum % This happened, because other condition reach the numOfLastTrial and in OR logic.
                              experimentData.phase(phaseNum).trial(trialNum).criterion.totalLookPercentage = -1;
                              experimentData.phase(phaseNum).trial(trialNum).criterion.isCorr(TOTAL_LOOK) = false;
                              quittingCriterion(TOTAL_LOOK) = false;
                          end
                      end
                      % First look criterion
                      if ~finishedLastNtrialCal(FIRST_LOOK)
                          if bi < phase(phaseNum).numOfLastTrial(FIRST_LOOK)
                              if experimentData.phase(phaseNum).trial(ti).isCorrFirstLook
                                  totalCorrFirstLook = totalCorrFirstLook + 1;
                              end
                              bi = bi + 1;
                          end
                          if bi == phase(phaseNum).numOfLastTrial(FIRST_LOOK)
                              experimentData.phase(phaseNum).trial(trialNum).criterion.totalCorrFirstLook = totalCorrFirstLook; 
                              % If FIRST_LOOK match the criterion before, we don't check again and it always pass.
                              if quittingCriterion(FIRST_LOOK) == true || totalCorrFirstLook >= phase(phaseNum).firstLook.numOfCorrLook
                                  experimentData.phase(phaseNum).trial(trialNum).criterion.isCorr(FIRST_LOOK) = true;
                                  quittingCriterion(FIRST_LOOK) = true;
                              else
                                  experimentData.phase(phaseNum).trial(trialNum).criterion.isCorr(FIRST_LOOK) = false;
                              end
                              finishedLastNtrialCal(FIRST_LOOK) = true; % stop to get in again
                          elseif bi == maxLastTrialNum % This happened, because other condition reach the numOfLastTrial and in OR logic.
                              experimentData.phase(phaseNum).trial(trialNum).criterion.totalCorrFirstLook = -1;
                              experimentData.phase(phaseNum).trial(trialNum).criterion.isCorr(FIRST_LOOK) = false;
                              quittingCriterion(FIRST_LOOK) = false;
                          end
                      end
                      % Ttest criterion
                      if ~finishedLastNtrialCal(TTEST)
                          if ci < phase(phaseNum).numOfLastTrial(TTEST)
                              ttestValues = [experimentData.phase(phaseNum).trial(ti).corrObsWinRatio ttestValues];
                              ci = ci + 1;
                          end
                          if ci == phase(phaseNum).numOfLastTrial(TTEST)
                              [h,p] = ttest(ttestValues, phase(phaseNum).ttest.mean/100, phase(phaseNum).ttest.alpha, 'right');
                              experimentData.phase(phaseNum).trial(trialNum).criterion.ttestPvalue = p;
                              % If TTEST match the criterion before, we don't check again and it always pass.
                              if quittingCriterion(TTEST) == true || h == 1
                                  experimentData.phase(phaseNum).trial(trialNum).criterion.isCorr(TTEST) = true;
                                  quittingCriterion(TTEST) = true;
                              else
                                  experimentData.phase(phaseNum).trial(trialNum).criterion.isCorr(TTEST) = false;
                              end
                              finishedLastNtrialCal(TTEST) = true; % stop to get in again
                          elseif ci == maxLastTrialNum % This happened, because other condition reach the numOfLastTrial and in OR logic.
                              experimentData.phase(phaseNum).trial(trialNum).criterion.ttestPvalue = -1;
                              experimentData.phase(phaseNum).trial(trialNum).criterion.isCorr(TTEST) = false;
                              quittingCriterion(TTEST) = false;
                          end
                      end

                      % finish all calculation of criterions and then break
%                       if ai > phase(phaseNum).numOfLastTrial(TOTAL_LOOK) && ...
%                          bi > phase(phaseNum).numOfLastTrial(FIRST_LOOK) && ...
%                          ci > phase(phaseNum).numOfLastTrial(TTEST)
                      if ai == maxLastTrialNum || bi == maxLastTrialNum || ci == maxLastTrialNum
                          % find out match all the conditions or not
                          % first logic
                          firstLogic = false;
                          if phase(phaseNum).logics(1) == NONE
                              if experimentData.phase(phaseNum).trial(trialNum).criterion.isCorr( phase(phaseNum).conditions(1) )
                                  firstLogic = true;
                              else
                                  firstLogic = false;
                              end
                          elseif phase(phaseNum).logics(1) == OR
                              if experimentData.phase(phaseNum).trial(trialNum).criterion.isCorr( phase(phaseNum).conditions(1) )...
                                      || experimentData.phase(phaseNum).trial(trialNum).criterion.isCorr( phase(phaseNum).conditions(2) )
                                  firstLogic = true;
                              else
                                  firstLogic = false;
                              end
                          elseif phase(phaseNum).logics(1) == AND
                              if experimentData.phase(phaseNum).trial(trialNum).criterion.isCorr( phase(phaseNum).conditions(1) )...
                                      && experimentData.phase(phaseNum).trial(trialNum).criterion.isCorr( phase(phaseNum).conditions(2) )
                                  firstLogic = true;
                              else
                                  firstLogic = false;
                              end
                          end
                          
                          % second logic
                          if phase(phaseNum).logics(2) == NONE
                              nextPhase = firstLogic;
                          elseif phase(phaseNum).logics(2) == OR
                              if firstLogic || experimentData.phase(phaseNum).trial(trialNum).criterion.isCorr( phase(phaseNum).conditions(3) )
                                  nextPhase = true;
                              else
                                  nextPhase = false;
                              end
                          elseif phase(phaseNum).logics(2) == AND
                              if firstLogic && experimentData.phase(phaseNum).trial(trialNum).criterion.isCorr( phase(phaseNum).conditions(3) )
                                  nextPhase = true;
                              else
                                  nextPhase = false;
                              end
                          end
                          
                          experimentData.phase(phaseNum).trial(trialNum).criterion.isAchieved = nextPhase;
                          if nextPhase == true || max([ai bi ci]) == quitLastTrialNum
                              break;  
                          end
                      end
                  end
                  
                  ti = ti - 1;
              end
              
              debugStr3 = sprintf('Cond: TL=%.3f|%d, FL=%d|%d, TTest=%.6f|%d, Next=%d'...
                      ,experimentData.phase(phaseNum).trial(trialNum).criterion.totalLookPercentage...
                      ,experimentData.phase(phaseNum).trial(trialNum).criterion.isCorr(TOTAL_LOOK)...
                      ,experimentData.phase(phaseNum).trial(trialNum).criterion.totalCorrFirstLook...
                      ,experimentData.phase(phaseNum).trial(trialNum).criterion.isCorr(FIRST_LOOK)...
                      ,experimentData.phase(phaseNum).trial(trialNum).criterion.ttestPvalue...
                      ,experimentData.phase(phaseNum).trial(trialNum).criterion.isCorr(TTEST)...
                      ,nextPhase...
                      );
          end % finish to check the condition. 

          debugStr{1} = sprintf('P#=%d, S=%d, I=%d, %s, %s'...
                      ,phaseNum...
                      ,SI...
                      ,experimentData.phase(phaseNum).trial(trialNum).isInterestStruct...
                      ,debugStr1...
                      ,debugStr2...
                      );
          debugStr{2} = debugStr3;
                  
          if debug
            disp(debugStr{1});
            disp(debugStr{2});
          end
      end % end of use quitting conditions

      %MO: vbl.. below modified; added false, phase(phaseNum).blankISI for
      %blank screen
      vbl = DrawScreen(curRect, imgNum, imgShape, false, phase(phaseNum).structNum(structIndex), maskNum, [mx my], vbl, debugStr, false, phase(phaseNum).blankISI);
      [mx my] = TrackEye(0, [-1 -1], vbl, 0, -1);
      %MO: this added to compute actual waittime
      mo_var_waitTime = round(rand*(phase(phaseNum).waitTime2-phase(phaseNum).waitTime1))+phase(phaseNum).waitTime1;
      while GetSecs()-currTime < mo_var_waitTime; %MO: WAS: < phase(phaseNum).waitTime
          WaitSecs(scr.ifi);
          [mx my] = TrackEye(0, [-1 -1], vbl, 0, -1);
      end

      % Save data
      experimentData.phase(phaseNum).trial(trialNum).endTime = currTime;
%       experimentData.phase(phaseNum).trial(trialNum).image = trialData.image;
%       experimentData.phase(phaseNum).trial(trialNum).eye = trialData.eye;
%       experimentData.phase(phaseNum).trial(trialNum).node = trialData.node;
%       experimentData.phase(phaseNum).trial(trialNum).trackTime = trialData.trackTime;
%       experimentData.phase(phaseNum).trial(trialNum).IsInObsWins = trialData.IsInObsWins;
%       experimentData.phase(phaseNum).trial(trialNum).waitAttention = trialData.waitAttention;
      save([experimentData.tempTrialDataDir '/TrailData_' num2str(phaseNum) '_' num2str(trialNum) '.mat'], 'trialData');
      save('experimentData.mat', 'experimentData');
      
      trialNum = trialNum + 1;
    end % trial while loop end    
    phaseNum = phaseNum + 1;
  end % phase while loop end
  
    % Finish the experiment
    %pause(2);
    CloseAll();
    return;

catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    %pause(2);
    CloseAll();
    err = lasterror;
    disp(err.message);
    for i=1:size(err.stack,1)
        disp(err.stack(i,1));
    end
    psychrethrow(psychlasterror);
end %try..catch..   

%% Find the moving object center (x,y)
    function [nodeNum center currObjSize] = findMoveObjCenter(curFrameNum, speed, fps, pathNum, imgSize)
        
        % The speed is different on each node, so we rely on the time to
        % calculat the node position.
        % Find all time duration for each node according to frame rate and speed
        len = length(path(pathNum).distance);
        restTime = curFrameNum/fps;
        nodeSpeed = speed*path(pathNum).objSpeedRatio; 
        nodeTime = path(pathNum).distance./nodeSpeed;
        
        % Path reaches the end node.
        if restTime >= sum(nodeTime)
            center = [path(pathNum).x(len+1) path(pathNum).y(len+1)];
            nodeNum = len+1;
            currObjSize = imgSize*path(pathNum).objSizeRatio(nodeNum);
            return;
        end
            
        % Find the rest of time at current node.
        for I = 1:len
            if restTime >= nodeTime(I)
                restTime = restTime - nodeTime(I);
            else
                break;
            end
        end
        
        nodeNum = I;
        
        % if the rest of time is 0, it is at the start point of that
        % portion of path
        if restTime == 0
            center = [path(pathNum).x(I) path(pathNum).y(I)];
            currObjSize = imgSize*path(pathNum).objSizeRatio(nodeNum);
        else
            center(1) = (path(pathNum).x(I+1) - path(pathNum).x(I))*restTime/nodeTime(I) + path(pathNum).x(I);
            center(2) = (path(pathNum).y(I+1) - path(pathNum).y(I))*restTime/nodeTime(I) + path(pathNum).y(I);
            currObjSize = imgSize * (path(pathNum).objSizeRatio(nodeNum) + (path(pathNum).objSizeRatio(nodeNum+1)-path(pathNum).objSizeRatio(nodeNum)) * restTime/nodeTime(I));
        end
    end

%% Find the eye postion and save the data 
    function [mx my] = TrackEye(currNode, center, vbl, waitForAttention, objSize)
	mx = -1;
        my = -1;
        gazeData = [];
        if( EYETRACKER )
            trialData.eye(trackEyeNum).calltime = GetSecs;
            gazeData = talk2tobii('GET_SAMPLE');
            trialData.eye(trackEyeNum).responsetime = GetSecs;
            if isempty(gazeData)
                CloseAll();
                error('Cannot get the gaze data from Tobii system!');
            end

            currTobiiTime = gazeData(5)*1000 +... % Time in sec returned from the TETserver
                                    gazeData(6)/1000;    % Time in usec returned from the TETserver
            if currTobiiTime == preTobiiTime
                return; %Don't save duplicate data from Tobii
            else
                preTobiiTime = currTobiiTime;
            end
            
            if gazeData(1:4) > 0 % both eyes are valid
                mx = (gazeData(1)+gazeData(3))*scr.winRect(3)/2;
                my = (gazeData(2)+gazeData(4))*scr.winRect(4)/2;                
            else
                if gazeData(1:2) > 0 % left eye is valid
                    mx = gazeData(1)*scr.winRect(3);
                    my = gazeData(2)*scr.winRect(4);
                elseif gazeData(3:4) > 0 % right eye is valid
                    mx = gazeData(3)*scr.winRect(3);
                    my = gazeData(4)*scr.winRect(4);
                else
                    mx = -1;
                    my = -1;
                end
            end 
        else
            trialData.eye(trackEyeNum).calltime = GetSecs;
            [mx, my, buttons]=GetMouse(0); %for debug by mouse;
            trialData.eye(trackEyeNum).responsetime = GetSecs;
        end
        
        %Save data of eye tracking and image moving center
        trialData.image(trackEyeNum).center = center;
        trialData.image(trackEyeNum).objSize = objSize;
        trialData.eye(trackEyeNum).center = [mx my];
        trialData.eye(trackEyeNum).gazeData = gazeData;
        %trialData.filpScr(trackEyeNum).time = vbl;
        trialData.node(trackEyeNum).currNode = currNode;
        trialData.waitAttention(trackEyeNum).value = waitForAttention;
        trialData.trackTime(trackEyeNum).time = GetSecs();
        IsInObsWins = zeros(1,length(obswin)+4);
        for oi=1:length(obswin)
            IsInObsWins(oi) = IsInRect(mx, my, obswin(oi).rect);
        end
        IsInObsWins(length(obswin)+IN_WHOLE_SCR) = IsInRect(mx, my, scr.rect);
        IsInObsWins(length(obswin)+CURR_NODE_NUM) = currNode;
        if isempty(gazeData)
            IsInObsWins(length(obswin)+LEYE_VALIDITY) = 0; % 0 is best validity.
            IsInObsWins(length(obswin)+REYE_VALIDITY) = 0; % 0 is best validity.
        else
            IsInObsWins(length(obswin)+LEYE_VALIDITY) = gazeData(7);
            IsInObsWins(length(obswin)+REYE_VALIDITY) = gazeData(8);
        end
        trialData.IsInObsWins(trackEyeNum,:) = IsInObsWins;
        
        %Record key number
        [ keyIsDown, seconds, keyCode ] = KbCheck(-1);
        if keyIsDown
            keyNum = find(keyCode);
            if length(keyNum) == 1
                trialData.keyInput(trackEyeNum).keyNum = keyNum;
            else
                trialData.keyInput(trackEyeNum).keyNum = -1;
            end
        else
            trialData.keyInput(trackEyeNum).keyNum = -1;
        end
        
        % for testing only
%         if trackEyeNum > 1 && trialData.eye(trackEyeNum).calltime - trialData.eye(trackEyeNum-1).calltime > 100
%             beep;
%         end
        
        trackEyeNum = trackEyeNum+1;
    end
%% Set structure index
    function structIndex = SetStructIndex(phaseNum, trialNum)
        N = length(phase(phaseNum).structNum);
        if phase(phaseNum).fixPercentage
            tmp = 100*rand;
            for structIndex = 1:N % rand select structure index
                if tmp < sum(phase(phaseNum).structPercentage(1:structIndex))
                    break;
                end
            end
            for j = 1:N
                if (phase(phaseNum).structCounter(structIndex)+1) <= trialNum*phase(phaseNum).structPercentage(structIndex)/100
                    break;
                else
                    structIndex = structIndex + 1;
                    structIndex = mod(structIndex,N+1);
                    if structIndex == 0
                        structIndex = 1;
                    end
                end
            end
        else
            structIndex = ceil(N*rand);
        end
        phase(phaseNum).structCounter(structIndex) = phase(phaseNum).structCounter(structIndex)+1;
    end

%% Get out from waitForAttention by press key 'g'
    function ans=IsKeepGoing()
        ans = false;
        % Check the state of the keyboard.
        [ keyIsDown, seconds, keyCode ] = KbCheck; 
        % If the user is pressing a key, then display its code number and name.
        if keyIsDown
            if keyCode(keepGoingKey)
                ans = true; % keep going even if eyes don't look at the observation windows.
            end
            % If the user holds down a key, KbCheck will report multiple events.
            % To condense multiple 'keyDown' events into a single event, we wait until all
            % keys have been released.
            %while KbCheck; end
        end
    end

%% Find max last trial num
    function [maxLastTrialNum quitLastTrialNum] = FindMaxLastTrialNum(pn)
        maxLastTrialNum = phase(pn).numOfLastTrial(phase(pn).conditions(1)); % start checking logic.
        quitLastTrialNum = phase(pn).numOfLastTrial(phase(pn).conditions(1)); % quit checking logic.
        if phase(pn).logics(1) ~= NONE
          if phase(pn).logics(1) == OR % select small one
              if maxLastTrialNum > phase(pn).numOfLastTrial(phase(pn).conditions(2))
                  maxLastTrialNum = phase(pn).numOfLastTrial(phase(pn).conditions(2));
              end
          elseif phase(pn).logics(1) == AND %select big one
              if maxLastTrialNum < phase(pn).numOfLastTrial(phase(pn).conditions(2))
                  maxLastTrialNum = phase(pn).numOfLastTrial(phase(pn).conditions(2));
              end
          end
          if quitLastTrialNum < phase(pn).numOfLastTrial(phase(pn).conditions(2))
              quitLastTrialNum = phase(pn).numOfLastTrial(phase(pn).conditions(2));
          end
        end
        if phase(pn).logics(2) ~= NONE
          if phase(pn).logics(2) == OR % select small one
              if maxLastTrialNum > phase(pn).numOfLastTrial(phase(pn).conditions(3))
                  maxLastTrialNum = phase(pn).numOfLastTrial(phase(pn).conditions(3));
              end
          elseif phase(pn).logics(2) == AND %select big one
              if maxLastTrialNum < phase(pn).numOfLastTrial(phase(pn).conditions(3))
                  maxLastTrialNum = phase(pn).numOfLastTrial(phase(pn).conditions(3));
              end
          end
          if quitLastTrialNum < phase(pn).numOfLastTrial(phase(pn).conditions(3))
              quitLastTrialNum = phase(pn).numOfLastTrial(phase(pn).conditions(3));
          end
        end
        disp(sprintf('maxLastTrialNum = %d, quitLastTrialNum = %d', maxLastTrialNum, quitLastTrialNum));
    end

%% Close all
    function CloseAll()
        % Finish the experiment
        if(EYETRACKER)
            talk2tobii('STOP_RECORD');
            talk2tobii('STOP_TRACKING');
            talk2tobii('SAVE_DATA',trackFileName,eventFileName,'TRUNK');
            talk2tobii('DISCONNECT');    
        end
        
        if(NIRSMACHINE)%MO: Stop the ETG 
            SerialComm( 'write', SerialOTNum, oted ); 
        end 
            
    
%         for i = 1:length(sound)
%             % Stop playback:
%             alSourceStop(sound(i).source);
% 
%             % Unqueue sound buffer:
%             alSourceUnqueueBuffers(sound(i).source, 1);
% 
%             % Wait a bit:
%             WaitSecs(0.1);
% 
%             % Delete buffer:
%             alDeleteBuffers(1, sound(i).buffers);
% 
%             % Wait a bit:
%             WaitSecs(0.1);
% 
%             % Delete source:
%             alDeleteSources(1, sound(i).source);
% 
%             % Wait a bit:
%             WaitSecs(0.1);
%         end
        % Shutdown OpenAL:
        CloseOpenAL;  

        % Close all open onscreen and offscreen windows and textures, movies and video
        % sources. Release nearly all ressources.
        Screen('CloseAll');
        ShowCursor;
        Priority(0);
        
        %save(['data' datestr(now, 'yymmddHHMMSS')],'experimentData');
        SaveAllData()
    end

end