function options = setOptions(options)
  %To customize the algorithm you can change the items in the options and
  %structure listed below. You also get a default options structure by running
  %the following command.
  %
  %options = setOptions();
  %
  %=============================================================================
  %               options | description
  %                       | [ possible , and >default< values ]
  %=============================================================================
  %         design_length | the number of variables in the design string
  %                       | [ positive integer , >0< ]
  %    design_lower_bound | lower bound for each variable
  %                       | [ vector , >-Inf< ]
  %    design_upper_bound | upper bound for each variable
  %                       | [ vector , >Inf< ]
  %     discrete_variables | indicates which variables are integers
  %                       | [ binary vector , >false< ]
  %      objective_length | the number of objectives in the problem
  %                       | [ positive integer , >0< ]
  % objective_lower_bound | lower bound for each objective value, used to scale
  %                       | objective space
  %                       | [ vector , >-Inf< ]
  % objective_upper_bound | upper bound for each objective value, used to scale
  %                       | objective space
  %                       | [ vector , >Inf< ]
  %     constraint_length | number of constraints in the problem
  %                       | [ positive integer , >0< ]
  %          archive_size | max number of designs kept after each generation,
  %                       | Note: ALL rank one points are kept regardless.
  %                       | [integer value, >10*options.design_length<]
  %         evals_per_gen | max number of candidates evaluated each generation
  %                       | [ positive integer , >10*options.design_length< ]
  %initializationFunction | the function(s) used to initialize the population if
  %                       | no designs currently exist in the archive
  %                       | [ custom function(s) , @initialization.random ,
  %                       |  >@initialization.latinHypercube< ]
  %     selectionFunction | the function(s) used to select designs for
  %                       | reproduction
  %                       | [ custom function(s) , @selection.roulette ,
  %                       | >@selection.tournament< ]
  %     crossoverFunction | the function(s) used to intermix the selected
  %                       | design's genetic information
  %                       | [ custom function(s) , @crossover.scattered ,
  %                       | >@crossover.blended< ]
  %      mutationFunction | the function(s) used to mutate the selected
  %                       | design's genetic information
  %                       | [ custom function(s) @mutation.uniform , 
  %                       | @mutation.biased , >@mutation.adaptive< ]
  %             tolerance | used to determine when two values are to be
  %                       | considered identical
  %                       | [ positive real , >1e-6< ]
  %          trimFunction | the function used to prevent re-evaluation of
  %                       | designs, NOTE if your simiulation is stochastic you
  %                       | should use your own function
  %                       | [ custom function(s) , >@trim.exactMatch< ]
  %     objectiveFunction | the function(s) used to calculate the objective
  %                       | value(s), will automatically set itself to the
  %                       | function passed in
  %                       | [ custom function ]
  %       number_of_cores | specified the number objective function evaluations
  %                       | that can take place in parralell
  %                       | [ positive integer , >1< ]
  %           show_output | used to turn off output and run in a batch mode
  %                       | [ binary , >true< ]
  %        outputFunction | used to display the progress of the algorithm
  %                       | [custom function(s) , @output.convergence ,
  %                       | @output.frontier , >@output.iteration< ]
  %         otherFunction | function(s) called at the end of each generation
  %                       | [ custom function(s) , >{}< ]
  %       max_generations | maximum number of generations allowed
  %                       | [ postitive integer , >100< ]
  %       max_evaluations | maximum number of evaluations allowed
  %                       | [ postitive integer , >Inf< ]
  %           max_runtime | maximum amount of total runtime allowed in seconds
  %                       | [ postive real , >60< ]
  % max_stall_generations | maximum number of stall generations allowed
  %                       | [ postitive integer , >10< ]
  %    hypervolume_target | target hypervolume to stop at
  %                       | [ postive real , >Inf< ]
  %=============================================================================
  
  %TODO be able to parse options coming in as cells -> {'max_runtime',100}
  
  %check for input
  if ~exist('options','var') || ~isstruct(options)
    options = struct;
  elseif ~isfield(options,'objectiveFunction')
    options.objectiveFunction = {};
  end
  
  %number of variables in design string
  if ~isfield(options,'design_length') || isempty(options.design_length)
    if isempty(options.objectiveFunction)
      options.design_length = 0;
    elseif isfield(options,'integer') && ~isempty(options.integer)
      options.design_length = length(options.integer);
    elseif isfield(options,'lower_bound') && ~isempty(options.lower_bound)
      options.design_length = length(options.lower_bound);
    elseif isfield(options,'upper_bound') && ~isempty(options.upper_bound)
      options.design_length = length(options.upper_bound);
    else
      user_input = inputdlg('How many design variables are there?');
      options.design_length = round(str2double(user_input{1}));
    end
  end
  
  %lower bound on the design string
  if ~isfield(options,'design_lower_bound') || isempty(options.design_lower_bound)
    options.design_lower_bound = -Inf(1,options.design_length);
  end
  
  %upper bound on the design string
  if ~isfield(options,'design_upper_bound') || isempty(options.design_upper_bound)
    options.design_upper_bound = Inf(1,options.design_length);
  end
  
  %binary string indicating which variables are discrete
  if ~isfield(options,'discrete_variables') || isempty(options.discrete_variables)
    options.discrete_variables = false(1,options.design_length);
  end
  
  %number of objectives in problem
  if ~isfield(options,'objective_length') || isempty(options.objective_length)
    if isempty(options.objectiveFunction)
      options.objective_length = 0;
    else
      x = options.design_lower_bound;
      x(isinf(x)) = 0;
      f = options.objectiveFunction(x);
      options.objective_length = length(f);
    end
  end
  
  %lower bound on objective values - used for scaling
  if ~isfield(options,'objective_lower_bound') || isempty(options.objective_lower_bound)
    options.objective_lower_bound = -Inf(1,options.objective_length);
  end
  
  %upper bound on objective values - used for scaling
  if ~isfield(options,'objective_upper_bound') || isempty(options.objective_upper_bound)
    options.objective_upper_bound = Inf(1,options.objective_length);
  end
  
  %number of constraints in problem
  if ~isfield(options,'constraint_length') || isempty(options.constraint_length)
    if isempty(options.objectiveFunction)
      options.constraint_length = 0;
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
  
  %max number of designs kept after each generation
  if ~isfield(options,'archive_size') || isempty(options.archive_size)
    options.archive_size = 10*options.design_length;
  end
  
  %max number of candidates evaluated each generation
  if ~isfield(options,'evals_per_gen') || isempty(options.evals_per_gen)
    options.evals_per_gen = 10*options.design_length;
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
  
  %set the default crossover function
  if ~isfield(options,'crossoverFunction') || isempty(options.crossoverFunction)
    options.crossoverFunction = {@crossover.blended};
  elseif isa(options.crossoverFunction,'function_handle')
    options.crossoverFunction = {options.crossoverFunction};
  end
  
  %set the default mutation function
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
  if ~isfield(options,'otherFunction') || isemtpy(options.otherFunction)
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