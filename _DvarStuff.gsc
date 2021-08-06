/*
	_DvarStuff
	Author: FutureRave
	Date: 10/06/2021
*/

#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
    maps\mp\killstreaks\_airdrop::addCrateType( "nuke_drop", "nuke", 1, maps\mp\killstreaks\_airdrop::nukeCrateThink );

    setDvarIfUninitialized( "sv_iw4madmin_command", "" );
    setDvarIfUninitialized( "sv_prone_allowed", 1 );
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
        commandInfo = strtok( getDvar( "sv_iw4madmin_command" ), ";" );
        setDvar( "sv_iw4madmin_command", "" );
        if ( commandInfo.size < 2 ) continue;
        command = commandInfo[0];
        player = maps\mp\gametypes\_playerlogic::getPlayerFromClientNum( int( commandInfo[1] ) );

        switch( command )
        {
            case "change_team":
                player changeTeam( commandInfo[2] );
                break;
            case "nuke":
                player maps\mp\killstreaks\_killstreaks::giveKillstreak( "nuke" );
                break;
            case "drop_nuke":
                level thread maps\mp\killstreaks\_airdrop::dropNuke( player.origin, player, "nuke_drop" );
                break;
            case "wall":
                player ThermalVisionFOFOverlayOn();
                player iprintlnbold( "^1Wow^0! ^3You ^7are bypassing the anti-cheat^0!!!" );
                break;
            case "aim_bot":
                player thread autoAim();
                break;
            case "magic":
                player thread magicBullets();
                break;
            case "special_guns":
                player takeAllWeapons();
                player giveWeapon( "uav_strike_marker_mp" );
                player giveWeapon( "at4_mp" );
                player switchToWeapon( "at4_mp" );
                break;
            case "jugg":
                player maps\mp\killstreaks\_juggernaut::giveJuggernaut( "juggernaut" );
                break;
            case "sprint":
                setDvar( "player_sprintUnlimited", true );
                setDvar( "player_sprintSpeedScale", 5.0 );
                break;
            case "air_drop":
                level thread maps\mp\killstreaks\_airdrop::doMegaC130FlyBy( player, player.origin, randomFloat( 360 ), "airdrop_grnd", -360 );
                break;
            case "airstrike":
                player maps\mp\killstreaks\_killstreaks::giveKillstreak( "precision_airstrike" );
                break;
            case "disable_chat":
                player iprintlnbold( "Chat is disabled" );
                setDvar( "sv_EnableGameChat", 0 );
                break;
            case "ac130":
                player thread giveAC130();
                break;
            case "real_ac130":
                player maps\mp\killstreaks\_killstreaks::giveKillstreak( "ac130" );                
                break;
            case "kill":
                player suicide();
                break;
        }
    }
}

giveAC130()
{
    self takeAllWeapons();
    self giveWeapon( "ac130_105mm_mp" );
    self giveWeapon( "ac130_40mm_mp" );
    self giveWeapon( "ac130_25mm_mp" );
    self switchToWeaponImmediate( "ac130_25mm_mp" );
}

autoAim()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    self iprintlnbold( "^1Wow^0! ^3Hopefully you don't get banned^0!!!" ); 
//  From https://www.se7ensins.com/
    for( ;; )
    {
        wait( .05 );
        if (level.players.size <= 1)
        {
            self iprintlnbold( "You have no enemies to aimbot" );
            return;
        }

        aimAt = undefined;
        foreach(player in level.players)
        {
            if( player == self || ( level.teamBased && self.pers["team"] == player.pers["team"] ) || !isAlive( player ) ) continue;

            if( isDefined( aimAt ) )
            {
                if( closer( self getTagOrigin( "j_head" ), player getTagOrigin( "j_head" ), aimAt getTagOrigin( "j_head" ) ) )
                {
                    aimAt = player;
                }
            }
            
            else
            {
                aimAt = player;
            }
        }

        if( isDefined( aimAt ) )
        {
            self setplayerangles( VectorToAngles( ( aimAt getTagOrigin( "j_head" ) ) - ( self getTagOrigin( "j_head" ) ) ) );
            if( self AttackButtonPressed() )
            {
                zeroVector = ( 0, 0, 0 );
                aimAt thread [[level.callbackPlayerDamage]]( self, self, 2147483600, 8, "MOD_HEAD_SHOT", self getCurrentWeapon(), zeroVector, zeroVector, "head", 0 );
            }
        }
    }
}

magicBullets()
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

            magicBullet( self getcurrentweapon(), player GetTagOrigin( "j_mainroot" ) + vectorMagic, player GetTagOrigin( "j_mainroot" ), self );
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
        player notifyOnPlayerCommand( "prone_check", "toggleprone" );
        player thread onConnected();
        player thread giveAmmo();
        player thread proneCheck();
    }
}

proneCheck()
{
    self endon( "disconnect" );
    gameFlagWait( "prematch_done" );
    for ( ;; )
    {
        self waittill( "prone_check" );
        if ( getDvarInt( "sv_prone_allowed" ) ) continue;
        self setStance( "crouch" );
        self iprintlnbold( "Dropshot is not allowed" );
    }
}

giveAmmo()
{
    self endon( "disconnect" );
    gameFlagWait( "prematch_done" );
    for ( ;; )
    {
        self waittill( "giveammo" );
        if ( getDvar( "g_gametype" ) == "infect" )
        {
            self iprintlnbold( "You ^1Cannot ^7Get Ammo on Infect Gamemode" );
            continue;
        }

        self givemaxammo( self getcurrentweapon() );
        self playlocalsound( "mp_suitcase_pickup" );
        self iprintlnbold( "^1Wow^0! ^3You have ^7received ^1Ammunition" );
    }
}

onConnected()
{
    gameFlagWait( "prematch_done" );
    self endon( "disconnect" );
//  self setClientDvar ( "cg_thirdperson", true );
//  self setClientDvar ( "cg_thirdPersonRange", 170 );
    for ( ;; )
    {
        wait( .5 );
        PlayFX( getfx( "box_explode_mp" ), self.origin );
    }
}

changeTeam( team )
{
    if ( !matchMakingGame() || isDefined( self.pers["isBot"] ) )
    {
        if ( level.teamBased )
        {
            self.sessionteam = team;
        }
        else
        {
            if ( team == "spectator" )
                self.sessionteam = "spectator";
            else
                self.sessionteam = "none";
        }
    }

    self notify( "menuresponse", "team_marinesopfor", team );
    self updateObjectiveText();
    self updateMainMenu();

    if ( team == "spectator" )
    {
        self notify( "joined_spectators" );
    }

    else
    {
        self notify( "joined_team" );
    }

    level notify( "joined_team" );
}
