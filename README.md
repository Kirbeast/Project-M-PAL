# Project M PAL
As the offical developement of Project M and therefore the PAL port has been cancelled, we will porting it.  
Be aware that this is **experimental!** While there shouldn't be any issues when testing on a real console, please do so only if you are experienced enough.

[![Visit our Discord channel](https://i.imgur.com/uBnGtnG.png)](https://discord.gg/BAUU4Vu)
# Tools needed
- A Gecko Code compiler (Recommended: jwiicm)
- When using Dolphin, a tool that can mount the SD.raw (Recommended: ImDisk)

# Installation (Homebrew only)
1. Connect your SD card to your computer. (Dolphin: Go to My Documents\Dolphin\Wii and mount the SD.raw)
2. Download any version of Project M and copy the content into the root of your SD.
3. Copy the content of **build** into the root of your SD
4. Then go into the Folder **projectm** -> **pf** and delete or rename these folders and files:

- **fighter** (For Advanced Users see: Characters)
- **item** (Not tested yet)
- **module** (Not tested yet)
- **stage** (For Advanced Users see: Stages)
- **info2** (Crashes Stadium Modes and Menu)
- **system -> common3.pac**

# Updating the Codes (Dolphin)
I've included a Batch file that updates the Codes in the "SD.raw". You need a folder "tools" with jwiicm in it and ImDisk installed.

# Characters
### Working:
- **Kirby**: Dash Attack has no Flame Effect. Final Cutter can't attack horizontal. Copy Abilities are crashing the game.

### Not Working:
- **Characters**: Aerials, Jab, and dash crash the game

# Stages
- **Metal Cavern**: crashes
- **Saffron City**: crashes
- **Yoshi's Story**: Collisions do not match
- (Battlefield: Loads the Brawl version. I am using the netplay version of PM, but normally it should load the Melee version)
- **Pokemon Stadium**: Glitched. Collisions do not match. Starts as a transformed version.
- **Rumble Falls**: crashes

# Specials Thanks
- Sarg
- Dantrion
- Wiiztec
- PMDT for creating this wonderful mod
