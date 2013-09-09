function [f,x,g] = paretoFront(state)
  i = (state.ranks == 1);
  f = state.objective_values(i,:);
  x = state.design_values(i,:);
  if ~isempty(state.constraint_values)
    g = state.constraint_values(i,:);
  else
    g = [];
  end
end
