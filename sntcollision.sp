#include <sourcemod>
#include <sdkhooks>

public Plugin:myinfo =
{
	name = "SNT Collision Plugin",
	author = "Arcala the Gyiyg",
	description = "When two enemy players collide, checks their speeds ",
	version = "1.0.1",
	url = "N/A"
}

public Action Event_OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    if (IsPlayerAlive(client))
    {
        SDKHook(client, SDKHook_StartTouch, Hook_StartTouch);
    }
    return Plugin_Continue;
}

public void OnPluginStart()
{
    HookEvent("player_spawn", Event_OnPlayerSpawn);
}

public void OnClientDisconnect(int client)
{
    SDKUnhook(client, SDKHook_StartTouch, Hook_StartTouch);
}

public Action Hook_StartTouch(int client, int other)
{
    float _fClient1Vecs[3];
    float _fClient2Vecs[3];
    float _fClient1Velocity;
    float _fClient2Velocity;
    float _fAvgVelocity;
    float _fVelocityDiff;
    
    if (other < MaxClients && other > 0)
    {
        int _iClient1Health;
        int _iClient2Health;

        _iClient1Health = GetClientHealth(client);
        _iClient2Health = GetClientHealth(other);

        GetEntPropVector(client, Prop_Data, "m_vecVelocity", _fClient1Vecs);
        GetEntPropVector(other, Prop_Data, "m_vecVelocity", _fClient2Vecs);

        for(new i = 0; i <= 2; i++)
        {
            _fClient1Vecs[i] *= _fClient1Vecs[i];
            _fClient2Vecs[i] *= _fClient2Vecs[i];
        }

        _fClient1Velocity = SquareRoot(_fClient1Vecs[0] + _fClient1Vecs[1] + _fClient1Vecs[2]);
        _fClient2Velocity = SquareRoot(_fClient2Vecs[0] + _fClient2Vecs[1] + _fClient2Vecs[2]);
        _fAvgVelocity = ((_fClient1Velocity + _fClient2Velocity)/2)

        if (_fAvgVelocity > 800)
        {
            if (_fClient1Velocity == 0) {
                _fClient1Velocity = 50.0;
            }
            else if (_fClient2Velocity == 0) {
                _fClient2Velocity = 50.0;
            }
            if (_fClient1Velocity > _fClient2Velocity)
            {
                _fVelocityDiff = (_fClient2Velocity/_fClient1Velocity);
                float _fClient2Health = float(_iClient2Health);
                SDKHooks_TakeDamage(other, client, client, (_fClient2Health * _fVelocityDiff), DMG_VEHICLE, -1);
            }
            else if (_fClient1Velocity < _fClient2Velocity)
            {
                _fVelocityDiff = (_fClient1Velocity/_fClient2Velocity);
                float _fClient1Health = float(_iClient1Health);
                SDKHooks_TakeDamage(client, other, other, (_fClient1Health * _fVelocityDiff), DMG_VEHICLE, -1);
            }
        }
    }
    return Plugin_Handled;
}