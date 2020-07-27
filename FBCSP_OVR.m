%张正杰
%2020.7.23
%主程序：实现FBCSP_OVR+SVM分类 
clc;
clear;
load('DATA_OLD/01t.mat'); 
EEGSignal_X  = EEGSignals.x(:,1:22,:);
EEGSignal_y  = EEGSignals.y;
EEGSignals.x = EEGSignal_X;
%%
%分割数据集 留出法
[Idx_Train, Idx_Test] = crossvalind('HoldOut',288, 0.2);
EEG_Train.x = EEGSignal_X(:,:,Idx_Train);
EEG_Train.y = EEGSignal_y(Idx_Train);
EEG_Train.s = EEGSignals.s;
EEG_Test.x = EEGSignal_X(:,:,Idx_Test);
EEG_Test.y = EEGSignal_y(Idx_Test);
EEG_Test.s = EEGSignals.s;
%%
%计算空间滤波器
CSPMatrix_Train=cell(9,1);
EEG_Ftr =cell(9,1);
EEG_Fte =cell(9,1);
classLabels = [1;2;3;4];
dx = 2;
for i = 1 : 9
     fl  = 4*i;
     fh = 4*(i+1);
     Signal_FB_Train= Bpfilters(EEG_Train.x,fl,fh,2);
     EEG_F.x = Signal_FB_Train;
     EEG_F.y = EEG_Train.y;
     EEG_F.s = EEG_Train.s;
     EEG_Ftr{i} = EEG_F;
     CSPMatrix_Train{i,:} = learnCSP(EEG_F,classLabels);
     Signal_FB_Test= Bpfilters(EEG_Test.x,fl,fh,2);
     EEG_F.x = Signal_FB_Test;
     EEG_F.y = EEG_Test.y;
     EEG_F.s = EEG_Test.s;
     EEG_Fte{i} = EEG_F;
end
FilterPairs = 2;       % CSP特征选择参数m  CSP特征为2*m个 可以画完特征点图再来选m
features_train = cell(9,1);
features_test  = cell(9,1);
for j = 1:9
    features_train{j} = extractCSP(EEG_Ftr{i}, CSPMatrix_Train{j,:}, FilterPairs);
    features_test{j} = extractCSP(EEG_Fte{j}, CSPMatrix_Train{j,:}, FilterPairs);
end
%%
%特征提取与选择
numTest = length(EEG_Test.y);
numTrain = length(EEG_Train.y);
Ftrain36=zeros(numTrain,36);
Ftest36=zeros(numTest ,36);
Ftrain_max4 = cell(4,1);
Ftest_max4 = cell(4,1);
numF = 36;
k = 4;
for i = 1 : 4
    for j = 1 : 9
         Ftrain4 = features_train{j ,1}{i ,1 };
         Ftrain36( :,(j-1)*4+1:j*4)=Ftrain4;
         Ftest4 = features_test{j ,1}{i ,1 };
         Ftest36( :,(j-1)*4+1:j*4)=Ftest4;
    end
      Ftrain_max4{i} = Ftrain36;
      Ftest_max4{i} = Ftest36;
%     ytrain = EEG_Train.y;
%     ytrain(EEG_Train.y==i)=1;
%     ytrain(EEG_Train.y~=i)=0;
%     ytest  = EEG_Test.y;
%     ytest(EEG_Test.y==i)=1;
%     ytest(EEG_Test.y~=i)=0;
%     [rankk,w] = mutInfFS(Ftrain36,ytrain,numF);
%     Ftrain_max4{i} = Ftrain36(:,rankk(1:k));
%     [rankk,w] = mutInfFS(Ftest36,ytest,numF);
%     Ftest_max4{i} = Ftest36(:,rankk(1:k));
end
%%
%SVM
[acc,kappa] = svmFunction(Ftrain_max4,Ftest_max4,EEG_Train,EEG_Test);



