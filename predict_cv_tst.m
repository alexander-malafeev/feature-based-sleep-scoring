%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all; fclose all;

addpath ./src/features

global epochl;


load('model.mat');


data_folder = './data/';
load('file_sets.mat');


cv_y  = [];
cv_y_ = [];
CV_l = [];
i_l = 1;
for i=1:length(files_CV)
    load( [data_folder files_CV{i}] );
    X = X(:,features_ndx);
    
    [label,score] = predict(model,X);
    CV_l(i) = numel(stages);    
    cv_y(i_l:i_l+CV_l(i)-1) =  stages;
    cv_y_(i_l:i_l+CV_l(i)-1) =  str2num(cell2mat(label));
    i_l = i_l+CV_l(i);
end


t_y  = [];
t_y_ = [];
test_l = [];
i_l = 1;
for i=1:length(files_test)
    load( [data_folder files_test{i}] );
    X = X(:,features_ndx);
    
    [label,score] = predict(model,X);
    test_l(i) = numel(stages);
    t_y(i_l:i_l+test_l(i)-1) =  stages;
    t_y_(i_l:i_l+test_l(i)-1) =  str2num(cell2mat(label));
    i_l = i_l+test_l(i);
end


save('predictions_RF_300.mat', 'cv_y', 'cv_y_', 't_y', 't_y_', ... 
 'test_l', 'CV_l', 'files_test', 'files_CV');


%===========
cv_y  = [];
cv_y_ = [];
CV_l = [];
i_l = 1;
for i=1:length(files_CV)
    load( [data_folder files_CV{i}] );
    X = X(:,features_ndx);
    
    [label,score] = predict(model,X);


    y = str2num(cell2mat(label));
    y = medfilt1(y,3);
    CV_l(i) = numel(stages);
    cv_y(i_l:i_l+CV_l(i)-1) =  stages;
    cv_y_(i_l:i_l+CV_l(i)-1) =  y;
    i_l = i_l+CV_l(i);
end


t_y  = [];
t_y_ = [];
test_l = [];
i_l = 1;
for i=1:length(files_test)
    load( [data_folder files_test{i}] );
    X = X(:,features_ndx);
    
    [label,score] = predict(model,X);

    y = str2num(cell2mat(label));
    y = medfilt1(y,3);
    test_l(i) = numel(stages);
    t_y(i_l:i_l+test_l(i)-1) =  stages;
    t_y_(i_l:i_l+test_l(i)-1) =  y;
    i_l = i_l+test_l(i);
end



save('predictions_RF_300_MF.mat', 'cv_y', 'cv_y_', 't_y', 't_y_', ... 
 'test_l', 'CV_l', 'files_test', 'files_CV');