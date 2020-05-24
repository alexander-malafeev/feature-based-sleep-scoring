function [ SEF ] = SEF( Pspec, fs,  df, x, band )

% Spectral Edge Frequency is frequency, below which x percent 
% of the total power of a given signal are located. 
% (typically x is in the range 75 to 95.)

% for details see 
% Malafeev et al. Automatic Human Sleep Stage Scoring Using Deep Neural Networks
% https://www.frontiersin.org/articles/10.3389/fnins.2018.00781/full

if ~exist('x','var') || isempty(x)
    x=0.75;
end

if ~exist('band','var') || isempty(band)
    band_ndx=1:size(Pspec,1);
else
    band_ndx = round( band(1)/df ):round( band(2)/df );
end

n = size(Pspec,2);
faxis = 0:df:fs/2;

SEF = zeros( n, 1 );

for i=1:n
    s = Pspec(band_ndx, i);
    t = cumsum(s)/sum(s);
    ix = find(t>x);
    if ~isempty(ix)
        SEF(i) = ix(1)*df;
    else
        SEF(i) = 0;
    end;
end

end