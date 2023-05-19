% Function to take signal, apply a lowpass filter at specified frequency
% and plot resulting waveform
function[avg_coeff,neg,pos] = my_filtering(signal, cutoff, sample_freq, variable, start_trim_point, end_trim_point)

    L = length(signal);
    
    filtered = lowpass(signal(1:end), cutoff, sample_freq, 'Steepness', 0.95);
    figure('Name',['Filtered ',variable])
    hold on
    plot((1:L)/sample_freq, signal, 'b', 'DisplayName', 'Original')
    plot((1:L)/sample_freq, filtered, 'k', 'LineWidth', 2, 'DisplayName', 'Filtered')
    hold off
    xlabel('Time (s)')
    legend('Location','NorthWest')
    set(gca, 'FontSize', 18)
    grid on

    % Dynamic Labelling
    if isequal(variable,'Lift')
        ylabel('C_L')
    elseif isequal(variable,'Drag')
        ylabel('C_D')
    else
        ylabel('Magnitude')
    end
    
    data = filtered(ceil(L*start_trim_point):floor(L*end_trim_point));
    avg_coeff = mean(data);
    neg = avg_coeff - min(signal(ceil(L*start_trim_point):floor(L*end_trim_point)));
    pos = max(signal(ceil(L*start_trim_point):floor(L*end_trim_point))) - avg_coeff;

end