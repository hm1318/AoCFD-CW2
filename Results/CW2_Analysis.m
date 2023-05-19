%% A script to analyse outputs from nektar++
% By Harrison Moss
% 15/04/23

%% Setting up the workspace
close all
clear
clc
set(0,'DefaultFigureWindowStyle','Docked')

%% User variables
alphas = [-4,-2,0,2,4,6,8];
alphas_3D = [-4, 0, 8];

%% Pre-allocation
nek.D2 = array2table(zeros(length(alphas), 7),'VariableNames',{'a','Cl','Cd','Cl_neg','Cl_pos','Cd_neg','Cd_pos'});
nek.D2.a = alphas';
nek.D3 = array2table(zeros(length(alphas_3D), 7),'VariableNames',{'a','Cl','Cd','Cl_neg','Cl_pos','Cd_neg','Cd_pos'});
nek.D3.a = alphas_3D';
components2D = zeros(length(alphas), 7);
components2D = array2table(components2D,'VariableNames',{'alpha','x_pres','x_visc','x_tot','y_pres','y_visc','y_tot'});
components3D = zeros(length(alphas_3D), 7);
components3D = array2table(components3D,'VariableNames',{'alpha','x_pres','x_visc','x_tot','y_pres','y_visc','y_tot'});

%% Main Extraction Loop - 2D
for i = 1:length(alphas)
    % Load Data - changes each loop
    data = dlmread(['2DResults/aeroForces',num2str(alphas(i)),'.fce'],'',6,0);
    tableNames = {'Time','x_pres','x_visc','x_tot','y_pres','y_visc','y_tot','mom_visc','mom_pres','mom_tot'};
    data = array2table(data, 'VariableNames',tableNames);
    
    % AoA Correction
    data.Cd = 2 * (cosd(alphas(i))*data.x_tot + sind(alphas(i))*data.y_tot);
    data.Cl = 2 * (sind(alphas(i))*data.x_tot + cosd(alphas(i))*data.y_tot);
    
    % FFT
    L = height(data);
    sample_freq = (L-1)/(data.Time(L)-data.Time(1));
    my_fft(data.Cl(round(L/2):end), alphas(i), sample_freq, 'Lift')
    my_fft(data.Cd(round(L/2):end), alphas(i), sample_freq, 'Drag')
    
    % Filtering
    [nek.D2.Cl(i),nek.D2.Cl_neg(i),nek.D2.Cl_pos(i)] = my_filtering(data.Cl, 1, sample_freq, 'Lift', 0.85, 0.95);
    [nek.D2.Cd(i),nek.D2.Cd_neg(i),nek.D2.Cd_pos(i)] = my_filtering(data.Cd, 1, sample_freq, 'Drag', 0.85, 0.95);

    % Sampling x&y components of force
    components2D.alpha(i) = alphas(i);
    components2D(i,2:end) = array2table(mean(table2array(data(end-500:end,2:7))));
    
end

clear data

%% Main Extraction Loop - 3D
for i = 1:length(alphas_3D)
    % Load Data
    data = dlmread(['3DResults/aeroForces3D',num2str(alphas_3D(i)),'.fce'],'',6,0);
    tableNames = {'Time','x_pres','x_visc','x_tot','y_pres','y_visc','y_tot','mom_visc','mom_pres','mom_tot'};
    data = array2table(data, 'VariableNames',tableNames);
    data.Time = data.Time - data.Time(1);
    
    % AoA Correction
    data.Cd = 2 * (cosd(alphas_3D(i))*data.x_tot + sind(alphas_3D(i))*data.y_tot);
    data.Cl = 2 * (sind(alphas_3D(i))*data.x_tot + cosd(alphas_3D(i))*data.y_tot);
    
    % FFT
    L = height(data);
    sample_freq = (L-1)/(data.Time(L)-data.Time(1));
    my_fft(data.Cl(round(L/2):end), alphas_3D(i), sample_freq, 'Lift')
    my_fft(data.Cd(round(L/2):end), alphas_3D(i), sample_freq, 'Drag')
    
    % Filtering
    [nek.D3.Cl(i),nek.D3.Cl_neg(i),nek.D3.Cl_pos(i)] = my_filtering(data.Cl, 1, sample_freq, 'Lift', 0.85, 0.95);
    [nek.D3.Cd(i),nek.D3.Cd_neg(i),nek.D3.Cd_pos(i)] = my_filtering(data.Cd, 1, sample_freq, 'Drag', 0.85, 0.95);

    % Sampling x&y components of force
    components3D.alpha(i) = alphas_3D(i);
    components3D(i,2:end) = array2table(mean(table2array(data(end-500:end,2:7))));
    
end

clear table

%% Plotting sim results against experimental data
% Loading data
validation.ccm_sa = dlmread('ccm_sa_data.txt','',2,0);
validation.ccm_sa = array2table(validation.ccm_sa, 'VariableNames',{'a','Cl','Cd'});
validation.ccm_sa = validation.ccm_sa(1:end-1,:);
validation.ccm_sst = dlmread('ccm_sst_data.txt','',2,0);
validation.ccm_sst = array2table(validation.ccm_sst, 'VariableNames',{'a','Cl','Cd'});
validation.exp = dlmread('exp_data.txt','',2,0);
validation.exp = array2table(validation.exp, 'VariableNames',{'a','Cl','Cd'});

% Linespecs
ls.sa = ':^'; colour.sa = [0.4660 0.6740 0.1880];
ls.sst = ':v'; colour.sst = [0.4940 0.1840 0.5560];
ls.exp = '-k';
ls.nek = '--square'; colour.nek = [0.8500 0.3250 0.0980];

% Plotting
my_plot('Cl vs a', nek, validation, 'a', 'Cl', '\alpha (degrees)', 'C_L', ls, colour, 1)
my_plot('Cd vs a', nek, validation, 'a', 'Cd', '\alpha (degrees)', 'C_D', ls, colour, 1)
my_plot('Cl vs Cd', nek, validation, 'Cd', 'Cl', 'C_D', 'C_L', ls, colour, 1)
my_plot('Cl vs Cd', nek, validation, 'Cd', 'Cl', 'C_D', 'C_L', ls, colour, 0)

%% Convergence Plot
% Data Extraction
poly_degrees = [2,4,6];
conv_Cl_avg = zeros(1, length(poly_degrees));
conv_Cd_avg = zeros(1, length(poly_degrees));
% Result analysis
for i = 1:length(poly_degrees)
    
    % Import data
    conv_data.(['poly',num2str(poly_degrees(i))]) = dlmread(['ConvergenceResults/aeroForcesP',num2str(poly_degrees(i)),'.fce'],'',6,0);
    conv_data.(['poly',num2str(poly_degrees(i))]) = array2table(conv_data.(['poly',num2str(poly_degrees(i))]), 'VariableNames', tableNames);
    
    % AoA Correction
    conv_data.(['poly',num2str(poly_degrees(i))]).Cd = 2 * (cosd(8)*conv_data.(['poly',num2str(poly_degrees(i))]).x_tot + sind(8)*conv_data.(['poly',num2str(poly_degrees(i))]).y_tot);
    conv_data.(['poly',num2str(poly_degrees(i))]).Cl = 2 * (sind(8)*conv_data.(['poly',num2str(poly_degrees(i))]).x_tot + cosd(8)*conv_data.(['poly',num2str(poly_degrees(i))]).y_tot);
    
    % FFT
    L = height(conv_data.(['poly',num2str(poly_degrees(i))]));
    sample_freq = L/(conv_data.(['poly',num2str(poly_degrees(i))]).Time(L)-conv_data.(['poly',num2str(poly_degrees(i))]).Time(1));
    my_fft(conv_data.(['poly',num2str(poly_degrees(i))]).Cl(round(L/2):end), poly_degrees(i), sample_freq, 'Lift')
    my_fft(conv_data.(['poly',num2str(poly_degrees(i))]).Cd(round(L/2):end), poly_degrees(i), sample_freq, 'Drag')
    
end

% Convergence Plotting
my_conv_error_plot(conv_data, 'Cl Convergence per p', 'Cl', 20, 'Time (s)', '\epsilon_{C_L} (%)', [0 10 0.4 2], validation.exp)
my_conv_error_plot(conv_data, 'Cd Convergence per p', 'Cd', 20, 'Time (s)', '\epsilon_{C_D} (%)', [0 10 -0.05 0.35], validation.exp)

%% Plotting Drag contributors
figure('Name','x Contributions to Forces')
hold on
plot(components2D.alpha, components2D.x_pres, '--xb', 'LineWidth', 1.5, 'MarkerSize', 12, 'DisplayName',' 2D Pressure')
plot(components2D.alpha, components2D.x_visc, ':xb', 'LineWidth', 2, 'MarkerSize', 12, 'DisplayName',' 2D Viscous')
plot(components2D.alpha, components2D.x_tot, '-xb', 'LineWidth', 1.5, 'MarkerSize', 12, 'DisplayName',' 2D Total')
plot(components3D.alpha, components3D.x_pres, '--+r', 'LineWidth', 1.5, 'MarkerSize', 12, 'DisplayName',' 3D Pressure')
plot(components3D.alpha, components3D.x_visc, ':+r', 'LineWidth', 2, 'MarkerSize', 12, 'DisplayName',' 3D Viscous')
plot(components3D.alpha, components3D.x_tot, '-+r', 'LineWidth', 1.5, 'MarkerSize', 12, 'DisplayName',' 3D Total')
hold off
xlabel('\alpha')
ylabel('Contribution to Force in x')
grid on
grid minor
legend('Location','southwest')
set(gca,"FontSize",18)

figure('Name','y Contributions to Forces')
hold on
plot(components2D.alpha, components2D.y_pres, '--xb', 'LineWidth', 1.5, 'DisplayName',' 2D Pressure')
plot(components2D.alpha, components2D.y_visc, ':xb', 'LineWidth', 2, 'DisplayName',' 2D Viscous')
plot(components2D.alpha, components2D.y_tot, '-xb', 'LineWidth', 1.5, 'DisplayName',' 2D Total')
plot(components3D.alpha, components3D.y_pres, '--+r', 'LineWidth', 1.5, 'DisplayName',' 3D Pressure')
plot(components3D.alpha, components3D.y_visc, ':+r', 'LineWidth', 2, 'DisplayName',' 3D Viscous')
plot(components3D.alpha, components3D.y_tot, '-+r', 'LineWidth', 1.5, 'DisplayName',' 3D Total')
hold off
xlabel('\alpha')
ylabel('Contribution to Force in y')
grid on
grid minor
legend('Location','northwest')
set(gca,"FontSize",18)

%% Plotting Pressure Coefficients
q = 0.5;
pres_avg = array2table(zeros(81,3), 'VariableNames',{'a','D2','D3'});

figure('Name','2D Pressure Coefficient Comparison')
hold on
for i = 101:111
    data = dlmread(['2DResults/Pressures/pres_',num2str(i),'.dat'],'',3,0);
    data = data(:,[1,5]);
    data = array2table(data,'VariableNames',{'x','p'});
    data.Cp = data.p/q;
    plot(data.x,-data.Cp)

    pres_avg.D2 = pres_avg.D2 + data.Cp;
end
hold off
xlabel('x/c')
ylabel('-C_p')
grid on 
grid minor

figure('Name','3D Pressure Coefficient Comparison')
hold on
for i = 203:213
    data = dlmread(['3DResults/Pressures/pres_',num2str(i),'.dat'],'',3,0);
    data = data(:,[1,6]);
    data = array2table(data,'VariableNames',{'x','p'});
    data.Cp = data.p/q;
    plot(data.x,-data.Cp)

    pres_avg.D3 = pres_avg.D3 + data.Cp;
end
hold off
xlabel('x/c')
ylabel('-C_p')
grid on 
grid minor

s7055 = readtable("points_s7055.pts",'FileType','text');
s7055.Properties.VariableNames={'x','y'};

pres_avg.x = data.x;
pres_avg.D2 = pres_avg.D2/11;
pres_avg.D3 = pres_avg.D3/11;
figure('Name', 'C_p Comparison')
hold on
plot(pres_avg.x, -pres_avg.D2,'-.b','DisplayName','2D', 'LineWidth', 2)
plot(pres_avg.x, -pres_avg.D3,'--r', 'DisplayName','3D', 'LineWidth', 2)
plot(s7055.x, 6*s7055.y,'-k','DisplayName', 'S7055 (Not to Scale)', 'LineWidth', 2)
hold off
xlabel('x/c')
ylabel('-C_p')
grid on
grid minor
set(gca,"FontSize",18)
legend()