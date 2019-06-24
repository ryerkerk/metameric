### Selection Operators

This folder contains the selection operators described in Chapter 7 of the dissertation. The selection operator will accept the parent and child populations as inputs, and then return a subset of these solutions as the new parent population. 

Two selection operators are provided, `Selection_LengthNiching` and `Selection_NoNiching`, one of these must be defined in `params.selectionOperator`. Different variations of these operators are possible by using different window functions (if necessary) and different local selection operators. 

If `Selection_LengthNiching` is used then one of the window functions needs to be defined in `params.windowFunction`. This function will return a set of solutions lengths at which niches should be formed. If `Selection_NoNiching` is used then a single niche is formed with all solutions in the combined parent/child population.

Once the niches are formed local selection occurs. `params.localSelectionOperator` defines the function handle to be used. Three local selection operators are provided here. `LocalSelection_Greedy` selects the N best solutions from each niche, note that this operator is not used in the dissertation. `LocalSelection_Tournament` performs tournament selection on each niche, and `LocalSelection_Score` performs score selection as described in Section 7.3.2. 

`RecordBest` is used by each selection operator in order to determine and record the fitness, constraint violation penalty, and length of the best solution in the combined parent/child population. `DetermineNicheSize` calculates the number of solutions that should be selected from each niche. 