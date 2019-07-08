 % genBodePlot.m
 % David E Olumese (dolumese@g.hmc.edu) | 28th Jan 2019
 % E151/E153 Course Development

%% variables
 % data file parameters
fname = './Data/rcCircuit.csv';
fStartRow = 3; 
fStartCol = 0;

 % estimated number of system poles & zeros
np = 1;
nz = 0;

 % maximum frequency in sweep
FRange_Hz = 1:0.1:400;      % [Hz]
Fmax_Hz   = FRange_Hz(end); % [Hz]
Fmax      = Fmax_Hz*(2*pi); % [rad/s]

 % bode plot figure bounds
mindB = -20;
maxdB = 10;
minDeg = -135;
maxDeg = 0;

%% Pull data from the file
M = csvread(fname, fStartRow, fStartCol);
t    = M(:,1);
inV  = M(:,2);
outV = M(:,3);

t = t - t(1); % adjust time to start from zero

Ts = t(2);  % [s] Sampling period
Fs = 1/Ts;  % [Hz] Sampling frequency
windw = []; % windowing function

%% Plot data
figure(1)
plot(t, inV, t, outV);
legend('Input signal', 'Output signal')
xlabel('Time (s)')
ylabel('Voltage (V)')
title('Input and Output Signals from Frequency Sweep')

%% Make bode plot with estimated poles & zeros
 % generate an estimated system
data = iddata(outV, inV, Ts);
sys = tfest(data, np, nz);

 % plot the bode plot
figure(2)
H = bodeplot(sys);
setoptions(H, 'FreqUnits', 'Hz');
title('Estimated System Bode Plot (Based on Number of Poles and Zeros)')
grid on

%% Make bode plot using transfer function estimation
[txy, ft] = tfestimate(inV, outV, windw, [], FRange_Hz, Fs); % generate tf estimate

 % determine system parameters
A  = abs(txy);           A_dB = mag2db(A);
Ph = unwrap(angle(txy)); Ph_deg = 180/pi*Ph;
w  = 2*pi*ft;

 % plot bode (include only useful information [F0, Fmax])
figure(3);
subplot(2, 1, 1)
semilogx(ft, A_dB);
axis([0 Fmax_Hz mindB maxdB])
title('System Bode Plot from Estimated Transfer Function')
ylabel('Magnitude (dB)')
grid on

subplot(2, 1, 2)
semilogx(ft, Ph_deg);
set(gca, 'YTick', [-180 -90 -45 0 45 90 180])
axis([0 Fmax_Hz minDeg maxDeg])
xlabel('Frequency (Hz)')
ylabel('Phase (degrees)')
grid on
