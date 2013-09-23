function options = setOptions(options)
  %To customize the algorithm you can change the items in the options and
  %structure listed below. You also get a default options structure by running
  %the following command.
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
  
  %TODO be able to parse options coming in as cells -> {'max_runtime',100}
  %TODO might go back to reproductionFunction instead of crossover and mutation
  
  %check for input
  if ~exist('options','var') || ~isstruct(options)
    options = struct;
  end
  
  %function used to calculate objective and constraint value(s)
  if ~isfield(options,'analysisFunction')
    options.analysisFunction = {};
  end
  
  %number of objectives in problem
  if ~isfield(options,'number_of_objectives') || isempty(options.number_of_objectives)
    if isempty(options.analysisFunction)
      options.number_of_objectives = [];
    else
      user_input = inputdlg('options.number_of_objectives not set! Enter number of objectives:');
      options.number_of_objectives = str2double(user_input{1});
    end
  end
  
  %number of constraints in problem
  if ~isfield(options,'number_of_constraints') || isempty(options.number_of_constraints)
    if isempty(options.analysisFunction)
      options.number_of_constraints = [];
    else
      user_input = inputdlg('options.number_of_constraints not set! Enter number of constraints:');
      options.number_of_constraints = str2double(user_input{1});
    end
  end
  
  %number of variables in design string
  if ~isfield(options,'number_of_variables') || isempty(options.number_of_variables)
    if isempty(options.analysisFunction)
      options.number_of_variables = [];
    else
      user_input = inputdlg('options.number_of_variables not set! Enter number of variables:');
      options.number_of_variables = str2double(user_input{1});
    end
  end
  
  %binary string indicating which variables are discrete
  if ~isfield(options,'discrete_variables') || isempty(options.discrete_variables)
    if isempty(options.number_of_variables)
      options.discrete_variables = [];
    else
      options.discrete_variables = false(1,options.number_of_variables);
    end
  end
  
  %lower bound on the design string
  if ~isfield(options,'variable_lower_bound') || isempty(options.variable_lower_bound)
    if isempty(options.number_of_variables)
      options.variable_lower_bound = [];
    else
      options.variable_lower_bound = -Inf(1,options.number_of_variables);
    end
  end
  
  %upper bound on the design string
  if ~isfield(options,'variable_upper_bound') || isempty(options.variable_upper_bound)
    if isempty(options.number_of_variables)
      options.variable_upper_bound = [];
    else
      options.variable_upper_bound = Inf(1,options.number_of_variables);
    end    
  end
  
  %point in the objective space that hypervolume is measured from
  if ~isfield(options,'reference_point') || isempty(options.reference_point)
    options.reference_point = [];
  end
  
  %number of designs in population each generation
  if ~isfield(options,'population_size') || isempty(options.population_size)
    if isempty(options.number_of_variables)
      options.population_size = [];
    else
      options.population_size = 10*options.number_of_variables;
    end
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
  
  %set the default initialization function
  if ~isfield(options,'initializationFunction')
    options.initializationFunction = {@initialization.latinHypercube};
  elseif isemptyc(options.initializationFunction)
    options.initializationFunction = {};
  elseif isa(options.initializationFunction,'function_handle')
    options.initializationFunction = {options.initializationFunction};
  end
  
  %set the default selection function
  if ~isfield(options,'selectionFunction')
    options.selectionFunction = {@selection.tournament};
  elseif  isemptyc(options.selectionFunction)
    options.seclectionFunction = {};
  elseif isa(options.selectionFunction,'function_handle')
    options.selectionFunction = {options.selectionFunction};
  end
  
  %set the default crossover function
  if ~isfield(options,'crossoverFunction')
    options.crossoverFunction = {@crossover.scattered};
  elseif  isemptyc(options.crossoverFunction)
    options.crossoverFunction = {};
  elseif isa(options.crossoverFunction,'function_handle')
    options.crossoverFunction = {options.crossoverFunction};
  end
  
  %set the default mutation function
  if ~isfield(options,'mutationFunction')
    options.mutationFunction = {@mutation.uniform};
  elseif  isemptyc(options.mutationFunction)
    options.mutationFunction = {};
  elseif isa(options.mutationFunction,'function_handle')
    options.mutationFunction = {options.mutationFunction};
  end
  
  %set default preprocess function
  if ~isfield(options,'preprocessFunction')
    options.preprocessFunction = {@preprocess.exactMatchTrim};
  elseif  isemptyc(options.preprocessFunction)
    options.preprocessFunction = {};
  elseif isa(options.preprocessFunction,'function_handle')
    options.preprocessFunction = {options.preprocessFunction};
  end
  
  %set default output function
  if ~isfield(options,'outputFunction')
    options.outputFunction = {@output.iteration};
  elseif  isemptyc(options.outputFunction)
    options.outputFunction = {};
  elseif isa(options.outputFunction,'function_handle')
    options.outputFunction = {options.outputFunction};
  end
  
  %set default other function to empty
  if ~isfield(options,'otherFunction') || isemptyc(options.otherFunction)
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
  
end

function result = isemptyc(cell)
  if isa(cell,'cell')
    result = all(cellfun(@isempty,cell));
  else
    result = isempty(cell);
  end
end