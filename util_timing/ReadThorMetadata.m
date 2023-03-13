%{
ReadThorMetadata.m
2023.3.9 VL
Read metadata from ThorImage experiment.xml

%}


function [Steps,Flyback,Frames,ftimes,CaptureRatePerSlice] = ReadThorMetadata(path)

MetaData = xml2struct(fullfile(path,'Experiment.xml'));
Steps = str2num(MetaData.ThorImageExperiment.ZStage.Attributes.steps);
Flyback = str2num(MetaData.ThorImageExperiment.Streaming.Attributes.flybackFrames);
Frames= str2num(MetaData.ThorImageExperiment.Streaming.Attributes.frames);
if(Steps == 1)
    Flyback = 0;
end

nslice = Steps + Flyback;

[ftimes,triggertime] = GenerateFrameTime(path);
ftimes = ftimes - triggertime;
tottime = ftimes(end);
CaptureRateTot = Frames/tottime;
CaptureRatePerSlice = CaptureRateTot / nslice;

