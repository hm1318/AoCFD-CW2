% Function to plot output QOIs from different methods
function[] = my_plot(name, nek, val, x, y, xlab, ylab, ls, colour)

    figure('Name', name)
    hold on
    plot(val.exp.(x), val.exp.(y), ls.exp, 'LineWidth', 2, 'DisplayName', 'Experimental')
    plot(val.ccm_sst.(x), val.ccm_sst.(y), ls.sst, 'LineWidth', 2, 'MarkerSize', 12, 'Color', colour.sst, 'DisplayName', 'Star SST')
    plot(val.ccm_sa.(x), val.ccm_sa.(y), ls.sa, 'LineWidth', 2, 'MarkerSize', 12, 'Color', colour.sa, 'DisplayName', 'Star SA')
    plot(nek.D2.(x), nek.D2.(y), ls.nek, 'LineWidth', 2, 'MarkerSize', 12, 'Color', colour.nek, 'DisplayName', 'Nektar++ 2D')
    plot(nek.D3.(x), nek.D3.(y), '*b', 'LineWidth', 2, 'MarkerSize', 14, 'DisplayName', 'Nektar++ Quasi-3D')
    hold off
    xlabel(xlab)
    ylabel(ylab)
    grid on
    grid minor
    legend('Location','NorthWest')
    set(gca,"FontSize",18)

end