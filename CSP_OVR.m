%张正杰
%2020.7.23
%主程序：实现CSP_OVR+SVM分类 
clc;
clear;
tic
%储存9个被试十次测试的acc和kappa
a_k = zeros(10,18);
for ak = 1:9
%加载数据
load(['DATA_OLD/0' num2str(ak) 't.mat']);
%数据拼接
%      X1=EEGSignals.x;
%      Y1=EEGSignals.y;
% load(['DATA_OLD/0' num2str(ak) 'e.mat']);
%      X2=EEGSignals.x;
%      Y2=EEGSignals.y;
%      X3=cat(3,X1,X2);
%      Y3=cat(1,Y1,Y2);
%      EEGSignals1.x=X3;   
%      EEGSignals1.y=Y3;   
%      EEGSignals1.s=250; 
%%
EEGSignal_X  = EEGSignals.x(:,1:22,:); %前22通道
EEGSignal_y  = EEGSignals.y;
EEGSignals.x = EEGSignal_X;
len = length(EEGSignals.y);
%%
%滤波7—30Hz带通滤波
fl = 7;
fh = 30;
dx = 5;
signals_F = Bpfilters(EEGSignal_X,fl,fh,dx);
EEGSignals.x = signals_F;
%测试滤波效果，作频谱图
% N  = 750;
% fs = 250;
% x1   =  EEGSignal_X(:,:,1);
% x_f1 =  signals_F(:,:,1);
% x    =  x1(:,8); 
% x_f  =  x_f1(:,8);
% FFT(x,x_f,N,fs);
%%
%数据集分割 留出法
% [Idx_Train, Idx_Test] = crossvalind('HoldOut',288, 0.2);
% EEG_Train.x = EEGSignals.x(:,:,Idx_Train);
% EEG_Train.y = EEGSignals.y(Idx_Train);
% EEG_Train.s = EEGSignals.s;
% EEG_Test.x = EEGSignals.x(:,:,Idx_Test);
% EEG_Test.y = EEGSignals.y(Idx_Test);
% EEG_Test.s = EEGSignals.s;
%%
%十折交叉验证法
acca_kappa = zeros(len,2);
indices = crossvalind('Kfold',len,10); %10为交叉验证折数
for ik = 1:10   %实验记进行10次(交叉验证折数)，求10次的平均值作为实验结果，
    Idx_Test = (indices == ik); 
    Idx_Train = ~Idx_Test;  %产生测试集合训练集索引
    EEG_Train.x = EEGSignals.x(:,:,Idx_Train);
    EEG_Train.y = EEGSignals.y(Idx_Train);
    EEG_Train.s = EEGSignals.s;
    EEG_Test.x = EEGSignals.x(:,:,Idx_Test);
    EEG_Test.y = EEGSignals.y(Idx_Test);
    EEG_Test.s = EEGSignals.s;
%%
%空间滤波
classLabels = [1,2,3,4];
CSPMatrix=learnCSP(EEG_Train,classLabels);
%%
%特征提取
nbFilterPairs = 2;  %CSP特征选择参数m  CSP特征为2*m个 可以画完特征点图再来选m
for i = 1:4
    features_train = extractCSP(EEG_Train, CSPMatrix, nbFilterPairs);
    features_test = extractCSP(EEG_Test, CSPMatrix, nbFilterPairs);
end
%%
%SVM
[acc,kappa] = svmFunction(features_train,features_test,EEG_Train,EEG_Test);
acca_kappa(ik,:) = [acc kappa];
end
a_k(:,2*ak-1:2*ak)=acca_kappa(1:10,:);
end
toc