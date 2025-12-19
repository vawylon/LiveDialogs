# LiveDialogs

**Languages:** [English](README.en.md) | [Русский](README.ru.md)

#### EN
LiveDialogs — Allows you to write multi-level dialogs in a single function without duplicating logic between “opening” and “handling the response”.

#### RU
LiveDialogs — Позволяет писать многоуровневые диалоги в одной функции и без дублирования логики между “открытием” и “обработкой ответа”, а так же совершать асинхронные запросы.

---

## Example:

```c
CMD:menu(playerid) {
    Dialog_Create(playerid, Dialog:Menu);
}

dialog Menu(playerid)
{
    Create:<"Money">
    {
        // when pressing "Back" we will close the dialog
        ResponseRight: return DIALOG_CLOSE;

        // using a loop we create 10 items
        for (new i = 1, amount; i <= 10; i++) {
            new amount = i * 20000;
            ListItem:<"Get %d$", amount>
            {
                GivePlayerMoney(playerid, amount);
                SendClientMessage(playerid, -1, "You received {44FF44}%d$", amount);
                return DIALOG_REOPEN; // Reopen the dialog
            }
        }

        ListItem:<"Experience">
        {
            // Dialog when selecting the "Experience" item
            Create:<"Get experience">
            {
                // Go back in case "Back" is pressed
                ResponseRight: return DIALOG_BACK;

                ListItem:<"1 EXP">
                {
                    SetPlayerLevel(playerid, GetPlayerLevel(playerid) + 1);
                    SendClientMessage(playerid, -1, "You received {FFCC44}%d EXP", 1);
                    return DIALOG_BACK;
                }

                ListItem:<"Enter value">
                {
                    // Create a dialog when selecting value input
                    Create:<"Get experience">
                    {
                        // Go back in case "Back" is pressed
                        ResponseRight: return DIALOG_BACK;

                        InputText:<"Enter amount of experience">
                        {
                            new exp = Dialog_Number(playerid);
                            if (exp <= 0)
                            {
                                // Reopen the dialog if the number is not valid
                                SendClientMessage(playerid, -1, "Invalid value entered!");
                                return DIALOG_REOPEN;
                            }

                            SetPlayerLevel(playerid, GetPlayerLevel(playerid) + exp);
                            SendClientMessage(playerid, -1, "You received {FFCC44}%d EXP", exp);

                            return DIALOG_BACK;
                        }
                    }
                    Button:<"Give", "Back">;
                }
            }
            Button:<"Select", "Back">;
        }
    }
    Button:<"Select", "Close">;
}
```

---

## Пример:

```c
CMD:menu(playerid) {
    Dialog_Create(playerid, Dialog:Menu);
}

dialog Menu(playerid)
{
    Create:<"Деньги">
    {
        // при нажатии "Назад" закроем диалог
        ResponseRight: return DIALOG_CLOSE;

        // с помощью цикла создаём 10 пунктов
        for (new i = 1, amount; i <= 10; i++) {
            new amount = i * 20000;
            ListItem:<"Получить %d$", amount>
            {
                GivePlayerMoney(playerid, amount);
                SendClientMessage(playerid, -1, "Вы получили {44FF44}%d$", amount);
                return DIALOG_REOPEN; // Открываем диалог заново
            }
        }

        ListItem:<"Опыт">
        {
            // Диалог при выборе пункта "Опыт"
            Create:<"Получить опыт">
            {
                // Вернёмся назад в случае нажатия "Назад"
                ResponseRight: return DIALOG_BACK;

                ListItem:<"1 EXP">
                {
                    SetPlayerLevel(playerid, GetPlayerLevel(playerid) + 1);
                    SendClientMessage(playerid, -1, "Вы получили {FFCC44}%d EXP", 1);
                    return DIALOG_BACK;
                }

                ListItem:<"Ввести значение">
                {
                    // Создаём диалог при выборе ввода значения
                    Create:<"Получить опыт">
                    {
                        // Вернёмся назад в случае выбора "Назад"
                        ResponseRight: return DIALOG_BACK;

                        InputText:<"Введите кол-во опыта">
                        {
                            new exp = Dialog_Number(playerid);
                            if (exp <= 0)
                            {
                                // Откроем дмалог повторно, в случае если число не валидное
                                SendClientMessage(playerid, -1, "Введено неверное значение!");
                                return DIALOG_REOPEN;
                            }

                            SetPlayerLevel(playerid, GetPlayerLevel(playerid) + exp);
                            SendClientMessage(playerid, -1, "Вы получили {FFCC44}%d EXP", exp);

                            return DIALOG_BACK;
                        }
                    }
                    Button:<"Выдать", "Назад">;
                }
            }
            Button:<"Выбрать", "Назад">;
        }
    }
    Button:<"Выбрать", "Закрыть">;
}

```
