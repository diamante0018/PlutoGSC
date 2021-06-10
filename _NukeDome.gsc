/*
	_NukeDome
	Author: Diavolo
	Date: 10/06/2021
*/

#include common_scripts\utility;
#include maps\mp\_utility;

init()
{
    level._effect[ "nolight_burst_mp" ]	= loadfx( "fire/firelp_huge_pm_nolight_burst" );
    precacheMpAnim( "windmill_spin_med" );
    precacheMpAnim( "foliage_desertbrush_1_sway" );
    precacheMpAnim( "oilpump_pump01" );
    precacheMpAnim( "oilpump_pump02" );
    precacheMpAnim( "windsock_large_wind_medium" );

    thread domeDyn();
    thread nukeDeath();
}

domeDyn()
{
    if ( getDvar( "mapname" ) != "mp_dome" )
    {
        return;
    }

    animated = getentarray( "animated_model", "targetname" );
    print( "domeDyn: animated_model size " + animated.size );
    for ( i = 0; i < animated.size; i++ )
    {
        model_name = animated[i].model;
        if ( isSubStr( model_name, "fence_tarp_" ) )
        {
//          print( "domeDyn fence_tarp_" );
            animated[i].targetname = "dynamic_model";
            precacheMpAnim( model_name + "_med_01" );
            animated[i] ScriptModelPlayAnim( model_name + "_med_01" );
        }
        else if ( model_name == "machinery_windmill" )
        {
//          print( "domeDyn machinery_windmill" );
            animated[i].targetname = "dynamic_model";
            animated[i] ScriptModelPlayAnim( "windmill_spin_med" );
        }
        else if ( isSubStr( model_name, "foliage" ) )
        {
//          print( "domeDyn foliage" );
            animated[i].targetname = "dynamic_model";
            animated[i] ScriptModelPlayAnim( "foliage_desertbrush_1_sway" );
        }
        else if ( isSubStr( model_name, "oil_pump_jack" ) )
        {
//          print( "domeDyn oil_pump_jack" );
            animated[i].targetname = "dynamic_model";
            animation = "oilpump_pump0" + ( randomint( 2 ) + 1 );
            animated[i] ScriptModelPlayAnim( animation );
        }
        else if ( model_name == "accessories_windsock_large" )
        { 
//          print( "domeDyn accessories_windsock_large" );
            animated[i].targetname = "dynamic_model";
            animated[i] ScriptModelPlayAnim( "windsock_large_wind_medium" );
        }
    }
}

doBoxEffect( effect )
{
    wait ( 3 );
    forward = AnglesToForward( self.angles );
    up = AnglesToUp( self.angles );

    effect delete();
    PlayFX( getfx( "box_explode_mp" ), self.origin, forward, up );

    self self_func( "scriptModelClearAnim" );
    self Hide();
}

fence_effect()
{
    forward = AnglesToForward( self.angles );
    up = AnglesToUp( self.angles );

    fxEnt = SpawnFx( getfx( "nolight_burst_mp" ), self.origin, forward, up );
    TriggerFx( fxEnt );

    self thread doBoxEffect( fxEnt );
}

clear_amim( delay )
{
    wait ( delay );
    self self_func( "scriptModelClearAnim" );
}

windsock_large()
{
    self self_func( "scriptModelClearAnim" );
    self.origin += (0, 0, 20);
    bounds_1 = spawn("script_model", self.origin + (15, -7, 0) );
    bounds_2 = spawn("script_model", self.origin + (70, -38, 0) );

    bounds_1 setModel( "com_plasticcase_friendly" );
    bounds_2 setModel( "com_plasticcase_friendly" );

    bounds_1 hide();
    bounds_2 hide();

    bounds_1 CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
    bounds_2 CloneBrushmodelToScriptmodel( level.airDropCrateCollision );

    bounds_1 SetContents( 1 );
    bounds_2 SetContents( 1 );

    bounds_1.angles = self.angles + (0, 90, 0);
    bounds_2.angles = bounds_1.angles;

    self linkto( bounds_2 );
    bounds_2 linkto( bounds_1 );
    bounds_1 PhysicsLaunchServer( (0,0,0), (-400, -250, 10) );
}

// Causes some errors so for now I don't use this
destroy()
{
    a1 = getentarray( "destructible_toy", "targetname" );
    foreach( e in a1 )
    {
        e notify( "damage", e.health, "", (0, 0, 0), (0, 0, 0), "MOD_EXPLOSIVE", "", "", "", 0, "frag_grenade_mp" ); 
    }

    a2 = getentarray( "destructible_vehicle", "targetname" );
    foreach( e in a2 )
    {
        e notify( "damage", 999999, "", (0, 0, 0), (0, 0, 0), "MOD_EXPLOSIVE", "", "", "", 0, "frag_grenade_mp" );
    }

    a3 = getentarray( "explodable_barrel", "targetname" );
    foreach( e in a3 )
    {
        e notify( "damage", 999999, "", (0, 0, 0), (0, 0, 0), "MOD_EXPLOSIVE", "", "", "", 0, "frag_grenade_mp" );
    }

    level notify( "game_cleanup" );
}

nukeDeath()
{
    level endon( "game_ended" );
    gameFlagWait( "prematch_done" );
    if ( getDvar( "mapname" ) != "mp_dome" )
    {
        return;
    }

    for ( ;; )
    {
        level waittill( "nuke_death" );
        dynamic = getentarray( "dynamic_model", "targetname" );
        print ( "dynamic_model size: " + dynamic.size);
        for ( i = 0; i < dynamic.size; i++ )
        {
            model_name = dynamic[i].model;
            if ( isSubStr( model_name, "fence_tarp_" ) )
            {
//              print( "Doing fence_effect" );
                dynamic[i] thread fence_effect();
            }

            else if ( model_name == "machinery_windmill" )
            {
//              print( "Doing machinery_windmill" );
                dynamic[i] rotateroll( 80, 2, .5, .1 );
                dynamic[i] thread clear_amim( 1 );
            }

            else if ( isSubStr( model_name, "foliage" ) )
            {
//              print( "Doing foliage" );
                dynamic[i].origin -= (0, 0, 50);
            }

            else if ( isSubStr( model_name, "oil_pump_jack" ) )
            {
//              print( "Doing oil_pump_jack" );
                dynamic[i] self_func( "scriptModelClearAnim" );
            }

            else if ( model_name == "accessories_windsock_large" )
            {
//              print( "Doing accessories_windsock_large" );
                dynamic[i] thread windsock_large();
            }
        }

        wait( 5 );
//      thread destroy();     
    }
}
