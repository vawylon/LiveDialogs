#include <open.mp>
#include <LiveDialogs>

#define START_CASH 			1000
#define MAX_SIZE_PASSWORD 	64
#define MAX_SIZE_EMAIL		32

new MySQL:mysql;

enum player_data {
	pMysqlID,
	pPassword[MAX_SIZE_PASSWORD],
	pNickName[MAX_PLAYER_NAME],
	pEmail[MAX_SIZE_EMAIL],
	pMoney
}
new LoginUnique[MAX_PLAYERS];
new pData[MAX_PLAYERS][player_data];
new const player_reset[player_data];

main()
{
	printf(" ");
	printf("  -------------------------------");
	printf("  |  LiveDialogs Test! 			|");
	printf("  -------------------------------");
	
	printf(" ");
}

/*
CREATE TABLE `accounts` (
	`pMysqlID` INT(11) NOT NULL AUTO_INCREMENT,
	`pNickName` CHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`pPassword` CHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`pMoney` INT(11) NULL DEFAULT '0',
	`pEmail` CHAR(32) NULL DEFAULT '' COLLATE 'utf8mb4_general_ci',
	UNIQUE INDEX `pNickName` (`pNickName`) USING BTREE,
	INDEX `pMysqlID` (`pMysqlID`) USING BTREE
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=3
;
*/
public OnGameModeInit()
{
	mysql = mysql_connect("localhost", "root", "", "data");
	if(!mysql)
	{
		print("Mysql fall connect!");
	}
	else
	{
		print("Mysql successful connect!");
	}
	SetGameModeText("Live Dialogs Test!");
	AddStaticVehicle(522, 2493.7583, -1683.6482, 12.9099, 270.8069, -1, -1);
	return 1;
}

public OnPlayerConnect(playerid)
{
	LoginUnique[playerid] ++;
	new query[124];
	GetPlayerName(playerid, pData[playerid][pNickName], MAX_PLAYER_NAME);
	mysql_format(mysql, query, sizeof query, "SELECT * FROM `accounts` WHERE `pNickName` = '%e'", pData[playerid][pNickName]);
	mysql_tquery(mysql, query, "OnLoadAccount", "dd", playerid, LoginUnique[playerid]);
	print(query);
	return 1;
}

forward OnLoadAccount(playerid, unique);
public OnLoadAccount(playerid, unique)
{
	if(LoginUnique[playerid] != unique) 
	{
		Kick(playerid);
		return;	
	}
	if(cache_num_rows()) 
	{
		cache_get_value_name_int(0, "pMysqlID", pData[playerid][pMysqlID]);
		cache_get_value_name(0, "pPassword", pData[playerid][pPassword]);
	}
	Dialog_Create(playerid, Dialog:Autorization);
}

dialog Autorization(playerid)
{
	SetPlayerPos(playerid, 217.8511, -98.4865, 1005.2578);
	SetPlayerFacingAngle(playerid, 113.8861);
	SetPlayerInterior(playerid, 15);
	SetPlayerCameraPos(playerid, 215.2182, -99.5546, 1006.4);
	SetPlayerCameraLookAt(playerid, 217.8511, -98.4865, 1005.2578);
	ApplyAnimation(playerid, "benchpress", "gym_bp_celebrate", 4.1, true, false, false, false, 0, SYNC_NONE);
	SetPlayerVirtualWorld(playerid, 1 + playerid);
	
	if(pData[playerid][pMysqlID])
	{
		TogglePlayerControllable(playerid, false);
		Create:<"�����������">
		{
			InputPassword:<"������� ������:">
			{
				new password[MAX_SIZE_PASSWORD];
				Dialog_Text(playerid, password);
				
				if(password[0] == EOS || pData[playerid][pPassword][0] == EOS) 
				{
					return DIALOG_REOPEN;			
				}
				if (strcmp(pData[playerid][pPassword], password )) 
				{
					Dialog_SetValue(playerid, 0, Dialog_GetValue(playerid, 0) + 1);
					if(Dialog_GetValue(playerid, 0) >= 3) 
					{
						Kick(playerid);
						return DIALOG_CLOSE;
					}
					SendClientMessage(playerid, -1, "������ �� ������. ������� %d / 3!", Dialog_GetValue(playerid, 0));
					return DIALOG_REOPEN;
				}
				TogglePlayerControllable(playerid, true);
				SpawnPlayer(playerid);
				return DIALOG_CLOSE;
			}
			else
			{
				return DIALOG_REOPEN;
			}
		}
		Button:<"�����">;
	}
	else
	{
		Create:<"�����������">
		{
			ResponseRight:return DIALOG_REOPEN;
			Input:<"������� ������ ������� �� 4 - "#MAX_SIZE_PASSWORD"� ��������">
			{
				new password[MAX_SIZE_PASSWORD];
				Dialog_Text(playerid, password);
				if(!(4 <= strlen(password) <= 64))
				{
					SendClientMessage(playerid, -1, "������ ������ ������ ���� �� 4 �� 64� ��������!");
					return DIALOG_REOPEN;
				}
				Create:<"�����������">
				{
					ResponseRight:return DIALOG_REOPEN;
					if(pData[playerid][pMysqlID] == 0) 
					{
						new query_addaccount[256];
						format(query_addaccount, sizeof query_addaccount, "INSERT INTO `accounts` (`pNickName`, `pPassword`, `pMoney`) VALUES ('%s', '%s', "#START_CASH");", 
							pData[playerid][pNickName], 
							password
						);
							
						DialogQuery:<mysql, query_addaccount>;
						
						pData[playerid][pMysqlID] = cache_insert_id();
						pData[playerid][pMoney] = START_CASH;
						format(pData[playerid][pPassword], MAX_SIZE_PASSWORD, "%s", password);
					}
					Input:<"������� ����� ����������� �����">
					{
						new email[MAX_SIZE_EMAIL];
						Dialog_Text(playerid, email);
						
						if(!(4 <= strlen(email) <= MAX_SIZE_EMAIL))
						{
							SendClientMessage(playerid, -1, "������� �� 4 �� "#MAX_SIZE_EMAIL"� ��������!");
							return DIALOG_REOPEN;
						}
						
						format(pData[playerid][pEmail], MAX_SIZE_EMAIL, "%s", email);					
						
						new query_updateemail[256];
						mysql_format(mysql, query_updateemail, sizeof query_updateemail, "UPDATE `accounts` SET `pEmail` = '%e' WHERE `pMysqlID` = %d", email, pData[playerid][pMysqlID]);
						mysql_tquery(mysql, query_updateemail);
						SpawnPlayer(playerid);
						return DIALOG_CLOSE;
					}
				}
				Button:<"�����">;
			}
		}
		Button:<"�����">;
	}
}

public OnPlayerDisconnect(playerid, reason)
{
	pData[playerid] = player_reset;
	return 1;
}
public OnPlayerSpawn(playerid)
{
	if(pData[playerid][pMysqlID] == 0) {
		return 0;	
	}
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerPos(playerid, 2495.3547, -1688.2319, 13.6774);
	SetPlayerFacingAngle(playerid, 351.1646);
	SetPlayerInterior(playerid, 0);
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if(!strcmp(cmdtext, "/menu"))
	{
		Dialog_Create(playerid, Dialog:Menu);
		return 1;
	}
	if(!strcmp(cmdtext, "/livedialogs"))
	{
		Dialog_Create(playerid, Dialog:Main);
		return 1;
	}
	if(!strcmp(cmdtext, "/deep"))
	{
		Dialog_Create(playerid, Dialog:Deep);
		return 1;
	}
	if(!strcmp(cmdtext, "/deleteaccount"))
	{
		Dialog_Create(playerid, Dialog:DeleteAccount);
	}
	return 0;
}

dialog Menu(playerid)
{
	Create:<"����">
	{
		ResponseRight:return DIALOG_CLOSE;
		ListItem:<"������ �����">
		{
			Create:<"������ �����">
			{
				ResponseRight:return DIALOG_BACK;
				Input:<"������� ���-�� �����">
				{
					new money = Dialog_Number(playerid);
					if(money < 1) {
						SendClientMessage(playerid, -1, "������� �� 1$");
						return DIALOG_REOPEN;			
					}
					GivePlayerMoney(playerid, money);
					return DIALOG_MAIN;
				}
			}
			Button:<"������", "�����">;
		}
		ListItem:<"���������� ������� �������">
		{
			ResponseRight:return DIALOG_BACK;
			Create:<"������� �������">
			{
				ResponseRight:return DIALOG_BACK;
				new str[92];
				for(new level; level<6; level++)
				{
					DialogRender:
					{
						if(level == 0)
						{
							format(str, sizeof str, "����� ������");
						}
						else
						{
							format(str, sizeof str, "%d �������", level);
						}
					}
					ListItem:<str>
					{
						SendClientMessage(playerid, -1, "���������� {FFCC00}%d ������� �������", level);
						SetPlayerWantedLevel(playerid, level);
						return DIALOG_BACK;
					}
				}
			}
			Button:<"����������", "�����">;
		}
		ListItem:<"������ ������">
		{
			static WEAPON:weapons[] = {WEAPON_M4, WEAPON_AK47, WEAPON_DEAGLE};
			Create:<"������">
			{
				ResponseRight:return DIALOG_BACK;
				new weaponname[32 char];
				for(new i; i<sizeof weapons; i++)
				{
					DialogRender:GetWeaponName(weapons[i], weaponname);
					ListItem:<weaponname>
					{
						Create:<"�������">
						{
							ResponseRight:return DIALOG_BACK;
							Input:<"������� ���-�� ������:">
							{
								new ammo = Dialog_Number(playerid);
								if(ammo <= 0) {
									SendClientMessage(playerid, -1, "������� ����� 1");
									return DIALOG_REOPEN;								
								}
								if(ammo >= 5_000) {
									SendClientMessage(playerid, -1, "������� �� ����� 5.000");
									return DIALOG_REOPEN;
								}
								GetWeaponName(weapons[i], weaponname);
								SendClientMessage(playerid, -1, "������ %s � %d ��������� ������!", weaponname, ammo);
								GivePlayerWeapon(playerid, weapons[i], ammo);
								return DIALOG_MAIN;
							}
						}
						Button:<"������", "�����">;
					}
				}
			}
			Button:<"�������", "�����">;
		}
		ListItem:<"���������� ����">
		{
			Create:<"����">
			{
				ResponseRight:return DIALOG_BACK;
				new skin = GetPlayerSkin(playerid);
				new str[64];
				for(new skinid = Dialog_GetValue(playerid, 0); skinid < Dialog_GetValue(playerid, 0) + 15; skinid++)
				{
					if(skinid > 311)
					{
						break;
					}
					DialogRender:
					{
						if(skin == skinid)
						{
							format(str, sizeof str, "{66ff66}%d ����", skinid);
						}
						else
						{
							format(str, sizeof str, "%d ����", skinid);
						}
					}
					ListItem:<str>
					{
						SetPlayerSkin(playerid, skinid);
						SendClientMessage(playerid, -1, "���������� {FFCC47}%d ����", skinid);
						return DIALOG_MAIN;
					}				
				}
				if(Dialog_GetValue(playerid, 0)+15 < 311)
				{
					ListItem:<"����� >>">
					{
						Dialog_SetValue(playerid, 0, Dialog_GetValue(playerid, 0) + 15);
						return DIALOG_REOPEN;
					}
				}
				if(Dialog_GetValue(playerid, 0) > 0)
				{
					ListItem:<"<< �����">
					{
						Dialog_SetValue(playerid, 0, Dialog_GetValue(playerid, 0) - 15);
						return DIALOG_REOPEN;
					}
				}
			}
			Button:<"����������", "�����">;
		}
		ListItem:<"���������� ����">
		{
			Create:<"����������">
			{
				ResponseRight:return DIALOG_BACK;
				
				static vehiclenames[][] = {
					"Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel", "Dumper", "Fireguard", "Trashmaster", "Strech", "Manana",
					"Infernus", "Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam", "Esperanto", "Taxi", "Washington", "Bobcat",
					"Whoopee", "BF Injection", "Hunter", "Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks", "Hotknife",
					"Trailer 1", "Previon", "Coach", "Cabbie", "Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral", "Squalo",
					"Seasparrow", "Pizzaboy", "Tram", "Trailer 2", "Turismo", "Speeder", "Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair",
					"Berkley's RC Van", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider", "Glendale", "Oceanic", "Sanchez", "Sparrow",
					"Patriot", "Quad", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX", "Burrito",
					"Camper", "Marquis", "Baggage", "Dozer", "Maverick", "News Chopper", "Rancher", "FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring",
					"Sandking", "Blista Compact", "PoliceMaverick", "Boxvillde", "Benson", "Mesa", "RC Goblin", "Hotring Racer A", "Hotring Racer B",
					"Bloodring Banger", "Rancher", "Super GT", "Elegant", "Journey", "Bike", "MountainBike", "Beagle", "Cropduster","Stunt",  "Baker",
					"Roadtrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra", "FCR-900", "NRG-500", "HPV1000", "CementCar", "Tow Truck", "Fortune",
					"Cadrona", "FBI Truck", "Willard", "Forklift", "Tractor", "Combine", "Fel tzer", "Remington", "Slamvan", "BLADe", "Freight", "Streak",
					"Vortex", "Vincent", "Bullet", "Clover", "Sadler", "Straz Pozarna LA", "Hustler", "Intruder", "Primo", "Cargobob", "Tampa", "Sunrise", "Merit",
					"Utility", "Nevada", "Yosemite", "Windsor", "Monster A", "Monster B", "Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Raindance",
					"RC Tiger", "Flash", "Tahoma", "Savanna", "Bandito", "Freight Flat", "Streak Carriage", "Kart", "Mower", "Dune", "Sweeper", "Broadway",
					"Tornado", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400", "News Van", "Tug", "Trailer 3", "Emperor", "Wayfarer", "Euros", "Hotdog",
					"Club", "Freight Carriage", "Trailer 4", "Andromada", "Dodo", "RC Cam", "Launch", "PoliceCar (LSPD)", "PoliceCar (SFPD)",
					"PoliceCar (LVPD)", "Ranger", "Picador", "S.W.A.T", "Alpha", "Phoenix", "Glendale", "Sadler", "Luggage Trailer A",
					"Luggage Trailer B", "Stairs", "Boxville", "Tiller", "Utility Trailer" 
				};

				ListHead:<"�������� ����������">;
				for(new modelindex = Dialog_GetValue(playerid, 0); modelindex < Dialog_GetValue(playerid, 0) + 15; modelindex++)
				{
					if(modelindex >= sizeof vehiclenames)
					{
						break;
					}
					ListItem:<vehiclenames[modelindex]>
					{
						Create:<"�������� ���� #1">
						{
							enum veh_color_data {
								veh_color_name[16], 
								veh_color_id
							};
							
							new colors[][veh_color_data] = {
								{"׸����", 	0},
								{"�����", 	1},
								{"�����", 	2},
								{"�������", 3},
								{"Ƹ����", 	6}
							};
							for(new colorindex1; colorindex1<sizeof colors; colorindex1++)
							{
								ListItem:<colors[colorindex1][veh_color_name]>
								{
									Create:<"�������� ���� #2">
									{
										for(new colorindex2; colorindex2<sizeof colors; colorindex2++)
										{
											ListItem:<colors[colorindex2][veh_color_name]>
											{
												new Float:x, Float:y, Float:z, Float:angle, Float:distance = 5.0;
												GetPlayerPos(playerid, x, y, z);
												GetPlayerFacingAngle(playerid, angle);
												
												CreateVehicle(
													modelindex + 400, 
													x + (distance * floatsin(-angle, degrees)), 
													y + (distance * floatcos(-angle, degrees)), 
													z,
													angle,
													colors[colorindex1][veh_color_id], 
													colors[colorindex2][veh_color_id],
													300
												);
												return DIALOG_MAIN;
											}
										}
									}
									Button:<"�������", "�����">;
								}
							}
						}
						Button:<"�������", "�����">;
					}				
				}
				if(Dialog_GetValue(playerid, 0)+15 < sizeof vehiclenames)
				{
					ListItem:<"����� >>">
					{
						Dialog_SetValue(playerid, 0, Dialog_GetValue(playerid, 0) + 15);
						return DIALOG_REOPEN;
					}
				}
				if(Dialog_GetValue(playerid, 0) > 0)
				{
					ListItem:<"<< �����">
					{
						Dialog_SetValue(playerid, 0, Dialog_GetValue(playerid, 0) - 15);
						return DIALOG_REOPEN;
					}
				}
			}
			Button:<"����������", "�����">;
		}
	}
	Button:<"�������", "�������">;
}

dialog Main(playerid)
{
    Create:<"LiveDialogs - ����������">
    {
        ResponseRight:return DIALOG_CLOSE;
        MessageBox:<"�� ��� ��������� � ����� �������">
        {
            Create:<"LiveDialogs - ������� �� ������� ����">
            {
                ResponseRight:return DIALOG_BACK;
                MessageBox:<"����� ����� � �� �������">
                {
                    ResponseRight:return DIALOG_BACK;
                    Create:<"LiveDialogs - ����������� ��������� � ������� ����">
                    {
                        ResponseRight:return DIALOG_MAIN;
                        MessageBox:<"����� \"�������\" � �� ������� � ������� ����!">
                        {
                            Create:<"LiveDialogs - �����">
                            {
                                ListHead:<"������ �����:">;
                                for(new i; i<10; i++)
                                {
									new str[92];
									format(str, sizeof str, "����� #%d", i);
                                    ListItem:<str>
                                    {
                                        SendClientMessage(playerid, -1, "������: %d �����!", i);
                                        return DIALOG_CLOSE;
                                    }
                                }
                            }
                        }
                        Button:<"�����", "�������">;
                    }
                }
            }
            Button:<"�����", "�����">;
        }
    }
    Button:<"�����", "�������">;
}

dialog DTest(playerid)
{
	enum deep_data {
		deep_id,
		deep_dialog[92]
	}
	new dialogdata[][deep_data] = 
	{
		{0, "������ 1"},
		{0, "������ 2"},
		{0, "������"},
		{0, "������ 3"},
		{0, "������ 4"}
	};
	Create:<dialogdata[0][deep_dialog]>
	{
		dialogdata[0][deep_id] = Dialog_GetDeep(playerid);
		MessageBox:<dialogdata[0][deep_dialog]>
		{
			Create:<dialogdata[1][deep_dialog]>
			{
				dialogdata[1][deep_id] = Dialog_GetDeep(playerid);
				MessageBox:<dialogdata[1][deep_dialog]>
				{
					Create:<dialogdata[2][deep_dialog]>
					{
						dialogdata[2][deep_id] = Dialog_GetDeep(playerid);
						DialogQuery:<mysql, "SELECT * FROM `accounts`">;
						new deepid = Dialog_GetDeep(playerid);
						new rows = cache_num_rows();
						ListItem:<"Reopen">
						{
							return DIALOG_REOPEN;
						}
						for(new i; i<rows; i++)
						{
							new nickname[MAX_PLAYER_NAME];
							cache_get_value_name(i, "pNickName", nickname);
							ListItem:<nickname>
							{
								Create:<dialogdata[3][deep_dialog]>
								{
									ResponseRight: return DIALOG_BACK;
									dialogdata[3][deep_id] = Dialog_GetDeep(playerid);
									MessageBox:<dialogdata[3][deep_dialog]>
									{
										Create:<dialogdata[4][deep_dialog]>
										{
											dialogdata[4][deep_id] = Dialog_GetDeep(playerid);
											ListItem:<"������� ��� � ��������� �����">
											{
												Dialog_CacheDestroy(playerid, deepid);
												return DIALOG_BACK;
											}
											ListItem:<"������� ��� � ������� ���� ������">
											{
												Dialog_CacheDestroy(playerid, deepid);
												return DIALOG_REOPEN;
											}
											ListItem:<"������� ��� � ������� ������� ����">
											{
												Dialog_CacheDestroy(playerid, deepid);
												return DIALOG_MAIN;
											}
											for(new j; j<sizeof dialogdata; j++)
											{
												ListItem:<dialogdata[j][deep_dialog]>
												{
													return DialogGoto:<dialogdata[j][deep_id]>;
												}
											}
										}
										Button:<"�������", "�������">;
									}
								}
							}
						}
					}
					Button:<"�������", "�����">;
				}
			}
			Button:<"�������", "�������">;
		}
	}
	Button:<"�������", "�������">;
}




dialog DeleteAccount(playerid)
{
	Create:<"������ 1">
	{
		MessageBox:<"�����">
		{
			Create:<"������ 2">
			{
				DialogQuery:<mysql, "SELECT * FROM `accounts` LIMIT 15">;

				new deepid = Dialog_GetDeep(playerid);
				new rows = cache_num_rows();
				new str[128];

				for(new i; i<rows; i++)
				{
					new nickname[MAX_PLAYER_NAME], id;
					cache_get_value_name(i, "pNickName", nickname);
					cache_get_value_name_int(i, "pMysqlID", id);
					ListItem:<nickname>
					{
						Create:<"�������� ��������">
						{
							ResponseRight: return DIALOG_BACK;
							DialogRender: format(str, sizeof str, "�� ������������� ������ ������� ������� %s?", nickname);
							MessageBox:<str>
							{
								format(str, sizeof str, "DELETE FROM `accounts` WHERE  `pMysqlID`=%d ", id);
								mysql_tquery(mysql, str);

								Dialog_CacheDestroy(playerid, deepid);
								return DialogGoto:<deepid>;
							}
						}
						Button:<"�������", "�����">;
					}
				}
			}
			Button:<"�������", "�����">;
		}
	}
	Button:<"�������", "�������">;
}