function [objectives,constraints] = evaluate(state,options)
  %evaluate is used to evaluate designs in parralel. Pass in either the state
  %structure or an array of designs along with the options structure. The first 
  %option will evaluate the state structure, while the second will evaluate the
  %array of designs. Both use the objective function specified in the options 
  %structure.
  %
  %[objectives,constraints] = evaluate(state,options)
  %
  %[objectives,constraints] = evaluate(array,options)
  
  if isstruct(state)
    designs = state.candidates;
  elseif isnumeric(state)
    designs = state;
  end
  
  rows = size(designs,1);
  objectives = nan(rows,options.objective_length);
  constraints = nan(rows,options.constraint_length);
  objFun = options.objectiveFunction;
  
  if options.constraint_length
    parfor i=1:rows
      [objectives(i,:),constraints(i,:)] = objFun(designs(i,:));
    end
  else
    parfor i=1:rows
      objectives(i,:) = objFun(designs(i,:));
    end
  end
end
