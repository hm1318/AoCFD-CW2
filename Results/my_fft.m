% Function to plot fft power spectrum of given signal
function[] = my_fft(x, alpha, sample_freq, variable)

    Y = fft(x);
    L = length(x);
    Fs = sample_freq;
    
    P2 = abs(Y/L);
    P1 = P2(1:floor(L/2+1));
    P1(2:end-1) = 2*P1(2:end-1);
    
    figure('Name',['FFT of ',variable, ' of a=',num2str(alpha)])
    hold on
    
    f = Fs*(0:floor(L/2))/L;
    plot(f,P1, 'LineWidth',2)
    xlabel("f (Hz)")
    ylabel("|P1(f)|")
    set(gca, 'XScale', 'log')
    set(gca, 'FontSize', 18)
    grid minor
    grid on

end