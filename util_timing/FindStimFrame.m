%{
FindStimFrame.m
2023.3.9 VL
Matches frame timing with given stimulus timings

Inputs
stimTimes: 1 row vector with timings of stimuli
frameTimes: 1 row vector with frame timings from ThorSync
crtslice: slice to extract frame timing for
totslice: total number of slices (steps + flyback)


%}

function stimFrameNumbers = FindStimFrame(stimTimes, ftimes, crtslice, totslice)

ftimes_slice = ftimes(crtslice:totslice:end);

stimFrameNumbers = zeros(1,length(stimTimes));

for i = 1:length(stimTimes)
    stimFrameNumbers(i) = find(ftimes_slice>=stimTimes(i),1)-1;
end

