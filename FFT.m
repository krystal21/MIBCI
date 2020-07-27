function FFT(x,x_f,N,fs)
%������
%2020.7.23
%�����˲�ǰ��Ĳ���ͼ��Ƶ��ͼ
%�����˲�ǰ���źţ��źų��ȣ��ź�Ƶ��
n1=0:N-1;
x1=x(1:N);
y1=abs(fft(x1)).^2/N;
t1=(0:N/2-1)*fs/N;
figure
subplot(2,2,1)
plot(n1,x1);
xlabel('n');
ylabel('��ֵ');
title('�˲�ǰʱ�źŵĲ���');
 
subplot(2,2,2)
plot(t1,y1(1:N/2));
axis([4 40 0 1000]);
xlabel('f/Hz');
ylabel('|P|^2');
title('�˲�ǰ�������ܶȺ���');


x1=x_f(1:N);
y1=abs(fft(x1)).^2/N;
t1=(0:N/2-1)*fs/N;
subplot(2,2,3)
plot(n1,x1);
xlabel('n');
ylabel('��ֵ');
title('�˲���ʱ�źŵĲ���');
 
subplot(2,2,4)
plot(t1,y1(1:N/2));
axis([4 40 0 1000]);
xlabel('f/Hz');
ylabel('|P|^2');
title('�˲��������ܶȺ���');
end