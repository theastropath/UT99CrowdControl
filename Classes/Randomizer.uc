class Randomizer extends Mutator;

function InitRando()
{
    ShuffleItems();
}

function ShuffleItems()
{
    local Inventory item, items[512], weapons[128];
    local int num_items, num_weapons, i, slot;

    foreach AllActors(class'Inventory', item) {
        if(item.Owner != None) continue;
        if(Weapon(item) != None)
            weapons[num_weapons++] = item;
        else
            items[num_items++] = item;
    }

    for(i=0; i<num_items; i++) {
        slot = Rand(num_items);
        if(slot != i)
            SwapActors(items[i], items[slot]);
    }

    for(i=0; i<num_weapons; i++) {
        slot = Rand(num_weapons);
        if(slot != i)
            SwapActors(weapons[i], weapons[slot]);
    }
}

function SwapActors(Actor a, Actor b)
{
    local vector locA;
    local Rotator rotA;

    locA = a.Location;
    rotA = a.Rotation;
    a.SetLocation(b.Location);
    a.SetRotation(b.Rotation);
    b.SetLocation(locA);
    b.SetRotation(rotA);
}

simulated function PreBeginPlay()
{
   InitRando();
   CheckServerPackages();
}

function CheckServerPackages()
{
    local string packages;

    if (Level.NetMode!=NM_DedicatedServer && Level.NetMode!=NM_ListenServer){
        //Not hosting a server, don't worry about it
        return;
    }

    packages=ConsoleCommand("get Engine.GameEngine ServerPackages");
    if (InStr(packages,"UT99CrowdControl")!=-1){
        log("UT99CrowdControl is set in ServerPackages!  Nice!");
    } else {
        log("UT99CrowdControl is not set in ServerPackages!  Bummer!");
        packages = Left(packages,Len(packages)-1)$",\"UT99CrowdControl\")";
        log("Added UT99CrowdControl to ServerPackages!");
        ConsoleCommand("set Engine.GameEngine ServerPackages "$packages);

        //Reload the level so that the serverpackages gets updated for real
        log("Restarting game so that ServerPackages are reloaded");
        Level.ServerTravel( "?Restart", false );
    }
}
