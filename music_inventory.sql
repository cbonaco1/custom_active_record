CREATE TABLE bands (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

CREATE TABLE albums (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  band_id INTEGER,

  FOREIGN KEY(band_id) REFERENCES bands(id)
);

CREATE TABLE tracks (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  album_id INTEGER,

  FOREIGN KEY(album_id) REFERENCES albums(id)
);

INSERT INTO bands (id, name) VALUES (1, "The Rolling Stones");
INSERT INTO bands (id, name) VALUES (2, "The Black Keys");
INSERT INTO bands (id, name) VALUES (3, "The Beatles");
INSERT INTO bands (id, name) VALUES (4, "Struggling Band");

INSERT INTO albums (id, name, band_id) VALUES (1, "Sticky Fingers", 1);
INSERT INTO albums (id, name, band_id) VALUES (2, "Revolver", 3);
INSERT INTO albums (id, name, band_id) VALUES (3, "Greatest Hits", 3);
INSERT INTO albums (id, name, band_id) VALUES (4, "El Camino", 2);

INSERT INTO tracks (id, name, album_id) VALUES (1, "Sympathy for the Devil", 1);
INSERT INTO tracks (id, name, album_id) VALUES (2, "Gimme Shelter", 1);
INSERT INTO tracks (id, name, album_id) VALUES (3, "Can't always get what you want", 1);
INSERT INTO tracks (id, name, album_id) VALUES (4, "Lonely Boy", 2);
INSERT INTO tracks (id, name, album_id) VALUES (5, "Tighten Up", 2);
