function [acc,kappa] = svmFunction(features_train,features_test,EEG_Train,EEG_Test)
%������
%2020.7.23
%ѵ���Ӳ�������
%���룺ѵ���������Լ�cell(4*1)��ÿ��Ԫ���Ӧһ��OVRCSP�˲����˳��Ľ��
%�����acc��kappa
% Ѱ�����c/g����������������+������֤����
svmmodel = cell(4,1);
%�������Ų��������Էŵ������������
c4 = zeros(4,1);
g4 = zeros(4,1);
for k = 1:4
[c,g] = meshgrid(-10:0.2:10,-10:0.2:10); %101*101 �ɸ�����Ҫ����
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
%ѵ��SVMģ��
    svmmodel{k} = svmtrain(double(EEG_Train.y==k),features_train{k},cmd);
end
%%
%Ԥ��
numTest = length(EEG_Test.y);
numLabels = 4;
accuracy = cell(4,1);
decision_value = zeros(numTest,numLabels); %����ֵ������OVR����ں�
predict_label = zeros(numTest,numLabels);  %Ԥ���ǩ
for k=1:numLabels
    [predict_label(:,k), accuracy{k}, decision_value(:,k)]... 
    = svmpredict( double(EEG_Test.y==k), features_test{k},svmmodel{k});
end
%% OVR����
decision_value_1 = decision_value;  %�Ѿ���ֵͳһ ����ֵ�������ͱ�ǩ��Ӧ
for g =1:4
    if svmmodel{g}.Label(1) == 0
        decision_value_1(:,g) = -decision_value(:,g);
    end
end
[~,maxInx]=max(decision_value_1,[],2); %���ľ���ֵ������
lab_sum = sum(predict_label,2);
ovr_label = zeros(numTest,1);
for j = 1:numTest
    if lab_sum(j) == 1  %��ʵ���ﲻ�ü�if���Ժ���һ��ͳһ�����ֵ���ֵ��Ӧ�����ǩ
       ovr_label(j) = find(predict_label(j,:));
    else
       ovr_label(j) = maxInx(j);
    end
end
%���ڹ۲����ݣ���ǩ����һ����ʵ�Ѿ���ֵҲ�ӽ����������
label_comp = zeros(numTest,7);
comp = EEG_Test.y==ovr_label;
label_comp(:,1:4)=predict_label;
label_comp(:,5)=EEG_Test.y;
label_comp(:,6)=ovr_label;
label_comp(:,7)=double(comp);
%%�����ȷ�Ⱥ�kappa
rightnum = sum(EEG_Test.y==ovr_label);
acc = rightnum/numTest
kappa = (4*acc-1)/3
%% VI. ��ͼ
figure
plot(1:length(EEG_Test.y),EEG_Test.y,'r-*')
hold on
plot(1:length(EEG_Test.y),ovr_label,'b:o')
grid on
legend('��ʵ���','Ԥ�����')
xlabel('���Լ��������')
ylabel('���Լ��������')
string = {'���Լ�SVMԤ�����Ա�(RBF�˺���)';
          ['accuracy = ' num2str(acc*100) '%' 'kappa = ' num2str(kappa*100) '%']};
title(string)
