function sqi_cal(fname,pname,duration)
%%% This code calculates SQL metrics using Optical Density, Concentration files in xlsx format and
% generates plots and excel files to be saved in the current path,The following
% devices are used in the paper: OctaMon, Brite 23, Brite 24 and OxyMon.
% duration:second of segments to run SQI algorithm on, 10s is used in paper
% oxysoft2matlab、spm12 is needed
%
% reference--------------------------------------------------------------------
% https://www.artinis.com/blogpost-all/2023/assessing-nirs-signal-quality-implementation-of-the-signal-quality-index-sqi
% paper------------------------------------------------------------------------
% https://opg.optica.org/boe/fulltext.cfm?uri=boe-11-11-6732&id=441993


% Read in OD and conc data
od = oxysoft2matlab([pname fname], 'rawOD');
conc = oxysoft2matlab([pname fname], 'oxy/dxy');

% put OD data in variable(s), skip first 10 samples (big spike)
OD1 = od.OD(10:end,1:2:end).';
OD2 = od.OD(10:end,2:2:end).';

% put conc data in variables, skip first 10 samples (big spike)
oxy = conc.oxyvals(10:end,:).';
deoxy = conc.dxyvals(10:end,:).';

% Baseline correction
oxy = bsxfun(@minus, oxy, oxy(:,1));
deoxy = bsxfun(@minus, deoxy, deoxy(:,1));

%% definitions
% get sampling freq
fs = conc.Fs;
fs = floor(fs);
% duration(sec) of segments to run SQI algorithm on
% duration in samples
tSmp = duration*fs;
% SQI threshold value: 1- very bad, 5 - very good quality
thre = 3;

SQI_data.OD1 = struct([]);
SQI_data.oxy = struct([]);
SQI_data.OD2 = struct([]);
SQI_data.dxy = struct([]);
SQI_data.TandS = [];

% here calculate how many segments will you have?
segment = length(OD1(1,:))/(tSmp); % identical for concentrations
% +1 to loop the very last bit of data
if round(segment)<segment
    segment = round(segment)+1;
else
    segment = round(segment);
end

% you will need indexing of each segment time
iSmp = 0:tSmp:(tSmp*segment);
for ss = 1:segment % loop through all segments and channels
    if ss == segment
        % last bit of data
        SQI_data.OD1{end+1}(:,:) = OD1(:, iSmp(ss)+1:end);
        SQI_data.oxy{end+1}(:,:) = oxy(:, iSmp(ss)+1:end);
        SQI_data.OD2{end+1}(:,:) = OD2(:, iSmp(ss)+1:end);
        SQI_data.dxy{end+1}(:,:) = deoxy(:, iSmp(ss)+1:end);
    else
        % iSmp(ss)+1:iSmp(ss+1) - means from the index of
        % current segment ss, to the index of next segment ss+1
        % segment the data into defined duration bins in all trials and append
        SQI_data.OD1{end+1}(:,:) = OD1(:, iSmp(ss)+1:iSmp(ss+1));
        SQI_data.oxy{end+1}(:,:) = oxy(:, iSmp(ss)+1:iSmp(ss+1));
        SQI_data.OD2{end+1}(:,:) = OD2(:, iSmp(ss)+1:iSmp(ss+1));
        SQI_data.dxy{end+1}(:,:) = deoxy(:, iSmp(ss)+1:iSmp(ss+1));
    end
    % save trial index and segment index
    SQI_data.TandS(end+1, :) = [ss];
end

%% Get SQI scores
% can be done on cells, but this is perhaps faster
for seg = 1:length(SQI_data.OD1)
    disp(seg)
    for cc = 1:numel(SQI_data.OD1{1}(:,1))
        SQI_score(cc, seg)= SQI(SQI_data.OD1{seg}(cc,:), SQI_data.OD2{seg}(cc,:),...
            SQI_data.oxy{seg}(cc,:), SQI_data.dxy{seg}(cc,:), fs);
    end
end

%% Plotting each channel and Saving Plots

% Create plots directory if it doesn't exist
if ~exist([ pname 'sqi_plots/' fname(1:end-5)], 'dir')
    mkdir([pname 'sqi_plots/' fname(1:end-5)])
end

for channel = 1:size(OD1, 1)
    score = repelem(SQI_score(channel,:), fs*duration);
    score = score(1:length(OD1));
    
   

    % Create a figure for each channel
    % figure('WindowState', 'maximized');
    
    x = [1:length(oxy(channel, :))]/fs;
    
    % Plot oxy and deoxy data
    yyaxis left
    plot(x,oxy(channel, :), 'r', 'DisplayName', 'Oxyhemoglobin');
    hold on;
    plot(x,deoxy(channel, :), 'b', 'LineStyle', '-', 'DisplayName', 'Deoxyhemoglobin');
    ylabel('Concentration Change');
    ax = gca; % Get current axes
    ax.YColor = 'k'; % Set left y-axis color to black
    xlim([min(x) max(x)]);

    % Plot SQI score
    yyaxis right
    plot(x,score, 'k', 'LineWidth', 2, 'DisplayName', 'SQI Score'); % Thick black line
    ylim([0 6]);
    ylabel('SQI Score');
    ax.YColor = 'k'; % Set right y-axis color to black

    % Set title and legend
    title(conc.label(channel));
    legend;
    xlabel('Time/s');
    set(gcf, 'WindowState', 'maximized');
    
    % Save the figure with high DPI and using the channel label as filename
    saveas(gcf, fullfile([pname 'sqi_plots/' fname(1:end-5)], sprintf('%s.png', strrep(conc.label{channel}, '/', '_'))), 'png');
    hold off;
     clf;
end

%% Plotting all channel and Saving Plots

yticklabelscontent={};
for i = 1:2:size(conc.Rx_TxId,2)
    yticklabelscontent{end+1} =['Rx' num2str(conc.Rx_TxId(1,i)) ' - Tx' num2str(conc.Rx_TxId(2,i))];
end

% plot
imagesc(SQI_score);
colormap("autumn");
colormap(gray);
c = colorbar;
c.LineWidth=1;
c.FontSize=13;
c.TickLength=[0 0];

xlabel('Segment');
ylabel('Channel');
yticks(1:size(conc.Rx_TxId,2)/2);
yticklabels(yticklabelscontent);
title('SQI Score');
set(gca, 'LineWidth', 1,'FontSize',13,'TickLength',[0 0]);
set(gcf, 'WindowState', 'maximized');

saveas(gcf, fullfile([pname 'sqi_plots/'], sprintf([fname(1:end-5) '.png'], 'png')));
close;

%% save as xlsx

cell_SQIscore = num2cell(SQI_score');

d2 = [num2cell(1:size(cell_SQIscore,1))',cell_SQIscore];
head={};
for i = 1:2:size(conc.Rx_TxId,2)
    head{end+1} =['Rx' num2str(conc.Rx_TxId(1,i)) '_Tx' num2str(conc.Rx_TxId(2,i))];
end
head = [{'block'},head];
T = cell2table(d2, 'VariableNames', head);
writetable(T, [pname 'sqi_plots\' fname(1:end-5) '.xlsx']);
