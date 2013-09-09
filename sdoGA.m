function [state,options] = sdoGA(objectiveFunction,options,state)
  %sdoGA is a genetic algorithm that is designed for easy customization.
  %To use, pass in the objective function along with the optional options and
  %state structures.
  %
  %[state,options] = sdoGA(objectiveFunction[,options,state])
  %
  %To continue from a previous run, just update the convergence criteria in the
  %options structure and pass it in along with the previous state structure.
  %
  %[state,options] = GA(objectiveFunction,options,state)
  %
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
  %     integer_variables | indicates which variables are integers
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
  % candidate_size_bounds | bounds on the number of designs in the candidate
  %                       | population each generation
  %                       | [ positive integer , >10*options.design_length< ]
  % candidate_size_update | the number of designs to add to or subtract from the
  %                       | candidate population each generation
  %                       | [ integer , >0< ]
  %         active_fronts | determines how many frontiers to keep active
  %                       | [ positive integer , >max(candidate_size_bounds)< ]
  %               archive | indicates whether inactive designs should be kept,
  %                       | otherwise they are discarded
  %                       | [ binary , >false< ]
  %initializationFunction | the function(s) used to initialize the population if
  %                       | no designs currently exist in the archive
  %                       | [ custom function(s) , @initialization.random ,
  %                       |  >@initialization.latinHypercube< ]
  %     selectionFunction | the function(s) used to select designs for
  %                       | reproduction
  %                       | [ custom function(s) , @selection.roulette ,
  %                       | >@selection.tournament< ]
  %     crossoverFunction | the function(s) used to intermix the design strings
  %                       | [ custom function(s) , @crossover.scattered ,
  %                       | >@crossover.blended< ]
  %      mutationFunction | the function(s) used to mutate the design strings
  %                       | [ custom function(s) , @mutation.uniform ,
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
  %
  %This algorithm allows for multiple functions to be used for each operation.
  %This does NOT apply to the objective function, which should be the handle to
  %a single function. Multiple functions are entered using a cell array. The
  %algorithm will execute them in the order of their entry as shown in the
  %example below.
  %
  %Example: options.outputFunction = {@customFunc1,@customFunc2};
  %
  %The algorithm also allows for custom functions to be used inplace of or
  %alongside the builtin operator functions. Below is a table showing the inputs
  %and outputs for each type of custom function.
  %
  %=============================================================================
  %function operation | <- inputs
  %                   | -> outputs
  %=============================================================================
  %    initialization | <- state structure, options structure
  %                   | -> candidates array
  %         selection | <- state structure, options structure
  %                   | -> candidates array
  %         crossover | <- state structure, options structure
  %                   | -> candidates array
  %          mutation | <- state structure, options structure
  %                   | -> candidates array
  %              trim | <- state structure, options structure
  %                   | -> candidates array
  %         objective | <- design vector
  %                   | -> objective vector, constraint vector (optional)
  %            output | <- state structure, options structure
  %                   | -> no output
  %             other | <- state structure, options structure
  %                   | -> state structure, options structure
  %=============================================================================
  %
  %The state structure below holds information about various parameters at the
  %current generation.
  %
  %=============================================================================
  %             state | description
  %=============================================================================
  %        candidates | array storing designs to be evaluated
  %     design_values | array storing all living evaluated designs
  %  objective_values | array storing objective values of living designs
  % constraint_values | array storing constraint values of living designs
  %             ranks | vector storing the rank each living designs associated
  %                     frontier
  %crowding_distances | vector storing the distance between each living design
  %                     and its neighbor in the objective space
  %        generation | value indicating the current generation number
  %       evaluations | vector storing the number of evaluations performed in
  %                     each generation
  %      hypervolumes | vector storing the hypervolume value at the end of each
  %                     generation
  %          runtimes | vector storing the time required for each generation
  % stall_generations | value indicating the generation at which the last
  %                     improvement in hypervolume value occurred
  %converged_fraction | value indicating how close the algorithm is to stopping
  %=============================================================================
  %
  %author: Garrett Foster
  %email: garrett.d.foster@gmail.com
  %web: http://SDOResearch.com
  %version: 2013.02.08
  
  %detect options variable
  if ~exist('options','var') || ~isstruct(options)
    options = struct;
  end
  
  %add the objective function to the options structure
  if isfield(options,'objectiveFunction') && ~isempty(options.objectiveFunction) && ~isequal(objectiveFunction,options.objectiveFunction)
    warning('Objective Function has been changed!');
  end
  if iscell(objectiveFunction)
    if length(objectiveFunction) > 1
      warning('Only using the first objective function!');
    end
    options.objectiveFunction = objectiveFunction{1};
  else
    options.objectiveFunction = objectiveFunction;
  end
  
  %set unspecified options with defaults
  options = utility.setOptions(options);
  
  %initialize state
  if ~exist('state','var') || ~isstruct(state)
    state = struct;
  end
  state = setState(state,options);
  
  %indicate start of algorithm
  if options.show_output
    fprintf('sdoGA run starting at %i-%i-%i %i:%i:%02.0f\n',clock);
  end
  
  %loop until converged
  while state.converged_fraction < 1
    
    %start generation timer
    tic;
    
    %increment generation counter
    state.generation = state.generation + 1;
    
    %initialize candidate population for sizing purposes
    state.candidates = initializeCandidates(state,options);
    
    %selection
    for i=1:length(options.selectionFunction)
      state.candidates = options.selectionFunction{i}(state,options);
    end
    
    %crossover
    for i=1:length(options.crossoverFunction)
      state.candidates = options.crossoverFunction{i}(state,options);
    end
    
    %mutation
    for i=1:length(options.mutationFunction)
      state.candidates = options.mutationFunction{i}(state,options);
    end
    
    %evaluate candidates and update state
    state = updateState(state,options);
    
    %output information
    if options.show_output
      for i=1:length(options.outputFunction)
        options.outputFunction{i}(state,options);
      end
    end
    
    %other function
    for i=1:length(options.otherFunction)
      %would prefer that options NOT get changed, may remove that ability later
      [state,options] = options.otherFunction{i}(state,options);
    end
    
  end
  
  %cleanup before exiting
  [state,options] = cleanup(state,options);
end

%state initialization function
function state = setState(state,options)
  
  %candidate design values for current generation
  if ~isfield(state,'candidates')
    state.candidates = [];
  end
  
  %archive of design values
  if ~isfield(state,'design_values')
    state.design_values = [];
  end
  
  %archive of objective values
  if ~isfield(state,'objective_values')
    state.objective_values = [];
  end
  
  %archive of constraint values
  if ~isfield(state,'constraint_values')
    state.constraint_values = [];
  end
  
  %archive of rank values
  if ~isfield(state,'ranks')
    state.ranks = [];
  end
  
  %archive of crowding distance values
  if ~isfield(state,'crowding_distances')
    state.crowding_distances = [];
  end
  
  %current generation number
  if ~isfield(state,'generation') || isempty(state.generation)
    state.generation = 0;
  end
  
  %evaluations per generation
  if ~isfield(state,'evaluations')
    state.evaluations = [];
  end
  
  %hypervolume per generation
  if ~isfield(state,'hypervolumes')
    state.hypervolumes = [];
  end
  
  %runtime per generation
  if ~isfield(state,'runtime')
    state.runtime = [];
  end
  
  %generation of last improvement should always initialize to 0
  state.stall_generations = 0;
  
  %amount converged
  state.converged_fraction = 0;
  
  %check to see if an initial population needs to be created
  tic;
  if isempty(state.design_values)
    %create candidates
    for i=1:length(options.initializationFunction)
      state.candidates = options.initializationFunction{i}(state,options);
    end
  else
    %see if we have un-evaluated designs
    x_rows = size(state.design_values,1);
    f_rows = size(state.objective_values,1);
    
    if x_rows > f_rows
      state.candidates = state.design_values(f_rows+1:end,:);
      state.population(f_rows+1:end,:) = [];
    else
      state.candidates = [];
    end
  end
  
  %update state
  state = updateState(state,options);
  
  %other function
  for i=1:length(options.otherFunction)
    %would prefer that options NOT get changed, may remove that ability later
    [state,options] = options.otherFunction{i}(state,options);
  end
end

%initialize the candidate population for the upcoming generation
function candidates = initializeCandidates(state,options)
  
  if options.candidate_size_update < 0
    start = max(options.candidate_size_bounds);
    limit = min(options.candidate_size_bounds);
  else
    start = min(options.candidate_size_bounds);
    limit = max(options.candidate_size_bounds);
  end
  
  rows = min(start + options.candidate_size_update*state.generation, limit);
  candidates = nan(rows,options.design_length);
end

%update state
function state = updateState(state,options)
  
  %trim candidates prior to prevent re-evaluation
  for i=1:length(options.trimFunction)
    state.candidates = options.trimFunction{i}(state,options);
  end
  
  if size(state.candidates,1) > 0
    %evaluate candidates
    [objectives,constraints] = utility.evaluate(state,options);
    
    %save values
    
    top = size(state.design_values,1)+1;
    bottom = size(state.candidates,1)+top-1;
    state.design_values(top:bottom,:) = state.candidates;
    state.objective_values(top:bottom,:) = objectives;
    state.constraint_values(top:bottom,:) = constraints;
    
    %compute the best possible rank of the new designs
    state.ranks(top:bottom,:) = metric.nonDominationRank(objectives,constraints);
    
    %combine to get updated ranks
    for i=1:options.active_fronts
      index = (state.ranks == i);
      state.ranks(index,:) = metric.nonDominationRank(...
        state.objective_values(index,:),state.constraint_values(index,:)...
        ) + (i - 1);
    end
    
    %denote inactive designs by NaN rank
    active = (state.ranks <= options.active_fronts);
    state.ranks(~active,:) = nan;
    
    %update crowding distance
    state.crowding_distances(active,:) = ...
      metric.crowdingDistance(state.objective_values(active,:));
    state.crowding_distances(~active,:) = nan;
    
    %cut inactive designs if not in archival mode
    if ~options.archive
      state.design_values = state.design_values(active,:);
      state.objective_values = state.objective_values(active,:);
      state.constraint_values = state.constraint_values(active,:);
      state.ranks = state.ranks(active,:);
      state.crowding_distances = state.crowding_distances(active,:);
    end
    
    %calculate and store convergence information
    state.evaluations(state.generation+1,:) = size(state.candidates,1);
    
    %when calculating new hypervolume,  scale if both bounds are present
    lb = options.objective_lower_bound;
    l_inf = isinf(lb);
    ub = options.objective_upper_bound;
    u_inf = isinf(ub);
    bounded = (~l_inf & ~u_inf);
    
    %scale bounded variables
    [null,f] = utility.getOptimal(state);
    if any(bounded)
      f(:,bounded) = utility.normalize(f(:,bounded),[lb(bounded);ub(bounded)]);
    end
    
    %calculate new hypervolume
    ref = max(state.objective_values);
    ref(~u_inf) = ub(~u_inf);
    ref(bounded) = 1;
    state.hypervolumes(state.generation+1,:) = metric.hypervolume(f,ref);
    
    %update number of stall generations
    if state.generation > 0 && abs(state.hypervolumes(end)-state.hypervolumes(end-1)) < options.tolerance
      state.stall_generations = state.stall_generations + 1;
    else
      state.stall_generations = 0;
    end
    
    %update vector storing the time used for each generation
    state.runtimes(state.generation+1,:) = toc;
    
    %value indicating how close the algorithm is to stopping
    state.converged_fraction = max(...
      [sum(state.evaluations)/options.max_evaluations,...
      state.generation/options.max_generations,...
      sum(state.runtimes)/options.max_runtime,...
      state.stall_generations/options.max_stall_generations,...
      state.hypervolumes(end)/options.hypervolume_target]);
  end
end

%cleanup function
function [state,options] = cleanup(state,options)
  
  %indicate cause of stopping
  if options.show_output
    if sum(state.evaluations) >= options.max_evaluations
      disp('Max number of evaluations reached.');
    elseif state.generation >= options.max_generations
      disp('Max number of generations reached.');
    elseif sum(state.runtimes) >= options.max_runtime
      disp('Max amount of time reached.');
    elseif state.stall_generations >= options.max_stall_generations
      disp('Max number of stall generations reached.');
    elseif state.hypervolumes(end) >= options.hypervolume_target
      disp('Hypervolume target reached.');
    end
  end
  
end
