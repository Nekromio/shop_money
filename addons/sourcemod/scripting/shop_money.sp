#pragma semicolon 1
#pragma newdecls required

#include <shop>

ConVar
	cvCash;

bool
	bCashClient[MAXPLAYERS+1];

int
	g_iAccount;

CategoryId
	gcategory_id;

ItemId
	g_iID;

public Plugin myinfo =
{
	name = "[Shop Core] Money",
	author = "Nek.'a 2x2",
	version = "1.0.1",
	url = "https://ggwp.site/"
};

public void OnPluginStart()
{
	g_iAccount = FindSendPropInfo("CCSPlayer", "m_iAccount");

    if(Shop_IsStarted()) Shop_Started();

	AutoExecConfig(true, "money", "shop");

	HookEvent("player_spawn", EventPlayerSpawn);
}

public void Shop_Started()
{
    gcategory_id = Shop_RegisterCategory("ability", "Способности", "");
	if(gcategory_id == INVALID_CATEGORY) SetFailState("Failed to register category");

    if (Shop_StartItem(gcategory_id, "money"))
    {
		ConVar cvar[3];
		cvCash = CreateConVar("sm_shop_money_count", "16000", "Сколько денег будет выдано?");
		(cvar[0] = CreateConVar("sm_shop_money_price", "450", "Цена покупки.", _, true, 0.0)).AddChangeHook(ChangeCvar_Buy);
		(cvar[1] = CreateConVar("sm_shop_money_sell_price", "200", "Цена продажи.", _, true, 0.0)).AddChangeHook(ChangeCvar_Sell);
		(cvar[2] = CreateConVar("sm_shop_money_time", "86400", "Время действия покупки в секундах.", _, true, 0.0)).AddChangeHook(ChangeCvar_Time);
	
		Shop_SetInfo("money", "Наличные", cvar[0].IntValue, cvar[1].IntValue, Item_Togglable, cvar[2].IntValue);
		Shop_SetCallbacks(OnItemRegistered, OnEquipItem);
		Shop_EndItem();
    }
}

public void ChangeCvar_Buy(ConVar convar, const char[] oldValue, const char[] newValue)
{
	Shop_SetItemPrice(g_iID, convar.IntValue);
}

public void ChangeCvar_Sell(ConVar convar, const char[] oldValue, const char[] newValue)
{
	Shop_SetItemSellPrice(g_iID, convar.IntValue);
}

public void ChangeCvar_Time(ConVar convar, const char[] oldValue, const char[] newValue)
{
	Shop_SetItemValue(g_iID, convar.IntValue);
}

public void OnPluginEnd()
{
	Shop_UnregisterMe();
}

public void OnItemRegistered(CategoryId category_id, const char[] sCategory, const char[] sItem, ItemId item_id)
{
	g_iID = item_id;
}

public ShopAction OnEquipItem(int client, CategoryId category_id, const char[] sCategory, ItemId item_id, const char[] sItem, bool isOn, bool elapsed)
{
	if (isOn || elapsed)
	{
		bCashClient[client] = false;
		return Shop_UseOff;
	}

	bCashClient[client] = true;
	return Shop_UseOn;
}

void EventPlayerSpawn(Event hEvent, const char[] sEvent, bool db)
{
	int client = GetClientOfUserId(hEvent.GetInt("userid"));
	if(IsFakeClient(client) || !bCashClient[client])
		return;
	SetMoney(client, cvCash.IntValue);
}

void SetMoney(int client, int amount)
{
	if (g_iAccount != -1)
	{
		SetEntData(client, g_iAccount, amount);
	}	
}