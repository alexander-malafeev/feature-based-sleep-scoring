function [counts, F, H] = detectSEM(signal, fs, epochl)
    % the algorithm detects slow eye movements 

    % Magosso, E., Provini, F., Montagna, P. and Ursino, M. A wavelet based method
    % for automatic detection of slow eye movements: A pilot study. Medical
    % engineering & physics, 2006, 28: 860-875. 

    % implemented by Alexander Malafeev based on the description of the 
    % algorithm in the paper

    W3 = 0.5115;
    W4 = 1.0431;
    W5 = 1.0761;
    W7 = 0.0988;
    W8 = 0.1553;
    W9 = 0.0488;
    W10 = 0.0496;
    th = 0.85;


    % % downsampling
    % n = round(fs/128);
    % g =  gcd(128,fs);
    % p = 128/g;
    % q = fs/g;
    % signal = resample(signal,p,q);
    s = signal;
    J0 = 6;
    wname = 'db4';
    scales = 10;
    
    [c,l] = wavedec(s,scales,'db4');

    k2 = numel(c);
    for i=1:10    
        k1 = k2 - l(12-i)+1;
        d{i} = c(k1:k2);
        k2 = k1-1;
    end

    E = zeros(scales, numel(d{J0}) );

    M = numel(signal)/2^6 - 1;
    % compute energy atoms

    for j=1:5
        dt = d{j};
        for n=0:M
            %n = n1-1; 
            k1 = (2*n-1)*(2^(J0-j))/2;
            k2 = (2*n+1)*(2^(J0-j))/2-1;
            if(k1<=0) k1 =  1; end;
            if(k2>= numel(d{j})) k2 =  numel(d{j}); end;
            Et = 0;
            for k=k1:k2
                Et = Et + dt(k+1).^2;
            end
            E(j, n+1) = Et; 
        end
    end


    for j=7:10
        dt = d{j};
        M = numel(signal)/2^j - 1;
        for k=0:M
            n1 = k*(2^(j-J0));
            n2 = (k+1)*(2^(j-J0))-1;
            if(n2>= numel(d{J0})) n2 =  numel(d{J0})-1; end;
            
            E(j, n1+1:n2+1) = dt(k+1).^2/(2^(j-J0)); 
        end
    end

    j=6;
    dt = d{j};
    M = numel(signal)/2^j - 1;
    for n=0:M
        E(j, n+1) = dt(n+1).^2; 
    end

    F = zeros(1, numel(d{J0}) );

    A = W7*E(7,:) +W8*E(8,:) + W9*E(9,:) + W10*E(10,:);
    B = A + W3*E(3,:)+ W4*E(4,:)+ W5*E(5,:);
    F  = A./B;


    epochlN = epochl*2;
    maxep = floor(numel(F)/epochlN);
    F1 = F(1:maxep*epochlN);
    tmp = reshape(F1, [epochlN maxep ] );
    F = sum(tmp, 1);

    thCrossings = zeros(size(F1));
    thCrossings( find(F1>=th) ) = 1;


    tmp = reshape(thCrossings, [epochlN maxep ] );

    counts = sum(tmp, 1);

    H  = E(1,:)+E(2,:);
    H1 = H(1:maxep*epochlN);
    tmp = reshape(H1, [epochlN maxep ] );
    H = sum(tmp, 1);





