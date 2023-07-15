import numpy as np

class Complex_pll:
    
    def __init__(self, 
                 sample_frequency,   # sample frequency in herz
                 noise_bandwidth,    # noise bandwidth in herz
                 damping_factor,     # damping factor
                 central_frequency): # central NCO frequency in herz        
        
        self.central_frequency = central_frequency
        self.sample_frequency = sample_frequency
        
        self.ts = 1/self.sample_frequency  # sample time
        BL_n = noise_bandwidth * self.ts   # normalized noise bandwidth
        
        ksi = damping_factor
        
        self.kp = 4*ksi*BL_n / (ksi + 0.25/ksi) 
        self.ki = 4*BL_n**2 / (ksi + 0.25/ksi)**2

        # PLL internal variables
        self.NCO_phase = 0
        self.loop_filter_acc = 0

        
    def step(self, input_frame):
        frame_size = input_frame.size
            
        output_frame = np.zeros(frame_size, dtype=complex)
        frequency_error = np.zeros(frame_size)
            
        for n in range(frame_size):
            # умножение сигнала на сигнал от NCO
            phase_error = np.angle( input_frame[n] * np.exp(-1j * self.NCO_phase) )
            
            # петлевой фильтр
            kp_out = self.kp * phase_error
            ki_out = self.ki * phase_error + self.loop_filter_acc
            loop_filter_out = kp_out + ki_out

            # обновление состояния накопителя в петлевом фильтре
            self.loop_filter_acc = ki_out;

            # обновление фазы NCO
            self.NCO_phase = self.NCO_phase + loop_filter_out + 2*np.pi*self.central_frequency*self.ts

            # формирование выходных значений
            frequency_error[n] = loop_filter_out / (2*np.pi) * self.sample_frequency 
            output_frame[n] = np.exp(1j * self.NCO_phase)
            
        return frequency_error, output_frame 
