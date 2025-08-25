% Define the data points
x = [0.12, 1.36]; % 横坐标 (单位: v)
distance = [5, 170]; % 纵坐标 (单位: cm)

% Create the plot
figure;
plot(x, distance, '-o', 'LineWidth', 1.5);
hold on;

% Label the axes
xlabel('x (v)', 'FontSize', 24); % 横坐标增加单位v，字体大小24
ylabel('Distance (cm)', 'FontSize', 24); % 纵坐标字体大小24

% Set the axis limits
xlim([0, 1.5]);
ylim([0, 180]);

% Add a grid
grid on;

% Add title
title('Distance vs x', 'FontSize', 28); % 设置标题字体大小

% Adjust tick labels font size
ax = gca; % 获取当前坐标轴
ax.FontSize = 24; % 设置刻度标签字体大小

% Display the plot
hold off;
