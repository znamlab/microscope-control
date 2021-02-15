classdef monitor_blanker < handle
% monitor_blanker
% 
% Deliver monitor and PMT gating signals triggered by the X-mirror
% 
% Inspired by si_tools.monitor_blanker by Rob Campbell

    properties (Hidden, SetAccess=protected)
        daqId = 0
        siHandle = 'hSI'
        hSI
        hTask
    end
    
    properties
        monitor_port = 0
        monitor_line = 0
        pmt_port = 0
        pmt_line = 1
        
        % in microseconds
        mon_timings = [ 0 45 17 45 1 ];
        pmt_timings = [ 3 40 24 40 1 ];
        
        mon_waveform
        pmt_waveform
    end
    
    methods
        function obj = monitor_blanker()
            % get handle to SI object
            obj.hSI = evalin('base',obj.siHandle);
            % get the handle for the vDAQ device
            hResourceStore = dabs.resources.ResourceStore();
            hvDAQ = hResourceStore.filterByName(sprintf('vDAQ%d', obj.daqId));
            hFpga = hvDAQ.hDevice;
            % create task
            obj.hTask = dabs.vidrio.ddi.DoTask(hFpga,'Blanking waveform');
            mon_ch = sprintf('D%d.%d', obj.monitor_port, obj.monitor_line);
            pmt_ch = sprintf('D%d.%d', obj.pmt_port, obj.pmt_line);
            obj.hTask.addChannel(mon_ch);
            obj.hTask.addChannel(pmt_ch);
            obj.hTask.sampleRate = obj.hTask.maxSampleRate;
            % setup trigger            
            obj.hTask.cfgDigEdgeStartTrig(...
                obj.hSI.hScan2D.trigBeamClkOutInternalTerm);
            obj.hTask.allowRetrigger = true;
            obj.hTask.sampleMode = 'finite';
            obj.make_waveform()
            obj.start()
        end
        
        function make_waveform(obj)
            % generate waveforms when parameters update
            
            % convert from microseconds to samples
            mon_timings_samples = ...
                round(obj.mon_timings * 1e-6 * obj.hTask.sampleRate);
            pmt_timings_samples = ...
                round(obj.pmt_timings * 1e-6 * obj.hTask.sampleRate);

            obj.mon_waveform = [ ...
                zeros(mon_timings_samples(1), 1); 
                ones(mon_timings_samples(2), 1); 
                zeros(mon_timings_samples(3), 1); 
                ones(mon_timings_samples(4), 1);
                zeros(mon_timings_samples(5), 1)  ];
            
            obj.pmt_waveform = [ ...
                ones(pmt_timings_samples(1), 1); 
                zeros(pmt_timings_samples(2), 1); 
                ones(pmt_timings_samples(3), 1); 
                zeros(pmt_timings_samples(4), 1);
                ones(pmt_timings_samples(5), 1) ];
        end
        
        function set.mon_timings(obj, value)
            % update waveform and restart task
            if numel(value)==5 && all(value>=0)
                obj.mon_timings = value;
                obj.make_waveform()
                obj.stop()
                obj.start()
            else
                fprintf('Waveform timings must be a positive 4 element vector.\n')
            end
        end
        
        function set.pmt_timings(obj, value)
            % update waveform and restart task
            if numel(value)==5 && all(value>=0)
                obj.pmt_timings = value;
                obj.make_waveform()
                obj.stop()
                obj.start()
            else
                fprintf('Waveform timings must be a positive 5 element vector.\n')
            end            
        end
        
        function start(obj)
            try
                obj.hTask.writeOutputBuffer(...
                    [ obj.mon_waveform, obj.pmt_waveform ]);
                obj.hTask.samplesPerTrigger = size(obj.mon_waveform, 1);
                obj.hTask.start();
            catch ME
                error('Failed to start task')
            end
        end
        
        function stop(obj)
            try
                obj.hTask.stop();
            catch ME
                error('Failed to stop task')
            end
        end
        
        function delete(obj)
            % stop task and clean up
            fprintf('Monitor blanker is shutting down...')
            obj.stop()
            obj.hTask.delete();
            fprintf('done\n')
        end
    end
end