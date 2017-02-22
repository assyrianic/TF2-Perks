#include <sourcemod>
#include <sdktools>
#include <tf2_stocks>
#include <tf2attributes>
#include <clientprefs>

#pragma semicolon		1
#pragma newdecls		required

#define PLUGIN_VERSION		"1.2.0"
#define MXCL			MAXPLAYERS+1

#define int(%1)			view_as<int>(%1)
#define bool(%1)		view_as<bool>(%1)

public Plugin myinfo = {
	name = "TF2 Perks System",
	author = "Nergal/Assyrian",
	description = "Recreates the CoD Perk system for TF2",
	version = PLUGIN_VERSION,
	url = "http://steamcommunity.com/groups/acvsh"
};

//non-cvar Handles
//Handle hCookies[9];

enum {	// PerkTiers
	TierOne = 0,
	TierTwo,
	TierTre
};

enum nPerks {
	NullPerk = -1,
	MoreHealth = 0,			//more standard health
	FasterReload,				//faster weapon reloading for everything - 1
	MoreFirerate,				//faster weapon fire rate - 2
	FasterMovement,			//faster move speed. - 3
	MoreAccuracy,				//increased accuracy on weps - 4
	FasterWepSwitch,			//decreased weapon switch time - 5
	BulletResistance, //6
	BlastResistance, //7
	FireResistance, //8
	MoreJumpHeight, //9
	MoreClipsize, //10
	MoreOverheal,				//only applied to mediguns - 11
	LongerOverheal,			//only applied to mediguns - 12
	MoreCaptureRate, //13
	CancelFallDmg, //14
	HealthRegen, //15
	Parachute,				//attrib -> 640 - 16
	BiDirectionalTele, //17
	ProjectilePenetration,		//attrib -> 266 ; try 397 for single penetrations - 18
	MoreAmmo, //19
	AmmoRegen, //20
	SeeEnemyHealth, //21 - attrib -> 269
	DispenserRadius, //22 - attrib -> 345
	
};
#define nPerks(%1)	view_as<nPerks>(%1) //functional notation style is better :)

/* equipment, weapon and ability
TierOne============================================= - 6 things
Parachute
BiDirectionalTele
MoreAmmo
AmmoRegen
DispenserRadius
==================================================

TierTwo============================================= - 9 things
BulletResistance
BlastResistance
LongerOverheal
MoreOverheal
MoreClipsize
HealthRegen
FasterReload
MoreFirerate
MoreHealth
==================================================

TierTre============================================== - 9 things
ProjectilePenetration
MoreAccuracy
SeeEnemyHealth
FasterMovement
MoreCaptureRate
CancelFallDmg
FireResistance
MoreJumpHeight
FasterWepSwitch
==================================================
*/

/*
custom projectile model attrib -> 675
usage: "model/path/object.mdl"

damage all connected -> 360

*/

//Floats
//float flPerkValue[nPerks];

//Ints
//int iPerkAttribs[nPerks];

nPerks iClientPerks[MXCL][TierTre+1]; // first array = player index, 2nd = perk slot;

//Bools
//bool bCooky[MXCL];

//Strings
char szPerkName[64];
/*
methodmap nPerks
{
	public nPerks(nPerks perk)
	{
		if ( IsValidClient( userid ) ) {
			return view_as< CPerks >(perk);
		}
		return view_as< CPerks >(NullPerk);
	}
};*/
methodmap TF2Perks {
	public TF2Perks(int userid)
	{
		if ( IsValidClient( userid ) ) {
			return view_as< TF2Perks >(GetClientUserId( userid ) );
		}
		return view_as< TF2Perks >( -1 );
	}
	property int index {
		public get()				{ return GetClientOfUserId( int(this) ); }
	}
	/*property bool bCookie
	{
		public get()				{ return bCooky[ this.index ]; }
		public set( bool value )		{ bCooky[ this.index ] = value; }
	}*/
	property nPerks iTierOne {
		public get() {
			return iClientPerks[ this.index ][ TierOne ];
		}
		public set( nPerks value ) {
			iClientPerks[ this.index ][ TierOne ] = value;
		}
	}
	property nPerks iTierTwo {
		public get() {
			return iClientPerks[ this.index ][ TierTwo ];
		}
		public set( nPerks value ) {
			iClientPerks[ this.index ][ TierTwo ] = value;
		}
	}
	property nPerks iTierTre {
		public get() {
			return iClientPerks[ this.index ][ TierTre ];
		}
		public set( nPerks value ) {
			iClientPerks[ this.index ][ TierTre ] = value;
		}
	}
	/*public void StoreCookies()
	{
		if( this.bCookie ) {
			char cookie[64];
			char item[6];
			cookie[0] = '\0';

			for( int i=1 ; i<9 ; i++ ) {
				cookie[0] = '\0';
				for( int d ; d<TierTre+1 ; d++ ) {
					IntToString( int(iClientPerks[this.index][i][d]), item, sizeof(item) );
					StrCat(cookie, sizeof(cookie), item);
					StrCat(cookie, sizeof(cookie), ";");
				}
				SetClientCookie(this.index, hCookies[i], cookie);
			}
		}
	}
	public void RetrieveCookies()
	{
		char cookie[64];
		char fragments[9][9];

		for (int i = 1; i < 9; i++)
		{
			GetClientCookie( this.index, hCookies[i], cookie, sizeof( cookie ) );
			ExplodeString( cookie, ";", fragments, sizeof(fragments), sizeof(fragments[]) );
			for (int d = 0; d < 3; d++)
			{
				iClientPerks[this.index][i][0] = nPerks(StringToInt( fragments[d] ));
				iClientPerks[this.index][i][1] = nPerks(StringToInt( fragments[d+1] ));
				iClientPerks[this.index][i][2] = nPerks(StringToInt( fragments[d+2] ));
			}
		}
		this.bCookie = true;
	}*/
	public void GetCurrPerkName(int tier, char[] buffer, int bufferlen)
	{
		switch (tier) {
			case TierOne: {
				switch (this.iTierOne) {
					case NullPerk:		Format(buffer, bufferlen, "None");
					case Parachute: 	Format(buffer, bufferlen, "Parachute");

					case BiDirectionalTele:	Format(buffer, bufferlen, "Bi-Tele");

					case MoreAmmo:		Format(buffer, bufferlen, "More Ammo");

					case AmmoRegen:		Format(buffer, bufferlen, "Ammo Regen");

					case DispenserRadius:	Format(buffer, bufferlen, "More Dispenser Radius");
				}
			}
			case TierTwo: {
				switch (this.iTierTwo) {
					case NullPerk:		Format(buffer, bufferlen, "None");
					case BulletResistance: 	Format(buffer, bufferlen, "Bullet Resistance");

					case BlastResistance: 	Format(buffer, bufferlen, "Blast Resistance");

					case LongerOverheal: 	Format(buffer, bufferlen, "Longer Overheal");

					case MoreOverheal: 	Format(buffer, bufferlen, "More Overheal");

					case MoreClipsize: 	Format(buffer, bufferlen, "More Clipsize");

					case HealthRegen: 	Format(buffer, bufferlen, "Health Regen");

					case FasterReload: 	Format(buffer, bufferlen, "Faster Reloading");

					case MoreFirerate: 	Format(buffer, bufferlen, "Faster Fire Rate");

					case MoreHealth: 	Format(buffer, bufferlen, "More Max Health");
				}
			}
			case TierTre: {
				switch (this.iTierTre) {
					case NullPerk:		Format(buffer, bufferlen, "None");
					case ProjectilePenetration: 	Format(buffer, bufferlen, "Projectile Penetration");

					case MoreAccuracy: 	Format(buffer, bufferlen, "More Weapon Accuracy");

					case SeeEnemyHealth: 	Format(buffer, bufferlen, "See Enemy Health");

					case FasterMovement: 	Format(buffer, bufferlen, "Faster Move Speed");

					case MoreCaptureRate: 	Format(buffer, bufferlen, "Higher Capture Rate");

					case CancelFallDmg: 	Format(buffer, bufferlen, "Cancel Fall Damage");

					case FireResistance: 	Format(buffer, bufferlen, "Fire Resistance");

					case MoreJumpHeight: 	Format(buffer, bufferlen, "Higher Jump Height");

					case FasterWepSwitch: 	Format(buffer, bufferlen, "Faster Weapon Switch");

				}
			}
		}
	}
	public void ApplyAttributes()
	{
		int classnum = int(TF2_GetPlayerClass(this.index));
		int iAttrib = -1, wep = -1; float flValue = 0.0;
		if (/*this.bCookie && */GetClientTeam(this.index) != 3 && classnum > 0) {
			TF2Attrib_RemoveAll(this.index);
			TF2Attrib_SetByDefIndex(this.index, 57, (GetClientHealth(this.index)/50.0+3.0));
			for ( int i = TierOne; i < TierTre+1; i++ ) {
				switch (i) {
					case TierOne: {
						switch (this.iTierOne) {
							case NullPerk: {}
							case Parachute: {
								iAttrib = 640; flValue = 1.0;
								TF2Attrib_SetByDefIndex(this.index, iAttrib, flValue);
							}
							case BiDirectionalTele: {
								iAttrib = 276; flValue = 1.0;
								TF2Attrib_SetByDefIndex(this.index, iAttrib, flValue);
							}
							case MoreAmmo: {
								iAttrib = 76; flValue = 1.25;
								TF2Attrib_SetByDefIndex(this.index, iAttrib, flValue);
								TF2Attrib_SetByDefIndex(this.index, 78, 1.25);
							}
							case AmmoRegen: {
								iAttrib = 112; flValue = 0.025;
								TF2Attrib_SetByDefIndex(this.index, iAttrib, flValue);
							}
							case DispenserRadius: {
								iAttrib = 345; flValue = 1.25;
								if (classnum == 9) { //engie
									wep = GetPlayerWeaponSlot(this.index, 4);
									if ( wep != -1 )
										TF2Attrib_SetByDefIndex(wep, iAttrib, flValue);
								}
							}
						}
					}
					case TierTwo: {
						switch (this.iTierTwo) {
							case NullPerk: {}
							case BulletResistance: {
								iAttrib = 66; flValue = 0.7;
								TF2Attrib_SetByDefIndex(this.index, iAttrib, flValue);
							}
							case BlastResistance: {
								iAttrib = 64; flValue = 0.7;
								TF2Attrib_SetByDefIndex(this.index, iAttrib, flValue);
							}
							case LongerOverheal: {
								iAttrib = 13; flValue = 1.25;
								if (classnum == 5) { //medic
									wep = GetPlayerWeaponSlot(this.index, TFWeaponSlot_Secondary);
									if ( wep != -1 ) {
										TF2Attrib_SetByDefIndex(wep, iAttrib, flValue);
									}
								}
							}
							case MoreOverheal: {
								iAttrib = 11; flValue = 1.25;
								if (classnum == 5) { //medic
									wep = GetPlayerWeaponSlot(this.index, TFWeaponSlot_Secondary);
									if ( wep != -1 ) {
										TF2Attrib_SetByDefIndex(wep, iAttrib, flValue);
									}
								}
							}
							case MoreClipsize: {
								iAttrib = 335; flValue = 1.25;
								for (int i; i < 3; i++) {
									if ( GetPlayerWeaponSlot(this.index, i) != -1 ) {
										TF2Attrib_SetByDefIndex(i, iAttrib, flValue);
									}
								}
							}
							case HealthRegen: {
								iAttrib = 57; flValue = 10.0;
								TF2Attrib_SetByDefIndex(this.index, iAttrib, flValue);
							}
							case FasterReload: {
								iAttrib = 97; flValue = 0.6;
								TF2Attrib_SetByDefIndex(this.index, iAttrib, flValue);
							}
							case MoreFirerate: {
								iAttrib = 345; flValue = 1.2;
								//TF2Attrib_SetByDefIndex(this.index, iAttrib, flValue);
								for (int i; i < 3; i++) {
									if ( GetPlayerWeaponSlot(this.index, i) != -1 && IsValidEntity(i) ) {
										TF2Attrib_SetByDefIndex(i, iAttrib, flValue);
									}
								}
							}
							case MoreHealth: {
								iAttrib = 26; flValue = 30.0;
								TF2Attrib_SetByDefIndex(this.index, iAttrib, flValue);
							}
						}
					}
					case TierTre: {
						switch (this.iTierTre) {
							case NullPerk: {}
							case ProjectilePenetration: {
								iAttrib = 397; flValue = 4.0;
								for (int i; i < 3; i++) {
									if ( GetPlayerWeaponSlot(this.index, i) != -1 )
										TF2Attrib_SetByDefIndex(i, iAttrib, flValue);
								}
							}
							case MoreAccuracy: {
								iAttrib = 106; flValue = 0.7;
								for (int i; i < 3; i++) {
									if ( GetPlayerWeaponSlot(this.index, i) != -1 && IsValidEntity(i) )
										TF2Attrib_SetByDefIndex(i, iAttrib, flValue);
								}
							}
							case SeeEnemyHealth: {
								iAttrib = 269; flValue = 1.0;
								TF2Attrib_SetByDefIndex(this.index, iAttrib, flValue);
							}
							case FasterMovement: {
								iAttrib = 107; flValue = 1.15;
								TF2Attrib_SetByDefIndex(this.index, iAttrib, flValue);
							}
							case MoreCaptureRate: {
								iAttrib = 68; flValue = 1.0;
								TF2Attrib_SetByDefIndex(this.index, iAttrib, flValue);
							}
							case CancelFallDmg: {
								iAttrib = 275; flValue = 1.0;
								TF2Attrib_SetByDefIndex(this.index, iAttrib, flValue);
							}
							case FireResistance: {
								iAttrib = 60; flValue = 0.7;
								TF2Attrib_SetByDefIndex(this.index, iAttrib, flValue);
							}
							case MoreJumpHeight: {
								iAttrib = 326; flValue = 1.2;
								TF2Attrib_SetByDefIndex(this.index, iAttrib, flValue);
							}
							case FasterWepSwitch: {
								iAttrib = 178; flValue = 0.7;
								TF2Attrib_SetByDefIndex(this.index, iAttrib, flValue);
							}
						}
					}
				}
			}
			TF2_AddCondition(this.index, TFCond_SpeedBuffAlly, 0.01);
		}
	}
};

////////////////////////////////////////////////
////////// P L U G I N  S T U F F Z ////////////
////////////////////////////////////////////////
public void OnPluginStart()
{
        RegConsoleCmd("sm_perks", PerksMenu, "Perks menu");
        RegConsoleCmd("sm_perk", PerksMenu, "Perks menu");

	HookEvent("post_inventory_application", PlayerSpawn);
	HookEvent("player_spawn", PlayerSpawn);

	/*hCookies[0] = RegClientCookie("tf2perks_cookie_scout", "", CookieAccess_Private);
	hCookies[1] = RegClientCookie("tf2perks_cookie_sniper", "", CookieAccess_Private);
	hCookies[2] = RegClientCookie("tf2perks_cookie_soldier", "", CookieAccess_Private);
	hCookies[3] = RegClientCookie("tf2perks_cookie_demo", "", CookieAccess_Private);
	hCookies[4] = RegClientCookie("tf2perks_cookie_medic", "", CookieAccess_Private);
	hCookies[5] = RegClientCookie("tf2perks_cookie_heavy", "", CookieAccess_Private);
	hCookies[6] = RegClientCookie("tf2perks_cookie_pyro", "", CookieAccess_Private);
	hCookies[7] = RegClientCookie("tf2perks_cookie_spy", "", CookieAccess_Private);
	hCookies[8] = RegClientCookie("tf2perks_cookie_engineer", "", CookieAccess_Private);*/

	for (int i = 1; i <= MaxClients; i++) {
		if (!IsValidClient(i))
			continue;
		OnClientConnected(i);
	}
}
public void OnClientConnected(int client)
{
	TF2Perks player = TF2Perks(client);

	player.iTierOne = NullPerk;
	player.iTierTwo = NullPerk;
	player.iTierTre = NullPerk;

	/*player.bCookie = false;
	if ( IsClientInGame(client) ) {
		player.RetrieveCookies();
	}*/
}
public void OnClientDisconnect(int client)
{
	//TF2Perks player = TF2Perks(client);
	//player.bCookie = false;
	//player.StoreCookies();
}

public Action PerksMenu(int client, int args)
{
	if ( IsClientInGame(client) ) {
		if (args == 1) {
			char argone[8]; GetCmdArg(1, argone, sizeof(argone));
			TF2Perks player = TF2Perks(client);
			if ( StrContains(argone, "one") != -1 || StrContains(argone, "1") != -1 ) {
				PerkOneMenu(player);
			}
			else if ( StrContains(argone, "two") != -1 || StrContains(argone, "2") != -1 ) {
				PerkTwoMenu(player);
			}
			else if ( StrContains(argone, "three") != -1 || StrContains(argone, "3") != -1 ) {
				PerkTreMenu(player);
			}
			else {
				ReplyToCommand(client, "[TF2-Perks] Usage: sm_perks <1, 2, or 3>");
			}
		}
		else if (args > 1) {
			char argone[32]; GetCmdArg(1, argone, sizeof(argone));
			TF2Perks player = TF2Perks(client);
			if ( StrContains(argone, "one") != -1 || StrContains(argone, "1") != -1 ) {
				GetCmdArg(2, argone, sizeof(argone));
				for ( nPerks i = MoreHealth; i < nPerks; i++ ) {
					GetPerkNames( i, szPerkName, sizeof(szPerkName) );
					if (StrContains(argone, szPerkName, false) != -1) {
						player.iTierOne = i;
					}
				}
			}
			else if ( StrContains(argone, "two") != -1 || StrContains(argone, "2") != -1 )
			{
				GetCmdArg(2, argone, sizeof(argone));
				for ( nPerks i = MoreHealth; i < nPerks; i++ ) {
					GetPerkNames( i, szPerkName, sizeof(szPerkName) );
					if (StrContains(argone, szPerkName, false) != -1) {
						player.iTierTwo = i;
					}
				}
			}
			else if ( StrContains(argone, "three") != -1 || StrContains(argone, "3") != -1 )
			{
				GetCmdArg(2, argone, sizeof(argone));
				for ( nPerks i = MoreHealth; i < nPerks; i++ ) {
					GetPerkNames( i, szPerkName, sizeof(szPerkName) );
					if (StrContains(argone, szPerkName, false) != -1) {
						player.iTierTre = i;
					}
				}
			}
		}
		else {
			Menu perksmenu = new Menu(MenuHandler_Perks);
			perksmenu.SetTitle("[TF2-Perks] Choose Your Perks");
			perksmenu.AddItem("1", "Tier 1 Perks");
			perksmenu.AddItem("2", "Tier 2 Perks");
			perksmenu.AddItem("3", "Tier 3 Perks");
			perksmenu.Display(client, MENU_TIME_FOREVER);
		}
	}
	return Plugin_Handled;
}
public int MenuHandler_Perks(Menu menu, MenuAction action, int client, int selection)
{
	char info[4]; menu.GetItem(selection, info, sizeof(info));
	if (action == MenuAction_Select) {
		TF2Perks player = TF2Perks(client);
		switch (selection) {
			case 0: PerkOneMenu(player);
			case 1: PerkTwoMenu(player);
			case 2: PerkTreMenu(player);
		}
		player.ApplyAttributes();
	}
	else if (action == MenuAction_End)
		delete menu;	
}
void PerkOneMenu(TF2Perks player)
{
	Menu tierone = new Menu(MenuHandler_PerkOne);
	player.GetCurrPerkName( TierOne, szPerkName, sizeof(szPerkName) );
	tierone.SetTitle( "Tier 1 Perks | Equipment -Current Perk: %s", szPerkName );

	nPerks perkone[] = { /*Parachute, */BiDirectionalTele, MoreAmmo, AmmoRegen, DispenserRadius };
	char numstr[8];

	for ( int i; i < sizeof(perkone); i++ ) {
		GetPerkNames( perkone[i], szPerkName, sizeof(szPerkName) );
		IntToString(int(perkone[i]), numstr, sizeof(numstr));
		tierone.AddItem(numstr, szPerkName);
	}

	tierone.Display(player.index, MENU_TIME_FOREVER);
}
void PerkTwoMenu(TF2Perks player)
{
	Menu tiertwo = new Menu(MenuHandler_PerkTwo);
	player.GetCurrPerkName( TierTwo, szPerkName, sizeof(szPerkName) );
	tiertwo.SetTitle( "Tier 2 Perks | Weapon -Current Perk: %s", szPerkName );

	nPerks perktwo[] = { BulletResistance, BlastResistance, LongerOverheal, MoreOverheal, MoreClipsize,/* HealthRegen, */FasterReload, MoreFirerate, MoreHealth };
	char numstr[8];

	for ( int i; i < sizeof(perktwo); i++ ) {
		GetPerkNames( perktwo[i], szPerkName, sizeof(szPerkName) );
		IntToString(int(perktwo[i]), numstr, sizeof(numstr));
		tiertwo.AddItem(numstr, szPerkName);
	}

	tiertwo.Display(player.index, MENU_TIME_FOREVER);
}
void PerkTreMenu(TF2Perks player)
{
	Menu tiertre = new Menu(MenuHandler_PerkTre);
	player.GetCurrPerkName( TierTre, szPerkName, sizeof(szPerkName) );
	tiertre.SetTitle("Tier 3 Perks | Ability -Current Perk: %s", szPerkName);

	nPerks perktre[] = { ProjectilePenetration, MoreAccuracy, SeeEnemyHealth, FasterMovement, MoreCaptureRate, CancelFallDmg, FireResistance, MoreJumpHeight, FasterWepSwitch };
	char numstr[8];

	for ( int i; i < sizeof(perktre); i++ ) {
		GetPerkNames( perktre[i], szPerkName, sizeof(szPerkName) );
		IntToString(int(perktre[i]), numstr, sizeof(numstr));
		tiertre.AddItem(numstr, szPerkName);
	}

	tiertre.Display(player.index, MENU_TIME_FOREVER);
}
public int MenuHandler_PerkOne(Menu menu, MenuAction action, int client, int select)
{
	char info1[16]; menu.GetItem(select, info1, sizeof(info1));
        if (action == MenuAction_Select) {
		TF2Perks player = TF2Perks(client);
		player.iTierOne = nPerks( StringToInt(info1) );
		//player.StoreCookies();
		player.ApplyAttributes();

		player.GetCurrPerkName( TierOne, szPerkName, sizeof(szPerkName) );
		ReplyToCommand(client, "[TF2-Perks] %s is your Equipment Perk", szPerkName);
		PerksMenu(client, -1);
        }
	else if (action == MenuAction_Cancel) {
		switch (select) {
			case MenuCancel_ExitBack: PerksMenu(client, -1);
		}
	}
        else if (action == MenuAction_End)
		delete menu;
}
public int MenuHandler_PerkTwo(Menu menu, MenuAction action, int client, int select)
{
	char info2[16]; menu.GetItem(select, info2, sizeof(info2));
	if (action == MenuAction_Select) {
		TF2Perks player = TF2Perks(client);
		player.iTierTwo = nPerks( StringToInt(info2) );
		//player.StoreCookies();
		player.ApplyAttributes();

		player.GetCurrPerkName( TierTwo, szPerkName, sizeof(szPerkName) );
		ReplyToCommand(client, "[TF2-Perks] %s is your Tier 2 Perk", szPerkName);
		PerksMenu(client, -1);
        }
	else if (action == MenuAction_Cancel) {
		switch (select) {
			case MenuCancel_ExitBack: PerksMenu(client, -1);
		}
	}
	else if (action == MenuAction_End)
		delete menu;
}
public int MenuHandler_PerkTre(Menu menu, MenuAction action, int client, int select)
{
	char info3[16]; menu.GetItem(select, info3, sizeof(info3));
	if (action == MenuAction_Select) {
		TF2Perks player = TF2Perks(client);
		player.iTierTre = nPerks( StringToInt(info3) );
		//player.StoreCookies();
		player.ApplyAttributes();

		player.GetCurrPerkName( TierTre, szPerkName, sizeof(szPerkName) );
		ReplyToCommand(client, "[TF2-Perks] %s is your Tier 3 Perk", szPerkName);
		PerksMenu(client, -1);
        }
	else if (action == MenuAction_Cancel) {
		switch (select)
		{
			case MenuCancel_ExitBack: PerksMenu(client, -1);
		}
	}
	else if (action == MenuAction_End) {
		delete menu;
	}
}
/*
char bit[4][64] = "It Is Bbout Future";

ExplodeString( YOURSTRING, " ", bit, sizeof(bit), sizeof(bit[]) );

bit[0] = It
bit[1] = Is
bit[2] = About
bit[3] = Future

*/
public void OnClientCookiesCached(int client)
{
	if (IsClientInGame(client)) {
		TF2Perks player = TF2Perks(client);
		//player.RetrieveCookies();
		player.ApplyAttributes();
	}
}
void GetPerkNames(nPerks num, char[] buffer, int bufferlen)
{
	switch (num) {
		case Parachute: 	Format(buffer, bufferlen, "Parachute");
		case BiDirectionalTele:	Format(buffer, bufferlen, "Bi-Tele");
		case MoreAmmo:		Format(buffer, bufferlen, "More Ammo");
		case AmmoRegen:		Format(buffer, bufferlen, "Ammo Regen");
		case DispenserRadius:	Format(buffer, bufferlen, "More Dispenser Radius");
		case BulletResistance: 	Format(buffer, bufferlen, "Bullet Resistance");
		case BlastResistance: 	Format(buffer, bufferlen, "Blast Resistance");
		case LongerOverheal: 	Format(buffer, bufferlen, "Longer Overheal");
		case MoreOverheal: 	Format(buffer, bufferlen, "More Overheal");
		case MoreClipsize: 	Format(buffer, bufferlen, "More Clipsize");
		case HealthRegen: 	Format(buffer, bufferlen, "Health Regen");
		case FasterReload: 	Format(buffer, bufferlen, "Faster Reloading");
		case MoreFirerate: 	Format(buffer, bufferlen, "Faster Fire Rate");
		case MoreHealth: 	Format(buffer, bufferlen, "More Max Health");
		case ProjectilePenetration: 	Format(buffer, bufferlen, "Projectile Penetration");
		case MoreAccuracy: 	Format(buffer, bufferlen, "More Weapon Accuracy");
		case SeeEnemyHealth: 	Format(buffer, bufferlen, "See Enemy Health");
		case FasterMovement: 	Format(buffer, bufferlen, "Faster Move Speed");
		case MoreCaptureRate: 	Format(buffer, bufferlen, "Higher Capture Rate");
		case CancelFallDmg: 	Format(buffer, bufferlen, "Cancel Fall Damage");
		case FireResistance: 	Format(buffer, bufferlen, "Fire Resistance");
		case MoreJumpHeight: 	Format(buffer, bufferlen, "Higher Jump Height");
		case FasterWepSwitch: 	Format(buffer, bufferlen, "Faster Weapon Switch");
	}
}
public Action PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId( event.GetInt("userid") );
	TF2Perks player = TF2Perks(client);

	/*if ( !player.bCookie )
	{
		if ( AreClientCookiesCached(client) ) player.RetrieveCookies();
		else ReplyToCommand(client, "[TF2-Perks] The Server hasn't retrieved your Perks yet.");
	}*/
	player.ApplyAttributes();

	static bool bSpawn[MXCL][10];
	int num = int(TF2_GetPlayerClass(client));

	if ( num && !bSpawn[client][num] )
	{
		PerksMenu(client, -1);
		bSpawn[client][num] = true;
	}
	else if ( !GetRandomInt(0, 4) )
		PerksMenu(client, -1);

	return Plugin_Continue;
}
stock bool IsValidClient(int iClient, bool bReplay = true)
{
	if (iClient <= 0 || iClient > MaxClients) return false;
	else if (!IsClientInGame(iClient)) return false;
	else if (bReplay && (IsClientSourceTV(iClient) || IsClientReplay(iClient))) return false;
	return true;
}
