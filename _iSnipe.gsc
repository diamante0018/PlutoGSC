/*
	_iSnipe
	Author: Diavolo
	Date: 04/07/2021
*/

#include common_scripts\utility;
#include maps\mp\_utility;

init()
{
    create_dvar( "sv_antiHardScope", 1 );
    thread onConnect();
}

onConnect()
{
    for ( ;; )
    {
        level waittill( "connected", player );
        player thread connected();
        player thread spawned();
    }
}

spawned()
{
    level endon( "game_ended" );
    self endon ( "disconnect" );
    for ( ;; )
    {
        self waittill( "spawned_player" );
        if ( self hasWeapon( "stinger_mp" ) )
        {
            self takeWeapon( "stinger_mp" );
        }
    }
}

connected()
{
    if ( getDvarInt( "sv_antiHardScope" ) != 1) return;
    level endon( "game_ended" );
    self endon ( "disconnect" );

    self.check_ads_cycle = 0;
    for ( ;; )
    {
        wait( .2 );
        if ( !IsAlive( self ) ) continue;

        ads = self PlayerADS();
        adsCycles = self.check_ads_cycle;
        if ( ads == 1 )
        {
            adsCycles += 1;
        }

        else
        {
            adsCycles = 0;
        }

        if ( adsCycles > 3 )
        {
            self allowAds( false );
            self iPrintLnBold( "Hard Scoping is not allowed" );
        }

        if ( !self adsButtonPressed() )
        {
            self allowAds( true );
        }

        self.check_ads_cycle = adsCycles;
    }
}
