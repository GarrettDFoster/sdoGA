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
    designs = state.candidate_tbl;
  elseif isnumeric(state)
    designs = state;
  end
  
  rows = size(designs,1);
  objectives = nan(rows,options.number_of_objectives);
  constraints = nan(rows,options.number_of_constraints);
  objFun = options.analysisFunction;
  
  if options.number_of_constraints
    parfor i=1:rows
      [objectives(i,:),constraints(i,:)] = objFun(designs(i,:));
    end
  else
    parfor i=1:rows
      objectives(i,:) = objFun(designs(i,:));
    end
  end
end
