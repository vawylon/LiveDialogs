# LiveDialogs

A dialog DSL for Pawn (SA-MP / open.mp) that helps you write multi-step dialogs in a single readable flow, without duplicating checks across “create” and “response” handlers.

**Languages:** [English](README_en.md) | [Русский](README.ru.md)

---

## Why LiveDialogs?

With most dialog “engines” you eventually hit the same wall:

- You repeat the same validations **when opening** a dialog and **when handling** the response.
- Dialog rendering and response logic often live in different places → harder to read, easier to break.
- With multi-level dialogs the amount of checks and “back/next/reopen” routing grows **exponentially**.

LiveDialogs aims to keep dialog logic **linear**, **local**, and **safe** by splitting dialog execution into two clear phases: **render** and **response**.

---

## Core idea

A dialog has **two states**:

1. **Render phase** — building the UI text/items
2. **Response phase** — executing the block that matches the user’s choice

Supported building blocks (examples):

```c
// DIALOG_STYLE_LIST
ListItem:<text[], ...> { /* left button */ } else { /* right button */ }

// DIALOG_STYLE_MSGBOX
MessageBox:<text[], ...> { /* left */ } else { /* right */ }

// DIALOG_STYLE_PASSWORD
InputPassword:<text[], ...> { /* left */ } else { /* right */ }

// DIALOG_STYLE_INPUT
InputText:<text[], ...> { /* left */ } else { /* right */ }

// DIALOG_STYLE_TABLIST_HEADERS
ListHead:<text[], ...>;
```

During response:

* the main block runs for the **left** button
* `else` runs for the **right** button

In many cases you don’t want per-item `else`. Use global button handlers instead:

```c
ResponseRight: { /* runs when right button is pressed */ }
ResponseLeft:  { /* runs when left button is pressed */ }
```

---

## Installation

1. Copy `LiveDialogs.inc` into your includes.
2. Include it in your gamemode:

```c
#include <LiveDialogs>
```

### Optional: `va_args` formatting (recommended)

LiveDialogs supports `va_args` formatting for text. If you want to use `"%d"`, `"%s"`, etc. directly inside `ListItem`, `MessageBox`, etc., include YSI `y_va`:

```c
#include <YSI_Coding\y_va>
#include <LiveDialogs>
```

If you don’t include `y_va`, format strings manually into buffers.

---

## Quick start

```c
CMD:show(playerid)
{
    Dialog_Create(playerid, Dialog:Main);
    return 1;
}

dialog Main(playerid)
{
    Create:<"Main menu">
    {
        ResponseRight: return DIALOG_CLOSE;

        ListItem:<"Item 1">
        {
            SendClientMessage(playerid, -1, "You selected item 1");
            return DIALOG_CLOSE;
        }

        ListItem:<"Item 2">
        {
            SendClientMessage(playerid, -1, "You selected item 2");
            return DIALOG_CLOSE;
        }
    }
    Button:<"Select", "Close">;
}
```

---

## `DialogRender` (do heavy work once)

Sometimes you don’t want to run the same heavy code twice (once while rendering, and again when the player clicks a button).
`DialogRender` executes **only during rendering**.

```c
new PlayerInfoText[512];

dialog PlayerInfo(playerid)
{
    Create:<"Player info">
    {
        PlayerInfoText[0] = EOS;

        DialogRender:
        {
            new nickname[MAX_PLAYER_NAME];
            GetPlayerName(playerid, nickname);

            format(PlayerInfoText, sizeof PlayerInfoText,
                "\
                    Nick: %s\n\
                    Money: %d$\n\
                    Level: %d\
                ",
                nickname,
                pData[playerid][pMoney],
                pData[playerid][pLevel]
            );
        }

        MessageBox:<PlayerInfoText>
        {
            return DIALOG_CLOSE;
        }
    }
    Button:<"Close">;
}
```

---

## Loops and “static data” problem

You **can** build lists with loops, but remember:

> The data used to build the list must stay **static** until the player selects an item.

Example of a risky list:

```c
dialog SelectNearbyPlayer(playerid)
{
    Create:<"Select a nearby player">
    {
        ResponseRight: return DIALOG_CLOSE;

        foreach (new player : StreamedPlayers[playerid])
        {
            new name[MAX_PLAYER_NAME];
            GetPlayerName(player, name);

            ListItem:<"%s (%d)", name, player>
            {
                // PROBLEM: if someone leaves, StreamedPlayers iterator can change,
                // and the selected index may map to a different player.
                return DIALOG_CLOSE;
            }
        }
    }
    Button:<"Select", "Back">;
}
```

---

## Collections: snapshot changing lists (`DialogCollect` / `DialogCollections`)

To “freeze” a dynamic list (players nearby, streamed entities, etc.), collect IDs during render and iterate over the frozen collection during response.

```c
dialog CollectionsExample(playerid)
{
    Create:<"Select a nearby player">
    {
        ResponseRight: return DIALOG_CLOSE;

        DialogRender:
        {
            foreach (new player : StreamedPlayers[playerid])
            {
                DialogCollect:<player>;
            }
        }

        DialogCollections:<player>
        {
            new name[MAX_PLAYER_NAME];
            GetPlayerName(player, name);

            ListItem:<"%s (%d)", name, player>
            {
                if (!IsPlayerConnected(player))
                {
                    SendClientMessage(playerid, -1, "Player left the server!");
                    return DIALOG_REOPEN; // rebuild list
                }
                return DIALOG_CLOSE;
            }
        }
    }
    Button:<"Select", "Back">;
}
```

---

## Nesting and navigation

You can open dialogs inside dialogs (multi-level flows). Navigation helpers:

* `DIALOG_CLOSE` — close dialog completely
* `DIALOG_REOPEN` — reopen the current dialog (re-render)
* `DIALOG_BACK` — go one level up and re-render
* `return DialogGoto:<deep>;` — jump to a specific depth (one level below)
* `DIALOG_REOPEN_TIME:<milliseconds>` — reopen after delay
* `DIALOG_HIDE` — hide dialog to show later

Depth is limited by `DIALOG_MAX_DEEP`.

### Simple nested example

```c
dialog Main(playerid)
{
    Create:<"Menu">
    {
        ListItem:<"Item 1">
        {
            Create:<"Item 1">
            {
                ResponseRight: return DIALOG_BACK;

                MessageBox:<"This is item 1 dialog">
                {
                    return DIALOG_CLOSE;
                }
            }
            Button:<"Close", "Back">;
        }
    }
    Button:<"Select", "Close">;
}
```

---

## Example: money transfer “wizard”

Flow:

1. enter target player id (or use Collections)
2. enter amount
3. confirm

```c
dialog GiveMoney(playerid)
{
    Create:<"Transfer money">
    {
        ResponseRight: return DIALOG_CLOSE;

        InputText:<"Enter player ID:">
        {
            new target = Dialog_Number(playerid);
            if (!IsPlayerConnected(target))
            {
                SendClientMessage(playerid, -1, "Player is not online!");
                return DIALOG_REOPEN;
            }

            Create:<"Transfer money">
            {
                ResponseRight: return DIALOG_BACK;

                InputText:<"Enter amount:">
                {
                    new amount = Dialog_Number(playerid);

                    if (amount <= 0)
                    {
                        SendClientMessage(playerid, -1, "Amount must be > 0!");
                        return DIALOG_REOPEN;
                    }
                    if (amount > pData[playerid][pMoney])
                    {
                        SendClientMessage(playerid, -1, "Not enough money!");
                        return DIALOG_REOPEN;
                    }

                    new name[MAX_PLAYER_NAME];
                    GetPlayerName(target, name);

                    Create:<"Transfer money">
                    {
                        ResponseRight: return DIALOG_BACK;

                        MessageBox:<"\
                            Confirm transfer?\n\
                            Target: %s (%d)\n\
                            Amount: %d$\
                        ", name, target, amount>
                        {
                            GivePlayerMoney(playerid, -amount);
                            GivePlayerMoney(target, amount);

                            SendClientMessagef(playerid, -1,
                                "You sent %d$ to %s (%d)", amount, name, target);

                            GetPlayerName(playerid, name);
                            SendClientMessagef(target, -1,
                                "%s (%d) sent you %d$", name, playerid, amount);

                            return DIALOG_CLOSE;
                        }
                    }
                    Button:<"Send", "Back">;
                }
            }
            Button:<"Next", "Back">;
        }
    }
    Button:<"Select", "Back">;
}
```

**Note:** You don’t need to repeat online/money checks right before `GivePlayerMoney` if you already validate them on the final “Send” click.

---

## Database queries (`DialogQuery`)

You can fetch data via async SQL queries.

**Important:** a dialog can contain **only one** `DialogQuery` call.

Example: Top 10 richest accounts

```c
static query_top_10[] = "\
    SELECT `id`, `nickname`, `money` \
    FROM `accounts` \
    ORDER BY `money` DESC \
    LIMIT 10;\
";

dialog PlayersTopMoney(playerid)
{
    Create:<"Top 10 richest">
    {
        ResponseRight: return DIALOG_CLOSE;

        DialogQuery:<mysqlconnect, query_top_10>;

        new rows = cache_num_rows();
        if (rows == 0)
        {
            MessageBox:<"No rows in `accounts`">
            {
                return DIALOG_CLOSE;
            }
        }

        ListHead:<"Player\tMoney">;

        new nickname[MAX_PLAYER_NAME];
        new money, accountid;

        for (new i = 0; i < rows; i++)
        {
            cache_get_value_int(i, "id", accountid);
            cache_get_value_name(i, "nickname", nickname);
            cache_get_value_int(i, "money", money);

            ListItem:<"%d. %s\t%d$", i + 1, nickname, money>
            {
                return PlayerAccountInfo(playerid, accountid);
            }
        }
    }
    Button:<"Select", "Close">;
}
```

### Cache lifetime

`DialogQuery` results are cached by dialog depth.
If you navigate within the same cached depth and you need fresh data, destroy the cache manually:

```c
Dialog_CacheDestroy(playerid, deepid);
return DialogGoto:<deepid>;
```

---

## Best practices

* Prefer `ResponseRight` / `ResponseLeft` instead of per-item `else` for simple “Close/Back” behavior.
* Use `DialogRender` for expensive formatting / list building.
* If your list can change (players streaming in/out, dynamic DB-driven content), use **Collections**.
* Keep dialog state explicit (IDs, amounts, selected row) and validate at the final confirmation step.

---

## License / Contributing

Add your license here (MIT, GPL, custom, etc.).
PRs and issues are welcome — please include a minimal reproduction if reporting a bug.

