﻿using System.Diagnostics.CodeAnalysis;
using ConnectorLib.SimpleTCP;
using CrowdControl.Common;
using ConnectorType = CrowdControl.Common.ConnectorType;

namespace CrowdControl.Games.Packs.UnrealTournament99;

public class UnrealTournament99 : SimpleTCPPack<SimpleTCPServerConnector>
{
    public override string Host => "0.0.0.0";

    public override ushort Port => 43384;

    [SuppressMessage("CrowdControl.PackMetadata", "CC1009:Message Format Property")]
    public override ISimpleTCPPack.MessageFormatType MessageFormat => ISimpleTCPPack.MessageFormatType.CrowdControlLegacy;

    public UnrealTournament99(UserRecord player, Func<CrowdControlBlock, bool> responseHandler, Action<object> statusUpdateHandler) : base(player, responseHandler, statusUpdateHandler) { }

    public override Game Game { get; } = new("Unreal Tournament 99", "UnrealTournament99", "PC", ConnectorType.SimpleTCPServerConnector);

    //Weapon list
    private static readonly ParameterDef weaponList = new("Weapons", "weapons",
        new Parameter("Translocator", "translocator"),
        new Parameter("Ripper", "ripper"),
        new Parameter("BioRifle", "biorifle"),
        new Parameter("Flak Cannon", "flakcannon"),
        new Parameter("Sniper Rifle", "sniperrifle"),
        new Parameter("Shock Rifle", "shockrifle"),
        new Parameter("Pulse Rifle", "pulsegun"),
        new Parameter("Minigun", "minigun"),
        new Parameter("Rocket Launcher", "rocketlauncher")
    );

    //Ammo List
    private static readonly ParameterDef ammoList = new("Ammo", "ammo",
        new Parameter("Flak Ammo", "flakammo"),
        new Parameter("BioRifle Goo", "bioammo"),
        new Parameter("Redeemer Missile", "warheadammo"),
        new Parameter("Pulse Rifle Ammo", "pammo"),
        new Parameter("Shock Rifle Core", "shockcore"),
        new Parameter("Ripper Blades", "bladehopper"),
        new Parameter("Rockets", "rocketpack"),
        new Parameter("Sniper Ammo", "bulletbox"),
        new Parameter("Minigun/Enforcer Ammo", "miniammo")
    );

    public override EffectList Effects { get; } = new Effect[]
    {
        //General Effects
        new("Go Third-Person", "third_person"){Price = 10, Description = "Force players to see themselves!", Duration=60},
        new("Full Fat Tournament", "full_fat"){Price = 5, Description = "All players become extremely fat!", Duration=60},
        new("Just Skin and Bones", "skin_and_bones"){Price = 4, Description = "All players become extremely skinny!", Duration=60},
        new("Spawn an Attacking Bot (One Death)", "spawn_a_bot_attack"){Price = 10, Description = "This will spawn a bot on whatever team has the least amount of players and will be on the offensive"},
        new("Spawn a Defending Bot (One Death)", "spawn_a_bot_defend"){Price = 10, Description = "This will spawn a bot on whatever team is has the least amount of players with orders to defend their base"},
        new("Reset Domination Control Points", "reset_domination_control_points"){Price = 5, Description = "This will reset all control points in Domination Mode to neutral"},
        new("Return Flags", "return_ctf_flags"){Price = 5, Description = "In Capture the Flag Mode, this will return all flags to their base"},
        new("Explosive Corpses", "explosive_corpses"){Price = 5, Description = "Players explode when they die!", Duration=60},
        new("Slime-Filled Bodies", "slime_corpses"){Price = 5, Description = "Players spurt toxic goo when they take damage and when they die!", Duration=60},
        new("Blue (Redeemer) Shell", "blue_redeemer_shell") {Price = 15, Description = "Drops a redeemer explosion on the player in first place!" },

        ////////////////////////////////////////////////////////////////

        //Movement and Camera
        new("Gotta Go Fast", "gotta_go_fast"){ Category = "Movement & Camera", Price = 10, Description = "It's extra fast mode!", Duration=60},
        new("Gotta Go Slow", "gotta_go_slow"){ Category = "Movement & Camera", Price = 10, Description = "It's extra slow mode!", Duration=15},
        new("Swap All Players Positions", "swap_player_position"){ Category = "Movement & Camera", Price = 10, Description = "All players swap positions with other players on the map!"},
        new("Nudge All Players", "nudge"){ Category = "Movement & Camera", Price = 5, Description = "Push the players around!"},
        new("Ice Physics", "ice_physics"){ Category = "Movement & Camera", Price = 10, Description = "Summon frosty floors!", Duration=60},
        new("Low Gravity", "low_grav"){ Category = "Movement & Camera", Price = 5, Description = "Low gravity means players jump higher!", Duration=60},
        new("Extreme Gravity", "jupiter_physics"){ Category = "Movement & Camera", Price = 5, Description = "Gravity becomes much stronger, so players can't jump as high and take fall damage from lower heights!", Duration=60},
        new("Flood the Arena", "flood"){ Category = "Movement & Camera", Price = 10, Description = "Flood the arena!", Duration=20},
        new("Slow First Place Player", "first_place_slow"){ Category = "Movement & Camera", Price = 5, Description = "The first place player is too good, let's punish them!", Duration=45},
        new("Jump Boot Madness", "jump_boot_madness"){ Category = "Movement & Camera", Price = 3, Description = "Give all players jump boots and keep them topped up so they can jump really high!", Duration=60},
        new("Red Light, Green Light", "red_light_green_light"){ Category = "Movement & Camera", Price = 10, Description = "The light randomly changes between Red and Green!  Move while the light is red and... KABOOM!", Duration=60},
        new("Bouncy Castle", "bouncy_castle"){ Category = "Movement & Camera", Price = 3, Description = "Everyone gets periodically bounced up into the air!", Duration=60},

        ////////////////////////////////////////////////////////////////
        
        //new("Health and Armor","health",ItemKind.Folder),
        new("Full Heal", "full_heal") { Category = "Health & Ammo", Price = 5, Description = "Send a full heal to all players!" },
        new("Shield Belts for All", "full_armour") { Category = "Health & Ammo", Price = 5, Description = "You get a shield belt and you get a shield belt! Everyone gets shield belts!" },
        new("Give Health", "give_health")
        {
            Quantity = 200,
            Category = "Health & Ammo",
            Price = 1,
            Description = "Give a little health!"
        },
        new("Sudden Death", "sudden_death") { Category = "Health & Ammo", Price = 10, Description = "Activate sudden death mode!" },
        new("Thanos Snap", "thanos") { Category = "Health & Ammo", Price = 15, Description = "Half of the players in the match get obliterated!" },
        new("Vampiric Attacks", "vampire_mode") { Category = "Health & Ammo", Price = 10, Description = "All attacks by players sap some life, healing the player!", Duration=60 },
        new("Give Shield Belt to Last Place", "last_place_shield") { Category = "Health & Ammo", Price = 5, Description = "Help out that last place player!" },
        new("Regenerating Health", "health_regen") { Category = "Health & Ammo", Price = 10, Description = "All players regenerate 5 health per second!", Duration=60 },
        
        /////////////////////////////////////////////////////////////////
        
        //new("Weapons and Damage","weapons",ItemKind.Folder),
        new("Give Weapon to All", "give_weapon")
        {
            Parameters = weaponList,
            Category = "Weapons & Damage",
            Price = 5,
            Description = "Give all players any normal weapon in the game!"
        }, //Needs to use a weapons list
        new("Give Instagib Rifles to All", "give_instagib") { Category = "Weapons & Damage", Price = 15, Description = "Give an Instagib Rifle to all players!" },
        new("Give Redeemers to All", "give_redeemer") { Category = "Weapons & Damage", Price = 15, Description = "Give a redeemer to all players!" },
        new("Force Everybody to Use Weapon", "force_weapon_use")
        {
            Parameters = weaponList,
            Category = "Weapons & Damage",
            Price = 25,
            Description = "Force all players to only use one specific weapon you choose!",
            Duration=60
        }, //Needs to use a weapons list
        new("Force All Players to use Instagib Rifle", "force_instagib") { Category = "Weapons & Damage", Price = 15, Description = "Force all players to use an Instagib Rifle only", Duration=60 },
        new("Force All Players to use Redeemers", "force_redeemer") { Category = "Weapons & Damage", Price = 15, Description = "Force all players to use redeemers only!", Duration=60 },
        new("Give Ammo", "give_ammo")
        {
            Quantity = 10,
            Parameters = ammoList,
            Category = "Weapons & Damage",
            Price = 1,
            Description = "Give some specific ammo of your choice to all players!"
        },
        new("Remove All Ammo", "no_ammo") { Category = "Weapons & Damage", Price = 10, Description = "Steal all ammo from players!" },
        new("Bonus Damage for All", "bonus_dmg") { Category = "Weapons & Damage", Price = 5, Description = "Pump up the damage on all players" },
        new("Melee Only!", "melee_only") { Category = "Weapons & Damage", Price = 10, Description = "Never mind these guns, it's punching time!", Duration=60 },
        new("Bonus Damage for Last Place", "last_place_bonus_dmg") { Category = "Weapons & Damage", Price = 5, Description = "Help out the last place player and grant them bonus damage!" },
        new("All Players Drop Current Weapon", "drop_selected_item") { Category = "Weapons & Damage", Price = 10, Description = "Who needs this weapon anyway..." },
        new("Thorns", "thorns") { Category = "Weapons & Damage", Price = 5, Description = "All players grow thorns, inflicting damage back on those who are dealing damage.", Duration=60},
        new("Weapon Chaos", "random_weapon_swap") { Category = "Weapons & Damage", Price = 5, Description = "All players start randomly switching weapons!", Duration=60},
        new("Infinite Razors", "infinite_razor") { Category = "Weapons & Damage", Price = 5, Description = "All razors fired from the Ripper gun bounce forever while the effect is active.", Duration=60},
        new("Massive Momentum", "massive_momentum"){ Category = "Weapons & Damage", Price = 3, Description = "All damage imparts significantly more momentum to the target!", Duration=60}
    };
}