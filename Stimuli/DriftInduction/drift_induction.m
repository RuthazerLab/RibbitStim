%{
drift_induction.m

Script for timed visual stimulus presentation (moving bars) and triggered image capture

Presents moving bar stimulus in single direction

Use:
- Set parameters for stim
- Run script and wait for "press any key" prompt to display on command line
- Start capture on ThorImage (set trigger mode to "trigger first")
- Press any key to start experiment

Notes
*If the program shows "Capture initiated" but capture does not start in
ThorImage, refer to triggertest.m for troubleshooting

Versions:
2023.7.3 VL

%}


%set directory to save experiment info
filepath = 'E:\CoconutTree\M1\Data\data_stim testing\stimtesting-NourDser';


%direction of animal ('west' for imaging left tectum, 'east' for imaging right tectum)
%Direction of azimuth drifting bars will change accordingly
facing = 'west';		%%%west = facing inside of microscope stage (screen to right)
facing = 'east';		%%%east = facing outside of microscope stage (screen to left)

driftDir = 'Up';    %AP, PA, Up or Down

initpause = 5; %pause after capture initiation and before stim presentation
inductionRepeats = 10;
inductionFreq = 0.3; %Hz
inductionISI = 0;   %seconds

barsize = 25;   %pixels
bartype = 'off';        %%% on or off

DevName = 'Dev1';   %device name for NI USB-6009 on your computer

xlim = [158 646];   %(old screen)
ylim = [185 479];



%% ------end of setting vars----------

driftFreq = inductionFreq;
repeats = inductionRepeats;
stimtimes = zeros(repeats,3); %Timing data: stim ID + start time + end time
%Stim IDs: 1=AP, 2=PA, 3=Up, 4=Down
stimInterval = inductionISI;

exptime = initpause + repeats * ((1/driftFreq) + stimInterval);

if strcmp(driftDir,'AP')
    stimID = 1;
else if strcmp(driftDir,'PA')
        stimID = 2;
    else if strcmp(driftDir,'Up')
            stimID = 3;
        else if strcmp(driftDir,'Down')
                stimID = 4;
            else
                message=sprintf('Invalid input for driftDir');
                disp(message);
                return
            end
        end
    end
end


%% experiment initialization
%Screen parameters--------------
activeX_c = xlim(2)-xlim(1);
activeY_c = ylim(2)-ylim(1);
xCenter_c = xlim(1)+(xlim(2)-xlim(1))/2;
yCenter_c = ylim(1)+(ylim(2)-ylim(1))/2;

currentdir = pwd;
addpath(genpath(currentdir));

getc_start = clock;
timestamp_start = timestamp(getc_start,'ymdt');
timestamp_stime = timestamp(getc_start,'time');

logtxt = fopen([filepath '\StimLog_' timestamp_start '.txt'],'wt');
message=sprintf(['Induction recording: moving bars ' driftDir]);
disp(message);
fprintf(logtxt,[message '\n']);
message=sprintf(['Facing = ' facing]);
disp(message);
fprintf(logtxt,[message '\n']);
message=sprintf(['Induction Freq= ' num2str(inductionFreq)]);
disp(message);
fprintf(logtxt,[message '\n']);
message=sprintf(['Induction ISI = ' num2str(inductionISI)]);
disp(message);
fprintf(logtxt,[message '\n']);

%PTB startup
Screen('Preference', 'Verbosity', 0);
Screen('Preference', 'SuppressAllWarnings', 0);
Screen('Preference','VisualDebugLevel',0);  %this line disables PTB welcome screen - instead shows black screen
Screen('Preference','SkipSyncTests',1);
sca;
close all;

PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);	%Draw to external screen
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
bgcolor = white;

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, bgcolor);
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
ifi=Screen('GetFlipInterval',window);
vbl = Screen('Flip', window);
waitframes = 1;
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);


message = sprintf([timestamp_stime ': Please set capture time to ' secs2hms(exptime)]);
disp(message);
message = sprintf(['-Press any key to start experiment-']);
disp(message);

while ~KbCheck
end

%% stimulus presentation

%Set up National Instrument USB-6009 setup, trigger @ port ao1----------------
try
    s = daq.createSession('ni');
    addAnalogOutputChannel(s,DevName,'ao1','Voltage');
    Triggered = 1;
catch
    Triggered = 0;
end

%Send trigger to start experiment----------------
if(Triggered)
    outputSingleScan(s,5);
end
start = tic;
if(Triggered)
    outputSingleScan(s,0);
end

StartT = GetSecs;
getc=clock;
timestamp_now = timestamp(getc,'time');
message=sprintf([timestamp_now ': Capture initiated']);
disp(message);


%initial pause: display blank screen
Screen('FillRect', window, bgcolor);
vbl = Screen('Flip', window, vbl + 0.5 * ifi);
pause(initpause);
    


for i = 1:repeats
    
    stimIndex = i;
    toctime = toc(start);
    message=sprintf(['[' num2str(toctime) ']: ' driftDir ' bar']);
    disp(message);
    fprintf(logtxt,[message '\n']);
    stimtimes(stimIndex,1)=stimID;
    stimtimes(stimIndex,2)=toctime;
    
    drift_stimbody;
    
    toctime = toc(start);
    message=sprintf(['[' num2str(toctime) ']: End cycle']);
    disp(message);
    fprintf(logtxt,[message '\n']);
    stimtimes(stimIndex,3)=toctime;
    pause(stimInterval);
   
    
end


%Return screen to background color
Screen('FillRect', window, bgcolor);
vbl = Screen('Flip', window, vbl + 0.5 * ifi);

message = sprintf(['-End of stimulus presentation-']);
disp(message);
fprintf(logtxt,[message '\n']);
sca;

%% post experiment: save data
endtime = toc(start);

datmat = [filepath '\StimulusData_' timestamp_start '.mat'];
save(datmat,'stimtimes','facing','driftDir','inductionRepeats','inductionFreq','inductionISI','barsize','bartype');

getc=clock;
timestamp_now = timestamp(getc,'time');
message=sprintf([timestamp_now ': Experiment done']);
disp(message);
fprintf(logtxt,[message '\n']);
message=sprintf(['Elapsed time is ' secs2hms(endtime)]);
disp(message);
fprintf(logtxt,[message '\n']);
message=sprintf('%s',['Data saved to ' datmat]);
disp(message);

fclose(logtxt);
