#include <a_samp>
#include <a_mysql>
#include <zcmd>

/* -- TABLE OF ID's --
 1-25       = Account Dialogs
 1001-2000  = Dunnos
*/

/* Server Information */
#define    SERVER_NAME    "Furious Freeroam"
#define    SERVER_IP      "127.0.0.1:7777"
#define    SERVER_GAMEMODE "CameronCT"
#define    SERVER_MAP     "CTCameron"

/* Database Information */
#define    MYSQL_HOST     "127.0.0.1"
#define    MYSQL_USER     "root"
#define    MYSQL_PASS     "root"
#define    MYSQL_DB       "server"
#define    MYSQL_PORT     "3306"

/* Colors RGBA */
#define 	COLOR_GREY      0xAFAFAFAA
#define 	COLOR_GREEN     0x33AA33AA
#define 	COLOR_RED       0xAA3333AA
#define 	COLOR_YELLOW    0xFFFF00AA
#define 	COLOR_WHITE     0xFFFFFFAA
#define 	COLOR_BLUE      0x0000BBAA
#define 	COLOR_LIGHTBLUE 0x33CCFFAA
#define 	COLOR_ORANGE    0xFF9900AA
#define 	COLOR_BLACK     0x000000AA
#define 	COLOR_BROWN     0XA52A2AAA
#define 	COLOR_GOLD      0xB8860BAA

/* Colors HEX */
#define     HEX_RED       "{FF0000}"
#define     HEX_WHITE     "{FFFFFF}"
#define     HEX_YELLOW    "{FFFF00}"

/* Account Dialogs */
#define     DIALOG_LOGIN       1
#define     DIALOG_REGISTER    2
#define     DIALOG_SECURITY    3

/* Player Data */
enum Player_Info {
	bool:Logged,
	bool:Registered,
	Name[MAX_PLAYER_NAME],
	Attempts,
	LoginTimer
};
new Player[MAX_PLAYERS][Player_Info];

/* Variables */
new
	MySQL:zSQL,
	zQuery[256],
    zString[256];
	
/* Macros */
#define isnull(%1) ((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))

/* Functions */
forward checkAccountExists(playerid);
forward OnConnectResponse(playerid);

main() { }
public OnGameModeInit() {
	/* Cuz fuck this error */
	zString = "test";
	
	/* Database -> Initiate */
	zSQL = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_DB, MYSQL_PASS);
	if(mysql_errno() == 0) {
	    /* Debugging On */
		mysql_log(ALL);
	
	    /* Create Structure */
		DatabaseStructure();
	} else print("Unable to connect to database!");
	
	SetGameModeText(SERVER_NAME);
	AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	return 1;
}

public OnGameModeExit() {
	mysql_close(zSQL);
	return 1;
}

public OnPlayerRequestClass(playerid, classid) {
	new
		szName[24];
		
	/* Scenery */
	SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
	
	/* Greetings */
	SendClientMessage(playerid, -1, " "HEX_RED" Welcome to our "HEX_YELLOW"server!");
	
	/* Queue Login */
 	szName = getPlayerName(playerid);
 	mysql_format(zSQL, zQuery, sizeof(zQuery), "SELECT a_id FROM accounts WHERE a_name = '%e'", szName);
 	mysql_tquery(zSQL, zQuery, "OnConnectResponse", "d", playerid);
	return 1;
}

public OnPlayerConnect(playerid) {
	Player[playerid][Logged]   = false;
	Player[playerid][Attempts] = 0;
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	return 1;
}

public OnPlayerSpawn(playerid)
{
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

stock getPlayerName(playerid) {
	new
	   szName[MAX_PLAYER_NAME];

	GetPlayerName(playerid, szName, MAX_PLAYER_NAME);
	return szName;
}

stock DatabaseStructure() {
	return 1;
}

public OnConnectResponse(playerid) {
	return 1;
}
