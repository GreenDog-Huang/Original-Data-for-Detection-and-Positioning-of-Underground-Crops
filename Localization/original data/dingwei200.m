% 加载数据
data = readtable("C:\Users\12865\Desktop\科研\实验\11.8\y1左-0.95_20241108163339_500.csv"); % 加载CSV文件
AIN1 = data.AIN1; % 提取 AIN1 列数据
AIN2 = data.AIN2; % 提取 AIN2 列数据

% 只取前3600个数据点
num_points = 3600;
AIN1 = AIN1(1:num_points);
AIN2 = AIN2(1:num_points);

% 创建时间轴（以秒为单位）
time = (0:num_points-1) / 500; % 每500个数据点为1秒

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

% 初始化存储差值的变量
differences = []; % 存储最大值与最小值的差
max_values = [];  % 存储最大值

% 对每个最小点计算左右200点范围的最大值并求差
for i = 1:length(min_indices)
    % 定义范围（左右200点）
    range_start = max(1, min_indices(i) - 100); % 确保索引不越界
    range_end = min(length(AIN1_smooth), min_indices(i) + 100);
    range = range_start:range_end;
    
    % 找到该范围内的最大值
    max_val = max(AIN1_smooth(range));
    max_values = [max_values; max_val];
    
    % 计算最大值与最小值的差
    diff = max_val - min_AIN1_values(i);
    differences = [differences; diff];
end

% 找到差值最大的点
[~, max_diff_idx] = max(differences); % 获取差值最大的点的索引

% 绘制平滑后的 AIN1 和处理后的 AIN2
figure;
plot(time, AIN1_smooth, 'r-', 'LineWidth', 3, 'DisplayName', 'have');
hold on;
plot(time, AIN2_processed, 'g-', 'LineWidth', 3, 'DisplayName', 'distance');

% 在图中标记所有最小点和对应范围内的最大值
for i = 1:length(min_indices)
    % 标记最小值
    plot(time(min_indices(i)), min_AIN1_values(i), 'bo', 'MarkerSize', 16, 'LineWidth', 3); % 不添加DisplayName
    
    % 将最小值的文本标注在红线的下方
    text(time(min_indices(i)), min_AIN1_values(i) - 0.05, ...
        sprintf('Minimum: %.4f', min_AIN1_values(i)), ...
        'FontSize', 18, ... % 调整字体大小
        'VerticalAlignment', 'top', 'HorizontalAlignment', 'center'); 
    
    % 标记对应的最大值
    max_idx = find(AIN1_smooth == max_values(i), 1);
    plot(time(max_idx), max_values(i), 'ro', 'MarkerSize', 16, 'LineWidth', 3); % 不添加DisplayName
    
    % 将最大值的文本标注在红线的上方
    text(time(max_idx), max_values(i) + 0.05, ...
        sprintf('Max: %.4f', max_values(i)), ...
        'FontSize', 18, ... % 调整字体大小
        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center');
end

% 标记差值最大的点
plot(time(min_indices(max_diff_idx)), min_AIN1_values(max_diff_idx), 'ms', 'MarkerSize', 16, 'LineWidth', 3, 'DisplayName', 'Max Diff Point');
text(time(min_indices(max_diff_idx)), min_AIN1_values(max_diff_idx) - 0.1, ...
    sprintf('Max Diff: %.4f', differences(max_diff_idx)), ...
    'FontSize', 18, ...
    'VerticalAlignment', 'top', 'HorizontalAlignment', 'center');

% 添加图例和标签
xlabel('Time (s)', 'FontSize', 20); % 设置横坐标标签字体大小
ylabel('Amplitude', 'FontSize', 20); % 设置纵坐标标签字体大小
set(gca, 'FontSize', 18); % 设置坐标轴刻度字体大小
legend('show', 'Location', 'best', 'FontSize', 18); % 设置图例字体大小
grid on;
hold off;

% 显示结果
fprintf('找到的最小点与左右200点范围内最大点的差值：\n');
for i = 1:length(min_indices)
    fprintf('时间 %.2f 秒, 最小值 %.4f, 最大值 %.4f, 差值 %.4f\n', ...
        time(min_indices(i)), min_AIN1_values(i), max_values(i), differences(i));
end

% 输出差值最大的点及其详细信息
fprintf('\n差值最大的点：\n');
fprintf('时间 %.2f 秒, 最小值 %.4f, 最大值 %.4f, 差值 %.4f\n', ...
    time(min_indices(max_diff_idx)), min_AIN1_values(max_diff_idx), max_values(max_diff_idx), differences(max_diff_idx));
