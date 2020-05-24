function [ Delta, Theta, Alpha, Spindles, Beta,  Gamma ] = extractBands( Pspec, fs,  df )


% Delta
fl = 0.8;
fh = 5.0;
delta_ind=round(fl/df)+1:round(fh/df)+1; % 0.8-4.6 Hz; 0.2 Hz resolution
Delta=(df*sum(Pspec(delta_ind,:)))';


%Theta
fl = 5.0;
fh = 8.6;
theta_ind=round(fl/df)+1:round(fh/df)+1; % 0.8-4.6 Hz; 0.2 Hz resolution
Theta=df*(sum(Pspec(theta_ind,:)))';


%Alpha
fl = 8.6;
fh = 12;
alpha_ind=round(fl/df)+1:round(fh/df)+1; % 0.8-4.6 Hz; 0.2 Hz resolution
Alpha=df*(sum(Pspec(alpha_ind,:)))';

%Spindles

fl = 11;
fh = 15;
spindles_ind=round(fl/df)+1:round(fh/df)+1; % 0.8-4.6 Hz; 0.2 Hz resolution
Spindles=df*(sum(Pspec(spindles_ind,:)))';

%Beta
fl = 16;
fh = 30;
beta_ind=round(fl/df)+1:round(fh/df)+1; % 0.8-4.6 Hz; 0.2 Hz resolution
Beta=df*(sum(Pspec(beta_ind,:)))';

%Gamma
fl = 30;
fh = 40;
gamma_ind=round(fl/df)+1:round(fh/df)+1; % 0.8-4.6 Hz; 0.2 Hz resolution
Gamma=df*(sum(Pspec(gamma_ind,:)))';

% %Gamma2
% fl = 51;
% fh = 90;
% gamma2_ind=round(fl/df)+1:round(fh/df)+1; % 0.8-4.6 Hz; 0.2 Hz resolution
% Gamma2=df*(sum(Pspec(gamma2_ind,:)))';


end