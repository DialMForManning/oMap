CREATE TABLE books (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  reader_id INTEGER,
  library_id INTEGER,

  FOREIGN KEY(reader_id) REFERENCES reader(id)
  FOREIGN KEY(library_id) REFERENCES library(id)
);

CREATE TABLE readers (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
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
  (1, "Myst Island"), (2, "Great Tree Library");

INSERT INTO
  readers (id, name, library_id)
VALUES
  (1, "Atrus", 1),
  (2, "Katran", 1),
  (3, "Gehn", 2),
  (4, "Achenar", NULL);

INSERT INTO
  books (id, title, reader_id, library_id)
VALUES
  (1, "Stoneship", 1, 1),
  (2, "Selentic", 1, 1),
  (3, "Haven", 4, 1),
  (4, "233rd Age", 3, 2),
  (5, "Spire", NULL, NULL);
