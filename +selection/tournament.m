function candidates = tournament(state,options)
  
  %initialize sizing variables
  [rows,cols] = size(state.candidates);
  
  %get active sub-population
  active = ~isnan(state.ranks);
  state.ranks = state.ranks(active,:);
  state.design_values = state.design_values(active,:);
  state.crowding_distances = state.crowding_distances(active,:);
  
  %figure out how big the sub-population needs to be
  pop_size = min(sum(active),rows*2);
  
  %trim the sub-population
  [null,index] = sortrows([state.ranks,-1*state.crowding_distances]);
  index = index(1:pop_size);
  state.ranks = state.ranks(index);
  state.design_values = state.design_values(index,:);
  state.crowding_distances = state.crowding_distances(index,:);
  
  %perform 4 person tournaments until candidates is filled
  for i=1:rows
    j = randi([1,pop_size],[4,1]);
    [null k] = sortrows([state.ranks(j),-1*state.crowding_distances(j)]);
    state.candidates(i,:) = state.design_values(j(k(1)),:);
  end
  
  %return
  candidates = state.candidates;
end
