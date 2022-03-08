#if defined _pVip_included
#endinput
#endif
#define _pVip_included

/* [ Defines ] */
#define GROUP_TEAM						0
#define GROUP_DOUBLE_JUMP				1
#define GROUP_MAX_HP					2
#define GROUP_EXTRA_HP_SPAWN			3
#define GROUP_EXTRA_HP_SPAWN_ROUND		4
#define GROUP_EXTRA_MONEY_SPAWN			5
#define GROUP_EXTRA_MONEY_SPAWN_ROUND   6
#define GROUP_EXTRA_MONEY_SPAWN_INFO    7
#define GROUP_EXTRA_MONEY_KILL			8
#define GROUP_EXTRA_MONEY_KILL_ROUND	9
#define GROUP_EXTRA_MONEY_KILL_INFO     10
#define GROUP_EXTRA_MONEY_KILL_HS		11
#define GROUP_EXTRA_MONEY_KILL_HS_ROUND	12
#define GROUP_EXTRA_MONEY_KILL_HS_INFO	13
#define GROUP_EXTRA_MONEY_ASSIST		14
#define GROUP_EXTRA_MONEY_ASSIST_ROUND	15
#define GROUP_EXTRA_MONEY_ASSIST_INFO	16
#define GROUP_EXTRA_MONEY_PLANT			17
#define GROUP_EXTRA_MONEY_PLANT_ROUND	18
#define GROUP_EXTRA_MONEY_PLANT_INFO	19
#define GROUP_EXTRA_MONEY_DEFUSE		20
#define GROUP_EXTRA_MONEY_DEFUSE_ROUND	21
#define GROUP_EXTRA_MONEY_DEFUSE_INFO	22
#define GROUP_EXTRA_MONEY_HOSTAGE		23
#define GROUP_EXTRA_MONEY_HOSTAGE_ROUND	24
#define GROUP_EXTRA_MONEY_HOSTAGE_INFO	25
#define GROUP_EXTRA_MONEY_MVP			26
#define GROUP_EXTRA_MONEY_MVP_ROUND		27
#define GROUP_EXTRA_MONEY_MVP_INFO		28
#define GROUP_EXTRA_MONEY_KNIFE			29
#define GROUP_EXTRA_MONEY_KNIFE_ROUND	30
#define GROUP_EXTRA_MONEY_KNIFE_INFO	31
#define GROUP_EXTRA_MONEY_GRENADE		32
#define GROUP_EXTRA_MONEY_GRENADE_ROUND	33
#define GROUP_EXTRA_MONEY_GRENADE_INFO	34
#define GROUP_EXTRA_MONEY_ZEUS			35
#define GROUP_EXTRA_MONEY_ZEUS_ROUND	36
#define GROUP_EXTRA_MONEY_ZEUS_INFO		37
#define GROUP_EXTRA_MONEY_NOSCOPE		38
#define GROUP_EXTRA_MONEY_NOSCOPE_ROUND	39
#define GROUP_EXTRA_MONEY_NOSCOPE_INFO	40
#define GROUP_EXTRA_HP_KILL				41
#define GROUP_EXTRA_HP_KILL_ROUND		42
#define GROUP_EXTRA_HP_KILL_INFO		43
#define GROUP_EXTRA_HP_KILL_HS			44
#define GROUP_EXTRA_HP_KILL_HS_ROUND	45
#define GROUP_EXTRA_HP_KILL_HS_INFO		46
#define GROUP_EXTRA_HP_ASSIST			47
#define GROUP_EXTRA_HP_ASSIST_ROUND		48
#define GROUP_EXTRA_HP_ASSIST_INFO	    49
#define GROUP_EXTRA_HP_KNIFE			50
#define GROUP_EXTRA_HP_KNIFE_ROUND		51
#define GROUP_EXTRA_HP_KNIFE_INFO		52
#define GROUP_EXTRA_HP_GRENADE			53
#define GROUP_EXTRA_HP_GRENADE_ROUND	54
#define GROUP_EXTRA_HP_GRENADE_INFO		55
#define GROUP_EXTRA_HP_ZEUS				56
#define GROUP_EXTRA_HP_ZEUS_ROUND		57
#define GROUP_EXTRA_HP_ZEUS_INFO		58
#define GROUP_EXTRA_HP_NOSCOPE			59
#define GROUP_EXTRA_HP_NOSCOPE_ROUND	60
#define GROUP_EXTRA_HP_NOSCOPE_INFO     61
#define GROUP_KEVLAR					62
#define GROUP_KEVLAR_AMOUNT				63
#define GROUP_KEVLAR_ROUND				64
#define GROUP_HELMET					65
#define GROUP_HELMET_ROUND				66
#define GROUP_HE_NUM					67
#define GROUP_HE_ROUND					68
#define GROUP_FLASH_NUM					69
#define GROUP_FLASH_ROUND				70
#define GROUP_SMOKE_NUM					71
#define GROUP_SMOKE_ROUND				72
#define GROUP_MOLOTOV_NUM				73
#define GROUP_MOLOTOV_ROUND				74
#define GROUP_HEALTHSHOT_NUM			75
#define GROUP_HEALTHSHOT_ROUND          76
#define GROUP_TA_NUM					77
#define GROUP_TA_ROUND					78	
#define GROUP_SNOWBALL_NUM				79
#define GROUP_SNOWBALL_ROUND			80
#define GROUP_SHIELD					81
#define GROUP_SHIELD_ROUND				82
#define GROUP_DECOY_NUM					83
#define GROUP_DECOY_ROUND				84
#define GROUP_GRAVITY					0
#define GROUP_GRAVITY_ROUND				85
#define GROUP_SPEED						1
#define GROUP_SPPED_ROUND				86
#define GROUP_DEFUSER					87
#define GROUP_DEFUSER_ROUND				88
#define GROUP_HEAL_NUM					89
#define GROUP_HEAL_ROUND				90
#define GROUP_HEAL_VALUE                91
#define GROUP_PRIMARY_MENU				92
#define GROUP_PRIMARY_MENU_ROUND		93
#define GROUP_SECONDARY_MENU	 		94
#define GROUP_SECONDARY_MENU_ROUND		95
#define GROUP_GRENADES_MENU				96
#define GROUP_GRENADES_MENU_ROUND		97
#define GROUP_VISIBILITY				98
#define GROUP_VISIBILITY_ROUND			99
#define GROUP_DAMAGE_GIVEN				100	
#define GROUP_DAMAGE_GIVEN_ROUND		101
#define GROUP_DAMAGE_TAKEN				102
#define GROUP_DAMAGE_TAKEN_ROUND		103
#define GROUP_DAMAGE_FALL				104
#define GROUP_DAMAGE_FALL_ROUND			105
#define GROUP_HUD_POSITION_X			2
#define GROUP_HUD_POSITION_Y			3
#define GROUP_HUD_RED					106
#define GROUP_HUD_GREEN					107
#define GROUP_HUD_BLUE					108
#define GROUP_RESPAWN_CHANCE			109
#define GROUP_RESPAWN_CHANCE_ROUND		110
#define GROUP_INDEX						111
#define INTEGER_FIELDS					112
#define FLOAT_FIELDS					4
#define CLIENT_DAMAGE_GIVE				0
#define CLIENT_DAMAGE_TAKE				1
#define CLIENT_DAMAGE_FALL				2
#define CLIENT_HEALS					3
#define CLIENT_GRENADES					4
#define CLIENT_MAX_FIELDS				5
#define SET_HE_NUM						0
#define SET_SMOKE_NUM					1
#define SET_FLASH_NUM					2
#define SET_DECOY_NUM					3
#define SET_MOLOTOV_NUM					4
#define SET_TAGRENADE_NUM				5
#define MAX_SET_ITEMS					6

/* [ Enums ] */
enum struct Enum_GroupInfo {
	char sName[32];
	char sFlags[16];
	char sTableTag[32];
	char sChatTag[64];
	char sWelcomeChat[256];
	char sWelcomeHud[256];
	char sGoodbyeChat[256];
	char sGoodbyeHud[256];
	int iStats[INTEGER_FIELDS];
	float fStats[FLOAT_FIELDS];
}
enum struct Enum_ClientInfo {
	char sName[MAX_NAME_LENGTH];
	int iStats[CLIENT_MAX_FIELDS];
	char sPrimary[32];
	char sSecondary[32];
	int iGroupId;
	int iGrenadeSet;
	bool bDoubleJump;
	bool bGunMenu;
	
	void Reset() {
		this.sName = "";
		for (int i = 0; i < CLIENT_MAX_FIELDS; i++)
		this.iStats[i] = 0;
		this.iGroupId = 0;
		this.sPrimary = "";
		this.sSecondary = "";
		this.bDoubleJump = true;
		this.bGunMenu = true;
		this.iGrenadeSet = -1;
	}
}
enum struct Enum_PluginInfo {
	int iDeathmatchMode;
	int iDisableBuyHelemet;
	int iGroups;
	int iRound;
	int iHealType;
	int iGrenadeSets;
	bool bChatSystem[2];
	char sMenuTag[64];
	char sChatTag[64];
}
enum struct Enum_GrenadeSetsInfo {
	char sName[64];
	char sFlags[16];
	int iTeam;
	int iAmount[MAX_SET_ITEMS];
}

/* [ Natives & Forwards ] */
/*
 * Pobiera ilość grup dodanych do configu.
 *
 * @return		Ilość grup dodanych do configu
 */
native int pVip_GetGroupsCount();

/*
 * Pobiera informacje o danej grupie
 *
 * @param iGroupId			Index Grupy
 * @param aInfo				Enum_GroupInfo
 * @noreturn
 */
native void pVip_GetGroupInfo(int iGroupId, any aGroup[sizeof(Enum_GroupInfo)]);

/*
 * Pobiera informacje o danym graczu.
 *
 * @param iClient			Index gracza
 * @param aInfo				Enum_ClientInfo
 * @noreturn
 */
native void pVip_GetClientInfo(int iClient, any aGroup[sizeof(Enum_ClientInfo)]);

/*
 * Ustawia grupę gracza.
 *
 * @param iClient			Index gracza
 * @param iGroupId			Index grupy
 * @noreturn
 */
native bool pVip_SetClientGroup(int iClient, int iGroupId);

/*
 * Pobiera wartości przypisane do zmiennych i cvarów z silnika.
 *
 * @param aPlugin			Enum_PluginInfo
 * @noreturn
 */
native void pVip_GetPluginInfo(any aPlugin[sizeof(Enum_PluginInfo)]);

/*
 * Wywołuje funkcję PreparePlayerSetup.
 *
 * @param iClient			Index gracza
 * @return					True w przypadku powodzenia, false w przeciwnym.
 */
native bool pVip_PreparePlayerSetup(int iClient);

/*
 * Włącza / Wyłącza działanie pluginu.
 *
 * @param bEnabled			Status pluginu
 * @noreturn
 */
native void pVip_SetPluginStatus(bool bEnabled);

/*
 * Pobiera status działania pluginu
 *
 * @return		True w przypadku działania, w przeciwnym false.
 */
native bool pVip_GetPluginStatus();

/* 
 * Szuka Id grupy na podstawie flag oraz teamu.
 *
 * @param sFlags		Flagi
 * @param iTeam			Id Teamu (0 - BOTH)
 *
 * @return		W przypadku powodzenia zwróci ID grupy, w przeciwnym -1;
 */
native int pVip_GetGroupIdByFlags(char[] sFlags, int iTeam = 0);
/*
 * Wywołuje się po nadaniu grupy graczowi.
 *
 * @param iClient			Index gracza
 * @param iGroupId			Index grupy
 *
 * @noreturn
 */
forward void pVip_GroupReceived(int iClient, int iGroupId);

/*
 * Wywołuje się po ustaweniu wszystkich bonusów przy spawnie.
 *
 * @param iClient			Index gracza
 *
 * @noreturn
 */
forward void pVip_AfterPlayerSetup(int iClient);

/*
 * Wywołuje się po udanej próbie odrodzenia.
 *
 * @param iClient			Index gracza
 *
 * @noreturn
 */
forward void pVip_Respawned(int iClient);

/*
 * Wywołuje się po załadowaniu configu.
 *
 *
 * @noreturn
 */
forward void pVip_ConfigLoaded(); 