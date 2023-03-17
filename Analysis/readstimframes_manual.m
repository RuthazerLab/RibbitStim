%{
readstimframes_manual

Example script to match stim timings with corresponding frame numbers

**Please put Thorsync files in same folder as ThorImage files
(i.e. "Experiment.xml" and "Episode001.h5" needs to be in same folder)

Output: 
stimframes = frame numbers for each given stim timepoint


versions
2023.3.17 VL
For Cynthia's 20230227 coherence dots data:
Pls copy stim timings from StimLog .txt file

%}

%% ------Fill in the following parameters----------

%ThorImage and ThorSync files
thorimagepath = 'F:\Cynthia data\GCaMP data coherence dots 2023\dots1';

%Index of slice to look at
crtslice = 4;

%Vector with stim timings
stimTimes = [17.0053, 37.0495, 57.079, 77.1101, 97.1432];



%% ------end of user input----------

%Read metadata from ThorImage "Experiment.xml" and frame data from ThorSync "Episode001.h5"
[Steps,Flyback,Frames,ftimes,CaptureRate] = ReadThorMetadata(thorimagepath);
totslice = Steps + Flyback;

%Match stim timings with frame numbers and display to command line
stimframes = FindStimFrame(stimTimes,ftimes,crtslice,totslice)


