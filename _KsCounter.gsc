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
    create_dvar( "sv_scrollingHud", 1 );
    create_dvar( "sv_scrollingSpeed", 30 );
    create_dvar( "sv_hudBottom", "^1Press ^7'^2Vote Yes^7' ^1for ammunition!" );

    thread onConnect();
    thread scrollingText();
}

scrollingText()
{
    if ( getDvarInt( "sv_scrollingHud" ) != 1 ) return;
    bottomHudText = createServerFontString( "hudbig", 0.4 );
    bottomHudText setPoint( "CENTER", "BOTTOM", 0, -5 );
    bottomHudText.foreground = true;
	bottomHudText.hidewheninmenu = true;
    bottomHudText setText( getDvar( "sv_hudBottom" ) );

    level endon( "game_ended" );
    for ( ;; )
    {
        bottomHudText setPoint( "CENTER", "BOTTOM", 1100, -5 );
        bottomHudText moveOverTime( getDvarInt( "sv_scrollingSpeed" ) );
        bottomHudText.x = -700;
        wait( 30 );
    }
}

onConnect()
{
    for ( ;; )
    {
        level waittill( "connected", player );
        player thread killstreakPlayer();
    }
}

killstreakPlayer()
{
    level endon( "game_ended" );
    self endon ( "disconnect" );

//  ID for admins
    self.MyPlayerID = self createFontString( "HudBig", 0.5 );
    self.MyPlayerID setPoint( "BOTTOMCENTER", "BOTTOMCENTER", 0, -5 );
    self.MyPlayerID setText( "^2Player ^5ID^7: " + self getentitynumber() );
    self.MyPlayerID.hideWhenInMenu = true;

//  Ks
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
