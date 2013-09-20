clear
clc

%a simple example of how to setup and run the SDO Genetic Algorithm

%first lets grab the default options structure
options = utility.setOptions();

%lets tell it how many many objectives, constraints, and variables are in the
%example problem
options.number_of_objectives = 1;
options.number_of_constraints = 0;
options.number_of_variables = 2;

%now lets update it so that it plots the convergence along with the iteration 
%text output. Note that multiple functions are entered using a cell array. The 
%algorithm will execute them in the order of their entry.
options.outputFunction = {@output.iteration, @output.convergence};

%if we define the bounds on the design space the algorithm should do better.
%In this exampel we have 2 design variables.
options.variable_lower_bound = [-1,-2.5];
options.variable_upper_bound = [2.5,1];

%Now we can solve our objective function, which in this example is a simple 
%2-norm calculation. To do this we call the main algorithm function and pass in
%a handle to the objective function (i.e. @norm) as well as the updated options
%structure. Once the algorithm finished the final state structure is returned.
state = sdoGA(@norm,options);

%If we wanted to restart the algorithm from its current points we would simply 
%update any convergence criteria in the options structure and run the main
%the main algorithm function again. Assume the algorithm stopped because it ran
%out of time. The reason you have to increase the options maximum amount is due
%to the state structure retaining the previous information. This is by design as 
%it allows you to keep track of ALL the work needed to find the optimal design.
%The only exceptions to this rule are the number of stall generations and the
%convergence fraction in the state structure. These values WILL reset each time 
%the algorithm is called. This means you do NOT have to increase the maximum 
%number of stall generations in the options.
options.max_runtime = 120; %previous setting was 60 seconds

%We can then pass in this updated options structure as well as the previously
%found state structure to continue running the algorithm.
state = sdoGA(@norm,options,state);

%Finally, if we want to see just the optimal designs and performance we can use
%a utility function. In this case we are grabbing the optimal design values as
%well as the associated objective values. We expect the optimum to occur at 0,0. 
x = state.variable_tbl(state.optimal_index,:);
f = state.objective_tbl(state.optimal_index,:);






