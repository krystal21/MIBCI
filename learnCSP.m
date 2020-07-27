function CSPMatrix = learnCSP(EEGSignals,classLabels)
%������
%2020.7.23
%�������źŵ�CSP�ռ��˲���
%���룺�źţ�struct��ʽ x(t*C*N)y(1*N)s=fs������ǩ����[1 2 3 4]
%������ռ��˲�����cell(4,1)��һ�Զ�CSP
nbChannels = size(EEGSignals.x,2);   % ͨ��
nbTrials = size(EEGSignals.x,3);        % ʵ�����
nbClasses = length(classLabels);       % ���
covMatrices = cell(nbClasses,1);        %����CSP����
%% Ϊÿ����������׼����Э�������
trialCov = zeros(nbChannels,nbChannels,nbTrials);
for t=1:nbTrials
    E = EEGSignals.x(:,:,t)';                       %note the transpose
    EE = E * E';
    trialCov(:,:,t) = EE ./ trace(EE);
end
clear E;
clear EE;
%����ÿһ���Э�������
for c=1:nbClasses      
    %EEGSignals.y==classLabels(c) ����һϵ��01
    covMatrices{c} = mean(trialCov(:,:,EEGSignals.y == classLabels(c)),3);  
end
%��Ͽռ�Э�������
covTotal = covMatrices{1} + covMatrices{2} + covMatrices{3} + covMatrices{4};
%����׻�����
[Ut,Dt] = eig(covTotal); 
eig_abs = abs(diag(Dt));
[eig_sort,egIndex] = sort(eig_abs, 'descend');
Ut = Ut(:,egIndex);
P = diag(sqrt(1./eig_sort)) * Ut';
%�����ռ��˲���
%��P�任��һ��Э�������
CSPMatrix = cell(nbClasses,1);   
for i = 1 : 4
S1 =  P * covMatrices{i} * P';
[U1,D1] = eig(S1);
eig_B_abs = abs(diag(D1));
[eig_B,egIndex] = sort(eig_B_abs, 'descend');
U1 = U1(:, egIndex);
CSPMatrix{i} = U1' * P;
end

