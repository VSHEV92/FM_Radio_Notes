function Hd = Pilot_Bandpass_FIR_Coeff(Fs)
%PILOT_BANDPASS_FIR_COEFF Returns a discrete-time filter object.

% MATLAB Code
% Generated by MATLAB(R) 9.12 and DSP System Toolbox 9.14.
% Generated on: 20-May-2023 13:10:34

% Equiripple Bandpass filter designed using the FIRPM function.

% All frequency values are in kHz.
% Fs = 120;  % Sampling Frequency

Fstop1 = 16e3;              % First Stopband Frequency
Fpass1 = 18e3;              % First Passband Frequency
Fpass2 = 20e3;              % Second Passband Frequency
Fstop2 = 22e3;              % Second Stopband Frequency
Dstop1 = 0.001;           % First Stopband Attenuation
Dpass  = 0.057501127785;  % Passband Ripple
Dstop2 = 0.001;           % Second Stopband Attenuation
dens   = 20;              % Density Factor

% Calculate the order from the parameters using FIRPMORD.
[N, Fo, Ao, W] = firpmord([Fstop1 Fpass1 Fpass2 Fstop2]/(Fs/2), [0 1 ...
                          0], [Dstop1 Dpass Dstop2]);

% Calculate the coefficients using the FIRPM function.
b  = firpm(N, Fo, Ao, W, {dens});
Hd = dfilt.dffir(b);

% [EOF]
