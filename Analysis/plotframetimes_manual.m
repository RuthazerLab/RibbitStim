%{
plotframetimes_manual

Plot stimulus timing onto response trace (readout from suite2P)

**Please put Thorsync files in same folder as ThorImage files
(i.e. "Experiment.xml" and "Episode001.h5" needs to be in same folder)


versions
2023.3.17 VL
For Cynthia's 20230227 coherence dots data:
Pls copy stim timings from StimLog .txt file

%}

%% ------Fill in the following parameters----------

%ThorImage and ThorSync files  
thorimagepath = 'F:\Cynthia data\GCaMP data coherence dots 2023\dots1';

%Suite2P file (Fall.mat)
suite2ppath = 'F:\Cynthia data\GCaMP data coherence dots 2023\dots1\Slice 4\suite2p\plane0';

%Index of slice to look at
crtslice = 4;

%Index of cell to look at
cellno = 110;

%Vector with stim timing
stimTimes = [17.0053, 37.0495, 57.079, 77.1101, 97.1432];



%% ------end of user input----------

[Steps,Flyback,Frames,ftimes,CaptureRate] = ReadThorMetadata(thorimagepath);
totslice = Steps + Flyback;

%Match stim timings with frame numbers
stimframes = FindStimFrame(stimTimes,ftimes,crtslice,totslice);

%Plot response trace for specified cell and overlay with vertical lines
%to indicate stim timings
%Note: The following code plots values from "F", you can change it to plot
%from "Fneu" or "spks" instead
tracevals = F(cellno,:);

plot(tracevals,'Color',[0 0.4470 0.7410]);

hold on;
for i = 1:length(stimframes)
    xline(stimframes(i),'Color',[0.9290 0.6940 0.1250]);
end
hold off;
