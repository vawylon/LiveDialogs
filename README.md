
��������� ����� ���������� "������" �� ���������� � ��, ��� ��� �������� ������� � ��� ��������� ������� �� ����������� ���� � �� �� ��������. ����� ���������� ������� ��� �������. mdialgs:

```c
DialogCreate:Main(playerid)
{
� � if(GetPlayerMoney(playerid) < 10_000) {
� � � � SendClientMessage(playerid, 0xFF0000FF, "� ��� ��� 10.000$");
� � � � return 0;
� � }
� � Dialog_Open(playerid, Dialog:Main, DIALOG_STYLE_INPUT,
� � � � "���� �����",
� � � � "\
� � � � � � ������� �� ������ ���� ������ �������� 10.000$:\
� � � � ",
� � � � "������", "�������"
� � )
}

DialogResponse:Main(playerid, response, listitem, inputtext[])
{
� � if(response)
� � {
� � � � return;
� � }
� � if(GetPlayerMoney(playerid) < 10_000) {
� � � � SendClientMessage(playerid, 0xFF0000FF, "� ��� ��� 10.000$");
� � � � return 0;
� � }

� � new player = strval(inputtext);
� � if(!IsPlayerConnected(player))
� � {
� � � � SendClientMessage(playerid, 0xFF0000FF, "����� �� � ����.");
� � � � Dialog_Show(playerid, Dialog:Main);
� � � � return 0;
� � }
� � GivePlayerMoney(playerid, -10_000);
� � GivePlayerMoney(player, 10_000);
� � SendClientMessage(playerid, "10.000$ �������� ������ %d", player);
� � SendClientMessage(playerid, "����� %d ������� ��� 10.000$", playerid);
}

```

�������� ��������� ������� � ��������� �������� � ������ ��������� ������ � ������� �� �������, �� ��� ����. � ��� �� �������� � ��������� ������� ������� ���������� � ������ ������, ��� ���������� ������ ����, � �� � �������� � ������� ������������, ��� ��� ��� ����� ���������� ����������� �� ������ ������� ����.
����� �������� ����������, ����� ������ �������������� ���� �����, ���� � ����� ������ �� ���������� ���-�� �����, ����� ���������� ��������� �����, �� ������ ��������� �� ���������� �� ������ � ��������� �� ������������ � ������ ��������, � ��� �������� �������� ������, ��� ��������� "������", �� ������ ��������� �� ���������� �� ������ � ���� ���������, ������� �� ������� ���� � ���� ����� ����������� �������� � ������ ������� ���������� ������������ ����� ��� ���� ����� ������ ����� ��������. ������ �������� ����������� ������ ������� � ������ ������ �� ������� ������������ � ������ ��������.
![[dialogs.png]]

��� ���������� ����� ��������������� ��� ���������� ������� �������, ��� ���� ��� ������ ���� � ��������� ������ � ����� ��������� ���������� �������.
� ����� ����� ��� ������ ������ ��������, ��� ������� �� ������ ����������� !��� ���������� �� ����� ������ ������ � ������������� � ������� ��������� !. ��������� ������� ��� ���� ��� ������ �� ������ ����� � �� ������� ��� ����� LiveDialogs.

```c
CMD:show(playerid) {
� � Dialog_Create(playerid, Dialog:Main);
}

dialog Main(playerid)
{
� � Create:<"���������� ����">
� � {
� � � � ListItem:<"����� 1">
� � � � {
� � � � � � // ��� ���������� � ������ ���� ����� ������ 1� �����
� � � � � � // � ����� ������ ������
� � � � � � SendClientMessage(playerid, -1, "�� ������ ������� 1� �����");
� � � � � � return DIALOG_CLOSE;
� � � � }
� � � � else
� � � � {
� � � � � � // ��� ���������� � ������ ���� ����� ������ 1� �����
� � � � � � // � ����� ������ ������
� � � � � � SendClientMessage(playerid, -1, "�� ������ \"�����\" �� 1� ������");
� � � � � � return DIALOG_CLOSE;
� � � � }
� � � � ListItem:<"����� 2">
� � � � {
� � � � � � // ��� ���������� � ������ ���� ����� ������ 2� �����
� � � � � � // � ����� ������ ������
� � � � � � SendClientMessage(playerid, -1, "�� ������ ������� 2� �����");
� � � � � � return DIALOG_CLOSE;
� � � � }
� � � � else
� � � � {
� � � � � � // ��� ���������� � ������ ���� ����� ������ 2� �����
� � � � � � // � ����� ������ ������
� � � � � � SendClientMessage(playerid, -1, "�� ������ \"�����\" �� 2� ������");
� � � � � � return DIALOG_CLOSE;
� � � � }
� � � � ListItem:<"����� 3">
� � � � {
� � � � � � // ��� ���������� � ������ ���� ����� ������ 3� �����
� � � � � � // � ����� ������ ������
� � � � � � SendClientMessage(playerid, -1, "�� ������ ������� 3� �����");
� � � � � � return DIALOG_CLOSE;
� � � � }
� � � � else
� � � � {
� � � � � � // ��� ���������� � ������ ���� ����� ������ 3� �����
� � � � � � // � ����� ������ ������
� � � � � � SendClientMessage(playerid, -1, "�� ������ \"�����\" �� 3� ������");
� � � � � � return DIALOG_CLOSE;
� � � � }
� � }
� � Button:<"�������", "�����">;
}

```

### ������� ���

� ������� ���� 2 ���������:

**������ �������** � ��������� \***������� ������**\*;

```c
// � ## DIALOG_STYLE_LIST
ListItem:<text[], ...> { /* response left */ } else { /* response right */ }
// � ## DIALOG_STYLE_MESSAGEBOX
MessageBox:<text[], ...> { /* response left */ } else { /* response right */ }
// � ## DIALOG_STYLE_PASSWORD
InputPassword:<text[], ...> { /* response left */ } else { /* response right */ }
// � ## DIALOG_STYLE_INPUT
InputText:<text[], ...> { /* response left */ } else { /* response right */ }
// � ## DIALOG_STYLE_TABLIST_HEADERS
ListHead:<text[], ...>;
```

��� ������� �������, ��� ������ ���������� ������ �����, ����� ����� ������ ����� (������ ����� �������); �else � ��� ������ ����� �������� ��� ������� ������ ������ �������.

```c
ListItem:<string:text[], ...>
```

� ����������� ������� ����� ����������� � else �� �����

```c
Create:<"������">
{
� � ListItem:<"����� 1">
� � {
� � � � SendClientMessage(playerid, -1, "������ ����� 1");
� � }
� � else
� � {
� � � � return DIALOG_CLOSE;
� � }
� � ListItem:<"����� 2">
� � {
� � � � SendClientMessage(playerid, -1, "������ ����� 2");
� � }
� � else
� � {
� � � � return DIALOG_CLOSE;
� � }
}
```
�� ������ ���������� �������� ��� �������:
ResponseRight / Left:

```c
ResponseRight: { /* ��� ����� �������� ��� ������� ������ ������ */ }
ResponseLeft: { /* ��� ����� �������� ��� ������� ����� ������ */ }
```
#### ������:

```c
Create:<"������">
{
� � ResponseRight: {
� � � � return DIALOG_CLOSE;
� � � � // ������, ��� ������� ������ ������� �������, �� ����� �����������.
� � � � // � ����� ��������, ��� ListItem {} else { *����* } ������� �� ����������,
� � � � // � ������ � ���� �����.
� � � � // ����� ������������ ����������� ����, ������� ������ �� �����������:
� � � � // ResponseRight:return DIALOG_CLOSE;
� � }
� � ListItem:<"����� 1">
� � {
� � � � SendClientMessage(playerid, -1, "������ ����� 1");
� � � � return DIALOG_CLOSE;
� � }
� � ListItem:<"����� 2">
� � {
� � � � SendClientMessage(playerid, -1, "������ ����� 2");
� � � � return DIALOG_CLOSE;
� � }
}
```
```c
#inclide <YSI_Coding/y_args>
#inclide <LiveDialogs>
```

LiveDialogs ������������ **va_args**, �� ������ ������������� �����, ��� ����� ���������� va_args �� ���������� YSI � ����� �������������� ����� ��������, ����� ������������ ��������������:

  
```c
new list;
ListItem:<"����� #%d", ++list>
{
}
ListItem:<"����� #%d", ++list>
{
}
> ����� #1
> ����� #2
```

� ��������� ������� �� ������������� ��������� ��� ������ ��� ������� � ��� ������� �������, ��� ����� ���� DialogRender.

��� ������ ���������� ������ � ��� ������, ����� ��� ��������� �������. ����� ������� ������ ��� ����� ���� �����.

```c
new String256[256]; // � ������� ���������� ������

dialog PlayerInfo(playerid)
{
� � Create:<"������">
� � {
� � � � String256[0] = EOS;

� � � � DialogRender: {
� � � � � � // � ������, ���� ����� ������ ������,
� � � � � � // �������������� ����� � ���� �������.
� � � � � � // � ������ �������� �������������� ����� 1 ���
� � � � � � new nickname[MAX_PLAYER_NAME];
� � � � � � GetPlayerName(playerid, nickname);
� � � � � � format(String256, sizeof String256,
� � � � � � � � "\
� � � � � � � � � � �����: %d$\n\
� � � � � � � � � � �������: %d\n\
� � � � � � � � � � ��: %.0f\n\
� � � � � � � � � � �����: %.0f\
� � � � � � � � ",
� � � � � � � � pData[playerid][pMoney],
� � � � � � � � pData[playerid][pLevel],
� � � � � � � � pData[playerid][pHealth],
� � � � � � � � pData[playerid][pArmour],
� � � � � � );
� � � � }
� � � � MessageBox<String256>
� � � � {
� � � � � � return DIALOG_CLOSE;
� � � � }
� � }
� � Button:<"�������">;
}
```
### �����

�� ������ ������������ �����, **�� ����������� ������ � ������ �������,** **���������� ������ ���� ���������**, ������ ������� ����������, ���������� ��������� � ��������� ����� ����� ���������.

```c
dialog ForList(playerid)
{
� � Create:<"���������� ����">
� � {
� � � � ResponseRight: return DIALOG_CLOSE;
� � � � for(new i=1; i<4; i++)
� � � � {
� � � � � � ListItem:<"����� %d", i>
� � � � � � {
� � � � � � � � SendClientMessage(playerid, -1, "�� ������� %d �����", i);
� � � � � � � � return DIALOG_CLOSE;
� � � � � � }
� � � � }
� � }
� � Button:<"�������", "�����">;
}
```

��� ������, ����� ����� ����� ��������, �� ��� ��������� ��������������� �� ����� �����������:

```c
dialog SelectPlayer(playerid)
{
� � Create:<"�������� ������ �����">
� � {
� � � � ResponseRight: return DIALOG_CLOSE;
� � � � foreach(new player : StreamedPlayers[playerid])
� � � � {
� � � � � � new nickname[MAX_PLAYER_NAME];
� � � � � � GetPlayerName(player, nickname);
� � � � � � ListItem:<"%s(%d)", nickname, player>
� � � � � � {
� � � � � � � � SendClientMessage(playerid, -1,
� � � � � � � � � � "�� ������� ������ %s(%d)",
� � � � � � � � � � nickname, player
� � � � � � � � );
� � � � � � � � return DIALOG_CLOSE;
� � � � � � }
� � � � }
� � }
� � Button:<"�������", "�����">;
}
```

� ������ ����� 5 ������� - ������� ������� �����, �� ����� ��� ��� ������� ������, ���� �� ������ ����� �������� ���� � ����� �������� **StreamedPlayers** ��������� � ����� ������ ���������� ������ �����.

### ���������


�� ������ ������������� ������ �������, ����� ���������� � ������� �������, ��� ������� �������� ����:

```c
dialog Collections(playerid)
{
� � Create:<"�������� ������ �����">
� � {
� � � � ResponseRight: return DIALOG_CLOSE;
� � � � DialogRender: {
� � � � � � foreach(new player : StreamedPlayer[playerid]) {
� � � � � � � � DialogCollect:<player>;
� � � � � � }
� � � � }

� � � � // DialogRender: foreach(new i : StreamedPlayer[playerid]) DialogCollect:<i>;
� � � � // �� ��� �� ������������� ������ �� StreamedPlayer � ������ �� ��
� � � � // ���������
� � � � // �������� ��������, �������� � ������ �������, ������� ����� �������!
� � � � // player �� ����� ���������, �� ����������� ������
� � � � DialogCollections:<player>
� � � � {
� � � � � � new nickname[MAX_PLAYER_NAME];
� � � � � � GetPlayerName(player, nickname);
� � � � � � ListItem:<"%s(%d)", nickname, player>
� � � � � � {
� � � � � � � � if(!IsPlayerConnected(player)) {
� � � � � � � � � � SendClientMessage(playerid, -1, "����� ������� ����!");
� � � � � � � � � � return DIALOG_REOPEN;
� � � � � � � � � � // DIALOG_REOPEN ��������� ������� ������ ��������,
� � � � � � � � � � // ����� ������ ����� ������ ������� �����.
� � � � � � � � }
� � � � � � � � return DIALOG_CLOSE;
� � � � � � }
� � � � }
� � }
� � Button:<"�������", "�����">;
}
```
### �����������

���� ��� ������� �������� ���������� ���� � ����������� �������� ��� ������ � ������������� ������������ ����������� ���������� � �������������� �������. � ������ �� ��� ������������ ���� ���������, � ������������ ����� ���� ��������� �����, ���� ������� ������.

```c
dialog Main(playerid)
{
� � Create:<"���������� ����">
� � {
� � � � ListItem:<"����� 1">
� � � � {
� � � � � � Create:<"���������� ���� ������ 1">
� � � � � � {
� � � � � � � � DialogResponse:return DIALOG_BACK;
� � � � � � � � MessageBox:<"��� ���������� ���� 1�� ������">
� � � � � � � � {
� � � � � � � � � � return DIALOG_CLOSE;
� � � � � � � � }
� � � � � � }
� � � � � � Button:<"�������", "�����">;
� � � � }
� � � � ListItem:<"����� 2">
� � � � {
� � � � � � Create:<"���������� ���� ������ 2">
� � � � � � {
� � � � � � � � DialogResponse:return DIALOG_BACK;
� � � � � � � � MessageBox:<"��� ���������� ���� 2�� ������">
� � � � � � � � {
� � � � � � � � � � return DIALOG_CLOSE;
� � � � � � � � }
� � � � � � }
� � � � � � Button:<"�������", "�����">;
� � � � }
� � � � ListItem:<"����� 3">
� � � � {
� � � � � � Create:<"���������� ���� ������ 3">
� � � � � � {
� � � � � � � � DialogResponse:return DIALOG_BACK;
� � � � � � � � MessageBox:<"��� ���������� ���� 3�� ������">
� � � � � � � � {
� � � � � � � � � � return DIALOG_CLOSE;
� � � � � � � � }
� � � � � � }
� � � � � � Button:<"�������", "�����">;
� � � � }
� � }
� � Button:<"�������", "�������">;
}
```

��� ������ ������ ������ ������������ "�������������" � ������ ������ � �������������� `DIALOG_STYLE_MSGBOX`, ��� ������������ ���������, ��� �������� � �������. ��� ��������� ����� �������� �������� ������������ ��������� `DIALOG_BACK`. ��� ������� �� ������ ������ ������ ������������ � ����������� "����������� ����". ������� ����������� �������� ���������� ���������� `DIALOG_MAX_DEEP`.

---
### ��������, ������� ����� ������������:

- **`DIALOG_CLOSE`** � ��������� ������ ���������;
- **`DIALOG_REOPEN`** � �������� ��������� ������;
- **`DIALOG_BACK`** � ���������� �� ���� ������� ����, �������� ����������� ������;
*  **`return DialogGoto:<deep>;`** ������� ��������� ������ ������� ����. 
- **`DIALOG_REOPEN_TIME:<milliseconds>`** � �������� ��������� ������ ����� �������� ���������� �����������;
- **`DIALOG_HIDE`** � �������� ������, ������� ����� ����� ������� �������.

� ����� ������ ������� �� �������� �������������� � �������������� ����������, � ��� �� ������� ������� ����������� � ������ ������ ������ ���� ���� (�� ������� ForList ���� MainMenu)

---
```c
dialog MainMenu(playerid)
{
� � Create:<"���� ������">
� � {
� � � � ListItem:<"������ ForList">
� � � � {
� � � � � � return ForList(playerid);
� � � � }
� � � � ListItem:<"������ Collections">
� � � � {
� � � � � � return Collections(playerid);
� � � � }
� � � � ListItem:<"����� SelectPlayer">
� � � � {
� � � � � � return SelectPlayer(playerid);
� � � � }
� � � � ListItem:<"����� PlayerInfo">
� � � � {
� � � � � � return PlayerInfo(playerid);
� � � � }
� � }
� � Button:<"�������", "�������">;
}
```

�� ������ ������ ���������, � ������� ��������� ������ ����� �������� ������, � ��������� ������ � 5�� ������:

```c
dialog MainMenu(playerid)
{
� � Create:<"���� ������">
� � {
� � � � if(pData[playerid][pLevel] >= 5)
� � � � {
� � � � � � // ���� ����� ����� �������� � ��� ������,
� � � � � � // ����� � ������ 5� � ����� �������.
� � � � � � ListItem:<"������ ForList">
� � � � � � {
� � � � � � � � return ForList(playerid);
� � � � � � }
� � � � }
� � � � ListItem:<"������ Collections">
� � � � {
� � � � � � return Collections(playerid);
� � � � }
� � � � ListItem:<"����� SelectPlayer">
� � � � {
� � � � � � return SelectPlayer(playerid);
� � � � }
� � � � ListItem:<"����� PlayerInfo">
� � � � {
� � � � � � return PlayerInfo(playerid);
� � � � }
� � }
� � Button:<"�������", "�������">;
}
```

������� ������ �������� �����, ��� ������� ����� ����� ������ �� ������ (�� ������ ������������ dialog Collections), ����� ������ ���-�� ����� � ����������� ��������.

```c
dialog GiveMoney(playerid)
{
� � // ������ ���: ���� ID ������
� � Create:<"�������� �����">
� � {
� � � � ResponseRight: return DIALOG_CLOSE;
� � � � Input:<"������� �� ������:">
� � � � {
� � � � � � new player = Dialog_Number(playerid);
� � � � � � if(!IsPlayerConnected(player)) {
� � � � � � � � SendClientMessage(playerid, -1, "����� �� � ����!");
� � � � � � � � return DIALOG_REOPEN;
� � � � � � }
� � � � � � // ������ ���: ���� �����
� � � � � � Create:<"�������� �����">
� � � � � � {
� � � � � � � � DialogRight: return DIALOG_BACK;
� � � � � � � � Input:<"������� ����� ������� ������ ��������:">
� � � � � � � � {
� � � � � � � � � � // Dialog_Number ���������� ������� �����
� � � � � � � � � � new money = Dialog_Number(playerid);
� � � � � � � � � � if(money < 0) {
� � � � � � � � � � � � SendClientMessage(playerid, -1, "������� ����� 1$!");
� � � � � � � � � � � � return DIALOG_REOPEN;
� � � � � � � � � � }
� � � � � � � � � � if(money > pData[playerid][pMoney]) {
� � � � � � � � � � � � SendClientMessage(playerid, -1, "� ��� ��� ����� �����!");
� � � � � � � � � � � � return DIALOG_REOPEN;
� � � � � � � � � � }
� � � � � � � � � � new nickname[MAX_PLAYER_NAME];
� � � � � � � � � � GetPlayerName(player, nickname);
� � � � � � � � � � 
� � � � � � � � � � // ������ ���: �������������
� � � � � � � � � � Create:<"�������� �����">
� � � � � � � � � � {
� � � � � � � � � � � � ResponseRight:return DIALOG_BACK;
� � � � � � � � � � � � new money = Dialog_Number(playerid);
� � � � � � � � � � � � MessageBox:<"\
� � � � � � � � � � � � � � �� ������������� ������ �������� ������?\n\
� � � � � � � � � � � � � � �����: %s (%d)\n\
� � � � � � � � � � � � � � �����: %d$\
� � � � � � � � � � � � ", nickname, player, money>
� � � � � � � � � � � � {
� � � � � � � � � � � � � � GivePlayerMoney(playerid, -money);
� � � � � � � � � � � � � � GivePlayerMoney(player, money);
� � � � � � � � � � � � � � SendClientMessage(playerid, -1,
� � � � � � � � � � � � � � � � "�� �������� %d$ ������ %s (%d)",
� � � � � � � � � � � � � � � � � � money, nickname, player
� � � � � � � � � � � � � � );
� � � � � � � � � � � � � � GetPlayerName(playerid, nickname);
� � � � � � � � � � � � � � SendClientMessage(playerid, -1,
� � � � � � � � � � � � � � � � "����� %s(%d) ������� ��� %d ������",
� � � � � � � � � � � � � � � � � � nickname, playerid, money
� � � � � � � � � � � � � � );
� � � � � � � � � � � � � � return DIALOG_CLOSE;
� � � � � � � � � � � � }
� � � � � � � � � � }
� � � � � � � � � � Button:<"��������", "�����">;
� � � � � � � � }
� � � � � � }
� � � � � � Button:<"�����", "�����">;
� � � � }
� � }
� � Button:<"�������", "�����">;
}

```

��������, ��� ����� ��������� ����� ����� `Player_GiveMoney` ��� ������������� ������������� ���������, ��������� �� ����� � ���� ��� ����� �� �� ���������� �������, ��� ��� ��� ����������� �������� ��� ����������� � ������ ������� �� ������ "��������". ��� ���� �������� �����, ��������� `DialogRender` � `DialogCollections` �������� �����, ��� ��� ��������� ��������� ������� ��� ����� ���� ��� � � ������ ������� �������.

### ������� � ���� ������

�� ������ \*�����������\* ������ �� sql ������������ ��������� ��� ������:

```c
// ����� � ���������� ������ �������������� �� ������ ������ � ��������� MD :)
static query_top_10[] = "\
� � SELECT `nickname`, `money` \
� � FROM `accounts` \
� � ORDER BY `money` desc LIMIT 10;\
";

dialog PlayersTopMoney(playerid)
{
� � Create:<"��� 10 ������� �������">
� � {
� � � � ResponseRight:return DIALOG_CLOSE;
� � � � DialogQuery:<mysqlconnect, query_top_10>;
� � � � 
� � � � new rows = cache_num_rows();

� � � � if(rows == 0) {
� � � � � � DialogMessgbox:<"� ������� `accounts` ��� �������"> {
� � � � � � � � return DIALOG_CLOSE;
� � � � � � }
� � � � }

� � � � // ������� ������ DIALOG_STYLE_TABLIST_HEADER
� � � � DialogHead:<"�����\t�����">;
� � � � for(new i; i<rows; i++)
� � � � {
� � � � � � cache_get_value_name(i, "nickname", nickname);
� � � � � � cache_get_value_int(i, "money", money);
� � � � � � if(i < 3)
� � � � � � {
� � � � � � � � // �������� ��� 3 � ����� ����
� � � � � � � � ListItem:<"{FFCC47}%d{FFFFFF}. %s\t%d$", i+1, nickname, money>
� � � � � � � � {
� � � � � � � � � � SendClientMessage(playerid, -1, "����� %s ������ � ��� 3 ���������� �������, ������� %d �����.", nickname, i+1);
� � � � � � � � � � return DIALOG_REOPEN;
� � � � � � � � � � );
� � � � � � � � }
� � � � � � }
� � � � � � else
� � � � � � {
� � � � � � � � ListItem:<"%d. %s\t%d$", i+1, nickname, money>
� � � � � � � � {
� � � � � � � � � � SendClientMessage(playerid, -1, "����� %s ������ � ��� 10 ���������� �������, ������� %d �����.", nickname, i+1);
� � � � � � � � � � return DIALOG_REOPEN;
� � � � � � � � }
� � � � � � }
� � � � }
� � }
� � Button:<"�������", "�������">;
}
```

**DialogQuery** �������� �������, ��� �������� � ��� ������ ���� �������� ���� �� ��������
```c
dialog DestroyAccount(playerid)
{
	Create:<"������ 1">
	{
		ResponseRight: return DIALOG_BACK;
		MessageBox:<"�����">
		{
			Create:<"������ 2">
			{
				ResponseRight: return DIALOG_BACK;
				DialogQuery:<mysql, "SELECT * FROM `accounts` LIMIT 15">;
				// �������� ������� ������� (id)
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
								// ��� ��� �� ���������� ������������ � ������ � �����, ��� �� ����� �����, ��� ����� ������� �������������� ��� �� �������� ����� ����������.
								Dialog_CacheDestroy(playerid, deepid);
								return DialogGoto:<deepid>; // ������ ������������� goto
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
```

�����: � ������� ����� ���� ������ ���� ����� DialogQuery.

��������, ��� ������ ������ ����� �������� �������������� ���������� ����� ��������� ������� ��� �������.

```c
// ����� � ���������� ������ �������������� �� ������ ������ � ��������� MD :)
static query_account[] = "\
� � SELECT * FROM `accounts` WHERE `id` = %d\
";

dialog PlayersTopMoney(playerid, accountid)
{
� � Create:<"���������� � ������">
� � {
� � � � ResponseRight:return DIALOG_CLOSE;
� � � � DialogQuery:<mysqlconnect, query_account, accountid>;
� � � � if(cache_num_rows() == 0) {
� � � � � � DialogMessgbox:<"������� %d �� ������", accountid> {
� � � � � � � � return DIALOG_CLOSE;
� � � � � � }
� � � � }
� � � � DialogRender:
� � � � {
� � � � � � new nickname[MAX_PLAYER_NAME],
� � � � � � � � money,
� � � � � � � � level,
� � � � � � � � bank,
� � � � � � � � ip,
� � � � � � � � registation[32]
� � � � � � ;
� � � � � � cache_get_value_name_name(i, "nickname", nickname);
� � � � � � cache_get_value_name_int(i, "money", money);
� � � � � � cache_get_value_name_int(i, "level", level);
� � � � � � cache_get_value_name_int(i, "bank", bank);
� � � � � � cache_get_value_name(i, "ip", ip);
� � � � � � cache_get_value_name_int(i, "registation", registation);
� � � � � � format(String1024, sizeof String1024,
� � � � � � � � "\
� � � � � � � � � � �� ��������: %d\n\
� � � � � � � � � � ���: %s\n\
� � � � � � � � � � �������: %d\n\
� � � � � � � � � � �� �����: %d$\n\
� � � � � � � � � � � �����: %d$\n\
� � � � � � � � � � IP: %s\n\
� � � � � � � � � � ���������������: %s\
� � � � � � � � ",
� � � � � � � � accountid,
� � � � � � � � nickname,
� � � � � � � � level,
� � � � � � � � bank,
� � � � � � � � ip,
� � � � � � � � registration
� � � � � � );
� � � � }
� � � � MessageBox:<String1024>
� � � � {
� � � � � � return DIALOG_BACK;
� � � � }
� � }
� � Button:<"�������", "�������">;
}
```

������ ������� ���� ������ � PlayersTopMoney:

```c
dialog PlayersTopMoney(playerid)
{
� � Create:<"��� 10 ������� �������">
� � {
� � � � ResponseRight:return DIALOG_CLOSE;
� � � � DialogQuery:<mysqlconnect, query_top_10>;
� � � � new rows = cache_num_rows();
� � � � if(rows == 0) {
� � � � � � DialogMessgbox:<"� ������� `accounts` ��� �������"> {
� � � � � � � � return DIALOG_CLOSE;
� � � � � � }
� � � � }
� � � � 
� � � � // ������� ������ DIALOG_STYLE_TABLIST_HEADER
� � � � DialogHead:<"�����\t�����">;

� � � � for(new i; i<rows; i++)
� � � � {
� � � � � � cache_get_value_name(i, "id", accountid);
� � � � � � cache_get_value_name(i, "nickname", nickname);
� � � � � � cache_get_value_int(i, "money", money);
� � � � � � ListItem:<"{%s}%d{FFFFFF}. %s\t%d$", i<3?("FFCC46"):("FFFFFF"), i+1, nickname, money>
� � � � � � {
� � � � � � � � return PlayersTopMoney(playerid, accountid);
� � � � � � }
� � � � }
� � }
� � Button:<"�������", "�������">;
}
```