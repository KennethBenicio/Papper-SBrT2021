%%Number of elements per IRS

clc
clear
close all
pkg load communications

Mr = 4;
Mt = 4;
P  = 2;

MCC    = 1e2;
snr    = 0:5:40; %dB
snr_tr = 25;  
SNR    = 10.^(snr/10); %linear
SNR_TR = 10.^(snr_tr/10);

%% Parameters
ADR_no_IRS_c1  = zeros(length(SNR),MCC);
ADR_propos_c1  = zeros(length(SNR),MCC);

ADR_no_IRS_c2  = zeros(length(SNR),MCC);
ADR_propos_c2  = zeros(length(SNR),MCC);

ADR_no_IRS_c3  = zeros(length(SNR),MCC);
ADR_propos_c3  = zeros(length(SNR),MCC);

ADR_no_IRS_c4  = zeros(length(SNR),MCC);
ADR_propos_c4  = zeros(length(SNR),MCC);

%% CASE 1
sys_par_c1    = zeros(5,1);
sys_par_c1(1) = Mr;
sys_par_c1(2) = Mt;
sys_par_c1(3) = 8;
sys_par_c1(4) = P;
sys_par_c1(5) = 8*Mt;

%% CASE 2
sys_par_c2    = zeros(5,1);
sys_par_c2(1) = Mr;
sys_par_c2(2) = Mt;
sys_par_c2(3) = 16;
sys_par_c2(4) = P;
sys_par_c2(5) = 16*Mt;

%% CASE 3
sys_par_c3    = zeros(5,1);
sys_par_c3(1) = Mr;
sys_par_c3(2) = Mt;
sys_par_c3(3) = 32;
sys_par_c3(4) = P;
sys_par_c3(5) = 32*Mt;

%% CASE 4
sys_par_c4    = zeros(5,1);
sys_par_c4(1) = Mr;
sys_par_c4(2) = Mt;
sys_par_c4(3) = 64;
sys_par_c4(4) = P;
sys_par_c4(5) = 64*Mt;

tic 
for jj = 1:length(SNR)
    jj
    for mc = 1:MCC
        mcc
        %% CASE 1 P = 1  
        [ADR_propos_c1(jj,mc),ADR_no_IRS_c1(jj,mc),~,~,~,] = tcc_pilot_sig_beam_opt_specific(sys_par_c1,4,SNR(jj),SNR_TR);
        
        %% CASE 2 P = 2
        [ADR_propos_c2(jj,mc),ADR_no_IRS_c2(jj,mc),~,~,~,] = tcc_pilot_sig_beam_opt_specific(sys_par_c2,4,SNR(jj),SNR_TR);
        
        %% CASE 3 P = 3
        [ADR_propos_c3(jj,mc),ADR_no_IRS_c3(jj,mc),~,~,~,] = tcc_pilot_sig_beam_opt_specific(sys_par_c3,4,SNR(jj),SNR_TR);
        
        %% CASE 4 P = 4
        [ADR_propos_c4(jj,mc),ADR_no_IRS_c4(jj,mc),~,~,~,] = tcc_pilot_sig_beam_opt_specific(sys_par_c4,4,SNR(jj),SNR_TR);   
    end
end
toc

ADR_no_IRS_c1  = mean(ADR_no_IRS_c1,2);
ADR_propos_c1  = mean(ADR_propos_c1,2);

ADR_no_IRS_c2  = mean(ADR_no_IRS_c2,2);
ADR_propos_c2  = mean(ADR_propos_c2,2);

ADR_no_IRS_c3  = mean(ADR_no_IRS_c3,2);
ADR_propos_c3  = mean(ADR_propos_c3,2);

ADR_no_IRS_c4  = mean(ADR_no_IRS_c4,2);
ADR_propos_c4  = mean(ADR_propos_c4,2);

%% Saving data files

save ADR_no_IRS_c1.mat ADR_no_IRS_c1
save ADR_no_IRS_c2.mat ADR_no_IRS_c2
save ADR_no_IRS_c3.mat ADR_no_IRS_c3
save ADR_no_IRS_c4.mat ADR_no_IRS_c4

save ADR_propos_c1.mat ADR_propos_c1
save ADR_propos_c2.mat ADR_propos_c2
save ADR_propos_c3.mat ADR_propos_c3
save ADR_propos_c4.mat ADR_propos_c4