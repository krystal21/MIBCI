function CSPMatrix = learnCSP(EEGSignals,classLabels)
%张正杰
%2020.7.23
%求四类信号的CSP空间滤波器
%输入：信号（struct格式 x(t*C*N)y(1*N)s=fs），标签类型[1 2 3 4]
%输出：空间滤波器组cell(4,1)存一对多CSP
nbChannels = size(EEGSignals.x,2);   % 通道
nbTrials = size(EEGSignals.x,3);        % 实验次数
nbClasses = length(classLabels);       % 类别
covMatrices = cell(nbClasses,1);        %储存CSP矩阵
%% 为每个试验计算标准化的协方差矩阵。
trialCov = zeros(nbChannels,nbChannels,nbTrials);
for t=1:nbTrials
    E = EEGSignals.x(:,:,t)';                       %note the transpose
    EE = E * E';
    trialCov(:,:,t) = EE ./ trace(EE);
end
clear E;
clear EE;
%计算每一类的协方差矩阵
for c=1:nbClasses      
    %EEGSignals.y==classLabels(c) 返回一系列01
    covMatrices{c} = mean(trialCov(:,:,EEGSignals.y == classLabels(c)),3);  
end
%混合空间协方差矩阵
covTotal = covMatrices{1} + covMatrices{2} + covMatrices{3} + covMatrices{4};
%计算白化矩阵
[Ut,Dt] = eig(covTotal); 
eig_abs = abs(diag(Dt));
[eig_sort,egIndex] = sort(eig_abs, 'descend');
Ut = Ut(:,egIndex);
P = diag(sqrt(1./eig_sort)) * Ut';
%构建空间滤波器
%用P变换第一类协方差矩阵
CSPMatrix = cell(nbClasses,1);   
for i = 1 : 4
S1 =  P * covMatrices{i} * P';
[U1,D1] = eig(S1);
eig_B_abs = abs(diag(D1));
[eig_B,egIndex] = sort(eig_B_abs, 'descend');
U1 = U1(:, egIndex);
CSPMatrix{i} = U1' * P;
end

