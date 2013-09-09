sdoGA
=====

System Design Optimization Lab's Genetic Algorithm (sdoGA)

sdoGA is a genetic algorithm that is written in Matlab and designed for easy customization. To use, pass in the objective function along with the optional options and state structures.

    [state,options] = sdoGA(objectiveFunction[,options,state])

To continue from a previous run, just update the convergence criteria in the options structure and pass it in along with the previous state structure.

    [state,options] = GA(objectiveFunction,options,state)

To customize the algorithm you can change the items in the options structure. You also get a default options structure by running the following command.

    options = utility.setOptions();
