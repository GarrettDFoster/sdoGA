function [state,options] = sdoGA(analysisFunction,options,state)
  %sdoGA is a genetic algorithm that is designed for easy customization.
  %To use, pass in the analysis function along with the optional options and
  %state structures.
  %
  %[state,options] = sdoGA(analysisFunction[,options,state])
  %
  %To continue from a previous run, just update the convergence criteria in the
  %options structure and pass it in along with the previous state structure.
  %
  %[state,options] = sdoGA(analysisFunction,options,state)
  %
  %To customize the algorithm you can change the items in the options structure
  %listed below. Run the following command to get a default options structure.
  %
  %options = utility.setOptions();
  %
  %=============================================================================
  %               options | description
  %                       | [ possible , and >default< values ]
  %=============================================================================
  %      analysisFunction | function used to calculate objective and constraint
  %                       | value(s)
  %                       | [ custom function ]
  %  number_of_objectives | the number of objectives in the problem
  %                       | [ positive integer , >0< ]
  % number_of_constraints | number of constraints in the problem
  %                       | [ positive integer , >0< ]
  %   number_of_variables | the number of variables in the design string
  %                       | [ positive integer , >0< ]
  %    discrete_variables | indicates which variables are integers
  %                       | [ binary vector , >false< ]
  %  variable_lower_bound | lower bound for each variable
  %                       | [ vector , >-Inf< ]
  %  variable_upper_bound | upper bound for each variable
  %                       | [ vector , >Inf< ]
  %       reference_point | vector indicating point in objective space that
  %                       | hypervolume is measured from
  %                       | [ vector, >[]< ]
  %       population_size | number of designs kept in active population
  %                       | [ positive integer ,
  %                       |  >10*options.number_of_variables< ]
  %       number_of_cores | specified the number of analysisFunction evaluations
  %                       | that can take place in parralell
  %                       | [ positive integer , >1< ]
  %initializationFunction | the function(s) used to initialize the population if
  %                       | no designs currently exist in the archive
  %                       | [ custom function(s) ,
  %                       |  >@initialization.latinHypercube< ]
  %     selectionFunction | the function(s) used to select designs for
  %                       | reproduction
  %                       | [ custom function(s) , >@selection.tournament< ]
  %     crossoverFunction | the function(s) used to intermix the selected
  %                       | design's genetic information
  %                       | [ custom function(s) , >@crossover.scattered< ]
  %      mutationFunction | the function(s) used to mutate the selected
  %                       | design's genetic information
  %                       | [ custom function(s) , >@mutation.uniform< ]
  %    preprocessFunction | the function used to pre-process the designs,
  %                       | default usage is to prevent re-evaluation of designs
  %                       | [ custom function(s) , >@trim.exactMatchTrim< ]
  %        outputFunction | used to display the progress of the algorithm, if no
  %                       | ouput is desired then input an empty cell
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
  %=============================================================================
  %
  %The state structure below holds information about various parameters at the
  %current generation.
  %
  %=============================================================================
  %              state | description
  %=============================================================================
  %         generation | integer indicating the current generation number
  %      candidate_tbl | array storing designs to be evaluated
  %       variable_tbl | array storing variable values of archived designs
  %      objective_tbl | array storing objective values of archived designs
  %     constraint_tbl | array storing constraint values of archived designs
  %   initial_gen_list | vector storing initial gen in pop of archived designs
  %     final_gen_list | vector storing final gen in pop of archived designs
  %   population_index | binary vector indicating which archived designs are in 
  %                    | active population
  %          rank_list | vector indicating frontier of each population member
  % crowding_dist_list | vector storing the crowding distance of optimal members
  %evaluations_per_gen | vector storing the number of evaluations performed in
  %                    | each generation
  %    runtime_per_gen | vector storing the time (seconds) required for each gen
  %hypervolume_per_gen | vector storing the hypervolume for each generation
  %  stall_generations | integer indicating number of generations since last
  %                    | improvement in hypervolume value
  % converged_fraction | estimated value indicating closeness to convergence
  %=============================================================================
  %
  %author: Garrett Foster
  %email: garrett.d.foster@gmail.com
  %web: http://SDOResearch.com
  
  %detect options variable
  if ~exist('options','var') || ~isstruct(options)
    options = struct;
  end
  
  %add the objective function to the options structure
  if isfield(options,'analysisFunction') && ~isequal(analysisFunction,options.analysisFunction)
    warning('Analysis Function has been changed!');
  end
  if iscell(analysisFunction)
    if length(analysisFunction) > 1
      warning('Only using the first analysis function!');
    end
    options.analysisFunction = analysisFunction{1};
  else
    options.analysisFunction = analysisFunction;
  end
  
  %set unspecified options with defaults
  options = utility.setOptions(options);
  
  %initialize state
  if ~exist('state','var') || ~isstruct(state)
    state = struct;
  end
  state = setState(state,options);
  
  %indicate start of algorithm
  if ~isempty(options.outputFunction)
    fprintf('sdoGA run starting at %i-%i-%i %i:%i:%02.0f\n',clock);
  end
  
  %loop until converged
  while state.converged_fraction < 1
    
    %start generation timer
    tic;
    
    %initialize candidate array for sizing purposes
    state.candidate_tbl = initCandidateTbl(options);
    
    %selection
    for i=1:length(options.selectionFunction)
      state.candidate_tbl = options.selectionFunction{i}(state,options);
    end
    
    %crossover
    for i=1:length(options.crossoverFunction)
      state.candidate_tbl = options.crossoverFunction{i}(state,options);
    end
    
    %mutation
    for i=1:length(options.mutationFunction)
      state.candidate_tbl = options.mutationFunction{i}(state,options);
    end
    
    %evaluate candidates and update state
    state = updateState(state,options);
    
    %output information
    for i=1:length(options.outputFunction)
      options.outputFunction{i}(state,options);
    end
    
    %other function
    for i=1:length(options.otherFunction)
      %would prefer that options NOT get changed, may remove that ability later
      [state,options] = options.otherFunction{i}(state,options);
    end
    
  end
  
  %cleanup before exiting
  state = cleanup(state,options);
end

%state initialization function
function state = setState(state,options)
  
  %integer indicating the current generation number
  if ~isfield(state,'generation') || isempty(state.generation)
    state.generation = 0;
  end
  
  %array storing designs to be evaluated
  if ~isfield(state,'candidate_tbl')
    state.candidate_tbl = [];
  end
  
  %array storing variable values of archived designs
  if ~isfield(state,'variable_tbl')
    state.variable_tbl = [];
  end
  
  %array storing objective values of archived designs
  if ~isfield(state,'objective_tbl')
    state.objective_tbl = [];
  end
  
  %array storing constraint values of archived designs
  if ~isfield(state,'constraint_tbl')
    state.constraint_tbl = [];
  end
  
  %vector storing initial generation of archived designs
  if ~isfield(state,'initial_gen_list')
    state.initial_gen_list = [];
  end
  
  %vector storing final gen in pop of archived designs
  if ~isfield(state,'final_gen_list')
    state.final_gen_list = [];
  end
  
  %binary vector indicating which archived designs are in the active population
  if ~isfield(state,'population_index')
    state.population_index = false(0);
  end
  
  %vector indicating frontier of each population member
  if ~isfield(state,'rank_list')
    state.rank_list = [];
  end
  
  %vector storing the crowding distance of optimal designs
  if ~isfield(state,'crowding_dist_list')
    state.crowding_dist_list = [];
  end
  
  %vector storing the number of evaluations performed in each generation
  if ~isfield(state,'evaluation_per_gen')
    state.evaluations_per_gen = [];
  end
  
  %vector storing the time (seconds) required for each generation
  if ~isfield(state,'runtime_per_gen')
    state.runtime_per_gen = [];
  end
  
  %vector storing the hypervolume for each generation
  if ~isfield(state,'hypervolume_per_gen')
    state.hypervolume_per_gen = [];
  end
  
  %integer indicating number of generations since last improvement in hypervolume value
  if ~isfield(state,'stall_generations') || isempty(state.stall_generations)
    state.stall_generations = 0;
  end
  
  %estimated value indicating closeness to convergence
  if ~isfield(state,'converged_fraction') || isempty(state.converged_fraction)
    state.converged_fraction = 0;
  end
  
  %check to see if an initial population needs to be created
  tic;
  if isempty(state.variable_tbl)
    %create candidates
    for i=1:length(options.initializationFunction)
      state.candidate_tbl = options.initializationFunction{i}(state,options);
    end
  else
    %see if we have un-evaluated designs
    x_rows = size(state.variable_tbl,1);
    f_rows = size(state.objective_tbl,1);
    
    if x_rows > f_rows
      state.candidate_tbl = state.variable_tbl(f_rows+1:end,:);
      state.variable_tbl(f_rows+1:end,:) = [];
    else
      state.candidate_tbl = [];
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
function candidates = initCandidateTbl(options)  
  rows = options.population_size;
  cols = options.number_of_variables;
  candidates = nan(rows,cols);
end

%update state structure
function state = updateState(state,options)
  
  %increment generation counter
  state.generation = state.generation + 1;
  
  if ~isempty(state.candidate_tbl)
    
    %preprocess candidates prior to evaluation
    for i=1:length(options.preprocessFunction)
      state.candidate_tbl = options.preprocessFunction{i}(state,options);
    end
    
    %evaluate candidates
    [objectives,constraints] = evaluate(state,options);
    
    %save values
    top = size(state.variable_tbl,1)+1;
    bottom = size(state.candidate_tbl,1)+top-1;
    state.variable_tbl(top:bottom,:) = state.candidate_tbl;
    state.objective_tbl(top:bottom,:) = objectives;
    state.constraint_tbl(top:bottom,:) = constraints;
    
    %indicate candidates have been added to population
    state.population_index(top:bottom,:) = true;
    
    %update initial generation list
    state.initial_gen_list(top:bottom,:) = state.generation;
    
    %compute the best possible rank of the new designs
    state.rank_list(top:bottom,:) = metric.nonDominatedRank(objectives,constraints);
    
    %combine to get rank of current population
    for i=1:nnz(state.population_index)
      %identify designs to consider
      index = (state.rank_list == i);
      if ~any(index)
        break;
      end
      
      %update ranks
      state.rank_list(index,:) = metric.nonDominatedRank(...
        state.objective_tbl(index,:),...
        state.constraint_tbl(index,:)...
        ) + (i - 1);
    end
    
    %compute crowding distance of optimal designs
    state.crowding_dist_list(state.population_index,1) = NaN;
    index = state.rank_list == 1;
    state.crowding_dist_list(index,:) = metric.crowdingDistance(...
      state.objective_tbl(index,:)...
    );
  
    %prune population to size
    pop_index = state.population_index;
    if nnz(state.rank_list == 1) > options.population_size
      
      %keeping only frontier points
      state.population_index(state.rank_list > 1,:) = false; 
      
      %remove lowest crowding distance one at a time until front fits
      while nnz(state.rank_list == 1) > options.population_size
        index = (state.crowding_dist_list == min(state.crowding_dist_list));
        state.population_index(index,:) = false;
        state.crowding_dist_list(index,:) = NaN;
        state.rank_list(index,:) = NaN;
        index = (state.rank_list == 1);
        state.crowding_dist_list(index,:) = metric.crowdingDistance(...
          state.objective_tbl(index,:)...
        );
      end
    
    else      
      [null,index] = sortrows([...
        state.rank_list,...
        -state.initial_gen_list...
      ]);
      index = index(1:options.population_size);   
      state.population_index(1:length(pop_index),:) = false;
      state.population_index(index,:) = true;
    end
    
    %update metrics
    expired = pop_index & ~state.population_index;
    state.rank_list(expired,:) = NaN;
    state.crowding_dist_list(expired,:) = NaN;
    state.final_gen_list(expired,:) = state.generation;
   
  end
  
  %update evaluation counter
  state.evaluations_per_gen(state.generation,:) = size(state.candidate_tbl,1);
  
  %calculate hypervolume of frontier
  state.hypervolume_per_gen(state.generation,:) = metric.hypervolume(...
    state.objective_tbl(state.rank_list == 1,:),...
    options.reference_point...
  );

  %update number of stall generations
  if state.generation > 1 && 1 - (state.hypervolume_per_gen(end)/state.hypervolume_per_gen(end-1)) < 0.001
    state.stall_generations = state.stall_generations + 1;
  else
    state.stall_generations = 0;
  end
  
  %update vector storing the time used for each generation
  state.runtime_per_gen(state.generation,:) = toc;
  
  %update value indicating how close the algorithm is to stopping
  state.converged_fraction = max([...
    sum(state.evaluations_per_gen)/options.max_evaluations,...
    (state.generation)/(options.max_generations),...
    sum(state.runtime_per_gen)/options.max_runtime,...
    state.stall_generations/options.max_stall_generations...
  ]);
end

%evaluate function
function [objectives,constraints] = evaluate(state,options)  
    
  designs = state.candidate_tbl;  
  rows = size(designs,1);
  num_obj = options.number_of_objectives;
  num_constr = options.number_of_constraints;
  
  objectives = nan(rows,num_obj);
  constraints = nan(rows,num_constr);  
  objFun = options.analysisFunction;
     
  if num_constr > 0
    parfor i=1:rows
      [objectives(i,:),constraints(i,:)] = objFun(designs(i,:));
    end
  else
    parfor i=1:rows
      objectives(i,:) = objFun(designs(i,:));
    end
  end
end

%cleanup function
function state = cleanup(state,options)
  
  %indicate cause of stopping
  if ~isempty(options.outputFunction)
    if sum(state.evaluations_per_gen) >= options.max_evaluations
      disp('Max number of evaluations reached.');
    elseif state.generation >= options.max_generations
      disp('Max number of generations reached.');
    elseif sum(state.runtime_per_gen) >= options.max_runtime
      disp('Max amount of time reached.');
    elseif state.stall_generations >= options.max_stall_generations
      disp('Max number of stall generations reached.');
    elseif state.hypervolumes(end) >= options.hypervolume_target
      disp('Hypervolume target reached.');
    end
  end
  
end
