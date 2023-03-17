%{
ovals_coherent
Random moving dots with adjustable coherence

Use:
- run to display stimulus
- change stim appearance by changing parameters (dot speed, number of dots, dot width, coherence)
- to end stim display, press ESC 

Notes
*The program opens a PTB display window, which will default open to a connected external screen
The PTB window will automatically close at the end of the program and return control to Matlab.
If no external screen is connected, the stim will display on your main screen.
If the program is terminated unusually, you may get stuck on an open PTB display window 
and unable to return to Matlab.
if this happens, press ALT+TAB or close PTB display window from taskbar (right click Matlab icon to display all open tabs)

*Depending on your GPU specs, there may be an upper limit to the number of dots 
you can render before it gets laggy


versions
2023.2.15 VL
coherent dots are currently set to always move from left to right. 
change commented code to make them move in the same randomized direction instead

2023.3.8 VL
add parameter to set direction of coherent dots

%}

clearvars;

dot_speed   = 5;    % dot speed (pix/sec)
ndots       = 20;   % number of dots
dot_w       = 20;   % width of dot (pix)
coherence = 50;    %coherence (0 to 100)
coherentDir = 100;    %direction of coherent motion (0 to 2)
%If set to 100, coherent dots will move in a randomly selected direction
%Left to right = 0
%Down = 0.5
%Right to left = 1
%Up = 1.5

%set screen limits
xlim = 100;
ylim = 100;
xwidth = 200;
ywidth = 200;

fullscreen = 1;     %when set to 1, stimulus dots run in full screen range (overrides screen limit values)

%------end of setting vars----------
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

escapeKey = KbName('ESCAPE');

%number of dots
nCoherent = round(coherence/100 * ndots);
nRand = ndots - nCoherent;

%randomly generate [ndots] dot coordinates
xymatrix_init = rand(2,ndots);
xymatrix_oval = zeros(4,ndots);
xymatrix_oval(1,:) = xymatrix_init(1,:).*xwidth-dot_w/2;
xymatrix_oval(2,:) = xymatrix_init(2,:).*ywidth-dot_w/2;
xymatrix_oval(3,:) = xymatrix_init(1,:).*xwidth+dot_w/2;
xymatrix_oval(4,:) = xymatrix_init(2,:).*ywidth+dot_w/2;

exitDemo = false;
dir_update = rand(1,ndots)*2*pi;

changeDots = [zeros(1,nRand), ones(1,nCoherent)];        % define vector for indexing into dot coords
changeDots = logical(changeDots(randperm(ndots)'));     % Randomise which dots are defined as random on this frame
ind_coherent = find(changeDots);    %list indices of coherent dots

%set direction for coherent dots to move
if coherentDir == 100
    dir_coherent = normrnd(0,2)*pi;
else
    dir_coherent = coherentDir*pi;
end


while exitDemo == false
	[keyIsDown,secs, keyCode] = KbCheck;
    if keyCode(escapeKey)
        exitDemo = true;
    end	    
    
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
    
    %dir_coherent = dir_coherent + normrnd(0,0.02)*2*pi;
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

sca

