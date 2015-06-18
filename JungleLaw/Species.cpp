#include "Species.h"

Species::Species()
{
    topFitness = averageFitness = staleness = 0;
    genomes = vector<Genome>();
}
