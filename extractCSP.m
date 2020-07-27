function features = extractCSP(EEGSignals, CSPMatrix, nbFilterPairs)
%������
%2020.7.23
%���룺�źŸ�ʽͬ�ϣ�CSP�ռ��˲���cell(4,1)��m����ѡ�����
%�������Ӧ4��CSP������cell(4,1)��ÿ������2m��
nbTrials = size(EEGSignals.x,3);%������
features = cell(4,1);           
features_n = zeros(nbTrials, 2*nbFilterPairs);  %һ��CSP��������
%������ȡ��ѡ��
for i = 1:4
CSPMatrix_n =  CSPMatrix{i};
Filter = CSPMatrix_n([1:nbFilterPairs (end-nbFilterPairs+1):end],:);
for t=1:nbTrials      
    projectedTrial = Filter * EEGSignals.x(:,:,t)';    
    variances = var(projectedTrial,0,2);    
    for f=1:length(variances)
        %features_n(t,f) = log(variances(f));
        features_n(t,f) = log(variances(f)/sum(variances));  %����������
    end
end
    features{i} = features_n;
end


