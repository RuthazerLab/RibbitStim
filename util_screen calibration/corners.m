clear all;

rgbcolor = [0 0 50];    %blue
%rgbcolor = [50 0 0];    %red

rgbcolor = rgbcolor./255;

rgbcolor = [1 1 1];

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
white = white/2;
%bgcolor = white;
bgcolor = black;

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, bgcolor);
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
ifi=Screen('GetFlipInterval',window);
topPriorityLevel = MaxPriority(window);
vbl = Screen('Flip', window);
waitframes = 1;
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

escapeKey = KbName('ESCAPE');

rectColor = black;
barsize = 50;
baseRect = [0 0 screenXpixels barsize];


% xlim = [158 656];   %old screen
% ylim = [180 480];

xlim = [18 480];   %new screen
ylim = [505 800];


xCenter_c = xlim(1)+(xlim(2)-xlim(1))/2;
yCenter_c = ylim(1)+(ylim(2)-ylim(1))/2;

c = KbName('c');

exitDemo = false;
prevkeystate = 0;

disp('ready');

while exitDemo == false
    
	[keyIsDown,secs,keyCode] = KbCheck;
    
    if keyIsDown
        if prevkeystate == 0            
            if keyCode(escapeKey)
                exitDemo = true;
            elseif keyCode(c)
                if isequal(bgcolor,rgbcolor)
                    bgcolor = black;
                else
                    bgcolor = rgbcolor;
                end
            end
        end
    end
    
    prevkeystate = keyIsDown;
	
    Screen('FillRect', window, bgcolor);
	baseRect = [0 0 18 18];
    maxDiameter = max(baseRect) * 1.01;
    centeredRect = CenterRectOnPointd(baseRect, xlim(1),ylim(1));
	Screen('FillOval', window, rectColor, centeredRect, maxDiameter);
    centeredRect = CenterRectOnPointd(baseRect, xlim(2),ylim(1));
	Screen('FillOval', window, rectColor, centeredRect, maxDiameter);
    centeredRect = CenterRectOnPointd(baseRect, xlim(1),ylim(2));
	Screen('FillOval', window, rectColor, centeredRect, maxDiameter);
    centeredRect = CenterRectOnPointd(baseRect, xlim(2),ylim(2));
	Screen('FillOval', window, rectColor, centeredRect, maxDiameter);
    longRect = [0 0 screenXpixels 5];
    centeredRect = CenterRectOnPointd(longRect, xCenter_c, ylim(1));
	Screen('FillRect', window, rectColor, centeredRect);
	
	
	vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
	
end

sca