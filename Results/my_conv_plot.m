function[] = my_conv_plot(conv_data, name, var, spacing, xlab, ylab, lims, val)
    
    % Interpolation for experimental data
    exp_val = interp1(val.a, val.(var), 8);
    
    % Plotting
    figure('Name', name)
    hold on 
    plot(conv_data.poly2.Time(1:spacing:end)-conv_data.poly2.Time(1), conv_data.poly2.(var)(1:spacing:end), ':x', 'LineWidth', 2, 'MarkerSize', 12, 'DisplayName', 'P=2')
    plot(conv_data.poly4.Time(1:spacing:end)-conv_data.poly4.Time(1), conv_data.poly4.(var)(1:spacing:end), '-.square', 'LineWidth', 2, 'MarkerSize', 12, 'DisplayName', 'P=4')
    plot(conv_data.poly6.Time(1:spacing:end)-conv_data.poly6.Time(1), conv_data.poly6.(var)(1:spacing:end), '--*', 'LineWidth', 2, 'MarkerSize', 12, 'DisplayName', 'P=6')
    plot([0 10], [exp_val exp_val], '-k', 'LineWidth', 2, 'DisplayName', 'Experimental')
    hold off
    grid on
    grid minor
    legend('Location','NorthWest')
    xlabel(xlab)
    ylabel(ylab)
    axis(lims)
    set(gca,"FontSize",18)

    % Analysis metrics
    for i=2:2:6
        window = conv_data.(['poly',num2str(i)]).(var)(end-1000:end);
        disp([var,' median at p=',num2str(i),' = ',num2str(median(window))])
        disp([var,' mean at p=',num2str(i),' = ',num2str(mean(window))])
    end

end