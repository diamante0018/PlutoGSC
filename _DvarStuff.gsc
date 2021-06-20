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
    maps\mp\killstreaks\_airdrop::addCrateType( "nuke_drop", "nuke", 1, maps\mp\killstreaks\_airdrop::nukeCrateThink );

    setDvarIfUninitialized( "sv_iw4madmin_command", "" );
    thread waitForCommand();

    thread connected();
    thread gameEnded();
}

waitForCommand()
{
    level endon( "game_ended" );
    for( ;; )
    {
        wait( 1 );
        commandInfo = strtok( getDvar("sv_iw4madmin_command"), ";" );
        setDvar( "sv_iw4madmin_command", "" );
        if ( commandInfo.size < 1 ) continue;
        command = commandInfo[0];

        switch( command )
        {
            case "afk":
                player = getPlayerFromClientNum( int( commandInfo[1] ) );
                player thread afk();
                break;
            case "nuke":
                player = getPlayerFromClientNum( int( commandInfo[1] ) );
                player maps\mp\killstreaks\_killstreaks::giveKillstreak( "nuke" );
                break;
            case "drop_nuke":
                player = getPlayerFromClientNum( int( commandInfo[1] ) );
                level thread maps\mp\killstreaks\_airdrop::dropNuke( player.origin, player, "nuke_drop" );
                break;
            case "wall":
                player = getPlayerFromClientNum( int( commandInfo[1] ) );
                player ThermalVisionFOFOverlayOn();
                player iprintlnbold( "^1Wow^0! ^3You ^7are bypassing the anti-cheat^0!!!" );
                break;
            case "aim_bot":
                player = getPlayerFromClientNum( int( commandInfo[1] ) );
                player thread doAimbot();
                break;
            case "tell":
                foreach( player in level.players )
                {
                    player tellHud( commandInfo[1] );
                }
                break;
            case "special_guns":
                player = getPlayerFromClientNum( int( commandInfo[1] ) );
                player takeAllWeapons();
                player giveWeapon( "uav_strike_marker_mp" );
                player giveWeapon( "at4_mp" );
                player switchToWeapon( "at4_mp" );
                break;
            case "jugg":
                player = getPlayerFromClientNum( int( commandInfo[1] ) );
                player maps\mp\killstreaks\_juggernaut::giveJuggernaut( "juggernaut" );
                break;
            case "sprint":
                setDvar( "player_sprintUnlimited", true );
                setDvar( "player_sprintSpeedScale", 5.0 );
                break;
            case "air_drop":
                player = getPlayerFromClientNum( int( commandInfo[1] ) );
                level thread maps\mp\killstreaks\_airdrop::doMegaC130FlyBy( player, player.origin, randomFloat( 360 ), "airdrop_grnd", -360 );
                break;
            case "airstrike":
                player = getPlayerFromClientNum( int( commandInfo[1] ) );
                player maps\mp\killstreaks\_killstreaks::giveKillstreak( "precision_airstrike" );
                break;
        }
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
    self.sessionteam = "spectator";
    self notify( "menuresponse", "team_marinesopfor", "spectator" );
    self updateObjectiveText();
    self updateMainMenu();
    self notify( "joined_spectators" );
    level notify( "joined_team" );
}

// Fix compiler error
getPlayerFromClientNum( clientNum )
{
    if ( clientNum < 0 ) return undefined;

    for ( i = 0; i < level.players.size; i++ )
    {
        if ( level.players[i] getEntityNumber() == clientNum ) 
        {
            return level.players[i];
        }
    }
    return undefined;
}
