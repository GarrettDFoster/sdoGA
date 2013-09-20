function candidates = tournament(state,options)
  
  %initialize static tournament size
  tournament_size = 4;
  
  %initialize sizing variables
  [rows,cols] = size(state.candidate_tbl);
  
  %grab elite portion of the state in case we are in archival mode
  [null,index] = sortrows([-state.optimal_index,-state.hypervolume_list,-state.birth_gen_list]);
  index = index(1:min(size(state.variable_tbl,1),rows*tournament_size));
  state.variable_tbl = state.variable_tbl(index,:);
  state.optimal_index = state.optimal_index(index,:);
  state.hypervolume_list = state.hypervolume_list(index,:);
  
  %perform tournaments until candidates is filled
  for i=1:rows
    j = randi([1,rows],[tournament_size,1]);
    [null k] = sortrows([-state.optimal_index(j),-1*state.hypervolume_list(j)]);
    state.candidate_tbl(i,:) = state.variable_tbl(j(k(1)),:);
  end
  
  %return
  candidates = state.candidate_tbl;
end
