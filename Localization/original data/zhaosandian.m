% 读取数据
data = readtable("C:\Users\12865\Desktop\科研\小论文\xlw\实验数据\定位\original\yousun\you_20241113162929_500.csv"); % 加载CSV文件
AIN1 = data.AIN1; % 提取 AIN1 列数据
AIN2 = data.AIN2; % 提取 AIN2 列数据

% 平滑处理 AIN1 和 AIN2
window_size = 50; % 定义平滑窗口大小
AIN1_smooth = movmean(AIN1, window_size); % 使用移动平均进行平滑处理
AIN2_smooth = movmean(AIN2, window_size); % 使用移动平均进行平滑处理

% 处理 AIN2：每个值除以5
AIN2_processed = AIN2 / 5;

% 初始化变量
min_indices = []; % 存储最小值的索引
min_AIN1_values = []; % 存储最小的 AIN1 值
corresponding_AIN2_values = []; % 存储对应的 AIN2 值
remaining_indices = 1:length(AIN1_smooth); % 可选的索引范围

% 查找所有相隔至少500点的最小值
while ~isempty(remaining_indices)
    % 找到当前范围内的最小值
    [min_val, min_idx] = min(AIN1_smooth(remaining_indices));
    global_idx = remaining_indices(min_idx); % 全局索引
    
    % 存储结果
    min_indices = [min_indices; global_idx];
    min_AIN1_values = [min_AIN1_values; min_val];
    corresponding_AIN2_values = [corresponding_AIN2_values; AIN2_processed(global_idx)];
    
    % 移除当前最小点及其附近500点范围
    exclude_range = max(1, global_idx - 500):min(length(AIN1_smooth), global_idx + 500);
    remaining_indices = setdiff(remaining_indices, exclude_range);
end

% 计算平滑后 AIN1 的斜率（差分法）
slopes = diff(AIN1_smooth); % 差分计算斜率
slopes = [slopes; slopes(end)]; % 补充最后一个斜率值以匹配数据长度

% 绘制平滑后的 AIN1 和处理后的 AIN2
figure;
plot(1:length(AIN1_smooth), AIN1_smooth, 'r-', 'LineWidth', 1.5, 'DisplayName', '平滑后的 AIN1');
hold on;
plot(1:length(AIN2_processed), AIN2_processed, 'g-', 'LineWidth', 1.2, 'DisplayName', 'AIN2 / 5');

% 在图中标记所有最小点
for i = 1:length(min_indices)
    plot(min_indices(i), min_AIN1_values(i), 'bo', 'MarkerSize', 8, 'LineWidth', 1.5, 'DisplayName', sprintf('最小AIN1-%d', i));
    text(min_indices(i), min_AIN1_values(i), ...
        sprintf('AIN1: %.4f\nAIN2: %.4f', min_AIN1_values(i), corresponding_AIN2_values(i)), ...
        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
end

% 添加图例和标签
title('平滑后的 AIN1 和 AIN2 (/5) 数据对比');
xlabel('数据点索引');
ylabel('值');
legend('show');
grid on;
hold off;

% 显示结果
for i = 1:length(min_indices)
    slope_at_min = slopes(min_indices(i)); % 获取当前点的斜率
    fprintf('第 %d 个最小的平滑后 AIN1 值为 %.4f，对应的 AIN2 (/5) 值为 %.4f，索引为 %d，斜率为 %.4f。\n', ...
        i, min_AIN1_values(i), corresponding_AIN2_values(i), min_indices(i), slope_at_min);
end
