function candidates = productLineTrim(state,options,number_of_attributes,number_of_features)

%pull off price portion
price = state.candidates(:,1:number_of_features);
features = state.candidates(:,number_of_features+1:end);

%re-order features
for i=1:size(features,1)  
  matrix = vec2mat(features(i,:),number_of_attributes);
  sorted_matrix = sortrows(matrix);
  rotated_matrix = sorted_matrix';
  features(i,:) = rotated_matrix(:)';
end

%round prices
price = round(price*1e2)/1e2;

candidates = [price,features];

%get unique
candidates = unique(candidates,'rows');

%check for inclusion
i = ~ismember(candidates,state.design_values,'rows');
candidates = candidates(i,:);

end

