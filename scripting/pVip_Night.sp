/* [ Includes ] */
#include <sourcemod>
#include <sdktools>
#include <pVip-Core>

/* [ Compiler Options ] */
#pragma newdecls required
#pragma semicolon		1

/* [ Defines ] */
#define LoopClients(%1)		for(int %1 = 1; %1 < MaxClients; %1++) if(IsValidClient(%1))
#define NIGHT_START			0
#define NIGHT_END			1
#define NIGHT_GROUP			2

/* [ Enums ] */
Enum_PluginInfo g_ePlugin;

/* [ Booleans ] */
bool g_bEnabled;
bool g_bFreeGroup[MAXPLAYERS];

/* [ Integers ] */
int g_iCvar[3];

/* [ Plugin Author And Informations ] */
public Plugin myinfo = {
	name = "[CS:GO] Pawel - [ pVip - Night Vip ]", 
	author = "Pawel", 
	description = "Moduł do systemu Vip na serwery CS:GO by Paweł.", 
	version = "1.0.1", 
	url = "https://steamcommunity.com/id/pawelsteam"
};

/* [ Plugin Startup ] */
public void OnPluginStart() {
	/* [ Events ] */
	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_spawn", Event_PlayerSpawn);
}

/* [ Standard Actions ] */
public void pVip_ConfigLoaded() {
	pVip_GetPluginInfo(g_ePlugin);
}

public void OnConfigsExecuted() {
	LoadConfig();
}

public void OnMapStart() {
	CheckHour();
}

public void OnClientPostAdminCheck(int iClient) {
	if (IsValidClient(iClient))
		g_bFreeGroup[iClient] = false;
}
public void OnClientDisconnect(int iClient) {
	if (IsValidClient(iClient))
		g_bFreeGroup[iClient] = false;
}

/* [ Events ] */
public Action Event_RoundStart(Event eEvent, const char[] sName, bool bDontBroadcast) {
	CheckHour();
}

public Action Event_PlayerSpawn(Event eEvent, const char[] sName, bool bDontBroadcast) {
	if (!g_bEnabled)return Plugin_Continue;
	int iClient = GetClientOfUserId(eEvent.GetInt("userid"));
	if (!IsValidClient(iClient))return Plugin_Continue;
	Enum_ClientInfo eInfo;
	pVip_GetClientInfo(iClient, eInfo);
	if (!eInfo.iGroupId && !g_bFreeGroup[iClient]) {
		pVip_SetClientGroup(iClient, g_iCvar[NIGHT_GROUP]);
		g_bFreeGroup[iClient] = true;
	}
	if (g_bFreeGroup[iClient]) {
		pVip_SetClientGroup(iClient, g_iCvar[NIGHT_GROUP]);
		if (!IsWarmup())
			pVip_PreparePlayerSetup(iClient);
	}
	return Plugin_Continue;
}

/* [ Helpers ] */
void LoadConfig() {
	KeyValues kv = new KeyValues("Pawel Night Vip - Config");
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "configs/pPlugins/pVip_Night.cfg");
	if (!kv.ImportFromFile(sPath)) {
		if (!FileExists(sPath)) {
			if (GenerateConfig())
				LoadConfig();
			else
				SetFailState("[ ✘ pVip Night » Config ✘ ] Nie udało się utworzyć pliku konfiguracyjnego!");
			delete kv;
			return;
		}
		else {
			LogError("[ ✘ pVip Night » Config ✘ ] Aktualny plik konfiguracyjny jest uszkodzony! Trwa tworzenie nowego...");
			if (GenerateConfig())
				LoadConfig();
			else
				SetFailState("[ ✘ pVip Night » Config ✘ ] Nie udało się utworzyć pliku konfiguracyjnego!");
			delete kv;
			return;
		}
	}
	if (kv.JumpToKey("Ustawienia")) {
		g_iCvar[NIGHT_START] = kv.GetNum("Start_Hour");
		g_iCvar[NIGHT_END] = kv.GetNum("End_Hour");
		g_iCvar[NIGHT_GROUP] = kv.GetNum("GroupId");
		kv.GoBack();
	}
	CheckHour();
	delete kv;
}

bool GenerateConfig() {
	KeyValues kv = new KeyValues("Pawel Night Vip - Config");
	char sPath[PLATFORM_MAX_PATH];
	char sDirectory[PLATFORM_MAX_PATH] = "configs/pPlugins/";
	BuildPath(Path_SM, sPath, sizeof(sPath), sDirectory);
	if (!DirExists(sPath)) {
		CreateDirectory(sPath, 504);
		if (!DirExists(sPath))
			SetFailState("Nie udało się utworzyć katalogu /sourcemod/configs/pPlugins/ . Proszę to zrobić ręcznie.");
	}
	BuildPath(Path_SM, sPath, sizeof(sPath), "%spVip_Night.cfg", sDirectory);
	if (kv.JumpToKey("Ustawienia", true)) {
		kv.SetString("Start_Hour", "22");
		kv.SetString("End_Hour", "9");
		kv.SetString("GroupId", "1");
		kv.GoBack();
	}
	kv.Rewind();
	bool bResult = kv.ExportToFile(sPath);
	delete kv;
	return bResult;
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

void CheckHour() {
	if (g_iCvar[NIGHT_START] || g_iCvar[NIGHT_END]) {
		char sHour[8];
		FormatTime(sHour, sizeof(sHour), "%H", GetTime());
		int iHour = StringToInt(sHour);
		if (iHour >= g_iCvar[NIGHT_START] || iHour <= g_iCvar[NIGHT_END])
			g_bEnabled = true;
		else if (iHour <= g_iCvar[NIGHT_START] && iHour >= g_iCvar[NIGHT_END])
			g_bEnabled = false;
	}
} 

bool IsWarmup() {
	int iWarmup = GameRules_GetProp("m_bWarmupPeriod", 4, 0);
	if (iWarmup == 1)return true;
	else return false;
}