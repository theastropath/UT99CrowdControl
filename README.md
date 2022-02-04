# Crowd Control for Unreal Tournament 99

This is a mutator which can be used to connect to the Crowd Control service, which allows Twitch Viewers to interact with a game that a streamer is participating in.
Since only one instance of Crowd Control can be attached at a time, most effects apply to all players on the server simultaneously.  A few apply to the player in first/last place, and a few more apply to random players.


## Compiling

I have been compiling this project using UMake (https://ut99.org/viewtopic.php?f=58&t=14044).  Simply put the contents of this repository into a UT99CrowdControl folder in the main Unreal Tournament install directory, then drag the files inside the Classes folder onto UMake.
The compiled .u file will be put into the System folder.


## Installing

Either compile the .u file or download it from the Releases page and put it along with the .int file into the System folder of your Unreal Tournament installation.  The mutator should then be available to use in the Mutators menu.