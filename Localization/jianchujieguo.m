% 设置文件夹路径
folderPath = "C:\Users\12865\Desktop\科研\小论文\xlw\实验数据\you"; % 替换为你的文件夹路径
filePattern = fullfile(folderPath, "*.csv"); % 只读取CSV文件
fileList = dir(filePattern); % 获取文件夹中所有CSV文件的列表

% 定义滑轨总长度
L = 160; % 滑轨总长度 (厘米)

% 结果保存路径
outputFilePath = fullfile(folderPath, "横坐标值表.txt");
outputFile = fopen(outputFilePath, 'w'); % 打开文件写入模式

% 遍历文件夹中的每个文件
for fileIdx = 1:length(fileList)
    % 获取当前文件路径
    filePath = fullfile(fileList(fileIdx).folder, fileList(fileIdx).name);
    
    % 加载数据
    data = readtable(filePath, 'VariableNamingRule', 'preserve'); % 保留原始列标题
    if ~ismember('AIN1', data.Properties.VariableNames)
        fprintf('文件 %s 缺少 AIN1 列，跳过。\n', filePath);
        continue;
    end
    
    % 提取 AIN1 列数据
    AIN1 = data.AIN1;

    % 只取前3600个数据点
    num_points = min(3600, length(AIN1)); % 确保数据点不越界
    AIN1 = AIN1(1:num_points);

    % 创建时间轴（以秒为单位）
    time = (0:num_points-1) / 500; % 每500个数据点为1秒

    % 将时间轴转换为空间轴
    space = linspace(0, L, num_points); % 生成空间轴，范围 0 到 160 cm

    % 平滑处理 AIN1
    window_size = 50; % 定义平滑窗口大小
    AIN1_smooth = movmean(AIN1, window_size); % 使用移动平均进行平滑处理

    % 初始化变量
    min_indices = []; % 存储最小值的索引
    min_AIN1_values = []; % 存储最小的 AIN1 值
    remaining_indices = 1:length(AIN1_smooth); % 可选的索引范围

    % 查找所有相隔至少500点的最小值
    while ~isempty(remaining_indices)
        % 找到当前范围内的最小值
        [min_val, min_idx] = min(AIN1_smooth(remaining_indices));
        global_idx = remaining_indices(min_idx); % 全局索引

        % 存储结果
        min_indices = [min_indices; global_idx];
        min_AIN1_values = [min_AIN1_values; min_val];

        % 移除当前最小点及其附近500点范围
        exclude_range = max(1, global_idx - 500):min(length(AIN1_smooth), global_idx + 500);
        remaining_indices = setdiff(remaining_indices, exclude_range);
    end

    % 初始化存储差值的变量
    differences = []; % 存储最大值与最小值的差
    max_values = [];  % 存储最大值
    max_indices = []; % 存储最大值的索引

    % 对每个最小点计算左右100点范围的最大值并求差
    for i = 1:length(min_indices)
        % 定义范围（左右100点）
        range_start = max(1, min_indices(i) - 100); % 确保索引不越界
        range_end = min(length(AIN1_smooth), min_indices(i) + 100);
        range = range_start:range_end;

        % 找到该范围内的最大值及其索引
        [max_val, local_max_idx] = max(AIN1_smooth(range));
        global_max_idx = range(local_max_idx); % 映射到全局索引
        max_values = [max_values; max_val];
        max_indices = [max_indices; global_max_idx];

        % 计算最大值与最小值的差
        diff = max_val - min_AIN1_values(i);
        differences = [differences; diff];
    end

    % 找到差值最大的点
    [~, max_diff_idx] = max(differences); % 获取差值最大的点的索引

    % 差值最大的点的横坐标
    max_diff_position = space(min_indices(max_diff_idx)); % 差值最大的点的横坐标

    % 将横坐标值写入输出文件
    fprintf(outputFile, '%.2f\n', max_diff_position);

    % 打印到控制台
    fprintf('文件 %d: %s 的差值最大点横坐标已保存到文件。\n', fileIdx, filePath);
end

% 关闭文件
fclose(outputFile);

% 打印完成信息
fprintf('所有文件的计算完成！横坐标值已保存到 %s。\n', outputFilePath);
