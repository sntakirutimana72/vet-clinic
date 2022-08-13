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

--------------------------------------------------------------------------
-- MILESTONE 4
--------------------------------------------------------------------------

-- Queries for analytics

/*
Who was the last animal seen by William Tatcher?
How many different animals did Stephanie Mendez see?
List all vets and their specialties, including vets with no specialties.
List all animals that visited Stephanie Mendez between April 1st and August 30th, 2020.
What animal has the most visits to vets?
Who was Maisy Smith's first visit?
Details for most recent visit: animal information, vet information, and date of visit.
How many visits were with a vet that did not specialize in that animal's species?
What specialty should Maisy Smith consider getting? Look for the species she gets the most.
*/

-- Who was the last animal seen by William Tatcher?
SELECT X.name animal_name, X.last_visit last_visit_date
FROM (
  SELECT A.name, V.name vet_name, T.visitation_date last_visit
  FROM visits T 
    JOIN vets V ON V.id = T.vet_id 
    JOIN animals A ON A.id = T.animal_id 
  WHERE V.name = 'William Tatcher'
  GROUP BY T.vet_id, A.name, vet_name, T.visitation_date
) AS X
GROUP BY X.name, X.last_visit, X.vet_name   
HAVING X.last_visit = (
  SELECT MAX(visitation_date) FROM visits T2 
  JOIN vets V2 ON V2.id = T2.vet_id 
  WHERE V2.name = 'William Tatcher'
  GROUP BY T2.vet_id
)
ORDER BY X.vet_name;

-- How many different animals did Stephanie Mendez see?
SELECT SX.name species, COUNT(A.species_id) FROM visits T
  JOIN vets V ON V.id = T.vet_id 
  JOIN animals A ON A.id = T.animal_id 
  JOIN (
    SELECT A2.id, S2.name FROM animals A2 
      JOIN species S2 ON S2.id = A2.species_id 
    GROUP BY S2.id, A2.id
  ) AS SX
  ON SX.id = T.animal_id
WHERE V.name = 'Stephanie Mendez' 
GROUP BY A.species_id, SX.name;

-- List all vets and their specialties, including vets with no specialties.
SELECT V.id, V.name vet_name, SX.specialties FROM vets V 
  LEFT JOIN (
    SELECT T.vet_id, SP.name specialties FROM specializations T
      JOIN species SP ON SP.id = T.species_id
  ) AS SX
  ON SX.vet_id = V.id 
ORDER BY V.id;

-- List all animals that visited Stephanie Mendez between April 1st and August 30th, 2020.
SELECT A.id, A.name animal_name, T.visitation_date 
FROM visits T
  JOIN animals A ON A.id = T.animal_id 
  JOIN vets V ON V.id = T.vet_id 
WHERE 
  V.name = 'Stephanie Mendez' AND 
  T.visitation_date BETWEEN DATE '2020-04-01' AND DATE '2020-08-30'
ORDER BY T.visitation_date;

-- What animal has the most visits to vets?
SELECT A.id, A.name animal_name, COUNT(T.animal_id) most_visits 
FROM visits T 
  JOIN animals A ON A.id = T.animal_id 
GROUP BY A.id, A.name 
HAVING COUNT(T.animal_id) = (
  SELECT MAX(T2.count) 
  FROM (
    SELECT COUNT(T3.animal_id) FROM visits T3 
    GROUP BY T3.animal_id
  ) T2
);

-- Who was Maisy Smith's first visit?
SELECT X.name animal_name, X.first_visit first_visit_date 
FROM (
  SELECT A.name, V.name vet_name, T.visitation_date first_visit
  FROM visits T 
    JOIN vets V ON V.id = T.vet_id 
    JOIN animals A ON A.id = T.animal_id 
  WHERE V.name = 'Maisy Smith'
  GROUP BY T.vet_id, A.name, vet_name, T.visitation_date
) AS X
GROUP BY X.name, X.first_visit, X.vet_name  
HAVING X.first_visit = (
  SELECT MIN(visitation_date) FROM visits T2 
  JOIN vets V2 ON V2.id = T2.vet_id 
  WHERE V2.name = 'Maisy Smith'
  GROUP BY T2.vet_id
)
ORDER BY (X.vet_name, X.first_visit);

-- Details for most recent visit: animal information, vet information, and date of visit.
SELECT 
  A.id, A.name animal_name, A.weight_kg animal_weight, 
  V.id vet_id, V.name vet_name, T.visitation_date recent_visit_date
FROM visits T 
  JOIN vets V ON V.id = T.vet_id 
  JOIN animals A ON A.id = T.animal_id
WHERE T.visitation_date = (SELECT MAX(visitation_date) FROM visits);

-- How many visits were with a vet that did not specialize in that animal's species?
SELECT COUNT(T.vet_id) total_visits_with_non_specialist 
FROM visits T
  LEFT OUTER JOIN specializations TS ON TS.vet_id = T.vet_id
WHERE TS.vet_id IS NULL
GROUP BY T.vet_id;

-- What specialty should Maisy Smith consider getting? Look for the species she gets the most.
SELECT TX.recommended_speciality, TX.total_visits 
FROM (
  SELECT 
    SP.name recommended_speciality, COUNT(SP.id) total_visits
  FROM visits TS 
    JOIN vets V ON V.id = TS.vet_id
    JOIN animals A ON A.id = TS.animal_id 
    JOIN (
      SELECT A2.id, SPX.name FROM species SPX 
      JOIN animals A2 ON A2.species_id = SPX.id 
    ) SP
    ON SP.id = TS.animal_id
  WHERE V.name = 'Maisy Smith'
  GROUP BY SP.name
) AS TX  
WHERE TX.total_visits = (
  SELECT MAX(TS2.count) 
  FROM (
    SELECT COUNT(A2.species_id) FROM visits T2 
      JOIN vets V2 ON V2.id = T2.vet_id
      JOIN animals A2 ON A2.id = T2.animal_id 
      JOIN (
        SELECT A3.id, SPX2.name FROM species SPX2 
        JOIN animals A3 ON A3.species_id = SPX2.id 
      ) SP2
    ON SP2.id = T2.animal_id
    WHERE V2.name = 'Maisy Smith'
    GROUP BY A2.species_id
  ) TS2
);
