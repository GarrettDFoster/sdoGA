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
  %              ages | vector storing age of all living designs
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
  %version: 2013.03.11
  
  %detect options variable
  if ~exist('options','var') || ~isstruct(options)
    options = struct;
  end
  
  %add the objective function to the options structure
  if isfield(options,'objectiveFunction') && ~isequal(objectiveFunction,options.objectiveFunction)
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
  
  %age of each design
  if ~isfield(state,'ages')
    state.ages = [];
  end
  
  %archive of rank values
  if ~isfield(state,'ranks')
    state.ranks = [];
  end
  
  %archive of crowding distance values per frontier group
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
  if ~isfield(state,'runtimes')
    state.runtimes = [];
  end
  
  %generation of last improvement
  if ~isfield(state,'stall_generations') || isempty(state.stall_generations)
    state.stall_generations = 0;
  end
  
  %amount converged
  if ~isfield(state,'converged_fraction') || isempty(state.converged_fraction)
    state.converged_fraction = 0;
  end
  
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
  
  %   %allow for growing and shinking candidate evaluations
  %   if options.candidate_size_update < 0
  %     start = max(options.candidate_size_bounds);
  %     limit = min(options.candidate_size_bounds);
  %   else
  %     start = min(options.candidate_size_bounds);
  %     limit = max(options.candidate_size_bounds);
  %   end
  %   rows = min(start + options.candidate_size_update*state.generation, limit);
  
  rows = options.evals_per_gen;
  candidates = nan(rows,options.design_length);
end

%update state
function state = updateState(state,options)
  
  if ~isempty(state.candidates)
    %trim candidates prior to prevent re-evaluation
    for i=1:length(options.trimFunction)
      state.candidates = options.trimFunction{i}(state,options);
    end
    
    %evaluate candidates
    [objectives,constraints] = utility.evaluate(state,options);
    
    %save values
    top = size(state.design_values,1)+1;
    bottom = size(state.candidates,1)+top-1;
    state.design_values(top:bottom,:) = state.candidates;
    state.objective_values(top:bottom,:) = objectives;
    state.constraint_values(top:bottom,:) = constraints;
    
    %update ages
    state.ages = state.ages+1;
    state.ages(top:bottom,:) = zeros(bottom-top+1,1);
    
    %compute the best possible rank of the new designs
    if options.constraint_length > 0
      state.ranks(top:bottom,:) = metric.nonDominationRank(objectives,constraints);
    else
      state.ranks(top:bottom,:) = metric.nonDominationRank(objectives);
    end
    
    %combine to get updated ranks
    for i=1:size(state.design_values,1)
      index = (state.ranks == i);
      %check to see if we are out of rankings
      if all(~index)
        break;
      end
      %update ranks
      state.ranks(index,:) = metric.nonDominationRank(...
        state.objective_values(index,:),state.constraint_values(index,:)...
        ) + (i - 1);
      %check to see if enough are ranked for the next evaluation %SAVES TIME
      if nnz(state.ranks <= i) > options.evals_per_gen
        %NaN non-ranked so the ranking isn't mis-used
        state.rank(state.ranks > i) = NaN;
        break;
      end
    end
    
    %update crowding distance per front
    state.crowding_distances(top:bottom,1) = NaN;
    for i=1:max(state.ranks)
      index = (state.ranks == i);
      state.crowding_distances(index,:) = ...
        metric.crowdingDistance(state.objective_values(index,:));
    end
    
    %cut any designs that fall outside the archive limit
    if size(state.design_values,1) > options.archive_size
      %initialize binary vector
      keep = false(size(state.design_values,1),1);
      
      %keep ALL rank 1 points
      keep(state.ranks == 1) = true;
      
      %check to see if more points are needed
      if nnz(keep) < options.archive_size
        
        %identify stopping rank
        for i=2:max(state.ranks)
          if nnz(state.ranks <= i) == options.archive_size
            keep(state.ranks <= i) = true;
            break;
          elseif nnz(state.ranks <= i) > options.archive_size
            keep(state.ranks <= i) = true;
            %go through current front and remove points one by one
            while nnz(keep) > options.archive_size
              %sort current front and remove member with smallest crowding dist
              index = find(keep & state.ranks == i);
              [null,sorted_index] = sortrows([...
                -state.crowding_distances(index,:),...
                state.ages(index,:)...
                ]);
              keep(index(sorted_index(end))) = false;
              %update crowding distance for the remaining
              index = (keep & state.ranks == i);
              state.crowding_distances(index,:) = ...
                metric.crowdingDistance(state.objective_values(index,:));
            end
            break;
          elseif i == max(state.ranks)
            keep(:) = true;
            %go through current front and remove points one by one
            while nnz(keep) > options.archive_size
              %sort current front and remove member with smallest crowding dist
              index = find(keep & isnan(state.ranks));
              [null,sorted_index] = sortrows([...
                -state.crowding_distances(index,:),...
                state.ages(index,:)...
                ]);
              keep(index(sorted_index(end))) = false;
              %update crowding distance for the remaining
              index = (keep & isnan(state.ranks));
              state.crowding_distances(index,:) = ...
                metric.crowdingDistance(state.objective_values(index,:));
            end
            break;
          end
        end
      end
      %update archive
      state.design_values = state.design_values(keep,:);
      state.objective_values = state.objective_values(keep,:);
      state.constraint_values = state.constraint_values(keep,:);
      state.ages = state.ages(keep,:);
      state.ranks = state.ranks(keep,:);
      state.crowding_distances = state.crowding_distances(keep,:);
    end
    
    %calculate and store convergence information
    state.evaluations(state.generation+1,:) = size(state.candidates,1);
    
    %calculate new hypervolume
    ref = options.objective_upper_bound;
    index = isinf(ref);
    ref(index) = max(state.objective_values(:,index));
    state.hypervolumes(state.generation+1,:) = metric.hypervolume(...
      utility.paretoFront(state),ref);
    
    %update number of stall generations
    if state.generation > 0 && abs(state.hypervolumes(end)-state.hypervolumes(end-1)) < options.tolerance
      state.stall_generations = state.stall_generations + 1;
    else
      state.stall_generations = 0;
    end
    
    %update vector storing the time used for each generation
    state.runtimes(state.generation+1,:) = toc;
  end
  
  %value indicating how close the algorithm is to stopping
  state.converged_fraction = max(...
    [sum(state.evaluations)/options.max_evaluations,...
    (state.generation+1)/(options.max_generations+1),... %FIXME, currently hacked to stop 0/0 errors
    sum(state.runtimes)/options.max_runtime,...
    state.stall_generations/options.max_stall_generations,...
    state.hypervolumes(end)/options.hypervolume_target]);
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
