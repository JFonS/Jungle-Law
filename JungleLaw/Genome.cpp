#include "Genome.h"

const float Genome::mutateConnectionsChance = 0.25;
const float Genome::minkMutationChance = 0.9;
const float Genome::biasMutationChance = 0.75;
const float Genome::nodeMutationChance = 2.0;
const float Genome::enableMutationChance = 0.5;
const float Genome::disableMutationChance = 0.4;
const float Genome::stepSize = 0.1;

Genome::Genome()
{
    genes = vector<Gene>();
    fitness = adjustedFitness = maxneuron = globalRank = 0;
    // TO-DO network network = {}


}

Genome Genome::BasicGenome()
{
    Genome g;
    g.
}
