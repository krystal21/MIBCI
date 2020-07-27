function filtered_signal=Bpfilters(signal,fl,fh,dx)
%张正杰
%2020.7.23
%设计一个切比雪夫二型带通滤波器
%输入：原始信号，通带频率低通和高通，阻带与通带的距离。
%输出：滤波后信号
fs = 250;
wp = [fl-dx  fh+dx] / (fs/2);    %阻带频率
ws = [fl  fh] / (fs/2);           %通带频率
alpha_p = 3;                    %通带允许最大衰减为  db
alpha_s = 40;                   %阻带允许最小衰减为  db
%获取阶数和截止频率
[ N3,wn ] = cheb2ord( wp , ws , alpha_p , alpha_s);
%获得转移函数系数
[ b,a ] = cheby2(N3,alpha_s,wn,'bandpass');
%freqz(b,a)
%滤波
filtered_signal = filter(b,a,signal);
end