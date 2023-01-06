# Crowd Control for Unreal Tournament 99

This is a mutator which can be used to connect to the Crowd Control service, which allows Twitch Viewers to interact with a game that a streamer is participating in.
Since only one instance of Crowd Control can be attached at a time, most effects apply to all players on the server simultaneously.  A few apply to the player in first/last place, and a few more apply to random players.


## Compiling

I have been compiling this project using UMake (https://ut99.org/viewtopic.php?f=58&t=14044).  Simply put the contents of this repository into a UT99CrowdControl folder in the main Unreal Tournament install directory, then drag the files inside the Classes folder onto UMake.
The compiled .u file will be put into the System folder.


## Installing

Either compile the .u file or download it from the Releases page and put it along with the .int file into the System folder of your Unreal Tournament installation.  The mutator should then be available to use in the Mutators menu.


## Usage

Once installed, start your game (Practice mode, "Crowd Control Tournament" through the Mods menu, Local Hosting, or on a Dedicated Server).  The "Start Unreal Tournament" option in the menu won't have Crowd Control, but you can use the "Start Crowd Control Tournament" option under the mods menu to play the campaign with Crowd Control.  If playing a practice game or hosting a server, make sure to enable the "Crowd Control support for UT99" mutator.

Single Player Campaign:
![CrowdControlTournament](https://user-images.githubusercontent.com/13684088/210175207-f7ad8f07-42f5-4c2a-87ec-d6f3bd288902.png)

Practice mode or hosting a server:
![CrowdControlMutator](https://user-images.githubusercontent.com/13684088/210175358-bd6ad463-c6ba-4ce2-812d-b32e757b59c7.png) 

If you are playing a local game or running the server on the same computer as Crowd Control, the mutator will be able to connect without any additional configuration.

If you are running the Crowd Control client on a different machine than the server (eg. you are using a dedicated server), you will need to tell the server where your Crowd Control client is.  Log in as an admin on your server (Go to console and use "adminlogin <adminpassword>").  Once logged in, you can configure the IP where the Crowd Control client (or OfflineCrowdControl script) is running.  To do this, go to the console and type

> mutate cc setip <ip-address-where-crowd-control-is-running>

Once the IP has been set, the mutator will likely automatically connect on its own.  If not, you can initiate a reconnect by going to the console and using

> mutate cc reconnect
  
If you are running the mutator on a different machine than the Crowd Control client (or the offlineCrowdControl script), you may need to ensure that you have port **43384** open for TCP traffic in order for things to work.

## Multiplayer HUD

While the new HUD elements for showing the active effects will work without any changes in singleplayer games, it won't show up in multiplayer without adding the package to your ServerPackages.  To do so, open your UnrealTournament.ini file (in your system folder) and find the section with a list of packages starting with "ServerPackages=" (In the "[Engine.GameEngine]" section).  Add a new line to the end of that list that says:

ServerPackages=UT99CrowdControl

Once added, players that join your game will be able to see the time remaining on any active Crowd Control effects.

![CrowdControlServerPackages](https://user-images.githubusercontent.com/13684088/210919471-29fa42d1-e476-4ffd-849f-6fadd1f7f4da.png)
## Online Multiplayer

Epic has taken their master servers offline, which would prevent players from finding online multiplayer games.  Luckily, the community has their own master servers ready to go!  While the server can be configured manually, the simplest solution is probably to install the [OldUnreal Unreal Tournament 99 patch](https://github.com/OldUnreal/UnrealTournamentPatches/releases), since that also fixes other issues at the same time.


## Where to Buy

Good luck!  Epic removed the game for sale from everywhere that I'm aware of.

## Feedback
  
Join the Discord server to discuss this mod or to provide feedback: https://discord.gg/GYqqDdAzzW

  

