sdoGA
=====

System Design Optimization Lab's Genetic Algorithm (sdoGA)

sdoGA is a genetic algorithm that is written in Matlab and designed for easy customization. To use, pass in the analysis function along with the optional options and state structures.

    [state,options] = sdoGA(analysisFunction[,options,state])

To continue from a previous run, just update the convergence criteria in the options structure and pass it in along with the previous state structure.

    [state,options] = GA(analysisFunction,options,state)

To customize the algorithm you can change the items in the options structure. To get a default options structure, run the following command.

    options = utility.setOptions();
