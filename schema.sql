/* Database schema to keep the structure of entire database. */

CREATE DATABASE vet_clinic;

\c vet_clinic;

CREATE TABLE IF NOT EXISTS animals(
  id              int GENERATED ALWAYS AS IDENTITY, 
  name            varchar(100) not null,
  date_of_birth   date not null,
  escape_attempts int not null,
  neutered        boolean not null,
  weight_kg       float not null,
  PRIMARY KEY(id)
);
