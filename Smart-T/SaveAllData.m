function SaveAllData(experimentDataFile)
% Usage: SaveAllData('experimentData.mat')
% We will save the experimentData, parameters and all trialData
% to a dataYYMMDDHHMMSS.mat file
% Aslin baby lab experiment
% Author: Johnny, 3/13/2009

if nargin == 0
    experimentDataFile = 'experimentData.mat';
end

if ~exist(experimentDataFile,'file')
    error('The experiment data file %s doesn''t exists!', experimentDataFile)
end
load(experimentDataFile); % we have experimentData now.

if ~exist(experimentData.tempTrialDataDir,'dir')
    error('TempTrialData dones''t exists! Cannot save all the data!');
end

load([experimentData.tempTrialDataDir '/parameters.mat']); % We have parameters now.

experimentData.debug = parameters.debug;
experimentData.connTobii = parameters.connTobii;
experimentData.connNIRS = parameters.connNIRS;
experimentData.SerialOTNum = parameters.SerialOTNum;
experimentData.scr = parameters.scr;
experimentData.mask = parameters.mask;
experimentData.obswin = parameters.obswin;
experimentData.loom = parameters.loom;
experimentData.sound = parameters.sound;
experimentData.randomSet = parameters.randomSet;
experimentData.img = parameters.img;
experimentData.path = parameters.path;
experimentData.structure = parameters.structure;


dirFile = dir(experimentData.tempTrialDataDir);
for i=1:length(dirFile)
    if ~dirFile(i).isdir && ~strcmp(dirFile(i).name,'parameters.mat')
        load([experimentData.tempTrialDataDir '/' dirFile(i).name]); % We have trialData now.
        [pathstr, name, ext, versn] = fileparts(dirFile(i).name);
        [dummy phaseNum trialNum] = strread(name, '%s %d %d', 'delimiter', '_');
        experimentData.phase(phaseNum).trial(trialNum).image = trialData.image;
        experimentData.phase(phaseNum).trial(trialNum).eye = trialData.eye;
        experimentData.phase(phaseNum).trial(trialNum).node = trialData.node;
        experimentData.phase(phaseNum).trial(trialNum).trackTime = trialData.trackTime;
        experimentData.phase(phaseNum).trial(trialNum).IsInObsWins = trialData.IsInObsWins;
        experimentData.phase(phaseNum).trial(trialNum).waitAttention = trialData.waitAttention;
        experimentData.phase(phaseNum).trial(trialNum).keyInput = trialData.keyInput;
    end
end

save(['data' datestr(now, 'yymmddHHMMSS')],'experimentData');

rmdir(experimentData.tempTrialDataDir,'s');
