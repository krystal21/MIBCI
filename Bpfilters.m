function filtered_signal=Bpfilters(signal,fl,fh,dx)
%������
%2020.7.23
%���һ���б�ѩ����ʹ�ͨ�˲���
%���룺ԭʼ�źţ�ͨ��Ƶ�ʵ�ͨ�͸�ͨ�������ͨ���ľ��롣
%������˲����ź�
fs = 250;
wp = [fl-dx  fh+dx] / (fs/2);    %���Ƶ��
ws = [fl  fh] / (fs/2);           %ͨ��Ƶ��
alpha_p = 3;                    %ͨ���������˥��Ϊ  db
alpha_s = 40;                   %���������С˥��Ϊ  db
%��ȡ�����ͽ�ֹƵ��
[ N3,wn ] = cheb2ord( wp , ws , alpha_p , alpha_s);
%���ת�ƺ���ϵ��
[ b,a ] = cheby2(N3,alpha_s,wn,'bandpass');
%freqz(b,a)
%�˲�
filtered_signal = filter(b,a,signal);
end