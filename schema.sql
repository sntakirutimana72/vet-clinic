/* Database schema to keep the structure of entire database. */

CREATE DATABASE vet_clinic;

\c vet_clinic;

CREATE TABLE IF NOT EXISTS vets (
  id                 INT GENERATED ALWAYS AS IDENTITY,
  name               VARCHAR(100),
  age                INT,
  date_of_graduation DATE NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS species (
  id   INT GENERATED ALWAYS AS IDENTITY,
  name VARCHAR(40) NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS specializations (
  species_id INT,
  vet_id     INT,
  PRIMARY KEY (species_id, vet_id),
  FOREIGN KEY (vet_id) REFERENCES vets (id) ON DELETE CASCADE,
  FOREIGN KEY (species_id) REFERENCES species (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS owners (
  id        INT GENERATED ALWAYS AS IDENTITY,
  full_name VARCHAR(255) NOT NULL,
  age       INT NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS animals (
  id              INT GENERATED ALWAYS AS IDENTITY, 
  name            VARCHAR(100) NOT NULL,
  date_of_birth   DATE NOT NULL,
  escape_attempts INT NOT NULL,
  neutered        BOOLEAN NOT NULL,
  weight_kg       FLOAT NOT NULL,
  PRIMARY KEY(id)
);

ALTER TABLE animals ADD species VARCHAR(40);

BEGIN;
ALTER TABLE animals DROP species;
ALTER TABLE animals ADD species_id INT REFERENCES species (id);
ALTER TABLE animals ADD owner_id INT REFERENCES owners (id);
COMMIT;

CREATE TABLE IF NOT EXISTS visits (
  animal_id       INT,
  vet_id          INT,
  visitation_date DATE NOT NULL,
  PRIMARY KEY (animal_id, vet_id, visitation_date),
  FOREIGN KEY (vet_id) REFERENCES vets (id) ON DELETE CASCADE,
  FOREIGN KEY (animal_id) REFERENCES animals (id) ON DELETE CASCADE
);
