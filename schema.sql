/* Database schema to keep the structure of entire database. */

CREATE DATABASE vet_clinic;

\c vet_clinic;

CREATE TABLE IF NOT EXISTS owners (
  id        INT GENERATED ALWAYS AS IDENTITY,
  full_name VARCHAR(255) NOT NULL,
  age       INT NOT NULL,
  PRIMARY KEY(id)
);

CREATE TABLE IF NOT EXISTS species (
  id   INT GENERATED ALWAYS AS IDENTITY,
  name VARCHAR(40) NOT NULL,
  PRIMARY KEY(id)
);

CREATE TABLE IF NOT EXISTS animals (
  id              INT GENERATED ALWAYS AS IDENTITY, 
  name            VARCHAR(100) NOT NULL,
  species_id      INT,
  owner_id        INT,
  date_of_birth   DATE NOT NULL,
  escape_attempts INT NOT NULL,
  neutered        BOOLEAN NOT NULL,
  weight_kg       FLOAT NOT NULL,
  PRIMARY KEY(id),
  CONSTRAINT fk_species
    FOREIGN KEY(species_id) 
      REFERENCES species(id) 
      ON DELETE SET NULL,
  CONSTRAINT fk_owners
    FOREIGN KEY(owner_id) 
      REFERENCES owners(id) 
      ON DELETE SET NULL
);
