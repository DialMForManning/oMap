CREATE TABLE books (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  reader_id INTEGER,

  FOREIGN KEY(reader_id) REFERENCES reader(id)
);

CREATE TABLE readers (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  library_id INTEGER,

  FOREIGN KEY(library_id) REFERENCES reader(id)
);

CREATE TABLE libraries (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

INSERT INTO
  libraries (id, name)
VALUES
  (1, "Brooklyn Public"), (2, "Boston Public");

INSERT INTO
  readers (id, fname, lname, library_id)
VALUES
  (1, "Atrus", "Pelopnus", 1),
  (2, "Katran", "Phrygia", 1),
  (3, "Gehn", "Mycenaen", 2),
  (4, "Achenar", "Pelopnus", NULL);

INSERT INTO
  books (id, title, reader_id)
VALUES
  (1, "Releeshan", 1),
  (2, "Riven", 2),
  (3, "Haven", 3),
  (4, "Fifth Age", 3),
  (5, "Spire", NULL);
