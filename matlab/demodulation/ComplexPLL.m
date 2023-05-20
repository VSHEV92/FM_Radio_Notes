classdef (StrictDefaults) ComplexPLL < matlab.System
    % untitled Add summary here
    %
    % NOTE: When renaming the class name untitled, the file name
    % and constructor name must be updated to use the class name.
    %
    % This template includes most, but not all, possible properties, attributes,
    % and methods that you can implement for a System object in Simulink.

    % Public, tunable properties
    properties
        SampleFrequency;   % sample frequency in herz
        NoiseBandwidth;    % noise bandwidth in herz
        Dampingfactor;     % damping factor
        CentralFrequency;  % central NCO frequency in herz
    end

    % Public, non-tunable properties
    properties(Nontunable)

    end

    properties(DiscreteState)

    end

    % Pre-computed constants
    properties(Access = private)
        NCOPhase;
        LoopFilterAcc;
        Ts; 
        kp;
        ki;
    end

    methods
        % Constructor
        function obj = ComplexPLL(varargin)
            % Support name-value pair arguments when constructing object
             setProperties(obj,nargin,varargin{:})
        end
    end

    methods(Access = protected)
        %% Common functions
        function setupImpl(obj)
            % Perform one-time calculations, such as computing constants
            obj.Ts = 1/obj.SampleFrequency;

            BL_n = obj.NoiseBandwidth * obj.Ts;
            ksi = obj.Dampingfactor;
            kd = 1; 

            obj.kp = 4*ksi*BL_n / (ksi + 0.25/ksi) / kd;
            obj.ki = 4*BL_n^2 / (ksi + 0.25/ksi)^2 / kd;

            obj.NCOPhase = 0;
            obj.LoopFilterAcc = 0;
        end

        function [OutputFrame, FrequencyError] = stepImpl(obj, InputFrame)
            % Implement algorithm. Calculate y as a function of input u and
            % discrete states.

            FrameSize = length(InputFrame);
            
            OutputFrame = complex(zeros(FrameSize,1));
            FrequencyError = zeros(FrameSize,1);
            
            for n = 1:FrameSize
                % mixer
                PhaseError = angle(InputFrame(n) * exp(-1j*obj.NCOPhase));

                % loop filter
                kp_out = obj.kp * PhaseError;
                ki_out = obj.ki * PhaseError + obj.LoopFilterAcc;
                loop_filter_out = kp_out + ki_out;
                
                % update loop filter acc value
                obj.LoopFilterAcc = ki_out;

                % update nco phase
                obj.NCOPhase = obj.NCOPhase + loop_filter_out + 2*pi*obj.CentralFrequency*obj.Ts;
 
                % set outputs
                FrequencyError(n) = loop_filter_out / (2*pi) * obj.SampleFrequency; 
                OutputFrame(n) = exp(1j*obj.NCOPhase);
            end
        end

        function resetImpl(obj)
            % Initialize / reset discrete-state properties
            obj.NCOPhase = 0;
            obj.LoopFilterAcc = 0;
        end

        %% Backup/restore functions
        function s = saveObjectImpl(obj)
            % Set properties in structure s to values in object obj

            % Set public properties and states
            s = saveObjectImpl@matlab.System(obj);

            % Set private and protected properties
            %s.myproperty = obj.myproperty;
        end

        function loadObjectImpl(obj,s,wasLocked)
            % Set properties in object obj to values in structure s

            % Set private and protected properties
            % obj.myproperty = s.myproperty; 

            % Set public properties and states
            loadObjectImpl@matlab.System(obj,s,wasLocked);
        end

        %% Simulink functions
        function ds = getDiscreteStateImpl(obj)
            % Return structure of properties with DiscreteState attribute
            ds = struct([]);
        end

        function flag = isInputSizeMutableImpl(obj,index)
            % Return false if input size cannot change
            % between calls to the System object
            flag = false;
        end

        function [out1, out2] = isOutputFixedSizeImpl(obj)
            out1 = true;
            out2 = true;
        end

        function [out1, out2] = isOutputComplexImpl(obj)
            out1 = true;
            out2 = false;
        end

        function [out1, out2] = getOutputDataTypeImpl(obj)
            out1 = propagatedInputDataType(obj,1);
            out2 = propagatedInputDataType(obj,1);
         end

        function [out1, out2] = getOutputSizeImpl(obj)
            out1 = propagatedInputSize(obj,1);
            out2 = propagatedInputSize(obj,1);
        end

        function icon = getIconImpl(obj)
            % Define icon for System block
            icon = mfilename("class"); % Use class name
            % icon = "My System"; % Example: text icon
            % icon = ["My","System"]; % Example: multi-line text icon
            % icon = matlab.system.display.Icon("myicon.jpg"); % Example: image file icon
        end
    end

    methods(Static, Access = protected)
        %% Simulink customization functions
        function header = getHeaderImpl
            % Define header panel for System block dialog
            header = matlab.system.display.Header(mfilename("class"));
        end

        function group = getPropertyGroupsImpl
            % Define property section(s) for System block dialog
            group = matlab.system.display.Section(mfilename("class"));
        end
    end
end
