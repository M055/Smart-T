function ObsWinAvgFigure(inputDataFile,inputDataTitleFile,firstNode,lastNode,phaseNum,version)
% ObsWinAvgFigure(inputDataFile,inputDataTitleFile,firstNode,lastNode,phaseNum, version) will show 
% figures of average gaze point in different observation windows based on node by node.
% By default, 
% inputDataFile = 'CsvData.csv';
% inputDataTitleFile = 'CsvData.txt';
% firstNode = -1; (use all nodes in path)
% lastNode = -1; (use all nodes in path)
% phaseNum = -1; (show all phase figures)
% version = 1; Title without waitAttention, CallTime(ms), ResponseTime(ms), ObjCenterX,ObjCenterY,ObjSize 
% version = 2; Title without CallTime(ms), ResponseTime(ms), ObjCenterX,ObjCenterY,ObjSize 
% version = 3; Title without ObjCenterX,ObjCenterY,ObjSize 
% version = 4; (default)
% Author: Johnny, 6/12/09

% Check input arguments
if nargin == 0
    inputDataFile = 'CsvData.csv';
    inputDataTitleFile = 'CsvData.txt';
    firstNode = -1;
    lastNode = -1;
    phaseNum = -1;
    version = 4;
elseif nargin == 2
    firstNode = -1;
    lastNode = -1;
    phaseNum = -1;
    version = 4;
elseif nargin == 3
    lastNode = -1;
    phaseNum = -1;
    version = 4;
elseif nargin == 4
    phaseNum = -1;
    version = 4;
elseif nargin == 5
    version = 4;
elseif nargin ~= 6    
    disp('Error input arguments: ObsWinAvgFigure(''inputDataFile'',''inputDataTitleFile'',firstNode,lastNode,phaseNum, version)!');
    return
end

% read files
tmp = textread(inputDataTitleFile, '%[^\n]');
columnTitle = strread(tmp{1}, '%s','delimiter',',');
data = csvread(inputDataFile);

% define the index of column title in .csv file
I_TIME = 1;                 % time in ms (Tobii)
I_TIME_CALL = 2;            % time before call talk2tobii('GET_SAMPLE');
I_TIME_RESPONSE = 3;        % time after call talk2tobii('GET_SAMPLE');
I_PHASE_NUM = 4;            % phase number
I_TRIAL_NUM = 5;            % trial number
I_PATH_NUM = 6;             % path number
I_NODE_NUM = 7;             % node number
I_LEFTEYE_VALIDITY = 8;     % Left eye validity (0-4)
I_RIGHTEYE_VALIDITY = 9;    % right eye validity (0-4)
I_GAZE_X = 10;              % gaze x
I_GAZE_Y = 11;              % gaze y
I_WAIT_ATTENTION = 12;      % wait for attention in the node
I_OBJ_CENTER_X = 13;        % object center X
I_OBJ_CENTER_Y = 14;        % object center Y
I_OBJ_SIZE = 15;            % object size in pixel
I_OBSWIN = 16;              % observation windows starting index

% for old version
if version == 3
    I_TIME = 1;             % time in ms (Tobii)
    I_TIME_CALL = 2;        % time before call talk2tobii('GET_SAMPLE');
    I_TIME_RESPONSE = 3;    % time after call talk2tobii('GET_SAMPLE');
    I_PHASE_NUM = 4;        % phase number
    I_TRIAL_NUM = 5;        % trial number
    I_PATH_NUM = 6;         % path number
    I_NODE_NUM = 7;         % node number
    I_LEFTEYE_VALIDITY = 8;  % Left eye validity (0-4)
    I_RIGHTEYE_VALIDITY = 9; % right eye validity (0-4)
    I_GAZE_X = 10;           % gaze x
    I_GAZE_Y = 11;           % gaze y
    I_WAIT_ATTENTION = 12;  % wait for attention in the node
    I_OBSWIN = 13;           % observation windows starting index    
elseif version == 2
    I_PHASE_NUM = 2;        % phase number
    I_TRIAL_NUM = 3;        % trial number
    I_PATH_NUM = 4;         % path number
    I_NODE_NUM = 5;         % node number
    I_LEFTEYE_VALIDITY = 6;  % Left eye validity (0-4)
    I_RIGHTEYE_VALIDITY = 7; % right eye validity (0-4)
    I_GAZE_X = 8;           % gaze x
    I_GAZE_Y = 9;           % gaze y
    I_WAIT_ATTENTION = 10;  % wait for attention in the node
    I_OBSWIN = 11;           % observation windows starting index
elseif version == 1
    I_PHASE_NUM = 2;        % phase number
    I_TRIAL_NUM = 3;        % trial number
    I_PATH_NUM = 4;         % path number
    I_NODE_NUM = 5;         % node number
    I_LEFTEYE_VALIDITY = 6;  % Left eye validity (0-4)
    I_RIGHTEYE_VALIDITY = 7; % right eye validity (0-4)
    I_GAZE_X = 8;           % gaze x
    I_GAZE_Y = 9;           % gaze y
    I_OBSWIN = 10;           % observation windows starting index
end

%find average time interval between data rows
timeInterval = FindTimeInterval(data);
if timeInterval == 0 % for testing program that doesn't connect to Tobii
    timeInterval = 1/60;
end

% eliminate waitAttention data
if version > 1 % first version didn't have I_WAIT_ATTENTION column
    data = data(find(data(:,I_WAIT_ATTENTION) == 0),:);
end

% eliminate last unfinished trial data
EliminateLastUnfinishedTrial(); 

totalWinNum = length(columnTitle)-I_OBSWIN+1;
for i=1:totalWinNum
    color(i,:) = rand(1,3)*0.5+0.4;
end
totalPhaseNum = max(data(:,I_PHASE_NUM));

phase = [];
for phaseIndex=1:totalPhaseNum
    phase(phaseIndex).path = FindPhaseAvg(phaseIndex);
end
    
if phaseNum == -1 % show the figure of all phases
    for phaseIndex=1:totalPhaseNum
        ShowFigures(phaseIndex);
    end
elseif phaseNum <= max(data(:,I_PHASE_NUM))
    ShowFigures(phaseNum);
end

%% find frame rate
% we use phase#1 and trial#1 data number and time stamp to figure out the
% average time interval(1/frame rate). 
% We will record the data between trails and time delay will happen, 
% so we need count frame rate within trial duration.
    function timeInterval = FindTimeInterval(data)
        tmpdata = data(find(data(:,I_PHASE_NUM) == 1 & data(:,I_TRIAL_NUM)==1),:);
        node = max(tmpdata(:,I_NODE_NUM));
        tmpdata = data(find(tmpdata(:,I_NODE_NUM) < node));
        timeInterval = (tmpdata(end,I_TIME)-tmpdata(1,I_TIME))/(size(tmpdata,1)-1)/1000;
    end

%% show the figures of average attendance of observation windows in phase
    function ShowFigures(phaseNum)
        figure;
        maxPathNum = length(phase(phaseNum).path);
        for pi = 1:maxPathNum
            maxNodeNum = length(phase(phaseNum).path(pi).node);
            startNode = 1;
            endNode = maxNodeNum;
            if firstNode ~= -1 && firstNode > 0 && firstNode <= maxNodeNum
                startNode = firstNode;
            end
            if lastNode ~= -1 && maxNodeNum > 0 && maxNodeNum <= maxNodeNum
                endNode = lastNode;
            end
            
            avgObswinNum = phase(phaseNum).path(pi).node(startNode).avgObswinNum;
            iNode = size(avgObswinNum,1);
            for ni = startNode+1:endNode
                avgObswinNum = [avgObswinNum' phase(phaseNum).path(pi).node(ni).avgObswinNum']';
                iNode = [iNode size(avgObswinNum,1)];
            end
            % Create time line. Here we get every data per frame and frame rate is 60Hz. 
            time = 0:timeInterval:(size(avgObswinNum,1)-1)*timeInterval;
            
            for iw = 1:totalWinNum
                subplot(totalWinNum,maxPathNum,(iw-1)*maxPathNum+pi);
                plot(time, avgObswinNum(:,iw), '.', 'color', 'black');
                set(gca,'xtick',[],'ytick',[0 1],'xlim',[0 time(end)],'ylim',[0 1],'color', color(iw,:));
                if pi == 1
                    ylabel(columnTitle(I_OBSWIN+iw-1));
                end
                if iw == 1
                    if firstNode == -1 && lastNode == -1
                        title(['Phase ' num2str(phaseNum) '; Path ' num2str(phase(phaseNum).path(pi).pathIndex) '; All Nodes; # of Trial:' num2str(phase(phaseNum).path(pi).numOfTrial)]);
                    elseif endNode == maxNodeNum
                        title(['Phase ' num2str(phaseNum) '; Path ' num2str(phase(phaseNum).path(pi).pathIndex) '; Node:' num2str(startNode) '-' num2str(endNode-1) '; # of Trial:' num2str(phase(phaseNum).path(pi).numOfTrial)]);
                    else
                        title(['Phase ' num2str(phaseNum) '; Path ' num2str(phase(phaseNum).path(pi).pathIndex) '; Node:' num2str(startNode) '-' num2str(endNode) '; # of Trial:' num2str(phase(phaseNum).path(pi).numOfTrial)]);
                    end
                end
                % add line for each node
                textYpos = -0.15;
                if iw == 1
                    text(0,textYpos,num2str(startNode));
                end
                for in = 1:length(iNode)-1
                    if in == length(iNode)-1 && endNode == maxNodeNum
                        line([time(iNode(in)) time(iNode(in))], [0 1], 'color', 'r');
                        if iw == 1
                            text(time(iNode(in)),textYpos,'0'); % line for finishing experiment
                        end
                    else
                        line([time(iNode(in)) time(iNode(in))], [0 1], 'color', 'b');
                        if iw == 1
                            text(time(iNode(in)),textYpos,num2str(in+startNode));
                        end
                    end
                end
            end
            %Reset the bottom subplot to have xticks
            set(gca,'xtickMode', 'auto')
            xlabel('time(s)')
        end
    end

%% Find average attendance of observation windows for each phase
    function path = FindPhaseAvg(phaseIndex)
        path = [];
        I = find(data(:,I_PHASE_NUM)==phaseIndex);
        nums = unique(data(I,I_PATH_NUM));
        for pi = 1:length(nums)
            path(pi).pathIndex = nums(pi);
            path(pi).node = FindPathAvg(phaseIndex, path(pi).pathIndex);
            PI = find(data(:,I_PHASE_NUM)==phaseIndex & data(:,I_PATH_NUM)==path(pi).pathIndex);
            path(pi).numOfTrial = length(unique(data(PI,I_TRIAL_NUM)));
        end
    end

%% Find average attendance of observation windows for each path and phase
    function node = FindPathAvg(phaseIndex, pathIndex)
        node = [];
        I = find(data(:,I_PHASE_NUM)==phaseIndex);
        I = find(data(I,I_PATH_NUM)==pathIndex);
        for nodeIndex=1:max(data(I,I_NODE_NUM))
            node(nodeIndex).avgObswinNum = FindNodeAvg(phaseIndex, pathIndex, nodeIndex);
        end
        % Any node marked 0 is the waitting time between trials, so there is no image.
        node(nodeIndex+1).avgObswinNum = FindNodeAvg(phaseIndex, pathIndex, 0);
    end

%% Find average attendance of observation windows between nodes
    function avgObswinNum = FindNodeAvg(phaseIndex, pathIndex, nodeIndex)
        avgObswinNum = [];
        %for debug
        %disp(sprintf('phaseIndex=%d pathIndex=%d nodeIndex=%d', phaseIndex, pathIndex, nodeIndex));
        I = find(data(:,I_PHASE_NUM)==phaseIndex & data(:,I_PATH_NUM)==pathIndex & data(:,I_NODE_NUM)==nodeIndex);
        if isempty(I)
            return;
        end
        nodeData = data(I,:);
        trialNums = unique(nodeData(:,I_TRIAL_NUM));
        phase(phaseIndex).path(pathIndex).numOfTrial = length(trialNums);
        trialSize = [];
        for ti=1:length(trialNums)
            I = find(nodeData(:,I_TRIAL_NUM)==trialNums(ti));
            trial(ti).data = nodeData(I,:); % Save the data of different trials in same phase, path and node.
            trialSize = [trialSize size(trial(ti).data,1)];
            % for debug
            %totalDataNum = length(find(data(:,I_PHASE_NUM)==phaseIndex & data(:,I_PATH_NUM)==pathIndex & data(:,I_TRIAL_NUM)==trialNums(ti)))
        end
        
        % Since we eliminate waitAttention data, the duration between node
        % to node are same in different trials, but we still find the min.
        minLength = min(trialSize);
        ti = 1;
        avgObswinNum = zeros(minLength,size(trial(1).data, 2)-I_OBSWIN+1);
        while ti <= length(trial)
            avgObswinNum = avgObswinNum + trial(ti).data(1:minLength,I_OBSWIN:end);
            ti = ti+1;
        end
        avgObswinNum = avgObswinNum/length(trial);
    end

%% Eliminate Last Unfinished Trial
    function EliminateLastUnfinishedTrial()
        I = find(data(:,I_PHASE_NUM)==data(end,I_PHASE_NUM) & data(:,I_PATH_NUM)==data(end,I_PATH_NUM));
        trialNums = unique(data(I,I_TRIAL_NUM)); % sorted in ascending order
        % If path exists in more than one trials, we will compare trials. 
        % If number of nodes in last trial is less than first trail, last trial will be eliminated.
        if length(trialNums) > 1
            I2 = find(data(I,I_TRIAL_NUM) == trialNums(1));
            nodeNums1 = unique(data(I2,I_NODE_NUM));
            I2 = find(data(I,I_TRIAL_NUM) == trialNums(end));
            nodeNums2 = unique(data(I2,I_NODE_NUM));
            if length(nodeNums2) < length(nodeNums1)
                I3 = find(data(:,I_PHASE_NUM)==data(end,I_PHASE_NUM) & data(:,I_TRIAL_NUM)==data(end,I_TRIAL_NUM));
                data = data(1:I3(1)-1,:);
            end
        end
    end


end