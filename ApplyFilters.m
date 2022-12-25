
function LineImg = ApplyFilters(Img,filters)

[origSize_y origSize_x] = size(Img);

Img = double(Img);
FilterNames = fieldnames(filters);
LineImg = [];

for i = 1:length(FilterNames)
    filterval = getfield(filters,FilterNames{i});
    conv_val = conv2(Img,filterval);
    conv_val = ComputeFeatureLines(conv_val);
    [convSize_y convSize_x] = size(conv_val);
    ofset_y = (convSize_y-origSize_y)/2; 
    ofset_x = (convSize_x-origSize_x)/2;
    conv_val = conv_val(ofset_y+1:end-ofset_y, ofset_x+1:end-ofset_x);    
    conv_val = bwmorph(conv_val,'clean');  %% clean the single pixels.
    LineImg = setfield(LineImg,FilterNames{i},conv_val);
end

end


function Img = ComputeFeatureLines(Img)
%% normalize Img
max_val = max(max(Img));
min_val = min(min(Img));
Img = (Img-min_val)/(max_val-min_val);

%% Otsu Threshold - find the level
% level = graythresh(Img)
level = 0.5;
Img = im2bw(Img,level);

end