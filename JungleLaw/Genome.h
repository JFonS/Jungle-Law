#ifndef GENOME_H
#define GENOME_H

class Genome
{
private:

    static extern float mutateConnectionsChance;
    static extern float minkMutationChance;
    static extern float biasMutationChance;
    static extern float nodeMutationChance;
    static extern float enableMutationChance;
    static extern float disableMutationChance;
    static extern float stepSize;

public:
    vector<Gene> genes;
    int fitness;
    int adjustedFitness;
    // TO-DO network network = {}
    int maxneuron;
    int globalRank;

    Genome();
    static Genome BasicGenome();
};

#endif // GENOME_H
