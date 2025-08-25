% 定义文件夹路径
folder1 = "C:\Users\12865\Desktop\科研\小论文\xlw\实验数据\定位\original\yousun"; % 文件夹1路径
folder2 = "C:\Users\12865\Desktop\科研\小论文\xlw\实验数据\定位\original\wusun"; % 文件夹2路径

% 获取文件夹中的所有CSV文件
files1 = dir(fullfile(folder1, '*.csv'));
files2 = dir(fullfile(folder2, '*.csv'));

% 初始化存储第二个最小点值和斜率的结果
data1 = []; % 文件夹1的结果
data2 = []; % 文件夹2的结果

% 定义平滑窗口大小
window_size = 10;

% 处理文件夹1
for file = files1'
    % 读取CSV文件
    data = readtable(fullfile(file.folder, file.name));
    AIN1 = data.AIN1;
    AIN2 = data.AIN2;
    
    % 平滑处理 AIN1
    AIN1_smooth = movmean(AIN1, window_size);
    
    % 计算斜率
    slopes = diff(AIN1_smooth);
    slopes = [slopes; slopes(end)];
    
    % 找到三个相隔至少500点的最小值
    min_indices = [];
    remaining_indices = 1:length(AIN1_smooth);
    for i = 1:3
        [min_val, min_idx] = min(AIN1_smooth(remaining_indices));
        global_idx = remaining_indices(min_idx);
        min_indices = [min_indices; global_idx];
        exclude_range = max(1, global_idx - 500):min(length(AIN1_smooth), global_idx + 500);
        remaining_indices = setdiff(remaining_indices, exclude_range);
    end
    
    % 获取第二个最小点的值和斜率
    second_min_idx = min_indices(2);
    second_min_value = AIN1_smooth(second_min_idx);
    second_min_slope = slopes(second_min_idx);
    
    % 存储结果
    data1 = [data1; second_min_value, second_min_slope];
end

% 处理文件夹2
for file = files2'
    % 读取CSV文件
    data = readtable(fullfile(file.folder, file.name));
    AIN1 = data.AIN1;
    AIN2 = data.AIN2;
    
    % 平滑处理 AIN1
    AIN1_smooth = movmean(AIN1, window_size);
    
    % 计算斜率
    slopes = diff(AIN1_smooth);
    slopes = [slopes; slopes(end)];
    
    % 找到三个相隔至少500点的最小值
    min_indices = [];
    remaining_indices = 1:length(AIN1_smooth);
    for i = 1:3
        [min_val, min_idx] = min(AIN1_smooth(remaining_indices));
        global_idx = remaining_indices(min_idx);
        min_indices = [min_indices; global_idx];
        exclude_range = max(1, global_idx - 500):min(length(AIN1_smooth), global_idx + 500);
        remaining_indices = setdiff(remaining_indices, exclude_range);
    end
    
    % 获取第二个最小点的值和斜率
    second_min_idx = min_indices(2);
    second_min_value = AIN1_smooth(second_min_idx);
    second_min_slope = slopes(second_min_idx);
    
    % 存储结果
    data2 = [data2; second_min_value, second_min_slope];
end

% 合并两组数据
all_data = [data1; data2];

% k-means 聚类
k = 2; % 聚类数
[idx, centroids] = kmeans(all_data, k);

% 绘制聚类结果
figure;
scatter(data1(:, 2), data1(:, 1), 50, idx(1:size(data1, 1)), 'filled'); % 文件夹1
hold on;
scatter(data2(:, 2), data2(:, 1), 50, idx(size(data1, 1)+1:end), 'filled'); % 文件夹2
plot(centroids(:, 2), centroids(:, 1), 'kx', 'LineWidth', 2, 'MarkerSize', 10); % 聚类中心

% 图形设置
title('k-means 聚类结果');
xlabel('斜率');
ylabel('值');
legend('文件夹1', '文件夹2', '聚类中心');
grid on;
hold off;
