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

INSERT INTO albums (id, name, band_id) VALUES (1, "Sticky Fingers", 1);
INSERT INTO albums (id, name, band_id) VALUES (2, "Greatest Hits", 2);
INSERT INTO albums (id, name, band_id) VALUES (3, "El Camino", 3);

INSERT INTO tracks (name, album_id) VALUES ("Sympathy with the Devil", 1);
INSERT INTO tracks (name, album_id) VALUES ("Gimme Shelter", 1);
INSERT INTO tracks (name, album_id) VALUES ("Can't always get what you want", 1);
INSERT INTO tracks (name, album_id) VALUES ("Lonely Boy", 2);
INSERT INTO tracks (name, album_id) VALUES ("Tighten Up", 2);
