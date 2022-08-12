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

--------------------------------------------------------------------------
-- MILESTONE 3
--------------------------------------------------------------------------

-- Queries for analytics 

-- What animals belong to Melody Pond?
SELECT anim.* FROM animals anim 
  JOIN owners boss ON boss.id = anim.owner_id 
WHERE boss.full_name = 'Melody Pond';

-- List of all animals that are pokemon (their type is Pokemon).
SELECT anim.* FROM animals anim 
  JOIN species sp ON sp.id = anim.species_id  
WHERE sp.name = 'Pokemon';

-- List all owners and their animals, remember to include those that don't own any animal.
SELECT name animal_name, full_name owner_name FROM owners boss 
  LEFT JOIN animals anim ON anim.owner_id = boss.id 
ORDER BY boss.id, boss.full_name;

-- How many animals are there per species?
SELECT sp.name species, COUNT(anim.species_id) animals_by_species 
FROM animals anim 
  JOIN species sp ON sp.id = anim.species_id 
GROUP BY sp.name, anim.species_id;

-- List all Digimon owned by Jennifer Orwell.
SELECT anim.* FROM animals anim 
  JOIN owners boss ON boss.id = anim.owner_id 
  JOIN species sp ON sp.id = anim.species_id 
WHERE boss.full_name = 'Jennifer Orwell' AND sp.name = 'Digimon';

-- List all animals owned by Dean Winchester that haven't tried to escape.
SELECT anim.* FROM animals anim 
  JOIN owners boss ON boss.id = anim.owner_id 
WHERE boss.full_name = 'Dean Winchester' AND anim.escape_attempts = 0;

-- Who owns the most animals?
SELECT T.*
FROM (
  SELECT boss.*, COUNT(boss.id) total_animals 
  FROM owners boss
  JOIN animals anim 
    ON anim.owner_id = boss.id 
  GROUP BY boss.id
) AS T 
GROUP BY T.id, T.full_name, T.age, T.total_animals   
HAVING T.total_animals = (
  SELECT MAX(T3.total) 
  FROM (
    SELECT COUNT(bs.id) total
    FROM owners bs
    JOIN animals ai 
      ON ai.owner_id = bs.id 
    GROUP BY bs.id
  ) AS T3 
);
