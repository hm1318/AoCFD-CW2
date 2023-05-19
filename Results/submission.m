%% Sample code of that used to postprocess Nektar++ output
% By Harrison Moss
% 18/05/23
% Full code available on Github (hyperlinked above)

%% User variables
alphas = [-4,-2,0,2,4,6,8];
alphas_3D = [-4, 0, 8];

%% Pre-allocation
% neg/pos values lower/upper bounds of unsteady QOI output
nek.D2 = array2table(zeros(length(alphas), 7),'VariableNames',...
    {'a','Cl','Cd','Cl_neg','Cl_pos','Cd_neg','Cd_pos'});
nek.D2.a = alphas';
nek.D3 = array2table(zeros(length(alphas_3D), 7),'VariableNames',...
    {'a','Cl','Cd','Cl_neg','Cl_pos','Cd_neg','Cd_pos'});
nek.D3.a = alphas_3D';
components2D = zeros(length(alphas), 7);
components2D = array2table(components2D,'VariableNames',...
    {'alpha','x_pres','x_visc','x_tot','y_pres','y_visc','y_tot'});
components3D = zeros(length(alphas_3D), 7);
components3D = array2table(components3D,'VariableNames',...
    {'alpha','x_pres','x_visc','x_tot','y_pres','y_visc','y_tot'});

%% Main Extraction Loop - 2D
% Same process followed for quasi-3D and different p-types
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

%% Plotting Pressure Coefficients
q = 0.5;
pres_avg = array2table(zeros(81,3), 'VariableNames',{'a','D2','D3'});

% 2D - same process followed for quasi-3D
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