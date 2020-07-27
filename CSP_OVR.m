%������
%2020.7.23
%������ʵ��CSP_OVR+SVM���� 
clc;
clear;
tic
%����9������ʮ�β��Ե�acc��kappa
a_k = zeros(10,18);
for ak = 1:9
%��������
load(['DATA_OLD/0' num2str(ak) 't.mat']);
%����ƴ��
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
EEGSignal_X  = EEGSignals.x(:,1:22,:); %ǰ22ͨ��
EEGSignal_y  = EEGSignals.y;
EEGSignals.x = EEGSignal_X;
len = length(EEGSignals.y);
%%
%�˲�7��30Hz��ͨ�˲�
fl = 7;
fh = 30;
dx = 5;
signals_F = Bpfilters(EEGSignal_X,fl,fh,dx);
EEGSignals.x = signals_F;
%�����˲�Ч������Ƶ��ͼ
% N  = 750;
% fs = 250;
% x1   =  EEGSignal_X(:,:,1);
% x_f1 =  signals_F(:,:,1);
% x    =  x1(:,8); 
% x_f  =  x_f1(:,8);
% FFT(x,x_f,N,fs);
%%
%���ݼ��ָ� ������
% [Idx_Train, Idx_Test] = crossvalind('HoldOut',288, 0.2);
% EEG_Train.x = EEGSignals.x(:,:,Idx_Train);
% EEG_Train.y = EEGSignals.y(Idx_Train);
% EEG_Train.s = EEGSignals.s;
% EEG_Test.x = EEGSignals.x(:,:,Idx_Test);
% EEG_Test.y = EEGSignals.y(Idx_Test);
% EEG_Test.s = EEGSignals.s;
%%
%ʮ�۽�����֤��
acca_kappa = zeros(len,2);
indices = crossvalind('Kfold',len,10); %10Ϊ������֤����
for ik = 1:10   %ʵ��ǽ���10��(������֤����)����10�ε�ƽ��ֵ��Ϊʵ������
    Idx_Test = (indices == ik); 
    Idx_Train = ~Idx_Test;  %�������Լ���ѵ��������
    EEG_Train.x = EEGSignals.x(:,:,Idx_Train);
    EEG_Train.y = EEGSignals.y(Idx_Train);
    EEG_Train.s = EEGSignals.s;
    EEG_Test.x = EEGSignals.x(:,:,Idx_Test);
    EEG_Test.y = EEGSignals.y(Idx_Test);
    EEG_Test.s = EEGSignals.s;
%%
%�ռ��˲�
classLabels = [1,2,3,4];
CSPMatrix=learnCSP(EEG_Train,classLabels);
%%
%������ȡ
nbFilterPairs = 2;  %CSP����ѡ�����m  CSP����Ϊ2*m�� ���Ի���������ͼ����ѡm
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