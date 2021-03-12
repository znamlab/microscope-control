%%  Simple example script to run ai_recorder

addpath('E:\code\ScanImageTools\code')
AI=sitools.ai_recorder('aiRecSettingPZ2P.mat'); % check displayed properies

%% if you want to change the setting
if false
    AI = sitools.ai_recorder(false);
    AI.devType = 'vDAQ';  % set the DAQ type, either DAQmx or vDAQ
    AI.devName = 'vDAQ0';
    AI.chanNames={'lick_sensor'};
    AI.AI_channels = 5; 
    AI.voltageRange = 10;
    AI.sampleRate = 4000;
    AI.yMin = 0;
    AI.yMax = 0.001;
    AI.saveCurrentSettings('aiRecSettingPZ2P.mat');
    delete(AI)
end

