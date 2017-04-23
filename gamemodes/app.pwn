#include <a_samp>
#include <a_mysql>
#include <zcmd>

/* -- TABLE OF ID's --
 1-25       = Account Dialogs
 1001-2000  = Dunnos
*/

/* Server Information */
#define    SERVER_NAME      "Furious Freeroam"
#define    SERVER_IP        "127.0.0.1:7777"
#define    SERVER_GAMEMODE  "CameronCT"
#define    SERVER_MAP       "CTCameron"

/* BCRYPT Settings */
#define    BCRYPT_COST      15

/* Spawn Information */
#define    SPAWN_POS_X      1958.3783
#define    SPAWN_POS_Y      1343.1572
#define    SPAWN_POS_Z      15.3746

/* Database Information */
#define    MYSQL_HOST     "localhost"
#define    MYSQL_USER     "root"
#define    MYSQL_PASS     "password"
#define    MYSQL_DB       "samp"

/* Colors RGBA */
#define     COLOR_GREY      0xAFAFAFAA
#define     COLOR_GREEN     0x33AA33AA
#define     COLOR_RED       0xAA3333AA
#define     COLOR_YELLOW    0xFFFF00AA
#define     COLOR_WHITE     0xFFFFFFAA
#define     COLOR_BLUE      0x0000BBAA
#define     COLOR_LIGHTBLUE 0x33CCFFAA
#define     COLOR_ORANGE    0xFF9900AA
#define     COLOR_BLACK     0x000000AA
#define     COLOR_BROWN     0XA52A2AAA
#define     COLOR_GOLD      0xB8860BAA

/* Colors HEX */
#define     HEX_RED       "{FF0000}"
#define     HEX_WHITE     "{FFFFFF}"
#define     HEX_YELLOW    "{FFFF00}"

/* Account Dialogs */
#define     DIALOG_LOGIN       1
#define     DIALOG_REGISTER    2
#define     DIALOG_EMAIL       3
#define     DIALOG_SECURITY    4

/* Player Data */
enum E_PLAYER {
	ID,
    Name[MAX_PLAYER_NAME],
    Email[192],
    Password[65],
    Cache: Cache,
    bool:Logged,
    bool:Registered,
    Attempts,
    LoginTimer
};
new Player[MAX_PLAYERS][E_PLAYER];

/* Variables */
new
    MySQL:zSQL,
	zSQLRace[MAX_PLAYERS],
    zQuery[256],
    zString[256];

/* Macros */
#define isnull(%1) ((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))

/* Whirlpool */
native WP_Hash(buffer[], len, const str[]);

/* Functions */
forward OnConnectResponse(playerid, race);
forward OnPlayerRegister(playerid);

forward FetchPlayerData(playerid);
forward UpdatePlayerData(playerid);

/* Functions > Bcrypt */
forward OnPasswordHashed(playerid);
forward OnPasswordChecked(playerid);

main() { }
public OnGameModeInit() {
    /* Cuz fuck this error */
    zString = "test";

    /* Database -> Initiate */
    zSQL = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_DB);
    if(mysql_errno() == 0) {
        /* Create Structure */
        DatabaseStructure();
    } else {
        print(" ");
        print("[MySQL] Error Connecting!");
        print("--------------------------------");
        print("Host: "MYSQL_HOST" - User: "MYSQL_USER" - Pass: "MYSQL_PASS" - Database: "MYSQL_DB"");
    }

    SetGameModeText(SERVER_NAME);
    AddPlayerClass(0, SPAWN_POS_X, SPAWN_POS_Y, SPAWN_POS_Z, 269.1425, 0, 0, 0, 0, 0, 0);
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
    SetPlayerPos(playerid, SPAWN_POS_X, SPAWN_POS_Y, SPAWN_POS_Z);
    SetPlayerCameraPos(playerid, SPAWN_POS_X, SPAWN_POS_Y, SPAWN_POS_Z);
    SetPlayerCameraLookAt(playerid, SPAWN_POS_X, SPAWN_POS_Y, SPAWN_POS_Z);

    /* Greetings */
    SendClientMessage(playerid, -1, " "HEX_RED" Welcome to our "HEX_YELLOW"server!");

    /* Queue Login */
    szName = getPlayerName(playerid);
    mysql_format(zSQL, zQuery, sizeof(zQuery), "SELECT a_id, a_name, a_password, a_email, a_money, a_score, a_kills, a_deaths FROM accounts WHERE a_name = '%e' LIMIT 1", szName);
    mysql_tquery(zSQL, zQuery, "OnConnectResponse", "dd", playerid, zSQLRace[playerid]);
    return 1;
}

public OnPlayerConnect(playerid) {
    zSQLRace[playerid]++;
    
    Player[playerid][Logged]   = false;
    Player[playerid][Attempts] = 0;
    return 1;
}

public OnPlayerDisconnect(playerid, reason) {
    zSQLRace[playerid]++;
    
    if (cache_is_valid(Player[playerid][Cache]))
		clearCache(playerid);
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

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    switch(dialogid) {
        case DIALOG_LOGIN: {
            if (response && !isnull(inputtext)) {
                
                new
					PasswordHash[65];
					
                WP_Hash(PasswordHash, sizeof(PasswordHash), inputtext);
				
				
                
            } else Kick(playerid);
            return 1;
        }
        case DIALOG_REGISTER: {
            if (response && !isnull(inputtext)) {
				if (strlen(inputtext) <= 1)
					return ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Register", "Your password cannot be empty, please enter a password!", "Create", "Cancel");

                new
					PasswordHash[65];

                WP_Hash(PasswordHash, sizeof(PasswordHash), inputtext);
				
				mysql_format(zSQL, zQuery, sizeof(zQuery), "INSERT INTO accounts ( a_username, a_password ) VALUES ( '%e', '%e' )", Player[playerid][Name], Player[playerid][Password]);
				mysql_tquery(zSQL, zQuery, "OnPlayerRegister", "d", playerid);
				
                /* Query Stuff */
                SendClientMessage(playerid, -1, "You have successfully registered your account, please look");
            } else Kick(playerid);
            return 1;
        }
    }
    return 0;
}

public OnConnectResponse(playerid, race) {
	if (race != zSQLRace[playerid])
	    return Kick(playerid);
	
    if (cache_num_rows() == 1) {
		cache_get_value(0, "a_username", Player[playerid][Name], MAX_PLAYER_NAME);
		cache_get_value(0, "a_password", Player[playerid][Password], 65);
        Player[playerid][Cache] = cache_save();
    
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", "Your account exists in our database, please enter your password!", "Login", "Cancel");
    } else
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Register", "It looks like you do not have an account, today is your lucky day to secure this name!", "Create", "Cancel");
    return 1;
}

// ------ Commands
CMD:help(playerid, params[]) {
	SendGlobalMessage("I love turtles");
	SendErrorMessage(playerid, "This is not done yet, sorry");
	return 1;
}

// ------ Send Messages
stock SendErrorMessage(playerid, msg[]) {
	return SendClientMessage(playerid, COLOR_RED, msg);
}

stock SendInfoMessage(playerid, msg[]) {
	return SendClientMessage(playerid, COLOR_BLUE, msg);
}

stock SendGlobalMessage(msg[]) {
	return SendClientMessageToAll(COLOR_ORANGE, msg);
}

// ------ Player
getPlayerName(playerid) {
    new
       szName[MAX_PLAYER_NAME];

    GetPlayerName(playerid, szName, MAX_PLAYER_NAME);
    return szName;
}

// ------ MySQL Related
DatabaseStructure() {
    mysql_query_file(zSQL, "database.sql");
    return 1;
}

clearCache(playerid) {
    cache_delete(Player[playerid][Cache]);
    Player[playerid][Cache] = MYSQL_INVALID_CACHE;
    return 1;
}

