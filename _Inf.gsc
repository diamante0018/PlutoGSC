/*
	_Inf
	Author: FutureRave
	Date: 11/06/2021
*/

#include common_scripts\utility;
#include maps\mp\_utility;

DEFAULT_PORT = 27017;

init()
{
    IPrintLn( "^6I am ^1Diavolo ^6and I lost my Mind." );
//  print( getDvarInt( "net_port" ) );
    precacheItem( "at4_mp" );
    precacheItem( "uav_strike_marker_mp" );

    thread antiRQ();
    thread onConnect();

//  How to array in gsc
    level.myPrimaryGuns = [];
    level.myPrimaryGuns[ level.myPrimaryGuns.size ] = "iw5_1887_mp";
    level.myPrimaryGuns[ level.myPrimaryGuns.size ] = "iw5_aa12_mp";
    level.myPrimaryGuns[ level.myPrimaryGuns.size ] = "iw5_ksg_mp";
    level.myPrimaryGuns[ level.myPrimaryGuns.size ] = "iw5_spas12_mp";
    level.myPrimaryGuns[ level.myPrimaryGuns.size ] = "iw5_striker_mp";
    level.myPrimaryGuns[ level.myPrimaryGuns.size ] = "iw5_usas12_mp";
    level.myPrimaryGuns[ level.myPrimaryGuns.size ] = "iw5_ak47_mp";

    level.myPistols = [];
    level.myPistols[ level.myPistols.size ] = "iw5_44magnum_mp";
    level.myPistols[ level.myPistols.size ] = "iw5_fmg9_mp";
    level.myPistols[ level.myPistols.size ] = "iw5_fnfiveseven_mp";
    level.myPistols[ level.myPistols.size ] = "iw5_g18_mp";
    level.myPistols[ level.myPistols.size ] = "iw5_mp412jugg_mp";
    level.myPistols[ level.myPistols.size ] = "iw5_mk14_mp";
    level.myPistols[ level.myPistols.size ] = "iw5_p99_mp";
    level.myPistols[ level.myPistols.size ] = "iw5_usp45_mp";
    level.myPistols[ level.myPistols.size ] = "iw5_usp45jugg_mp";
    level.myPistols[ level.myPistols.size ] = "iw5_m9_mp";
    level.myPistols[ level.myPistols.size ] = "at4_mp";
    level.myPistols[ level.myPistols.size ] = "iw5_acr_mp";
    level.myPistols[ level.myPistols.size ] = "uav_strike_marker_mp";
    level.myPistols[ level.myPistols.size ] = "iw5_deserteagle_mp";

    level waittill( "prematch_over" );
//  Made to run on one server only
    if ( getDvarInt( "net_port" ) != DEFAULT_PORT ) return;
    
    foreach( player in level.players )
    {
        if ( player.pers["team"] != "allies" ) continue;
        player thread giveLoad();
    }
}

antiRQ()
{
    level endon( "game_ended" );
    gameFlagWait( "prematch_done" );
//  For all inf servers
    if ( getDvar( "g_gametype" ) != "infect" ) return;

    for( ;; )
    {
        wait ( .5 );
//      If it's only 2 people let them quit
        if (level.players.size < 3) continue;

        foreach( player in level.players )
        {
            if ( player.pers["team"] == "axis" )
            {
                player closepopupmenu( "" );
                player closeingamemenu();
            }
        }
    }
}

onConnect()
{
    if ( getDvarInt( "net_port" ) != DEFAULT_PORT ) return;
    for ( ;; )
    {
        level waittill( "connected", player );
        player thread connected();
        player thread weaponFired();
    }
}

weaponFired()
{
    self endon( "disconnect" );
    for ( ;; )
    {
        self waittill( "weapon_fired", weaponName );
        if ( weaponName != "uav_strike_marker_mp" &&  weaponName != "at4_mp" ) continue;
        
        angles = AnglesToForward( self GetPlayerAngles() );
        angles *= 1000000;
        magicBullet( "ims_projectile_mp", self GetTagOrigin( "tag_weapon_left" ), angles, self );
        magicBullet( "ims_projectile_mp", self GetTagOrigin( "tag_weapon_left" ), angles + ( 50, 50, 50 ), self );
        self givemaxammo( weaponName );
        self giveStartAmmo( weaponName );
    }
}

// In case survivor joined mid game.
connected()
{
    self endon( "disconnect" );
    for( ;; )
    {
        self waittill( "spawned_player" );
        if ( self.pers["team"] == "allies" && getDvarInt( "net_port" ) == DEFAULT_PORT )
        {
            self thread giveLoad();
        }
    }
}

giveLoad()
{
    self takeallweapons();
//  Primary
    gunInt = randomint( level.myPrimaryGuns.size );
    gunName = level.myPrimaryGuns[ gunInt ];
    self giveWeapon( gunName );
    wait( .5 );
    self switchToWeapon( gunName );
//  Secondary
    gunInt = randomint( level.myPistols.size );
    gunName = level.myPistols[ gunInt ];
    self giveWeapon( gunName );
    self giveWeapon( "semtex_mp" );
    self SetOffhandSecondaryClass( "flash" );
    self giveWeapon( "portable_radar_mp", 0 );
    self giveStartAmmo( "portable_radar_mp" );
}
