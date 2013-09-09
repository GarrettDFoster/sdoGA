function options = setOptions(options)
  %To customize the algorithm you can change the items in the options and
  %structure listed below. You also get a default options structure by running
  %the following command.
  %
  %options = setOptions();
  
  %TODO be able to parse options coming in as cells -> {'max_runtime',100}
  
  %check for input
  if ~exist('options','var') || ~isstruct(options)
    options = struct;
  end
  if ~isfield(options,'objectiveFunction')
    options.objectiveFunction = {};
  end
  
  %number of variables in design string
  if ~isfield(options,'design_length') || isempty(options.design_length)
    if isempty(options.objectiveFunction)
      options.design_length = [];
    elseif isfield(options,'integer_variables') && ~isempty(options.integer_variables)
      options.design_length = length(options.integer_variables);
    elseif isfield(options,'design_lower_bound') && ~isempty(options.design_lower_bound)
      options.design_length = length(options.design_lower_bound);
    elseif isfield(options,'design_upper_bound') && ~isempty(options.design_upper_bound)
      options.design_length = length(options.design_upper_bound);
    else
      user_input = inputdlg('How many design variables are there?');
      options.design_length = round(str2double(user_input{1}));
    end
  end
  
  %lower bound on the design string
  if ~isfield(options,'design_lower_bound') || isempty(options.design_lower_bound)
    if isempty(options.design_length)
      options.design_lower_bound = [];
    else
      options.design_lower_bound = -Inf(1,options.design_length);
    end
  end
  
  %upper bound on the design string
  if ~isfield(options,'design_upper_bound') || isempty(options.design_upper_bound)
    if isempty(options.design_length)
      options.design_upper_bound = [];
    else
      options.design_upper_bound = Inf(1,options.design_length);
    end
  end
  
  %binary string indicating which variables are integers
  if ~isfield(options,'integer_variables') || isempty(options.integer_variables)
    if isempty(options.design_length)
      options.integer_variables = [];
    else
      options.integer_variables = false(1,options.design_length);
    end
  end
  
  %number of objectives in problem
  if ~isfield(options,'objective_length') || isempty(options.objective_length)
    if isempty(options.objectiveFunction)
      options.objective_length = [];
    else
      x = options.design_lower_bound;
      x(isinf(x)) = 0;
      f = options.objectiveFunction(x);
      options.objective_length = length(f);
    end
  end
  
  %lower bound on objective values - used for scaling
  if ~isfield(options,'objective_lower_bound') || isempty(options.objective_lower_bound)
    if isempty(options.objective_length)
      options.objective_lower_bound = [];
    else
      options.objective_lower_bound = -Inf(1,options.objective_length);
    end
  end
  
  %upper bound on objective values - used for scaling
  if ~isfield(options,'objective_upper_bound') || isempty(options.objective_upper_bound)
    if isempty(options.objective_length)
      options.objective_upper_bound = [];
    else
      options.objective_upper_bound = Inf(1,options.objective_length);
    end
  end
  
  %number of constraints in problem
  if ~isfield(options,'constraint_length') || isempty(options.constraint_length) || options.constraint_length == 0
    if isempty(options.objectiveFunction)
      options.constraint_length = [];
    else
      try
        x = options.design_lower_bound;
        x(isinf(x)) = 0;
        [null,g] = options.objectiveFunction(x);
        options.constraint_length = length(g);
      catch
        options.constraint_length = 0;
      end
    end
  end
  
  %bounds on the number of designs in the candidate population
  if ~isfield(options,'candidate_size_bounds') || isempty(options.candidate_size_bounds)
    if isempty(options.design_length)
      options.candidate_size_bounds = [];
    else
      options.candidate_size_bounds = ones(1,2)*10*options.design_length;
    end
  else
    a = min(options.candidate_size_bounds);
    b = max(options.candidate_size_bounds);
    options.candidate_size_bounds = [a,b];
  end
  
  %how many designs to add or subtract from the candidate population each generation
  if ~isfield(options,'candidate_size_update') || isempty(options.candidate_size_update)
    if isempty(options.design_length)
      options.candidate_size_update = [];
    else
      options.candidate_size_update = 0;
    end
  end
  
  %maximum rank of frontier to keep active
  if ~isfield(options,'active_fronts') || isempty(options.active_fronts)
    if isempty(options.candidate_size_bounds)
      options.active_fronts = [];
    else
      options.active_fronts = 2*max(options.candidate_size_bounds);
    end
  end
  
  %archive or delete inactive designs
  if ~isfield(options,'archive') || isempty(options.archive)
    options.archive = false;
  end
  
  %set the default initialization function
  if ~isfield(options,'initializationFunction') || isempty(options.initializationFunction)
    options.initializationFunction = {@initialization.latinHypercube};
  elseif isa(options.initializationFunction,'function_handle')
    options.initializationFunction = {options.initializationFunction};
  end
  
  %set the default selection function
  if ~isfield(options,'selectionFunction') || isempty(options.selectionFunction)
    options.selectionFunction = {@selection.tournament};
  elseif isa(options.selectionFunction,'function_handle')
    options.selectionFunction = {options.selectionFunction};
  end
  
  %set the default crossover functions
  if ~isfield(options,'crossoverFunction') || isempty(options.crossoverFunction)
    options.crossoverFunction = {@crossover.blended};
  elseif isa(options.crossoverFunction,'function_handle')
    options.crossoverFunction = {options.crossoverFunction};
  end
  
  %set the default mutation functions
  if ~isfield(options,'mutationFunction') || isempty(options.mutationFunction)
    options.mutationFunction = {@mutation.adaptive};
  elseif isa(options.mutationFunction,'function_handle')
    options.mutationFunction = {options.mutationFunction};
  end
  
  %used to determine when two values are to be considered identical
  if ~isfield(options,'tolerance') || isempty(options.tolerance)
    options.tolerance = 1e-6;
  end
  
  %set default trim function
  if ~isfield(options,'trimFunction') || isempty(options.trimFunction)
    options.trimFunction = {@trim.exactMatch};
  elseif isa(options.trimFunction,'function_handle')
    options.trimFunction = {options.trimFunction};
  end
  
  %set the number of cores to be used
  if ~isfield(options,'number_of_cores') || isempty(options.number_of_cores)
    %default to 1
    options.number_of_cores = 1;
  elseif options.number_of_cores > 1
    try
      matlabpool('open',min(getenv('NUMBER_OF_PROCESSORS'),options.number_of_cores));
    catch
      matlabpool close force
      matlabpool('open',min(getenv('NUMBER_OF_PROCESSORS'),options.number_of_cores));
    end
  end
  
  %used to turn off output and run in a batch mode
  if ~isfield(options,'show_output') || isempty(options.show_output)
    options.show_output = true;
  end
  
  %set default output function
  if ~isfield(options,'outputFunction') || isempty(options.outputFunction)
    options.outputFunction = {@output.iteration};
  elseif isa(options.outputFunction,'function_handle')
    options.outputFunction = {options.outputFunction};
  end
  
  %set default other function to empty - this is primarily for the user
  if ~isfield(options,'otherFunction') || isempty(options.otherFunction)
    options.otherFunction = {};
  elseif isa(options.otherFunction,'function_handle')
    options.otherFunction = {options.otherFunction};
  end
  
  %maximum number of evaluations allowed
  if ~isfield(options,'max_evaluations') || isempty(options.max_evaluations)
    options.max_evaluations = Inf;
  end
  
  %maximum number of generations allowed
  if ~isfield(options,'max_generations') || isempty(options.max_generations)
    options.max_generations = 100;
  end
  
  %maximum amount of total runtime allowed
  if ~isfield(options,'max_runtime') || isempty(options.max_runtime)
    options.max_runtime = 60; %seconds
  end
  
  %maximum number of stall generations allowed
  if ~isfield(options,'max_stall_generations') || isempty(options.max_stall_generations)
    options.max_stall_generations = 10;
  end
  
  %target hypervolume to stop at
  if ~isfield(options,'hypervolume_target') || isempty(options.hypervolume_target)
    options.hypervolume_target = Inf;
  end
  
end