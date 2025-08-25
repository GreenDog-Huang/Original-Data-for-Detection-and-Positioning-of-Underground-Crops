% 假设数据
total_distance = 130;  % 总距离130cm
distance_per_magnet = 1;  % 每次磁铁经过时车轮移动1cm
AIN2_value = repmat([2.12, 0.32], 1, total_distance);  % 电压值交替变化
index = 0:(2*total_distance-1);  % 每次磁铁经过的索引（总共记录两次）

% 计算横轴为距离
distance = index * distance_per_magnet;  % 将索引转换为对应的距离（单位：cm）

% 绘制电压变化的关系图
figure;
plot(distance, AIN2_value, 'b-', 'LineWidth', 2);
title('AIN 2 Curve');
xlabel('Distance (cm)');
ylabel('AIN 2 Value (V)');
grid on;
legend('AIN 2');
