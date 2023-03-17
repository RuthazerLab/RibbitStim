%{
triggertest.m

Sets up external trigger on National Instrument USB-6009 on port ao1 and
sends a single 5V trigger
(when you set ThorImage to capture on Trigger First mode, running this
code snippet will initiate capture)

The device name for the USB-6009 on your machine may vary.
If you encounter a "device ID not recognized" error, check the error
message on the command line to find the name of a device that is supported
and edit the second parameter in "addAnalogOutputChannel" to the name of that device
(e.g. 'Dev1', 'Trigger', 'Dev0')

%}

s = daq.createSession('ni');
addAnalogOutputChannel(s,'Dev1','ao1','Voltage');

outputSingleScan(s,5);
outputSingleScan(s,0);