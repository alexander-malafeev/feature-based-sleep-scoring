function [ err ] = findErrors(  exp, alg )

    numErr = numel( find(alg~=exp) );
    N = numel(alg);

    err = numErr/N;
