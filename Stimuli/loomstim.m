%{
loomstim
Expanding dark circle

Use:
- run to display one presentation of the stimulus (expansion + fade)
- change stim appearance by changing parameters (expansion speed, linear/log expansion)

Notes
*The program opens a PTB display window, which will default open to a connected external screen
The PTB window will automatically close at the end of the program and return control to Matlab.
If no external screen is connected, the stim will display on your main screen.
If the program is terminated unusually, you may get stuck on an open PTB display window 
and unable to return to Matlab.
if this happens, press ALT+TAB or close PTB display window from taskbar (right click Matlab icon to display all open tabs)

%}

clearvars;

%uncomment the following section for linear expansion (constant radial velocity, decelerating approach)
% expandType = 'linear';
% expandSpeed = 20;   %pixels/sec

%uncomment the following section for hyperbolic expansion (constant approach velocity)
expandType = 'hyperb';
expandRV = 0.5; %R/V, seconds (larger R/V = slower expansion)
collisionTime = 5; %time to collision, seconds (for larger R/V, if initial circle seems too large, try extending time to collision)

stimDur = 6;   %total loom presentation duration (if circle fills screen before end of stimDur, screen will stay black until end of stimDur)
fadeDur = 2;   %seconds. set to nonzero value to have screen fade gradually from black back to white at end of stim presentation


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

screenmaxpixels = sqrt(xwidth^2+ywidth^2);

exitDemo = false;


%initiate circle
ovalcenter_x = xlim+xwidth/2;
ovalcenter_y = ylim+ywidth/2;
ovalRad = 0;

baseRect = [xlim ylim xlim+xwidth ylim+ywidth];
centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);

%display and update circle

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
    
    if strcmp(expandType,'linear')
        ovalRad = elapsedTime * expandSpeed;
    elseif strcmp(expandType,'hyperb')
        if elapsedTime >= collisionTime
            ovalRad = screenmaxpixels;
        else
            ovalRad = expandRV * screenmaxpixels / (collisionTime - elapsedTime);
        end
    else
        disp('Error: Expansion type not recognized, please check parameters!');
        exitDemo = true;
    end
    
    %if the updated oval size exceeds the designated display area, show a
    %black screen
    if ovalRad>screenmaxpixels
        ovalRad = screenmaxpixels;
    end
    
end

t1 = tic;
elapsedTime2 = toc(t1);

if fadeDur>0
    while elapsedTime2 <= fadeDur
        
        rectcolor = (elapsedTime2/fadeDur)*(white-black);
        Screen('FillRect', window, rectcolor, centeredRect);
        Screen('DrawingFinished', window);
        vbl=Screen('Flip', window, vbl + (waitframes-0.5)*ifi);
        elapsedTime2 = toc(t1);
        
    end
end

exitDemo = true;

sca