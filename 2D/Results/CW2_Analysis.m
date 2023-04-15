%% A script to analyse outputs from nektar++
% By Harrison Moss
% 15/04/23

%% Setting up the workspace
close all
clear
clc
set(0,'DefaultFigureWindowStyle','Docked')

%% User variables
angles_run = [-4];

%% Main Loop
for i = angles_run
    % Load Data
    data = dlmread(['aeroForces',num2str(i),'.fce'],'',6,0);
    
    % Extract data
    tableNames = {'Time','x_pres','x_visc','x_tot','y_pres','y_visc','y_tot','mom_visc','mom_pres','mom_tot'};
    data = array2table(data, 'VariableNames',tableNames);
    
    % Correction
    data.Cd = 2 * (cosd(i)*data.x_tot + sind(i)*data.y_tot);
    data.Cl = 2 * (sind(i)*data.x_tot + cosd(i)*data.y_tot);
    
    % Plot
    figure()
    title(['Coefficients for \alpha = ',num2str(i)]);
    hold on
    plot(data.Time, data.Cl, '-b', 'DisplayName', 'C_L')
    plot(data.Time, data.Cd, '.g', 'DisplayName', 'C_D')
    hold off
    legend()
    xlabel('Time (s)')
    ylabel('Coefficient Magnitude')
end
