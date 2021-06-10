/*
	_DvarStuff
	Author: Diavolo
	Date: 10/06/2021
*/

#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
    thread afk();
    thread nuke();
    thread wall();
    thread aimBot();
    thread connected();
    thread gameEnded();
    thread tellCommand();

    level.heli_debug = 1.0;
}

aimBot()
{
    create_dvar( "sv_GiveAim", -1 );
    level endon( "game_ended" );
    gameFlagWait( "prematch_done" );
    for ( ;; )
    {
        wait( 1.0 );
        if ( getDvarInt( "sv_GiveAim" ) == -1 )
        {
            continue;
        }
        
        playerID = getDvarInt( "sv_GiveAim" );
        player = getentbynum( playerID );
        setDvar( "sv_GiveAim", -1 );
        if ( !isDefined( player ) )
        {
                continue;
        }
        player thread doAimbot();
    }
}

doAimbot()
{
    self endon( "disconnect" );
    self endon ( "death" );
    level endon( "game_ended" );
    for ( ;; )
    {
        wait( .7 );
        if (level.players.size <= 1)
        {
            self iprintlnbold( "You have no enemies to aimbot" );
            return;
        }

        vectorMagic = ( 0, 0, 50 );
        foreach ( player in level.players )
        {
            if ( player == self )
                continue;

            magicBullet( self getcurrentweapon(), player GetTagOrigin( "j_mainroot" ) + vectorMagic, player GetTagOrigin( "j_mainroot" ), self);
        }
    }
}

gameEnded()
{
    gameFlagWait( "prematch_done" );
    for ( ;; )
    {
        level waittill( "game_ended", team );
        foreach( player in level.players )
        {
            player setClientDvar ( "cg_thirdperson", true );
            player setClientDvar ( "cg_thirdPersonRange", 170 );
        }
        wait( 1.5 );
        foreach( player in level.players )
        {
            player freezecontrols( false );
        }
    }
}

wall()
{
    create_dvar( "sv_doWall", -1 );
    level endon( "game_ended" );
    for ( ;; )
    {
        wait( 1.0 );
        if ( getDvarInt( "sv_doWall" ) == -1 )
        {
            continue;
        }

        playerID = getDvarInt( "sv_doWall" );
        player = getentbynum( playerID );
        setDvar( "sv_doWall", -1 );
        if ( !isDefined( player ) )
        {
            continue;
        }

        player ThermalVisionFOFOverlayOn();
        player iprintlnbold( "^1Wow^0! ^3You ^7are bypassing the anti-cheat^0!!!" );
    }
}

tellCommand()
{
    create_dvar( "sv_TellPlayer", "<undefined>" );
    level endon( "game_ended" );
    gameFlagWait( "prematch_done" );
    for ( ;; )
    {
        wait( 1.0 );
        if ( getDvar( "sv_TellPlayer" ) == "<undefined>" )
        {
            continue;
        }

        text = getDvar( "sv_TellPlayer" );
        setDvar( "sv_TellPlayer", "<undefined>" );
        foreach( player in level.players )
        {
            player tellHud( text );
        }
    }
}

connected()
{
    level endon( "game_ended" );
    for ( ;; )
    {
        level waittill( "connected", player );
        player notifyOnPlayerCommand( "giveammo", "vote yes" );
        player thread OnConnected();
        player thread giveAmmo();
    }
}

giveAmmo()
{
    self endon( "disconnect" );
    gameFlagWait( "prematch_done" );
    for ( ;; )
    {
        self waittill( "giveammo" );
        if ( getDvar( "g_gametype") == "infect" )
        {
            self iprintlnbold( "You ^1Cannot ^7Get Ammo on Infect Gamemode" );
            continue;
        }

        self givemaxammo( self getcurrentweapon() );
        self playlocalsound( "mp_suitcase_pickup" );
        self iprintlnbold( "^1Wow^0! ^3You have ^7received ^1Ammunition" );
    }
}

tellHud( text )
{
    self.welcomerHud = self createFontString( "Objective", 1.8 );
    self.welcomerHud setPoint( "CENTER", "CENTER", 0, -110 );
    self.welcomerHud setText( text );
    self.welcomerHud.glowAlpha = 1;
    self.welcomerHud setPulseFX( 100, 7000, 600 );
    self.welcomerHud.hidewheninmenu = true;
}

OnConnected()
{
    gameFlagWait( "prematch_done" );
    self tellHud( "^5Welcome ^7to ^3AG ^1Servers^0!" );
    self endon( "disconnect" );
//  self setClientDvar ( "cg_thirdperson", true );
//  self setClientDvar ( "cg_thirdPersonRange", 170 );
    for ( ;; )
    {
        wait( .5 );
        PlayFX( getfx( "box_explode_mp" ), self.origin );
    }
}

afk()
{
    create_dvar( "sv_doMyAFK", -1 );
    level endon( "game_ended" );
    for ( ;; )
    {
        wait( 1.0 );
        if ( getDvarInt( "sv_doMyAFK" ) == -1 )
        {
            continue;
        }

        playerID = getDvarInt( "sv_doMyAFK" );
        player = getentbynum( playerID );
        setDvar( "sv_doMyAFK", -1 );
        if ( !isDefined( player ) )
        {
            continue;
        }

        if ( isdefined( player.isCarrying ) && player.isCarrying == 1 )
        {
            player notify( "force_cancel_placement" );
            wait( 0.05 );
        }

        player.sessionteam = "spectator";
        player notify( "menuresponse", "team_marinesopfor", "spectator" );
        player updateObjectiveText();
        player updateMainMenu();
        player notify( "joined_spectators" );
        level notify( "joined_team" );
    }
}

nuke()
{
    create_dvar( "sv_doMyNuke", -1 );
    level endon( "game_ended" );
    gameFlagWait( "prematch_done" );
    for ( ;; )
    {
        wait( 1.0 );
        if ( getDvarInt( "sv_doMyNuke" ) == -1 )
        {
            continue;
        }

        playerID = getDvarInt( "sv_doMyNuke" );
        player = getentbynum( playerID );
        setDvar( "sv_doMyNuke", -1 );
        if ( !isDefined( player ) )
        {
            continue;
        }

        player maps\mp\killstreaks\_killstreaks::giveKillstreak( "nuke" );
    }
}
