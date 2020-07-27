function [acc,kappa] = svmFunction(features_train,features_test,EEG_Train,EEG_Test)
%张正杰
%2020.7.23
%训练加测试特征
%输入：训练集，测试集cell(4*1)，每个元组对应一个OVRCSP滤波器滤出的结果
%输出：acc和kappa
% 寻找最佳c/g参数—网格搜索法+交叉验证方法
svmmodel = cell(4,1);
%储存最优参数，可以放到函数里面输出
c4 = zeros(4,1);
g4 = zeros(4,1);
for k = 1:4
[c,g] = meshgrid(-10:0.2:10,-10:0.2:10); %101*101 可根据需要调整
[m,n] = size(c);
cg = zeros(m,n);
eps = 10^(-4);
v = 5;
bestc = 1;
bestg = 0.1;
bestacc = 0;
for i = 1:m
    for j = 1:n
        cmd = ['-v ',num2str(v),' -t 2',' -c ',num2str(2^c(i,j)),' -g ',num2str(2^g(i,j))];
        cg(i,j) = svmtrain(double(EEG_Train.y==k),features_train{k},cmd);     
        if cg(i,j) > bestacc
            bestacc = cg(i,j);
            bestc = 2^c(i,j);
            bestg = 2^g(i,j);
        end        
 
        if abs( cg(i,j)-bestacc )<=eps && bestc > 2^c(i,j) 
            bestacc = cg(i,j);
            bestc = 2^c(i,j);
            bestg = 2^g(i,j);
        end               
    end
end
c4(k)= bestc;
g4(k)= bestg;
cmd = [' -t 2',' -c ',num2str(bestc),' -g ',num2str(bestg)];
%%
%训练SVM模型
    svmmodel{k} = svmtrain(double(EEG_Train.y==k),features_train{k},cmd);
end
%%
%预测
numTest = length(EEG_Test.y);
numLabels = 4;
accuracy = cell(4,1);
decision_value = zeros(numTest,numLabels); %决策值，用于OVR结果融合
predict_label = zeros(numTest,numLabels);  %预测标签
for k=1:numLabels
    [predict_label(:,k), accuracy{k}, decision_value(:,k)]... 
    = svmpredict( double(EEG_Test.y==k), features_test{k},svmmodel{k});
end
%% OVR分类
decision_value_1 = decision_value;  %把决策值统一 决策值的正负和标签对应
for g =1:4
    if svmmodel{g}.Label(1) == 0
        decision_value_1(:,g) = -decision_value(:,g);
    end
end
[~,maxInx]=max(decision_value_1,[],2); %最大的决策值的索引
lab_sum = sum(predict_label,2);
ovr_label = zeros(numTest,1);
for j = 1:numTest
    if lab_sum(j) == 1  %其实这里不用加if可以合在一起，统一后决策值最大值对应输出标签
       ovr_label(j) = find(predict_label(j,:));
    else
       ovr_label(j) = maxInx(j);
    end
end
%便于观察数据，标签放在一起，其实把决策值也加进来更好理解
label_comp = zeros(numTest,7);
comp = EEG_Test.y==ovr_label;
label_comp(:,1:4)=predict_label;
label_comp(:,5)=EEG_Test.y;
label_comp(:,6)=ovr_label;
label_comp(:,7)=double(comp);
%%输出精确度和kappa
rightnum = sum(EEG_Test.y==ovr_label);
acc = rightnum/numTest
kappa = (4*acc-1)/3
%% VI. 绘图
figure
plot(1:length(EEG_Test.y),EEG_Test.y,'r-*')
hold on
plot(1:length(EEG_Test.y),ovr_label,'b:o')
grid on
legend('真实类别','预测类别')
xlabel('测试集样本编号')
ylabel('测试集样本类别')
string = {'测试集SVM预测结果对比(RBF核函数)';
          ['accuracy = ' num2str(acc*100) '%' 'kappa = ' num2str(kappa*100) '%']};
title(string)
