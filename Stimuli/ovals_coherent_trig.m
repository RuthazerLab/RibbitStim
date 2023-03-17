%{
ovals_coherent_trig
Random moving dots with adjustable coherence (experiment trigger ver.)

Use:
- Set parameters for stim appearance (dot speed, number of dots, dot width, coherence)
and experiment (stim time, isi, repeats)
- Run script and wait for "press any key" prompt to display on command line
- Start capture on ThorImage (set trigger mode to "trigger first")
- Press any key to start experiment

Use ovals_coherent.m for testing stim appearance


Notes
*The program opens a PTB display window, which will default open to a connected external screen
The PTB window will automatically close at the end of the program and return control to Matlab.
If no external screen is connected, the stim will display on your main screen.
If the program is terminated unusually, you may get stuck on an open PTB display window
and unable to return to Matlab.
if this happens, press ALT+TAB or close PTB display window from taskbar (right click Matlab icon to display all open tabs)

*Depending on your GPU specs, there may be an upper limit to the number of dots
you can render before it gets laggy

*If the program shows "Capture initiated" but capture does not start in
ThorImage, refer to triggertest.m for troubleshooting


versions
2023.2.15 VL
coherent dots are currently set to always move from left to right.
change commented code to make them move in the same randomized direction instead

2023.3.6 VL
-added option to add blank presentation at end of each set (presents a white screen)
-changed data container to save start time as well as end time for each presentation (including blanks)
-fixed bug where timing data is only saved for one repeat (sorry for dumb)

2023.3.8 VL
-added option to set the direction of coherent motion for each presentation
-add device name for USB6009 as a user set parameter:

The device name for the USB-6009 on your machine may vary.
If you encounter a "device ID not recognized" error, check the error
message on the command line to find the name of a device that is supported
and set "DevName" to the name of that device (e.g. 'Dev1', 'Trigger', 'Dev0')

%}

clearvars;

%set directory to save experiment info
filepath = 'E:\CoconutTree\M1\Data\data_Cynthia\Cynthia random dots';

DevName = 'Dev1';   %device name for NI USB-6009 on your computer

dot_speed   = 10;    % dot speed (pix/sec)
ndots       = 20;   % number of dots
dot_w       = 20;   % width of dot (pix)

coherenceVect = [50 0 100 100]; %coherence values to run in each set (0 to 100)
coherentDirVect = [0 0 0 1.5]; %direction of coherent motion (0 to 2)
%Left to right = 0
%Down = 0.5
%Right to left = 1
%Up = 1.5
%If set to 100, coherent dots will move in a randomly selected direction

stimDur = 3;   %stimulus display time (secs)
repeats = 2;    %number of times to repeat each set
isi = 5;       %isi (seconds)

addblank = 1;   %if set to 1, a blank presentation will be added to the end of each repeat

%set screen limits
xlim = 158;
ylim = 185;
xwidth = 488;
ywidth = 294;

fullscreen = 0;     %when set to 1, stimulus dots run in full screen range (overrides screen limit values)


%------end of setting vars----------


%% experiment initialization
currentdir = pwd;
addpath(genpath(currentdir));

getc_start = clock;
timestamp_start = timestamp(getc_start,'ymdt');
timestamp_stime = timestamp(getc_start,'time');

logtxt = fopen([filepath '\StimLog_' timestamp_start '.txt'],'wt');
message=sprintf(['Dot number = ' int2str(ndots)]);
disp(message);
fprintf(logtxt,[message '\n']);
message=sprintf(['Dot speed = ' int2str(dot_speed)]);
disp(message);
fprintf(logtxt,[message '\n']);
message=sprintf(['Dot size = ' int2str(dot_w)]);
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

nstims = length(coherenceVect);
exptime = repeats*(stimDur+isi)*(nstims+addblank)+isi;

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

for currepeat = 1:repeats
    for currstim = 1:nstims
        
        dataindex = currstim + nstims*(currepeat-1);       
        
        toctime = toc(start);
        stimtimes(dataindex,1) = toctime;       
        
        %set direction for coherent dots to move
        coherence = coherenceVect(currstim);
        coherentDir = coherentDirVect(currstim);
        if coherentDir == 100
            dir_coherent = normrnd(0,2)*pi;
        else
            dir_coherent = coherentDir*pi;
        end
        
        message=sprintf(['[' num2str(toctime) ']: Coherence ' int2str(coherence) ', Direction ' num2str(coherentDir)]);
        disp(message);
        fprintf(logtxt,[message '\n']);
        
        %assign dots
        nCoherent = round(coherence/100 * ndots);
        nRand = ndots - nCoherent;
        
        %randomly generate [ndots] dot coordinates
        xymatrix_init = rand(2,ndots);
        xymatrix_oval = zeros(4,ndots);
        xymatrix_oval(1,:) = xymatrix_init(1,:).*xwidth-dot_w/2;
        xymatrix_oval(2,:) = xymatrix_init(2,:).*ywidth-dot_w/2;
        xymatrix_oval(3,:) = xymatrix_init(1,:).*xwidth+dot_w/2;
        xymatrix_oval(4,:) = xymatrix_init(2,:).*ywidth+dot_w/2;
        
        dir_update = rand(1,ndots)*2*pi;
        
        changeDots = [zeros(1,nRand), ones(1,nCoherent)];        % define vector for indexing into dot coords
        changeDots = logical(changeDots(randperm(ndots)'));     % Randomise which dots are defined as random on this frame
        ind_coherent = find(changeDots);    %list indices of coherent dots
        
        t0 = clock;
        while etime(clock, t0) < stimDur
            
            %display dots
            baseRect = [xlim ylim xlim+xwidth ylim+ywidth];
            centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
            Screen('FillRect', window, bgcolor, centeredRect);
            Screen('FillOval', window, dotcolor,xymatrix_oval);
            Screen('DrawingFinished', window);
            
            %find dots that have moved out of range
            d_yout = find(xymatrix_oval(4,:)>ylim+ywidth+dot_w);
            d_yout2 = find(xymatrix_oval(2,:)<ylim-dot_w);
            d_xout = find(xymatrix_oval(3,:)>xlim+xwidth+dot_w);
            d_xout2 = find(xymatrix_oval(1,:)<xlim-dot_w);
            
            %replot dots that are out of range
            xy_update4 = (xymatrix_oval(4,:));
            xy_update3 = (xymatrix_oval(3,:));
            xy_update2 = (xymatrix_oval(2,:));
            xy_update1 = (xymatrix_oval(1,:));
            
            xy_update4(d_yout) = xy_update4(d_yout) - (ywidth+dot_w);
            xy_update2(d_yout) = xy_update2(d_yout) - (ywidth+dot_w);
            
            xy_update4(d_yout2) = xy_update4(d_yout2) + (ywidth+dot_w);
            xy_update2(d_yout2) = xy_update2(d_yout2) + (ywidth+dot_w);
            
            xy_update3(d_xout) = xy_update3(d_xout) - (xwidth+dot_w);
            xy_update1(d_xout) = xy_update1(d_xout) - (xwidth+dot_w);
            
            xy_update3(d_xout2) = xy_update3(d_xout2) + (xwidth+dot_w);
            xy_update1(d_xout2) = xy_update1(d_xout2) + (xwidth+dot_w);
            
            
            xymatrix_oval(4,:) = xy_update4;
            xymatrix_oval(3,:) = xy_update3;
            xymatrix_oval(2,:) = xy_update2;
            xymatrix_oval(1,:) = xy_update1;
            
            %update dot coords
            %for random dots - move in random direction for dot_speed
            %for coherent dots - set motion direction to same value
            
            dir_update = dir_update + normrnd(0,0.02,[1,ndots])*2*pi;
            dir_update(ind_coherent) = dir_coherent;
            dir_update = mod(dir_update,2*pi);
            
            x_update = cos(dir_update);
            y_update = sin(dir_update);
            xymatrix_oval(2,:) = xymatrix_oval(2,:)+dot_speed*y_update;
            xymatrix_oval(4,:) = xymatrix_oval(4,:)+dot_speed*y_update;
            xymatrix_oval(1,:) = xymatrix_oval(1,:)+dot_speed*x_update;
            xymatrix_oval(3,:) = xymatrix_oval(3,:)+dot_speed*x_update;
            
            vbl=Screen('Flip', window, vbl + (waitframes-0.5)*ifi);
        end
        
        toctime = toc(start);
        stimtimes(dataindex,2) = toctime;
        message=sprintf(['[' num2str(toctime) ']: End presentation']);
        disp(message);
        fprintf(logtxt,[message '\n']);       
        
        %isi: display white screen
        centeredRect = CenterRectOnPointd(fullscreenRect, xCenter, yCenter);
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
        
        pause(stimDur);
        
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
save(datmat,'stimtimes','dot_speed','ndots','dot_w','stimDur','repeats','isi','coherenceVect','coherentDirVect','blanktimes');

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

