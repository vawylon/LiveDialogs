#if defined __inc_LiveDialogs
    #endinput
#else
    #define __inc_LiveDialogs
#endif

//                                         _             
//                                        | |            
//              __   ____ ___      ___   _| | ___  _ __  
//              \ \ / / _` \ \ /\ / / | | | |/ _ \| '_ \ 
//               \ V / (_| |\ V  V /| |_| | | (_) | | | |
//                \_/ \__,_| \_/\_/  \__, |_|\___/|_| |_|
//                                    __/ |              
//                                   |___/            
// tg @vawylon
// vk vk.com/vawylon 

#include <a_mysql>

#if defined FILTERSCRIPT
    #define LiveDIALOG_ID               5122
#else
    #define LiveDIALOG_ID               5120
#endif

#define DIALOG_MAX_COLLECTION           32
#define MAX_FUNCTION_NAME               32
#define DIALOG_MAX_LIST_ITEMS           64
#define MAX_DIALOG_HEAD                 144
#define MAX_DIALOG_BODY                 4096
#define DIALOG_MAX_DEEP                 16

#define Create:<%1>                     if(Dialog_Incr(playerid)) if(Dialog_Head(playerid, %1))
#define ListHead:<%1>                   Dialog_BodyHead(playerid, %1)
#define ListItem:<%1>                   if(Dialog_Body(playerid, DIALOG_STYLE_LIST, %1)) if(Dialog_IsResponse(playerid))
#define Input:<%1>                      if(Dialog_Body(playerid, DIALOG_STYLE_INPUT, %1)) if(Dialog_IsResponse(playerid))
#define InputPassword:<%1>              if(Dialog_Body(playerid, DIALOG_STYLE_PASSWORD, %1)) if(Dialog_IsResponse(playerid))
#define MessageBox:<%1>                 if(Dialog_Body(playerid, DIALOG_STYLE_MSGBOX, %1)) if(Dialog_IsResponse(playerid))
#define Button:<%1>                     return Dialog_Button(playerid, %1)
#define DIALOG_REOPEN_TIME<%0>          DIALOG:SetTimerEx("Dialog_Reopen", %0, false, "i", playerid)
#define DialogRender:                   if(Dialog_IsRender(playerid))
#define DialogQuery:<%0,%1>             if(!Dialog_Query(playerid, %0, %1)) return DIALOG_HIDE
#define ResponseRight:                  if(!Dialog_IsRender(playerid)) if(!Dialog_IsResponse(playerid))
#define ResponseLeft:					if(!Dialog_IsRender(playerid)) if(Dialog_IsResponse(playerid))
#define DialogCollections:<%0>          for(new %0, %0__ncollect, %0__index; Dialog_CollectFor(playerid, %0, %0__ncollect); %0__index++)
#define DialogCollect:<%0>              Dialog_AddCollection(playerid, %0)
#define dialog%0(%2)                    forward DIALOG:%0(playerid);public DIALOG:%0(%2)
#define LDIsNull(%1) 					((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))
#define DialogGoto:<%0>                 Dialog_Back(playerid, %0)

#define DialogClose                     DIALOG_CLOSE
#define DialogMain                      DialogGoto:<0>

#if !defined Dialog
    #define Dialog:         #
#endif

enum DIALOG
{
    DIALOG_HIDE                 = -1,
    DIALOG_REOPEN               = 0,
    DIALOG_MAIN                 = 1,
    DIALOG_CLOSE                = 2,
    DIALOG_BACK                 = 3
}

enum dialog_data {
    dialog_deep,
    dialog_currentdeep,
    dialog_list,
    DIALOG_STYLE:dialog_style,
    dialogs_increm,
    dialog_history_list     [DIALOG_MAX_DEEP],
    dialog_history_deep     [DIALOG_MAX_DEEP],
	dialog_function         [MAX_FUNCTION_NAME],
    dialog_response         [DIALOG_MAX_DEEP],
	dialog_head             [MAX_DIALOG_HEAD],
	dialog_body             [MAX_DIALOG_BODY]
}

static DialogCollect        [MAX_PLAYERS][DIALOG_MAX_DEEP][DIALOG_MAX_COLLECTION];
static DialogCollectCount   [MAX_PLAYERS][DIALOG_MAX_DEEP];
static pDialogValue         [MAX_PLAYERS][DIALOG_MAX_DEEP][DIALOG_MAX_LIST_ITEMS];
static Cache:pDialogCache   [MAX_PLAYERS][DIALOG_MAX_DEEP];
static pDialogInput         [MAX_PLAYERS][DIALOG_MAX_DEEP][144];
static pDialog              [MAX_PLAYERS][dialog_data];
static stock DialogQuery	[4096];

#if defined _INC_y_va
    static dialogbuffer         [MAX_DIALOG_BODY];
#endif

forward DIALOG:Dialog_Reopen(playerid);
forward DIALOG:Dialog_Main(playerid);
forward Dialog_OnQuery(playerid, deep, const func[]);

stock DIALOG:Dialog_Button(playerid, const left[], const right[] = "")
{
    if(pDialog[playerid][dialog_head][0] == EOS && pDialog[playerid][dialog_body][0] == EOS) {
        return DIALOG_CLOSE;
    }
    
    ShowPlayerDialog(playerid, LiveDIALOG_ID, pDialog[playerid][dialog_style], pDialog[playerid][dialog_head], pDialog[playerid][dialog_body], left, right);

    pDialog[playerid][dialog_head][0] = EOS;
    pDialog[playerid][dialog_body][0] = EOS;
    pDialog[playerid][dialog_style] = DIALOG_STYLE:0;
    return DIALOG_CLOSE;
}

stock Dialog_IsResponse(playerid)
{
    return pDialog[playerid][dialog_response][pDialog[playerid][dialog_currentdeep]];
}

stock Dialog_Incr(playerid) {
    pDialog[playerid][dialog_currentdeep] ++;
    return 1;
}

#if defined _INC_y_va
    stock Dialog_Head(playerid, const head[], va_args<>)
#else
    stock Dialog_Head(playerid, const head[])
#endif
{
    if(pDialog[playerid][dialog_history_deep][pDialog[playerid][dialog_currentdeep]] == pDialog[playerid][dialog_deep])
    {
        #if defined _INC_y_va
            format(pDialog[playerid][dialog_head], MAX_DIALOG_HEAD, head, va_start<2>);
        #else
			pDialog[playerid][dialog_head][0] = EOS;
            strcat(pDialog[playerid][dialog_head], head, MAX_DIALOG_HEAD);
        #endif
    }
    pDialog[playerid][dialog_list] = 0;
    return 1;
}

stock bool:Dialog_IsRender(playerid)
{
    if(pDialog[playerid][dialog_history_deep][pDialog[playerid][dialog_currentdeep]] == pDialog[playerid][dialog_deep])
    {
        return true;
    }
    else
    {
        if(pDialog[playerid][dialog_history_list][pDialog[playerid][dialog_currentdeep]] == pDialog[playerid][dialog_list])
        {
            return false;
        }
        else
        {
            if(pDialog[playerid][dialog_style] != DIALOG_STYLE_LIST && pDialog[playerid][dialog_style] != DIALOG_STYLE_TABLIST && pDialog[playerid][dialog_style] != DIALOG_STYLE_TABLIST_HEADERS) 
            {
                return false;
            }
            return true;
        }
    }
}

#if defined _INC_y_va
    stock Dialog_SetHead(playerid, const head[], va_args<>)
#else
    stock Dialog_SetHead(playerid, const head[])
#endif
{
	if(pDialog[playerid][dialog_function] == EOS) {
		return false;
	}
	if(!Dialog_IsRender(playerid)) {
		return false;
	}
	#if defined _INC_y_va
		format(pDialog[playerid][dialog_head], MAX_DIALOG_HEAD, head, va_start<2>);
	#else
		pDialog[playerid][dialog_head][0] = EOS;
		strcat(pDialog[playerid][dialog_head], head, MAX_DIALOG_HEAD);
	#endif
	return true;
}

stock Dialog_SetValue(playerid, listitem, value)
{
    pDialogValue[playerid][pDialog[playerid][dialog_currentdeep]][listitem] = value;
}

stock Dialog_GetValue(playerid, listitem)
{
    return pDialogValue[playerid][pDialog[playerid][dialog_currentdeep]][listitem];
}

#if defined _INC_y_va
    stock bool:Dialog_Body(playerid, DIALOG_STYLE:style, const body[], va_args<>)
#else
    stock bool:Dialog_Body(playerid, DIALOG_STYLE:style, const body[])
#endif
{
    if(pDialog[playerid][dialog_history_deep][pDialog[playerid][dialog_currentdeep]] == pDialog[playerid][dialog_deep])
    {
        #if defined _INC_y_va
            dialogbuffer[0] = EOS;
            strcat(dialogbuffer, "%s");
            strcat(dialogbuffer, body);
            strcat(dialogbuffer, "\n");
            format(pDialog[playerid][dialog_body], MAX_DIALOG_BODY, dialogbuffer, pDialog[playerid][dialog_body], va_start<3>);
        #else
            format(pDialog[playerid][dialog_body], MAX_DIALOG_BODY, "%s%s\n", pDialog[playerid][dialog_body], body);
        #endif
        
        if(pDialog[playerid][dialog_style] != DIALOG_STYLE_LIST && pDialog[playerid][dialog_style] != DIALOG_STYLE_TABLIST && pDialog[playerid][dialog_style] != DIALOG_STYLE_TABLIST_HEADERS) {
            pDialog[playerid][dialog_style] = style;
        }
        return false;
    }
    else
    {
        if(pDialog[playerid][dialog_history_list][pDialog[playerid][dialog_currentdeep]] == pDialog[playerid][dialog_list])
        {
            pDialog[playerid][dialog_list] ++;
            return true;
        }
        else
        {
            if(style == DIALOG_STYLE_LIST)
            {
                pDialog[playerid][dialog_list] ++;
            }
            else
            {
                return true;
            }
            return false;
        }
    }
}

#if defined _INC_y_va
    stock Dialog_BodyHead(playerid, const body[], va_args<>)
#else
    stock Dialog_BodyHead(playerid, const body[])
#endif
{
    if(Dialog_IsRender(playerid))
    {
        #if defined _INC_y_va
            dialogbuffer[0] = EOS;
            strcat(dialogbuffer, "%s");
            strcat(dialogbuffer, body);
            strcat(dialogbuffer, "\n");
            format(pDialog[playerid][dialog_body], MAX_DIALOG_BODY, dialogbuffer, pDialog[playerid][dialog_body], va_start<2>);
        #else
            format(pDialog[playerid][dialog_body], MAX_DIALOG_BODY, "%s%s\n", pDialog[playerid][dialog_body], body);
        #endif

        pDialog[playerid][dialog_style] = DIALOG_STYLE_TABLIST_HEADERS;
    }
}

stock Dialog_Number(playerid)
{
    return strval(pDialogInput[playerid][pDialog[playerid][dialog_currentdeep]]);
}

stock Dialog_Text(playerid, inputtext[], sizes = sizeof inputtext)
{
    strcat(inputtext, pDialogInput[playerid][pDialog[playerid][dialog_currentdeep]], sizes);
    return strlen(pDialogInput[playerid][pDialog[playerid][dialog_currentdeep]]);
}

public DIALOG:Dialog_Reopen(playerid)
{
    pDialog[playerid][dialog_currentdeep] = -1;
    pDialog[playerid][dialog_deep] --;
    CallLocalFunction(pDialog[playerid][dialog_function], "i", playerid);
    return DIALOG_CLOSE;
}

stock Dialog_GetDeep(playerid) 
{
    return pDialog[playerid][dialog_currentdeep];
}

stock bool:Dialog_AddCollection(playerid, value) 
{
    if(DialogCollectCount[playerid][ pDialog[playerid][dialog_currentdeep] ] + 1 > DIALOG_MAX_COLLECTION) {
        return false;
    }
    DialogCollect[playerid][ pDialog[playerid][dialog_currentdeep] ][ DialogCollectCount[playerid][ pDialog[playerid][dialog_currentdeep] ]] = value;
    DialogCollectCount[playerid][ pDialog[playerid][dialog_currentdeep] ] ++;
    return true;
}

stock bool:Dialog_CollectFor(playerid, &value, &next) 
{
    if(DialogCollectCount[playerid][ pDialog[playerid][dialog_currentdeep] ] > next) {
        value = DialogCollect[playerid][ pDialog[playerid][dialog_currentdeep] ][ next ];
        next ++;
        return true;
    }
    return false;
}

stock void:Dialog_Response(playerid, dialogid, response, listitem, const inputtext[])
{
    if(LiveDIALOG_ID != dialogid) {
        return;
    }
    if(pDialog[playerid][dialog_currentdeep] < 0) {
        return;
    }
    pDialog[playerid][dialog_deep] ++;
    pDialog[playerid][dialog_history_list][pDialog[playerid][dialog_currentdeep]] = listitem;
    pDialogInput[playerid][pDialog[playerid][dialog_currentdeep]][0] = EOS;
    strcat(pDialogInput[playerid][pDialog[playerid][dialog_currentdeep]], inputtext, 144);
    pDialog[playerid][dialog_response][pDialog[playerid][dialog_currentdeep]] = response;
    pDialog[playerid][dialog_currentdeep] ++;
    pDialog[playerid][dialog_history_deep][pDialog[playerid][dialog_currentdeep]] = pDialog[playerid][dialog_currentdeep];
    pDialog[playerid][dialog_currentdeep] = -1;
    
    Dialog_Result(playerid, DIALOG:CallLocalFunction(pDialog[playerid][dialog_function], "i", playerid));
    return;
}

stock Dialog_SelectItem(playerid)
{
    return pDialog[playerid][dialog_history_list][pDialog[playerid][dialog_currentdeep]];
}

stock bool:Dialog_CacheDestroy(playerid, deep) 
{
    if(pDialogCache[playerid][deep])
    {
        printf("Cache Delete[%d]", deep);
        cache_delete(pDialogCache[playerid][deep]);
        pDialogCache[playerid][deep] = Cache:0;
        return true;
    }
    return false;
}

stock bool:Dialog_CacheDestroyAll(playerid)
{
    for(new i; i<DIALOG_MAX_DEEP; i++) {
        if(pDialog[playerid][dialog_currentdeep]) {
            printf("Cache Delete[%d]", i);
            cache_delete(pDialogCache[playerid][i]);
            pDialogCache[playerid][i] = Cache:0;
        }
    }
    return true;
}

stock DIALOG:Dialog_Back(playerid, deep)
{
    if(pDialog[playerid][dialog_deep] < deep) {
        return DIALOG_CLOSE;
    }
    if (0 <= deep < DIALOG_MAX_DEEP )
    {
        pDialog[playerid][dialog_deep] = deep + 1;
        for(new i = deep+1; i < DIALOG_MAX_DEEP; i++)
        {
            pDialog[playerid][dialog_history_list][i] = 0;
            pDialog[playerid][dialog_history_deep][i] = 0;
            pDialog[playerid][dialog_response][i] = 0;
            DialogCollectCount[playerid][i] = 0;
            pDialogInput[playerid][i][0] = EOS;
            for(new j; j<DIALOG_MAX_LIST_ITEMS; j++)
            {
                pDialogValue[playerid][i][j] = 0;
            }
            Dialog_CacheDestroy(playerid, i);
        }
        pDialog[playerid][dialog_currentdeep] = -1;
        return DIALOG_REOPEN;
    }
    return DIALOG_CLOSE;
}

stock void:Dialog_Result(playerid, DIALOG:result)
{
    switch(result)
    {
        case DIALOG_CLOSE: 
        {
            return;
        }
        case DIALOG_REOPEN:
        {
            Dialog_Reopen(playerid);
            return;
        }
        case DIALOG_BACK:
        {
            Dialog_Back(playerid, pDialog[playerid][dialog_deep] - 2);
            Dialog_Reopen(playerid);
            return;
        }
        case DIALOG_MAIN:
        {
            Dialog_Back(playerid, 0);
            Dialog_Reopen(playerid);
            return;
        }
        case DIALOG_HIDE: 
        {
            
        }
    }
}

stock bool:Dialog_Create(playerid, const function[])
{
    if(!IsPlayerConnected(playerid)) {
        return false;
    }
    for(new i; i<DIALOG_MAX_DEEP; i++)
    {
        pDialog[playerid][dialog_history_list][i] = -1;
        pDialog[playerid][dialog_history_deep][i] = -1;
        pDialog[playerid][dialog_response][i] = 0;
        pDialogInput[playerid][i][0] = EOS;
        for(new j; j<DIALOG_MAX_LIST_ITEMS; j++)
        {
            pDialogValue[playerid][i][j] = 0;
        }
        DialogCollectCount[playerid][i] = 0;
    }
    pDialog[playerid][dialog_list] = 0;
    pDialog[playerid][dialog_body][0] = EOS;
    pDialog[playerid][dialog_head][0] = EOS;
    pDialog[playerid][dialog_history_deep][0] = 0;
    pDialog[playerid][dialog_deep] = 0;
    pDialog[playerid][dialog_style] = DIALOG_STYLE:0;
    pDialog[playerid][dialog_currentdeep] = -1;
    pDialog[playerid][dialog_function][0] = EOS;
    strcat(pDialog[playerid][dialog_function], function, MAX_FUNCTION_NAME);
	
    for(new i; i<sizeof pDialogCache[]; i++) {
        if(cache_is_valid(pDialogCache[playerid][i])) 
        {
            printf("Cache Delete[%d]", i);
            cache_delete(pDialogCache[playerid][i]);
        }
        pDialogCache[playerid][i] = Cache:0;
    }

    CallLocalFunction(function, "i", playerid);
    return true;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	Dialog_Response(playerid, dialogid, response, listitem, inputtext);
	#if defined lda_OnDialogResponse
		return lda_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
	#else
		return 1;
	#endif
}

#if defined _ALS_OnDialogResponse
	#undef OnDialogResponse
#else
	#define _ALS_OnDialogResponse
#endif
#define OnDialogResponse lda_OnDialogResponse
#if defined lda_OnDialogResponse
	forward lda_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif

#if defined _INC_y_va
    stock Dialog_Query(playerid, MySQL:connect, const query[], va_args<>)
#else
    stock Dialog_Query(playerid, MySQL:connect, const query[])
#endif
{
    if(pDialogCache[playerid][pDialog[playerid][dialog_currentdeep]] == Cache:0)
    {
        #if defined _INC_y_va
        	mysql_format(connect, DialogQuery, sizeof DialogQuery, query, va_start<3>);
        	mysql_tquery(connect, DialogQuery, "Dialog_OnQuery", "dds", playerid, pDialog[playerid][dialog_currentdeep], pDialog[playerid][dialog_function]);
        #else
        	mysql_tquery(connect, query, "Dialog_OnQuery", "dds", playerid, pDialog[playerid][dialog_currentdeep], pDialog[playerid][dialog_function]);
        #endif
        return 0;
    }
    else
    {
        cache_set_active(pDialogCache[playerid][ pDialog[playerid][dialog_currentdeep] ]);
        return 1;
    }
}

public Dialog_OnQuery(playerid, deep, const func[])
{
	if (!strcmp(pDialog[playerid][dialog_function], func ) && !LDIsNull(pDialog[playerid][dialog_function]) && !LDIsNull(func))
	{
	    pDialog[playerid][dialog_currentdeep] = -1;
	    pDialogCache[playerid][deep] = cache_save();
	    Dialog_Result(playerid, DIALOG:CallLocalFunction(pDialog[playerid][dialog_function], "i", playerid));
	}
}