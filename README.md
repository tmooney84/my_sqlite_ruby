# Welcome to My Sqlite
***

## Task
my_sqlite is a light weight database program written in Ruby that includes SELECT, INSERT, UPDATE and DELETE functionality to make use of CSV databases. It allows the user to manipulate the information using  inner joins, WHERE and ORDER BY as well.

## Description
This application is comprised of a command-line parsing interface file (my_sqlite_cli.rb) and a second file that houses the SQL logic for performing CRUD functionality on CSV tables.

## Installation
Clone the my_sqlite reposity using SSH:

```bash
git clone git@git.us.qwasar.io:my_sqlite_196364_zb4-2n/my_sqlite.git
```

## Usage
Ruby needs to be installed on your system in order to use this application. See Ruby's official documentation for more details: https://www.ruby-lang.org/en/documentation/installation/

-nba_player_data.csv is a mock table for demonstrating the program's functionality

In order to start the program run:

```bash
cd lib      # program code and demo csv files are housed in the "lib" directory

ruby my_sqlite_cli.rb
```

Enter in the SQL Query that you would like to run:
```
--SELECT functionality--
my_sqlite> SELECT name FROM nba_player_data.csv WHERE year_start = 1971;

--SELECT functionality with JOIN and DESC
my_sqlite> SELECT name, team_name FROM nba_players.csv JOIN teams.csv ON nba_players.team_id = teams.team_id ORDER BY team_name DESC;

--INSERT functionality--
INSERT INTO teams.csv (team_id, team_name) VALUES ("100", "Boston Celtics");

--UPDATE functionality--
UPDATE teams.csv SET team_name="Golden State Warriors" WHERE team_id="3";

--DELETE functionality--
my_sqlite> DELETE FROM teams.csv WHERE team_name="Los Angeles Lakers";
```

To quit the program:
```
my_sqlite> quit
```

### The Core Team


<span><i>Made at <a href='https://qwasar.io'>Qwasar SV -- Software Engineering School</a></i></span>
<span><img alt='Qwasar SV -- Software Engineering School's Logo' src='https://storage.googleapis.com/qwasar-public/qwasar-logo_50x50.png' width='20px' /></span>
