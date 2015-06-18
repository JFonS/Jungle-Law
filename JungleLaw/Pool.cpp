#include "Pool.h"

Pool::Pool()
{
    species = vector<Species>();
    generation = maxFitness = 0;
    pool.innovation = nOutputs;
    currentSpecies = currentGenome = 1;
}
