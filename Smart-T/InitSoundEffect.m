function InitSoundEffect
% Aslin baby lab experiment
% Author: Johnny, 4/1/2008

% Base on moaldemo example
% moaldemo - Minimalistic demo on how to use OpenAL for
% 3D audio output in Matlab. This is mostly trash code
% for initial testing and development. Better demos will
% follow soon.

global debug connTobii connNIRS scr mask obswin loom sound img path structure phase
%MO: connNIRS added above
% Initialize OpenAL subsystem at debuglevel 2 with the default output
% device:
soundLen = length(sound);
InitializeMatlabOpenAL(soundLen);

% Generate sound buffer:
for i=1:soundLen
    sound(i).buffers = alGenBuffers(1);
end

% Query for errors:
alGetString(alGetError)

% Create sound data:

for i = 1:soundLen
    [data, freq, nbits] = wavread(sound(i).filename);

    % Convert to 16 bit signed integer format, map range from -1.0 ; 1.0 to -32768 ; 32768.
    % This is one of two sound formats accepted by OpenAL, the other being unsigned 8 bit
    % integer in range 0;255. Other formats (e.g. float or double) are supported by some
    % implementations, but one can't count on it. This is more efficient anyways...
    data = int16(data * 32767);

    % Fill our sound buffer with the data from the sound vector. Tell AL that its
    % a 16 bpc, mono format, with length(mynoise)*2 bytes total, to be played at
    % a sampling rate of freq Hz. The AL will resample this to the native device
    % sampling rate and format at buffer load time.
    alBufferData( sound(i).buffers, AL.FORMAT_MONO16, data, length(data)*2, freq);

    % Create a sound source:
    sound(i).source = alGenSources(1);

    % Attach our buffer to it: The source will play the buffers sound data.
    alSourceQueueBuffers(sound(i).source, 1, sound(i).buffers);

    % Set emission volume to 100%, aka a gain of 1.0:
    alSourcef(sound(i).source, AL.GAIN, 1);
end

alListenerfv(AL.POSITION, [0, 0, 0]);
alListenerfv(AL.VELOCITY, [0, 0, 0]);
alListenerfv(AL.ORIENTATION, [0, 0, -1, 0, 1, 0]);

return;
