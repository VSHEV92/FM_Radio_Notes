
%% скрипт для формирования модулированных записей

clc; clear; close all;

FramesNumber = 1000;    % число обрабатываемых пачек данных
AudioFrameSize = 1000;  % количество отсчетов аудиофайла, получаемых за один раз
RateRatio = 10;         % коэффициент увеличения частоты дискретизации
Fc = 100e3;             % частота несущей
ModIndex = 1;           % индекс модуляции
InputFile = 'wav/Audio_Source.wav';     % входной файл
OutputFile = 'wav/Audio_FM_ModIdx_1.wav';     % выходной файл

% объект для считываения отсчетов аудиофайла
AudioReader = dsp.AudioFileReader(...
    InputFile, ...
    'SamplesPerFrame',AudioFrameSize...
    );

% дополнительные расчеты
AudioFs = AudioReader.SampleRate;               % получаем частоту дискретизации аудиосообщения
SignalFs = AudioFs * RateRatio;                 % частота дискретизации модулированного сигнала
SignalFrameSize = AudioFrameSize * RateRatio;   % количество отсчетов чм-сигнала, получаемых за один раз

% вычисление чувствительности модулятора
Kf = ModIndex * AudioFs / 2;

% объект для записи отсчетов модулированного сигнала
AudioWriter = dsp.AudioFileWriter(...
   OutputFile, ...
   'SampleRate', SignalFs ...
   );

% интерполятор 
Upsampler = dsp.SampleRateConverter(...
    'Bandwidth', 40e3, ...
    'InputSampleRate',AudioFs, ...
    'OutputSampleRate', SignalFs ...
    );

% начальная фаза интегратора
InitPhase = 0;

% запуск симуляции
for i = 1:FramesNumber
    % считывание отсчетов аудиосообщения и выделение одного канала из
    % стерео сигнала
    AudioData = AudioReader();
    AudioData = AudioData(:,1);

    % увеличение частоты дискретизации аудиосообщения
    MessageData = Upsampler(AudioData);

    % вычисление мгновенной частоты (Hz)
    freq = Fc + Kf * MessageData;
    
    % вычисление фазы в радианах c помощью интегрирования
    phase = InitPhase + 2*pi/SignalFs * cumsum(freq);
    
    % обновление начальной фазы интегратора
    InitPhase = phase(end);
    
    % формирование модулированного сигнала
    FmSignal = [cos(phase) sin(phase)];
    
    % запись данных в файл
    AudioWriter(FmSignal);
end

% закрытие файлов
release(AudioReader);
release(AudioWriter);