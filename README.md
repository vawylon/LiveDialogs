# LiveDialogs
Используя любой диалоговый "движок" вы упираетесь в то, что при создании диалога и при обработке нажатия вы используете одни и те же проверки. Взять популярный инклуйд для диалога. mdialgs:
```c
DialogCreate:Main(playerid)
{
	if(GetPlayerMoney(playerid) < 10_000) {
		SendClientMessage(playerid, 0xFF0000FF, "У Вас нет 10.000$");
		return 0;
	}
	Dialog_Open(playerid, Dialog:Main, DIALOG_STYLE_INPUT, 
		"Дать денег", 
		"\
			Введите ид игрока кому хотите передать 10.000$:\
		",
		"Выдать", "Закрыть"
	)
}

DialogResponse:Main(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		return;
	}
	if(GetPlayerMoney(playerid) < 10_000) {
		SendClientMessage(playerid, 0xFF0000FF, "У Вас нет 10.000$");
		return 0;
	}
	new player = strval(inputtext);
	if(!IsPlayerConnected(player))
	{
		SendClientMessage(playerid, 0xFF0000FF, "Игрок не в сети.");
		Dialog_Show(playerid, Dialog:Main);
		return 0;
	}
	GivePlayerMoney(playerid, -10_000);
	GivePlayerMoney(player, 10_000);
	SendClientMessage(playerid, "10.000$ переданы игроку %d", player);
	SendClientMessage(playerid, "Игрок %d передал Вам 10.000$", playerid);
}
```
Создание отдельных функций и повторных проверок в данном банальном случае в прицепе не страшны, но они есть. А так же создание и обработка диалога зачатую происходит в разных местах, что затрудняет чтение кода, а то и приводит к ошибкам разработчика, так как ему вечно приходится отвлекаться на разные участки кода.
Самая страшное происходит, когда диалог многоуровневый имею введу, если в самом начале вы проверяете кол-во денег, потом открываете следующий пункт, вы должны проверить не изменились ли данные и находится ли пользователь в пункте легально, а при создании третьего уровня, при обработке "уровня", вы должны убедиться не изменились ли данные в двух остальных, которые на уровень ниже и чего стоит определения действий и кнопок которые возвращают пользовотеля назад или если нужно диалог снова показать. Данные проблемы максимально сложно описать и поймут только те которые сталкивались с такими вопросам.
![[dialogs.png]]
Это количество растёт экспоненциально при увеличении глубины диалога, что рано или поздно ведёт к нарушению логики и трату огромного количества времени.
Я долго думал как решить данные проблемы, как сделать их псевдо асинхрнными !это совершенно не имеет ничего общего с асинхронность и другими терминами !. Написание диалога для меня как серпом по одному месту и ГО разберём что такое LiveDialogs.
```c

CMD:show(playerid) {
	Dialog_Create(playerid, Dialog:Main);
}

dialog Main(playerid) 
{
	Create:<"Диалоговое окно">
	{
		ListItem:<"Пункт 1">
		{
			// код выполнится в случае если игрок выбрал 1й пункт 
			// и нажал правую кнопку
			SendClientMessage(playerid, -1, "Вы нажали выбрали 1й пункт");
			return DIALOG_CLOSE;
		}
		else
		{ 
			// код выполнится в случае если игрок выбрал 1й пункт 
			// и нажал правую кнопку
			SendClientMessage(playerid, -1, "Вы нажали \"Назад\" на 1м пункте");
			return DIALOG_CLOSE;
		}
		
		ListItem:<"Пункт 2">
		{
			// код выполнится в случае если игрок выбрал 2й пункт 
			// и нажал правую кнопку
			SendClientMessage(playerid, -1, "Вы нажали выбрали 2й пункт");
			return DIALOG_CLOSE;
		}
		else
		{ 
			// код выполнится в случае если игрок выбрал 2й пункт 
			// и нажал правую кнопку
			SendClientMessage(playerid, -1, "Вы нажали \"Назад\" на 2м пункте");
			return DIALOG_CLOSE;
		}
		
		ListItem:<"Пункт 3">
		{
			// код выполнится в случае если игрок выбрал 3й пункт 
			// и нажал правую кнопку
			SendClientMessage(playerid, -1, "Вы нажали выбрали 3й пункт");
			return DIALOG_CLOSE;
		}
		else
		{ 
			// код выполнится в случае если игрок выбрал 3й пункт 
			// и нажал правую кнопку
			SendClientMessage(playerid, -1, "Вы нажали \"Назад\" на 3м пункте");
			return DIALOG_CLOSE;
		}
	}
	Button:<"Выбрать", "Назад">;
}
```

### Разберём код

У диалога есть 2 состояния:
**Рендер диалога** и состояние \***нажатой кнопки**\*;

```c
// — ## DIALOG_STYLE_LIST
ListItem:<text[], ...> { /* response left */ } else { /* response right */ }
```
```c
// — ## DIALOG_STYLE_MESSAGEBOX
MessageBox:<text[], ...> { /* response left */ } else { /* response right */ }
```
```c
// — ## DIALOG_STYLE_PASSWORD
InputPassword:<text[], ...> { /* response left */ } else { /* response right */ }
```
```c
// — ## DIALOG_STYLE_INPUT
InputText:<text[], ...> { /* response left */ } else { /* response right */ }
```
```c
// — ## DIALOG_STYLE_TABLIST_HEADERS
ListHead:<text[], ...>;
```

При рендере диалога, код внутри выполнится только тогда, когда будет выбран пункт (нажата левая клавиша);  else — код внутри будет выполнен при нажатии правой кнопки диалога.
```c
ListItem:<string:text[], ...>
```
В большинстве случаев такая конструкция с else не нужна
```c
Create:<"Диалог">
{
	ListItem:<"Пункт 1">
	{
		SendClientMessage(playerid, -1, "Выбран пункт 1");
	}
	else
	{
		return DIALOG_CLOSE;
	}
	ListItem:<"Пункт 2">
	{
		SendClientMessage(playerid, -1, "Выбран пункт 2");
	}
	else
	{
		return DIALOG_CLOSE;
	}
}
```

Вы можете установить действие для клавиши:
ResponseRight / Left:

```c
ResponseRight: { /* код будет выполнен при нажатии правой кнопки */ }
ResponseLeft: { /* код будет выполнен при нажатии левой кнопки */ }
```
#### Пример:

```c
Create:<"Диалог">
{
	ResponseRight: {
		return DIALOG_CLOSE;
		// Теперь, при нажатии правой клавиши диалога, он будет закрываться. 
		// В таком варианте, код ListItem {} else { *этот* } никогда не выполнится,
		// а только в этом месте.
		// Можно использовать конструкцию ниже, наличие скобок не обязательно:
		// ResponseRight:return DIALOG_CLOSE;
	}
	
	ListItem:<"Пункт 1">
	{
		SendClientMessage(playerid, -1, "Выбран пункт 1");
		return DIALOG_CLOSE;
	}
	ListItem:<"Пункт 2">
	{
		SendClientMessage(playerid, -1, "Выбран пункт 2");
		return DIALOG_CLOSE;
	}
}
```

```c
#inclide <YSI_Coding/y_args>
#inclide <LiveDialogs>
```
LiveDialogs поддерживает **va_args**, вы можете форматировать текст для этого подключите va_args из библиотеки YSI и тогда форматирование будет работать иначе делайте самостоятельно:

```c
new list;
ListItem:<"Пункт #%d", ++list>
{

}
ListItem:<"Пункт #%d", ++list>
{

}

> Пункт #1
> Пункт #2
```

В некоторых случаях не целесообразно выполнять код дважды при рендере и при нажатии клавиши, для этого есть DialogRender.

Код внутри выполнится только в том случае, когда идёт отрисовка диалога. Позже поймете почему это может быть важно.

```c
new String256[256]; // к примеру глобальный массив
dialog PlayerInfo(playerid) 
{
	Create:<"Диалог">
	{
		String256[0] = EOS;
		
		DialogRender: {
			// в случае, если игрок нажмет кнопку, 
			// форматирование будет в двух случаях. 
			
			// С данной форматирование будет 1 раз
			new nickname[MAX_PLAYER_NAME];
			GetPlayerName(playerid, nickname);
			format(String256, sizeof String256, 
				"\
					Денег: %d$\n\
					Уровень: %d\n\
					ХП: %.0f\n\
					Броня: %.0f\
				",
				pData[playerid][pMoney],
				pData[playerid][pLevel],
				pData[playerid][pHealth],
				pData[playerid][pArmour],
			);
		}
		MessageBox<String256>
		{
			return DIALOG_CLOSE;
		}
	}
	Button:<"Закрыть">;
}
```

### Циклы

Вы можете использовать циклы, **но обязательно должны в голове держать,** **ИНФОРМАЦИЯ ДОЛЖНА БЫТЬ СТАТИЧНОЙ**, список диалога отрисуется, информация изменится и выбранный пункт будет ошибочным.

```c
dialog ForList(playerid) 
{
	Create:<"Диалоговое окно">
	{
		ResponseRight: return DIALOG_CLOSE;
		for(new i=1; i<4; i++)
		{
			ListItem:<"Пункт %d", i>
			{
				SendClientMessage(playerid, -1, "Вы выбрали %d пункт", i);
				return DIALOG_CLOSE;
			}
		}
	}
	Button:<"Выбрать", "Назад">;
}
```
Вот пример, когда циклы будут работать, но при некоторых обстоятельствах не верно срабатывать:

```c
dialog SelectPlayer(playerid) 
{
	Create:<"Выберите игрока рядом">
	{
		ResponseRight: return DIALOG_CLOSE;
		foreach(new player : StreamedPlayers[playerid])
		{
			new nickname[MAX_PLAYER_NAME];
			GetPlayerName(player, nickname);
			ListItem:<"%s(%d)", nickname, player>
			{
				SendClientMessage(playerid, -1, 
					"Вы выбрали игрока %s(%d)", 
					nickname, player
				);
				return DIALOG_CLOSE;
			}
		}
	}
	Button:<"Выбрать", "Назад">;
}
```
В списке будет 5 пунктов - игроков которые рядом, но перед тем как выбрать игрока, один из списка может покинуть игру и тогда итератор **StreamedPlayers** изменится и будет выбран совершенно другой игрок.

### Коллекции

Вы можете зафиксировать список который, может измениться в течении времени, вот решение проблемы выше:

```c
dialog Collections(playerid) 
{
	Create:<"Выберите игрока рядом">
	{
		ResponseRight: return DIALOG_CLOSE;
		
		DialogRender: {
			foreach(new player : StreamedPlayer[playerid]) {
				DialogCollect:<player>;
			}
		}
		// DialogRender: foreach(new i : StreamedPlayer[playerid]) DialogCollect:<i>;
		// мы как бы зафиксировали данные из StreamedPlayer и теперь он не 
		// изменится
		// обратите внимание, значений в списке столько, сколько будет пунктов!
		// player не нужно объявлять, он объявляется внутри
		DialogCollections:<player> 
		{
			new nickname[MAX_PLAYER_NAME];
			GetPlayerName(player, nickname);
			ListItem:<"%s(%d)", nickname, player>
			{
				if(!IsPlayerConnected(player)) {
					SendClientMessage(playerid, -1, "Игрок покинул игру!");
					return DIALOG_REOPEN; 
					// DIALOG_REOPEN позволяет открыть диалог повторно, 
					// будет собран новый диалог игроков рядом.
				}
				return DIALOG_CLOSE;
			}
		}
	}
	Button:<"Выбрать", "Назад">;
}
```

### Вложенности

Этот код создает основное диалоговое окно с несколькими пунктами для выбора и предоставляет пользователю возможность переходить в дополнительные диалоги. В каждом из них отображается свое сообщение, и пользователь может либо вернуться назад, либо закрыть диалог.
```c
dialog Main(playerid) 
{
	Create:<"Диалоговое окно">
	{
		ListItem:<"Пункт 1">
		{
			Create:<"Диалоговое окно пункта 1">
			{
				DialogResponse:return DIALOG_BACK;
				MessageBox:<"Это диалоговое окно 1го пункта">
				{
					return DIALOG_CLOSE;
				}
			}
			Button:<"Закрыть", "Назад">;
		}
		ListItem:<"Пункт 2">
		{
			Create:<"Диалоговое окно пункта 2">
			{
				DialogResponse:return DIALOG_BACK;
				MessageBox:<"Это диалоговое окно 2го пункта">
				{
					return DIALOG_CLOSE;
				}
			}
			Button:<"Закрыть", "Назад">;
		}
		ListItem:<"Пункт 3">
		{
			Create:<"Диалоговое окно пункта 3">
			{
				DialogResponse:return DIALOG_BACK;
				MessageBox:<"Это диалоговое окно 3го пункта">
				{
					return DIALOG_CLOSE;
				}
			}
			Button:<"Закрыть", "Назад">;
		}
	}
	Button:<"Выбрать", "Закрыть">;
}
```

При выборе любого пункта пользователь "проваливается" в другой диалог с использованием `DIALOG_STYLE_MSGBOX`, где отображается сообщение, как показано в примере. Для навигации между уровнями диалогов используется директива `DIALOG_BACK`. При нажатии на правую кнопку диалог возвращается к предыдущему "Диалоговому окну". Глубина вложенности диалогов ограничена параметром `DIALOG_MAX_DEEP`. 

---

### Возвраты, которые нужно использовать:

- **`DIALOG_CLOSE`** — закрывает диалог полностью;
- **`DIALOG_REOPEN`** — повторно открывает диалог;
- **`DIALOG_BACK`** — возвращает на один уровень выше, повторно отрисовывая диалог;
- **`DIALOG_BACK_BACK`** — возвращает на два уровня выше и перерисовывает диалог;
- **`DIALOG_BACK_BACK_BACK`** — возвращает на три уровня ниже;
- **`DIALOG_BACK_BACK_BACK_BACK`** — возвращает на четыре уровня ниже;
- **`DIALOG_REOPEN_TIME:<milliseconds>`** — повторно открывает диалог через заданное количество миллисекунд;
- **`DIALOG_HIDE`** — скрывает диалог, который можно будет открыть позднее.
В любых других случаев вы получите предупреждение о несоответствии аргументов, а так же диалоги которые подключаете в другой диалог должны быть выше (из примера ForList выше MainMenu)
---
```c
dialog MainMenu(playerid) 
{
	Create:<"Меню игрока">
	{
		ListItem:<"Диалог ForList">
		{
			return ForList(playerid);
		}
		ListItem:<"Диалог Collections">
		{
			return Collections(playerid);
		}
		ListItem:<"Пункт SelectPlayer">
		{
			return SelectPlayer(playerid);
		}
		ListItem:<"Пункт PlayerInfo">
		{
			return PlayerInfo(playerid);
		}
	}
	Button:<"Выбрать", "Закрыть">;
}
```

Вы можете делать ветвления, к примеру некоторые пункты будут доступны всегда, а некоторые только с 5го уровня:
 
```c
dialog MainMenu(playerid) 
{
	Create:<"Меню игрока">
	{
		if(pData[playerid][pLevel] >= 5) 
		{
			// этот пункт будет доступен в том случае, 
			// когда у игрока 5й и более уровень.
			ListItem:<"Диалог ForList">
			{
				return ForList(playerid);
			}
		}
		ListItem:<"Диалог Collections">
		{
			return Collections(playerid);
		}
		ListItem:<"Пункт SelectPlayer">
		{
			return SelectPlayer(playerid);
		}
		ListItem:<"Пункт PlayerInfo">
		{
			return PlayerInfo(playerid);
		}
	}
	Button:<"Выбрать", "Закрыть">;
}
```
Сделаем диалог передачи денег, для примера нужно будет ввести ид игрока (вы можете использовать dialog Collections), после ввести кол-во денег и подтвердить передачу.

```c
dialog GiveMoney(playerid) 
{
	// Первый шаг: ввод ID игрока
	Create:<"Передать денег">
	{
		ResponseRight: return DIALOG_CLOSE;
		
		Input:<"Введите ид игрока:">
		{
			new player = Dialog_Number(playerid);

			if(!IsPlayerConnected(player)) {
				SendClientMessage(playerid, -1, "Игрок не в сети!");
				return DIALOG_REOPEN;
			}
			// Второй шаг: ввод суммы
			Create:<"Передать денег">
			{
				DialogRight: return DIALOG_BACK;
				
				Input:<"Введите сумму которую хотите передать:">
				{
					// Dialog_Number возвращает введёное число
					new money = Dialog_Number(playerid);

					if(money < 0) {
						SendClientMessage(playerid, -1, "Введите более 1$!");
						return DIALOG_REOPEN;
					}
					if(money > pData[playerid][pMoney]) {
						SendClientMessage(playerid, -1, "У Вас нет такой суммы!");
						return DIALOG_REOPEN;
					}
					
					new nickname[MAX_PLAYER_NAME];
					GetPlayerName(player, nickname);
					
					// Третий шаг: подтверждение
					Create:<"Передать денег">
					{
						ResponseRight:return DIALOG_BACK;
						
						new money = Dialog_Number(playerid);
						
						MessageBox:<"\
							Вы действительно хотите передать деньги?\n\
							Игрок: %s (%d)\n\
							Сумма: %d$\
						", nickname, player, money>
						{
							GivePlayerMoney(playerid, -money);
							GivePlayerMoney(player, money);

							SendClientMessage(playerid, -1, 
								"Вы передали %d$ игроку %s (%d)", 
									money, nickname, player
							);

							GetPlayerName(playerid, nickname);
					
							SendClientMessage(playerid, -1, 
								"Игрок %s(%d) передал Вам %d рублей", 
									nickname, playerid, money
							);
							
							return DIALOG_CLOSE;
						}
					}
					Button:<"Передать", "Назад">;
				}
			}
			Button:<"Далее", "Назад">;
		}
	}
	Button:<"Выбрать", "Назад">;
}
```

Заметьте, что перед передачей денег через `Player_GiveMoney` нет необходимости дополнительно проверять, находится ли игрок в сети или имеет ли он достаточно средств, так как все необходимые проверки уже выполняются в момент нажатия на кнопку "передать". Как было отмечено ранее, директивы `DialogRender` и `DialogCollections` особенно важны, так как позволяют выполнить тяжелый код всего один раз — в момент рендера диалога.

### Запросы в базу данных

Вы можете \*выдергивать\* данные из sql асинхронными запросами вот пример:

```c
// вынес в переменную просто перекидывается на другую строку в редакторе MD :)
static query_top_10[] = "\
	SELECT `nickname`, `money` \
	FROM `accounts` \
	ORDER BY `money` desc LIMIT 10;\
";

dialog PlayersTopMoney(playerid) 
{
	Create:<"Топ 10 богатых игроков">
	{
		ResponseRight:return DIALOG_CLOSE;
		
		DialogQuery:<mysqlconnect, query_top_10>;

		new rows = cache_num_rows();
		
		if(rows == 0) {
			DialogMessgbox:<"В таблице `accounts` нет записей"> {
				return DIALOG_CLOSE;
			}
		}
		// сделаем список DIALOG_STYLE_TABLIST_HEADER
		DialogHead:<"Игрок\tСумма">;
		for(new i; i<rows; i++) 
		{
			cache_get_value_name(i, "nickname", nickname);
			cache_get_value_int(i, "money", money);

			if(i < 3)
			{
				// покрасим топ 3 в жёлтый цвет
				ListItem:<"{FFCC47}%d{FFFFFF}. %s\t%d$", i+1, nickname, money>
				{
					SendClientMessage(playerid, -1, "Игрок %s входит в топ 3 богатейших игроков, занимая %d место.", nickname, i+1);
					return DIALOG_REOPEN;
					);
				}
			}
			else
			{
				ListItem:<"%d. %s\t%d$", i+1, nickname, money>
				{
					SendClientMessage(playerid, -1, "Игрок %s входит в топ 10 богатейших игроков, занимая %d место.", nickname, i+1);
					return DIALOG_REOPEN;
				}
			}
		}
	}
	Button:<"Выбрать", "Закрыть">;
}
```

DialogQuery кэширует запросы, Директива DIALOG_REOPEN, DIALOG_BACK очищают его только в том случае, если возврат произошел на уровень ниже диалога где выполнен запрос.

Важно: в диалоге может быть только один вызов DialogQuery.

Например, при выборе игрока можно получить дополнительную информацию через отдельную функцию для диалога.

```c

// вынес в переменную просто перекидывается на другую строку в редакторе MD :)
static query_account[] = "\
	SELECT * FROM `accounts` WHERE `id` = %d\
";

dialog PlayersTopMoney(playerid, accountid) 
{
	Create:<"Информация о игроке">
	{
		ResponseRight:return DIALOG_CLOSE;
		
		DialogQuery:<mysqlconnect, query_account, accountid>;
		
		if(cache_num_rows() == 0) {
			DialogMessgbox:<"Аккаунт %d не найден", accountid> {
				return DIALOG_CLOSE;
			}
		}
		
		DialogRender: 
		{
			new nickname[MAX_PLAYER_NAME],
				money,
				level,
				bank,
				ip,
				registation[32]
			;
			
			cache_get_value_name_name(i, "nickname", nickname);
			cache_get_value_name_int(i, "money", money);
			cache_get_value_name_int(i, "level", level);
			cache_get_value_name_int(i, "bank", bank);
			cache_get_value_name(i, "ip", ip);
			cache_get_value_name_int(i, "registation", registation);
			
			format(String1024, sizeof String1024, 
				"\
					Ид аккаунта: %d\n\
					Ник: %s\n\
					Уровень: %d\n\
					На руках: %d$\n\
					В банке: %d$\n\
					IP: %s\n\
					Зарегистрирован: %s\
				",
				accountid,
				nickname,
				level,
				bank,
				ip,
				registration
			);
		}
		MessageBox:<String1024>
		{
			return DIALOG_BACK;
		}
	}
	Button:<"Выбрать", "Закрыть">;
}
```

Теперь добавим этот диалог в PlayersTopMoney:

```c
dialog PlayersTopMoney(playerid) 
{
	Create:<"Топ 10 богатых игроков">
	{
		ResponseRight:return DIALOG_CLOSE;
		
		DialogQuery:<mysqlconnect, query_top_10>;

		new rows = cache_num_rows();
		
		if(rows == 0) {
			DialogMessgbox:<"В таблице `accounts` нет записей"> {
				return DIALOG_CLOSE;
			}
		}
		// сделаем список DIALOG_STYLE_TABLIST_HEADER
		DialogHead:<"Игрок\tСумма">;
		for(new i; i<rows; i++) 
		{
			cache_get_value_name(i, "id", accountid);
			cache_get_value_name(i, "nickname", nickname);
			cache_get_value_int(i, "money", money);

			ListItem:<"{%s}%d{FFFFFF}. %s\t%d$", i<3?("FFCC46"):("FFFFFF"), i+1, nickname, money>
			{
				return PlayersTopMoney(playerid, accountid);
			}
		}
	}
	Button:<"Выбрать", "Закрыть">;
}
```
