/* [ Includes ] */
#include <sourcemod>
#include <sdktools>
#include <pVip-Core>

/* [ Compiler Options ] */
#pragma newdecls required
#pragma semicolon		1

/* [ Defines ] */
#define LoopClients(%1)		for(int %1 = 1; %1 < MaxClients; %1++) if(IsValidClient(%1))

/* [ Enums ] */
Enum_PluginInfo g_ePlugin;

/* [ Menus ] */
Menu g_mMenu;

/* [ Plugin Author And Informations ] */
public Plugin myinfo =  {
	name = "[CS:GO] Pawel - [ pVip - Online Members Module ]", 
	author = "Pawel", 
	description = "Moduł do systemu Vip na serwery CS:GO by Paweł.", 
	version = "1.0.0", 
	url = "https://steamcommunity.com/id/pawelsteam"
};

/* [ Plugin Startup ] */
public void OnPluginStart() {
	/* [ Commands ] */
	RegConsoleCmd("sm_vips", Online_Command);
}

/* [ Standard Actions ] */
public void pVip_ConfigLoaded() {
	pVip_GetPluginInfo(g_ePlugin);
}

/* [ Commands ] */
public Action Online_Command(int iClient, int iArgs) {
	int iGroups = pVip_GetGroupsCount();
	if (iGroups == 1)
		DisplayOnlineGroup(iGroups).Display(iClient, MENU_TIME_FOREVER);
	else
		DisplayOnline(iClient).Display(iClient, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

Menu DisplayOnline(int iClient) {
	char sBuffer[256], sItem[8];
	Format(sBuffer, sizeof(sBuffer), "[ ★ %s » Online ★ ]\n ", g_ePlugin.sMenuTag);
	g_mMenu = new Menu(Online_Handler);
	int iGroups = pVip_GetGroupsCount();
	g_mMenu.SetTitle(sBuffer);
	if (iGroups > 1) {
		Format(sBuffer, sizeof(sBuffer), "%s\n➪ Witaj, %N!", sBuffer, iClient);
		Format(sBuffer, sizeof(sBuffer), "%s\n➪ Wybierz grupę, aby zobaczyć graczy online.", sBuffer);
		Format(sBuffer, sizeof(sBuffer), "%s\n---------------------------------------------", sBuffer);
		g_mMenu.SetTitle(sBuffer);
		Enum_GroupInfo eGroup;
		for (int i = 1; i <= iGroups; i++) {
			pVip_GetGroupInfo(i, eGroup);
			Format(sBuffer, sizeof(sBuffer), "» %s", eGroup.sName);
			IntToString(i, sItem, sizeof(sItem));
			g_mMenu.AddItem(sItem, sBuffer);
		}
	}
	else if (!iGroups)
		g_mMenu.AddItem("0", "» Nie wykryto żadnej grupy.\n ", ITEMDRAW_DISABLED);
	return g_mMenu;
}

public int Online_Handler(Menu mMenu, MenuAction maAction, int iClient, int iPosition) {
	switch (maAction) {
		case MenuAction_Select: {
			char sItem[8];
			mMenu.GetItem(iPosition, sItem, sizeof(sItem));
			int iId = StringToInt(sItem);
			DisplayOnlineGroup(iId).Display(iClient, MENU_TIME_FOREVER);
		}
		case MenuAction_End:delete mMenu;
	}
}

Menu DisplayOnlineGroup(int iGroupId) {
	char sBuffer[256];
	Enum_GroupInfo eGroup;
	pVip_GetGroupInfo(iGroupId, eGroup);
	Format(sBuffer, sizeof(sBuffer), "[ ★ %s » Online ★ ]\n ", g_ePlugin.sMenuTag);
	Format(sBuffer, sizeof(sBuffer), "%s\n➪ Gracze online z grupy: %s", sBuffer, eGroup.sName);
	Format(sBuffer, sizeof(sBuffer), "%s\n---------------------------------------------", sBuffer);
	g_mMenu = new Menu(OnlineGroup_Handler);
	g_mMenu.SetTitle(sBuffer);
	Enum_ClientInfo eClientInfo;
	LoopClients(i) {
		pVip_GetClientInfo(i, eClientInfo);
		if (eClientInfo.iGroupId == iGroupId) {
			Format(sBuffer, sizeof(sBuffer), "» %N", i);
			g_mMenu.AddItem("", sBuffer, ITEMDRAW_DISABLED);
		}
	}
	if (!g_mMenu.ItemCount)
		g_mMenu.AddItem("", "» Aktualnie nie ma żadnego gracza online z tej grupy.\n ", ITEMDRAW_DISABLED);
	return g_mMenu;
}

public int OnlineGroup_Handler(Menu mMenu, MenuAction maAction, int iClient, int iPosition) {
	switch (maAction) {
		case MenuAction_End:delete mMenu;
	}
}

/* [ Helpers ] */
bool IsValidClient(int iClient, bool bForceAlive = false) {
	if (iClient <= 0)return false;
	if (iClient > MaxClients)return false;
	if (!IsClientConnected(iClient))return false;
	if (IsFakeClient(iClient))return false;
	if (IsClientSourceTV(iClient))return false;
	if (bForceAlive)if (!IsPlayerAlive(iClient))return false;
	return IsClientInGame(iClient);
}
