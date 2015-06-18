#ifndef POOL_H
#define POOL_H

class Pool
{
private:
    vector<Species> species;
    int generation;
    int innovation;
    int currentSpecies;
    int currentGenome;
    int maxFitness;

public:
    Pool();

};

#endif // POOL_H
