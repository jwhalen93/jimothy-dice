#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Jimothy"
#define PLUGIN_VERSION "0.01"

#include <sourcemod>
#include <sdktools>

#pragma newdecls required

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
	
	char name[MAX_NAME_LENGTH];
	GetClientName(client, name, sizeof(name));
	int dice = GetRandomInt(1, 1);
	PrintToChat(client, "You just rolled %d on the Jimothy Dice!", dice);
	switch(dice)
	{
		case 1:
		{
			IgniteEntity(client, 25.0);
			JdSlapped[client] = true;
			TriggerTimer(TIMER_JDSLAP[client] = CreateTimer(0.1, Timer_Jd_Slap, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE), true);
		}
	}
	return Plugin_Handled;
}

public Action Timer_Jd_Slap(Handle hTimer, int client)
{
	
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