% 设置周期
period = 16.708; 

% 创建时间轴，长度为130
t = 0:0.01:130; % 时间轴从0到130

% 初始化一个向量来保存y值
y = zeros(size(t));

% 根据区间设置不同的y值
for i = 1:length(t)
    % 对每个点在周期内的位置进行分类
    mod_t = mod(t(i), period); % 计算当前点在周期内的位置
    
    if mod_t >= 0 && mod_t < 1
        y(i) = 0.32; % 0到1区间，值为0.32
    elseif mod_t >= 1 && mod_t < 15.708
        y(i) = 2.12; % 1到15.708区间，值为2.12
    elseif mod_t >= 15.708 && mod_t < 16.708
        y(i) = 0.32; % 15.708到16.708区间，值为0.32
    end
end

% 绘制图形
figure;
plot(t, y);
xlabel('Time');
ylabel('Value');
title('Periodic Function');
grid on;
