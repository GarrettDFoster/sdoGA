function candidates = greedyInitialization(state,options,model)
%GREEDYINITIALIZATION Summary of this function goes here
%   Detailed explanation goes here

%density settings
population_fraction = 1;
product_line_fraction = 1;

%load model and define characteristics
load(model);
number_of_levels = cellfun(@length,feature_costs);
number_of_features = sum(number_of_levels);
number_of_attributes = length(feature_costs);
number_of_products = 3;
number_of_respondents = size(part_worths,1);

%find ideal features using greedy approach
ideal_features = nan(number_of_respondents,number_of_attributes);
left = 1;
for j=1:number_of_attributes
  right = sum(number_of_levels(1:j));
  [null,ideal_features(:,j)] = max(part_worths(:,left:right),[],2);
  left = right+1;
end

%build markup matrix
markup = nan(options.generation_size,number_of_features);
step = 1/(options.generation_size-1);
m = 0;
for i=1:options.generation_size
  markup(i,:) = ones(1,number_of_features)*m;
  m = m+step;
end

%build feature matrix
feat = nan(options.generation_size,number_of_attributes*number_of_products);
for i=1:options.generation_size
  for j=1:number_of_products
    right = j*number_of_attributes;
    left = right-number_of_attributes+1;
    feat(i,left:right) = ideal_features(randi([1,number_of_respondents],1),:);    
  end
end

%build candidates
candidates = [markup,feat];

end