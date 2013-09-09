function candidates = tournament(state,options)
  
  %initialize static tournament size
  tournament_size = 4;
  
  %initialize sizing variables
  [rows,cols] = size(state.candidates);
  
  %grab elite portion of the state encase we are in archival mode
  [null,index] = sortrows([state.ranks,-state.crowding_distances,state.ages]);
  index = index(1:min(size(state.design_values,1),rows*tournament_size));
  state.design_values = state.design_values(index,:);
  state.ranks = state.ranks(index,:);
  state.crowding_distances = state.crowding_distances(index,:);
  
  %perform tournaments until candidates is filled
  for i=1:rows
    j = randi([1,rows],[tournament_size,1]);
    [null k] = sortrows([state.ranks(j),-1*state.crowding_distances(j)]);
    state.candidates(i,:) = state.design_values(j(k(1)),:);
  end
  
  %return
  candidates = state.candidates;
end
