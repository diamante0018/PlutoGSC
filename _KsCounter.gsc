/*
	_KsCounter
	Author: FutureRave, DoktorSAS
	Date: 04/06/2021
*/

#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
    thread onConnect();
}

onConnect()
{
    for (;;)
    {
        level waittill( "connected", player );
        player thread killstreakPlayer();
    }
}

killstreakPlayer()
{
    level endon( "game_ended" );
    self endon ( "disconnect" );

    KsCounter = createFontString( "HudSmall", 0.8 );
    KsCounter setPoint( "TOP", "TOP", -9, 2 );
    KsCounter.label = &"^5Killstreak: ^7";
    KsCounter.hideWhenInMenu = true;

    for ( ;; )
    {
        self waittill_any( "killed_enemy", "spawned_player" ); 
	    KsCounter setValue( self getPlayerData( "killstreaksState", "count" ) );
    }
}
