function candidates = exactMatch(state,options)
  candidates = unique(state.candidates,'rows');
  i = ~ismember(candidates,state.design_values,'rows');
  candidates = candidates(i,:);
end