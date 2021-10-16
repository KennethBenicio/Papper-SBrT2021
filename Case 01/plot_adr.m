clc
clear
close all

%% Parameters
Mr = 4;
Mt = 4;
N  = 8;
K  = N * Mt;
snr    = 0:5:30; %dB

%% CASE 1
sys_par_c1    = zeros(5,1);
sys_par_c1(1) = Mr;
sys_par_c1(2) = Mt;
sys_par_c1(3) = N;
sys_par_c1(4) = 1;
sys_par_c1(5) = N*Mt;

%% CASE 2
sys_par_c2    = zeros(5,1);
sys_par_c2(1) = Mr;
sys_par_c2(2) = Mt;
sys_par_c2(3) = N;
sys_par_c2(4) = 2;
sys_par_c2(5) = N*Mt;

%% CASE 3
sys_par_c3    = zeros(5,1);
sys_par_c3(1) = Mr;
sys_par_c3(2) = Mt;
sys_par_c3(3) = N;
sys_par_c3(4) = 3;
sys_par_c3(5) = N*Mt;

%% CASE 4
sys_par_c4    = zeros(5,1);
sys_par_c4(1) = Mr;
sys_par_c4(2) = Mt;
sys_par_c4(3) = N;
sys_par_c4(4) = 4;
sys_par_c4(5) = N*Mt;

%% Loading data files

load ADR_no_IRS_c1.mat 
load ADR_no_IRS_c2.mat 
load ADR_no_IRS_c3.mat
load ADR_no_IRS_c4.mat 

load ADR_propos_c1.mat 
load ADR_propos_c2.mat 
load ADR_propos_c3.mat
load ADR_propos_c4.mat 

%% ADR plot
figure('DefaultAxesFontSize',12)

txt = ['Propose, P = ' num2str(sys_par_c1(4))]; 
plot(snr,ADR_propos_c1,'-s','color', [0.8 0.1  1.0 ], "linewidth", 2, "markersize", 8, "DisplayName", txt);
hold on

txt = ['Propose, P = ' num2str(sys_par_c2(4))];
plot(snr,ADR_propos_c2,'-+','color', [0.75 0.25  0 ], "linewidth", 2, "markersize", 8, "DisplayName", txt);
hold on

txt = ['Propose, P = ' num2str(sys_par_c3(4))];
plot(snr,ADR_propos_c3,'-x','color', [0.15 1  0.45 ], "linewidth", 2, "markersize", 8, "DisplayName", txt);
hold on

txt = ['Propose, P = ' num2str(sys_par_c4(4))];
plot(snr,ADR_propos_c4,'-d','color', [0.6 0.25  1 ], "linewidth", 2, "markersize", 8, "DisplayName", txt);
hold on

txt = ['No IRS, L = ' num2str(sys_par_c1(4))];
plot(snr,ADR_no_IRS_c1,'--s','color', [0.8 0.1  1 ], "linewidth", 2, "markersize", 10, "DisplayName", txt);
hold on

txt = ['No IRS, L = ' num2str(sys_par_c2(4))];
plot(snr,ADR_no_IRS_c2,'--+','color', [0.75 0.25  0 ], "linewidth", 2, "markersize", 10, "DisplayName", txt);
hold on

txt = ['No IRS, L = ' num2str(sys_par_c3(4))];
plot(snr,ADR_no_IRS_c3,'--x','color', [0.15 1  0.45 ], "linewidth", 2, "markersize", 10, "DisplayName", txt);
hold on

txt = ['No IRS, L = ' num2str(sys_par_c4(4))];
plot(snr,ADR_no_IRS_c4,'--d','color', [0.6 0.25  1 ], "linewidth", 2, "markersize", 8, "DisplayName", txt);
hold off

title(['Signal Absorption Model N = ' num2str(N), ', M_R = ' num2str(Mr), ', M_T = ' num2str(Mt)])
xlabel('SNR in dB')
ylabel('ADR in bps/Hz')

legend_copy = legend("location", "northwest");
set (legend_copy, "fontsize", 16);

grid on;

print -depsc sempahtloss.eps