function info = muteinf(A, Y)
n = size(A,1);%ʵ������
Z = [A Y];%����ʵ����ά��ֵ����ǩ
nbins = max(floor(n/10),10);%��������ĸ���
pA = hist(A, nbins);%min(A)��max(A)���ֳ�nbins�������������ÿ������ĸ���
pA = pA ./ n;%����ʵ������
i = find(pA == 0);
pA(i) = 0.00001;%����ʹĳһ����ĸ���Ϊ0
od = size(Y,2);%һ��ά��
%��������ʵ����ͬ��ǩ�ĵĸ���ֵ��Ҳ����Ƶ��
pY = [length(find(Y==1)) length(find(Y==0)) ] / n;
cl = 2;
p = zeros(cl,nbins);
rx = abs(max(A) - min(A)) / nbins;%ÿ�����䳤��
for i = 1:cl
    xl = min(A);%�������½�
    for j = 1:nbins
        if(i == 2) 
            interval = (xl <= Z(:,1)) & (Z(:,2) == -1);
        else
            interval = (xl <= Z(:,1)) & (Z(:,i+1) == +1);
        end
        if(j < nbins)
            interval = interval & (Z(:,1) < xl + rx);
        end
        %find(interval)
        p(i,j) = length(find(interval));
        
        if p(i,j) == 0 % hack!
            p(i,j) = 0.00001;
        end
        
        xl = xl + rx;
    end
end
HA = -sum(pA .* log(pA));%���㵱ǰά�ȵ���Ϣ��
HY = -sum(pY .* log(pY));%�����ǩ����Ϣ��
pA = repmat(pA,cl,1);
pY = repmat(pY',1,nbins);
p = p ./ n;
info = sum(sum(p .* log(p ./ (pA .* pY))));
info = 2 * info ./ (HA + HY);%���㻥��Ϣ