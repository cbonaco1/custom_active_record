# Schema Information for Music database

## bands
column name | data type | details
------------|-----------|-----------------------
id          | integer   | not null, primary key
name        | string    | not null

## albums
column name | data type | details
------------|-----------|-----------------------
id          | integer   | not null, primary key
name        | string    | not null
band_id     | integer   | not null, foreign key (references band)

## tracks
column name | data type | details
------------|-----------|-----------------------
id          | integer   | not null, primary key
name        | string    | not null
album_id    | integer   | not null, foreign key (references album)
