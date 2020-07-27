function features = extractCSP(EEGSignals, CSPMatrix, nbFilterPairs)
%张正杰
%2020.7.23
%输入：信号格式同上，CSP空间滤波器cell(4,1)，m特征选择参数
%输出：对应4个CSP的特征cell(4,1)，每次任务2m个
nbTrials = size(EEGSignals.x,3);%任务数
features = cell(4,1);           
features_n = zeros(nbTrials, 2*nbFilterPairs);  %一个CSP出的特征
%特征提取加选择
for i = 1:4
CSPMatrix_n =  CSPMatrix{i};
Filter = CSPMatrix_n([1:nbFilterPairs (end-nbFilterPairs+1):end],:);
for t=1:nbTrials      
    projectedTrial = Filter * EEGSignals.x(:,:,t)';    
    variances = var(projectedTrial,0,2);    
    for f=1:length(variances)
        %features_n(t,f) = log(variances(f));
        features_n(t,f) = log(variances(f)/sum(variances));  %对数防波动
    end
end
    features{i} = features_n;
end


