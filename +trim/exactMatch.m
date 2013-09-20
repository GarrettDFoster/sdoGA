function candidates = exactMatch(state,options)
  candidates = unique(state.candidate_tbl,'rows');
  i = ~ismember(candidates,state.variable_tbl,'rows');
  candidates = candidates(i,:);
end