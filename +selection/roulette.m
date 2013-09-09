function candidates = roulette(state,options)
  
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
  
  %build the wheel
  proportion = ((max(state.ranks)-state.ranks+1)/max(state.ranks)) + ...
    (state.crowding_distances / max(state.crowding_distances));
  wheel = cumsum(proportion)/sum(proportion);
  
  %select candidates
  for i = 1:rows
    r = rand;
    for j = 1:length(wheel)
      if(r < wheel(j))
        state.candidates(i,:) = state.design_values(j,:);
        break;
      end
    end
  end
  
  %return candidates
  candidates = state.candidates;
end