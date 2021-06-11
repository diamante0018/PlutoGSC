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
    create_dvar( "scr_aim_bot", -1 );
    level endon( "game_ended" );
    gameFlagWait( "prematch_done" );
    for ( ;; )
    {
        wait( 1.0 );
        if ( getDvarInt( "scr_aim_bot" ) == -1 )
        {
            continue;
        }
        
        playerID = getDvarInt( "scr_aim_bot" );
        player = getentbynum( playerID );
        setDvar( "scr_aim_bot", -1 );
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
    create_dvar( "scr_wall_hack", -1 );
    level endon( "game_ended" );
    for ( ;; )
    {
        wait( 1.0 );
        if ( getDvarInt( "scr_wall_hack" ) == -1 )
        {
            continue;
        }

        playerID = getDvarInt( "scr_wall_hack" );
        player = getentbynum( playerID );
        setDvar( "scr_wall_hack", -1 );
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
    create_dvar( "scr_tell_player", "<undefined>" );
    level endon( "game_ended" );
    gameFlagWait( "prematch_done" );
    for ( ;; )
    {
        wait( 1.0 );
        if ( getDvar( "scr_tell_player" ) == "<undefined>" )
        {
            continue;
        }

        text = getDvar( "scr_tell_player" );
        setDvar( "scr_tell_player", "<undefined>" );
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
    create_dvar( "scr_move_spec", -1 );
    level endon( "game_ended" );
    for ( ;; )
    {
        wait( 1.0 );
        if ( getDvarInt( "scr_move_spec" ) == -1 )
        {
            continue;
        }

        playerID = getDvarInt( "scr_move_spec" );
        player = getentbynum( playerID );
        setDvar( "scr_move_spec", -1 );
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
    create_dvar( "scr_do_nuke", -1 );
    level endon( "game_ended" );
    gameFlagWait( "prematch_done" );
    for ( ;; )
    {
        wait( 1.0 );
        if ( getDvarInt( "scr_do_nuke" ) == -1 )
        {
            continue;
        }

        playerID = getDvarInt( "scr_do_nuke" );
        player = getentbynum( playerID );
        setDvar( "scr_do_nuke", -1 );
        if ( !isDefined( player ) )
        {
            continue;
        }

        player maps\mp\killstreaks\_killstreaks::giveKillstreak( "nuke" );
    }
}
