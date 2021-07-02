/*
	_InfPerks
	Author: Diavolo
	Date: 20/06/2021
*/

#include common_scripts\utility;
#include maps\mp\_utility;

DEFAULT_PORT = 27017;

init()
{
    thread onConnect();
}

onConnect()
{
    if ( getDvarInt( "net_port" ) != DEFAULT_PORT ) return;
    for ( ;; )
    {
        level waittill( "connected", player );
        player thread connected();
    }
}

connected()
{
    self endon( "disconnect" );
    for( ;; )
    {
        self waittill( "spawned_player" );
        if ( self.pers["team"] == "axis" )
        {
            self thread givePerk();
        }
    }
}

givePerk()
{
    num = RandomInt( 10 );

    switch( num )
    {
        case 0:
            self maps\mp\killstreaks\_juggernaut::giveJuggernaut( "juggernaut_recon" );
            break;
        case 1:
            self maps\mp\killstreaks\_killstreaks::giveKillstreak( "airdrop_support" );
            break;
        case 2:
            setDvar( "sv_iw4madmin_command", "air_drop;" + self getentitynumber() );
            break;
        case 3:
            setDvar( "sv_iw4madmin_command", "wall;" + self getentitynumber() );
            break;
    }
}
