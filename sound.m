/*
 *  sound.c
 *  nibMAFF
 *
 *  Created by William Reade on Sat Oct 26 2002.
 *  Copyright (c) 2002 William Reade. All rights reserved.
 *
 */

#include "sound.h"
#include "mafftypes.h"

extern GlobalStuff *g;
extern void CleanUp(bool instaQuit);



void LoadSounds(void)
{
    short	i = 0;
    OSErr	err;
    Weapon	*theWeapon;
    
    while (i < NUM_SOUND_CHANNELS)
    {
        err = SndNewChannel(&(g->sndChannel[i]), sampledSynth, initMono, NULL);
        
        if (err != noErr)
            CleanUp(true);
        
        i++;
    }
    
    theWeapon = g->baseWeapon;
    theWeapon->shotSoundHandle = GetNamedResource('snd ', "\puzi");
    if (!theWeapon->shotSoundHandle)
        CleanUp(true);
    
    theWeapon = theWeapon->next;
    theWeapon->shotSoundHandle = GetNamedResource('snd ', "\pmagnum");
    if (!theWeapon->shotSoundHandle)
        CleanUp(true);
    
    theWeapon = theWeapon->next;
    theWeapon->shotSoundHandle = GetNamedResource('snd ', "\pshotgun");
    if (!theWeapon->shotSoundHandle)
        CleanUp(true);
    
    theWeapon = theWeapon->next;
    theWeapon->shotSoundHandle = GetNamedResource('snd ', "\pflamer");
    if (!theWeapon->shotSoundHandle)
        CleanUp(true);
    
    g->sounds.SCBonus = GetNamedResource('snd ', "\pscbonus");
    if (!g->sounds.SCBonus)
        CleanUp(true);
    
    g->sounds.LCBonus = GetNamedResource('snd ', "\plcbonus");
    if (!g->sounds.SCBonus)
        CleanUp(true);
    
    g->sounds.lastLife = GetNamedResource('snd ', "\plastlife");
    if (!g->sounds.lastLife)
        CleanUp(true);
    
    g->sounds.splat = GetNamedResource('snd ', "\psplat");
    if (!g->sounds.splat)
        CleanUp(true);
    
    g->sounds.stateSwitch = GetNamedResource('snd ', "\pstateswitch");
    if (!g->sounds.stateSwitch)
        CleanUp(true);
    
    g->sounds.weaponSwitch = GetNamedResource('snd ', "\pweaponswitch");
    if (!g->sounds.weaponSwitch)
        CleanUp(true);
    
    g->sounds.baa = GetNamedResource('snd ', "\pbaa");
    if (!g->sounds.baa)
        CleanUp(true);
    
    g->sounds.clank = GetNamedResource('snd ', "\pclank");
    if (!g->sounds.baa)
        CleanUp(true);
    
    g->sounds.breakchain = GetNamedResource('snd ', "\pbreakchain");
    if (!g->sounds.baa)
        CleanUp(true);
    
    
}

void FinishSounds(void)
{
    short	i = 0;
    Weapon	*theWeapon;
    SndCommand	shutUp;
    
    shutUp.cmd = quietCmd;
    shutUp.param1 = 0;
    shutUp.param2 = 0;
    
    while (i < NUM_SOUND_CHANNELS)
    {
        if (g->sndChannel[i])
        {
            SndDoImmediate(g->sndChannel[i], &shutUp);
            SndDisposeChannel(g->sndChannel[i], false);
        }
        
        i++;
    }
    
    theWeapon = g->baseWeapon;
    if (theWeapon->shotSoundHandle)
        ReleaseResource(theWeapon->shotSoundHandle);
    
    theWeapon = theWeapon->next;
    if (theWeapon->shotSoundHandle)
        ReleaseResource(theWeapon->shotSoundHandle);
    
    theWeapon = theWeapon->next;
    if (g->theWeapon->shotSoundHandle)
        ReleaseResource(theWeapon->shotSoundHandle);
    
    theWeapon = theWeapon->next;
    if (g->theWeapon->shotSoundHandle)
        ReleaseResource(theWeapon->shotSoundHandle);
    
    if (g->sounds.SCBonus)
        ReleaseResource(g->sounds.SCBonus);
    
    if (g->sounds.LCBonus)
        ReleaseResource(g->sounds.LCBonus);
    
    if (g->sounds.lastLife)
        ReleaseResource(g->sounds.lastLife);
    
    if (g->sounds.splat)
        ReleaseResource(g->sounds.splat);
    
    if (g->sounds.stateSwitch)
        ReleaseResource(g->sounds.stateSwitch);
    
    if (g->sounds.weaponSwitch)
        ReleaseResource(g->sounds.weaponSwitch);
    
    if (g->sounds.baa)
        ReleaseResource(g->sounds.baa);
    
    if (g->sounds.clank)
        ReleaseResource(g->sounds.clank);
    
    if (g->sounds.breakchain)
        ReleaseResource(g->sounds.breakchain);
}


void PlaySound(short channel, Handle sound)
{
    SndCommand		shutUp;
    
     if (g->pref.sound)
    {
        if (sound)
        {
            shutUp.cmd = quietCmd;
            shutUp.param1 = 0;
            shutUp.param2 = 0;
            
            SndDoImmediate(g->sndChannel[channel], &shutUp);
            
            HLock(sound);
            SndPlay (g->sndChannel [channel], (SndListResource **)sound, true);
            HUnlock(sound);
        }
    }
}

























