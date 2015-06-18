#ifndef SPECIES_H
#define SPECIES_H

class Species
{
private:
    int topFitness;
    int averageFitness;
    int staleness;
    vector<Genome> genomes;

public:
    Species();
};

#endif // SPECIES_H
