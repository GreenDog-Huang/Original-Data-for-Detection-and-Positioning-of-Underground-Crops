clc; clear;

% 1. 设计低通滤波器
fc_low = 8; % 截止频率
fs = 100; % 采样频率
[b_low, a_low] = butter(5, fc_low/(fs/2)); % 5阶巴特沃斯低通滤波器

% 2. 读取第一个文件夹的数据
folderPath = [pwd,'\original\wusun_Train'];
filePattern = fullfile(folderPath, '*.csv');
csvFiles = dir(filePattern);

for file_num = 1:length(csvFiles)
    fullFileName = fullfile(folderPath, csvFiles(file_num).name);
    data = readtable(fullFileName);
    DS = data.AIN1;
    DS_low = filter(b_low, a_low, DS);
    F_vactor1(1, file_num) = mean(DS_low(10:end));
    F_vactor1(2, file_num) = std(DS_low(10:end));
end

% 3. 读取第二个文件夹的数据
folderPath = [pwd,'\original\yousun_Train'];
filePattern = fullfile(folderPath, '*.csv');
csvFiles = dir(filePattern);

for file_num = 1:length(csvFiles)
    fullFileName = fullfile(folderPath, csvFiles(file_num).name);
    data = readtable(fullFileName);
    DS1 = data.AIN1;
    DS1_low = filter(b_low, a_low, DS1);
    F_vactor2(1, file_num) = mean(DS1_low(10:end));
    F_vactor2(2, file_num) = std(DS1_low(10:end));
end

% 4. 合并数据
F_vactorT = [F_vactor1, F_vactor2];

% 5. 使用统计方法自动剔除异常值
% 5.1 3σ 法则
mean_values = mean(F_vactorT, 2);
std_values = std(F_vactorT, 0, 2);
valid_idx_3sigma = all(abs(F_vactorT - mean_values) < 3 * std_values, 1);

% 5.2 箱线图法（IQR）
Q1 = quantile(F_vactorT, 0.25, 2);
Q3 = quantile(F_vactorT, 0.75, 2);
IQR = Q3 - Q1;
valid_idx_iqr = all((F_vactorT >= Q1 - 1.5 * IQR) & (F_vactorT <= Q3 + 1.5 * IQR), 1);

% 5.3 结合 3σ 和 IQR 条件
valid_idx = valid_idx_3sigma & valid_idx_iqr;
F_vactorT_filtered = F_vactorT(:, valid_idx);

fprintf('Removed Points (Outliers):\n');
disp(F_vactorT(:, ~valid_idx));

% 6. K-means 聚类
[IDX, C] = kmeans(F_vactorT_filtered', 2);

% 7. 可视化结果
figure;
plot(F_vactor1(1,:), F_vactor1(2,:), 'r*', 'MarkerSize', 24); hold on; % 原始数据 F_vactor1
plot(F_vactor2(1,:), F_vactor2(2,:), 'bo', 'MarkerSize', 24); hold on; % 原始数据 F_vactor2
plot(C(:,1), C(:,2), 'kp', 'MarkerSize', 24, 'MarkerFaceColor', 'y', 'LineWidth', 3); % 聚类中心

% 图形设置
legend('F\_vactor1 ', 'F\_vactor2 ', 'Cluster Centers');
xlabel('Mean', 'FontSize', 26, 'FontWeight', 'bold'); 
ylabel('Standard Deviation', 'FontSize', 26, 'FontWeight', 'bold');
title('Filtered Data with Statistical Outlier Removal and K-means Clustering', 'FontSize', 26, 'FontWeight', 'bold'); % Set the title font size and weight
set(gca, 'FontSize', 26, 'FontWeight', 'bold'); % 设置坐标轴字体大小
grid on;

% 设置坐标数字字体大小
ax = gca;
ax.XAxis.FontSize = 26;
ax.YAxis.FontSize = 26;
