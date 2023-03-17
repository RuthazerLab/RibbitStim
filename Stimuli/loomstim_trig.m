%{
loomstim_trig
Expanding dark circle (experiment trigger ver.)
Hyperbolic expansion with fixed R/V (constant approach velocity)

Use:
- Set parameters for stim appearance (expansion profile, whether or not to add fade & blanks)
- Run script and wait for "press any key" prompt to display on command line
- Start capture on ThorImage (set trigger mode to "trigger first")
- Press any key to start experiment

Use loomstim.m for testing stim appearance


Notes
*If the program shows "Capture initiated" but capture does not start in
ThorImage, refer to triggertest.m for troubleshooting

%}


clearvars;

%set directory to save experiment info
filepath = 'E:\CoconutTree\M1\Data\data_Cynthia\Cynthia random dots';

DevName = 'Dev1';   %device name for NI USB-6009 on your computer

expandRV = 0.1; %R/V, seconds (larger R/V = slower expansion)
collisionTime = 3; %time to collision, seconds (for larger R/V, if initial circle seems too large, try extending time to collision)
stimDur = 4;   %total loom presentation duration (if circle fills screen before end of stimDur, screen will stay black until end of stimDur)
fadeDur = 2;   %seconds. set to nonzero value to have screen fade gradually from black back to white at end of stim presentation
nstims = 5;      %number of times to present stimulus within one set
repeats = 2;    %number of times to repeat each set
isi = 5;       %isi (seconds)
addblank = 1;   %0 or 1. If set to 1, a blank presentation will be added to the end of each repeat


%set screen limits
xlim = 100;
ylim = 100;
xwidth = 200;
ywidth = 200;

fullscreen = 1;     %when set to 1, stimulus dots run in full screen range (overrides screen limit values)


%------end of setting vars----------


%% experiment initialization
currentdir = pwd;
addpath(genpath(currentdir));

getc_start = clock;
timestamp_start = timestamp(getc_start,'ymdt');
timestamp_stime = timestamp(getc_start,'time');

logtxt = fopen([filepath '\StimLog_' timestamp_start '.txt'],'wt');

message=sprintf(['Expansion R/V = ' num2str(expandRV) ' secs']);
disp(message);
fprintf(logtxt,[message '\n']);
message=sprintf(['Time to collision = ' num2str(collisionTime) ' secs']);
disp(message);
fprintf(logtxt,[message '\n']);

message=sprintf(['Stimulus duration = ' num2str(stimDur) ' secs']);
disp(message);
fprintf(logtxt,[message '\n']);
message=sprintf(['Fade duration = ' num2str(fadeDur) ' secs']);
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
dotcolor = black;

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, bgcolor);
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
ifi=Screen('GetFlipInterval',window);
vbl = Screen('Flip', window);
waitframes = 1;
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

if fullscreen
    xlim = 0;
    ylim = 0;
    xwidth = screenXpixels;
    ywidth = screenYpixels;
end

screenmaxpixels = sqrt(xwidth^2+ywidth^2);

%initiate experiment
exptime = repeats*(stimDur+fadeDur+isi)*(nstims+addblank)+isi;

message = sprintf([timestamp_stime ': Please set capture time to ' secs2hms(exptime)]);
disp(message);
message = sprintf(['-Press any key to start experiment-']);
disp(message);


while ~KbCheck
end


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


%% stimulus loop

stimtimes = zeros(nstims*repeats,2); %Timing data: start time + end time
blanktimes = zeros(repeats,2); %Blank times (start & end)

fullscreenRect = [0 0 screenXpixels screenYpixels];
centeredRect = CenterRectOnPointd(fullscreenRect, xCenter, yCenter);
Screen('FillRect', window, white ,centeredRect);
vbl = Screen('Flip', window, vbl + 0.5 * ifi);

pause(isi);


%initiate shapes
ovalcenter_x = xlim+xwidth/2;
ovalcenter_y = ylim+ywidth/2;

baseRect = [xlim ylim xlim+xwidth ylim+ywidth];
centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);


for currepeat = 1:repeats
    for currstim = 1:nstims
        
        dataindex = currstim + nstims*(currepeat-1);       
        
        toctime = toc(start);
        stimtimes(dataindex,1) = toctime;
        
        message=sprintf(['[' num2str(toctime) ']: Loom']);
        disp(message);
        fprintf(logtxt,[message '\n']);
        
        ovalRad = 0;
        
        t0 = tic;
        elapsedTime = toc(t0);
        
        while elapsedTime <= stimDur
            
            %display circle
            
            ovalRect = [0 0 ovalRad ovalRad];
            centeredOval = CenterRectOnPointd(ovalRect, ovalcenter_x, ovalcenter_y);
            Screen('FillRect', window, bgcolor, centeredRect);
            Screen('FillOval', window, dotcolor,centeredOval);
            Screen('DrawingFinished', window);
            vbl=Screen('Flip', window, vbl + (waitframes-0.5)*ifi);
            
            %update circle radius
            
            elapsedTime = toc(t0);
            
            
            if elapsedTime >= collisionTime
                ovalRad = screenmaxpixels;
            else
                ovalRad = expandRV * screenmaxpixels / (collisionTime - elapsedTime);
            end

            
            %if the updated oval size exceeds the designated display area, show a
            %black screen
            if ovalRad>screenmaxpixels
                ovalRad = screenmaxpixels;
            end
            
        end
        
        toctime = toc(start);
        stimtimes(dataindex,2) = toctime;
                
        if fadeDur>0
            message=sprintf(['[' num2str(toctime) ']: Fade']);
            disp(message);
            fprintf(logtxt,[message '\n']);
            
            t1 = tic;
            elapsedTime2 = toc(t1);
            while elapsedTime2 <= fadeDur
                
                rectcolor = (elapsedTime2/fadeDur)*(white-black);
                Screen('FillRect', window, rectcolor, centeredRect);
                Screen('DrawingFinished', window);
                vbl=Screen('Flip', window, vbl + (waitframes-0.5)*ifi);
                elapsedTime2 = toc(t1);
                
            end
        end
        
        toctime = toc(start);
        message=sprintf(['[' num2str(toctime) ']: End presentation']);
        disp(message);
        fprintf(logtxt,[message '\n']);       
        
        %isi: display white screen
        Screen('FillRect', window, white ,centeredRect);
        vbl = Screen('Flip', window, vbl + 0.5 * ifi);
        
        pause(isi);
        
    end
    
        
    %add blank presentation
    if addblank
        toctime = toc(start);
        blanktimes(currepeat,1) = toctime;        
        message=sprintf(['[' num2str(toctime) ']: Blank']);
        disp(message);
        fprintf(logtxt,[message '\n']);
        
        pause(stimDur + fadeDur);
        
        toctime = toc(start);
        blanktimes(currepeat,2) = toctime;
        message=sprintf(['[' num2str(toctime) ']: Blank end']);
        disp(message);
        fprintf(logtxt,[message '\n']);   
        
        pause(isi);
        
    end
end


sca


%% post experiment: save data
endtime = toc(start);

datmat = [filepath '\StimulusData_' timestamp_start '.mat'];
save(datmat,'stimtimes','expandRV','collisionTime','stimDur','fadeDur','nstims','repeats','isi','blanktimes');

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
