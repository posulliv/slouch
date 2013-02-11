CREATE TABLE hopes
(
  id SERIAL PRIMARY KEY,
  "desc" VARCHAR(256) NOT NULL,
  "date" VARCHAR(128),
  bumpCount INT
);
