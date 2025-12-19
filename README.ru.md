
---

Используя любой диалоговый «движок», вы упираетесь в то, что при создании диалога и при обработке нажатия приходится выполнять одни и те же проверки. Например, возьмём популярный инклюд для диалогов — **mdialogs**:

```c
DialogCreate:Main(playerid)
{
    if (GetPlayerMoney(playerid) < 10_000) {
        SendClientMessage(playerid, 0xFF0000FF, "У Вас нет 10.000$");
        return 1;
    }

    Dialog_Open(playerid, Dialog:Main, DIALOG_STYLE_INPUT,
        "Дать денег",
        "\
            Введите ID игрока, которому хотите передать 10.000$:\
        ",
        "Выдать", "Закрыть"
    );
    return 1;
}

DialogResponse:Main(playerid, response, listitem, inputtext[])
{
    // response == 1 — нажата левая кнопка ("Выдать")
    // response == 0 — нажата правая кнопка ("Закрыть")
    if (!response) return 1;

    if (GetPlayerMoney(playerid) < 10_000) {
        SendClientMessage(playerid, 0xFF0000FF, "У Вас нет 10.000$");
        return 1;
    }

    new player = strval(inputtext);
    if (!IsPlayerConnected(player)) {
        SendClientMessage(playerid, 0xFF0000FF, "Игрок не в сети.");
        Dialog_Show(playerid, Dialog:Main);
        return 1;
    }

    GivePlayerMoney(playerid, -10_000);
    GivePlayerMoney(player, 10_000);

    new msg[128];
    format(msg, sizeof msg, "10.000$ переданы игроку %d", player);
    SendClientMessage(playerid, -1, msg);

    format(msg, sizeof msg, "Игрок %d передал Вам 10.000$", playerid);
    SendClientMessage(player, -1, msg);

    return 1;
}
```

Создание отдельных функций и повторные проверки в данном банальном случае, в принципе, не страшны — но они есть. А также создание и обработка диалога зачастую происходят в разных местах, что затрудняет чтение кода, а иногда и приводит к ошибкам разработчика, потому что ему постоянно приходится отвлекаться на разные участки.

Самое страшное начинается, когда диалог многоуровневый. Имею в виду: если в самом начале вы проверяете количество денег, затем открываете следующий пункт — вы должны проверить, не изменились ли данные, и находится ли пользователь в этом пункте «легально». А при создании третьего уровня, при обработке «уровня», вы должны убедиться, что данные не изменились ещё и в двух остальных уровнях ниже. И чего только стоит определение действий и кнопок, которые возвращают пользователя назад, или ситуация, когда нужно заново показать диалог.

Эти проблемы сложно описать — и поймут их только те, кто действительно сталкивался с таким.

![[dialogs.png]]

Количество проверок растёт экспоненциально при увеличении глубины диалога, что рано или поздно ведёт к нарушению логики и трате огромного количества времени.

Я долго думал, как решить эти проблемы: как сделать диалоги «псевдо-асинхронными» (это совершенно не имеет ничего общего с асинхронностью и другими терминами). Написание диалогов для меня — как серпом по одному месту, так что разберём, что такое **LiveDialogs**.

```c
CMD:show(playerid)
{
    Dialog_Create(playerid, Dialog:Main);
    return 1;
}

dialog Main(playerid)
{
    Create:<"Диалоговое окно">
    {
        ListItem:<"Пункт 1">
        {
            // Код выполнится, если игрок выбрал пункт 1 и нажал ЛЕВУЮ кнопку.
            SendClientMessage(playerid, -1, "Вы нажали \"Выбрать\" на пункте 1");
            return DIALOG_CLOSE;
        }
        else
        {
            // Код выполнится, если игрок выбрал пункт 1 и нажал ПРАВУЮ кнопку.
            SendClientMessage(playerid, -1, "Вы нажали \"Назад\" на пункте 1");
            return DIALOG_CLOSE;
        }

        ListItem:<"Пункт 2">
        {
            SendClientMessage(playerid, -1, "Вы нажали \"Выбрать\" на пункте 2");
            return DIALOG_CLOSE;
        }
        else
        {
            SendClientMessage(playerid, -1, "Вы нажали \"Назад\" на пункте 2");
            return DIALOG_CLOSE;
        }

        ListItem:<"Пункт 3">
        {
            SendClientMessage(playerid, -1, "Вы нажали \"Выбрать\" на пункте 3");
            return DIALOG_CLOSE;
        }
        else
        {
            SendClientMessage(playerid, -1, "Вы нажали \"Назад\" на пункте 3");
            return DIALOG_CLOSE;
        }
    }
    Button:<"Выбрать", "Назад">;
}
```

## Разберём код

У диалога есть 2 состояния:

* **Рендер диалога**
* **Состояние нажатой кнопки**

```c
// — DIALOG_STYLE_LIST
ListItem:<text[], ...> { /* response left */ } else { /* response right */ }
// — DIALOG_STYLE_MSGBOX
MessageBox:<text[], ...> { /* response left */ } else { /* response right */ }
// — DIALOG_STYLE_PASSWORD
InputPassword:<text[], ...> { /* response left */ } else { /* response right */ }
// — DIALOG_STYLE_INPUT
InputText:<text[], ...> { /* response left */ } else { /* response right */ }
// — DIALOG_STYLE_TABLIST_HEADERS
ListHead:<text[], ...>;
```

При рендере диалога код внутри выполнится только тогда, когда будет выбран пункт (нажата **левая** кнопка). `else` — код внутри выполнится при нажатии **правой** кнопки диалога.

```c
ListItem:<string:text[], ...>
```

В большинстве случаев такая конструкция с `else` не нужна.

Вы можете установить действие для клавиш через `ResponseRight / ResponseLeft`:

```c
ResponseRight: { /* код будет выполнен при нажатии правой кнопки */ }
ResponseLeft:  { /* код будет выполнен при нажатии левой кнопки */ }
```

### Пример

```c
Create:<"Диалог">
{
    ResponseRight:
    {
        // Теперь при нажатии правой кнопки диалог будет закрываться.
        // В таком варианте код из `ListItem {} else { ... }` для правой кнопки
        // никогда не выполнится — обработка будет только здесь.
        return DIALOG_CLOSE;
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
#include <YSI_Coding\y_va>
#include <LiveDialogs>
```

LiveDialogs поддерживает **va_args**. Вы можете форматировать текст напрямую. Для этого подключите `y_va` из YSI — иначе форматируйте вручную:

```c
new list;
ListItem:<"Пункт #%d", ++list> { }
ListItem:<"Пункт #%d", ++list> { }

// Пункт #1
// Пункт #2
```

## DialogRender

В некоторых случаях нецелесообразно выполнять один и тот же код дважды — при рендере и при нажатии клавиши. Для этого существует **DialogRender**.

Код внутри выполнится только в момент отрисовки диалога. Позже вы поймёте, почему это может быть важно.

```c
new String256[256]; // к примеру, глобальный буфер

dialog PlayerInfo(playerid)
{
    Create:<"Диалог">
    {
        String256[0] = EOS;

        DialogRender:
        {
            // В случае, если игрок нажмёт кнопку, форматирование могло бы
            // выполниться дважды. С DialogRender форматирование будет один раз.
            new nickname[MAX_PLAYER_NAME];
            GetPlayerName(playerid, nickname);

            format(String256, sizeof String256,
                "\
                    Ник: %s\n\
                    Денег: %d$\n\
                    Уровень: %d\n\
                    ХП: %.0f\n\
                    Броня: %.0f\
                ",
                nickname,
                pData[playerid][pMoney],
                pData[playerid][pLevel],
                pData[playerid][pHealth],
                pData[playerid][pArmour]
            );
        }

        MessageBox:<String256>
        {
            return DIALOG_CLOSE;
        }
    }
    Button:<"Закрыть">;
}
```

## Циклы

Вы можете использовать циклы, но обязательно должны держать в голове: **информация должна быть статичной**. Иначе получится так: список диалога отрисовался, затем информация изменилась — и выбранный пункт окажется неверным.

```c
dialog ForList(playerid)
{
    Create:<"Диалоговое окно">
    {
        ResponseRight: return DIALOG_CLOSE;

        for (new i = 1; i < 4; i++)
        {
            ListItem:<"Пункт %d", i>
            {
                SendClientMessagef(playerid, -1, "Вы выбрали пункт %d", i);
                return DIALOG_CLOSE;
            }
        }
    }
    Button:<"Выбрать", "Назад">;
}
```

Вот пример, когда циклы будут работать, но при некоторых обстоятельствах могут срабатывать неверно:

```c
dialog SelectPlayer(playerid)
{
    Create:<"Выберите игрока рядом">
    {
        ResponseRight: return DIALOG_CLOSE;

        foreach (new player : StreamedPlayers[playerid])
        {
            new nickname[MAX_PLAYER_NAME];
            GetPlayerName(player, nickname);

            ListItem:<"%s(%d)", nickname, player>
            {
                SendClientMessagef(playerid, -1,
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

В списке будет 5 пунктов — игроков, которые находятся рядом. Но перед тем, как выбрать игрока, один из них может выйти из игры. Тогда итератор **StreamedPlayers** изменится, и в итоге будет выбран уже совершенно другой игрок.

## Коллекции

Вы можете «зафиксировать» список, который может измениться со временем. Вот решение проблемы выше:

```c
dialog Collections(playerid)
{
    Create:<"Выберите игрока рядом">
    {
        ResponseRight: return DIALOG_CLOSE;

        DialogRender:
        {
            foreach (new player : StreamedPlayers[playerid])
            {
                DialogCollect:<player>;
            }
        }

        // Мы как бы зафиксировали данные из StreamedPlayers, и теперь они не изменятся.
        // Обратите внимание: значений в коллекции ровно столько, сколько будет пунктов!
        // `player` объявлять не нужно — он объявляется внутри.
        DialogCollections:<player>
        {
            new nickname[MAX_PLAYER_NAME];
            GetPlayerName(player, nickname);

            ListItem:<"%s(%d)", nickname, player>
            {
                if (!IsPlayerConnected(player)) {
                    SendClientMessage(playerid, -1, "Игрок покинул игру!");
                    // DIALOG_REOPEN позволяет открыть диалог повторно,
                    // и собрать новый список игроков рядом.
                    return DIALOG_REOPEN;
                }

                return DIALOG_CLOSE;
            }
        }
    }
    Button:<"Выбрать", "Назад">;
}
```

## Вложенности

Этот код создаёт основное диалоговое окно с несколькими пунктами выбора и позволяет пользователю переходить в дополнительные диалоги. В каждом из них отображается своё сообщение, а пользователь может либо вернуться назад, либо закрыть диалог.

```c
dialog Main(playerid)
{
    Create:<"Диалоговое окно">
    {
        ListItem:<"Пункт 1">
        {
            Create:<"Диалоговое окно пункта 1">
            {
                ResponseRight: return DIALOG_BACK;

                MessageBox:<"Это диалоговое окно 1-го пункта">
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
                ResponseRight: return DIALOG_BACK;

                MessageBox:<"Это диалоговое окно 2-го пункта">
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
                ResponseRight: return DIALOG_BACK;

                MessageBox:<"Это диалоговое окно 3-го пункта">
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

При выборе любого пункта пользователь «проваливается» в другой диалог с использованием `DIALOG_STYLE_MSGBOX`, где отображается сообщение, как показано в примере. Для навигации между уровнями диалогов используется директива `DIALOG_BACK`. При нажатии на правую кнопку диалог возвращается к предыдущему «диалоговому окну». Глубина вложенности диалогов ограничена параметром `DIALOG_MAX_DEEP`.

---

## Возвраты, которые нужно использовать

* **`DIALOG_CLOSE`** — закрывает диалог полностью;
* **`DIALOG_REOPEN`** — повторно открывает диалог;
* **`DIALOG_BACK`** — возвращает на один уровень выше, повторно отрисовывая диалог;
* **`return DialogGoto:<deep>;`** — открывает указанный диалог уровнем ниже;
* **`DIALOG_REOPEN_TIME:<milliseconds>`** — повторно открывает диалог через заданное количество миллисекунд;
* **`DIALOG_HIDE`** — скрывает диалог (его можно будет открыть позже).

Во всех остальных случаях вы получите предупреждение о несоответствии аргументов. Также диалоги, которые вы подключаете в другой диалог, должны располагаться выше по коду (как в примере: **ForList** выше **MainMenu**).

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
        ListItem:<"Диалог SelectPlayer">
        {
            return SelectPlayer(playerid);
        }
        ListItem:<"Диалог PlayerInfo">
        {
            return PlayerInfo(playerid);
        }
    }
    Button:<"Выбрать", "Закрыть">;
}
```

Вы можете делать ветвления: например, часть пунктов будет доступна всегда, а часть — только начиная с 5-го уровня.

```c
dialog MainMenu(playerid)
{
    Create:<"Меню игрока">
    {
        if (pData[playerid][pLevel] >= 5)
        {
            // Этот пункт будет доступен, когда у игрока 5-й и выше уровень.
            ListItem:<"Диалог ForList">
            {
                return ForList(playerid);
            }
        }

        ListItem:<"Диалог Collections">
        {
            return Collections(playerid);
        }
        ListItem:<"Диалог SelectPlayer">
        {
            return SelectPlayer(playerid);
        }
        ListItem:<"Диалог PlayerInfo">
        {
            return PlayerInfo(playerid);
        }
    }
    Button:<"Выбрать", "Закрыть">;
}
```

## Пример: передача денег

Сделаем диалог передачи денег: сначала вводим ID игрока (можно через **Dialog Collections**), затем сумму и подтверждаем передачу.

```c
dialog GiveMoney(playerid)
{
    // Шаг 1: ввод ID игрока
    Create:<"Передать деньги">
    {
        ResponseRight: return DIALOG_CLOSE;

        InputText:<"Введите ID игрока:">
        {
            new player = Dialog_Number(playerid);
            if (!IsPlayerConnected(player)) {
                SendClientMessage(playerid, -1, "Игрок не в сети!");
                return DIALOG_REOPEN;
            }

            // Шаг 2: ввод суммы
            Create:<"Передать деньги">
            {
                ResponseRight: return DIALOG_BACK;

                InputText:<"Введите сумму, которую хотите передать:">
                {
                    new money = Dialog_Number(playerid);

                    if (money <= 0) {
                        SendClientMessage(playerid, -1, "Введите сумму больше 0$!");
                        return DIALOG_REOPEN;
                    }
                    if (money > pData[playerid][pMoney]) {
                        SendClientMessage(playerid, -1, "У Вас нет такой суммы!");
                        return DIALOG_REOPEN;
                    }

                    new nickname[MAX_PLAYER_NAME];
                    GetPlayerName(player, nickname);

                    // Шаг 3: подтверждение
                    Create:<"Передать деньги">
                    {
                        ResponseRight: return DIALOG_BACK;

                        MessageBox:<"\
                            Вы действительно хотите передать деньги?\n\
                            Игрок: %s (%d)\n\
                            Сумма: %d$\
                        ", nickname, player, money>
                        {
                            GivePlayerMoney(playerid, -money);
                            GivePlayerMoney(player, money);

                            SendClientMessagef(playerid, -1,
                                "Вы передали %d$ игроку %s (%d)",
                                money, nickname, player
                            );

                            GetPlayerName(playerid, nickname);
                            SendClientMessagef(player, -1,
                                "Игрок %s(%d) передал Вам %d$",
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

Обратите внимание: директивы `DialogRender` и `DialogCollections` особенно важны, потому что позволяют выполнить тяжёлый код всего один раз — в момент рендера диалога.

---

## Запросы в базу данных

Вы можете «выдёргивать» данные из SQL асинхронными запросами. Пример:

```c
// Вынесено в переменную (в редакторе MD так удобнее читать)
static query_top_10[] = "\
    SELECT `id`, `nickname`, `money` \
    FROM `accounts` \
    ORDER BY `money` DESC \
    LIMIT 10;\
";

dialog PlayersTopMoney(playerid)
{
    Create:<"Топ 10 богатых игроков">
    {
        ResponseRight: return DIALOG_CLOSE;

        DialogQuery:<mysqlconnect, query_top_10>;
        new rows = cache_num_rows();

        if (rows == 0)
        {
            MessageBox:<"В таблице `accounts` нет записей">
            {
                return DIALOG_CLOSE;
            }
        }

        // DIALOG_STYLE_TABLIST_HEADERS
        ListHead:<"Игрок\tСумма">;

        new nickname[MAX_PLAYER_NAME];
        new money, accountid;

        for (new i = 0; i < rows; i++)
        {
            cache_get_value_int(i, "id", accountid);
            cache_get_value_name(i, "nickname", nickname);
            cache_get_value_int(i, "money", money);

            ListItem:<"{%s}%d{FFFFFF}. %s\t%d$",
                (i < 3) ? ("FFCC47") : ("FFFFFF"),
                i + 1, nickname, money>
            {
                return PlayerAccountInfo(playerid, accountid);
            }
        }
    }
    Button:<"Выбрать", "Закрыть">;
}
```

**DialogQuery** кэширует результат запроса. Кэш можно удалять вручную, если вам нужно заново получить данные на той же глубине (пример ниже).

```c
dialog DestroyAccount(playerid)
{
    Create:<"Диалог 1">
    {
        ResponseRight: return DIALOG_BACK;

        MessageBox:<"Текст">
        {
            Create:<"Диалог 2">
            {
                ResponseRight: return DIALOG_BACK;

                DialogQuery:<mysql, "SELECT * FROM `accounts` LIMIT 15">;

                // Получаем глубину диалога (id)
                new deepid = Dialog_GetDeep(playerid);

                new rows = cache_num_rows();
                new str[128];

                for (new i; i < rows; i++)
                {
                    new nickname[MAX_PLAYER_NAME], id;
                    cache_get_value_name(i, "pNickName", nickname);
                    cache_get_value_name_int(i, "pMysqlID", id);

                    ListItem:<nickname>
                    {
                        Create:<"Удаление аккаунта">
                        {
                            ResponseRight: return DIALOG_BACK;

                            DialogRender:
                            {
                                format(str, sizeof str, "Вы действительно хотите удалить аккаунт %s?", nickname);
                            }

                            MessageBox:<str>
                            {
                                format(str, sizeof str, "DELETE FROM `accounts` WHERE `pMysqlID`=%d", id);
                                mysql_tquery(mysql, str);

                                // Если мы возвращаемся в диалог с кэшем, а нам нужны новые данные —
                                // кэш можно удалить вручную.
                                Dialog_CacheDestroy(playerid, deepid);

                                return DialogGoto:<deepid>;
                            }
                        }
                        Button:<"Удалить", "Назад">;
                    }
                }
            }
            Button:<"Выбрать", "Назад">;
        }
    }
    Button:<"Выбрать", "Закрыть">;
}
```

Важно: в одном диалоге может быть только один вызов **DialogQuery**.

Например, при выборе игрока можно получить дополнительную информацию через отдельную функцию/диалог:

```c
static query_account[] = "\
    SELECT * FROM `accounts` WHERE `id` = %d\
";

dialog PlayerAccountInfo(playerid, accountid)
{
    Create:<"Информация об игроке">
    {
        ResponseRight: return DIALOG_BACK;

        DialogQuery:<mysqlconnect, query_account, accountid>;

        if (cache_num_rows() == 0)
        {
            MessageBox:<"Аккаунт %d не найден", accountid>
            {
                return DIALOG_BACK;
            }
        }

        new String1024[1024];

        DialogRender:
        {
            // Обычно это строка 0, т.к. выборка по id
            new row = 0;

            new nickname[MAX_PLAYER_NAME];
            new money, level, bank;
            new ip[32];
            new registration[32];

            cache_get_value_name(row, "nickname", nickname);
            cache_get_value_int(row, "money", money);
            cache_get_value_int(row, "level", level);
            cache_get_value_int(row, "bank", bank);
            cache_get_value_name(row, "ip", ip);
            cache_get_value_name(row, "registration", registration);

            format(String1024, sizeof String1024,
                "\
                    ID аккаунта: %d\n\
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
                money,
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
    Button:<"Назад", "Закрыть">;
}
```

Теперь диалог `PlayerAccountInfo` уже подключён в `PlayersTopMoney` в обработчике пункта списка (см. пример выше).

---