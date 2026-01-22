//
//  main.m
//  MAFFia
//
//  Modern Cocoa entry point - most initialization moved to AppDelegate
//

#import <Cocoa/Cocoa.h>
#include "Pomme.h"
#include "mafftypes.h"
#include "main.h"

extern GlobalStuff *g;
extern void FinishSounds(void);
extern void RemoveAllLevels(void);
extern void RemoveAllScenery(void);
extern void DumpBackgrounds(void);
extern void RemoveAllSheep(void);
extern void RemoveAllScoreEffects(void);
extern void RemoveAllShotEffects(void);
extern void RemoveAllWeapons(void);
extern void UnloadHighScores(void);

// Main entry point - uses Cocoa application framework
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        return NSApplicationMain(argc, argv);
    }
}

// Stub - initialization handled by AppDelegate
void Initialise(void) {
    // Now handled by AppDelegate applicationDidFinishLaunching:
}

// Stub - event loop handled by Cocoa
void InterfaceLoop(void) {
    // Now handled by NSApplicationMain / Cocoa run loop
}

// Cleanup function - called by AppDelegate on termination
void CleanUp(bool instaQuit)
{
    if (!g) {
        if (instaQuit) exit(1);
        return;
    }
    
    short i = 0;
    
    // Note: Windows are managed by Cocoa now, we don't dispose them manually
    
    // Clean up GWorlds
    if (g->swapGWorld) DisposeGWorld(g->swapGWorld);
    if (g->interfaceBackGWorld) DisposeGWorld(g->interfaceBackGWorld);
    if (g->interfaceButtons) DisposeGWorld(g->interfaceButtons);
    if (g->interfaceRollover) DisposeGWorld(g->interfaceRollover);
    if (g->interfaceClick) DisposeGWorld(g->interfaceClick);
    if (g->aboutGWorld) DisposeGWorld(g->aboutGWorld);
    if (g->instructionsGWorld) DisposeGWorld(g->instructionsGWorld);
//    if (g->voteGWorld) DisposeGWorld(g->voteGWorld);
    
    if (g->gunsPictGWorld) DisposeGWorld(g->gunsPictGWorld);
    if (g->gunsPictMask) DisposeGWorld(g->gunsPictMask);
    if (g->lifePictGWorld) DisposeGWorld(g->lifePictGWorld);
    if (g->lifePictMask) DisposeGWorld(g->lifePictMask);
    if (g->sheepArrowGWorld) DisposeGWorld(g->sheepArrowGWorld);
    if (g->sheepArrowMask) DisposeGWorld(g->sheepArrowMask);
    
    if (g->SCBonusGWorld) DisposeGWorld(g->SCBonusGWorld);
    if (g->SKBonusGWorld) DisposeGWorld(g->SKBonusGWorld);
    if (g->LCBonusGWorld) DisposeGWorld(g->LCBonusGWorld);
    if (g->HFBonusGWorld) DisposeGWorld(g->HFBonusGWorld);
    if (g->JDBonusGWorld) DisposeGWorld(g->JDBonusGWorld);
    if (g->CUBonusGWorld) DisposeGWorld(g->CUBonusGWorld);
    if (g->bonusMask) DisposeGWorld(g->bonusMask);
    if (g->chainBonusGWorld) DisposeGWorld(g->chainBonusGWorld);
    if (g->chainBonusMask) DisposeGWorld(g->chainBonusMask);
    
    while (i < 5) {
        if (g->extraBonusGWorld[i]) DisposeGWorld(g->extraBonusGWorld[i]);
        i++;
    }
    
    if (g->msgLevelStartGWorld) DisposeGWorld(g->msgLevelStartGWorld);
    if (g->msgLevelStartMask) DisposeGWorld(g->msgLevelStartMask);
    if (g->msgLevelEndGWorld) DisposeGWorld(g->msgLevelEndGWorld);
    if (g->msgLevelEndMask) DisposeGWorld(g->msgLevelEndMask);
    if (g->msgGameOverGWorld) DisposeGWorld(g->msgGameOverGWorld);
    if (g->msgGameOverMask) DisposeGWorld(g->msgGameOverMask);
    if (g->msgCompletedGWorld) DisposeGWorld(g->msgCompletedGWorld);
    if (g->msgCompletedMask) DisposeGWorld(g->msgCompletedMask);
    if (g->msgPausedGWorld) DisposeGWorld(g->msgPausedGWorld);
    if (g->msgPausedMask) DisposeGWorld(g->msgPausedMask);
    
    if (g->theSheepType.liveSpriteRunRightA) DisposeGWorld(g->theSheepType.liveSpriteRunRightA);
    if (g->theSheepType.liveSpriteRunRightMaskA) DisposeGWorld(g->theSheepType.liveSpriteRunRightMaskA);
    if (g->theSheepType.liveSpriteRunRightB) DisposeGWorld(g->theSheepType.liveSpriteRunRightB);
    if (g->theSheepType.liveSpriteRunRightMaskB) DisposeGWorld(g->theSheepType.liveSpriteRunRightMaskB);
        
    if (g->theSheepType.liveSpriteRunLeftA) DisposeGWorld(g->theSheepType.liveSpriteRunLeftA);
    if (g->theSheepType.liveSpriteRunLeftMaskA) DisposeGWorld(g->theSheepType.liveSpriteRunLeftMaskA);
    if (g->theSheepType.liveSpriteRunLeftB) DisposeGWorld(g->theSheepType.liveSpriteRunLeftB);
    if (g->theSheepType.liveSpriteRunLeftMaskB) DisposeGWorld(g->theSheepType.liveSpriteRunLeftMaskB);
    
    if (g->theSheepType.originalDeadSpriteRight) DisposeGWorld(g->theSheepType.originalDeadSpriteRight);
    if (g->theSheepType.originalDeadSpriteRightMaskWithoutOutline) DisposeGWorld(g->theSheepType.originalDeadSpriteRightMaskWithoutOutline);
    if (g->theSheepType.originalDeadSpriteRightMaskWithOutline) DisposeGWorld(g->theSheepType.originalDeadSpriteRightMaskWithOutline);
    
    if (g->theSheepType.originalDeadSpriteLeft) DisposeGWorld(g->theSheepType.originalDeadSpriteLeft);
    if (g->theSheepType.originalDeadSpriteLeftMaskWithoutOutline) DisposeGWorld(g->theSheepType.originalDeadSpriteLeftMaskWithoutOutline);
    if (g->theSheepType.originalDeadSpriteLeftMaskWithOutline) DisposeGWorld(g->theSheepType.originalDeadSpriteLeftMaskWithOutline);
    
    if (g->theScoreStuff.scoreGraphics) DisposeGWorld(g->theScoreStuff.scoreGraphics);
    if (g->theScoreStuff.multiplierGraphics) DisposeGWorld(g->theScoreStuff.multiplierGraphics);
    if (g->theScoreStuff.scoreMask) DisposeGWorld(g->theScoreStuff.scoreMask);
    
    // Cursor is handled differently in Cocoa
    // ReleaseResource((Handle)g->crosshair);
    
    FinishSounds();
    
    RemoveAllSheep();
    RemoveAllScoreEffects();
    RemoveAllShotEffects();
    
    RemoveAllWeapons();
    RemoveAllLevels();
    RemoveAllScenery();
    DumpBackgrounds();
    
    // Depth switching is obsolete
    // ChangeDepthBack();
    
    UnloadHighScores();
    
    if (g) DisposePtr((Ptr)g);
    g = NULL;
    
    if (instaQuit)
        exit(1);
}
