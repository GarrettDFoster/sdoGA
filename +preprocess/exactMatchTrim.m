function candidates = exactMatchTrim(state,options)
  candidates = unique(state.candidate_tbl,'rows');
  if ~isempty(state.variable_tbl)
    i = ~ismember(candidates,state.variable_tbl,'rows');
    candidates = candidates(i,:);
  end
end
