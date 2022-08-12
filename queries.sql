--------------------------------------------------------------------------
-- MILESTONE 1
--------------------------------------------------------------------------

-- all animals whose name ends in "mon"
SELECT * FROM animals WHERE name LIKE '%mon';

-- name of all animals born between 2016 and 2019
SELECT name FROM animals 
  WHERE EXTRACT(YEAR FROM date_of_birth) BETWEEN 2016 AND 2019;

-- name of all animals that are neutered and have less than 3 escape attempts
SELECT name FROM animals WHERE neutered AND escape_attempts < 3;

-- date of birth of all animals named either "Agumon" or "Pikachu"
SELECT date_of_birth FROM animals WHERE name IN ('Agumon', 'Pikachu');

-- name and escape attempts of animals that weigh more than 10.5kg
SELECT name, escape_attempts FROM animals WHERE weight_kg > 10.5;

-- all animals that are neutered
SELECT * FROM animals WHERE neutered;

-- all animals not named Gabumon
SELECT * FROM animals WHERE name <> 'Gabumon';

/* 
all animals with a weight between 10.4kg and 17.3kg 
(including the animals with the weights that equals precisely 10.4kg or 17.3kg)
*/
SELECT * FROM animals WHERE weight_kg BETWEEN 10.4 AND 17.3;

--------------------------------------------------------------------------
-- MILESTONE 2
--------------------------------------------------------------------------

-- Queries for modifying schema 

/*
Inside a transaction update the animals table by setting the species column to `unspecified`. 
Verify that change was made. Then roll back the change and verify that 
the species columns went back to the state before the transaction.
*/
BEGIN;
UPDATE animals SET species = 'unspecified';
ROLLBACK;

/*
Inside a transaction:
  - Update the animals table by setting the species column to `digimon` 
    for all animals that have a name ending in `mon`.
  - Update the animals table by setting the species column to `pokemon` 
    for all animals that don't have species already set.
  - Commit the transaction.
*/
BEGIN;
UPDATE animals SET species = 'digimon' WHERE name LIKE '%mon';
UPDATE animals SET species = 'pokemon' WHERE species IS NULL;
COMMIT;

/* 
Inside a transaction delete all records in the animals table, 
then roll back the transaction.
*/
BEGIN;
DELETE FROM animals;
ROLLBACK;

-- compound tranctions
BEGIN;
DELETE FROM animals WHERE date_of_birth > DATE '2022-01-01';
SAVEPOINT NOTTA;
UPDATE animals SET weight_kg = weight_kg * -1;
ROLLBACK TO SAVEPOINT NOTTA;
UPDATE animals SET weight_kg = weight_kg * -1 WHERE weight_kg < 0;
COMMIT;

--------------------------------------------------------------------------

-- Queries for analytics 

-- How many animals are there?
SELECT COUNT(*) total_animals FROM animals;

-- How many animals have never tried to escape?
SELECT COUNT(*) total_animals_with_zero_escape_attempts 
FROM animals 
WHERE escape_attempts = 0;

-- What is the average weight of animals?
SELECT AVG(weight_kg) mean_weight FROM animals;

-- Who escapes the most, neutered or not neutered animals?
SELECT neutered, SUM(escape_attempts) total_attempts 
FROM animals 
GROUP BY neutered 
ORDER BY total_attempts DESC;

-- What is the minimum and maximum weight of each type of animal?
SELECT species, MIN(weight_kg) min_weight, MAX(weight_kg) max_weight
FROM animals 
GROUP BY species;

/*
What is the average number of escape attempts per animal type 
of those born between 1990 and 2000?
*/
SELECT species, AVG(escape_attempts) mean_escape 
FROM animals 
WHERE EXTRACT(YEAR FROM date_of_birth) BETWEEN 1990 AND 2000 
GROUP BY species;
