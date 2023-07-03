%{
drift_stimbody.m

Moving bar stimulus (support script)

Versions:
2023.7.3 VL

%}


%{
Script for displaying drifting bar using PTB
Shows black vertical bars on white background
Bar moves into screen, across screen and off screen, then n sec blank, then bar starts on screen again
Params: moving direction, frequency, duration of blank
Data saved: 2 column vector with cycle onset and end times

*1 cm diameter ~ 72 pixel rect
Viewing distance is 2.2cm
Visual angle calculator: http://www.oocities.org/robertellis600/va.html
50 pixels = 18 degrees

%}

%set these parameters in calling script
driftDir = driftDir;		%direction
freq = driftFreq;			%frequency
barsize = barsize;

if strcmp(driftDir,'AP')||strcmp(driftDir,'PA')
    driftOri = 'vertical';
elseif strcmp(driftDir,'Up')||strcmp(driftDir,'Down')
    driftOri = 'horizontal';
end

if strcmp(bartype,'on')
    bgcolor = black;
    rectColor = white;
else
    bgcolor = white;
    rectColor = black;
end
cycle = 1/freq;

%Flip horizontal stim based on animal orientation
if strcmp(facing,'west')
    if strcmp(driftDir,'AP')
        moveDir = 1;
    else
        moveDir = -1;
    end
else
    if strcmp(driftDir,'AP')
        moveDir = -1;
    else
        moveDir = 1;
    end
end

Screen('FillRect', window, bgcolor);
vbl = Screen('Flip', window, vbl + 0.5 * ifi);

time = 0;
go = 1;

while go
    loopstart = toc(start);
    if strcmp(driftOri,'vertical')
        baseRect = [0 0 barsize screenYpixels];
        if moveDir == 1
            xPos = (xlim(1)-barsize/2) + (time/cycle)*(xlim(2)-xlim(1)+barsize);
        else
            xPos = (xlim(2)+barsize/2) - (time/cycle)*(xlim(2)-xlim(1)+barsize);
        end
        centeredRect = CenterRectOnPointd(baseRect, xPos, yCenter);
    elseif strcmp(driftOri,'horizontal')
        baseRect = [0 0 screenXpixels barsize];
        if strcmp(driftDir,'Down')
            yPos = (ylim(1)-barsize/2) + (time/cycle)*(ylim(2)-ylim(1)+barsize);
        else
            yPos = (ylim(2)+barsize/2) - (time/cycle)*(ylim(2)-ylim(1)+barsize);
        end
        centeredRect = CenterRectOnPointd(baseRect, xCenter, yPos);
    end
    
    
    Screen('FillRect', window, rectColor, centeredRect);
    vbl = Screen('Flip', window, vbl + 0.5 * ifi);
    toctime = toc(start);
    time = time+ (toctime - loopstart);
    if time > cycle
        go = 0;     %end stim loop
    end
    
end



Screen('FillRect', window, bgcolor);
vbl = Screen('Flip', window, vbl + 0.5 * ifi);
