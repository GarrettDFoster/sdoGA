function candidates = targeted(state,options,number_of_products,population_fraction,product_line_fraction,targeted_dataset)

%TODO
%-make is so it can build a dataset if one doesn't exist

%check for optional parameters
if ~exist('population_fraction','var')
  population_fraction = 1;
end

if ~exist('product_line_fraction','var')
  product_line_fraction = 1;
end

if ~exist('targeted_dataset','var')
  targeted_dataset = dataset();
end

%build random population using a latin hypercube
candidates = initialization.latinHypercube(state,options);

%define population structure
rows = round(size(candidates,1)*population_fraction);
cols = round(number_of_products*product_line_fraction);
number_of_features = sum(~options.discrete_variables);
number_of_attributes = sum(options.discrete_variables)/number_of_products;

%go through each product and do replacement if neccessary

for i=1:rows
  %determine markup by picking a random dataset entry
  r = randi(length(targeted_dataset),1);
  markup = targeted_dataset.markup(r);
  
  %make temp dataset
  ds = targeted_dataset(targeted_dataset.markup == markup,:);
  
  %get unique products
  targeted_index = [];
  while length(unique(targeted_index)) < cols
    targeted_index = randi(length(ds),cols,1);
  end
  
  %rebuild product line
  markup = ones(1,number_of_features)*markup;
  features = vec2mat(candidates(i,number_of_features+1:end),number_of_attributes);
  
  %place the new products randomly in the line
  if cols < number_of_products
    feature_row = [];
    while length(unique(feature_row)) < cols
      feature_row = randi(number_of_products,cols,1);
    end
  else
    feature_row = 1:number_of_products;
  end
  
  %replace random products with targeted
  for k = 1:cols
    features(feature_row(k),:) = ds.optimal_product(targeted_index(k),number_of_features+1:end);
  end
  
  %combine markup and features into line
  features = features';
  candidates(i,:) = [markup,features(:)'];  
end

end