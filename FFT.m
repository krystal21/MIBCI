function FFT(x,x_f,N,fs)
%张正杰
%2020.7.23
%做出滤波前后的波形图和频谱图
%输入滤波前后信号，信号长度，信号频率
n1=0:N-1;
x1=x(1:N);
y1=abs(fft(x1)).^2/N;
t1=(0:N/2-1)*fs/N;
figure
subplot(2,2,1)
plot(n1,x1);
xlabel('n');
ylabel('幅值');
title('滤波前时信号的波形');
 
subplot(2,2,2)
plot(t1,y1(1:N/2));
axis([4 40 0 1000]);
xlabel('f/Hz');
ylabel('|P|^2');
title('滤波前功率谱密度函数');


x1=x_f(1:N);
y1=abs(fft(x1)).^2/N;
t1=(0:N/2-1)*fs/N;
subplot(2,2,3)
plot(n1,x1);
xlabel('n');
ylabel('幅值');
title('滤波后时信号的波形');
 
subplot(2,2,4)
plot(t1,y1(1:N/2));
axis([4 40 0 1000]);
xlabel('f/Hz');
ylabel('|P|^2');
title('滤波后功率谱密度函数');
end