clc;
clear ;
%%设计滤波器
fc_low = 8; % 截止频率（低通滤波器）
fs = 100; % 采样频率
[b_low, a_low] = butter(5, fc_low/(fs/2)); % 5阶巴特沃斯低通滤波器

% 指定包含 CSV 文件的文件夹路径
folderPath = ['C:\Users\12865\Desktop\科研\小论文\xlw\' ...
    '实验数据\20241214data_process\original\wusun_Train']; % 替换为你的文件夹路径
filePattern = fullfile(folderPath, '*.csv'); % 匹配文件夹中的所有 CSV 文件
csvFiles = dir(filePattern); % 获取所有匹配的文件列表
for file_num=1:length(csvFiles)
    % 获取当前文件的文件名和完整路径
    baseFileName = csvFiles(file_num).name;
    fullFileName = fullfile(folderPath, baseFileName);
        
    % 读取当前 CSV 文件
    data = readtable(fullFileName);
    DS= data.AIN1; % 提取 'AIN1' 列数据

    
    % 滤波处理
    DS_low = filter(b_low, a_low, DS); % 低通滤波后的信号
    F_vactor1(1,file_num)=mean(DS_low(10:end));
    F_vactor1(2,file_num)=std(DS_low(10:end));
    % E1_band = filter(b_band, a_band, E.AIN1); % 带通滤波后的信号
    % E2_band = filter(b_band, a_band, E.AIN2);
    % plot(DS_low,'b');hold on;
end
% 指定包含 CSV 文件的文件夹路径
folderPath = ['C:\Users\12865\Desktop\科研\小论文\xlw\实验数据' ...
    '\20241214data_process\original\yousun_Train']; % 替换为你的文件夹路径
filePattern = fullfile(folderPath, '*.csv'); % 匹配文件夹中的所有 CSV 文件
csvFiles = dir(filePattern); % 获取所有匹配的文件列表
loop=1;
for file_num=1:length(csvFiles)
    % 获取当前文件的文件名和完整路径
    baseFileName = csvFiles(file_num).name;
    fullFileName = fullfile(folderPath, baseFileName);
        
    % 读取当前 CSV 文件
    data = readtable(fullFileName);
    DS1= data.AIN1; % 提取 'AIN1' 列数据
    DS1_low = filter(b_low, a_low, DS1); % 低通滤波后的信号
    if std(DS1_low(10:end))>0.1||mean(DS1_low(10:end))<0.94
        figure(10)
        plot(DS1_low);hold on;
        disp error;
        continue;
    end
    F_vactor2(1,loop)=mean(DS1_low(10:end));
    F_vactor2(2,loop)=std(DS1_low(10:end));
    loop=loop+1;

end
F_vactorT=[F_vactor1,F_vactor2];
[IDX, C]=kmeans(F_vactorT',2);
[center,U,obj_fcn]=fcm(F_vactorT',2);
figure(11);
plot(F_vactor1(1,:),F_vactor1(2,:),'r*');hold on;
plot(F_vactor2(1,:),F_vactor2(2,:),'bo');hold on;
plot(C(1,1),C(1,2),'gv');hold on;
plot(C(2,1),C(2,2),'kv');hold on;
Have_FV=[C(1,1),C(1,2)];
No_FV=[C(2,1),C(2,2)];
folderPath = ['C:\Users\12865\Desktop\科研\小论文\xlw\实验数据' ...
    '\20241214data_process\original\wusun_test']; % 替换为你的文件夹路径
filePattern = fullfile(folderPath, '*.csv'); % 匹配文件夹中的所有 CSV 文件
csvFiles = dir(filePattern); % 获取所有匹配的文件列表
Have_SUN=[];
for file_num=1:length(csvFiles)
    % 获取当前文件的文件名和完整路径
    baseFileName = csvFiles(file_num).name;
    fullFileName = fullfile(folderPath, baseFileName);
        
    % 读取当前 CSV 文件
    data = readtable(fullFileName);
    DS1= data.AIN1; % 提取 'AIN1' 列数据
    DS1_low = filter(b_low, a_low, DS1); % 低通滤波后的信号
    F_vactor_test=[mean(DS1_low(10:end)),std(DS1_low(10:end))];
    if norm(Have_FV-F_vactor_test)>norm(No_FV-F_vactor_test)
        Have_SUN=[Have_SUN,false];
    else
        Have_SUN=[Have_SUN,true];
    end
    clear data DS1 DS1_low;
end
folderPath = ['C:\Users\12865\Desktop\科研\小论文\xlw\实验数据' ...
    '\20241214data_process\original\yousun_test']; % 替换为你的文件夹路径
filePattern = fullfile(folderPath, '*.csv'); % 匹配文件夹中的所有 CSV 文件
csvFiles = dir(filePattern); % 获取所有匹配的文件列表
for file_num=1:length(csvFiles)
    % 获取当前文件的文件名和完整路径
    baseFileName = csvFiles(file_num).name;
    fullFileName = fullfile(folderPath, baseFileName);
        
    % 读取当前 CSV 文件
    data = readtable(fullFileName);
    DS1= data.AIN1; % 提取 'AIN1' 列数据
    DS1_low = filter(b_low, a_low, DS1); % 低通滤波后的信号
    F_vactor_test=[mean(DS1_low(10:end)),std(DS1_low(10:end))];
    if norm(Have_FV-F_vactor_test)>norm(No_FV-F_vactor_test)
        Have_SUN=[Have_SUN,false];
    else
        Have_SUN=[Have_SUN,true];
    end
    clear data DS1 DS1_low;
end
