function CreateCsvData(inputFilename, outputFilename)
% CreateXCsvData(inputFilename, outputFilename) will create a 
% output .csv file according to input file (experimentData.mat). 
% Here experimentData.mat file was create by Tobii experiment.
% By default, 
% inputFilename='experimentData.mat'
% outputFilename = 'CsvData.csv' & 'CsvData.txt'
%
% Columes' title of text file will be 
% TobiiTime(ms),CallTime(ms),ResponseTime(ms),Phase#,Trial#,Struct#,Path#,Node#,
% LeyeValidity,ReyeValidity,gazeX,gazeY,waitAttention,KeyInput
% Obswin1,Obswin2,Obswin3,...ElsewhereWin
% version = 1; Title without waitAttention,CallTime(ms),ResponseTime(ms),ObjCenterX,ObjCenterY,ObjSize,KeyInput
% version = 2; Title without CallTime(ms),ResponseTime(ms),ObjCenterX,ObjCenterY,ObjSize,KeyInput
% version = 3; Title without ObjCenterX,ObjCenterY,ObjSize,KeyInput 
% version = 4; Title without KeyInput
% version = 5; (default)
% Author: Johnny, 5/26/2010

% Check input arguments
if nargin == 0
    inputFilename = 'experimentData.mat';
    outputFilename = 'CsvData';
elseif nargin == 1    
    outputFilename = 'CsvData';
elseif nargin ~= 2
    disp('Error input arguments: CreateCsvData(''inputFile.mat'', ''outputFile''!');
    return
end

% Try to load input file
try
    load(inputFilename);
catch
    ME=lasterror; %MO: comma added %MO: modified yet again
    error(ME.message);
end

if isempty(experimentData)
    error('Input data file is empty!');
end

% set version
version = 5;
if ~isfield(experimentData.phase(1).trial(1), 'keyInput')
    version = 4;
end
if ~isfield(experimentData.phase(1).trial(1).image(1), 'objSize')
    version = 3;
end
if ~isfield(experimentData.phase(1).trial(1).eye(1), 'calltime')
    version = 2;
end
if ~isfield(experimentData.phase(1).trial(1), 'waitAttention')
    version = 1;
end
disp(['Tobii experiment version: ' num2str(version)]);

% create the title of columes file
fid = fopen([outputFilename '.txt'], 'w');
totalColNum = 0;
if fid == -1
    error('Cannot create output colume title txt file!');
else
    switch version 
        case 1
            fprintf(fid, 'TobiiTime(ms),Phase#,Trial#,Struct#,Path#,Node#,LeyeValidity,ReyeValidity,gazeX,gazeY,');
        case 2
            fprintf(fid, 'TobiiTime(ms),Phase#,Trial#,Struct#,Path#,Node#,LeyeValidity,ReyeValidity,gazeX,gazeY,waitAttention,');
        case 3
            fprintf(fid, 'TobiiTime(ms),CallTime(ms),ResponseTime(ms),Phase#,Trial#,Struct#,Path#,Node#,LeyeValidity,ReyeValidity,gazeX,gazeY,waitAttention,');
        case 4
            fprintf(fid, 'TobiiTime(ms),CallTime(ms),ResponseTime(ms),Phase#,Trial#,Struct#,Path#,Node#,LeyeValidity,ReyeValidity,gazeX,gazeY,waitAttention,ObjCenterX,ObjCenterY,ObjSize,');
        case 5
            fprintf(fid, 'TobiiTime(ms),CallTime(ms),ResponseTime(ms),Phase#,Trial#,Struct#,Path#,Node#,LeyeValidity,ReyeValidity,gazeX,gazeY,waitAttention,ObjCenterX,ObjCenterY,ObjSize,KeyInput,');
    end
    for i=1:length(experimentData.obswin)
        fprintf(fid, ['Obswin' num2str(i) ',']);
    end
    fprintf(fid, 'ElsewhereWin\n');
    switch version 
        case 1
            totalColNum = 9+i+1;
        case 2
            totalColNum = 10+i+1;
        case 3
            totalColNum = 12+i+1;
        case 4
            totalColNum = 15+i+1;
    end
end

%Add information for each phase quitting.
phaseNum = 1;
while (phaseNum <= length(experimentData.phase))
    fprintf(fid, 'Phase#=%d', phaseNum);
    fprintf(fid, ',TotalTrial#=%d', experimentData.phase(phaseNum).trialNum);
    if ~isempty(experimentData.phase(phaseNum).trial)
        if ~isempty(experimentData.phase(phaseNum).trial(end).eye(end).gazeData)
            startTime = experimentData.phase(phaseNum).trial(1).eye(1).gazeData(5)*1000 +... % Time in sec returned from the TETserver
                            experimentData.phase(phaseNum).trial(1).eye(1).gazeData(6)/1000;    % Time in usec returned from the TETserver
            endTime = experimentData.phase(phaseNum).trial(end).eye(end).gazeData(5)*1000 +... % Time in sec returned from the TETserver
                            experimentData.phase(phaseNum).trial(end).eye(end).gazeData(6)/1000;    % Time in usec returned from the TETserver
            fprintf(fid, ',TotalTime(s)=%.3f', endTime/1000 - startTime/1000);
        else % do not connect to Tobii
            rowNum = 0;
            trialNum = 1;
            while trialNum <= length(experimentData.phase(phaseNum).trial)
                rowNum = rowNum+length(experimentData.phase(phaseNum).trial(trialNum).eye);
                trialNum = trialNum+1;
            end
            fprintf(fid, ',TotalTime(s)=%.3f', rowNum/60);
        end
    else %trial=[], when user 'Esc' in the very beginning of phase
        fprintf(fid, ',TotalTime(s)=0');
    end
    fprintf(fid, ',FinalTrial#=%d',length(experimentData.phase(phaseNum).trial));
    if isfield(experimentData.phase(phaseNum), 'useQuittingCond')
        % phase quitting condition constant
        NONE = 0;
        TOTAL_LOOK = 1;
        FIRST_LOOK = 2;
        TTEST = 3;
        AND = 1;
        OR = 2;
        fprintf(fid, ',UseQuittingCond=%d', experimentData.phase(phaseNum).useQuittingCond);
        if experimentData.phase(phaseNum).useQuittingCond && ~isempty(experimentData.phase(phaseNum).trial)
            %Find quitting by conditon or total trial
            if isfield(experimentData.phase(phaseNum).trial(end), 'criterion')&& ~isempty(experimentData.phase(phaseNum).trial(end).criterion)
                if isfield(experimentData.phase(phaseNum).trial(end).criterion', 'isAchieved') 
                    if experimentData.phase(phaseNum).trial(end).criterion.isAchieved
                        fprintf(fid, ',Quitting=Condition');
                    else
                        fprintf(fid, ',Quitting=TotalTrial');
                    end
                else  %do not have enough good trial
                    fprintf(fid, ',Quitting=TotalTrial');
                end
            else %do not have enough good trial
                fprintf(fid, ',Quitting=TotalTrial');
            end
            fprintf(fid, ',Condition=(%s ', WhichCondi(experimentData.phase(phaseNum).conditions(1)));
            fprintf(fid, '%s ', WhichLogic(experimentData.phase(phaseNum).logics(1)));
            fprintf(fid, '%s) ', WhichCondi(experimentData.phase(phaseNum).conditions(2)));
            fprintf(fid, '%s ', WhichLogic(experimentData.phase(phaseNum).logics(2)));
            fprintf(fid, '%s', WhichCondi(experimentData.phase(phaseNum).conditions(3)));
            
            %find GoodTrial and BadTrial
            GOOD_TRIAL_NUM = 1;
            CONDI_VALUE = 2;
            ACHIEVED = 3;
            condiResult = zeros(3,3);
            maxLastTrialNum = 0;
            for i=1:length(experimentData.phase(phaseNum).conditions)
              if experimentData.phase(phaseNum).conditions(i) ~= 0 % not a none condition
                  if maxLastTrialNum < experimentData.phase(phaseNum).numOfLastTrial(experimentData.phase(phaseNum).conditions(i))
                      maxLastTrialNum = experimentData.phase(phaseNum).numOfLastTrial(experimentData.phase(phaseNum).conditions(i));
                  end
              end
            end
            goodTrialNum = 0; BadTrialNum = 0;
            for ti=1:length(experimentData.phase(phaseNum).trial)
                if experimentData.phase(phaseNum).trial(ti).isInterestStruct
                    if experimentData.phase(phaseNum).trial(ti).isGoodTrial
                        goodTrialNum = goodTrialNum + 1;
                        if goodTrialNum >= maxLastTrialNum
                            if experimentData.phase(phaseNum).trial(ti).criterion.isCorr(TOTAL_LOOK) && condiResult(TOTAL_LOOK,ACHIEVED) == false
                                condiResult(TOTAL_LOOK,GOOD_TRIAL_NUM) = goodTrialNum;
                                condiResult(TOTAL_LOOK,CONDI_VALUE) = experimentData.phase(phaseNum).trial(ti).criterion.totalLookPercentage;
                                condiResult(TOTAL_LOOK,ACHIEVED) = true;
                            end
                            if experimentData.phase(phaseNum).trial(ti).criterion.isCorr(FIRST_LOOK) && condiResult(FIRST_LOOK,ACHIEVED) == false
                                condiResult(FIRST_LOOK,GOOD_TRIAL_NUM) = goodTrialNum;
                                condiResult(FIRST_LOOK,CONDI_VALUE) = experimentData.phase(phaseNum).trial(ti).criterion.totalCorrFirstLook;
                                condiResult(FIRST_LOOK,ACHIEVED) = true;
                            end
                            if experimentData.phase(phaseNum).trial(ti).criterion.isCorr(TTEST) && condiResult(TTEST,ACHIEVED) == false
                                condiResult(TTEST,GOOD_TRIAL_NUM) = goodTrialNum;
                                condiResult(TTEST,CONDI_VALUE) = experimentData.phase(phaseNum).trial(ti).criterion.ttestPvalue;
                                condiResult(TTEST,ACHIEVED) = true;
                            end
                        end
                    else
                        BadTrialNum = BadTrialNum + 1;
                    end
                end
            end
            fprintf(fid, ',GoodTrial#=%d,BadTrial#=%d',goodTrialNum,BadTrialNum);
            if condiResult(TOTAL_LOOK,ACHIEVED)
                fprintf(fid, ',SuccessTL=1');
                fprintf(fid, ',TLTrial#=%d',condiResult(TOTAL_LOOK,GOOD_TRIAL_NUM));
                fprintf(fid, ',TotalLook=%.3f',condiResult(TOTAL_LOOK,CONDI_VALUE));
            else
                fprintf(fid, ',SuccessTL=0');
                fprintf(fid, ',TLTrial#=%d',goodTrialNum);
                if goodTrialNum >= maxLastTrialNum
                    fprintf(fid, ',TotalLook=%.3f',experimentData.phase(phaseNum).trial(end).criterion.totalLookPercentage);
                else
                    fprintf(fid, ',TotalLook=-1');
                end
            end
            if condiResult(FIRST_LOOK,ACHIEVED)
                fprintf(fid, ',SuccessFL=1');
                fprintf(fid, ',FLTrial#=%d',condiResult(FIRST_LOOK,GOOD_TRIAL_NUM));
                fprintf(fid, ',FirstLook=%d',condiResult(FIRST_LOOK,CONDI_VALUE));
            else
                fprintf(fid, ',SuccessFL=0');
                fprintf(fid, ',FLTrial#=%d',goodTrialNum);
                if goodTrialNum >= maxLastTrialNum
                    fprintf(fid, ',FirstLook=%d',experimentData.phase(phaseNum).trial(end).criterion.totalCorrFirstLook);
                else
                    fprintf(fid, ',FirstLook=-1');
                end
            end
            if condiResult(TTEST,ACHIEVED)
                fprintf(fid, ',SuccessTtest=1');
                fprintf(fid, ',TTTrial#=%d',condiResult(TTEST,GOOD_TRIAL_NUM));
                fprintf(fid, ',Ttest=%.3f',condiResult(TTEST,CONDI_VALUE));
            else
                fprintf(fid, ',SuccessTtest=0');
                fprintf(fid, ',TTTrial#=%d',goodTrialNum);
                if goodTrialNum >= maxLastTrialNum
                    fprintf(fid, ',Ttest=%.3f',experimentData.phase(phaseNum).trial(end).criterion.ttestPvalue);
                else
                    fprintf(fid, ',Ttest=-1');
                end
            end
            fprintf(fid, ',TTPval=%.3f',experimentData.phase(phaseNum).ttest.alpha);
        else %do not use quitting condition
            fprintf(fid, ',Quitting=TotalTrial');
        end
    else % old version don't have UseQuittingCond
        fprintf(fid, ',UseQuittingCond=0,Quitting=TotalTrial');
    end
    fprintf(fid, '\n');
    phaseNum = phaseNum + 1;
end
fclose(fid);

% Preallocating Cell Arrays with the cell Function
rowNum = 0;
phaseNum = 1;
while (phaseNum <= length(experimentData.phase))
    trialNum = 1;
    while trialNum <= length(experimentData.phase(phaseNum).trial)
        rowNum = rowNum+length(experimentData.phase(phaseNum).trial(trialNum).eye);
        trialNum = trialNum+1;
    end
    phaseNum = phaseNum+1;
end        
M = cell(rowNum, totalColNum);

% create data csv file
rowNum = 1;
if isempty(experimentData.phase(1).trial(1).eye(1).gazeData)
    gazeTime = 0; % for debug
else
    gazeTime = experimentData.phase(1).trial(1).eye(1).gazeData(5)*1000 +... % ms
                experimentData.phase(1).trial(1).eye(1).gazeData(6)/1000; % ms
end
phaseNum = 1;
while (phaseNum <= length(experimentData.phase))
    trialNum = 1;
    while trialNum <= length(experimentData.phase(phaseNum).trial)
        frameNum = 1;
        structNum = experimentData.phase(phaseNum).trial(trialNum).structNum;
        pathNum = experimentData.structure(structNum).pathNum;
        %pathNum = experimentData.structure( experimentData.phase(phaseNum).structNum( experimentData.phase(phaseNum).trial(trialNum).structNum ) ).pathNum;
        while frameNum <= length(experimentData.phase(phaseNum).trial(trialNum).node) % MO: WAS: trial(trialNum).eye
            colNum = 1;
            % unit of currTime is ms
            if isempty(experimentData.phase(phaseNum).trial(trialNum).eye(frameNum).gazeData)
                currTime = 0; % for debug
            else
                currTime = experimentData.phase(phaseNum).trial(trialNum).eye(frameNum).gazeData(5)*1000 +... % Time in sec returned from the TETserver
                            experimentData.phase(phaseNum).trial(trialNum).eye(frameNum).gazeData(6)/1000;    % Time in usec returned from the TETserver
            end
            %M{rowNum,colNum} = currTime - gazeTime; colNum = colNum+1;
            M{rowNum,colNum} = currTime; colNum = colNum+1;
            if version >= 3 % add in version 3
                M{rowNum,colNum} = experimentData.phase(phaseNum).trial(trialNum).eye(frameNum).calltime*1000; colNum = colNum+1;
                M{rowNum,colNum} = experimentData.phase(phaseNum).trial(trialNum).eye(frameNum).responsetime*1000; colNum = colNum+1;
            end
            M{rowNum,colNum} = phaseNum; colNum = colNum+1;
            M{rowNum,colNum} = trialNum; colNum = colNum+1;
            M{rowNum,colNum} = cast(structNum,'double'); colNum = colNum+1;
            M{rowNum,colNum} = cast(pathNum,'double'); colNum = colNum+1;
            M{rowNum,colNum} = experimentData.phase(phaseNum).trial(trialNum).node(frameNum).currNode; colNum = colNum+1;
            if isempty(experimentData.phase(phaseNum).trial(trialNum).eye(frameNum).gazeData) % for debug
                M{rowNum,colNum} = 0; colNum = colNum+1; % Left eye validity (0-4)
                M{rowNum,colNum} = 0; colNum = colNum+1; % Right eye validity (0-4)
            else
                M{rowNum,colNum} = experimentData.phase(phaseNum).trial(trialNum).eye(frameNum).gazeData(7); colNum = colNum+1; % Left eye validity (0-4)
                M{rowNum,colNum} = experimentData.phase(phaseNum).trial(trialNum).eye(frameNum).gazeData(8); colNum = colNum+1; % Right eye validity (0-4)
            end
            M{rowNum,colNum} = experimentData.phase(phaseNum).trial(trialNum).eye(frameNum).center(1); colNum = colNum+1;   % eye gaze point X
            M{rowNum,colNum} = experimentData.phase(phaseNum).trial(trialNum).eye(frameNum).center(2); colNum = colNum+1;   % eye gaze point Y
            if version >= 2 % add in from version 2
                M{rowNum,colNum} = experimentData.phase(phaseNum).trial(trialNum).waitAttention(frameNum).value; colNum = colNum+1;
            end
            if version >= 4 % add in from version 4
                M{rowNum,colNum} = experimentData.phase(phaseNum).trial(trialNum).image(frameNum).center(1); colNum = colNum+1; % object center X
                M{rowNum,colNum} = experimentData.phase(phaseNum).trial(trialNum).image(frameNum).center(2); colNum = colNum+1; % object center Y
                M{rowNum,colNum} = double(experimentData.phase(phaseNum).trial(trialNum).image(frameNum).objSize); colNum = colNum+1;   % object size (pixel)
            end            
            if version >= 5 % add in from version 5
                M{rowNum,colNum} = double(experimentData.phase(phaseNum).trial(trialNum).keyInput(frameNum).keyNum); colNum = colNum+1; % Input key in number
            end            
            ElsewhereWin = 1;
            for winNum=1:length(experimentData.obswin)
                M{rowNum,colNum} = checkGazePoint(experimentData.phase(phaseNum).trial(trialNum).eye(frameNum).center, experimentData.obswin(winNum));
                if M{rowNum,colNum} == 1
                    ElsewhereWin = 0;
                end
                colNum = colNum+1;
            end
            if experimentData.phase(phaseNum).trial(trialNum).eye(frameNum).center(1) < 0
                ElsewhereWin = 0;
            end
            M{rowNum,colNum} = ElsewhereWin; colNum = colNum+1;
            frameNum = frameNum+1; rowNum = rowNum+1;
        end
        trialNum = trialNum+1;
    end
    phaseNum = phaseNum+1;
end

% we don't use csvwrite, because the precision of csvwrite is 6 by default 
% and cannot change, but the column of accumulate time could be huge number 
% in ms.
%if outputUniqueTimeStampData == 0
    dlmwrite([outputFilename '.csv'], cell2mat(M),'delimiter',',','precision', '%.3f');
% elseif outputUniqueTimeStampData == 1
%     % Create data without duplicate time data
%     M = cell2mat(M);
%     [b,m,n] = unique(M(:,1));
%     M2 = M(m,:);
%     dlmwrite([outputFilename '_uniqueTime.csv'],M2,'delimiter',',','precision', '%.3f');
% elseif outputUniqueTimeStampData == -1
%     dlmwrite([outputFilename '.csv'], cell2mat(M),'delimiter',',','precision', '%.3f');
% 
%     M = cell2mat(M);
%     [b,m,n] = unique(M(:,1));
%     M2 = M(m,:);
%     dlmwrite([outputFilename '_uniqueTime.csv'],M2,'delimiter',',','precision', '%.3f');
% end

end

%% find which condition used in logic
function condiStr = WhichCondi(conditions)
    condiStr = '';
    switch conditions
        case 0
            condiStr = 'None';
        case 1
            condiStr = 'TotalLook';
        case 2
            condiStr = 'FirstLook';
        case 3
            condiStr = 'Ttest';
    end
end

function logicStr = WhichLogic(logic)
    logicStr = '';
    switch logic
        case 0
            logicStr = 'None';
        case 1
            logicStr = 'And';
        case 2
            logicStr = 'Or';
    end
end

%% Check the gaze point w/wo observation window
function within = checkGazePoint(gaze, obswin)
    within = 0;
    if (gaze(1)>=obswin.upperLeftCorner(1) && gaze(1)<=obswin.upperLeftCorner(1)+obswin.width ... % x-coord
        && gaze(2)>=obswin.upperLeftCorner(2) && gaze(2)<=obswin.upperLeftCorner(2)+obswin.height) % y-coord
        within = 1;
    end
end
