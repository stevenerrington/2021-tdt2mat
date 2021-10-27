function [] = plotPowerSpectrum(data,fs)
%PLOTPOWERSPECTRUM Summary of this function goes here

x=data;
xFft = fft(x,length(x));
xF = ((0:1/length(x):1-1/length(x))*fs)';
% Take half of the data
xF = xF(1:length(xF)/2);
xFft = xFft(1:length(xF));
% magnitute and phase
xFft(1) = 0; %remove DC
magX = abs(xFft);
phaseX = unwrap(angle(xFft));

% plot
figure
subplot(2,1,1)
plot(xF(1:length(xF)/2),20*log10(magX(1:length(xF)/2)))
title('magnitude response')
xlabel('Frequency in kHz')
ylabel('dB')
axis tight
subplot(2,1,2)
plot(xF(1:length(xF)/2),phaseX(1:length(xF)/2))
title('phase response')
xlabel('Frequency in kHz')
ylabel('radians')
grid on;
axis tight


end

