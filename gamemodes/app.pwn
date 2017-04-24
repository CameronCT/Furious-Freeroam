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
#define    SERVER_WEBSITE   "google.com"

/* Password Settings */
#define    PASSWORD_BUFFER  129

/* Limits */
#define    MAX_ATTEMPTS     3 // Maximum Password Attempts

/* Spawn Information */
#define    SPAWN_POS_X      1958.3783
#define    SPAWN_POS_Y      1343.1572
#define    SPAWN_POS_Z      15.3746
#define    SPAWN_POS_A      269.1425

/* Database Information */
#define    MYSQL_HOST     "localhost"
#define    MYSQL_USER     "root"
#define    MYSQL_PASS     "password"
#define    MYSQL_DB       "samp"

/* Command Permissions */

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
#define     DIALOG_INFO        0
#define     DIALOG_LOGIN       1
#define     DIALOG_REGISTER    2
#define     DIALOG_EMAIL       3
#define     DIALOG_SECURITY    4

/* Variables */
new
    MySQL:zSQL,
    PasswordBuffer[PASSWORD_BUFFER],
    zSQLRace[MAX_PLAYERS],
    zQuery[128],
    zQueryL[192],
    zQueryXL[256],
    zString[128],
    zStringL[192],
    zStringXL[256];

/* Player Data */
enum E_PLAYER {
    ID,
    Name[MAX_PLAYER_NAME],
    Email[192],
    Password[PASSWORD_BUFFER],
    IP[16],
    LastIP[16],
    Admin,
    Cache: Cache,
    bool:Logged,
    LoggedTimer,
    LoggedAttempts,
    Registered[64],
    Kills,
    Deaths,
    Money,
    Score,
    Float:Health,
    Float:Armour
};
new Player[MAX_PLAYERS][E_PLAYER];

/* Macros */
#define isnull(%1) ((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))

/* Whirlpool */
native WP_Hash(buffer[], len, const str[]);

/* Functions */
forward OnConnectCheck(playerid, race);
forward OnPlayerCheck(playerid);
forward OnPlayerRegister(playerid);
forward OnPlayerLogin(playerid);

forward FetchPlayerData(playerid);
forward UpdatePlayerData(playerid);

/* Anticheat */
forward OnAnticheatCheck(playerid);

main() { }
public OnGameModeInit() {
    /* Database -> Initiate */
    //mysql_log(ALL);
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
    AddPlayerClass(0, SPAWN_POS_X, SPAWN_POS_Y, SPAWN_POS_Z, SPAWN_POS_A, 0, 0, 0, 0, 0, 0);
    return 1;
}

public OnGameModeExit() {
    // ------ Save Data on GameMode Exit [https://github.com/pBlueG/SA-MP-MySQL/blob/master/example_scripts/login_system-cache.pwn]
    for (new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
        if (IsPlayerConnected(i))
            OnPlayerDisconnect(i, 1);

    mysql_close(zSQL);
    return 1;
}

public OnPlayerRequestClass(playerid, classid) {
    /* Scenery */
    SetPlayerPos(playerid, SPAWN_POS_X, SPAWN_POS_Y, SPAWN_POS_Z);
    SetPlayerCameraPos(playerid, SPAWN_POS_X, SPAWN_POS_Y, SPAWN_POS_Z);
    SetPlayerCameraLookAt(playerid, SPAWN_POS_X, SPAWN_POS_Y, SPAWN_POS_Z);

    /* Greetings */
    SendClientMessage(playerid, -1, HEX_RED" Welcome to our "HEX_YELLOW"server!");

    /* Queue Login */
    mysql_format(zSQL, zQueryL, sizeof(zQueryL), "SELECT b_id, b_ip, b_reason, b_datetime FROM bans WHERE b_ip = '%e' LIMIT 1", getPlayerIP(playerid));
    mysql_tquery(zSQL, zQueryL, "OnConnectCheck", "dd", playerid, zSQLRace[playerid]);
    return 1;
}

public OnPlayerConnect(playerid) {
    zSQLRace[playerid]++;
    
    Player[playerid][Logged]   = false;
    Player[playerid][LoggedAttempts] = 0;

    SetTimerEx("OnAnticheatCheck", 1000, true, "d", playerid);
    return 1;
}

public OnPlayerDisconnect(playerid, reason) {
    zSQLRace[playerid]++;

    SavePlayerData(playerid);
    
    if (cache_is_valid(Player[playerid][Cache]))
        clearCache(playerid);
        
    Player[playerid][Logged] = false;
    return 1;
}

public OnPlayerSpawn(playerid) {
    zSetPlayerHealth(playerid, 99.0);
    
    GivePlayerWeapon(playerid, 38, 500);
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason) {
    if (killerid == INVALID_PLAYER_ID) return 0;
    if (Player[killerid][Logged] == false) return 0;
    
    Player[killerid][Kills]++;
    Player[playerid][Deaths]++;
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

public OnPlayerUpdate(playerid) {
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
        case DIALOG_INFO: return 1;
        case DIALOG_LOGIN: {
            if (response) {
                WP_Hash(PasswordBuffer, sizeof(PasswordBuffer), inputtext);
                
                if (!strcmp(PasswordBuffer, Player[playerid][Password], false)) {
                    mysql_format(zSQL, zQueryL, sizeof(zQueryL), "SELECT * FROM accounts WHERE a_name = '%e' LIMIT 1", Player[playerid][Name]);
                    mysql_tquery(zSQL, zQueryL, "OnPlayerLogin", "d", playerid);
                } else {
                    Player[playerid][LoggedAttempts]++;
                    if (Player[playerid][LoggedAttempts] >= MAX_ATTEMPTS+1) {
                        format(zString, sizeof(zString), "Putting in the wrong password more than %d times.", MAX_ATTEMPTS);
                        KickPlayer(playerid, "Server", zString);
                    } else {
                        format(zString, sizeof(zString), "(%d/%d) The password you have entered is incorrect, please try again.", Player[playerid][LoggedAttempts], MAX_ATTEMPTS);
                        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", zString, "Login", "Cancel");
                    }
                }
            } else KickPlayer(playerid, "Server", "Not putting in your password when prompted.");
            return 1;
        }
        case DIALOG_REGISTER: {
            if (response && !isnull(inputtext)) {
                if (strlen(inputtext) <= 1)
                    return ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Register", "Your password cannot be empty, please enter a password!", "Create", "Cancel");

                WP_Hash(PasswordBuffer, sizeof(PasswordBuffer), inputtext);

                mysql_format(zSQL, zQueryXL, sizeof(zQueryXL), "INSERT INTO accounts ( a_name, a_password, a_ip, a_lastip ) VALUES ( '%e', '%e', '%s', '%s' )", Player[playerid][Name], PasswordBuffer, getPlayerIP(playerid), getPlayerIP(playerid));
                mysql_tquery(zSQL, zQueryXL, "OnPlayerRegister", "d", playerid);
            } else KickPlayer(playerid, "Server", "Not putting in your password when prompted.");
            return 1;
        }
    }
    return 0;
}

// ------ Commands
CMD:help(playerid, params[]) {
    SendGlobalMessage("I love turtles");
    SendErrorMessage(playerid, "This is not done yet, sorry");
    return 1;
}

CMD:stats(playerid, params[]) {
   format(zStringXL, sizeof(zStringXL), ""HEX_YELLOW"ID:"HEX_WHITE" %d\n", Player[playerid][ID]);
   format(zStringXL, sizeof(zStringXL), "%s"HEX_YELLOW"Name:"HEX_WHITE" %s\n", zStringXL, Player[playerid][Name]);
   format(zStringXL, sizeof(zStringXL), "%s"HEX_YELLOW"Admin:"HEX_WHITE" %d\n", zStringXL, Player[playerid][Admin]);
   format(zStringXL, sizeof(zStringXL), "%s"HEX_YELLOW"IP:"HEX_WHITE" %s\n", zStringXL, Player[playerid][LastIP]);
   format(zStringXL, sizeof(zStringXL), "%s"HEX_YELLOW"Kills:"HEX_WHITE" %d\n", zStringXL, Player[playerid][Kills]);
   format(zStringXL, sizeof(zStringXL), "%s"HEX_YELLOW"Deaths:"HEX_WHITE" %d\n", zStringXL, Player[playerid][Deaths]);
   format(zStringXL, sizeof(zStringXL), "%s"HEX_YELLOW"Registered:"HEX_WHITE" %s\n", zStringXL, Player[playerid][Registered]);
   format(zStringXL, sizeof(zStringXL), "%s"HEX_YELLOW"Logged:"HEX_WHITE" %d\n", zStringXL, Player[playerid][Logged]);
   ShowPlayerDialog(playerid, DIALOG_INFO, DIALOG_STYLE_MSGBOX, ""HEX_YELLOW" Statistics", zStringXL, "Okay", "");
   return 1;
}


CMD:anticheat(playerid, params[]) {
    if (Player[playerid][Admin] <= 0) return SendErrorMessage(playerid, "You are not authorized to view this command");

    new
       Float:zHealth,
       Float:zArmour;

    GetPlayerHealth(playerid, zHealth);
    GetPlayerArmour(playerid, zArmour);

    format(zStringXL, sizeof(zStringXL),
        ""HEX_YELLOW"Money:"HEX_WHITE" $%d ($%d)\n"HEX_YELLOW"Score:"HEX_WHITE" %d (%d)\n"HEX_YELLOW"Health:"HEX_WHITE" %f (%f)\n"HEX_YELLOW"Armour:"HEX_WHITE" %f (%f)\n",
        GetPlayerMoney(playerid),
        Player[playerid][Money],
        GetPlayerScore(playerid),
        Player[playerid][Score],
        zHealth,
        Player[playerid][Health],
        zArmour,
        Player[playerid][Armour]
    );
    ShowPlayerDialog(playerid, DIALOG_INFO, DIALOG_STYLE_MSGBOX, ""HEX_YELLOW" Anticheat Debug", zStringXL, "X", "");
    return 1;
}

CMD:kill(playerid, params[]) {
    SetPlayerHealth(playerid, 0);
    return 1;
}

CMD:savestats(playerid, params[]) {
    SavePlayerData(playerid);
    SendInfoMessage(playerid, "Your stats have successfully been saved!");
    return 1;
}

CMD:acmoney(playerid, params[]) {
    GivePlayerMoney(playerid, 500);
    return 1;
}

CMD:acmoneysafe(playerid, params[]) {
    zGivePlayerMoney(playerid, 1000);
    zSetPlayerScore(playerid, 25);
    return 1;
}

CMD:achealth(playerid, params[]) {
    SetPlayerHealth(playerid, 52.0);
    return 1;
}

CMD:achealthsafe(playerid, params[]) {
    zSetPlayerHealth(playerid, 50.0);
    return 1;
}

CMD:fakedeath(playerid, params[]) {
	Player[playerid][Kills]+=5;
	Player[playerid][Deaths]++;
	SendClientMessage(playerid, -1, "Fake kills and deaths added?");
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

getPlayerIP(playerid) {
	new
	   szIP[16];
	   
	GetPlayerIp(playerid, szIP, sizeof(szIP));
	return szIP;
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

// ------ Accounts
public OnConnectCheck(playerid, race) {
    if (race != zSQLRace[playerid])
        return Kick(playerid);

	if (cache_num_rows() == 1) {
		new
			Datetime[64],
			Reason[255];
			
		cache_get_value_name(0, "b_reason", Reason, 255);
		cache_get_value_name(0, "b_datetime", Datetime, 255);

		/* Ban stuff here */
		format(zStringXL, sizeof(zStringXL), ""HEX_WHITE"You have been banned from the server for violating one or more of our rules.\n\n");
		format(zStringXL, sizeof(zStringXL), "%s"HEX_YELLOW"Reason:"HEX_WHITE" %s\n", zStringXL, Reason);
		format(zStringXL, sizeof(zStringXL), "%s"HEX_YELLOW"When:"HEX_WHITE" %s\n", zStringXL, Datetime);
		format(zStringXL, sizeof(zStringXL), "%s\n"HEX_WHITE"If you feel that you have been wrongfully banned, please go to "SERVER_WEBSITE".", zStringXL);
        ShowPlayerDialog(playerid, DIALOG_INFO, DIALOG_STYLE_MSGBOX, "You are banned from this server!", zStringXL, "X", "");
        SetTimerEx("_KickPlayer", 500, false, "d", playerid);
	} else {
        Player[playerid][Name] = getPlayerName(playerid);
        mysql_format(zSQL, zQueryL, sizeof(zQueryL), "SELECT a_id, a_password FROM accounts WHERE a_name = '%e' LIMIT 1", Player[playerid][Name]);
        mysql_tquery(zSQL, zQueryL, "OnPlayerCheck", "d", playerid);
	}
	return 1;
}
public OnPlayerCheck(playerid) {
    if (cache_num_rows() == 1) {
        Player[playerid][Cache] = cache_save();
        cache_get_value_name(0, "a_password", Player[playerid][Password], 129);
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", "Your account exists in our database, please enter your password!", "Login", "Cancel");
    } else
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Register", "It looks like you do not have an account, today is your lucky day to secure this name!", "Create", "Cancel");
    return 1;
}

public OnPlayerRegister(playerid) {
    Player[playerid][ID]        = cache_insert_id();
    Player[playerid][Logged]    = true;

    SetSpawnInfo(playerid, NO_TEAM, 0, SPAWN_POS_X, SPAWN_POS_Y, SPAWN_POS_Z, SPAWN_POS_A, 0, 0, 0, 0, 0, 0);
    SpawnPlayer(playerid);

    ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", "Your account exists in our database, please enter your password!", "Login", "Cancel");
    return 1;
}

public OnPlayerLogin(playerid) {
    Player[playerid][Cache] = cache_save();
	FetchPlayerData(playerid);
    Player[playerid][Logged] = true;
    
    SetSpawnInfo(playerid, NO_TEAM, 0, SPAWN_POS_X, SPAWN_POS_Y, SPAWN_POS_Z, SPAWN_POS_A, 0, 0, 0, 0, 0, 0);
    SpawnPlayer(playerid);
}

FetchPlayerData(playerid) {
    cache_set_active(Player[playerid][Cache]);

    /* Data */
    cache_get_value_name(0, "a_name", Player[playerid][Name], MAX_PLAYER_NAME);
    cache_get_value_name(0, "a_password", Player[playerid][Password], 129);
    cache_get_value_name(0, "a_datetime", Player[playerid][Registered], 64);
    cache_get_value_name(0, "a_ip", Player[playerid][IP], 16);
    cache_get_value_name(0, "a_lastip", Player[playerid][LastIP], 16);
    cache_get_value_int(0, "a_id", Player[playerid][ID]);
    cache_get_value_int(0, "a_admin", Player[playerid][Admin]);
    cache_get_value_int(0, "a_kills", Player[playerid][Kills]);
    cache_get_value_int(0, "a_deaths", Player[playerid][Deaths]);
    cache_get_value_int(0, "a_money", Player[playerid][Money]);
    cache_get_value_int(0, "a_score", Player[playerid][Score]);
    
    cache_delete(Player[playerid][Cache]);
    Player[playerid][Cache] = MYSQL_INVALID_CACHE;

    zSetPlayerMoney(playerid, Player[playerid][Money]);
    zSetPlayerScore(playerid, Player[playerid][Score]);
    zSetPlayerHealth(playerid, Player[playerid][Health]);
    zSetPlayerArmour(playerid, Player[playerid][Armour]);
    return 1;
}

SavePlayerData(playerid) {
    if (Player[playerid][Logged] == false) return 0;
    
    mysql_format(zSQL, zQueryL, sizeof(zQueryL), "UPDATE accounts SET a_lastip = '%s', a_admin = %d, a_kills = %d, a_deaths = %d, a_money = %d, a_score = %d WHERE a_id = %d", getPlayerIP(playerid), Player[playerid][Admin], Player[playerid][Kills], Player[playerid][Deaths], Player[playerid][Money], Player[playerid][Score], Player[playerid][ID]);
    mysql_tquery(zSQL, zQueryL);
    return 1;
}

// ------ Anticheat (http://forum.sa-mp.com/showthread.php?t=186988)
public OnAnticheatCheck(playerid) {
    new
       Float:zHealth,
       Float:zArmour;

    GetPlayerHealth(playerid, zHealth);
    GetPlayerArmour(playerid, zArmour);

    if (GetPlayerMoney(playerid) > Player[playerid][Money]) {
        format(zString, sizeof(zString), "Money Cheating (%d - %d)", GetPlayerMoney(playerid), Player[playerid][Money]);
        BanPlayer(playerid, "Anticheat", zString);
	}
        
    if (GetPlayerScore(playerid) > Player[playerid][Score]) {
        format(zString, sizeof(zString), "Score Cheating (%d - %d)", GetPlayerScore(playerid), Player[playerid][Score]);
        BanPlayer(playerid, "Anticheat", zString);
	}
        
    if (zHealth > Player[playerid][Health]) {
        format(zString, sizeof(zString), "Health Cheating (%.1f - %.1f)", zHealth, Player[playerid][Health]);
        BanPlayer(playerid, "Anticheat", zString);
	}
        
    if (zArmour > Player[playerid][Armour]) {
        format(zString, sizeof(zString), "Armour Cheating (%.1f - %.1f)", zArmour, Player[playerid][Armour]);
        BanPlayer(playerid, "Anticheat", zString);
	}
        
    return 1;
}

zGivePlayerMoney(playerid, money) {
    Player[playerid][Money] += money;
    GivePlayerMoney(playerid, money);
}

zSetPlayerMoney(playerid, money) {
    Player[playerid][Money] = money;
    GivePlayerMoney(playerid, money);
}

zSetPlayerScore(playerid, score) {
    Player[playerid][Score] = score;
    SetPlayerScore(playerid, score);
}

zSetPlayerHealth(playerid, Float:health) {
    Player[playerid][Health] = health;
    SetPlayerHealth(playerid, health);
}

zSetPlayerArmour(playerid, Float:armor) {
    Player[playerid][Armour] = armor;
    SetPlayerArmour(playerid, armor);
}

// ------ Kick / Ban
BanPlayer(playerid, user[], reason[]) {
    mysql_format(zSQL, zQueryL, sizeof(zQueryL), "INSERT INTO bans ( b_ip, b_reason ) VALUES ( '%s', '%e' )", getPlayerIP(playerid), reason);
    mysql_tquery(zSQL, zQueryL);
    
    format(zStringXL, sizeof(zStringXL), ""HEX_WHITE"You have been banned from the server for violating one or more of our rules.\n\n"HEX_YELLOW"User:"HEX_WHITE" %s\n"HEX_YELLOW"Reason:"HEX_WHITE" %s\n\nIf you feel that you have been wrongfully banned, please go to "SERVER_WEBSITE".", user, reason);
    ShowPlayerDialog(playerid, DIALOG_INFO, DIALOG_STYLE_MSGBOX, "You have been removed from the server!", zStringXL, "X", "");
    SetTimerEx("_KickPlayer", 500, false, "d", playerid);
}

KickPlayer(playerid, user[], reason[]) {
    format(zStringXL, sizeof(zStringXL), ""HEX_WHITE"You have been kicked from the server for violating one or more of our rules.\n\n"HEX_YELLOW"User:"HEX_WHITE" %s\n"HEX_YELLOW"Reason:"HEX_WHITE" %s\n\nYou may come back to the server anytime, but please think over why you were kicked to prevent further risk of a ban.", user, reason);
    ShowPlayerDialog(playerid, DIALOG_INFO, DIALOG_STYLE_MSGBOX, ""HEX_YELLOW" You have been removed from the server!", zStringXL, "X", "");
    SetTimerEx("_KickPlayer", 500, false, "d", playerid);
}

forward _BanPlayer(playerid, reason[]);
public _BanPlayer(playerid, reason[]) {
    BanEx(playerid, reason);
}

forward _KickPlayer(playerid);
public _KickPlayer(playerid) {
    Kick(playerid);
}

