function candidates = roulette(state,options)
  
  %FIXME account for all the bad designs in archival mode...perhaps only grab the top x portion of the pop?
  
  %initialize sizing variables
  [rows,cols] = size(state.candidates);
  
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