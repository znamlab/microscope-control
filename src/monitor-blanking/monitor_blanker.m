daqId = 0;

deviceInfo = dabs.vidrio.rdi.Device.getDeviceInfo(daqId);

hResourceStore = dabs.resources.ResourceStore();
hvDAQ = hResourceStore.filterByName(sprintf('vDAQ%d',daqId));
hFpga = hvDAQ.hDevice;

hTask = dabs.vidrio.ddi.DoTask(hFpga,'Blanking waveform');

%%
portno = 0;
lineno = 0;
ch = sprintf('D%d.%d', portno, lineno);
hTask.addChannel(ch);

%%
hTask.stop
waveform = [ zeros(200, 1); ones(1060, 1); zeros(200, 1); ones(1060, 1)  ];
hTask.sampleRate = hTask.maxSampleRate;

term = hSI.hScan2D.trigReferenceClkOutInternalTerm;
rate = hSI.hScan2D.trigReferenceClkOutInternalRate;

hTask.cfgDigEdgeStartTrig(hSI.hScan2D.trigBeamClkOutInternalTerm);
hTask.allowRetrigger = true;

%hTask.cfgSampClkTiming(hTask.sampleRate, size(waveform, 1));
hTask.writeOutputBuffer(waveform);
hTask.start;