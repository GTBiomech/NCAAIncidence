clc;clear;
%% Load Excel Data
data = readtable('Incidence_F1000.xlsx');

%% Extract Relevant Columns
matches = data.MATCH; 
players = unique(data.DEVICE_SN); 
PLA = data.PLA; 
PAA = data.PAA; 
group = unique(data.POSITION_GROUP);

UniqueMatches = length(data.MATCH);
UniquePlayers = length(unique(data.DEVICE_SN));
UniquePlayerMatches = numel(unique(strcat(string(data.DEVICE_SN), "_", string(data.MATCH))));

%% Define Thresholds
PLA_thresholds = linspace(min(PLA), max(PLA), 500);
PAA_thresholds = linspace(min(PAA), max(PAA), 500);

%% Initialize Results
mean_incidence_PLA = zeros(length(group), length(PLA_thresholds));
ci_lower_PLA = zeros(length(group), length(PLA_thresholds));
ci_upper_PLA = zeros(length(group), length(PLA_thresholds));

mean_incidence_PAA = zeros(length(group), length(PAA_thresholds));
ci_lower_PAA = zeros(length(group), length(PAA_thresholds));
ci_upper_PAA = zeros(length(group), length(PAA_thresholds));

num_bootstraps = 2500;

%% Compute Mean Incidence and Bootstrap CI for PLA for each group
for g = 1:length(group)
    group_data = data(ismember(data.POSITION_GROUP, group(g)), :);  % Filter data for current group
    group_players = unique(group_data.DEVICE_SN);
    
    for i = 1:length(PLA_thresholds)
        selected = PLA >= PLA_thresholds(i);
        incidence_per_player = arrayfun(@(p) sum(selected(group_data.DEVICE_SN == p)) / numel(unique(group_data.MATCH(group_data.DEVICE_SN == p))), group_players);
        mean_incidence_PLA(g, i) = mean(incidence_per_player);
        
        % Bootstrap resampling
        bootstrap_samples = zeros(num_bootstraps, 1);
        for b = 1:num_bootstraps
            resampled = incidence_per_player(randi(numel(incidence_per_player), numel(incidence_per_player), 1));
            bootstrap_samples(b) = mean(resampled);
        end
        
        % Compute statistics
        ci_lower_PLA(g, i) = prctile(bootstrap_samples, 2.5);
        ci_upper_PLA(g, i) = prctile(bootstrap_samples, 97.5);
    end
end

%% Compute Mean Incidence and Bootstrap CI for PAA for each group
for g = 1:length(group)
    group_data = data(ismember(data.POSITION_GROUP, group(g)), :);  % Filter data for current group
    group_players = unique(group_data.DEVICE_SN);
    
    for i = 1:length(PAA_thresholds)
        selected = PAA >= PAA_thresholds(i);
        incidence_per_player = arrayfun(@(p) sum(selected(group_data.DEVICE_SN == p)) / numel(unique(group_data.MATCH(group_data.DEVICE_SN == p))), group_players);
        mean_incidence_PAA(g, i) = mean(incidence_per_player);
        
        % Bootstrap resampling
        bootstrap_samples = zeros(num_bootstraps, 1);
        for b = 1:num_bootstraps
            resampled = incidence_per_player(randi(numel(incidence_per_player), numel(incidence_per_player), 1));
            bootstrap_samples(b) = mean(resampled);
        end
        
        % Compute statistics
        ci_lower_PAA(g, i) = prctile(bootstrap_samples, 2.5);
        ci_upper_PAA(g, i) = prctile(bootstrap_samples, 97.5);
    end
end


%% Plot Incidence vs PLA for each group
figure; subplot(1,2,1) ; hold on;
colors = lines(length(group)); % Distinct colors for each group
for g = 1:length(group)
    x = [PLA_thresholds, fliplr(PLA_thresholds)];
    y = [ci_lower_PLA(g, :), fliplr(ci_upper_PLA(g, :))];
    fill(x, y, colors(g, :), 'FaceAlpha', 0.3, 'EdgeColor', 'none'); % Shaded region
    plot(PLA_thresholds, mean_incidence_PLA(g, :), 'Color', colors(g, :), 'LineWidth', 2); % Mean line
end
xlabel('PLA Threshold (g)');
ylabel('HAE Incidence per Player Match');
grid on;
legend('','Defense','','Offense', 'Location', 'northeast');
xlim([5 45])
hold off;

%% Plot Incidence vs PAA for each group
subplot(1,2,2) ; hold on;
for g = 1:length(group)
    x = [PAA_thresholds, fliplr(PAA_thresholds)];
    y = [ci_lower_PAA(g, :), fliplr(ci_upper_PAA(g, :))];
    fill(x, y, colors(g, :), 'FaceAlpha', 0.3, 'EdgeColor', 'none'); % Shaded region
    plot(PAA_thresholds, mean_incidence_PAA(g, :), 'Color', colors(g, :), 'LineWidth', 2); % Mean line
end
xlabel('PAA Threshold (krad/s^2)');
ylabel('HAE Incidence per Player Match');
grid on;
legend('','Defense','','Offense', 'Location', 'northeast');
xlim([0.4 2.5])
hold off;



