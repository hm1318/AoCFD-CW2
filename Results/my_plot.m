% Function to plot output QOIs from different methods
function[] = my_plot(name, nek, val, x, y, xlab, ylab, ls, colour)

    figure('Name', name)
    hold on
    plot(val.exp.(x), val.exp.(y), ls.exp, 'LineWidth', 2, 'DisplayName', 'Experimental')
    plot(val.ccm_sst.(x), val.ccm_sst.(y), ls.sst, 'LineWidth', 2, 'MarkerSize', 12, 'Color', colour.sst, 'DisplayName', 'Star SST')
    plot(val.ccm_sa.(x), val.ccm_sa.(y), ls.sa, 'LineWidth', 2, 'MarkerSize', 12, 'Color', colour.sa, 'DisplayName', 'Star SA')

    errorbar_thickness = 0.75;

    if isequal(xlab, '\alpha (degrees)')
        e2 = errorbar(nek.D2.(x), nek.D2.(y), nek.D2.([(y),'_neg']), nek.D2.([(y),'_pos']), ls.nek, 'LineWidth', 2, 'MarkerSize', 12, 'Color', colour.nek, 'DisplayName', 'Nektar++ 2D');
        e3 = errorbar(nek.D3.(x), nek.D3.(y), nek.D3.([(y),'_neg']), nek.D3.([(y),'_pos']), '*b', 'LineWidth', 2, 'MarkerSize', 14, 'DisplayName', 'Nektar++ Quasi-3D');
    else
        e2 = errorbar(nek.D2.(x), nek.D2.(y), nek.D2.([(y),'_neg']), nek.D2.([(y),'_pos']), nek.D2.([(x),'_neg']), nek.D2.([(x),'_pos']), ls.nek, 'LineWidth', 2, 'MarkerSize', 12, 'Color', colour.nek, 'DisplayName', 'Nektar++ 2D');
        e3 = errorbar(nek.D3.(x), nek.D3.(y), nek.D3.([(y),'_neg']), nek.D3.([(y),'_pos']), nek.D3.([(x),'_neg']), nek.D3.([(x),'_pos']), '*b', 'LineWidth', 2, 'MarkerSize', 14, 'DisplayName', 'Nektar++ Quasi-3D');
    end

    e2.Bar.LineWidth = errorbar_thickness;
    e3.Bar.LineWidth = errorbar_thickness;
    e3.CapSize = 12;

    hold off
    xlabel(xlab)
    ylabel(ylab)
    grid on
    grid minor
    legend('Location','NorthWest')
    set(gca,"FontSize",18)

end