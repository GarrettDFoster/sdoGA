function candidates = tournament(state,options)
  
  %initialize static tournament size
  tournament_size = 4;
  
  %initialize sizing variables
  rows = options.population_size;
  
  %grab active population
  index = state.population_index;
  state.variable_tbl = state.variable_tbl(index,:);
  state.rank_list = state.rank_list(index,:);
  state.crowding_dist_list = state.crowding_dist_list(index,:);
  state.initial_gen_list = state.initial_gen_list(index,:);
  
  %perform tournaments until candidates is filled
  for i=1:rows
    j = randi([1,rows],[tournament_size,1]);
    [null,k] = sortrows([...
      state.rank_list(j),...
      -state.crowding_dist_list(j),...
      -state.initial_gen_list(j)...
    ]);
    state.candidate_tbl(i,:) = state.variable_tbl(j(k(1)),:);
  end
  
  %return
  candidates = state.candidate_tbl;
end
