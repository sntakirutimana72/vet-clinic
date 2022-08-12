-- Insert data into owners table
INSERT INTO owners (full_name, age)
VALUES 
  ('Sam Smith', 34),
  ('Jennifer Orwell', 19),
  ('Bob', 45),
  ('Melody Pond', 77),
  ('Dean Winchester', 14),
  ('Jodie Whittaker', 38);

-- Insert data into species table
INSERT INTO species (name) VALUES ('Pokemon'), ('Digimon');

-- Insert data into animals table
INSERT INTO 
  animals (name, date_of_birth, species_id, owner_id, escape_attempts, neutered, weight_kg)
VALUES 
  ('Agumon', '2020-02-03', 2, 1, 0, TRUE, 10.23),
  ('Gabumon', '2018-11-15', 2, 2, 2, TRUE, 8),
  ('Pikachu', '2021-01-07', 1, 2, 1, FALSE, 15.04),
  ('Devimon', '2017-05-12', 2, 3, 5, TRUE, 11),
  ('Charmander', '2020-02-08', 1, 4, 0, FALSE, -11),
  ('Plantmon', '2021-11-15', 2, 3, 2, TRUE, -5.7),
  ('Squirtle', '1993-04-02', 1, 4, 3, FALSE, -12.13),
  ('Angemon', '2005-06-12', 2, 5, 1, TRUE, -45),
  ('Boarmon', '2005-06-07', 2, 5, 7, TRUE, 20.4),
  ('Blossom', '1998-08-13', 2, 4, 3, TRUE, 17),
  ('Ditto', '2022-05-14', 1, NULL, 4, TRUE, 22);
