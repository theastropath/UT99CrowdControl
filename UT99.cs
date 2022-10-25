using System;
using System.Collections.Generic;
using CrowdControl.Common;
using CrowdControl.Games.Packs;
using ConnectorType = CrowdControl.Common.ConnectorType;

public class UnrealTournament99 : SimpleTCPPack
{
    public override string Host => "0.0.0.0";

    public override ushort Port => 43384;

    public UnrealTournament99(IPlayer player, Func<CrowdControlBlock, bool> responseHandler, Action<object> statusUpdateHandler) : base(player, responseHandler, statusUpdateHandler) { }

    public override Game Game { get; } = new Game(90, "Unreal Tournament 99", "UnrealTournament99", "PC", ConnectorType.SimpleTCPConnector);

    public override List<Effect> Effects => new List<Effect>
    {
        //General Effects
        new Effect("Go Third-Person", "third_person"),
        new Effect("Full Fat Tournament", "full_fat"),
        new Effect("Just Skin and Bones", "skin_and_bones"),
        new Effect("Gotta Go Fast (60 Seconds)", "gotta_go_fast"),
        new Effect("Gotta Go Slow (15 Seconds)", "gotta_go_slow"),
        new Effect("Swap Two Players Positions", "swap_player_position"),
        new Effect("Nudge All Players", "nudge"),
        new Effect("Ice Physics", "ice_physics"),
        new Effect("Low Gravity", "low_grav"),
        new Effect("Flood the Arena (20 Seconds)", "flood"),
        new Effect("Slow First Place Player", "first_place_slow"),
        new Effect("Spawn an Attacking Bot (One Death)", "spawn_a_bot_attack"),
        new Effect("Spawn a Defending Bot (One Death)", "spawn_a_bot_defend"),
        
        ////////////////////////////////////////////////////////////////
        
        new Effect("Health and Armor","health",ItemKind.Folder),
        new Effect("Full Heal", "full_heal","health"),
        new Effect("Shield Belts for All", "full_armour","health"),
        new Effect("Give Health", "give_health",new[]{"amount200"},"health"),
        new Effect("Sudden Death", "sudden_death","health"),
        new Effect("Thanos Snap", "thanos","health"),
        new Effect("Vampiric Attacks", "vampire_mode","health"),
        new Effect("Give Shield Belt to Last Place", "last_place_shield","health"),
        new Effect("Blue (Redeemer) Shell", "blue_redeemer_shell","health"),
        
        /////////////////////////////////////////////////////////////////
        
        new Effect("Weapons and Damage","weapons",ItemKind.Folder),
        new Effect("Give Weapon to All", "give_weapon",new[]{"weaponlist"},"weapons"), //Needs to use a weapons list
        new Effect("Give Instagib Rifles to All", "give_instagib","weapons"),
        new Effect("Give Redeemers to All", "give_redeemer","weapons"),
        new Effect("Force Everybody to Use Weapon", "force_weapon_use",new[]{"weaponlist"},"weapons"), //Needs to use a weapons list
        new Effect("Force All Players to use Instagib Rifle", "force_instagib","weapons"),
        new Effect("Force All Players to use Redeemers", "force_redeemer","weapons"),
        new Effect("Give Ammo", "give_ammo",new[]{"ammolist","amount10"},"weapons"),
        new Effect("Remove All Ammo", "no_ammo","weapons"),
        new Effect("Bonus Damage for All", "bonus_dmg","weapons"),
        new Effect("Melee Only! (60 seconds)", "melee_only","weapons"),
        new Effect("Bonus Damage for Last Place", "last_place_bonus_dmg","weapons"),
        new Effect("All Players Drop Current Weapon", "drop_selected_item","weapons"),
        
        
        
        ////////////////////////////////////////////////////////////////////////////////////////
        
        
        
        
        //Weapon list
        new Effect("Translocator","translocator",ItemKind.Usable,"weaponlist"),
        new Effect("Ripper","ripper",ItemKind.Usable,"weaponlist"),
        new Effect("BioRifle","biorifle",ItemKind.Usable,"weaponlist"),
        new Effect("Flak Cannon","flakcannon",ItemKind.Usable,"weaponlist"),
        new Effect("Sniper Rifle","sniperrifle",ItemKind.Usable,"weaponlist"),
        new Effect("Shock Rifle","shockrifle",ItemKind.Usable,"weaponlist"),
        new Effect("Pulse Rifle","pulsegun",ItemKind.Usable,"weaponlist"),
        new Effect("Minigun","minigun",ItemKind.Usable,"weaponlist"),
        new Effect("Rocket Launcher","rocketlauncher",ItemKind.Usable,"weaponlist"),

        //Ammo List
        new Effect("Flak Ammo","flakammo",ItemKind.Usable,"ammolist"),
        new Effect("BioRifle Goo","bioammo",ItemKind.Usable,"ammolist"),
        new Effect("Redeemer Missile","warheadammo",ItemKind.Usable,"ammolist"),
        new Effect("Pulse Rifle Ammo","pammo",ItemKind.Usable,"ammolist"),
        new Effect("Shock Rifle Core","shockcore",ItemKind.Usable,"ammolist"),
        new Effect("Ripper Blades","bladehopper",ItemKind.Usable,"ammolist"),
        new Effect("Rockets","rocketpack",ItemKind.Usable,"ammolist"),
        new Effect("Sniper Ammo","bulletbox",ItemKind.Usable,"ammolist"),
        new Effect("Minigun/Enforcer Ammo","miniammo",ItemKind.Usable,"ammolist"),
        
    };

    //Slider ranges need to be defined
    public override List<ItemType> ItemTypes => new List<ItemType>(new[]
    {
        new ItemType("Amount","amount10",ItemType.Subtype.Slider, "{\"min\":1,\"max\":10}"),
        new ItemType("Amount","amount200",ItemType.Subtype.Slider, "{\"min\":1,\"max\":200}"),
        new ItemType("Weapons","weaponlist",ItemType.Subtype.ItemList),
        new ItemType("Ammo","ammolist",ItemType.Subtype.ItemList),
    });
}
