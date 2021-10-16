%% SBrT 2021 -- x Pilot process function


function [ADR_prop,ADR_no_IRS,W_opt,Q_opt,S_opt] = tcc_pilot_sig_beam_opt_specific(sys_par,QAM_pilot,SNR,SNR_TR)

%% ---- System Parameters
Mr = sys_par(1);
Mt = sys_par(2);
N  = sys_par(3);
P  = sys_par(4);
K  = sys_par(5);
L  = P;
Nx = N/4;
Ny = 4;
%% Channels
%%  ANGLE TX e RX

theta_Tx = 2*pi*rand(1,L)- pi; %AOD
theta_Rx = 2*pi*rand(1,L)- pi; %AOA

B_tx  = 1/sqrt(1) * exp(1i*pi*(0:Mt-1).'*cos(theta_Tx));
A_rx  = 1/sqrt(1) * exp(1i*pi*(0:Mr-1).'*cos(theta_Rx));

%%  ANGLES IRS
%----- Proposed case
theta_IRS_AOA_y  = 2*pi*randn(1,P)- pi; %AOA vertical
theta_IRS_AOA_x  = 2*pi*randn(1,P)- pi; %AOA horizontal

theta_IRS_AOD_y  = 2*pi*randn(1,P)- pi; %AOD vertical
theta_IRS_AOD_x  = 2*pi*randn(1,P)- pi; %AOD horizontal

%----- Steering vectors AOA   x and y
b_irs_x = 1/sqrt(1) * exp(1i*pi*((0:Nx-1).'*(cos(theta_IRS_AOA_x).*sin(theta_IRS_AOA_y))));
b_irs_y = 1/sqrt(1) * exp(1i*pi*((0:Ny-1).'*cos(theta_IRS_AOA_y)));
B_irs   = kr(b_irs_y,b_irs_x); % NxNy x L

%----- Steering vectors AOD x and y
a_irs_x = 1/1 * exp(1i*pi*((0:Nx-1).'*(cos(theta_IRS_AOD_x).*sin(theta_IRS_AOD_y))));
a_irs_y = 1/1 * exp(1i*pi*((0:Ny-1).'*cos(theta_IRS_AOD_y)));
A_irs   = kr(a_irs_y,a_irs_x); % NxNy x L

%--- path gains
alpha_pl =  1/sqrt(2) * (randn(L,1) + 1i*randn(L,1));
beta_pl  =  1/sqrt(2) * (randn(L,1) + 1i*randn(L,1));


% alpha_pl =  1/sqrt(P) * ones(L,1);
% beta_pl  =  1/sqrt(P) * ones(L,1);

%% Pilots signal (4-QAM)

x_pilots =  randi([0,3],K,Mt);
x_pilots = 1/sqrt(2) * qammod(x_pilots,QAM_pilot); % 4-QAM Pilot Signal

%% Rec signal Pilots
y_pilots = zeros(Mr,K,P);

Es_pilots          = mean(abs(x_pilots(:)).^2); % Energy symbol pilot 
var_noise_pilot    = Es_pilots .*  1 /SNR_TR; % noise
noise_pilots       = sqrt(var_noise_pilot/2) * (randn(Mr,K,P) + 1i*randn(Mr,K,P));

%--- IRS ps
S     = dftmtx(K);
S     = S(1:N,:); % N x K


for k =1:K
    for p =1:P
        y_pilots(:,k,p) = A_rx(:,p)*alpha_pl(p)*A_irs(:,p).'*diag(S(:,k))*B_irs(:,p)*beta_pl(p)*B_tx(:,p).'*x_pilots(k,:).' + noise_pilots(:,k,p);
    end
end

%%  Processing Pilot Signal
tenY_p_3  = tens2mat(y_pilots,3).'; %  MrK x P

A_rx_hat  = zeros(Mr,P);
B_tx_hat  = zeros(Mt,P);
S_opt     = zeros(N,P);
%------- Knwon matrix
rp  = zeros(N,P); % colects the P estimation of the steeing vectors of the IRS
Cp  = kron(kr(S,x_pilots.').', eye(Mr));  %MrK x MrMtN
sc_ab = zeros(P,1); % contain the product alpha pl * beta pl

%---------------------------------x Loop x --------------------------------
for p =1:P
    %% ------- Pilot processing
    zp  = pinv(Cp) * tenY_p_3(:,p); % MrMtN x1 approx vec(kr(tenH(:,:,p).',tenG(:,:,p)))) = vec kron(B_tx(:,p),A_rx(:,p) ) * kr(B_irs(:,p).' , A_irs(:,p)).' ).'
       
    %% --------- SVD Step For IRS optimum phase-shift
    Zp           = reshape(zp,Mr*Mt,N);
    [Up,Sp,Vp]   = svd(Zp);
    
    %% IRS - Phase-SHift
    rp(:,p)    = -1 * conj(Vp(:,1));
    sc         = B_irs(1,p) .* A_irs(1,p);   % factor scalar
    rp_sc      = sc(1)/rp(1,p);

    rp(:,p)    = rp_sc * rp(:,p);
    rp(:,p)    = rp(:,p)./abs(rp(:,p));
    
    %% Opt IRS 
    S_opt(:,p) = exp(-1i*angle(rp(:,p)./abs(rp(:,p))));

    %% Channels Estimation
 
    fp         = Up(:,1) * Sp(1,1);
    fp_sc      = -1;   % factor scalar
    fp         = fp * fp_sc;
    
    %=------ Reshaping
    Fp         = reshape(fp,Mr,Mt); % approx A_rx(:,p) * B_tx(:,p).';
    %               Fp./( A_rx(:,p)* 1* B_tx(:,p).') % Check
    [Ux,Sx,Vx] = svd(Fp);
    %------ Channels
    
    A_rx_hat(:,p) = 1*Ux(:,1)*sqrt(Sx(1,1));
    B_tx_hat(:,p) = 1*conj(Vx(:,1))*sqrt(Sx(1,1));
    %
    %             A_rx_hat(:,p) = Ux(:,1);
    %             B_tx_hat(:,p) = conj(Vx(:,1));
    
    alpha_sc      = 1./A_rx_hat(1,p); % first Element of A_rx is equal to 1 since exp(1i*0*cos(a))
    %             alpha_sc      = 1;
    A_rx_hat(:,p) = A_rx_hat(:,p) * alpha_sc;
    
    beta_sc       = 1./B_tx_hat(1,p); % first Element of B_tx is equal to 1 since exp(1i*0*cos(b))
    %             beta_sc       = 1;
    B_tx_hat(:,p) = B_tx_hat(:,p) * beta_sc;
    
    
    
    scx        = zp./( 1 *  vec(kron(B_tx_hat(:,p),A_rx_hat(:,p) ) * rp(:,p).'));
    %         sc_ab(p)  = sc(1);
    sc_ab(p)  = mean(scx); %pathloss
end


%%   IRS gains

%IRS_gain_hat = zeros(P,1);
IRS_gain     = zeros(P,1);
for p=1:P
    %IRS_gain_hat(p)        = rp(:,p).'*S_opt(:,p); % With est
    IRS_gain(p)            = A_irs(:,p).'*diag(S_opt(:,p))*B_irs(:,p); % True channels
end
%%  Precoders and Combiners and ADR/
Heff_hat        = A_rx_hat * diag(sc_ab)*B_tx_hat.';

%----- Estimated
[W_opt,~,Q_opt]           = svd(Heff_hat);
W_opt                     = 1/sqrt(P) * W_opt(:,1:P);
Q_opt                     = 1/sqrt(P) * Q_opt(:,1:P);

%RETRANSMISSÃO 
Heq         = W_opt'*A_rx * diag(sc_ab) * diag(IRS_gain) * B_tx.'*Q_opt;
Heq_no_IRS  = W_opt'*A_rx * diag(sc_ab) * B_tx.'*Q_opt;


ADR_no_IRS  =   log2(real( det( eye(P) + (Heq_no_IRS*Heq_no_IRS')/(1/SNR) ) ) );
ADR_prop    =   log2(real( det( eye(P) + (Heq*Heq')/(1/SNR) ) ) );
