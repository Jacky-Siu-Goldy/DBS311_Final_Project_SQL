--******************************************
--Name: Jacky Chun Kit Siu, Song Joo
--ID: 134663186, 171443211
--Purpose: Assignment 2
--Date:23-11-2022
--******************************************


SET SERVEROUTPUT ON;
--4 CRUD Tasks for games table 

--INSERT PROCEDURE
CREATE OR REPLACE PROCEDURE spGamesInsert( 
    game_id games.gameid%TYPE,
    div_id games.divid%TYPE,
    game_num games.gamenum%TYPE,
    gameDandT games.gamedatetime%TYPE,
    homeT games.hometeam%TYPE,
    homeS games.homescore%TYPE,
    visitT games.visitteam%TYPE,
    visitS games.visitscore%TYPE,
    location_id games.locationid%TYPE,
    isPlayed2 games.isplayed%TYPE,
    notes2 games.notes%TYPE,
    errorCode OUT NUMBER)
    AS
BEGIN
    INSERT INTO games
    VALUES(game_id, div_id,game_num, gameDandT, homeT, homeS, visitT, visitS, location_id, isPlayed2, notes2);
    errorCode := 10;
    COMMIT;
EXCEPTION
    WHEN OTHERS
        THEN
        errorCode:=1;
END;

DECLARE
    newErrorCode NUMBER := 0;
BEGIN
spGamesInsert(122,28,91,TO_DATE('23-01-29','yy-mm-dd'),216,0,210,0,80,0,NULL,newErrorCode);
DBMS_OUTPUT.PUT_LINE(newErrorCode);

END;

--UPDATE PROCEDURE
CREATE OR REPLACE PROCEDURE spGamesUpdate(
    game_id NUMBER,
    div_id games.divid%TYPE,
    game_num games.gamenum%TYPE,
    gameDandT games.gamedatetime%TYPE,
    homeT games.hometeam%TYPE,
    homeS games.homescore%TYPE,
    visitT games.visitteam%TYPE,
    visitS games.visitscore%TYPE,
    location_id games.locationid%TYPE,
    isPlayed2 games.isplayed%TYPE,
    notes2 games.notes%TYPE,
    errorCode OUT NUMBER,
    safety NUMBER)AS
BEGIN
    UPDATE games
    SET
        divid = div_id,
        gamenum = game_num,
        gamedatetime = gameDandT,
        hometeam = homeT,
        homescore = homeS,
        visitteam = visitT,
        visitscore = visitS,
        locationid = location_id,
        isplayed = isplayed2,
        notes = notes2
    WHERE
        gameid = game_id;
    errorCode := 10;
    IF SQL%ROWCOUNT = 0 THEN
        errorCode := 2;
    ELSIF SQL%ROWCOUNT = 1 THEN
        COMMIT;
        errorCode := 10;
    ELSE
        IF safety = 1 THEN
            ROLLBACK;
        END IF;
        errorCode := 3;
    END IF;
    
EXCEPTION
    WHEN OTHERS 
        THEN
        errorCode := 1;
END;

DECLARE
    newErrorCode NUMBER := 0;
BEGIN
    spGamesUpdate(122,28,91,TO_DATE('23-02-25', 'yy-mm-dd'),216,0,210,0,80,0,NULL,newErrorCode,1);
    DBMS_OUTPUT.PUT_LINE(newErrorCode);
  
END;

--games DELETE
CREATE OR REPLACE PROCEDURE spGamesDelete( gID games.gameid%TYPE, errorCode OUT NUMBER, safety NUMBER) AS
BEGIN
    
    DELETE FROM games g WHERE g.gameid = gID;
    IF SQL%ROWCOUNT = 0 THEN
        errorCode:= 2;
    ELSIF SQL%ROWCOUNT = 1 THEN
        COMMIT;
        errorCode:= 10;
    ELSE
        IF safety = 1 THEN
            ROLLBACK;
        END IF;
        errorCode := 3;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        errorCode := 1;
END;

DECLARE
    newErrorCode NUMBER := 0;
BEGIN
    spGamesDelete(122, newErrorCode, 1);
    DBMS_OUTPUT.PUT_LINE(newErrorCode);
END;

--Select and return all fields based on pk

CREATE TYPE gamestype AS OBJECT(
    game_id NUMBER(38,0),
    div_id NUMBER(38,0),
    game_num NUMBER(38,0),
    gameDandT DATE,
    homeT NUMBER(38,0),
    homeS NUMBER(38,0),
    visitT NUMBER(38,0),
    visitS NUMBER(38,0),
    location_id NUMBER(38,0),
    isPlayed2 NUMBER(38,0),
    notes2 VARCHAR2(50));
    
CREATE OR REPLACE TYPE gamestypeset AS TABLE OF gamestype;

CREATE OR REPLACE PACKAGE refcur_games IS TYPE refcur_g IS REF CURSOR RETURN games%ROWTYPE;
END refcur_games;

CREATE OR REPLACE FUNCTION gamesoutput(g refcur_games.refcur_g)RETURN gamestypeset
PIPELINED IS
    out_rec gamestype := gamestype(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
    in_rec g%ROWTYPE;
BEGIN
    LOOP
        FETCH g INTO in_rec;
        EXIT WHEN g%NOTFOUND;
        out_rec.game_id := in_rec.gameid;
        out_rec.div_id:= in_rec.divid;
        out_rec.game_num := in_rec.gamenum;
        out_rec.gameDandT := in_rec.gamedatetime;
        out_rec.homeT:= in_rec.hometeam;
        out_rec.homeS:= in_rec.homescore;
        out_rec.visitT:=in_rec.visitteam;
        out_rec.visitS:= in_rec.visitscore;
        out_rec.location_id := in_rec.locationid;
        out_rec.isPlayed2 := in_rec.isplayed;
        out_rec.notes2:= in_rec.notes;
        PIPE ROW(out_rec);
    END LOOP;
    CLOSE g;
    RETURN;
END;


CREATE OR REPLACE PROCEDURE spGamesSelect(gameID NUMBER,refcursor OUT SYS_REFCURSOR, errorCode OUT NUMBER)AS
BEGIN
        OPEN refcursor
        FOR SELECT * FROM TABLE(gamesoutput(cursor(select*from games ))) WHERE game_id = gameID ; 
        
    errorCode :=10;
EXCEPTION
    WHEN OTHERS 
        THEN
        errorCode := 1;
END;

DECLARE
    newErrorCode NUMBER:=0;
    gamesselect_refcursor refcur_games.refcur_g;
    game_id NUMBER(38,0);
    div_id NUMBER(38,0);
    game_num NUMBER(38,0);
    gameDandT DATE;
    homeT NUMBER(38,0);
    homeS NUMBER(38,0);
    visitT NUMBER(38,0);
    visitS NUMBER(38,0);
    location_id NUMBER(38,0);
    isPlayed2 NUMBER(38,0);
    notes2 VARCHAR2(50);
BEGIN
 spGamesSelect(10,gamesselect_refcursor, newErrorCode);
  DBMS_OUTPUT.PUT_LINE('Error Code: '||newErrorCode);
  DBMS_OUTPUT.PUT_LINE(RPAD('game ID',13,' ')||RPAD('divID',13,' ')||RPAD('game num',13,' ')||RPAD('gameDateTime',13,' ')||
    RPAD('homeTeam',13,' ')||RPAD('homeScore',13,' ')||RPAD('visitTeam',13,' ')||RPAD('visitScore',13,' ')||
    RPAD('location_id',13,' ')||RPAD('isPlayed',13,' ')||RPAD('notes',13,' '));
    LOOP
        FETCH gamesselect_refcursor
        INTO game_id, div_id, game_num, gameDandT, homeT, homeS, visitT, visitS, location_id, isPlayed2, notes2;
        EXIT WHEN gamesselect_refcursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(RPAD(game_id, 13, ' ')||RPAD(div_id,13,' ')||RPAD(game_num,13,' ')||RPAD(gameDandT,13,' ')||
            RPAD(homeT,13,' ')||RPAD(homeS,13,' ')||RPAD(visitT,13,' ')||RPAD(visitS,13,' ')||RPAD(location_id,13,' ')||
            RPAD(isPlayed2,13,' ')||RPAD(NVL(notes2,'null'),13,' '));
    END LOOP;
    CLOSE gamesselect_refcursor;
END;

--4 CRUD tasks for GoalScorers table

--goalscorers INSERT
CREATE OR REPLACE PROCEDURE  spGoalscorersInsert(
    goalId goalscorers.goalid%TYPE,
    gameId goalscorers.gameid%TYPE,
    playerId goalscorers.playerid%TYPE,
    teamId goalscorers.teamid%TYPE,
    numGoals goalscorers.numgoals%TYPE,
    numAssists goalscorers.numassists%TYPE,
    errorCode OUT NUMBER) AS
BEGIN
    INSERT INTO goalscorers
    VALUES(goalId, gameId, playerId, teamId, numGoals, numAssists);
    errorCode := 10;
    COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    errorCode := 1;
END;

DECLARE
    newErrorCode NUMBER := 0;
BEGIN
    spGoalscorersInsert(292,99,2024144,211,9,0,newErrorCode);
    DBMS_OUTPUT.PUT_LINE(newErrorCode);
END;

--goalscorers UPDATE
CREATE OR REPLACE PROCEDURE spgoalscorersUpdate(
    goal_Id NUMBER,
    game_Id goalscorers.gameid%TYPE,
    player_Id goalscorers.playerid%TYPE,
    team_Id goalscorers.teamid%TYPE,
    num_Goals goalscorers.numgoals%TYPE,
    num_Assists goalscorers.numassists%TYPE,
    errorCode OUT NUMBER,
    safety NUMBER) AS
BEGIN
    UPDATE
        goalscorers
    SET
        gameid = game_Id,
        playerid = player_Id,
        teamid = team_Id,
        numgoals = num_Goals,
        numassists = num_Assists
    WHERE
        goalid = goal_Id;
    errorCode := 10;
    IF SQL%ROWCOUNT = 0 THEN
        errorCode := 2;
    ELSIF   SQL%ROWCOUNT = 1 THEN
        COMMIT;
        errorCode := 10;
    ELSE
        IF safety = 1 THEN
            ROLLBACK;
        END IF;
        errorCode := 3;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        errorCode := 1;
END;

DECLARE
    newErrorCode NUMBER := 0;
BEGIN
    spgoalscorersUpdate(292,99,2024144,211,100,0, newErrorCode, 1);
    DBMS_OUTPUT.PUT_LINE(newErrorCode);
END;

--goalscorers Delete

CREATE OR REPLACE PROCEDURE spGoalscorersDelete(goal_ID NUMBER, errorCode OUT NUMBER, safety Number)AS
BEGIN
    DELETE FROM goalscorers WHERE goalid = goal_ID;
    errorCode := 10;
    IF SQL%ROWCOUNT = 0 THEN
        errorCode := 2;
    ELSIF SQL%ROWCOUNT = 1 THEN
        COMMIT;
        errorCode := 10;
    ELSE
        IF safety = 1 THEN
            ROLLBACK;
        END IF;
        errorCode := 3;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        errorCode := 1;
END;

DECLARE
    newErrorCode NUMBER := 0;
BEGIN
    spGoalscorersDelete(292,newErrorCode,1);
    DBMS_OUTPUT.PUT_LINE(newErrorCode);
END;
--goalscorers SELECT
CREATE OR REPLACE TYPE goalscorerstype AS OBJECT(
    goal_id NUMBER(38,0),
    game_id NUMBER(38,0),
    player_id NUMBER(38,0),
    team_id NUMBER(38,0),
    num_goals NUMBER(38,0),
    num_assists NUMBER(38,0)
    );
CREATE OR REPLACE TYPE goalscorerstypeset AS TABLE OF goalscorerstype;
CREATE OR REPLACE PACKAGE refcur_goalscorers IS TYPE refcur_gs IS REF CURSOR RETURN goalscorers%ROWTYPE;
END refcur_goalscorers;

CREATE OR REPLACE FUNCTION goalscorersoutput(gs refcur_goalscorers.refcur_gs)RETURN goalscorerstypeset
PIPELINED IS
    out_rec goalscorerstype := goalscorerstype(NULL,NULL,NULL,NULL,NULL,NULL);
    in_rec gs%ROWTYPE;
BEGIN
    LOOP
        FETCH gs INTO in_rec;
        EXIT WHEN gs%NOTFOUND;
        out_rec.goal_id := in_rec.goalid;
        out_rec.game_id := in_rec.gameid;
        out_rec.player_id := in_rec.playerid;
        out_rec.team_id := in_rec.teamid;
        out_rec.num_goals:= in_rec.numgoals;
        out_rec.num_assists:= in_rec.numassists;
        PIPE ROW(out_rec);
    END LOOP;
    CLOSE gs;
    RETURN;
END;

CREATE OR REPLACE PROCEDURE spGoalscorersSelect(goal_id2 NUMBER, refcursor OUT SYS_REFCURSOR, errorCode OUT NUMBER)AS
BEGIN
    OPEN refcursor
    FOR SELECT * FROM TABLE(goalscorersoutput(CURSOR(SELECT * FROM goalscorers)))WHERE goal_id = goal_id2;
    
    errorCode := 10;
EXCEPTION
    WHEN OTHERS 
        THEN
        errorCode := 1;
END;

DECLARE
    newErrorCode NUMBER := 0;
    goalscorersSelect_refcursor refcur_goalscorers.refcur_gs;
    goalscorersRow goalscorers%ROWTYPE;
    
BEGIN

    spGoalscorersSelect(261,goalscorersSelect_refcursor, newErrorCode);
    DBMS_OUTPUT.PUT_LINE(newErrorCode);
    DBMS_OUTPUT.PUT_LINE(RPAD('goal ID',13,' ')||RPAD('game ID',13,' ')||RPAD('player ID',13,' ')||RPAD('team ID',13,' ')||
    RPAD('num Goals',13,' ')||RPAD('num Assists',13,' '));
    LOOP
        FETCH goalscorersSelect_refcursor
        INTO goalscorersRow;
        EXIT WHEN goalscorersSelect_refcursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(RPAD(goalscorersRow.goalid, 13, ' ')||RPAD(goalscorersRow.gameid,13,' ')||
        RPAD(goalscorersRow.playerid,13,' ')||RPAD(goalscorersRow.teamid,13,' ')||RPAD(goalscorersRow.numgoals,13,' ')||
        RPAD(goalscorersRow.numassists,13,' '));
    END LOOP;
    CLOSE goalscorersSelect_refcursor;
END;

--4 CRUD tasks for Players table
SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE spPlayersInsert(
    player_ID players.playerid%TYPE,
    reg_Num players.regnumber%TYPE,
    last_name players.lastname%TYPE,
    first_name players.firstname%TYPE,
    is_active players.isactive%TYPE,
    errorCode OUT NUMBER)AS
BEGIN
    INSERT INTO players
    VALUES(player_ID, reg_Num, last_name, first_name, is_active);
    errorCode := 10;
EXCEPTION
    WHEN OTHERS THEN
        errorCode:=1;
END;

DECLARE
    newErrorCode NUMBER := 0;
BEGIN
    spPlayersInsert(2024144, 982068, 'Siu', 'Jacky', 1, newErrorCode);
    DBMS_OUTPUT.PUT_LINE(newErrorCode);
END;

--Players Update

CREATE OR REPLACE PROCEDURE spPlayersUpdate(
    player_ID NUMBER,
    reg_Num players.regnumber%TYPE,
    last_name players.lastname%TYPE,
    first_name players.firstname%TYPE,
    is_active players.isactive%TYPE,
    errorCode OUT NUMBER,
    safety NUMBER) AS
BEGIN
    UPDATE
        Players
    SET
        regnumber = reg_Num,
        lastname = last_name,
        firstname = first_name,
        isactive = is_active
    WHERE
        playerid = player_ID;
    errorCode := 10;
    IF SQL%ROWCOUNT = 0 THEN
        errorCode := 2;
    ELSIF SQL%ROWCOUNT = 1 THEN
        errorCode := 10;
    ELSE
        IF safety = 1 THEN
            ROLLBACK;
        END IF;
        errorCode := 3;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        errorCode := 1;
END;

DECLARE
    newErrorCode NUMBER := 0;
BEGIN
    spPlayersUpdate(2024144,98268,'Wong','Jason',1, newErrorCode, 1);
    DBMS_OUTPUT.PUT_LINE(newErrorCode);
END;


--Players Delete

CREATE OR REPLACE PROCEDURE spPlayersDelete(player_ID players.playerid%TYPE, errorCode OUT NUMBER, safety NUMBER) AS
BEGIN
    DELETE FROM players WHERE playerid = player_ID;
    IF SQL%ROWCOUNT = 0 THEN
        errorCode:= 2;
    ELSIF SQL%ROWCOUNT = 1 THEN
        COMMIT;
        errorCode:= 10;
    ELSE
        IF safety = 1 THEN
            ROLLBACK;
        END IF;
        errorCode := 3;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        errorCode := 1;
END;

DECLARE
    newErrorCode NUMBER := 0;
BEGIN
  spPlayersDelete(2024144, newErrorCode, 1);
  DBMS_OUTPUT.PUT_LINE(newErrorCode);
END;

--Players Select
CREATE TYPE playerstype AS OBJECT(
    player_ID NUMBER(38,0),
    reg_Num VARCHAR2 (15),
    last_name VARCHAR2(25),
    first_name VARCHAR2(25),
    is_active NUMBER(38,0));
    
CREATE OR REPLACE TYPE playerstypeset AS TABLE OF playerstype;

CREATE OR REPLACE PACKAGE refcur_players IS TYPE refcur_p IS REF CURSOR RETURN players%ROWTYPE;
END refcur_players;

CREATE OR REPLACE FUNCTION playersoutput(pl refcur_players.refcur_p)RETURN playerstypeset
    PIPELINED IS
        out_rec playerstype := playerstype(NULL,NULL,NULL,NULL,NULL);
        in_rec pl%ROWTYPE;
BEGIN
    LOOP
        FETCH pl INTO in_rec;
        EXIT WHEN pl%NOTFOUND;
        out_rec.player_ID := in_rec.playerid;
        out_rec.reg_Num := in_rec.regnumber;
        out_rec.last_name:= in_rec.lastname;
        out_rec.first_name:= in_rec.firstname;
        out_rec.is_active:= in_rec.isactive;
        PIPE ROW(out_rec);
    END LOOP;
    CLOSE pl;
    RETURN;
END;

CREATE OR REPLACE PROCEDURE spPlayersSelect( player_ID2 NUMBER, refcursor OUT SYS_REFCURSOR, errorCode OUT NUMBER)AS
BEGIN
    OPEN refcursor
    FOR SELECT * FROM TABLE(playersoutput(CURSOR(SELECT * FROM players))) WHERE player_ID = player_ID2;
    errorCode := 10;
EXCEPTION
    WHEN OTHERS THEN
        errorCode := 1;
END;

DECLARE
    newErrorCode NUMBER := 0;
    playersselect_refcursor refcur_players.refcur_p;
    playersRow players%ROWTYPE;
BEGIN
    spPlayersSelect(1302,playersselect_refcursor, newErrorCode);
    DBMS_OUTPUT.PUT_LINE('Error Code: '||newErrorCode);
    DBMS_OUTPUT.PUT_LINE(RPAD('playerID',13,' ')||RPAD('regNumber',13,' ')||RPAD('lastName',13,' ')||RPAD('firstName',13,' ')||
    RPAD('isActive',13,' '));
    LOOP
        FETCH playersselect_refcursor
        INTO playersRow.playerid, playersRow.regnumber, playersRow.lastname, playersRow.firstname, playersRow.isactive;
        EXIT WHEN playersselect_refcursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(RPAD(playersRow.playerid,13,' ')||RPAD(playersRow.regnumber,13,' ')||RPAD(playersRow.lastname,13,' ')||
            RPAD(playersRow.firstname,13,' ')||RPAD(playersRow.isactive,13,' '));
    END LOOP;
    CLOSE playersselect_refcursor;
END;

--4 CRUD tasks for teams table
SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE spTeamsInsert(
    team_ID teams.teamid%TYPE,
    team_name teams.teamname%TYPE,
    is_active teams.isactive%TYPE,
    jersey_colour teams.jerseycolour%TYPE,
    errorCode OUT NUMBER)AS
BEGIN
    INSERT INTO teams
    VALUES(team_ID, team_name, is_active, jersey_colour);
    errorCode := 10;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        errorCode:= 1;
END;

DECLARE
    newErrorCode NUMBER := 0;
BEGIN
    spTeamsInsert(540,'MeatWad',1,'Brown', newErrorCode);
    DBMS_OUTPUT.PUT_LINE(newErrorCode);
END;

--Teams Update

CREATE OR REPLACE PROCEDURE spTeamsUpdate(
    team_id teams.teamid%TYPE,
    team_name teams.teamname%TYPE,
    is_active teams.isactive%TYPE,
    jersey_colour teams.jerseycolour%TYPE,
    errorCode OUT NUMBER,
    safety NUMBER)AS
BEGIN
    UPDATE teams
    SET
        teamname = team_name,
        isactive = is_active,
        jerseycolour = jersey_colour
    WHERE
        teamid = team_id;
    IF SQL%ROWCOUNT = 0 THEN
        errorCode := 2;
    ELSIF SQL%ROWCOUNT = 1 THEN
        errorCode := 10;
        COMMIT;
    ELSE
        IF safety = 1 THEN
            ROLLBACK;
        END IF;
        errorCode := 3;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        errorCode := 1;
END;

DECLARE
    newErrorCode NUMBER := 0;
BEGIN
    spTeamsUpdate(540,'FryLock',1,'Red', newErrorCode, 1);
    DBMS_OUTPUT.PUT_LINE(newErrorCode);
END;

--Teams Delete

CREATE OR REPLACE PROCEDURE spTeamsDelete(
    team_ID teams.teamid%type,
    errorCode OUT NUMBER,
    safety NUMBER)AS
BEGIN
    DELETE FROM teams WHERE teamid = team_ID;
    IF SQL%ROWCOUNT = 0 THEN
        errorCode := 2;
    ELSIF SQL%ROWCOUNT = 1 THEN
        COMMIT;
        errorCode:= 10;
    ELSE
        IF safety = 1 THEN
            ROLLBACK;
        END IF;
        errorCode := 3;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        errorCode := 1;
END;

DECLARE
    newErrorCode NUMBER := 0;
BEGIN
    spTeamsDelete(540, newErrorCode, 1);
    DBMS_OUTPUT.PUT_LINE(newErrorCode);
END;

--Teams SELECT

CREATE TYPE teamstype AS OBJECT(
    team_ID NUMBER(38,0),
    team_name VARCHAR2(10),
    is_active NUMBER(38,0),
    jersey_colour VARCHAR2(10));
    
CREATE TYPE teamstypeset AS TABLE OF teamstype;
CREATE PACKAGE refcur_teams AS TYPE refcur_t IS REF CURSOR RETURN teams%ROWTYPE;
END refcur_teams;
CREATE OR REPLACE FUNCTION teamsoutput( t refcur_teams.refcur_t) RETURN teamstypeset
PIPELINED IS
    out_rec teamstype := teamstype(NULL,NULL,NULL,NULL);
    in_rec t%ROWTYPE;
BEGIN
    LOOP
        FETCH t INTO in_rec;
        EXIT WHEN t%NOTFOUND;
        out_rec.team_ID := in_rec.teamid;
        out_rec.team_name := in_rec.teamname;
        out_rec.is_active := in_rec.isactive;
        out_rec.jersey_colour := in_rec.jerseycolour;
        PIPE ROW(out_rec);
    END LOOP;
    CLOSE t;
    RETURN;
END;

CREATE OR REPLACE PROCEDURE spTeamsSelect(team_ID2 teams.teamid%TYPE,refcursor OUT SYS_REFCURSOR, errorCode OUT NUMBER)AS
BEGIN
    OPEN refcursor
    FOR SELECT * FROM TABLE(teamsoutput(CURSOR(SELECT * FROM teams)))WHERE team_ID = team_ID2;
    errorCode := 10;
EXCEPTION
    WHEN OTHERS THEN
        errorCode := 1;
END;

DECLARE
    newErrorCode NUMBER := 10;
    teamsSelect_refcursor refcur_teams.refcur_t;
    teamRow teams%ROWTYPE;
BEGIN
    spTeamsSelect(225, teamsSelect_refcursor, newErrorCode);
    DBMS_OUTPUT.PUT_LINE('Error Code: '||newErrorCode);
    DBMS_OUTPUT.PUT_LINE(RPAD('team ID',13,' ')||RPAD('teamName',13,' ')||RPAD('isActive',13,' ')||RPAD('jerseyColour',13,' '));
    LOOP
        FETCH teamsSelect_refcursor
        INTO teamRow.teamid, teamRow.teamname, teamRow.isactive, teamRow.jerseycolour;
        EXIT WHEN teamsSelect_refcursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(RPAD(teamRow.teamid, 13, ' ')||RPAD(teamRow.teamname,13,' ')||RPAD(teamRow.isactive,13,' ')||RPAD(teamRow.jerseycolour,13,' '));
    END LOOP;
    CLOSE teamsSelect_refcursor;
END;

--4 CRUD tasks for Rosters table
SET SERVEROUTPUT ON;
--Rosters INSERT    
CREATE OR REPLACE PROCEDURE spRostersInsert(
    roster_ID rosters.rosterid%TYPE,
    player_ID rosters.playerid%TYPE,
    team_ID rosters.teamid%TYPE,
    is_active rosters.isactive%TYPE,
    jersey_number rosters.jerseynumber%TYPE,
    errorCode OUT NUMBER)AS
BEGIN
    INSERT INTO rosters
    VALUES(roster_ID, player_ID, team_ID, is_active, jersey_number);
    errorCode := 10;
EXCEPTION
    WHEN OTHERS THEN
    errorCode := 1;
END;

DECLARE
    newErrorCode NUMBER:= 10;
BEGIN
    spRostersInsert(231,2024144,212,1,88, newErrorCode);
    DBMS_OUTPUT.PUT_LINE('Error Code: '|| newErrorCode);
END;

--Rosters UPDATE

CREATE OR REPLACE PROCEDURE spRostersUpdate(
    roster_ID rosters.rosterid%TYPE,
    player_ID rosters.playerid%TYPE,
    team_ID rosters.teamid%TYPE,
    is_Active rosters.isactive%TYPE,
    jersey_Number rosters.jerseynumber%TYPE,
    errorCode OUT NUMBER,
    safety NUMBER) AS
BEGIN
    UPDATE rosters
    SET
        playerid = player_ID,
        teamid = team_ID,
        isactive = is_Active,
        jerseynumber = jersey_number
    WHERE
         rosterid = roster_ID;
    errorCode := 10;
    IF SQL%ROWCOUNT = 0 THEN
        errorCode := 2;
    ELSIF SQL%ROWCOUNT = 1 THEN
        errorCode := 10;
        COMMIT;
    ELSE
        IF safety = 1 THEN
            ROLLBACK;
        END IF;
        errorCode := 3;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        errorCode := 1;
END;

DECLARE
    newErrorCode NUMBER := 0;
BEGIN
    spRostersUpdate(231,2024144,212,1,95, newErrorCode, 1);
    DBMS_OUTPUT.PUT_LINE('Error Code: '|| newErrorCode);
END;

--Rosters DELETE

CREATE OR REPLACE PROCEDURE spRostersDelete(
    roster_ID rosters.rosterid%TYPE, 
    errorCode OUT NUMBER, 
    safety NUMBER)AS
BEGIN
    DELETE FROM rosters WHERE rosterid = roster_ID;
    errorCode := 10;
    IF SQL%ROWCOUNT = 0 THEN
        errorCode := 2;
    ELSIF SQL%ROWCOUNT = 1 THEN
        errorCode := 10;
        COMMIT;
    ElSE 
        IF safety = 1 THEN
            ROllBACK;
        END IF;
        errorCode := 3;
    END IF;
END;

DECLARE
    newErrorCode NUMBER := 0;
BEGIN
    spRostersDelete(231,newErrorCode, 1);
    DBMS_OUTPUT.PUT_LINE('Error Code: '||newErrorCode);
END;

-- Rosters SELECT

CREATE OR REPLACE TYPE rosterstype AS OBJECT(
    roster_ID NUMBER(38,0),
    player_ID NUMBER(38,0),
    team_ID NUMBER(38,0),
    is_Active NUMBER(38,0),
    jersey_Number NUMBER(38,0)
    )

CREATE OR REPLACE TYPE rosterstypeset AS TABLE OF rosterstype;

CREATE OR REPLACE PACKAGE refcur_rosters AS TYPE refcur_r IS REF CURSOR RETURN rosters%ROWTYPE;
END refcur_rosters;
CREATE OR REPLACE FUNCTION rostersoutput (r refcur_rosters.refcur_r) RETURN rosterstypeset
PIPELINED IS
    out_rec rosterstype := rosterstype(NULL,NULL,NULL,NULL,NULL);
    in_rec r%rowtype;
BEGIN
    LOOP
        FETCH r INTO in_rec;
        EXIT WHEN r%NOTFOUND;
        out_rec.roster_ID := in_rec.rosterid;
        out_rec.player_ID := in_rec.playerid;
        out_rec.team_ID := in_rec.teamid;
        out_rec.is_Active := in_rec.isactive;
        out_rec.jersey_Number:= in_rec.jerseynumber;
        PIPE ROW(out_rec);
    END LOOP;
    CLOSE r;
    RETURN;
END;

CREATE OR REPLACE PROCEDURE spRostersSelect(
    roster_ID2 NUMBER,
    refcursor OUT SYS_REFCURSOR,
    errorCode OUT NUMBER)AS
BEGIN
    OPEN refcursor
    FOR SELECT*FROM TABLE(rostersoutput(CURSOR(SELECT* FROM rosters))) WHERE roster_ID = roster_ID2;
    errorCode := 10;
EXCEPTION
    WHEN OTHERS THEN
        errorCode := 1;
END;

DECLARE
    newErrorCode NUMBER := 0;
    rostersSelect_refcursor refcur_rosters.refcur_r;
    rostersRow rosters%ROWTYPE;
BEGIN
    spRostersSelect(230,  rostersSelect_refcursor, newErrorCode);
    DBMS_OUTPUT.PUT_LINE(RPAD('roster ID',13,' ')||RPAD('player ID',13,' ')||RPAD('team ID',13,' ')||RPAD('is Active',13,' ')||
    RPAD('jersey Number',13,' '));
    LOOP
        FETCH rostersSelect_refcursor
        INTO rostersRow.rosterid, rostersRow.playerid, rostersRow.teamid, rostersRow.isactive, rostersRow.jerseynumber;
        EXIT WHEN rostersSelect_refcursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(RPAD(rostersRow.rosterid, 13, ' ')||RPAD(rostersRow.playerid,13,' ')||RPAD(rostersRow.teamid,13,' ')||RPAD(rostersRow.isactive,13,' ')||
            RPAD(rostersRow.jerseynumber,13,' '));
    END LOOP;
    CLOSE rostersSelect_refcursor;
END;

-- 4 CRUD tasks for sllocations table
SET SERVEROUTPUT ON;

--sllocation INSERT

CREATE OR REPLACE PROCEDURE spSllocationsInsert(
    location_ID sllocations.locationid%TYPE,
    location_Name sllocations.locationname%TYPE,
    field_Length sllocations.fieldlength%TYPE,
    is_Active sllocations.isactive%TYPE,
    errorCode OUT NUMBER)AS
BEGIN
    INSERT INTO sllocations
    VALUES(location_ID, location_Name, field_Length, is_Active);
    errorCode := 10;
EXCEPTION
    WHEN OTHERS THEN
        errorCode := 1;
END;

DECLARE
    newErrorCode NUMBER := 0;
BEGIN
    spSllocationsInsert(92,'2537 Victoria Park Ave',110,1,newErrorCode);
    DBMS_OUTPUT.PUT_LINE('Error Code: '||newErrorCode);
END;

--sllocations UPDATE
CREATE OR REPLACE PROCEDURE spSllocationsUpdate(
    location_ID sllocations.locationid%TYPE,
    location_Name sllocations.locationname%TYPE,
    field_Length sllocations.fieldlength%TYPE,
    is_Active sllocations.isactive%TYPE,
    errorCode OUT NUMBER,
    safety NUMBER)AS
BEGIN
    UPDATE sllocations
    SET
        locationname = location_Name,
        fieldlength = field_Length,
        isactive = is_Active
    WHERE 
      locationid = location_ID;
    IF SQL%ROWCOUNT = 0 THEN
        errorCode := 2;
    ELSIF SQL%ROWCOUNT = 1 THEN
        errorCode := 10;
        COMMIT;
    ELSE
        IF safety = 1 THEN
            ROLLBACK;
        END IF;
        errorCode := 3;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        errorCode := 1;
END;

DECLARE
    newErrorCode NUMBER := 0;
BEGIN
    spSllocationsUpdate(92, '35 Springfield Blvd', 110,1,newErrorCode,1);
    DBMS_OUTPUT.PUT_LINE('Error Code: '|| newErrorCode);
END;

--sllocations DELETE

CREATE OR REPLACE PROCEDURE spSllocationsDelete(
    location_ID sllocations.locationid%TYPE,
    errorCode OUT NUMBER,
    safety NUMBER)AS
BEGIN
    DELETE FROM sllocations WHERE locationid = location_ID;
    IF SQL%ROWCOUNT = 0 THEN
        errorCode := 2;
    ElSIF SQL%ROWCOUNT = 1 THEN
        COMMIT;
        errorCode := 10;
    ELSE
        IF safety = 1 THEN
            ROLLBACK;
        END IF;
        errorCode := 3;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        errorCode := 1;
END;

DECLARE
    newErrorCode NUMBER := 0;
BEGIN
    spSllocationsDelete(92, newErrorCode, 1);
    DBMS_OUTPUT.PUT_LINE('Error Code: '||newErrorCode);
END;

--sllocations SELECT

CREATE TYPE sllocationstype AS OBJECT(
    location_ID NUMBER(38,0),
    location_Name VARCHAR2(50),
    field_Length NUMBER(38,0),
    is_Active NUMBER(38,0));

CREATE OR REPLACE TYPE sllocationstypeset AS TABLE OF sllocationstype;

CREATE OR REPLACE PACKAGE refcur_sllocations AS TYPE refcur_sl IS  REF CURSOR RETURN sllocations%ROWTYPE;
END refcur_sllocations;

CREATE OR REPLACE FUNCTION sllocationsoutput (sl refcur_sllocations.refcur_sl) RETURN sllocationstypeset
PIPELINED IS
    out_rec sllocationstype := sllocationstype(NULL, NULL, NULL, NULL);
    in_rec sl%ROWTYPE;
BEGIN
    LOOP
        FETCH sl INTO in_rec;
        EXIT WHEN sl%NOTFOUND;
        out_rec.location_ID := in_rec.locationid;
        out_rec.location_Name := in_rec.locationname;
        out_rec.field_Length := in_rec.fieldLength;
        out_rec.is_Active := in_rec.isactive;
        PIPE ROW (out_rec);
    END LOOP;
    CLOSE sl;
    RETURN;
END;

CREATE OR REPLACE PROCEDURE spSllocationsSelect(location_ID2 NUMBER, refcursor OUT SYS_REFCURSOR, errorCode OUT NUMBER)AS
BEGIN
    OPEN refcursor
    FOR SELECT * FROM TABLE(sllocationsoutput(CURSOR(SELECT * FROM sllocations))) WHERE location_ID = location_ID2;
    errorCode := 10;
EXCEPTION
    WHEN OTHERS THEN
        errorCode := 1;
END;

DECLARE
    newErrorCode NUMBER := 0;
    sllocationsSelect_refcursor refcur_sllocations.refcur_sl;
    sllocationsRow sllocations%ROWTYPE;
BEGIN
    spSllocationsSelect(85, sllocationsSelect_refcursor, newErrorCode);
    DBMS_OUTPUT.PUT_LINE('Error Code: '||newErrorCode);
    DBMS_OUTPUT.PUT_LINE(RPAD('location ID',13,' ')||RPAD('location Name',50,' ')||RPAD('field Length',13,' ')||RPAD('is Active',13,' '));
    LOOP
        FETCH sllocationsSelect_refcursor
        INTO sllocationsRow.locationid, sllocationsRow.locationname, sllocationsRow.fieldlength, sllocationsRow.isactive;
        EXIT WHEN sllocationsSelect_refcursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(RPAD(sllocationsRow.locationid, 13, ' ')||RPAD(sllocationsRow.locationname,50,' ')||
            RPAD(sllocationsRow.fieldlength,13,' ')||RPAD(sllocationsRow.isactive,13,' '));
    END LOOP;
    CLOSE sllocationsSelect_refcursor;
END;

--2.	For each table, create a Stored Procedure that outputs the contents of the table to the script window 
--      (using DBMS_OUTPUT) for the standard SELECT * FROM <tablename> statement.
SET SERVEROUTPUT ON;
-- games SELECT ALL
CREATE OR REPLACE PROCEDURE spGamesSelectAll(refcursor OUT SYS_REFCURSOR, errorCode OUT NUMBER)AS
BEGIN
        OPEN refcursor
        FOR SELECT * FROM TABLE(gamesoutput(cursor(select*from games ))); 
        
    errorCode :=10;
EXCEPTION
    WHEN OTHERS 
        THEN
        errorCode := 1;
END;

DECLARE
    newErrorCode NUMBER:=0;
    gamesselectAll_refcursor refcur_games.refcur_g;
    game_id NUMBER(38,0);
    div_id NUMBER(38,0);
    game_num NUMBER(38,0);
    gameDandT DATE;
    homeT NUMBER(38,0);
    homeS NUMBER(38,0);
    visitT NUMBER(38,0);
    visitS NUMBER(38,0);
    location_id NUMBER(38,0);
    isPlayed2 NUMBER(38,0);
    notes2 VARCHAR2(50);
BEGIN
 spGamesSelectAll(gamesselectAll_refcursor, newErrorCode);
  DBMS_OUTPUT.PUT_LINE('Error Code: '||newErrorCode);
  DBMS_OUTPUT.PUT_LINE(RPAD('game ID',13,' ')||RPAD('divID',13,' ')||RPAD('game num',13,' ')||RPAD('gameDateTime',13,' ')||
    RPAD('homeTeam',13,' ')||RPAD('homeScore',13,' ')||RPAD('visitTeam',13,' ')||RPAD('visitScore',13,' ')||
    RPAD('location_id',13,' ')||RPAD('isPlayed',13,' ')||RPAD('notes',13,' '));
    LOOP
        FETCH gamesselectAll_refcursor
        INTO game_id, div_id, game_num, gameDandT, homeT, homeS, visitT, visitS, location_id, isPlayed2, notes2;
        EXIT WHEN gamesselectAll_refcursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(RPAD(game_id, 13, ' ')||RPAD(div_id,13,' ')||RPAD(game_num,13,' ')||RPAD(gameDandT,13,' ')||
            RPAD(homeT,13,' ')||RPAD(homeS,13,' ')||RPAD(visitT,13,' ')||RPAD(visitS,13,' ')||RPAD(location_id,13,' ')||
            RPAD(isPlayed2,13,' ')||RPAD(NVL(notes2,'null'),13,' '));
    END LOOP;
    CLOSE gamesselectAll_refcursor;
END;

--goalscorers SELECT ALL

CREATE OR REPLACE PROCEDURE spGoalscorersSelectAll(refcursor OUT SYS_REFCURSOR, errorCode OUT NUMBER)AS
BEGIN
    OPEN refcursor
    FOR SELECT * FROM TABLE(goalscorersoutput(CURSOR(SELECT * FROM goalscorers)));
    
    errorCode := 10;
EXCEPTION
    WHEN OTHERS 
        THEN
        errorCode := 1;
END;

DECLARE
    newErrorCode NUMBER := 0;
    goalscorersSelectAll_refcursor refcur_goalscorers.refcur_gs;
    goalscorersRow goalscorers%ROWTYPE;
    
BEGIN

    spGoalscorersSelectAll(goalscorersSelectAll_refcursor, newErrorCode);
    DBMS_OUTPUT.PUT_LINE(newErrorCode);
    DBMS_OUTPUT.PUT_LINE(RPAD('goal ID',13,' ')||RPAD('game ID',13,' ')||RPAD('player ID',13,' ')||RPAD('team ID',13,' ')||
    RPAD('num Goals',13,' ')||RPAD('num Assists',13,' '));
    LOOP
        FETCH goalscorersSelectAll_refcursor
        INTO goalscorersRow;
        EXIT WHEN goalscorersSelectAll_refcursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(RPAD(goalscorersRow.goalid, 13, ' ')||RPAD(goalscorersRow.gameid,13,' ')||
        RPAD(goalscorersRow.playerid,13,' ')||RPAD(goalscorersRow.teamid,13,' ')||RPAD(goalscorersRow.numgoals,13,' ')||
        RPAD(goalscorersRow.numassists,13,' '));
    END LOOP;
    CLOSE goalscorersSelectAll_refcursor;
END;

--players SELECT All
CREATE OR REPLACE PROCEDURE spPlayersSelectAll(refcursor OUT SYS_REFCURSOR, errorCode OUT NUMBER)AS
BEGIN
    OPEN refcursor
    FOR SELECT * FROM TABLE(playersoutput(CURSOR(SELECT * FROM players)));
    errorCode := 10;
EXCEPTION
    WHEN OTHERS THEN
        errorCode := 1;
END;

DECLARE
    newErrorCode NUMBER := 0;
    playersselectAll_refcursor refcur_players.refcur_p;
    playersRow players%ROWTYPE;
BEGIN
    spPlayersSelectAll(playersselectAll_refcursor, newErrorCode);
    DBMS_OUTPUT.PUT_LINE('Error Code: '||newErrorCode);
    DBMS_OUTPUT.PUT_LINE(RPAD('playerID',13,' ')||RPAD('regNumber',13,' ')||RPAD('lastName',13,' ')||RPAD('firstName',13,' ')||
    RPAD('isActive',13,' '));
    LOOP
        FETCH playersselectAll_refcursor
        INTO playersRow.playerid, playersRow.regnumber, playersRow.lastname, playersRow.firstname, playersRow.isactive;
        EXIT WHEN playersselectAll_refcursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(RPAD(playersRow.playerid,13,' ')||RPAD(playersRow.regnumber,13,' ')||RPAD(playersRow.lastname,13,' ')||
            RPAD(playersRow.firstname,13,' ')||RPAD(playersRow.isactive,13,' '));
    END LOOP;
    CLOSE playersselectAll_refcursor;
END;

--Teams SELECT All
CREATE OR REPLACE PROCEDURE spTeamsSelectAll(refcursor OUT SYS_REFCURSOR, errorCode OUT NUMBER)AS
BEGIN
    OPEN refcursor
    FOR SELECT * FROM TABLE(teamsoutput(CURSOR(SELECT * FROM teams)));
    errorCode := 10;
EXCEPTION
    WHEN OTHERS THEN
        errorCode := 1;
END;

DECLARE
    newErrorCode NUMBER := 10;
    teamsSelectAll_refcursor refcur_teams.refcur_t;
    teamRow teams%ROWTYPE;
BEGIN
    spTeamsSelectAll(teamsSelectAll_refcursor, newErrorCode);
    DBMS_OUTPUT.PUT_LINE('Error Code: '||newErrorCode);
    DBMS_OUTPUT.PUT_LINE(RPAD('team ID',13,' ')||RPAD('teamName',13,' ')||RPAD('isActive',13,' ')||RPAD('jerseyColour',13,' '));
    LOOP
        FETCH teamsSelectAll_refcursor
        INTO teamRow.teamid, teamRow.teamname, teamRow.isactive, teamRow.jerseycolour;
        EXIT WHEN teamsSelectAll_refcursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(RPAD(teamRow.teamid, 13, ' ')||RPAD(teamRow.teamname,13,' ')||RPAD(teamRow.isactive,13,' ')||RPAD(teamRow.jerseycolour,13,' '));
    END LOOP;
    CLOSE teamsSelectAll_refcursor;
END;

--Rosters SELECT All
CREATE OR REPLACE PROCEDURE spRostersSelectAll(
    refcursor OUT SYS_REFCURSOR,
    errorCode OUT NUMBER)AS
BEGIN
    OPEN refcursor
    FOR SELECT*FROM TABLE(rostersoutput(CURSOR(SELECT* FROM rosters)));
    errorCode := 10;
EXCEPTION
    WHEN OTHERS THEN
        errorCode := 1;
END;

DECLARE
    newErrorCode NUMBER := 0;
    rostersSelectAll_refcursor refcur_rosters.refcur_r;
    rostersRow rosters%ROWTYPE;
BEGIN
    spRostersSelectAll(rostersSelectAll_refcursor, newErrorCode);
    DBMS_OUTPUT.PUT_LINE(RPAD('roster ID',13,' ')||RPAD('player ID',13,' ')||RPAD('team ID',13,' ')||RPAD('is Active',13,' ')||
    RPAD('jersey Number',13,' '));
    LOOP
        FETCH rostersSelectAll_refcursor
        INTO rostersRow.rosterid, rostersRow.playerid, rostersRow.teamid, rostersRow.isactive, rostersRow.jerseynumber;
        EXIT WHEN rostersSelectAll_refcursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(RPAD(rostersRow.rosterid, 13, ' ')||RPAD(rostersRow.playerid,13,' ')||RPAD(rostersRow.teamid,13,' ')||RPAD(rostersRow.isactive,13,' ')||
            RPAD(rostersRow.jerseynumber,13,' '));
    END LOOP;
    CLOSE rostersSelectAll_refcursor;
END;

--sllocations SELECT ALL
CREATE OR REPLACE PROCEDURE spSllocationsSelectAll(refcursor OUT SYS_REFCURSOR, errorCode OUT NUMBER)AS
BEGIN
    OPEN refcursor
    FOR SELECT * FROM TABLE(sllocationsoutput(CURSOR(SELECT * FROM sllocations)));
    errorCode := 10;
EXCEPTION
    WHEN OTHERS THEN
        errorCode := 1;
END;

DECLARE
    newErrorCode NUMBER := 0;
    sllocationsSelectAll_refcursor refcur_sllocations.refcur_sl;
    sllocationsRow sllocations%ROWTYPE;
BEGIN
    spSllocationsSelectAll(sllocationsSelectAll_refcursor, newErrorCode);
    DBMS_OUTPUT.PUT_LINE('Error Code: '||newErrorCode);
    DBMS_OUTPUT.PUT_LINE(RPAD('location ID',13,' ')||RPAD('location Name',50,' ')||RPAD('field Length',13,' ')||
        RPAD('is Active',13,' '));
    LOOP
        FETCH sllocationsSelectAll_refcursor
        INTO sllocationsRow.locationid, sllocationsRow.locationname, sllocationsRow.fieldlength, sllocationsRow.isactive;
        EXIT WHEN sllocationsSelectAll_refcursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(RPAD(sllocationsRow.locationid, 13, ' ')||RPAD(sllocationsRow.locationname,50,' ')||
            RPAD(sllocationsRow.fieldlength,13,' ')||RPAD(sllocationsRow.isactive,13,' '));
    END LOOP;
    CLOSE sllocationsSelectAll_refcursor;
END;


--3.	Create a view which stores the “players on teams” information, called vwPlayerRosters which includes all fields from 
--      players, rosters, and teams in a single output table.  You only need to include records that have exact matches.
SET SERVEROUTPUT ON;

CREATE OR REPLACE VIEW vwPlayerRosters AS
    SELECT 
        p.playerid,
        p.regnumber,
        p.lastname,
        p.firstname,
        p.isactive AS player_isactive,
        r.rosterid,
        r.teamid,
        r.isactive AS roster_isactive,
        r.jerseynumber,
        t.teamname,
        t.isActive AS team_isactive,
        t.jerseycolour
        FROM players p INNER JOIN rosters r ON p.playerid = r.playerid
        INNER JOIN teams t ON r.teamid = t.teamid;
        
--4.	Using the vwPlayerRosters view, create an SP, named spTeamRosterByID, that outputs, using DBMS_OUTPUT, 
--      the team rosters, with names, for a team given a specific input parameter of teamID

CREATE OR REPLACE TYPE teamrostertype AS OBJECT(
    player_ID NUMBER(38,0),
    reg_Num VARCHAR2(15),
    last_Name VARCHAR2(25),
    first_Name VARCHAR2(25),
    p_isActive NUMBER(38,0),
    roster_ID NUMBER(38,0),
    team_ID NUMBER(38,0),
    r_isActive NUMBER(38,0),
    jersey_Number NUMBER(38,0),
    team_Name VARCHAR2(10),
    t_isActive NUMBER(38,0),
    jersey_Colour VARCHAR2(10));
    
CREATE OR REPLACE TYPE teamrostertypeset AS TABLE OF  teamrostertype;

CREATE OR REPLACE PACKAGE refcur_teamroster IS TYPE refcur_tr IS REF CURSOR RETURN vwPlayerRosters%ROWTYPE;
END refcur_teamroster;

CREATE OR REPLACE FUNCTION teamrosteroutput(tr refcur_teamroster.refcur_tr) return teamrostertypeset 
PIPELINED IS
    out_rec teamrostertype := teamrostertype(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
    in_rec tr%ROWTYPE;
BEGIN
    LOOP
        FETCH tr INTO in_rec;
        EXIT WHEN tr%NOTFOUND;
        out_rec.player_ID := in_rec.playerid;
        out_rec.reg_Num :=in_rec.regnumber;
        out_rec.last_Name := in_rec.lastname;
        out_rec.first_Name := in_rec.firstname;
        out_rec.p_isActive := in_rec.player_isactive;
        out_rec.roster_ID := in_rec.rosterid;
        out_rec.team_ID := in_rec.teamid;
        out_rec.r_isActive := in_rec.roster_isactive;
        out_rec.jersey_Number := in_rec.jerseynumber;
        out_rec.team_Name := in_rec.teamname;
        out_rec.t_isActive := in_rec.team_isactive;
        out_rec.jersey_Colour := in_rec.jerseycolour;
        PIPE ROW(out_rec);
    END LOOP;
    CLOSE tr;
    RETURN;
END;

CREATE OR REPLACE PROCEDURE spTeamRosterByID(team_ID2 NUMBER, refcursor OUT SYS_REFCURSOR, errorCode OUT NUMBER)AS
BEGIN
    OPEN refcursor
    FOR SELECT * FROM TABLE(teamrosteroutput(CURSOR(SELECT * FROM vwPlayerRosters)))WHERE team_ID = team_ID2;
    errorCode := 10;
EXCEPTION
    WHEN OTHERS THEN
        errorCode:= 1;
END;

DECLARE
    newErrorCode NUMBER := 0;
    teamRosterByID_refcursor refcur_teamroster.refcur_tr;
    teamRosterRow vwPlayerRosters%ROWTYPE;
BEGIN
    spTeamRosterByID(212,teamRosterByID_refcursor,newErrorCode);
    DBMS_OUTPUT.PUT_LINE('Error Code: '||newErrorCode);
    DBMS_OUTPUT.PUT_LINE(RPAD('player ID',13,' ')||RPAD('regNumber',13,' ')||RPAD('last Name',13,' ')||
        RPAD('first name',13,' ')||RPAD('player isActive',16,' ')||RPAD('roster ID',13,' ')||RPAD('team ID',13,' ')||
        RPAD('roster isActive',16,' ')||RPAD('jersey Number',15,' ')||RPAD('team Name',13,' ')||RPAD('team isActive',14,' ')||
        RPAD('jerseyColour',13,' '));
    LOOP
        FETCH teamRosterByID_refcursor
        INTO teamRosterRow.playerid,teamRosterRow.regnumber, teamRosterRow.lastname, teamRosterRow.firstname, 
            teamRosterRow.player_isactive, teamRosterRow.rosterid, teamRosterRow.teamid, teamRosterRow.roster_isactive,
            teamRosterRow.jerseynumber,teamRosterRow.teamname, teamRosterRow.team_isactive, teamRosterRow.jerseycolour;
        EXIT WHEN teamRosterByID_refcursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(RPAD(teamRosterRow.playerid,13,' ')||RPAD(teamRosterRow.regnumber,13,' ')||
            RPAD(teamRosterRow.lastname,13,' ')||
            RPAD(teamRosterRow.firstname,13,' ')||RPAD(teamRosterRow.player_isactive,16,' ')||
            RPAD(teamRosterRow.rosterid,13,' ')||RPAD(teamRosterRow.teamid,13,' ')||
            RPAD( teamRosterRow.roster_isactive,16,' ')||RPAD(teamRosterRow.jerseynumber,15,' ')||
            RPAD(teamRosterRow.teamname,13,' ')||RPAD(teamRosterRow.team_isactive,14,' ')||
            RPAD(teamRosterRow.jerseycolour,13,' '));
    END LOOP;
    CLOSE teamRosterByID_refcursor;
END;

--5.	Repeat task 4, by creating another similar stored procedure, named spTeamRosterByName, that receives a string parameter
--      and returns the team roster, with names, for a team found through a search string.  The entered parameter may be any 
--      part of the name.
CREATE OR REPLACE PROCEDURE spTeamRosterByName( team_Name2 varchar2, refcursor OUT SYS_REFCURSOR, errorCode OUT NUMBER)AS
BEGIN
    OPEN refcursor
    FOR SELECT * FROM TABLE(teamrosteroutput(CURSOR(SELECT * FROM vwPlayerRosters)))WHERE UPPER(team_Name) LIKE ('%'||UPPER(team_Name2)||'%');
    errorCode := 10;
EXCEPTION
    WHEN OTHERS THEN
        errorCode:= 1;
END;

DECLARE
    newErrorCode NUMBER := 0;
    teamRosterByName_refcursor refcur_teamroster.refcur_tr;
    teamRosterRow vwPlayerRosters%ROWTYPE;
BEGIN
    spTeamRosterByName('kicker',teamRosterByName_refcursor,newErrorCode);
    DBMS_OUTPUT.PUT_LINE('Error Code: '||newErrorCode);
    DBMS_OUTPUT.PUT_LINE(RPAD('player ID',13,' ')||RPAD('regNumber',13,' ')||RPAD('last Name',13,' ')||
        RPAD('first name',13,' ')||RPAD('player isActive',16,' ')||RPAD('roster ID',13,' ')||RPAD('team ID',13,' ')||
        RPAD('roster isActive',16,' ')||RPAD('jersey Number',15,' ')||RPAD('team Name',13,' ')||RPAD('team isActive',14,' ')||
        RPAD('jerseyColour',13,' '));
    LOOP
        FETCH teamRosterByName_refcursor
        INTO teamRosterRow.playerid,teamRosterRow.regnumber, teamRosterRow.lastname, teamRosterRow.firstname, 
            teamRosterRow.player_isactive, teamRosterRow.rosterid, teamRosterRow.teamid, teamRosterRow.roster_isactive,
            teamRosterRow.jerseynumber,teamRosterRow.teamname, teamRosterRow.team_isactive, teamRosterRow.jerseycolour;
        EXIT WHEN teamRosterByName_refcursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(RPAD(teamRosterRow.playerid,13,' ')||RPAD(teamRosterRow.regnumber,13,' ')||
            RPAD(teamRosterRow.lastname,13,' ')||
            RPAD(teamRosterRow.firstname,13,' ')||RPAD(teamRosterRow.player_isactive,16,' ')||
            RPAD(teamRosterRow.rosterid,13,' ')||RPAD(teamRosterRow.teamid,13,' ')||
            RPAD( teamRosterRow.roster_isactive,16,' ')||RPAD(teamRosterRow.jerseynumber,15,' ')||
            RPAD(teamRosterRow.teamname,13,' ')||RPAD(teamRosterRow.team_isactive,14,' ')||
            RPAD(teamRosterRow.jerseycolour,13,' '));
    END LOOP;
    CLOSE teamRosterByName_refcursor;
END;

--6.	Create a view that returns the number of players currently registered on each team, called vwTeamsNumPlayers.

CREATE OR REPLACE VIEW vwTeamsNumPlayers AS
SELECT
    COUNT(playerid) AS number_of_players,
    teamid
FROM
    Rosters
GROUP BY
    teamid;
    
--7.	Using vwTeamsNumPlayers create a user defined function, that given the team PK, will return the number 
--      of players currently registered, called fncNumPlayersByTeamID.
SET SERVEROUTPUT ON;


CREATE OR REPLACE FUNCTION fncNumPlayersByTeamID(team_ID2 NUMBER, errorCode OUT NUMBER) RETURN NUMBER IS
tnp NUMBER;
team_id NUMBER;
BEGIN
    
    SELECT
        number_of_players,
        teamid
    INTO
        tnp,
        team_id
    FROM
        vwTeamsNumPlayers
    WHERE
        teamid = team_ID2;
    errorCode := 10;
    IF SQL%ROWCOUNT = 0 THEN
        errorCode := 2;
        tnp:=0;
    ELSIF SQL%ROWCOUNT = 1 THEN
        
        errorCode := 10;
    ELSE
        tnp:=0;
        errorCode := 3;
    END IF;
    RETURN tnp;
EXCEPTION
    WHEN OTHERS THEN
        errorCode := 1;
        return 0;
END;
        
DECLARE
    newErrorCode NUMBER := 0;
    numPlayers NUMBER;
BEGIN
    numPlayers := fncNumPlayersByTeamID(315,newErrorCode);
    DBMS_OUTPUT.PUT_LINE('Error Code: '|| newErrorCode||' Number of Players: '||numPlayers);
END;

--8.	Create a view, called vwSchedule, that shows all games, but includes the written names for teams and locations, 
--      in addition to the PK/FK values.  Do not worry about division here.

CREATE OR REPLACE VIEW vwSchedule AS
SELECT 
    gameid,
    divid,
    gamenum,
    gamedatetime,
    hometeam,
    t.teamname AS homename,
    homescore,
    visitteam,
    t.teamname AS visitname,
    visitscore,
    g.locationid,
    l.locationname AS locationname,
    isplayed,
    notes
FROM games g
    LEFT JOIN sllocations l ON l.locationid = g.locationid
    LEFT JOIN teams t ON g.hometeam = t.teamid
ORDER BY gameid;

--9. Create a stored procedure, spSchedUpcomingGames, using DBMS_OUTPUT, 
-- that displays the games to be played in the next n days, where n is an input parameter.  
-- Make sure your code will work on any day of the year.

CREATE OR REPLACE PROCEDURE spSchedUpcomingGames ( days IN INT,refcursor OUT SYS_REFCURSOR, errorCode OUT NUMBER)AS
BEGIN
    OPEN refcursor
    FOR SELECT * FROM TABLE(gamesoutput(CURSOR(SELECT* FROM games))) 
    WHERE  gameDandT LIKE To_Date(SYSDATE+days,'DD-MON-YY'); 
    errorCode:= 10;
EXCEPTION
    WHEN OTHERS 
        THEN
        errorCode :=1;
END;

DECLARE
    newErrorCode NUMBER:=0;
    gamesselect_refcursor refcur_games.refcur_g;
    game_id NUMBER(38,0);
    div_id NUMBER(38,0);
    game_num NUMBER(38,0);
    gameDandT DATE;
    homeT NUMBER(38,0);
    homeS NUMBER(38,0);
    visitT NUMBER(38,0);
    visitS NUMBER(38,0);
    location_id NUMBER(38,0);
    isPlayed2 NUMBER(38,0);
    notes2 VARCHAR2(50);
BEGIN
 spSchedUpcomingGames(18,gamesselect_refcursor, newErrorCode);
  DBMS_OUTPUT.PUT_LINE('Error Code: '||newErrorCode);
  DBMS_OUTPUT.PUT_LINE(RPAD('game ID',13,' ')||RPAD('divID',13,' ')||RPAD('game num',13,' ')||RPAD('gameDateTime',13,' ')||
    RPAD('homeTeam',13,' ')||RPAD('homeScore',13,' ')||RPAD('visitTeam',13,' ')||RPAD('visitScore',13,' ')||
    RPAD('location_id',13,' ')||RPAD('isPlayed',13,' ')||RPAD('notes',13,' '));
    LOOP
        FETCH gamesselect_refcursor
        INTO game_id, div_id, game_num, gameDandT, homeT, homeS, visitT, visitS, location_id, isPlayed2, notes2;
        EXIT WHEN gamesselect_refcursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(RPAD(game_id, 13, ' ')||RPAD(div_id,13,' ')||RPAD(game_num,13,' ')||RPAD(gameDandT,13,' ')||
            RPAD(homeT,13,' ')||RPAD(homeS,13,' ')||RPAD(visitT,13,' ')||RPAD(visitS,13,' ')||RPAD(location_id,13,' ')||
            RPAD(isPlayed2,13,' ')||RPAD(NVL(notes2,'null'),13,' '));
    END LOOP;
    CLOSE gamesselect_refcursor;
END;

-- 10. Create a stored procedure, spSchedPastGames, using DBMS_OUTPUT,
-- that displays the games that have been played in the past n days, where n is an input parameter. 
-- Make sure your code will work on any day of the year.

CREATE OR REPLACE PROCEDURE spSchedPastGames ( days IN INT,refcursor OUT SYS_REFCURSOR, errorCode OUT NUMBER)AS
BEGIN
    OPEN refcursor
    FOR SELECT * FROM TABLE(gamesoutput(CURSOR(SELECT* FROM games))) 
    WHERE  gameDandT LIKE To_Date(SYSDATE-days,'DD-MON-YY'); 
    errorCode:= 10;
EXCEPTION
    WHEN OTHERS 
        THEN
        errorCode :=1;
END;

DECLARE
    newErrorCode NUMBER:=0;
    gamesselect_refcursor refcur_games.refcur_g;
    game_id NUMBER(38,0);
    div_id NUMBER(38,0);
    game_num NUMBER(38,0);
    gameDandT DATE;
    homeT NUMBER(38,0);
    homeS NUMBER(38,0);
    visitT NUMBER(38,0);
    visitS NUMBER(38,0);
    location_id NUMBER(38,0);
    isPlayed2 NUMBER(38,0);
    notes2 VARCHAR2(50);
BEGIN
 spSchedPastGames(16,gamesselect_refcursor, newErrorCode);
  DBMS_OUTPUT.PUT_LINE('Error Code: '||newErrorCode);
  DBMS_OUTPUT.PUT_LINE(RPAD('game ID',13,' ')||RPAD('divID',13,' ')||RPAD('game num',13,' ')||RPAD('gameDateTime',13,' ')||
    RPAD('homeTeam',13,' ')||RPAD('homeScore',13,' ')||RPAD('visitTeam',13,' ')||RPAD('visitScore',13,' ')||
    RPAD('location_id',13,' ')||RPAD('isPlayed',13,' ')||RPAD('notes',13,' '));
    LOOP
        FETCH gamesselect_refcursor
        INTO game_id, div_id, game_num, gameDandT, homeT, homeS, visitT, visitS, location_id, isPlayed2, notes2;
        EXIT WHEN gamesselect_refcursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(RPAD(game_id, 13, ' ')||RPAD(div_id,13,' ')||RPAD(game_num,13,' ')||RPAD(gameDandT,13,' ')||
            RPAD(homeT,13,' ')||RPAD(homeS,13,' ')||RPAD(visitT,13,' ')||RPAD(visitS,13,' ')||RPAD(location_id,13,' ')||
            RPAD(isPlayed2,13,' ')||RPAD(NVL(notes2,'null'),13,' '));
    END LOOP;
    CLOSE gamesselect_refcursor;
END;

-- 11. Each group must be creative and come up with an object (SP, UDF, or potentially trigger),of your own choosing, 
-- that will be built in the database to help support the same ideals of the above objects.

-- Description: spSchedBtweenGames displays the games that are either played or to be played
-- in the given period based on today's date; startdays and enddays from today are input parameters!

CREATE OR REPLACE PROCEDURE spSchedBtweenGames ( startdays IN INT, enddays IN INT,refcursor OUT SYS_REFCURSOR, errorCode OUT NUMBER)AS
BEGIN
    OPEN refcursor
    FOR SELECT * FROM TABLE(gamesoutput(CURSOR(SELECT* FROM games))) 
    WHERE
        TRUNC(TO_DATE(gameDandT,'DD-MON-YY')) BETWEEN 
        TRUNC(TO_DATE(SYSDATE - startdays,'DD-MON-YY')) AND 
        TRUNC(TO_DATE(SYSDATE + enddays,'DD-MON-YY'));
        
    errorCode:= 10;
EXCEPTION
    WHEN OTHERS 
        THEN
        errorCode :=1;
END;

DECLARE
    newErrorCode NUMBER:=0;
    gamesselect_refcursor refcur_games.refcur_g;
    game_id NUMBER(38,0);
    div_id NUMBER(38,0);
    game_num NUMBER(38,0);
    gameDandT DATE;
    homeT NUMBER(38,0);
    homeS NUMBER(38,0);
    visitT NUMBER(38,0);
    visitS NUMBER(38,0);
    location_id NUMBER(38,0);
    isPlayed2 NUMBER(38,0);
    notes2 VARCHAR2(50);
BEGIN
 spSchedBtweenGames(16,2,gamesselect_refcursor, newErrorCode);
  DBMS_OUTPUT.PUT_LINE('Error Code: '||newErrorCode);
  DBMS_OUTPUT.PUT_LINE(RPAD('game ID',13,' ')||RPAD('divID',13,' ')||RPAD('game num',13,' ')||RPAD('gameDateTime',13,' ')||
    RPAD('homeTeam',13,' ')||RPAD('homeScore',13,' ')||RPAD('visitTeam',13,' ')||RPAD('visitScore',13,' ')||
    RPAD('location_id',13,' ')||RPAD('isPlayed',13,' ')||RPAD('notes',13,' '));
    LOOP
        FETCH gamesselect_refcursor
        INTO game_id, div_id, game_num, gameDandT, homeT, homeS, visitT, visitS, location_id, isPlayed2, notes2;
        EXIT WHEN gamesselect_refcursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(RPAD(game_id, 13, ' ')||RPAD(div_id,13,' ')||RPAD(game_num,13,' ')||RPAD(gameDandT,13,' ')||
            RPAD(homeT,13,' ')||RPAD(homeS,13,' ')||RPAD(visitT,13,' ')||RPAD(visitS,13,' ')||RPAD(location_id,13,' ')||
            RPAD(isPlayed2,13,' ')||RPAD(NVL(notes2,'null'),13,' '));
    END LOOP;
    CLOSE gamesselect_refcursor;
END;
