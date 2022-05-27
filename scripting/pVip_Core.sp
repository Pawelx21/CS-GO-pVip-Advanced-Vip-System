/* Thanks to BCServ for few functions from SMLib which I have changed.*/
/********************************* [ ChangeLog ] ********************************
*
*	1.0.0 - Pierwsze wydanie pluginu.
*	1.0.1 - Przerobienie funkcji do dodawania broni z amunicją. Poprawa drobnych błędów.
*	1.0.2 - Przerobienie funkcji SetClientHealth oraz CheckFlags
*	1.0.3 - Poprawa nadawania grupy
*	1.0.4 - Dodanie nativów do włączania/wyłączania działania systemu oraz pobierania stanu jego działania.
*	1.0.5 - Dodano zestawy granatów do menu broni, dodatkowe zabezpieczenia, możliwość włączenia/wyłączenia double jumpa, możliwość tworzenia grup dla zwykłych graczy (brak flag)
*	1.0.6 - Dodano kompatybilność z pShop-Chatem.
*	1.0.7 - Dodano nativ, który wyszukje ID grupy po jego flagach oraz drużynie.
*	1.0.8 - Poprawiono nadawanie grup dla graczy.
*
********************************** [ ChangeLog ] *******************************/

/* [ Includes ] */
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <multicolors>
#include <cstrike>
#include <pVip-Core>

/* [ Compiler Options ] */
#pragma newdecls required
#pragma semicolon		1

/* [ Defines ] */
#define LoopValidClients(%1)		for(int %1 = 1; %1 < MaxClients; %1++) if(IsValidClient(%1))
#define MAX_GROUPS			16
#define MAX_GRENADES_SETS	10
#define PRIMARY				0
#define SECONDARY			1
#define MAIN				2
#define GRENADES			3
#define TAG					0
#define COLOR				1
#define NAME				2
#define MESSAGE				3

/* [ Global Forwards ] */
GlobalForward g_gfSpawn;
GlobalForward g_gfGroupReceived;
GlobalForward g_gfRespawned;
GlobalForward g_gfConfigLoaded;

/* [ Enums ] */
Enum_VipGroupInfo g_eGroup[MAX_GROUPS];
Enum_VipClientInfo g_eInfo[MAXPLAYERS + 1];
Enum_VipCoreInfo g_eCore;
Enum_VipGrenadeSetsInfo g_eGrenades[MAX_GRENADES_SETS];

/* [ Handles ] */
Handle g_hHud;

/* [ ArrayLists ] */
ArrayList g_arWeapons[2][5];

/* [ Integers ] */
int g_iValue;
int g_iPhase;

/* [ Floats ] */
float g_fValue;

/* [ Chars ] */
char g_sConVars[][][] = {
	{ "Flags", "o" }, { "Team", "0" }, { "Double_Jump", "1" }, { "Table_Tag", "[ VIP ] " }, { "Chat_Tag", "{lime}[ VIP ]" }, { "Max_Hp", "130" }, { "Extra_HP_Spawn", "10" }, { "Extra_HP_Spawn_Round", "2" }, 
	{ "Extra_Money_Spawn", "100" }, { "Extra_Money_Spawn_Round", "2" }, { "Extra_Moeny_Spawn_Info", "1" }, { "Extra_Money_Kill", "100" }, { "Extra_Money_Kill_Round", "1" }, { "Extra_Money_Kill_Info", "1" }, 
	{ "Extra_Money_Kill_Hs", "100" }, { "Extra_Money_Kill_Hs_Round", "1" }, { "Extra_Money_Kill_Hs_Info", "1" }, { "Extra_Money_Assist", "100" }, { "Extra_Money_Assist_Round", "1" }, { "Extra_Money_Assist_Info", "1" }, 
	{ "Extra_Money_Plant", "100" }, { "Extra_Money_Plant_Round", "1" }, { "Extra_Money_Plant_Info", "1" }, { "Extra_Money_Defuse", "100" }, { "Extra_Money_Defuse_Round", "1" }, { "Extra_Money_Defuse_Info", "1" }, 
	{ "Extra_Money_Hostage", "100" }, { "Extra_Money_Hostage_Round", "1" }, { "Extra_Money_Hostage_Info", "1" }, { "Extra_Money_Mvp", "100" }, { "Extra_Money_Mvp_Round", "1" }, { "Extra_Money_Mvp_Info", "1" }, 
	{ "Extra_Money_Knife", "100" }, { "Extra_Money_Knife_Round", "1" }, { "Extra_Money_Knife_Info", "1" }, { "Extra_Money_Grenade", "100" }, { "Extra_Money_Grenade_Round", "1" }, { "Extra_Money_Grenade_Info", "1" }, 
	{ "Extra_Money_Zeus", "100" }, { "Extra_Money_Zeus_Round", "1" }, { "Extra_Money_Zeus_Info", "1" }, { "Extra_Money_Noscope", "100" }, { "Extra_Money_Noscope_Round", "1" }, { "Extra_Money_Noscope_Info", "1" }, 
	{ "Extra_HP_Kill", "1" }, { "Extra_HP_Kill_Round", "1" }, { "Extra_HP_Kill_Info", "1" }, { "Extra_HP_Kill_Hs", "2" }, { "Extra_HP_Kill_Hs_Round", "1" }, { "Extra_HP_Kill_Hs_Info", "1" }, 
	{ "Extra_HP_Assist", "1" }, { "Extra_HP_Assist_Round", "1" }, { "Extra_HP_Assist_Info", "1" }, { "Extra_HP_Knife", "3" }, { "Extra_HP_Knife_Round", "1" }, { "Extra_HP_Knife_Info", "1" }, 
	{ "Extra_HP_Grenade", "2" }, { "Extra_HP_Grenade_Round", "1" }, { "Extra_HP_Grenade_Info", "1" }, { "Extra_HP_Zeus", "3" }, { "Extra_HP_Zeus_Round", "1" }, { "Extra_HP_Zeus_Info", "1" }, 
	{ "Extra_HP_Noscope", "1" }, { "Extra_HP_Noscope_Round", "1" }, { "Extra_HP_Noscope_Info", "1" }, { "Enable_Kevlar", "1" }, { "Kevlar_Amount", "100" }, { "Kevlar_Round", "2" }, 
	{ "Enable_Helmet", "1" }, { "Helmet_Round", "2" }, { "Hegrenade_Amount", "1" }, { "Hegrenade_Round", "2" }, { "Flash_Amount", "1" }, { "Flash_Round", "1" }, 
	{ "Smoke_Amount", "1" }, { "Smoke_Round", "1" }, { "Molotov_Amount", "1" }, { "Molotov_Round", "1" }, { "Healthshot_Amount", "1" }, { "Healthshot_Round", "1" }, 
	{ "Tagrenade_Amount", "0" }, { "Tagrenade_Round", "1" }, { "Snowballs_Amount", "0" }, { "Snowballs_Round", "1" }, { "Enable_Shield", "0" }, { "Shield_Round", "2" }, 
	{ "Decoy_Amount", "0" }, { "Decoy_Round", "1" }, { "Gravity_Amount", "1.0" }, { "Gravity_Round", "1" }, { "Speed_Amount", "1.0" }, { "Speed_Round", "1" }, 
	{ "Enable_Defuser", "1" }, { "Defuser_Round", "1" }, { "Heals_Amount", "2" }, { "Heals_Round", "1" }, { "Heals_Value", "10" }, { "Enable_Primary_Weapon_Menu", "1" }, 
	{ "Primary_Weapon_Menu_Round", "4" }, { "Enable_Secondary_Weapon_Menu", "1" }, { "Secondary_Weapon_Menu_Round", "2" }, { "Enable_Grenades_Menu", "1" }, { "Grenades_Menu_Round", "2" }, { "Visibility_Amount", "255" }, { "Visibility_Round", "1" }, { "Damage_Give_Percent", "100" }, 
	{ "Damage_Give_Round", "1" }, { "Damage_Take_Percent", "100" }, { "Damage_Take_Round", "1" }, { "Damage_Fall_Percent", "100" }, { "Damage_Fall_Round", "1" }, { "Welcome_Hud", "Na serwer wbija » {GROUP} {NAME} «" }, 
	{ "Goodbye_Hud", "Z serwera wychodzi » {GROUP} {NAME} «" }, { "Hud_Position_X", "-1.0" }, { "Hud_Position_Y", "-0.9" }, { "Hud_Color_Red", "0" }, { "Hud_Color_Green", "255" }, { "Hud_Color_Blue", "255" }, 
	{ "Welcome_Chat", "{orange}*******************\\n {default}• {orange}{GROUP} {NAME}{default} wbija na serwer.\\n{orange}*******************" }, { "Goodbye_Chat", "{orange}*******************\\n {default}• {orange}{GROUP} {NAME}{default} wychodzi z serwera.\\n{orange}*******************" }, 
	{ "Respawn_Percent", "0" }, { "Respawn_Round", "1" }, { "Unlimited_Primary_Ammo", "0" }, { "Unlimited_Primary_Ammo_Round", "1" }, { "Unlimited_Secondary_Ammo", "0" }, { "Unlimited_Secondary_Ammo_Round", "1" }
};

/* [ Booleans ] */
bool g_bEnabled = true;
bool g_bShopChatModule = false;

/* [ Menus ] */
Menu g_mMenu;

/* [ Plugin Author And Informations ] */
public Plugin myinfo = {
	name = "[CS:GO] Pawel - [ pVip ]", 
	author = "Pawel", 
	description = "Rozbudowany system VIP na serwery CS:GO by Paweł.", 
	version = "1.0.8", 
	url = "https://steamcommunity.com/id/pawelsteam"
};

/* [ Plugin Startup ] */
public void OnPluginStart() {
	/* [ Security ] */
	if (GetEngineVersion() != Engine_CSGO)
		SetFailState("[ ✘ pVip » Core ✘ ] Wykryto nieprawidłowy silnik gry. System VIP przystosowany jest pod CS:GO.");
	
	/* [ Commands ] */
	RegConsoleCmd("sm_heal", Heal_Command);
	RegConsoleCmd("sm_dj", DoubleJump_Command);
	RegConsoleCmd("sm_pvip_debug", Debug_Command);
	
	/* [ Events ] */
	HookEvent("weapon_reload", Event_WeaponReload);
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("bomb_planted", Event_BombPlanted);
	HookEvent("bomb_defused", Event_BombDefused);
	HookEvent("hostage_rescued", Event_HostageRescued);
	HookEvent("round_start", Event_RoundStart);
	HookEvent("cs_match_end_restart", Event_MatchRestart);
	HookEvent("cs_win_panel_match", Event_MatchRestart);
	HookEvent("announce_phase_end", Event_MatchRestart);
	HookEvent("cs_intermission", Event_MatchRestart);
	HookEvent("player_connect_full", Event_PlayerConnectFull);
	
	/* [ Forwards ] */
	g_gfSpawn = new GlobalForward("pVip_AfterPlayerSetup", ET_Ignore, Param_Cell);
	g_gfGroupReceived = new GlobalForward("pVip_GroupReceived", ET_Ignore, Param_Cell, Param_Cell);
	g_gfRespawned = new GlobalForward("pVip_Respawned", ET_Ignore, Param_Cell);
	g_gfConfigLoaded = new GlobalForward("pVip_ConfigLoaded", ET_Ignore);
	
	/* [ Hud ] */
	g_hHud = CreateHudSynchronizer();
	
	/* [ Array Lists ] */
	CreateArrays();
	
	/* [ Late Load ] */
	LoopValidClients(i)
	OnClientPostAdminCheck(i);
}

/* [ Standard Actions ] */
public void OnConfigsExecuted() {
	LoadConfig();
}

public void OnAllPluginsLoaded() {
	g_eCore.bChatSystem[0] = LibraryExists("chat-processor");
	if (g_eCore.bChatSystem[0]) {
		PrintToServer("✔ pVip Core | Wykryto Chat-Processor by Drixevel.");
		return;
	}
	g_eCore.bChatSystem[1] = LibraryExists("scp");
	if (g_eCore.bChatSystem[1]) {
		PrintToServer("✔ pVip Core | Wykryto Simple Chat Processor by Mini.");
		return;
	}
	g_bShopChatModule = LibraryExists("pShop-Chat");
	if (g_bShopChatModule) {
		PrintToServer("✔ pShop-Chat | Wykryto sklep by Pawel.");
		return;
	}
}

public void OnMapStart() {
	g_bEnabled = true;
	g_eCore.iGroups = 0;
	g_iPhase = 0;
}

public void OnClientPostAdminCheck(int iClient) {
	if (IsValidClient(iClient)) {
		g_eInfo[iClient].Reset();
		LoadClientGroup(iClient, true);
		SDKHook(iClient, SDKHook_OnTakeDamage, Hook_OnTakeDamage);
	}
}

public void OnClientDisconnect(int iClient) {
	if (IsValidClient(iClient) && g_eInfo[iClient].iGroupId) {
		ShowDisconnectInfo(iClient);
		g_eInfo[iClient].Reset();
		SDKUnhook(iClient, SDKHook_OnTakeDamage, Hook_OnTakeDamage);
	}
}

public void OnMapEnd() {
	ClearArrays();
}

/* [ Commands ] */
public Action Debug_Command(int iClient, int iArgs) {
	if (g_eInfo[iClient].iGroupId)
		CPrintToChat(iClient, "Twoja grupa: %s", g_eGroup[g_eInfo[iClient].iGroupId].sName);
	else CPrintToChat(iClient, "Nie masz grupy");
	char sName[32], sClass[32], sFlags[32];
	for (int i = 0; i < g_arWeapons[PRIMARY][0].Length; i++) {
		g_arWeapons[PRIMARY][1].GetString(i, sName, sizeof(sName));
		g_arWeapons[PRIMARY][2].GetString(i, sClass, sizeof(sClass));
		g_arWeapons[PRIMARY][4].GetString(i, sFlags, sizeof(sFlags));
		PrintToConsole(iClient, "%s - %s - %s", sName, sClass, sFlags);
	}
	for (int i = 0; i < g_arWeapons[SECONDARY][0].Length; i++) {
		g_arWeapons[SECONDARY][1].GetString(i, sName, sizeof(sName));
		g_arWeapons[SECONDARY][2].GetString(i, sClass, sizeof(sClass));
		g_arWeapons[SECONDARY][4].GetString(i, sFlags, sizeof(sFlags));
		PrintToConsole(iClient, "%s - %s - %s", sName, sClass, sFlags);
	}
}
public Action DoubleJump_Command(int iClient, int iArgs) {
	if (HasGroup(iClient) && g_eGroup[g_eInfo[iClient].iGroupId].iStats[GROUP_DOUBLE_JUMP] && g_bEnabled) {
		g_eInfo[iClient].bDoubleJump = g_eInfo[iClient].bDoubleJump ? false:true;
		CPrintToChat(iClient, "%s Double Jump został %s{default}.", g_eCore.sChatTag, g_eInfo[iClient].bDoubleJump ? "{lime}włączony":"{lightred}wyłączony");
		return Plugin_Handled;
	}
	return Plugin_Handled;
}
public Action CS_OnBuyCommand(int iClient, const char[] sWeapon) {
	if (g_eCore.iDisableBuyHelemet && g_eCore.iRound == 1 && StrEqual(sWeapon, "assaultsuit") && g_bEnabled) {
		CPrintToChat(iClient, "%s Nie możesz tego kupić na pistoletówce.", g_eCore.sChatTag);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action Heal_Command(int iClient, int iArgs) {
	if (!IsValidClient(iClient, true) || !HasGroup(iClient) || !g_bEnabled || !g_eCore.iHealType || !g_eGroup[g_eInfo[iClient].iGroupId].iStats[GROUP_HEAL_NUM])return Plugin_Handled;
	if (g_eInfo[iClient].iStats[CLIENT_HEALS]) {
		g_iValue = g_eGroup[g_eInfo[iClient].iGroupId].iStats[GROUP_HEAL_VALUE];
		if (GetClientHealth(iClient) < g_eGroup[g_eInfo[iClient].iGroupId].iStats[GROUP_MAX_HP]) {
			if (GetClientHealth(iClient) + g_iValue > g_eGroup[g_eInfo[iClient].iGroupId].iStats[GROUP_MAX_HP])
				SetClientHealth(iClient, g_eGroup[g_eInfo[iClient].iGroupId].iStats[GROUP_MAX_HP]);
			else
				SetClientHealth(iClient, GetClientHealth(iClient) + g_eGroup[g_eInfo[iClient].iGroupId].iStats[GROUP_HEAL_VALUE]);
			g_eInfo[iClient].iStats[CLIENT_HEALS]--;
			CPrintToChat(iClient, "%s Zostałeś {lime}uleczony{default}. Pozostałe apteczki: {lime}%d{default}.", g_eCore.sChatTag, g_eInfo[iClient].iStats[CLIENT_HEALS]);
		}
		else CPrintToChat(iClient, "%s Posiadasz max hp.", g_eCore.sChatTag);
	}
	else CPrintToChat(iClient, "%s Nie posiadasz uleczeń.", g_eCore.sChatTag);
	return Plugin_Handled;
}

/* [ Events ] */
public Action Event_WeaponReload(Event eEvent, const char[] sName, bool bDontBroadcast) {
	int iClient = GetClientOfUserId(eEvent.GetInt("userid"));
	if (!IsValidClient(iClient, true) || !HasGroup(iClient) || !g_bEnabled)return Plugin_Continue;
	if (g_eInfo[iClient].iStats[CLIENT_HEALS] && !g_eCore.iHealType && g_eGroup[g_eInfo[iClient].iGroupId].iStats[GROUP_HEAL_NUM]) {
		g_iValue = g_eGroup[g_eInfo[iClient].iGroupId].iStats[GROUP_HEAL_VALUE];
		if (GetClientHealth(iClient) < g_eGroup[g_eInfo[iClient].iGroupId].iStats[GROUP_MAX_HP]) {
			if (GetClientHealth(iClient) + g_iValue > g_eGroup[g_eInfo[iClient].iGroupId].iStats[GROUP_MAX_HP])
				SetClientHealth(iClient, g_eGroup[g_eInfo[iClient].iGroupId].iStats[GROUP_MAX_HP]);
			else
				SetClientHealth(iClient, GetClientHealth(iClient) + g_eGroup[g_eInfo[iClient].iGroupId].iStats[GROUP_HEAL_VALUE]);
			g_eInfo[iClient].iStats[CLIENT_HEALS]--;
			CPrintToChat(iClient, "%s Zostałeś {lime}uleczony{default}. Pozostałe apteczki: {lime}%d{default}.", g_eCore.sChatTag, g_eInfo[iClient].iStats[CLIENT_HEALS]);
		}
		else CPrintToChat(iClient, "%s Posiadasz max hp.", g_eCore.sChatTag);
	}
	if (g_eInfo[iClient].bAmmo[1]) {
		int iWeapon = GetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon");
		char sClass[32];
		GetEdictClassname(iWeapon, sClass, sizeof(sClass));
		if (IsValidWeapon(iWeapon) && !IsWeaponGrenade(sClass) && !IsWeaponKnife(sClass))
			SetEntProp(iWeapon, Prop_Send, "m_iPrimaryReserveAmmoCount", 420);
	}
	return Plugin_Continue;
}

public Action Event_PlayerSpawn(Event eEvent, const char[] sName, bool bDontBroadcast) {
	if (!g_bEnabled)return Plugin_Continue;
	int iClient = GetClientOfUserId(eEvent.GetInt("userid"));
	if (IsValidClient(iClient)) {
		if (g_eCore.iRound == 1) {
			g_eInfo[iClient].sPrimary = "";
			g_eInfo[iClient].sSecondary = "";
		}
		g_eInfo[iClient].iStats[CLIENT_DAMAGE_GIVE] = 100;
		g_eInfo[iClient].iStats[CLIENT_DAMAGE_TAKE] = 100;
		g_eInfo[iClient].iStats[CLIENT_DAMAGE_FALL] = 100;
		LoadClientGroup(iClient);
		return Plugin_Continue;
	}
	return Plugin_Continue;
}

public Action Event_PlayerConnectFull(Event eEvent, const char[] sName, bool bDontBroadcast) {
	int iClient = GetClientOfUserId(eEvent.GetInt("userid"));
	if (IsValidClient(iClient))
		LoadClientGroup(iClient);
}

public Action Event_PlayerDeath(Event eEvent, const char[] sName, bool bDontBroadcast) {
	if (!g_bEnabled)return Plugin_Continue;
	int iAttacker = GetClientOfUserId(eEvent.GetInt("attacker"));
	int iClient = GetClientOfUserId(eEvent.GetInt("userid"));
	if (!IsValidClient(iClient) || !IsValidClient(iAttacker))return Plugin_Continue;
	if (!g_eCore.iDeathmatchMode) {
		if (GetClientTeam(iAttacker) == GetClientTeam(iClient))
			return Plugin_Continue;
	}
	
	int iAssister = GetClientOfUserId(eEvent.GetInt("assister"));
	int iGroupId;
	if (IsValidClient(iAssister) && HasGroup(iAssister)) {
		iGroupId = g_eInfo[iAssister].iGroupId;
		if (!IsClientInTeam(iAssister, g_eGroup[iGroupId].iStats[GROUP_TEAM]))
			return Plugin_Continue;
		g_iValue = g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_ASSIST];
		if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_ASSIST_ROUND]) {
			SetClientCash(iAssister, GetClientCash(iAssister) + g_iValue);
			if (g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_ASSIST_INFO])
				CPrintToChat(iAssister, "%s Jako {purple}%s{default} dostałeś {lime}+%d${default} za asystowanie przy zabójstwie", g_eCore.sChatTag, g_eGroup[iGroupId].sName, g_iValue);
		}
		g_iValue = g_eGroup[iGroupId].iStats[GROUP_EXTRA_HP_ASSIST];
		if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_EXTRA_HP_ASSIST_ROUND]) {
			SetClientHealth(iAssister, GetClientHealth(iAssister) + g_iValue);
			if (g_eGroup[iGroupId].iStats[GROUP_EXTRA_HP_ASSIST_INFO])
				CPrintToChat(iAssister, "%s Jako {purple}%s{default} dostałeś {lime}+%d HP{default} za asystowanie przy zabójstwie", g_eCore.sChatTag, g_eGroup[iGroupId].sName, g_iValue);
		}
	}
	if (HasGroup(iClient)) {
		iGroupId = g_eInfo[iClient].iGroupId;
		if (IsClientInTeam(iClient, g_eGroup[iGroupId].iStats[GROUP_TEAM])) {
			if (g_eGroup[iGroupId].iStats[GROUP_RESPAWN_CHANCE] >= GetRandomInt(1, 100) && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_RESPAWN_CHANCE_ROUND])
				CreateTimer(0.5, Timer_Respawn, iClient, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	if (HasGroup(iAttacker)) {
		iGroupId = g_eInfo[iAttacker].iGroupId;
		if (IsClientInTeam(iAttacker, g_eGroup[iGroupId].iStats[GROUP_TEAM])) {
			bool bHeadshot = eEvent.GetBool("headshot");
			bool bNoscope = eEvent.GetBool("noscope");
			char sWeapon[32];
			eEvent.GetString("weapon", sWeapon, sizeof(sWeapon));
			if (bHeadshot) {
				g_iValue = g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_KILL_HS];
				if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_KILL_HS_ROUND]) {
					SetClientCash(iAttacker, GetClientCash(iAttacker) + g_iValue);
					if (g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_KILL_HS_INFO])
						CPrintToChat(iAttacker, "%s Jako {purple}%s{default} dostałeś {lime}+%d${default} za zabójstwo poprzez {lime}HeadShota{default}.", g_eCore.sChatTag, g_eGroup[iGroupId].sName, g_iValue);
				}
				g_iValue = g_eGroup[iGroupId].iStats[GROUP_EXTRA_HP_KILL_HS];
				if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_EXTRA_HP_KILL_HS_ROUND]) {
					SetClientHealth(iAttacker, GetClientHealth(iAttacker) + g_iValue);
					if (g_eGroup[iGroupId].iStats[GROUP_EXTRA_HP_KILL_HS_INFO])
						CPrintToChat(iAttacker, "%s Jako {purple}%s{default} dostałeś {lime}+%d HP{default} za zabójstwo poprzez {lime}HeadShota{default}.", g_eCore.sChatTag, g_eGroup[iGroupId].sName, g_iValue);
				}
			}
			else {
				g_iValue = g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_KILL];
				if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_KILL_ROUND]) {
					SetClientCash(iAttacker, GetClientCash(iAttacker) + g_iValue);
					if (g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_KILL_INFO])
						CPrintToChat(iAttacker, "%s Jako {purple}%s{default} dostałeś {lime}+%d${default} za zabójstwo .", g_eCore.sChatTag, g_eGroup[iGroupId].sName, g_iValue);
				}
				g_iValue = g_eGroup[iGroupId].iStats[GROUP_EXTRA_HP_KILL];
				if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_EXTRA_HP_KILL_ROUND]) {
					SetClientHealth(iAttacker, GetClientHealth(iAttacker) + g_iValue);
					if (g_eGroup[iGroupId].iStats[GROUP_EXTRA_HP_KILL_INFO])
						CPrintToChat(iAttacker, "%s Jako {purple}%s{default} dostałeś {lime}+%d HP{default} za zabójstwo.", g_eCore.sChatTag, g_eGroup[iGroupId].sName, g_iValue);
				}
			}
			
			if (bNoscope) {
				g_iValue = g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_NOSCOPE];
				if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_NOSCOPE_ROUND]) {
					SetClientCash(iAttacker, GetClientCash(iAttacker) + g_iValue);
					if (g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_NOSCOPE_INFO])
						CPrintToChat(iAttacker, "%s Jako {purple}%s{default} dostałeś {lime}+%d${default} za zabójstwo poprzez {lime}Noscope{default}.", g_eCore.sChatTag, g_eGroup[iGroupId].sName, g_iValue);
				}
				g_iValue = g_eGroup[iGroupId].iStats[GROUP_EXTRA_HP_NOSCOPE];
				if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_EXTRA_HP_NOSCOPE_ROUND]) {
					SetClientHealth(iAttacker, GetClientHealth(iAttacker) + g_iValue);
					if (g_eGroup[iGroupId].iStats[GROUP_EXTRA_HP_NOSCOPE_INFO])
						CPrintToChat(iAttacker, "%s Jako {purple}%s{default} dostałeś {lime}+%d HP{default} za zabójstwo poprzez {lime}Noscope{default}.", g_eCore.sChatTag, g_eGroup[iGroupId].sName, g_iValue);
				}
			}
			if (IsWeaponKnife(sWeapon)) {
				g_iValue = g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_KNIFE];
				if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_KNIFE_ROUND]) {
					SetClientCash(iAttacker, GetClientCash(iAttacker) + g_iValue);
					if (g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_KNIFE_INFO])
						CPrintToChat(iAttacker, "%s Jako {purple}%s{default} dostałeś {lime}+%d${default} za zabójstwo z {lime}noża{default}.", g_eCore.sChatTag, g_eGroup[iGroupId].sName, g_iValue);
				}
				g_iValue = g_eGroup[iGroupId].iStats[GROUP_EXTRA_HP_KNIFE];
				if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_EXTRA_HP_KNIFE_ROUND]) {
					SetClientHealth(iAttacker, GetClientHealth(iAttacker) + g_iValue);
					if (g_eGroup[iGroupId].iStats[GROUP_EXTRA_HP_KNIFE_INFO])
						CPrintToChat(iAttacker, "%s Jako {purple}%s{default} dostałeś {lime}+%d HP{default} za zabójstwo z {lime}noża{default}.", g_eCore.sChatTag, g_eGroup[iGroupId].sName, g_iValue);
				}
			}
			else if (IsWeaponGrenade(sWeapon)) {
				g_iValue = g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_GRENADE];
				if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_GRENADE_ROUND]) {
					SetClientCash(iAttacker, GetClientCash(iAttacker) + g_iValue);
					if (g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_GRENADE_INFO])
						CPrintToChat(iAttacker, "%s Jako {purple}%s{default} dostałeś {lime}+%d${default} za zabójstwo z {lime}granatu{default}.", g_eCore.sChatTag, g_eGroup[iGroupId].sName, g_iValue);
				}
				g_iValue = g_eGroup[iGroupId].iStats[GROUP_EXTRA_HP_GRENADE];
				if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_EXTRA_HP_GRENADE_ROUND]) {
					SetClientHealth(iAttacker, GetClientHealth(iAttacker) + g_iValue);
					if (g_eGroup[iGroupId].iStats[GROUP_EXTRA_HP_GRENADE_INFO])
						CPrintToChat(iAttacker, "%s Jako {purple}%s{default} dostałeś {lime}+%d HP{default} za zabójstwo z {lime}granatu{default}.", g_eCore.sChatTag, g_eGroup[iGroupId].sName, g_iValue);
				}
			}
			else if (StrContains(sWeapon, "taser") != -1) {
				g_iValue = g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_ZEUS];
				if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_ZEUS_ROUND]) {
					SetClientCash(iAttacker, GetClientCash(iAttacker) + g_iValue);
					if (g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_ZEUS_INFO])
						CPrintToChat(iAttacker, "%s Jako {purple}%s{default} dostałeś {lime}+%d${default} za zabójstwo z {lime}zeusa{default}.", g_eCore.sChatTag, g_eGroup[iGroupId].sName, g_iValue);
				}
				g_iValue = g_eGroup[iGroupId].iStats[GROUP_EXTRA_HP_ZEUS];
				if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_EXTRA_HP_ZEUS_ROUND]) {
					SetClientHealth(iAttacker, GetClientHealth(iAttacker) + g_iValue);
					if (g_eGroup[iGroupId].iStats[GROUP_EXTRA_HP_ZEUS_INFO])
						CPrintToChat(iAttacker, "%s Jako {purple}%s{default} dostałeś {lime}+%d HP{default} za zabójstwo z {lime}zeusa{default}.", g_eCore.sChatTag, g_eGroup[iGroupId].sName, g_iValue);
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action Event_BombPlanted(Event eEvent, const char[] sName, bool bDontBroadcast) {
	if (!g_bEnabled)return Plugin_Continue;
	int iClient = GetClientOfUserId(eEvent.GetInt("userid"));
	if (!IsValidClient(iClient))return Plugin_Continue;
	int iGroupId = g_eInfo[iClient].iGroupId;
	if (!IsClientInTeam(iClient, g_eGroup[iGroupId].iStats[GROUP_TEAM]))
		return Plugin_Continue;
	g_iValue = g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_PLANT];
	if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_PLANT_ROUND]) {
		SetClientCash(iClient, GetClientCash(iClient) + g_iValue);
		if (g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_PLANT_INFO])
			CPrintToChat(iClient, "%s Jako {purple}%s{default} dostałeś {lime}+%d${default} za podłożenie bomby.", g_eCore.sChatTag, g_eGroup[iGroupId].sName, g_iValue);
	}
	return Plugin_Continue;
}

public Action Event_BombDefused(Event eEvent, const char[] sName, bool bDontBroadcast) {
	if (!g_bEnabled)return Plugin_Continue;
	int iClient = GetClientOfUserId(eEvent.GetInt("userid"));
	if (!IsValidClient(iClient))return Plugin_Continue;
	int iGroupId = g_eInfo[iClient].iGroupId;
	if (!IsClientInTeam(iClient, g_eGroup[iGroupId].iStats[GROUP_TEAM]))
		return Plugin_Continue;
	g_iValue = g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_DEFUSE];
	if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_DEFUSE_ROUND]) {
		SetClientCash(iClient, GetClientCash(iClient) + g_iValue);
		if (g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_DEFUSE_INFO])
			CPrintToChat(iClient, "%s Jako {purple}%s{default} dostałeś {lime}+%d${default} za rozbrojenie bomby.", g_eCore.sChatTag, g_eGroup[iGroupId].sName, g_iValue);
	}
	return Plugin_Continue;
}

public Action Event_HostageRescued(Event eEvent, const char[] sName, bool bDontBroadcast) {
	if (!g_bEnabled)return Plugin_Continue;
	int iClient = GetClientOfUserId(eEvent.GetInt("userid"));
	if (!IsValidClient(iClient))return Plugin_Continue;
	int iGroupId = g_eInfo[iClient].iGroupId;
	if (!IsClientInTeam(iClient, g_eGroup[iGroupId].iStats[GROUP_TEAM]))
		return Plugin_Continue;
	g_iValue = g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_HOSTAGE];
	if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_HOSTAGE_ROUND]) {
		SetClientCash(iClient, GetClientCash(iClient) + g_iValue);
		if (g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_HOSTAGE_INFO])
			CPrintToChat(iClient, "%s Jako {purple}%s{default} dostałeś {lime}+%d${default} za uratowanie zakładnika.", g_eCore.sChatTag, g_eGroup[iGroupId].sName, g_iValue);
	}
	return Plugin_Continue;
}

public Action Event_RoundMvp(Event eEvent, const char[] sName, bool bDontBroadcast) {
	if (!g_bEnabled)return Plugin_Continue;
	int iClient = GetClientOfUserId(eEvent.GetInt("userid"));
	if (!IsValidClient(iClient))return Plugin_Continue;
	int iGroupId = g_eInfo[iClient].iGroupId;
	if (!IsClientInTeam(iClient, g_eGroup[iGroupId].iStats[GROUP_TEAM]))
		return Plugin_Continue;
	g_iValue = g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_MVP];
	if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_MVP_ROUND]) {
		SetClientCash(iClient, GetClientCash(iClient) + g_iValue);
		if (g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_MVP_INFO])
			CPrintToChat(iClient, "%s Jako {purple}%s{default} dostałeś {lime}+%d${default} za bycie MVP.", g_eCore.sChatTag, g_eGroup[iGroupId].sName, g_iValue);
	}
	return Plugin_Continue;
}

public Action Event_RoundStart(Event eEvent, const char[] sName, bool bDontBroadcast) {
	g_eCore.iRound = GetRoundNumber();
}

public Action Event_MatchRestart(Event eEvent, const char[] sName, bool bDontBroadcast) {
	if (StrEqual(sName, "announce_phase_end")) {
		g_iPhase++;
		if (g_iPhase >= 2) {
			return Plugin_Continue;
		}
	}
	g_eCore.iRound = 0;
	
	return Plugin_Continue;
}

/* [ Hooks ] */
public Action Hook_OnTakeDamage(int iClient, int &iAttacker, int &iInflictor, float &fDamage, int &iDamageType) {
	if (!g_bEnabled)return Plugin_Continue;
	if (HasGroup(iAttacker) && IsValidClient(iAttacker)) {
		fDamage = fDamage * (g_eInfo[iAttacker].iStats[CLIENT_DAMAGE_GIVE] * 0.01);
		return Plugin_Changed;
	}
	if (HasGroup(iClient) && IsValidClient(iClient)) {
		if (iDamageType & DMG_FALL) {
			fDamage = fDamage * (g_eInfo[iClient].iStats[CLIENT_DAMAGE_FALL] * 0.01);
			return Plugin_Changed;
		}
		fDamage = fDamage * (g_eInfo[iClient].iStats[CLIENT_DAMAGE_TAKE] * 0.01);
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

/* [ Double Jump and Heal ] */
public Action OnPlayerRunCmd(int iClient, int &iButtons) {
	if (!IsValidClient(iClient, true) || !HasGroup(iClient) || !g_bEnabled)return Plugin_Continue;
	if (g_eGroup[g_eInfo[iClient].iGroupId].iStats[GROUP_DOUBLE_JUMP] && g_eInfo[iClient].bDoubleJump) {
		static int iLastButtons[MAXPLAYERS + 1], iLastFlags[MAXPLAYERS + 1], iJumps[MAXPLAYERS + 1], iFlags, iButtonsF;
		iButtonsF = GetClientButtons(iClient);
		iFlags = GetEntityFlags(iClient);
		if (iLastFlags[iClient] & FL_ONGROUND && !(iFlags & FL_ONGROUND) && !(iLastButtons[iClient] & IN_JUMP) && iButtonsF & IN_JUMP)iJumps[iClient]++;
		else if (iFlags & FL_ONGROUND)iJumps[iClient] = 0;
		else if (!(iLastButtons[iClient] & IN_JUMP) && iButtonsF & IN_JUMP && iJumps[iClient] == 1) {
			iJumps[iClient]++;
			float fVel[3];
			GetEntPropVector(iClient, Prop_Data, "m_vecVelocity", fVel);
			fVel[2] = 250.0;
			TeleportEntity(iClient, NULL_VECTOR, NULL_VECTOR, fVel);
		}
		
		iLastFlags[iClient] = iFlags;
		iLastButtons[iClient] = iButtonsF;
	}
	if (g_eInfo[iClient].bAmmo[0]) {
		if (iButtons & IN_ATTACK) {
			int iWeapon = GetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon");
			char sClass[32];
			GetEdictClassname(iWeapon, sClass, sizeof(sClass));
			if (IsValidWeapon(iWeapon) && !IsWeaponGrenade(sClass) && !IsWeaponKnife(sClass))
				SetEntData(iWeapon, FindSendPropInfo("CBaseCombatWeapon", "m_iClip1"), 69);
		}
	}
	return Plugin_Continue;
}

/* [ Timers ] */
public Action Timer_SetSpawn(Handle hTimer, int iClient) {
	if (!g_bEnabled)return Plugin_Stop;
	PreparePlayerSetup(iClient);
	return Plugin_Stop;
}

public Action Timer_Respawn(Handle hTimer, int iClient) {
	if (!g_bEnabled)return;
	if (IsValidClient(iClient, true)) {
		CS_RespawnPlayer(iClient);
		CPrintToChat(iClient, "%s Jako {purple}%s{default} udało ci się odrodzić.", g_eCore.sChatTag, g_eGroup[g_eInfo[iClient].iGroupId].sName);
		Call_StartForward(g_gfRespawned);
		Call_PushCell(iClient);
		Call_Finish();
	}
}

/* [ Menus ] */
Menu DisplayWeaponsMenu(int iClient, int iType) {
	char sBuffer[256], sWeapon[32], sName[64], sFlags[16];
	Format(sBuffer, sizeof(sBuffer), "[ ★ %s » %s ★ ]\n ", g_eCore.sMenuTag, g_eGroup[g_eInfo[iClient].iGroupId].sName);
	switch (iType) {
		case PRIMARY: {
			Format(sBuffer, sizeof(sBuffer), "%s\n➪ Wybierz karabin.", sBuffer);
			Format(sBuffer, sizeof(sBuffer), "%s\n---------------------------------------------", sBuffer);
			g_mMenu = new Menu(Primary_Handler);
			g_mMenu.SetTitle(sBuffer);
			for (int i = 0; i < g_arWeapons[PRIMARY][0].Length; i++) {
				g_arWeapons[PRIMARY][4].GetString(i, sFlags, sizeof(sFlags));
				if ((CheckFlags(iClient, sFlags) || (g_eInfo[iClient].iGroupId > 0 && CheckGroupFlags(g_eGroup[g_eInfo[iClient].iGroupId].sFlags, sFlags)) && IsClientInTeam(iClient, g_arWeapons[PRIMARY][3].Get(i)))) {
					g_arWeapons[PRIMARY][1].GetString(i, sName, sizeof(sName));
					g_arWeapons[PRIMARY][2].GetString(i, sWeapon, sizeof(sWeapon));
					Format(sBuffer, sizeof(sBuffer), "» %s", sName);
					g_mMenu.AddItem(sWeapon, sBuffer);
				}
			}
			if (!g_mMenu.ItemCount)
				g_mMenu.AddItem("", "» Brak dostępnych broni dla twojej grupy", ITEMDRAW_DISABLED);
			return g_mMenu;
		}
		case SECONDARY: {
			Format(sBuffer, sizeof(sBuffer), "%s\n➪ Wybierz pistolet.", sBuffer);
			Format(sBuffer, sizeof(sBuffer), "%s\n---------------------------------------------", sBuffer);
			g_mMenu = new Menu(Secondary_Handler);
			g_mMenu.SetTitle(sBuffer);
			for (int i = 0; i < g_arWeapons[SECONDARY][0].Length; i++) {
				g_arWeapons[SECONDARY][4].GetString(i, sFlags, sizeof(sFlags));
				if ((CheckFlags(iClient, sFlags) || (g_eInfo[iClient].iGroupId > 0 && CheckGroupFlags(g_eGroup[g_eInfo[iClient].iGroupId].sFlags, sFlags)) && IsClientInTeam(iClient, g_arWeapons[SECONDARY][3].Get(i)))) {
					g_arWeapons[SECONDARY][1].GetString(i, sName, sizeof(sName));
					g_arWeapons[SECONDARY][2].GetString(i, sWeapon, sizeof(sWeapon));
					Format(sBuffer, sizeof(sBuffer), "» %s", sName);
					g_mMenu.AddItem(sWeapon, sBuffer);
				}
			}
			if (!g_mMenu.ItemCount)
				g_mMenu.AddItem("", "» Brak dostępnych broni dla twojej grupy", ITEMDRAW_DISABLED);
			return g_mMenu;
		}
		case MAIN: {
			Format(sBuffer, sizeof(sBuffer), "%s\n➪ Witaj, %N!", sBuffer, iClient);
			Format(sBuffer, sizeof(sBuffer), "%s\n---------------------------------------------", sBuffer);
			g_mMenu = new Menu(Main_Handler);
			g_mMenu.SetTitle(sBuffer);
			int iDraw = (!StrEqual(g_eInfo[iClient].sPrimary, "") && !StrEqual(g_eInfo[iClient].sSecondary, "")) ? ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED;
			g_mMenu.AddItem("", "» Nowy zestaw broni");
			g_mMenu.AddItem("", "» Poprzedni zestaw broni.\n ", iDraw);
			return g_mMenu;
		}
		case GRENADES: {
			Format(sBuffer, sizeof(sBuffer), "%s\n➪ Wybierz zestaw granatów.", sBuffer);
			Format(sBuffer, sizeof(sBuffer), "%s\n---------------------------------------------", sBuffer);
			g_mMenu = new Menu(Grenades_Handler);
			g_mMenu.SetTitle(sBuffer);
			for (int i = 0; i < g_eCore.iGrenadeSets; i++) {
				if (CheckFlags(iClient, g_eGrenades[i].sFlags) && IsClientInTeam(iClient, g_eGrenades[i].iTeam)) {
					Format(sBuffer, sizeof(sBuffer), "» %s", g_eGrenades[i].sName);
					Format(sWeapon, sizeof(sWeapon), "%d", i);
					g_mMenu.AddItem(sWeapon, sBuffer);
				}
			}
			if (!g_mMenu.ItemCount)
				g_mMenu.AddItem("", "» Brak dostępnych zestawów dla twojej grupy", ITEMDRAW_DISABLED);
			return g_mMenu;
		}
	}
	return g_mMenu;
}

public int Main_Handler(Menu mMenu, MenuAction maAction, int iClient, int iPosition) {
	switch (maAction) {
		case MenuAction_Select: {
			if (!iPosition)DisplayWeaponsMenu(iClient, PRIMARY).Display(iClient, MENU_TIME_FOREVER);
			else GiveLastWeapons(iClient);
		}
		case MenuAction_End:delete mMenu;
	}
}

public int Primary_Handler(Menu mMenu, MenuAction maAction, int iClient, int iPosition) {
	switch (maAction) {
		case MenuAction_Select: {
			char sItem[32];
			mMenu.GetItem(iPosition, sItem, sizeof(sItem));
			g_eInfo[iClient].sPrimary = sItem;
			StripClientWeapons(iClient, CS_SLOT_PRIMARY);
			GivePlayerItem(iClient, sItem);
			if (g_eGroup[g_eInfo[iClient].iGroupId].iStats[GROUP_SECONDARY_MENU] && g_eCore.iRound >= g_eGroup[g_eInfo[iClient].iGroupId].iStats[GROUP_SECONDARY_MENU_ROUND])
				DisplayWeaponsMenu(iClient, SECONDARY).Display(iClient, 15);
		}
		case MenuAction_End:delete mMenu;
	}
}

public int Secondary_Handler(Menu mMenu, MenuAction maAction, int iClient, int iPosition) {
	switch (maAction) {
		case MenuAction_Select: {
			char sItem[32];
			mMenu.GetItem(iPosition, sItem, sizeof(sItem));
			g_eInfo[iClient].sSecondary = sItem;
			StripClientWeapons(iClient, CS_SLOT_SECONDARY);
			GivePlayerItem(iClient, sItem);
			if (g_eGroup[g_eInfo[iClient].iGroupId].iStats[GROUP_GRENADES_MENU] && g_eCore.iRound >= g_eGroup[g_eInfo[iClient].iGroupId].iStats[GROUP_GRENADES_MENU_ROUND])
				DisplayWeaponsMenu(iClient, GRENADES).Display(iClient, 15);
		}
		case MenuAction_End:delete mMenu;
	}
}

public int Grenades_Handler(Menu mMenu, MenuAction maAction, int iClient, int iPosition) {
	switch (maAction) {
		case MenuAction_Select: {
			char sItem[32];
			mMenu.GetItem(iPosition, sItem, sizeof(sItem));
			int iGrenadeSet = StringToInt(sItem);
			g_eInfo[iClient].iGrenadeSet = iGrenadeSet;
			StripClientWeapons(iClient, CS_SLOT_GRENADE);
			GivePlayerGrenades(iClient, iGrenadeSet);
		}
		case MenuAction_End:delete mMenu;
	}
}

/* [ Helpers ] */
void PreparePlayerSetup(int iClient) {
	if (!IsValidClient(iClient) || !IsPlayerAlive(iClient) || !HasGroup(iClient) || !g_bEnabled)return;
	int iGroupId = g_eInfo[iClient].iGroupId;
	if (!IsClientInTeam(iClient, g_eGroup[iGroupId].iStats[GROUP_TEAM]))
		return;
	
	if (g_eGroup[iGroupId].iStats[GROUP_UNLIMITED_PRIMARY_AMMO] && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_UNLIMITED_PRIMARY_AMMO_ROUND])g_eInfo[iClient].bAmmo[0] = true;
	else g_eInfo[iClient].bAmmo[0] = false;
	
	if (g_eGroup[iGroupId].iStats[GROUP_UNLIMITED_SECONDARY_AMMO] && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_UNLIMITED_SECONDARY_AMMO_ROUND])g_eInfo[iClient].bAmmo[1] = true;
	else g_eInfo[iClient].bAmmo[1] = false;
	
	SetEntData(iClient, FindDataMapInfo(iClient, "m_iMaxHealth"), g_eGroup[iGroupId].iStats[GROUP_MAX_HP], 4, true);
	g_iValue = g_eGroup[iGroupId].iStats[GROUP_EXTRA_HP_SPAWN];
	if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_EXTRA_HP_SPAWN_ROUND])
		SetClientHealth(iClient, GetClientHealth(iClient) + g_eGroup[iGroupId].iStats[GROUP_EXTRA_HP_SPAWN]);
	
	g_iValue = g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_SPAWN];
	if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_SPAWN_ROUND]) {
		SetClientCash(iClient, GetClientCash(iClient) + g_iValue);
		if (g_eGroup[iGroupId].iStats[GROUP_EXTRA_MONEY_MVP_INFO])
			CPrintToChat(iClient, "%s Jako {purple}%s{default} dostałeś {lime}+%d${default} na start.", g_eCore.sChatTag, g_eGroup[iGroupId].sName, g_iValue);
	}
	g_iValue = g_eGroup[iGroupId].iStats[GROUP_KEVLAR];
	if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_KEVLAR_ROUND])
		SetClientKevlar(iClient, g_eGroup[iGroupId].iStats[GROUP_KEVLAR_AMOUNT]);
	
	g_iValue = g_eGroup[iGroupId].iStats[GROUP_HELMET];
	if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_HELMET_ROUND])
		SetEntProp(iClient, Prop_Send, "m_bHasHelmet", 1);
	
	static int iAmmo[2];
	int iMaxGrenades = FindConVar("ammo_grenade_limit_total").IntValue;
	g_eInfo[iClient].iStats[CLIENT_GRENADES] = CountClientGrenades(iClient);
	g_iValue = g_eGroup[iGroupId].iStats[GROUP_HE_NUM];
	if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_HE_ROUND] && g_eInfo[iClient].iStats[CLIENT_GRENADES] < iMaxGrenades) {
		iAmmo[0] = 0, iAmmo[1] = 0;
		GetClientWeaponAmmo(iClient, "weapon_hegrenade", iAmmo[0], iAmmo[1]);
		if (iAmmo[0] < g_iValue) {
			GiveClientWeaponAndAmmo(iClient, "weapon_hegrenade", g_iValue, g_iValue, g_iValue, g_iValue);
			g_eInfo[iClient].iStats[CLIENT_GRENADES] += g_iValue;
		}
	}
	g_iValue = g_eGroup[iGroupId].iStats[GROUP_FLASH_NUM];
	if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_FLASH_ROUND] && g_eInfo[iClient].iStats[CLIENT_GRENADES] < iMaxGrenades) {
		iAmmo[0] = 0, iAmmo[1] = 0;
		GetClientWeaponAmmo(iClient, "weapon_flashbang", iAmmo[0], iAmmo[1]);
		if (iAmmo[0] < g_iValue) {
			GiveClientWeaponAndAmmo(iClient, "weapon_flashbang", g_iValue, g_iValue, g_iValue, g_iValue);
			g_eInfo[iClient].iStats[CLIENT_GRENADES] += g_iValue;
		}
	}
	g_iValue = g_eGroup[iGroupId].iStats[GROUP_SMOKE_NUM];
	if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_SMOKE_ROUND] && g_eInfo[iClient].iStats[CLIENT_GRENADES] < iMaxGrenades) {
		iAmmo[0] = 0, iAmmo[1] = 0;
		GetClientWeaponAmmo(iClient, "weapon_smokegrenade", iAmmo[0], iAmmo[1]);
		if (iAmmo[0] < g_iValue) {
			GiveClientWeaponAndAmmo(iClient, "weapon_smokegrenade", g_iValue, g_iValue, g_iValue, g_iValue);
			g_eInfo[iClient].iStats[CLIENT_GRENADES] += g_iValue;
		}
	}
	g_iValue = g_eGroup[iGroupId].iStats[GROUP_MOLOTOV_NUM];
	if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_MOLOTOV_ROUND] && g_eInfo[iClient].iStats[CLIENT_GRENADES] < iMaxGrenades) {
		iAmmo[0] = 0, iAmmo[1] = 0;
		if (GetClientTeam(iClient) == CS_TEAM_CT) {
			GetClientWeaponAmmo(iClient, "weapon_incgrenade", iAmmo[0], iAmmo[1]);
			if (iAmmo[0] < g_iValue) {
				GiveClientWeaponAndAmmo(iClient, "weapon_incgrenade", g_iValue, g_iValue, g_iValue, g_iValue);
				g_eInfo[iClient].iStats[CLIENT_GRENADES] += g_iValue;
			}
		}
		else if (GetClientTeam(iClient) == CS_TEAM_T) {
			GetClientWeaponAmmo(iClient, "weapon_molotov", iAmmo[0], iAmmo[1]);
			if (iAmmo[0] < g_iValue) {
				GiveClientWeaponAndAmmo(iClient, "weapon_molotov", g_iValue, g_iValue, g_iValue, g_iValue);
				g_eInfo[iClient].iStats[CLIENT_GRENADES] += g_iValue;
			}
		}
	}
	g_iValue = g_eGroup[iGroupId].iStats[GROUP_HEALTHSHOT_NUM];
	if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_HEALTHSHOT_ROUND]) {
		iAmmo[0] = 0, iAmmo[1] = 0;
		GetClientWeaponAmmo(iClient, "weapon_healthshot", iAmmo[0], iAmmo[1]);
		if (iAmmo[0] < g_iValue)
			GiveClientWeaponAndAmmo(iClient, "weapon_healthshot", g_iValue, g_iValue, g_iValue, g_iValue);
	}
	g_iValue = g_eGroup[iGroupId].iStats[GROUP_TA_NUM];
	if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_TA_ROUND] && g_eInfo[iClient].iStats[CLIENT_GRENADES] < iMaxGrenades) {
		iAmmo[0] = 0, iAmmo[1] = 0;
		GetClientWeaponAmmo(iClient, "weapon_tagrenade", iAmmo[0], iAmmo[1]);
		if (iAmmo[0] < g_iValue) {
			GiveClientWeaponAndAmmo(iClient, "weapon_tagrenade", g_iValue, g_iValue, g_iValue, g_iValue);
			g_eInfo[iClient].iStats[CLIENT_GRENADES] += g_iValue;
		}
	}
	g_iValue = g_eGroup[iGroupId].iStats[GROUP_SNOWBALL_NUM];
	if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_SNOWBALL_ROUND] && g_eInfo[iClient].iStats[CLIENT_GRENADES] < iMaxGrenades) {
		iAmmo[0] = 0, iAmmo[1] = 0;
		GetClientWeaponAmmo(iClient, "weapon_snowball", iAmmo[0], iAmmo[1]);
		if (iAmmo[0] < g_iValue) {
			GiveClientWeaponAndAmmo(iClient, "weapon_snowball", g_iValue, g_iValue, g_iValue, g_iValue);
			g_eInfo[iClient].iStats[CLIENT_GRENADES] += g_iValue;
		}
	}
	g_iValue = g_eGroup[iGroupId].iStats[GROUP_SHIELD];
	if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_SHIELD_ROUND]) {
		if (!HasClientItem(iClient, "weapon_shield"))
			GivePlayerItem(iClient, "weapon_shield");
	}
	
	g_iValue = g_eGroup[iGroupId].iStats[GROUP_DECOY_NUM];
	if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_DECOY_ROUND] && g_eInfo[iClient].iStats[CLIENT_GRENADES] < iMaxGrenades) {
		iAmmo[0] = 0, iAmmo[1] = 0;
		GetClientWeaponAmmo(iClient, "weapon_decoy", iAmmo[0], iAmmo[1]);
		if (iAmmo[0] < g_iValue) {
			GiveClientWeaponAndAmmo(iClient, "weapon_decoy", g_iValue, g_iValue, g_iValue, g_iValue);
			g_eInfo[iClient].iStats[CLIENT_GRENADES] += g_iValue;
		}
	}
	
	g_fValue = g_eGroup[iGroupId].fStats[GROUP_GRAVITY];
	if (g_fValue != 1.0 && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_GRAVITY_ROUND])
		SetEntityGravity(iClient, g_fValue);
	
	g_fValue = g_eGroup[iGroupId].fStats[GROUP_SPEED];
	if (g_fValue != 1.0 && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_SPPED_ROUND])
		SetClientSpeed(iClient, g_fValue);
	if (GetClientTeam(iClient) == CS_TEAM_CT) {
		g_iValue = g_eGroup[iGroupId].iStats[GROUP_DEFUSER];
		if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_DEFUSER_ROUND]) {
			if (!GetEntProp(iClient, Prop_Send, "m_bHasDefuser"))
				GivePlayerItem(iClient, "item_defuser");
		}
	}
	
	g_iValue = g_eGroup[iGroupId].iStats[GROUP_HEAL_NUM];
	g_eInfo[iClient].iStats[CLIENT_HEALS] = 0;
	if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_HEAL_ROUND])
		g_eInfo[iClient].iStats[CLIENT_HEALS] = g_iValue;
	
	if (g_eGroup[iGroupId].iStats[GROUP_PRIMARY_MENU] && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_PRIMARY_MENU_ROUND] && g_eGroup[iGroupId].iStats[GROUP_SECONDARY_MENU] && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_SECONDARY_MENU_ROUND])
		DisplayWeaponsMenu(iClient, MAIN).Display(iClient, 15);
	else if (g_eGroup[iGroupId].iStats[GROUP_PRIMARY_MENU] && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_PRIMARY_MENU_ROUND])
		DisplayWeaponsMenu(iClient, PRIMARY).Display(iClient, 15);
	else if (g_eGroup[iGroupId].iStats[GROUP_SECONDARY_MENU] && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_SECONDARY_MENU_ROUND])
		DisplayWeaponsMenu(iClient, SECONDARY).Display(iClient, 15);
	else if (g_eGroup[iGroupId].iStats[GROUP_GRENADES_MENU] && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_GRENADES_MENU_ROUND])
		DisplayWeaponsMenu(iClient, GRENADES).Display(iClient, 15);
	
	g_iValue = g_eGroup[iGroupId].iStats[GROUP_VISIBILITY];
	if (g_iValue != 255 && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_VISIBILITY_ROUND])
		SetClientVisibility(iClient, g_iValue);
	
	g_iValue = g_eGroup[iGroupId].iStats[GROUP_DAMAGE_GIVEN];
	g_eInfo[iClient].iStats[CLIENT_DAMAGE_GIVE] = 100;
	if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_DAMAGE_GIVEN_ROUND])
		g_eInfo[iClient].iStats[CLIENT_DAMAGE_GIVE] = g_iValue;
	
	g_iValue = g_eGroup[iGroupId].iStats[GROUP_DAMAGE_TAKEN];
	g_eInfo[iClient].iStats[CLIENT_DAMAGE_TAKE] = 100;
	if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_DAMAGE_TAKEN_ROUND])
		g_eInfo[iClient].iStats[CLIENT_DAMAGE_TAKE] = g_iValue;
	
	g_iValue = g_eGroup[iGroupId].iStats[GROUP_DAMAGE_FALL];
	g_eInfo[iClient].iStats[CLIENT_DAMAGE_FALL] = 100;
	if (g_iValue && g_eCore.iRound >= g_eGroup[iGroupId].iStats[GROUP_DAMAGE_FALL_ROUND])
		g_eInfo[iClient].iStats[CLIENT_DAMAGE_FALL] = g_iValue;
	
	if (!StrEqual(g_eGroup[iGroupId].sTableTag, ""))
		CS_SetClientClanTag(iClient, g_eGroup[iGroupId].sTableTag);
	
	Call_StartForward(g_gfSpawn);
	Call_PushCell(iClient);
	Call_Finish();
}

void LoadConfig() {
	KeyValues kv = new KeyValues("Pawel Vip - Config");
	char sPath[PLATFORM_MAX_PATH], sName[32];
	BuildPath(Path_SM, sPath, sizeof(sPath), "configs/pPlugins/pVip.cfg");
	if (!kv.ImportFromFile(sPath)) {
		if (!FileExists(sPath)) {
			if (GenerateConfig())
				LoadConfig();
			else
				SetFailState("[ ✘ pVip » Config ✘ ] Nie udało się utworzyć pliku konfiguracyjnego!");
			delete kv;
			return;
		}
		else {
			LogError("[ ✘ pVip » Config ✘ ] Aktualny plik konfiguracyjny jest uszkodzony! Trwa tworzenie nowego...");
			if (GenerateConfig())
				LoadConfig();
			else
				SetFailState("[ ✘ pVip » Config ✘ ] Nie udało się utworzyć pliku konfiguracyjnego!");
			delete kv;
			return;
		}
	}
	if (kv.JumpToKey("Ustawienia")) {
		g_eCore.iHealType = kv.GetNum("Heal_Type");
		g_eCore.iDeathmatchMode = kv.GetNum("Deathmatch_Mode");
		g_eCore.iDisableBuyHelemet = kv.GetNum("Disable_Buy_Helmet_First_Round");
		kv.GetString("Menu_Tag", g_eCore.sMenuTag, sizeof(g_eCore.sMenuTag));
		kv.GetString("Chat_Tag", g_eCore.sChatTag, sizeof(g_eCore.sChatTag));
		kv.GoBack();
	}
	if (kv.JumpToKey("Menu Broni")) {
		ClearArrays();
		char sBuffer[64];
		if (kv.JumpToKey("Karabiny")) {
			kv.GotoFirstSubKey();
			do {
				g_arWeapons[PRIMARY][0].Push(g_arWeapons[PRIMARY][0].Length + 1);
				kv.GetSectionName(sBuffer, sizeof(sBuffer));
				sBuffer[0] = CharToUpper(sBuffer[0]);
				g_arWeapons[PRIMARY][1].PushString(sBuffer);
				kv.GetString("Weapon", sBuffer, sizeof(sBuffer));
				g_arWeapons[PRIMARY][2].PushString(sBuffer);
				g_arWeapons[PRIMARY][3].Push(kv.GetNum("Team"));
				kv.GetString("Flags", sBuffer, sizeof(sBuffer));
				g_arWeapons[PRIMARY][4].PushString(sBuffer);
			}
			while (kv.GotoNextKey());
			kv.GoBack();
		}
		kv.GoBack();
		if (kv.JumpToKey("Pistolety")) {
			kv.GotoFirstSubKey();
			do {
				g_arWeapons[SECONDARY][0].Push(g_arWeapons[SECONDARY][0].Length + 1);
				sBuffer = "";
				kv.GetSectionName(sBuffer, sizeof(sBuffer));
				g_arWeapons[SECONDARY][1].PushString(sBuffer);
				kv.GetString("Weapon", sBuffer, sizeof(sBuffer));
				g_arWeapons[SECONDARY][2].PushString(sBuffer);
				g_arWeapons[SECONDARY][3].Push(kv.GetNum("Team"));
				kv.GetString("Flags", sBuffer, sizeof(sBuffer));
				g_arWeapons[SECONDARY][4].PushString(sBuffer);
			}
			while (kv.GotoNextKey());
			kv.GoBack();
		}
		kv.GoBack();
		if (kv.JumpToKey("Granaty")) {
			kv.GotoFirstSubKey();
			g_eCore.iGrenadeSets = 0;
			do {
				kv.GetSectionName(g_eGrenades[g_eCore.iGrenadeSets].sName, sizeof(g_eGrenades[].sName));
				kv.GetString("Flags", g_eGrenades[g_eCore.iGrenadeSets].sFlags, sizeof(g_eGrenades[].sFlags));
				g_eGrenades[g_eCore.iGrenadeSets].iTeam = kv.GetNum("Team");
				g_eGrenades[g_eCore.iGrenadeSets].iAmount[SET_HE_NUM] = kv.GetNum("He_Amount");
				g_eGrenades[g_eCore.iGrenadeSets].iAmount[SET_SMOKE_NUM] = kv.GetNum("Smoke_Amount");
				g_eGrenades[g_eCore.iGrenadeSets].iAmount[SET_FLASH_NUM] = kv.GetNum("Flashbang_Amount");
				g_eGrenades[g_eCore.iGrenadeSets].iAmount[SET_DECOY_NUM] = kv.GetNum("Decoy_Amount");
				g_eGrenades[g_eCore.iGrenadeSets].iAmount[SET_MOLOTOV_NUM] = kv.GetNum("Molotov_Amount");
				g_eGrenades[g_eCore.iGrenadeSets].iAmount[SET_TAGRENADE_NUM] = kv.GetNum("TaGrenade_Amount");
				g_eCore.iGrenadeSets++;
			}
			while (kv.GotoNextKey());
			kv.GoBack();
		}
		kv.GoBack();
	}
	kv.GoBack();
	if (kv.JumpToKey("Grupy")) {
		kv.GotoFirstSubKey();
		g_eCore.iGroups = 0;
		int iField = 0;
		do {
			iField = 0;
			g_eCore.iGroups++;
			g_eGroup[g_eCore.iGroups].iStats[GROUP_INDEX] = g_eCore.iGroups;
			kv.GetSectionName(sName, sizeof(sName));
			g_eGroup[g_eCore.iGroups].sName = sName;
			kv.GetString("Flags", g_eGroup[g_eCore.iGroups].sFlags, 16);
			for (int i = 0; i < sizeof(g_sConVars); i++) {
				if (i == 0 || i == 3 || i == 4 || i == 88 || i == 90 || i == 111 || i == 112 || i == 113 || i == 114 || i == 118 || i == 119)
					continue;
				g_eGroup[g_eCore.iGroups].iStats[iField] = kv.GetNum(g_sConVars[i][0]);
				iField++;
			}
			g_eGroup[g_eCore.iGroups].fStats[GROUP_GRAVITY] = kv.GetFloat("Gravity_Amount", 1.0);
			g_eGroup[g_eCore.iGroups].fStats[GROUP_SPEED] = kv.GetFloat("Speed_Amount", 1.0);
			g_eGroup[g_eCore.iGroups].fStats[GROUP_HUD_POSITION_X] = kv.GetFloat("Hud_Position_X");
			g_eGroup[g_eCore.iGroups].fStats[GROUP_HUD_POSITION_Y] = kv.GetFloat("Hud_Position_Y");
			kv.GetString("Welcome_Hud", g_eGroup[g_eCore.iGroups].sWelcomeHud, 256);
			kv.GetString("Goodbye_Hud", g_eGroup[g_eCore.iGroups].sGoodbyeHud, 256);
			kv.GetString("Welcome_Chat", g_eGroup[g_eCore.iGroups].sWelcomeChat, 256);
			kv.GetString("Goodbye_Chat", g_eGroup[g_eCore.iGroups].sGoodbyeChat, 256);
			kv.GetString("Table_Tag", g_eGroup[g_eCore.iGroups].sTableTag, 32);
			kv.GetString("Chat_Tag", g_eGroup[g_eCore.iGroups].sChatTag, 64);
		}
		while (kv.GotoNextKey());
		kv.GoBack();
	}
	Call_StartForward(g_gfConfigLoaded);
	Call_Finish();
	delete kv;
}

bool GenerateConfig() {
	KeyValues kv = new KeyValues("Pawel Vip - Config");
	char sPath[PLATFORM_MAX_PATH];
	char sDirectory[PLATFORM_MAX_PATH] = "configs/pPlugins/";
	BuildPath(Path_SM, sPath, sizeof(sPath), sDirectory);
	if (!DirExists(sPath)) {
		CreateDirectory(sPath, 504);
		if (!DirExists(sPath))
			SetFailState("Nie udało się utworzyć katalogu /sourcemod/configs/pPlugins/ . Proszę to zrobić ręcznie.");
	}
	BuildPath(Path_SM, sPath, sizeof(sPath), "%spVip.cfg", sDirectory);
	if (kv.JumpToKey("Ustawienia", true)) {
		kv.SetString("Deathmatch_Mode", "0");
		kv.SetString("Disable_Buy_Helmet_First_Round", "1");
		kv.SetString("Menu_Tag", "PluginyCS.pl");
		kv.SetString("Chat_Tag", "{orange}PluginyCS.pl {grey}»{default}");
		kv.GoBack();
	}
	if (kv.JumpToKey("Menu Broni", true)) {
		kv.GotoFirstSubKey();
		if (kv.JumpToKey("Karabiny", true)) {
			kv.GotoFirstSubKey();
			if (kv.JumpToKey("AK-47", true)) {
				kv.SetString("Weapon", "weapon_ak47");
				kv.SetString("Team", "0");
				kv.SetString("Flags", "o");
				kv.GoBack();
			}
			if (kv.JumpToKey("M4a1-S", true)) {
				kv.SetString("Weapon", "weapon_m4a1_silencer");
				kv.SetString("Team", "0");
				kv.SetString("Flags", "o");
				kv.GoBack();
			}
			if (kv.JumpToKey("M4a4", true)) {
				kv.SetString("Weapon", "weapon_m4a1");
				kv.SetString("Team", "0");
				kv.SetString("Flags", "o");
				kv.GoBack();
			}
			if (kv.JumpToKey("Galilar", true)) {
				kv.SetString("Weapon", "weapon_galilar");
				kv.SetString("Team", "0");
				kv.SetString("Flags", "o");
				kv.GoBack();
			}
			if (kv.JumpToKey("Famas", true)) {
				kv.SetString("Weapon", "weapon_famas");
				kv.SetString("Team", "0");
				kv.SetString("Flags", "o");
				kv.GoBack();
			}
			kv.GoBack();
		}
		if (kv.JumpToKey("Pistolety", true)) {
			kv.GotoFirstSubKey();
			if (kv.JumpToKey("USP", true)) {
				kv.SetString("Weapon", "weapon_usp_silencer");
				kv.SetString("Team", "0");
				kv.SetString("Flags", "o");
				kv.GoBack();
			}
			if (kv.JumpToKey("Glock", true)) {
				kv.SetString("Weapon", "weapon_glock");
				kv.SetString("Team", "0");
				kv.SetString("Flags", "o");
				kv.GoBack();
			}
			if (kv.JumpToKey("Deagle", true)) {
				kv.SetString("Weapon", "weapon_deagle");
				kv.SetString("Team", "0");
				kv.SetString("Flags", "o");
				kv.GoBack();
			}
			if (kv.JumpToKey("Revolver", true)) {
				kv.SetString("Weapon", "weapon_revolver");
				kv.SetString("Team", "0");
				kv.SetString("Flags", "o");
				kv.GoBack();
			}
			if (kv.JumpToKey("Fiveseven", true)) {
				kv.SetString("Weapon", "weapon_fiveseven");
				kv.SetString("Team", "0");
				kv.SetString("Flags", "o");
				kv.GoBack();
			}
			kv.GoBack();
		}
		if (kv.JumpToKey("Granaty", true)) {
			kv.GotoFirstSubKey();
			if (kv.JumpToKey("2x Flash, 1x HE, 1x Smoke")) {
				kv.SetString("Flags", "o");
				kv.SetString("Team", "0");
				kv.SetString("He_Amount", "1");
				kv.SetString("Smoke_Amount", "1");
				kv.SetString("Flashbang_Amount", "2");
				kv.SetString("Decoy_Amount", "0");
				kv.SetString("Molotov_Amount", "0");
				kv.SetString("TaGrenade_Amount", "0");
				kv.GoBack();
			}
			kv.GoBack();
		}
		kv.GoBack();
	}
	if (kv.JumpToKey("Grupy", true)) {
		kv.GotoFirstSubKey();
		if (kv.JumpToKey("VIP", true)) {
			for (int i = 0; i < sizeof(g_sConVars); i++)
			kv.SetString(g_sConVars[i][0], g_sConVars[i][1]);
			kv.GoBack();
		}
		kv.GoBack();
	}
	kv.GoBack();
	kv.Rewind();
	bool bResult = kv.ExportToFile(sPath);
	delete kv;
	return bResult;
}

int SetClientCash(int iClient, int iAmount) {
	SetEntProp(iClient, Prop_Send, "m_iAccount", iAmount);
}

int GetClientCash(int iClient) {
	return GetEntProp(iClient, Prop_Send, "m_iAccount");
}

int SetClientHealth(int iClient, int iAmount) {
	int iMaxHealth = GetEntData(iClient, FindDataMapInfo(iClient, "m_iMaxHealth"));
	if (iAmount > iMaxHealth)
		SetEntData(iClient, FindDataMapInfo(iClient, "m_iHealth"), iMaxHealth, 4, true);
	else
		SetEntData(iClient, FindDataMapInfo(iClient, "m_iHealth"), iAmount, 4, true);
}

int SetClientKevlar(int iClient, int iAmount) {
	SetEntProp(iClient, Prop_Send, "m_ArmorValue", iAmount);
}

int GetClientWeaponsOffset(int iClient) {
	static int iOffset = -1;
	if (iOffset == -1)
		iOffset = FindDataMapInfo(iClient, "m_hMyWeapons");
	return iOffset;
}

int GetClientWeaponId(int iClient, char[] sClass) {
	int iOffset = GetClientWeaponsOffset(iClient) - 4, iWeapon = INVALID_ENT_REFERENCE, iMaxWeapons = 48;
	char sBuffer[32];
	for (int i = 0; i < iMaxWeapons; i++) {
		iOffset += 4;
		iWeapon = GetEntDataEnt2(iClient, iOffset);
		if (IsValidWeapon(iWeapon)) {
			GetEdictClassname(iWeapon, sBuffer, sizeof(sBuffer));
			if (StrEqual(sClass, sBuffer))
				return iWeapon;
		}
	}
	return INVALID_ENT_REFERENCE;
}

bool GetClientWeaponAmmo(int iClient, char[] sClass, int &iPrimary = -1, int &iSecondary = -1) {
	int iWeapon = GetClientWeaponId(iClient, sClass);
	if (iWeapon == INVALID_ENT_REFERENCE)return false;
	int iOffset[2];
	iOffset[0] = FindDataMapInfo(iClient, "m_iAmmo");
	if (iPrimary != -1) {
		iOffset[1] = iOffset[0] + (GetEntProp(iWeapon, Prop_Data, "m_iPrimaryAmmoType") * 4);
		iPrimary = GetEntData(iClient, iOffset[1]);
	}
	if (iSecondary != -1) {
		iOffset[1] = iOffset[0] + (GetEntProp(iWeapon, Prop_Data, "m_iSecondaryAmmoType") * 4);
		iSecondary = GetEntData(iClient, iOffset[1]);
	}
	return true;
}

int GiveClientWeaponAndAmmo(int iClient, char[] sClass, int iPriamry = -1, int iSecondary = -1, int iPrimaryClip = -1, int iSecondaryClip = -1) {
	bool bHasItem = HasClientItem(iClient, sClass);
	int iWeapon;
	if (!bHasItem) {
		iWeapon = GivePlayerItem(iClient, sClass);
		if (iWeapon == INVALID_ENT_REFERENCE)return INVALID_ENT_REFERENCE;
	}
	else
		iWeapon = GetClientWeaponId(iClient, sClass);
	if (iPrimaryClip != -1)
		SetEntProp(iWeapon, Prop_Data, "m_iClip1", iPrimaryClip);
	
	if (iSecondaryClip != -1)
		SetEntProp(iWeapon, Prop_Data, "m_iClip2", iSecondaryClip);
	
	SetClientWeaponAmmo(iClient, iWeapon, iPriamry, iSecondary);
	return iWeapon;
}

void SetClientWeaponAmmo(int iClient, int iWeapon, int iPrimary = -1, int iSecondary = -1) {
	int iOffset[2];
	iOffset[0] = FindDataMapInfo(iClient, "m_iAmmo");
	if (iPrimary != -1) {
		iOffset[1] = iOffset[0] + (GetEntProp(iWeapon, Prop_Data, "m_iPrimaryAmmoType") * 4);
		SetEntData(iClient, iOffset[1], iPrimary, 4, true);
	}
	if (iSecondary != -1) {
		iOffset[1] = iOffset[0] + (GetEntProp(iWeapon, Prop_Data, "m_iSecondaryAmmoType") * 4);
		SetEntData(iClient, iOffset[1], iSecondary, 4, true);
	}
}

void SetClientVisibility(int iClient, int iAlpha = 255) {
	if (iAlpha > 255 || iAlpha < 0)
		return;
	
	RenderMode rMode = RENDER_TRANSCOLOR;
	if (!iAlpha)
		rMode = RENDER_NONE;
	
	SetEntityRenderMode(iClient, rMode);
	if (iAlpha)
		SetClientRenderColor(iClient, -1, -1, -1, iAlpha);
}

void SetClientRenderColor(int iEntity, int iRed = -1, int iGreen = -1, int iBlue = -1, int iAlpha = -1) {
	bool bGotConfig = false;
	char sProp[32];
	if (!bGotConfig) {
		Handle hConfig = LoadGameConfigFile("core.games");
		bool bExists = GameConfGetKeyValue(hConfig, "m_clrRender", sProp, sizeof(sProp));
		delete hConfig;
		
		if (!bExists)
			strcopy(sProp, sizeof(sProp), "m_clrRender");
		bGotConfig = true;
	}
	
	int iOffSet = GetEntSendPropOffs(iEntity, sProp);
	if (iOffSet <= 0)return;
	
	if (iRed != -1)
		SetEntData(iEntity, iOffSet, iRed, 1, true);
	if (iGreen != -1)
		SetEntData(iEntity, iOffSet + 1, iGreen, 1, true);
	if (iBlue != -1)
		SetEntData(iEntity, iOffSet + 2, iBlue, 1, true);
	if (iAlpha != -1)
		SetEntData(iEntity, iOffSet + 3, iAlpha, 1, true);
}

bool IsWeaponKnife(char[] sClass) {
	if (StrContains(sClass, "knife", false) != -1 || StrContains(sClass, "bayonet", false) != -1)
		return true;
	return false;
}

bool IsWeaponGrenade(char[] sClass) {
	if (StrContains(sClass, "hegrenade", false) != -1 || 
		StrContains(sClass, "flashbang", false) != -1 || 
		StrContains(sClass, "smokegrenade", false) != -1 || 
		StrContains(sClass, "decoy", false) != -1 || 
		StrContains(sClass, "molotov", false) != -1 || 
		StrContains(sClass, "incgrenade", false) != -1 || 
		StrContains(sClass, "tagrenade", false) != -1)
	return true;
	return false;
}

void CreateArrays() {
	for (int i = 0; i < 5; i++) {
		g_arWeapons[PRIMARY][i] = new ArrayList(64);
		g_arWeapons[SECONDARY][i] = new ArrayList(64);
	}
}

void ClearArrays() {
	for (int i = 0; i < 5; i++) {
		g_arWeapons[PRIMARY][i].Clear();
		g_arWeapons[SECONDARY][i].Clear();
	}
}

bool IsValidClient(int iClient, bool bForceAlive = false) {
	if (iClient <= 0)return false;
	if (iClient > MaxClients)return false;
	if (!IsClientConnected(iClient))return false;
	if (IsFakeClient(iClient))return false;
	if (IsClientSourceTV(iClient))return false;
	if (bForceAlive)if (!IsPlayerAlive(iClient))return false;
	return IsClientInGame(iClient);
}

bool HasGroup(int iClient) {
	if (IsValidClient(iClient)) {
		if (g_eInfo[iClient].iGroupId != 0)
			return true;
		return false;
	}
	return true;
}

float SetClientSpeed(int iClient, float fAmount) {
	SetEntPropFloat(iClient, Prop_Data, "m_flLaggedMovementValue", fAmount);
}

bool HasClientItem(int iClient, char[] sClass) {
	if (!IsValidClient(iClient))return false;
	char sBuffer[32];
	int iSize = GetEntPropArraySize(iClient, Prop_Send, "m_hMyWeapons");
	for (int i = 0; i < iSize; i++) {
		int iWeapon = GetEntPropEnt(iClient, Prop_Send, "m_hMyWeapons", i);
		if (IsValidWeapon(iWeapon)) {
			GetEntityClassname(iWeapon, sBuffer, sizeof(sBuffer));
			if (StrEqual(sClass, sBuffer, false))
				return true;
		}
	}
	return false;
}

bool IsValidWeapon(int iEntity) {
	if (iEntity > 4096 && iEntity != INVALID_ENT_REFERENCE)
		iEntity = EntRefToEntIndex(iEntity);
	if (!IsValidEdict(iEntity) || !IsValidEntity(iEntity) || iEntity == -1)
		return false;
	char sClass[64];
	GetEdictClassname(iEntity, sClass, sizeof(sClass));
	return StrContains(sClass, "weapon_") == 0;
}

int GetRoundNumber() {
	int iRound = (GetTeamScore(CS_TEAM_CT) + GetTeamScore(CS_TEAM_T) + 1);
	if (iRound < 16)
		return iRound;
	if (iRound > 15 && iRound < 31)
		return iRound - 15;
	if (iRound > 30)
		return iRound - 30;
	return 0;
}

void LoadClientGroup(int iClient, bool bWelcome = false) {
	g_eInfo[iClient].iGroupId = 0;
	for (int i = 1; i <= g_eCore.iGroups; i++) {
		if (CheckFlags(iClient, g_eGroup[i].sFlags) && (!g_eGroup[i].iStats[GROUP_TEAM] || GetClientTeam(iClient) == g_eGroup[i].iStats[GROUP_TEAM])) {
			g_eInfo[iClient].iGroupId = i;
			PrintToConsole(iClient, "Nadana grupa: %s", g_eGroup[g_eInfo[iClient].iGroupId].sName);
			break;
		}
	}
	
	Call_StartForward(g_gfGroupReceived);
	Call_PushCell(iClient);
	Call_PushCell(g_eInfo[iClient].iGroupId);
	Call_Finish();
	if (!IsWarmup())
		CreateTimer(0.5, Timer_SetSpawn, iClient, TIMER_FLAG_NO_MAPCHANGE);
	
	Format(g_eInfo[iClient].sName, MAX_NAME_LENGTH, "%N", iClient);
	if (bWelcome)
		ShowConnectInfo(iClient);
}

void ShowConnectInfo(int iClient) {
	int iGroupId = g_eInfo[iClient].iGroupId;
	char sBuffer[256];
	if (!StrEqual(g_eGroup[iGroupId].sWelcomeHud, "")) {
		Format(sBuffer, sizeof(sBuffer), g_eGroup[iGroupId].sWelcomeHud);
		ReplaceString(sBuffer, sizeof(sBuffer), "{NAME}", g_eInfo[iClient].sName);
		ReplaceString(sBuffer, sizeof(sBuffer), "{GROUP}", g_eGroup[iGroupId].sName);
		SetHudTextParams(g_eGroup[iGroupId].fStats[GROUP_HUD_POSITION_X], g_eGroup[iGroupId].fStats[GROUP_HUD_POSITION_Y], 5.0, 
			g_eGroup[iGroupId].iStats[GROUP_HUD_RED], g_eGroup[iGroupId].iStats[GROUP_HUD_GREEN], g_eGroup[iGroupId].iStats[GROUP_HUD_BLUE], 255, 1);
		LoopValidClients(i)
		ShowSyncHudText(i, g_hHud, sBuffer);
		
	}
	if (!StrEqual(g_eGroup[iGroupId].sWelcomeChat, "")) {
		Format(sBuffer, sizeof(sBuffer), g_eGroup[iGroupId].sWelcomeChat);
		ReplaceString(sBuffer, sizeof(sBuffer), "{GROUP}", g_eGroup[iGroupId].sName);
		ReplaceString(sBuffer, sizeof(sBuffer), "{NAME}", g_eInfo[iClient].sName);
		if (StrContains(sBuffer, "\\n", false) != -1) {
			char sMessage[10][128];
			int iCount = ExplodeString(sBuffer, "\\n", sMessage, sizeof(sMessage), sizeof(sMessage[]));
			for (int i = 0; i < iCount; i++) {
				TrimString(sMessage[i]);
				CPrintToChat(iClient, sMessage[i]);
			}
		}
		else
			CPrintToChatAll(sBuffer);
	}
}

void ShowDisconnectInfo(int iClient) {
	int iGroupId = g_eInfo[iClient].iGroupId;
	char sBuffer[256];
	if (!StrEqual(g_eGroup[iGroupId].sGoodbyeHud, "")) {
		Format(sBuffer, sizeof(sBuffer), g_eGroup[iGroupId].sGoodbyeHud);
		ReplaceString(sBuffer, sizeof(sBuffer), "{NAME}", g_eInfo[iClient].sName);
		ReplaceString(sBuffer, sizeof(sBuffer), "{GROUP}", g_eGroup[iGroupId].sName);
		SetHudTextParams(g_eGroup[iGroupId].fStats[GROUP_HUD_POSITION_X], g_eGroup[iGroupId].fStats[GROUP_HUD_POSITION_Y], 5.0, 
			g_eGroup[iGroupId].iStats[GROUP_HUD_RED], g_eGroup[iGroupId].iStats[GROUP_HUD_GREEN], g_eGroup[iGroupId].iStats[GROUP_HUD_BLUE], 255);
		LoopValidClients(i)
		ShowSyncHudText(i, g_hHud, sBuffer);
	}
	if (!StrEqual(g_eGroup[iGroupId].sGoodbyeChat, "")) {
		Format(sBuffer, sizeof(sBuffer), g_eGroup[iGroupId].sGoodbyeChat);
		ReplaceString(sBuffer, sizeof(sBuffer), "{GROUP}", g_eGroup[iGroupId].sName);
		ReplaceString(sBuffer, sizeof(sBuffer), "{NAME}", g_eInfo[iClient].sName);
		if (StrContains(sBuffer, "\\n", false) != -1) {
			char sMessage[10][128];
			int iCount = ExplodeString(sBuffer, "\\n", sMessage, sizeof(sMessage), sizeof(sMessage[]));
			for (int i = 0; i < iCount; i++) {
				TrimString(sMessage[i]);
				CPrintToChat(iClient, sMessage[i]);
			}
		}
		else
			CPrintToChatAll(sBuffer);
	}
}

void GiveLastWeapons(int iClient) {
	if (!StrEqual(g_eInfo[iClient].sPrimary, "")) {
		StripClientWeapons(iClient, CS_SLOT_PRIMARY);
		GivePlayerItem(iClient, g_eInfo[iClient].sPrimary);
	}
	if (!StrEqual(g_eInfo[iClient].sSecondary, "")) {
		StripClientWeapons(iClient, CS_SLOT_SECONDARY);
		GivePlayerItem(iClient, g_eInfo[iClient].sSecondary);
	}
	if (g_eInfo[iClient].iGrenadeSet != -1) {
		StripClientWeapons(iClient, CS_SLOT_GRENADE);
		GivePlayerGrenades(iClient, g_eInfo[iClient].iGrenadeSet);
	}
}

void StripClientWeapons(int iClient, int iSlot = -1) {
	if (IsValidClient(iClient, true)) {
		int iWeapon;
		if (iSlot == -1) {
			for (int i = 0; i < 2; i++) {
				while ((iWeapon = GetPlayerWeaponSlot(iClient, i)) != -1) {
					RemovePlayerItem(iClient, iWeapon);
					AcceptEntityInput(iWeapon, "Kill");
				}
			}
		}
		else {
			while ((iWeapon = GetPlayerWeaponSlot(iClient, iSlot)) != -1) {
				RemovePlayerItem(iClient, iWeapon);
				AcceptEntityInput(iWeapon, "Kill");
			}
		}
	}
}

bool CheckFlags(int iClient, char[] sFlags) {
	if (StrEqual(sFlags, ""))return true;
	if (GetUserFlagBits(iClient) & ADMFLAG_ROOT)return true;
	int iCount = CountCharacters(sFlags);
	if (iCount > 1) {
		int iAccess = 0;
		char sFlag[16];
		for (int i = 0; i < iCount; i++) {
			Format(sFlag, sizeof(sFlag), "%c", sFlags[i]);
			if (GetUserFlagBits(iClient) & ReadFlagString(sFlag))
				iAccess++;
		}
		if (iAccess == iCount)return true;
	}
	if (GetUserFlagBits(iClient) & ReadFlagString(sFlags))return true;
	if (StrEqual(sFlags, ""))return true;
	return false;
}

bool CheckGroupFlags(char[] sGroupFlags, char[] sFlags) {
	if (StrEqual(sFlags, "") || StrContains(sGroupFlags, "z", false) != -1)return true;
	int iCount = CountCharacters(sFlags), iAccess = 0;
	char sFlag[2];
	for (int i = 0; i < iCount; i++) {
		Format(sFlag, sizeof(sFlag), "%c", sFlags[i]);
		if (StrContains(sGroupFlags, sFlag, false) != -1)
			iAccess++;
	}
	if (iAccess == iCount)return true;
	return false;
}

int CountCharacters(char[] sPhrase) {
	int iCharacters = 0;
	for (int i = 0; i < strlen(sPhrase); i++)
	iCharacters++;
	return iCharacters;
}

bool IsClientInTeam(int iClient, int iTeam) {
	if (!iTeam)return true;
	if (GetClientTeam(iClient) == iTeam)return true;
	return false;
}

bool IsWarmup() {
	int iWarmup = GameRules_GetProp("m_bWarmupPeriod", 4, 0);
	if (iWarmup == 1)return true;
	else return false;
}

int CountClientGrenades(int iClient) {
	int iAmmo[2];
	int iGrenades = 0;
	
	GetClientWeaponAmmo(iClient, "weapon_hegrenade", iAmmo[0], iAmmo[1]);
	iGrenades += iAmmo[0];
	iAmmo[0] = 0, iAmmo[1] = 0;
	
	GetClientWeaponAmmo(iClient, "weapon_flashbang", iAmmo[0], iAmmo[1]);
	iGrenades += iAmmo[0];
	iAmmo[0] = 0, iAmmo[1] = 0;
	
	GetClientWeaponAmmo(iClient, "weapon_smokegrenade", iAmmo[0], iAmmo[1]);
	iGrenades += iAmmo[0];
	iAmmo[0] = 0, iAmmo[1] = 0;
	
	GetClientWeaponAmmo(iClient, "weapon_incgrenade", iAmmo[0], iAmmo[1]);
	iGrenades += iAmmo[0];
	iAmmo[0] = 0, iAmmo[1] = 0;
	
	GetClientWeaponAmmo(iClient, "weapon_molotov", iAmmo[0], iAmmo[1]);
	iGrenades += iAmmo[0];
	iAmmo[0] = 0, iAmmo[1] = 0;
	
	GetClientWeaponAmmo(iClient, "weapon_tagrenade", iAmmo[0], iAmmo[1]);
	iGrenades += iAmmo[0];
	iAmmo[0] = 0, iAmmo[1] = 0;
	
	GetClientWeaponAmmo(iClient, "weapon_snowball", iAmmo[0], iAmmo[1]);
	iGrenades += iAmmo[0];
	iAmmo[0] = 0, iAmmo[1] = 0;
	
	GetClientWeaponAmmo(iClient, "weapon_decoy", iAmmo[0], iAmmo[1]);
	iGrenades += iAmmo[0];
	return iGrenades;
}

int GetGroupIdByName(char[] sName) {
	for (int i = 1; i <= g_eCore.iGroups; i++) {
		if (StrEqual(g_eGroup[i].sName, sName))
			return i;
	}
	return 0;
}

void GivePlayerGrenades(int iClient, int iSetId) {
	if (!IsValidClient(iClient, true))return;
	int iAmmo[2], iMaxGrenades = FindConVar("ammo_grenade_limit_total").IntValue;
	g_eInfo[iClient].iStats[CLIENT_GRENADES] = CountClientGrenades(iClient);
	
	g_iValue = g_eGrenades[iSetId].iAmount[SET_HE_NUM];
	if (g_iValue && g_eInfo[iClient].iStats[CLIENT_GRENADES] < iMaxGrenades) {
		GetClientWeaponAmmo(iClient, "weapon_hegrenade", iAmmo[0], iAmmo[1]);
		if (iAmmo[0] < g_iValue) {
			GiveClientWeaponAndAmmo(iClient, "weapon_hegrenade", g_iValue, g_iValue, g_iValue, g_iValue);
			g_eInfo[iClient].iStats[CLIENT_GRENADES] += g_iValue;
		}
	}
	g_iValue = g_eGrenades[iSetId].iAmount[SET_SMOKE_NUM];
	if (g_iValue && g_eInfo[iClient].iStats[CLIENT_GRENADES] < iMaxGrenades) {
		GetClientWeaponAmmo(iClient, "weapon_smokegrenade", iAmmo[0], iAmmo[1]);
		if (iAmmo[0] < g_iValue) {
			GiveClientWeaponAndAmmo(iClient, "weapon_smokegrenade", g_iValue, g_iValue, g_iValue, g_iValue);
			g_eInfo[iClient].iStats[CLIENT_GRENADES] += g_iValue;
		}
	}
	g_iValue = g_eGrenades[iSetId].iAmount[SET_FLASH_NUM];
	if (g_iValue && g_eInfo[iClient].iStats[CLIENT_GRENADES] < iMaxGrenades) {
		GetClientWeaponAmmo(iClient, "weapon_flashbang", iAmmo[0], iAmmo[1]);
		if (iAmmo[0] < g_iValue) {
			GiveClientWeaponAndAmmo(iClient, "weapon_flashbang", g_iValue, g_iValue, g_iValue, g_iValue);
			g_eInfo[iClient].iStats[CLIENT_GRENADES] += g_iValue;
		}
	}
	g_iValue = g_eGrenades[iSetId].iAmount[SET_DECOY_NUM];
	if (g_iValue && g_eInfo[iClient].iStats[CLIENT_GRENADES] < iMaxGrenades) {
		GetClientWeaponAmmo(iClient, "weapon_decoy", iAmmo[0], iAmmo[1]);
		if (iAmmo[0] < g_iValue) {
			GiveClientWeaponAndAmmo(iClient, "weapon_decoy", g_iValue, g_iValue, g_iValue, g_iValue);
			g_eInfo[iClient].iStats[CLIENT_GRENADES] += g_iValue;
		}
	}
	g_iValue = g_eGrenades[iSetId].iAmount[SET_MOLOTOV_NUM];
	if (g_iValue && g_eInfo[iClient].iStats[CLIENT_GRENADES] < iMaxGrenades) {
		if (GetClientTeam(iClient) == CS_TEAM_CT) {
			GetClientWeaponAmmo(iClient, "weapon_incgrenade", iAmmo[0], iAmmo[1]);
			if (iAmmo[0] < g_iValue) {
				GiveClientWeaponAndAmmo(iClient, "weapon_incgrenade", g_iValue, g_iValue, g_iValue, g_iValue);
				g_eInfo[iClient].iStats[CLIENT_GRENADES] += g_iValue;
			}
		}
		else if (GetClientTeam(iClient) == CS_TEAM_T) {
			GetClientWeaponAmmo(iClient, "weapon_molotov", iAmmo[0], iAmmo[1]);
			if (iAmmo[0] < g_iValue) {
				GiveClientWeaponAndAmmo(iClient, "weapon_molotov", g_iValue, g_iValue, g_iValue, g_iValue);
				g_eInfo[iClient].iStats[CLIENT_GRENADES] += g_iValue;
			}
		}
	}
	g_iValue = g_eGrenades[iSetId].iAmount[SET_TAGRENADE_NUM];
	if (g_iValue && g_eInfo[iClient].iStats[CLIENT_GRENADES] < iMaxGrenades) {
		GetClientWeaponAmmo(iClient, "weapon_tagrenade", iAmmo[0], iAmmo[1]);
		if (iAmmo[0] < g_iValue) {
			GiveClientWeaponAndAmmo(iClient, "weapon_tagrenade", g_iValue, g_iValue, g_iValue, g_iValue);
			g_eInfo[iClient].iStats[CLIENT_GRENADES] += g_iValue;
		}
	}
}

/* [ Chat Message ] */
#define MAXLENGTH_NAME		128
#define MAXLENGTH_MESSAGE	128
public Action CP_OnChatMessage(int &iAuthor, ArrayList arRecipients, char[] sFlagString, char[] sName, char[] sMessage, bool &bProcessColors, bool &bRemoveColors) {
	if (!g_eCore.bChatSystem[0] || !IsValidClient(iAuthor) || !HasGroup(iAuthor) || g_bShopChatModule)
		return Plugin_Continue;
	
	Format(sName, MAXLENGTH_NAME, " %s\x03 %s", g_eGroup[g_eInfo[iAuthor].iGroupId].sChatTag, sName);
	CFormatColor(sName, MAXLENGTH_NAME);
	return Plugin_Changed;
}

public Action OnChatMessage(int &iAuthor, Handle hRecipients, char[] sName, char[] sMessage) {
	if (!g_eCore.bChatSystem[1] || !IsValidClient(iAuthor) || !HasGroup(iAuthor) || g_bShopChatModule)
		return Plugin_Continue;
	Format(sName, MAXLENGTH_NAME, " %s \x03 %s", g_eGroup[g_eInfo[iAuthor].iGroupId].sChatTag, sName);
	Format(sMessage, MAXLENGTH_MESSAGE, "%s", sMessage);
	CFormatColor(sName, MAXLENGTH_NAME);
	return Plugin_Changed;
}

/* [ Natives ] */
public APLRes AskPluginLoad2(Handle hMySelf, bool bLate, char[] sError, int iErrosMax) {
	CreateNative("pVip_GetGroupsCount", Native_GetGroupsCount);
	CreateNative("pVip_GetGroupInfo", Native_GetGroupInfo);
	CreateNative("pVip_GetClientInfo", Native_GetClientInfo);
	CreateNative("pVip_GetPluginInfo", Native_GetPluginInfo);
	CreateNative("pVip_SetClientGroup", Native_SetClientGroup);
	CreateNative("pVip_GetGroupIdByName", Native_GetGroupIdByName);
	CreateNative("pVip_PreparePlayerSetup", Native_PreparePlayerSetup);
	CreateNative("pVip_SetPluginStatus", Native_SetPluginStatus);
	CreateNative("pVip_GetPluginStatus", Native_GetPluginStatus);
	CreateNative("pVip_GetGroupIdByFlags", Native_GetGroupIdByFlags);
	CreateNative("pVip_AutoAssignGroup", Native_AutoAssignGroup);
	CreateNative("pVip_GetGroupChatTag", Native_GetGroupChatTag);
	
	MarkNativeAsOptional("pVip_GetGroupsCount");
	MarkNativeAsOptional("pVip_GetGroupInfo");
	MarkNativeAsOptional("pVip_GetClientInfo");
	MarkNativeAsOptional("pVip_GetPluginInfo");
	MarkNativeAsOptional("pVip_SetClientGroup");
	MarkNativeAsOptional("pVip_GetGroupIdByName");
	MarkNativeAsOptional("pVip_PreparePlayerSetup");
	MarkNativeAsOptional("pVip_SetPluginStatus");
	MarkNativeAsOptional("pVip_GetPluginStatus");
	MarkNativeAsOptional("pVip_AutoAssignGroup");
	MarkNativeAsOptional("pVip_GetGroupIdByFlags");
	RegPluginLibrary("pVip-Core");
	return APLRes_Success;
}

public void OnLibraryAdded(const char[] sName) {
	if (StrEqual(sName, "chat-processor")) {
		g_eCore.bChatSystem[0] = true;
		PrintToServer("✔ pVip Core | Wykryto Chat-Processor by Drixevel.");
		return;
	}
	else if (StrEqual(sName, "scp")) {
		g_eCore.bChatSystem[1] = true;
		PrintToServer("✔ pVip Core | Wykryto Simple Chat Processor by Mini.");
		return;
	}
	else if (StrEqual(sName, "pShop-Chat")) {
		g_bShopChatModule = true;
		PrintToServer("✔ pVip Core | Wykryto sklep by Pawel.");
		return;
	}
}

public void OnLibraryRemoved(const char[] sName) {
	if (StrEqual(sName, "chat-processor"))g_eCore.bChatSystem[0] = false;
	else if (StrEqual(sName, "scp"))g_eCore.bChatSystem[1] = false;
	else if (StrEqual(sName, "pShop-Chat"))g_bShopChatModule = false;
}

public int Native_GetGroupsCount(Handle hPlugin, int iNumParams) {
	return g_eCore.iGroups;
}

public int Native_GetGroupInfo(Handle hPlugin, int iNumParams) {
	SetNativeArray(2, g_eGroup[GetNativeCell(1)], sizeof(g_eGroup[]));
}

public int Native_GetClientInfo(Handle hPlugin, int iNumParams) {
	int iClient = GetNativeCell(1);
	if (IsValidClient(iClient)) {
		SetNativeArray(2, g_eInfo[GetNativeCell(1)], sizeof(g_eInfo[]));
		return 1;
	}
	return 0;
}

public int Native_GetPluginInfo(Handle hPlugin, int iNumParams) {
	SetNativeArray(1, g_eCore, sizeof(g_eCore));
}

public int Native_SetClientGroup(Handle hPlugin, int iNumParams) {
	int iClient = GetNativeCell(1);
	if (IsValidClient(iClient)) {
		g_eInfo[iClient].iGroupId = GetNativeCell(2);
		return 1;
	}
	return 0;
}

public int Native_GetGroupIdByName(Handle hPlugin, int iNumParams) {
	char sName[32];
	GetNativeString(1, sName, sizeof(sName));
	return GetGroupIdByName(sName);
}

public int Native_PreparePlayerSetup(Handle hPlugin, int iNumParams) {
	int iClient = GetNativeCell(1);
	if (IsValidClient(iClient)) {
		PreparePlayerSetup(iClient);
		return true;
	}
	return false;
}

public int Native_SetPluginStatus(Handle hPlugin, int iNumParams) {
	g_bEnabled = view_as<bool>(GetNativeCell(1));
}

public int Native_GetPluginStatus(Handle hPlugin, int iNumParams) {
	return view_as<int>(g_bEnabled);
}

public int Native_GetGroupIdByFlags(Handle hPlugin, int iNumParams) {
	char sFlags[16];
	GetNativeString(1, sFlags, sizeof(sFlags));
	int iTeam = GetNativeCell(2);
	for (int i = 1; i <= g_eCore.iGroups; i++) {
		if (StrEqual(g_eGroup[i].sFlags, sFlags)) {
			if (iTeam != 0 && g_eGroup[i].iStats[GROUP_TEAM] == iTeam)
				return i;
			return i;
		}
	}
	return -1;
}

public int Native_AutoAssignGroup(Handle hPlugin, int iNumParams) {
	int iClient = GetNativeCell(1);
	if (IsValidClient(iClient)) {
		LoadClientGroup(iClient);
		return 1;
	}
	return 0;
}

public int Native_GetGroupChatTag(Handle hPlugin, int iNumParams) {
	SetNativeString(2, g_eGroup[GetNativeCell(1)].sChatTag, sizeof(g_eGroup[].sChatTag));
} 