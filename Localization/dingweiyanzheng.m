% 设置文件夹路径
folderPath = "C:\Users\12865\Desktop\科研\小论文\xlw\实验数据\11.13 you";
filePattern = fullfile(folderPath, "*.csv"); % 查找所有 .csv 文件
files = dir(filePattern); % 获取文件夹中所有文件

% 参数设置
num_points = 3600; % 每个文件截取的前 3600 个数据点
window_size = 50;  % 平滑窗口大小

% 初始化结果表格
results = table('Size', [length(files), 3], ...
                'VariableTypes', {'string', 'double', 'double'}, ...
                'VariableNames', {'FileName', 'MaxDiffAIN2', 'DValue'});

% 批量处理文件夹中的所有文件
for i = 1:length(files)
    % 获取当前文件路径
    filePath = fullfile(files(i).folder, files(i).name);
    
    % 加载数据文件
    data = readtable(filePath);
    
    % 检查 AIN1 和 AIN2 列是否存在
    if ~ismember('AIN1', data.Properties.VariableNames) || ~ismember('AIN2', data.Properties.VariableNames)
        fprintf('文件 %s 缺少 AIN1 或 AIN2 列，跳过处理。\n', files(i).name);
        continue;
    end
    
    % 提取 AIN1 和 AIN2 数据
    AIN1 = data.AIN1(1:num_points); % 取前 num_points 个数据点
    AIN2 = data.AIN2(1:num_points) / 5; % 取前 num_points 个数据点并除以 5
    
    % 平滑数据
    AIN1_smooth = movmean(AIN1, window_size);
    AIN2_smooth = movmean(AIN2, window_size);

    % 初始化变量
    min_indices = []; % 存储最小值的索引
    min_AIN1_values = []; % 存储最小的 AIN1 值
    remaining_indices = 1:length(AIN1_smooth); % 可选的索引范围

    % 查找所有相隔至少 500 点的最小值
    while ~isempty(remaining_indices)
        [min_val, min_idx] = min(AIN1_smooth(remaining_indices));
        global_idx = remaining_indices(min_idx); % 全局索引
        min_indices = [min_indices; global_idx];
        min_AIN1_values = [min_AIN1_values; min_val];
        exclude_range = max(1, global_idx - 500):min(length(AIN1_smooth), global_idx + 500);
        remaining_indices = setdiff(remaining_indices, exclude_range);
    end

    % 初始化存储差值的变量
    differences = []; % 存储最大值与最小值的差
    max_values = [];  % 存储最大值

    % 对每个最小点计算左右 200 点范围的最大值并求差
    for j = 1:length(min_indices)
        % 定义范围（左右 200 点）
        range_start = max(1, min_indices(j) - 100);
        range_end = min(length(AIN1_smooth), min_indices(j) + 100);
        range = range_start:range_end;
        
        % 找到该范围内的最大值
        max_val = max(AIN1_smooth(range));
        max_values = [max_values; max_val];
        
        % 计算最大值与最小值的差
        diff = max_val - min_AIN1_values(j);
        differences = [differences; diff];
    end

    % 找到差值最大的点
    [~, max_diff_idx] = max(differences);
    max_diff_time = (min_indices(max_diff_idx) - 1) / 500; % 时间点
    ain2_max_diff_value = AIN2_smooth(min_indices(max_diff_idx)); % 对应 AIN2 值
    
    % 根据公式 d ≈ 133.06 * x - 10.97 计算 d 值
    d_value = 133.06 * ain2_max_diff_value - 10.97;

    % 保存结果
    results.FileName(i) = files(i).name;
    results.MaxDiffAIN2(i) = ain2_max_diff_value;
    results.DValue(i) = d_value;

    % 输出当前文件结果
    fprintf('文件: %s\n', files(i).name);
    fprintf('最大差值对应时间: %.2f 秒, AIN2 值: %.4f, D 值: %.4f\n', ...
        max_diff_time, ain2_max_diff_value, d_value);
end

% 移除处理失败的文件记录（空行）
results = results(~cellfun(@isempty, results.FileName), :);

% 将结果保存到文件
outputFile = fullfile(folderPath, "results_AIN2_DValue.csv");
writetable(results, outputFile);
fprintf('处理结果已保存到: %s\n', outputFile);

% 显示完整结果
disp(results);
