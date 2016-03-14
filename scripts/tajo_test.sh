#!/usr/bin/env bash

export PROJ_DIR=/home/vagrant
export SERVERS=/vagrant/servers
export JAVA_HOME=/usr/lib/jvm/java-8-oracle
export HADOOP_HOME=/vagrant/servers/hadoop-2.7.2
export TAJO_MASTER_HEAPSIZE=1000
export TAJO_HOME=/vagrant/servers/tajo-0.11.1
export TAJO_WORKER_HEAPSIZE=5000
export TAJO_PID_DIR=${TAJO_HOME}/pids
export TAJO_LOG_DIR=${TAJO_HOME}/logs

wget http://files.grouplens.org/datasets/movielens/ml-1m.zip
unzip ml-1m.zip

exit 0;

# upload files
default> \dfs -mkdir /movielens/movies
default> \dfs -mkdir /movielens/ratings
default> \dfs -put ml-1m/movies.dat /movielens/movies
default> \dfs -put ml-1m/ratings.dat /movielens/ratings

# checkout files in hdfs
default> \dfs -ls /movielens
Found 2 items
drwxr-xr-x   - hadoop supergroup          0 2016-02-26 14:06 /movielens/movies
drwxr-xr-x   - hadoop supergroup          0 2016-02-26 14:06 /movielens/ratings
default> \dfs -ls /movielens/movies
Found 1 items
-rw-r--r--   1 hadoop supergroup     171308 2016-02-26 14:06 /movielens/movies/movies.dat

# access db
default> create database movie_lens;
OK
default> \c movie_lens;
You are now connected to database "movie_lens" as user "hadoop".

# create tables
movie_lens> CREATE EXTERNAL TABLE ratings (
 user_id INT ,
 movie_id INT ,
 rating INT ,
 rated_at INT
) USING TEXT WITH ('text.delimiter'='::') LOCATION 'hdfs://192.168.82.170:9010/movielens/ratings/';

movie_lens> CREATE EXTERNAL TABLE movies (
  movie_id INT,
  title TEXT,
  genres TEXT
) USING TEXT WITH ('text.delimiter'='::') LOCATION 'hdfs://192.168.82.170:9010/movielens/movies/';

# query sample data
movie_lens> select * from movies limit 5;
movie_id,  title,  genres
-------------------------------
1,  Toy Story (1995),  Animation|Children's|Comedy
2,  Jumanji (1995),  Adventure|Children's|Fantasy
3,  Grumpier Old Men (1995),  Comedy|Romance
4,  Waiting to Exhale (1995),  Comedy|Drama
5,  Father of the Bride Part II (1995),  Comedy
(5 rows, 0.013 sec, 0 B selected)

# query ratings count
movie_lens> select count(*) from ratings;
Progress: 100%, response time: 0.565 sec
?count
-------------------------------
1000209
(1 rows, 0.565 sec, 16 B selected)

# query join query
movie_lens> SELECT a.user_id, a.movie_id, b.title, a.rating, to_char(to_timestamp(a.rated_at), 'YYYY-MM-DD HH24:MI:SS') as rated_at
from ratings a, movies b
where a.movie_id = b.movie_id
limit 5;
user_id,  movie_id,  title,  rating,  rated_at
-------------------------------
1,  1193,  One Flew Over the Cuckoo's Nest (1975),  5,  2001-01-01 07:12:40
1,  661,  James and the Giant Peach (1996),  3,  2001-01-01 07:35:09
1,  914,  My Fair Lady (1964),  3,  2001-01-01 07:32:48
1,  3408,  Erin Brockovich (2000),  4,  2001-01-01 07:04:35
1,  2355,  Bug's Life, A (1998),  5,  2001-01-07 08:38:11
(5 rows, 1.519 sec, 446 B selected)

exit 0
