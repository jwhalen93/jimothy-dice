#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Jimothy"
#define PLUGIN_VERSION "0.01"

#include <sourcemod>
#include <sdktools>

#pragma newdecls required

#define JD_MENU_TITLE "Jimothy Dice"
#define ROLL_MENU_ITEM "roll"
#define ROLL_MENU_ITEM_DISPLAY "Roll"

Handle TIMER_JDSLAP[MAXPLAYERS+1] = INVALID_HANDLE;
bool JdSlapped[MAXPLAYERS+1];

public Plugin myinfo = 
{
	name = "Jimothy Dice",
	author = PLUGIN_AUTHOR,
	description = "Rolls the Jimothy dice",
	version = PLUGIN_VERSION,
	url = "https://www.youtube.com/watch?v=U_cPir6MwLM"
};


public void OnPluginStart()
{
	RegConsoleCmd("sm_jimothydice", Jimothy_Dice, "Roll the Jimothy Dice!");
	RegConsoleCmd("sm_jd", Jimothy_Dice, "Roll the Jimothy Dice!");
	RegConsoleCmd("sm_jdmenu", Jimothy_Dice_Menu, "Jimothy Dice Menu");
	
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
}

public Action Jimothy_Dice(int client, int args){
	if(!client)
	{
		ReplyToCommand(client, "Console cannot roll Jimothy Dice!");
		return Plugin_Handled;
	}
	
	if (args > 0)
	{
		ReplyToCommand(client, "Jimothy Dice takes no params!!.");
		SlapPlayer(client, 1000, true);
		return Plugin_Handled;
	}
	
	int dice = GetRandomInt(1, 2);
	PrintToChat(client, "You just rolled %d on the Jimothy Dice!", dice);
	switch(dice)
	{
		case 1:
		{
			Burning_Hammer(client);
		}
		case 2:
		{
			PrintToChat(client,"TODO: implement 2");
		}
	}
	return Plugin_Handled;
}

public void Burning_Hammer(int client)
{
	IgniteEntity(client, 25.0);
	JdSlapped[client] = true;
	TriggerTimer(TIMER_JDSLAP[client] = CreateTimer(0.1, Timer_Jd_Slap, GetClientUserId(client), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE), true);
}
public Action Timer_Jd_Slap(Handle hTimer, int userId)
{
	int client = GetClientOfUserId(userId);
	
	if(client == 0)
		return Plugin_Stop;

	else if(!JdSlapped[client])
	{
		TIMER_JDSLAP[client] = INVALID_HANDLE;
		return Plugin_Stop;
	}
		
	if(!IsClientInGame(client) || !IsPlayerAlive(client) || !SlapPlayer(client, 1, true))
	{
		JdSlapped[client] = false;
		TIMER_JDSLAP[client] = INVALID_HANDLE;
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public void OnClientDisconnect(int client)
{
	ResetVariables(client);
}

public void OnClientDisconnect_Post(int client)
{
	ResetVariables(client);
	JdSlapped[client] = false;
}

public void OnMapStart()
{
	for(int i=1;i < MAXPLAYERS+1;i++)
	{
		TIMER_JDSLAP[i] = INVALID_HANDLE;
	}
}

void ResetVariables(int client)
{
	if (TIMER_JDSLAP[client] != INVALID_HANDLE)
	{
		CloseHandle(TIMER_JDSLAP[client]);
		TIMER_JDSLAP[client] = INVALID_HANDLE;
	}
}

public void OnClientPutInServer(int client)
{
	JdSlapped[client] = false;
}

public Action Jimothy_Dice_Menu(int client, int args) 
{
	Menu menu = new Menu(Menu_Callback);
	menu.SetTitle(JD_MENU_TITLE);
	menu.AddItem(ROLL_MENU_ITEM, ROLL_MENU_ITEM_DISPLAY);
	menu.Display(client, 30);
	return Plugin_Handled;
}

public int Menu_Callback(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char item[32];
			menu.GetItem(param2, item, sizeof(item));
			if (StrEqual(item,ROLL_MENU_ITEM))
			{
				Jimothy_Dice(param1, 0);
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

public Action Event_PlayerSpawn(Handle hEvent, const char[] Name, bool dontBroadcast)
{	
	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	
	JdSlapped[client] = false;
	if(TIMER_JDSLAP[client] != INVALID_HANDLE)
	{
		CloseHandle(TIMER_JDSLAP[client]);
		TIMER_JDSLAP[client] = INVALID_HANDLE;
	}
}

public Action Event_PlayerDeath(Handle hEvent, const char[] Name, bool dontBroadcast)
{	
	int clientUserId = GetEventInt(hEvent, "userid");
	
	int client = GetClientOfUserId(clientUserId);

	if(client == 0)
		return;

	JdSlapped[client] = false;
	if(TIMER_JDSLAP[client] != INVALID_HANDLE)
	{
		CloseHandle(TIMER_JDSLAP[client]);
		TIMER_JDSLAP[client] = INVALID_HANDLE;
	}
}