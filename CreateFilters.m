
function filters = CreateFilters()

%% Create Directional Gaussian Filters
sizeOfMatrix = 9;
mu = 0;
sd = 0.5;

x = -1:0.25:1; %covers more than 99% of the curve
gaussNumbers = pdf('normal', x, mu, sd);


%% 
filters.deg_0 = zeros(sizeOfMatrix,sizeOfMatrix);
filters.deg_0((sizeOfMatrix+1)/2,:) = gaussNumbers;

%% 
filters.deg_30 = zeros(sizeOfMatrix,sizeOfMatrix);
filters.deg_30(7,1:2) = gaussNumbers(1:2);
filters.deg_30(6,2:4) = gaussNumbers(2:4);
filters.deg_30(5,4:6) = gaussNumbers(4:6);
filters.deg_30(4,6:8) = gaussNumbers(6:8);
filters.deg_30(4,6:8) = gaussNumbers(6:8);
filters.deg_30(3,8:9) = gaussNumbers(8:9);


filters.deg_60 = filters.deg_30';
filters.deg_90 = filters.deg_0';
filters.deg_120 = fliplr(filters.deg_60);
filters.deg_150 = fliplr(filters.deg_30);


end

