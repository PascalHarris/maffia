/*
 *  loading.c
 *  nibMAFF
 *
 *  Created by wibble on Fri Sep 06 2002.
 *  Copyright (c) 2002 William Reade. All rights reserved.
 *
 */

//#include "Pomme.h"
//#include <QuickTime/QuickTime.h>
//#include <QuickTime/QuickTimeComponents.h>
//#include <CoreServices/CoreServices.h>
//
//#include "loading.h"
//#include "mafftypes.h"
//
//#define PRF_CUR kCFPreferencesCurrentApplication
//
//extern void CleanUp(bool instaQuit);
//extern GlobalStuff *g;
//extern void ClearGWorld (GWorldPtr theGWorld, short colour);
//extern void LoadSounds(void);
//extern void LoadHighScores(void);
//extern void WindowSizeHack(Boolean repos);

#include "Pomme.h"
#import <Cocoa/Cocoa.h>
#include "mafftypes.h"
#include "loading.h"

#define PRF_CUR kCFPreferencesCurrentApplication

extern GlobalStuff *g;
extern void CleanUp(bool instaQuit);
extern void ClearGWorld(GWorldPtr theGWorld, short colour);
extern void LoadHighScores(void);
extern void WindowSizeHack(Boolean repos);

void LoadPicture(CFStringRef name, GWorldPtr *theGWorld, bool flipped)
{
    // Get URL for resource
    CFURLRef url = CFBundleCopyResourceURL(g->mainBundle, name, CFSTR("tif"), CFSTR("Graphics"));
    if (!url) {
        NSLog(@"LoadPicture: Failed to find resource %@", name);
        CleanUp(true);
        return;
    }
    
    // Load image using NSImage
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:(__bridge NSURL *)url];
    CFRelease(url);
    
    if (!image) {
        NSLog(@"LoadPicture: Failed to load image %@", name);
        CleanUp(true);
        return;
    }
    
    NSSize size = [image size];
    int width = (int)size.width;
    int height = (int)size.height;
    
    // Create 32-bit GWorld (Pomme's native format)
    Rect bounds = {0, 0, (short)height, (short)width};
    OSErr err = NewGWorld(theGWorld, 32, &bounds, NULL, NULL, 0);
    if (err) {
        NSLog(@"LoadPicture: Failed to create GWorld for %@", name);
        CleanUp(true);
        return;
    }
    
    // Get the pixel buffer from Pomme
    PixMapHandle pixMap = GetGWorldPixMap(*theGWorld);
    LockPixels(pixMap);
    
    UInt32 *destPixels = (UInt32 *)GetPixBaseAddr(pixMap);
    
    // Create NSBitmapImageRep to render the image
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc]
                                initWithBitmapDataPlanes:NULL
                                pixelsWide:width
                                pixelsHigh:height
                                bitsPerSample:8
                                samplesPerPixel:4
                                hasAlpha:YES
                                isPlanar:NO
                                colorSpaceName:NSDeviceRGBColorSpace
                                bytesPerRow:width * 4
                                bitsPerPixel:32];
    
    [NSGraphicsContext saveGraphicsState];
    NSGraphicsContext *ctx = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmap];
    [NSGraphicsContext setCurrentContext:ctx];
    
    // Handle horizontal flipping
    if (flipped) {
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform translateXBy:width yBy:0];
        [transform scaleXBy:-1 yBy:1];
        [transform concat];
    }
    
    // Draw image into bitmap
    [image drawInRect:NSMakeRect(0, 0, width, height)
             fromRect:NSZeroRect
            operation:NSCompositingOperationCopy
             fraction:1.0];
    
    [NSGraphicsContext restoreGraphicsState];
    
    // Copy RGBA bitmap data to Pomme's ARGB format
    unsigned char *srcData = [bitmap bitmapData];
    
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            int srcOffset = (y * width + x) * 4;
            int destOffset = y * width + x;
            
            unsigned char r = srcData[srcOffset + 0];
            unsigned char g = srcData[srcOffset + 1];
            unsigned char b = srcData[srcOffset + 2];
            unsigned char a = srcData[srcOffset + 3];
            
            // Pomme expects ARGB format
            // On little-endian systems, store as BGRA for correct byte order
            destPixels[destOffset] = (a << 24) | (r << 16) | (g << 8) | b;
        }
    }
    
    UnlockPixels(pixMap);
}

void LoadMask(CFStringRef name, GWorldPtr *theGWorld, bool flipped)
{
    // Get URL for resource
    CFURLRef url = CFBundleCopyResourceURL(g->mainBundle, name, CFSTR("tif"), CFSTR("Graphics"));
    if (!url) {
        NSLog(@"LoadMask: Failed to find resource %@", name);
        CleanUp(true);
        return;
    }
    
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:(__bridge NSURL *)url];
    CFRelease(url);
    
    if (!image) {
        NSLog(@"LoadMask: Failed to load image %@", name);
        CleanUp(true);
        return;
    }
    
    NSSize size = [image size];
    int width = (int)size.width;
    int height = (int)size.height;
    
    // For masks, we still create a 1-bit GWorld for compatibility with CopyMask
    Rect bounds = {0, 0, (short)height, (short)width};
    OSErr err = NewGWorld(theGWorld, 1, &bounds, NULL, NULL, 0);
    if (err) {
        NSLog(@"LoadMask: Failed to create GWorld for %@", name);
        CleanUp(true);
        return;
    }
    
    // Get the pixel buffer
    PixMapHandle pixMap = GetGWorldPixMap(*theGWorld);
    LockPixels(pixMap);
    
    Ptr destAddr = GetPixBaseAddr(pixMap);
    PixMap *pm = *pixMap;
    int destRowBytes = (pm->rowBytes & 0x3FFF);
    
    // Create bitmap to render image
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc]
                                initWithBitmapDataPlanes:NULL
                                pixelsWide:width
                                pixelsHigh:height
                                bitsPerSample:8
                                samplesPerPixel:4
                                hasAlpha:YES
                                isPlanar:NO
                                colorSpaceName:NSDeviceRGBColorSpace
                                bytesPerRow:width * 4
                                bitsPerPixel:32];
    
    [NSGraphicsContext saveGraphicsState];
    NSGraphicsContext *ctx = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmap];
    [NSGraphicsContext setCurrentContext:ctx];
    
    if (flipped) {
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform translateXBy:width yBy:0];
        [transform scaleXBy:-1 yBy:1];
        [transform concat];
    }
    
    [image drawInRect:NSMakeRect(0, 0, width, height)
             fromRect:NSZeroRect
            operation:NSCompositingOperationCopy
             fraction:1.0];
    
    [NSGraphicsContext restoreGraphicsState];
    
    // Convert to 1-bit: threshold based on brightness
    unsigned char *srcData = [bitmap bitmapData];
    
    // Clear destination first
    memset(destAddr, 0, destRowBytes * height);
    
    for (int y = 0; y < height; y++) {
        unsigned char *destRow = (unsigned char *)(destAddr + y * destRowBytes);
        
        for (int x = 0; x < width; x++) {
            int srcOffset = (y * width + x) * 4;
            
            // Get grayscale value (use red channel or average)
            unsigned char gray = srcData[srcOffset];  // Red channel
            
            // Set bit if pixel is "white" (above threshold)
            // Masks typically have white = transparent, black = opaque
            if (gray > 128) {
                int byteIndex = x / 8;
                int bitIndex = 7 - (x % 8);  // MSB first
                destRow[byteIndex] |= (1 << bitIndex);
            }
        }
    }
    
    UnlockPixels(pixMap);
}

void LoadInterface(void)
{
    IBNibRef 		nibRef;
    OSStatus		err;

    // Create a Nib reference passing the name of the nib file (without the .nib extension)
    // CreateNibReference only searches into the application bundle.
    err = CreateNibReference(CFSTR("main"), &nibRef);
    if (err) CleanUp(true);
    
    err = SetMenuBarFromNib(nibRef, CFSTR("MenuBar"));
    if (err) CleanUp(true);
    
    EnableMenuCommand(NULL, kHICommandPreferences);
    
    
    err = CreateWindowFromNib(nibRef, CFSTR("MainWindow"), &(g->theWindow));
    if (err) CleanUp(true);
    
    WindowSizeHack(true);
    
    err = CreateWindowFromNib(nibRef, CFSTR("AboutWindow"), &(g->aboutWindow));
    if (err) CleanUp(true);
    err = CreateWindowFromNib(nibRef, CFSTR("InstructionsWindow"), &(g->instructionsWindow));
    if (err) CleanUp(true);
    err = CreateWindowFromNib(nibRef, CFSTR("PrefsWindow"), &(g->prefsWindow));
    if (err) CleanUp(true);
    err = CreateWindowFromNib(nibRef, CFSTR("HighScoreWindow"), &(g->highScoreWindow));
    if (err) CleanUp(true);
    err = CreateWindowFromNib(nibRef, CFSTR("NewGameOverWindow"), &(g->gameOverWindow));
    if (err) CleanUp(true);
    err = CreateWindowFromNib(nibRef, CFSTR("HighScoresWindow"), &(g->highScoresWindow));
    if (err) CleanUp(true);
    err = CreateWindowFromNib(nibRef, CFSTR("LevelSelectWindow"), &(g->levelSelectWindow));
    if (err) CleanUp(true);
    err = CreateWindowFromNib(nibRef, CFSTR("AutoPauseWindow"), &(g->autoPauseWindow));
    if (err) CleanUp(true);
    err = CreateWindowFromNib(nibRef, CFSTR("AskSwitchWindow"), &(g->askSwitchWindow));
    if (err) CleanUp(true);

    // We don't need the nib reference anymore.
    DisposeNibReference(nibRef);
    
    // The window was created hidden so show it.
    ShowWindow(g->theWindow);
    SetPortWindowPort(g->theWindow);
    
//    GetGWorld(&thePort, &theDevice);
    
    
    g->mouseOverOption = 0;
}

void LoadPreferences(void)
{
    Boolean		valid;
    
    g->startNewGameImmediately = 0;
    
    g->pref.blood = CFPreferencesGetAppBooleanValue(CFSTR("blood"), PRF_CUR, &valid);
    
    if (!valid)
    {
        g->firstRunDoAbout = true;
        
        DefaultPrefs();
    }
    else
    {
        g->firstRunDoAbout = false;
        
        g->pref.fire = CFPreferencesGetAppBooleanValue(CFSTR("fire"), PRF_CUR, &valid);
        g->pref.sound = CFPreferencesGetAppBooleanValue(CFSTR("sound"), PRF_CUR, &valid);
        g->pref.turbo = CFPreferencesGetAppBooleanValue(CFSTR("turbo"), PRF_CUR, &valid);
        g->pref.shotFX = CFPreferencesGetAppBooleanValue(CFSTR("shotFX"), PRF_CUR, &valid);
        g->pref.border = CFPreferencesGetAppBooleanValue(CFSTR("shotFX"), PRF_CUR, &valid);
        if (!valid)
            g->pref.border = true;	// old versions did not have this pref
    }
    
    LoadHighScores();
}

void DefaultPrefs(void)
{
    g->pref.blood = true;
    g->pref.fire  = true;
    g->pref.sound = true;
    g->pref.turbo = false;
    g->pref.shotFX = true;
    g->pref.border = true;
    
    // no default for septh switch
    
    SavePreferences();
}

void SavePreferences(void) // depth switching is handled separately, for what seemed like good reasons at the time.
{
    
    if(g->pref.blood)
        CFPreferencesSetAppValue(CFSTR("blood"), kCFBooleanTrue, PRF_CUR);
    else
        CFPreferencesSetAppValue(CFSTR("blood"), kCFBooleanFalse, PRF_CUR);
    
    if(g->pref.fire)
        CFPreferencesSetAppValue(CFSTR("fire"), kCFBooleanTrue, PRF_CUR);
    else
        CFPreferencesSetAppValue(CFSTR("fire"), kCFBooleanFalse, PRF_CUR);
    
    if(g->pref.sound)
        CFPreferencesSetAppValue(CFSTR("sound"), kCFBooleanTrue, PRF_CUR);
    else
        CFPreferencesSetAppValue(CFSTR("sound"), kCFBooleanFalse, PRF_CUR);
    
    if(g->pref.turbo)
        CFPreferencesSetAppValue(CFSTR("turbo"), kCFBooleanTrue, PRF_CUR);
    else
        CFPreferencesSetAppValue(CFSTR("turbo"), kCFBooleanFalse, PRF_CUR);
    
    if(g->pref.shotFX)
        CFPreferencesSetAppValue(CFSTR("shotFX"), kCFBooleanTrue, PRF_CUR);
    else
        CFPreferencesSetAppValue(CFSTR("shotFX"), kCFBooleanFalse, PRF_CUR);
    
    if(g->pref.border)
        CFPreferencesSetAppValue(CFSTR("border"), kCFBooleanTrue, PRF_CUR);
    else
        CFPreferencesSetAppValue(CFSTR("border"), kCFBooleanFalse, PRF_CUR);
    
    CFPreferencesAppSynchronize(PRF_CUR);
}




void LoadGlobalGraphics(void)
{
    PixMapHandle	map;
    OSErr		err;
    
    LoadPicture(CFSTR("interfaceBack"), &g->interfaceBackGWorld, false);
    LoadPicture(CFSTR("interfaceButtons"), &g->interfaceButtons, false);
    LoadPicture(CFSTR("interfaceRollover"), &g->interfaceRollover, false);
    LoadPicture(CFSTR("interfaceClick"), &g->interfaceClick, false);
    LoadPicture(CFSTR("about"), &g->aboutGWorld, false);
    LoadPicture(CFSTR("instructions"), &g->instructionsGWorld, false);
    LoadPicture(CFSTR("vote"), &g->voteGWorld, false);
    
    LoadPicture(CFSTR("guns"), &g->gunsPictGWorld, false);
    LoadMask(CFSTR("gunsMask"), &g->gunsPictMask, false);
    LoadPicture(CFSTR("rose"), &g->lifePictGWorld, false);
    LoadMask(CFSTR("roseMask"), &g->lifePictMask, false);
    LoadPicture(CFSTR("arrow"), &g->sheepArrowGWorld, false);
    LoadMask(CFSTR("arrowMask"), &g->sheepArrowMask, false);
    
    LoadPicture(CFSTR("swissCheese"), &g->SCBonusGWorld, false);
    LoadPicture(CFSTR("shishKebab"), &g->SKBonusGWorld, false);
    LoadPicture(CFSTR("lambChop"), &g->LCBonusGWorld, false);
    LoadPicture(CFSTR("highFlier"), &g->HFBonusGWorld, false);
    LoadPicture(CFSTR("jammyDodger"), &g->JDBonusGWorld, false);
    LoadPicture(CFSTR("chainUp"), &g->CUBonusGWorld, false);
    LoadMask(CFSTR("bonusMask"), &g->bonusMask, false);
    LoadPicture(CFSTR("chainBonus"), &g->chainBonusGWorld, false);
    LoadMask(CFSTR("chainBonusMask"), &g->chainBonusMask, false);
    
    LoadPicture(CFSTR("mega"), &g->extraBonusGWorld[0], false);
    LoadPicture(CFSTR("ultra"), &g->extraBonusGWorld[1], false);
    LoadPicture(CFSTR("super"), &g->extraBonusGWorld[2], false);
    LoadPicture(CFSTR("extra"), &g->extraBonusGWorld[3], false);
    LoadPicture(CFSTR("double"), &g->extraBonusGWorld[4], false);
    
    LoadPicture(CFSTR("levelStart"), &g->msgLevelStartGWorld, false);
    LoadMask(CFSTR("levelStartMask"), &g->msgLevelStartMask, false);
    LoadPicture(CFSTR("levelEnd"), &g->msgLevelEndGWorld, false);
    LoadMask(CFSTR("levelEndMask"), &g->msgLevelEndMask, false);
    LoadPicture(CFSTR("gameOver"), &g->msgGameOverGWorld, false);
    LoadMask(CFSTR("gameOverMask"), &g->msgGameOverMask, false);
    LoadPicture(CFSTR("completed"), &g->msgCompletedGWorld, false);
    LoadMask(CFSTR("completedMask"), &g->msgCompletedMask, false);
    LoadPicture(CFSTR("paused"), &g->msgPausedGWorld, false);
    LoadMask(CFSTR("pausedMask"), &g->msgPausedMask, false);
    
    LoadPicture(CFSTR("runRightA"), &g->theSheepType.liveSpriteRunRightA, false);
    LoadMask(CFSTR("runRightMaskA"), &g->theSheepType.liveSpriteRunRightMaskA, false);
    LoadPicture(CFSTR("runRightB"), &g->theSheepType.liveSpriteRunRightB, false);
    LoadMask(CFSTR("runRightMaskB"), &g->theSheepType.liveSpriteRunRightMaskB, false);
    
    LoadPicture(CFSTR("runRightA"), &g->theSheepType.liveSpriteRunLeftA, true);
    LoadMask(CFSTR("runRightMaskA"), &g->theSheepType.liveSpriteRunLeftMaskA, true);
    LoadPicture(CFSTR("runRightB"), &g->theSheepType.liveSpriteRunLeftB, true);
    LoadMask(CFSTR("runRightMaskB"), &g->theSheepType.liveSpriteRunLeftMaskB, true);
    
    LoadPicture(CFSTR("deadRight"), &g->theSheepType.originalDeadSpriteRight, false);
    LoadMask(CFSTR("deadRightMaskThin"), &g->theSheepType.originalDeadSpriteRightMaskWithoutOutline, false);
    LoadMask(CFSTR("deadRightMaskFat"), &g->theSheepType.originalDeadSpriteRightMaskWithOutline, false);
    
    LoadPicture(CFSTR("deadRight"), &g->theSheepType.originalDeadSpriteLeft, true);
    LoadMask(CFSTR("deadRightMaskThin"), &g->theSheepType.originalDeadSpriteLeftMaskWithoutOutline, true);
    LoadMask(CFSTR("deadRightMaskFat"), &g->theSheepType.originalDeadSpriteLeftMaskWithOutline, true);
    
    LoadPicture(CFSTR("numbers"), &g->theScoreStuff.scoreGraphics, false);
    LoadPicture(CFSTR("numbersGold"), &g->theScoreStuff.multiplierGraphics, false);
    LoadMask(CFSTR("numbersMask"), &g->theScoreStuff.scoreMask, false);
    
    SetRect(&g->theScoreStuff.numberRect, 0, 0, 12, 17);
    
    map = GetGWorldPixMap(g->theSheepType.originalDeadSpriteRight);
    GetPixBounds(map, &g->theSheepType.deadBounds);
    
    err = NewGWorld(&g->theSheepType.splitMask,
                    1,
                    &g->theSheepType.deadBounds,
                    NULL,
                    NULL,
                    0);
    if (err)
        CleanUp(true);
        
    ClearGWorld(g->theSheepType.splitMask, whiteColor);
    
    err = NewGWorld(&g->swapGWorld,
                    16,
                    &g->swapBounds,
                    NULL, NULL, 0);
    if (err)
        CleanUp(true);
    
}

void LoadEveryThingElse(void)
{
    LoadLevels();
    
    LoadWeapons();
    
    LoadSounds();
    
    g->alreadyAutoPaused = false;
    
    g->crosshair = GetCursor(128);
    SetCursor(*g->crosshair);
}



void LoadLevels(void)
{
   g->baseSceneryType = NULL;
    g->baseBackground = NULL;
    
    LoadLevel(CFSTR("pasture"));
    LoadLevel(CFSTR("dump"));
    LoadLevel(CFSTR("road"));
    LoadLevel(CFSTR("beach"));
    LoadLevel(CFSTR("shrooms"));
    LoadLevel(CFSTR("alienplace"));
    LoadLevel(CFSTR("cloisters"));
    LoadLevel(CFSTR("aliencloister"));
    
}

void LoadLevel(CFStringRef theLevelName)
{
    CFDictionaryRef	theDict;
    CFDataRef		theData;
    CFURLRef		theURL;
    CFStringRef		errorString, key, stringValue;
    CFNumberRef		numberValue;
    CFArrayRef		arrayValue;
    Level		*newLevel, *theLevel;
    
    theURL = CFBundleCopyResourceURL(g->mainBundle, theLevelName, CFSTR("plist"), NULL);
    
    if (!CFURLCreateDataAndPropertiesFromResource(  kCFAllocatorDefault,
                                                    theURL,
                                                    &theData,
                                                    NULL,NULL,NULL)) CleanUp(true);
    
    CFRelease(theURL);
    
    theDict = CFPropertyListCreateFromXMLData(	NULL,
                                                theData,
                                                0,
                                                &errorString);
    
    CFRelease(theData);
    
    if (errorString || !theDict)
    {
        CFRelease(errorString);
        CleanUp(true);
    }
    
    // ok, we've got the dictionary. time to fill in the level data
    
    newLevel = (Level *)NewPtr(sizeof(Level));
    
    key = CFSTR("levelNumber");
    numberValue = CFDictionaryGetValue(theDict, key);
    CFNumberGetValue(numberValue, kCFNumberShortType, &newLevel->levelNumber);
    
    key = CFSTR("numSheep");
    numberValue = CFDictionaryGetValue(theDict, key);
    CFNumberGetValue(numberValue, kCFNumberLongType, &newLevel->numSheep);
    
    key = CFSTR("maxDelay");
    numberValue = CFDictionaryGetValue(theDict, key);
    CFNumberGetValue(numberValue, kCFNumberFloatType, &newLevel->maxDelay);
    
    key = CFSTR("minDelay");
    numberValue = CFDictionaryGetValue(theDict, key);
    CFNumberGetValue(numberValue, kCFNumberFloatType, &newLevel->minDelay);
    
    key = CFSTR("maxSpeed");
    numberValue = CFDictionaryGetValue(theDict, key);
    CFNumberGetValue(numberValue, kCFNumberFloatType, &newLevel->maxSpeed);
    
    key = CFSTR("minSpeed");
    numberValue = CFDictionaryGetValue(theDict, key);
    CFNumberGetValue(numberValue, kCFNumberFloatType, &newLevel->minSpeed);
    
    key = CFSTR("startPoints");
    arrayValue = CFDictionaryGetValue(theDict, key);
    CFRetain(arrayValue);
    FillInStartPoints(newLevel, arrayValue);
    CFRelease(arrayValue);
    
    key = CFSTR("background");
    stringValue = CFDictionaryGetValue(theDict, key);
    CFRetain(stringValue);
    newLevel->theBackground = GetBackgroundWithName(stringValue);
    CFRelease(stringValue);
    
    key = CFSTR("scenery");
    
    newLevel->baseSceneryToken = NULL;
    arrayValue = CFDictionaryGetValue(theDict, key);
    if (arrayValue)
    {
        CFRetain(arrayValue);
        LoadLevelScenery(newLevel, arrayValue);
        CFRelease(arrayValue);
    }
    
    newLevel->next = NULL;
    
    CFRelease(theDict);
    
    if (!g->baseLevel)
        g->baseLevel = newLevel;
    else
    {
        theLevel = g->baseLevel;
        
        while (theLevel->next)
            theLevel = theLevel->next;
        
        theLevel->next = newLevel;
    }
}

Background *GetBackgroundWithName(CFStringRef theName)
{
    Background		*theBackground, *newBackground;
    
    theBackground = g->baseBackground;
    
    while (theBackground)
    {
        if (CFStringCompare(theName, theBackground->name, 0) == kCFCompareEqualTo)
            return theBackground;
        
        theBackground = theBackground->next;
    }
    
    // if we haven't returned, the background isn't yet in memory.
    
    newBackground = (Background *)NewPtr(sizeof(Background));
    if (!newBackground)
        CleanUp(true);
    
    CFRetain(theName);
    newBackground->name = theName;
    LoadPicture(theName, &newBackground->theGWorld, false);
    newBackground->next = NULL;
    
    theBackground = g->baseBackground;
    
    if (!theBackground)
    {
        g->baseBackground = newBackground;
        return newBackground;
    }
    
    while (theBackground->next)
        theBackground = theBackground->next;
    
    theBackground->next = newBackground;
    
    return newBackground;
}

void DumpBackgrounds(void)
{
    Background	*thisBG, *thatBG;
    
    thisBG = g->baseBackground;
    
    while (thisBG)
    {
        thatBG = thisBG->next;
        
        CFRelease(thisBG->name);
        if (thisBG->theGWorld)
            DisposeGWorld(thisBG->theGWorld);
        
        DisposePtr((Ptr)thisBG);
        
        thisBG = thatBG;
    }
}

void FillInStartPoints(Level *theLevel, CFArrayRef theArray)
{
    CFIndex		numElements;
    CFIndex		count = 0;
    CFDictionaryRef	theDict;
    CFStringRef		key;
    CFNumberRef		value;
    StartPoint		*newSP;
    StartPoint		*lastSP = NULL;
    
    numElements = CFArrayGetCount(theArray);
    
    theLevel->baseStartPoint = NULL;
    theLevel->numStartPoints = numElements;
    
    while (count < numElements)
    {
        newSP = (StartPoint *)NewPtr(sizeof(StartPoint));
        
        theDict = CFArrayGetValueAtIndex(theArray, count);
        
        key = CFSTR("layer");
        value = CFDictionaryGetValue(theDict, key);
        CFNumberGetValue(value, kCFNumberShortType, &newSP->layer);
        
        key = CFSTR("yPos");
        value = CFDictionaryGetValue(theDict, key);
        CFNumberGetValue(value, kCFNumberShortType, &newSP->posY);
        
        newSP->next = NULL;
        
        if (!lastSP)
            theLevel->baseStartPoint = newSP;
        else
            lastSP->next = newSP;
        
        lastSP = newSP;
        
        count++;
    }
    
}

void LoadLevelScenery(Level *theLevel, CFArrayRef theArray)
{
    CFIndex		numElements;
    CFIndex		count = 0;
    CFDictionaryRef	theDict;
    CFStringRef		key;
    CFStringRef		stringValue;
    CFNumberRef		numberValue;
    
    short		layer;
    pointFloat		position;
    
    numElements = CFArrayGetCount(theArray);
    
    while (count < numElements)
    {
        theDict = CFArrayGetValueAtIndex(theArray, count);
        
        key = CFSTR("layer");
        numberValue = CFDictionaryGetValue(theDict, key);
        CFNumberGetValue(numberValue, kCFNumberShortType, &layer);
        
        key = CFSTR("posX");
        numberValue = CFDictionaryGetValue(theDict, key);
        CFNumberGetValue(numberValue, kCFNumberFloatType, &position.x);
        
        key = CFSTR("posY");
        numberValue = CFDictionaryGetValue(theDict, key);
        CFNumberGetValue(numberValue, kCFNumberFloatType, &position.y);
        
        key = CFSTR("name");
        stringValue = CFDictionaryGetValue(theDict, key);
        CFRetain(stringValue);
        
        AddScenery(theLevel, stringValue, position, layer);
        
        count++;
    }
    
}

void AddScenery(Level *theLevel, CFStringRef sceneryName, pointFloat position, short layer)
{
    SceneryToken	*newSToken;
    SceneryToken	*lastSToken;
    
    newSToken = (SceneryToken *)NewPtr(sizeof(SceneryToken));
    
    newSToken->position = position;
    newSToken->layer = layer;
    
    newSToken->type = FindSceneryType(sceneryName);
    
    if (!newSToken->type)
        newSToken->type = LoadSceneryType(sceneryName);
    
    if (!newSToken->type)
        CleanUp(true);
    
    lastSToken = theLevel->baseSceneryToken;
    
    if (!lastSToken)
        theLevel->baseSceneryToken = newSToken;
    else
    {
        while (lastSToken->next)
            lastSToken = lastSToken->next;
        
        lastSToken->next = newSToken;
    }
    
    newSToken->next = NULL;
}

SceneryType *FindSceneryType(CFStringRef sceneryName)
{
    SceneryType		*thisSType;
    CFComparisonResult	result;
    
    thisSType = g->baseSceneryType;
    
    while (thisSType)
    {
        result = CFStringCompare(sceneryName, thisSType->sceneryName, 0);
        
        if (result == kCFCompareEqualTo)
        {
            return thisSType;
        }
        thisSType = thisSType->next;
    }
    return NULL;
}

SceneryType *LoadSceneryType(CFStringRef sceneryName)
{
    SceneryType		*lastSceneryType;
    SceneryType		*newSceneryType;
    CFMutableStringRef	maskName;
    PixMapHandle	pixMap;
    
    newSceneryType = (SceneryType *)NewPtr(sizeof(SceneryType));
    
    if (!newSceneryType)
        return NULL;
    
    newSceneryType->sceneryName = sceneryName;
    
    LoadPicture(sceneryName, &newSceneryType->spriteGWorld, false);
    
    maskName = CFStringCreateMutableCopy(NULL, 0, sceneryName);
    CFStringAppend(maskName, CFSTR("Mask"));
    
    LoadMask(maskName, &newSceneryType->maskGWorld, false);
    
    pixMap = GetGWorldPixMap(newSceneryType->maskGWorld);
    GetPixBounds(pixMap, &newSceneryType->bounds);
    
    lastSceneryType = g->baseSceneryType;
    
    if (!lastSceneryType)
        g->baseSceneryType = newSceneryType;
    else
    {
        while (lastSceneryType->next)
            lastSceneryType = lastSceneryType->next;
        
        lastSceneryType->next = newSceneryType;
    }
    newSceneryType->next = NULL;
    
    CFRelease(maskName);
    
    return newSceneryType;
}


void RemoveAllLevels(void)
{
    Level		*thisLevel, *thatLevel;
    StartPoint		*thisSP, *thatSP;
    SceneryToken	*thisST, *thatST;
    
    if (g->baseLevel)
    {
        thisLevel = g->baseLevel;
        
        while (thisLevel)
        {
            if (thisLevel->baseStartPoint)
            {
                thisSP = thisLevel->baseStartPoint;
                
                while (thisSP)
                {
                    thatSP = thisSP->next;
                    DisposePtr((Ptr)thisSP);
                    thisSP = thatSP;
                }
            }
            
            if (thisLevel->baseSceneryToken)
            {
                thisST = thisLevel->baseSceneryToken;
                
                while (thisST)
                {
                    thatST = thisST->next;
                    DisposePtr((Ptr)thisST);
                    thisST = thatST;
                }
            }
            
            thatLevel = thisLevel->next;
            DisposePtr((Ptr)thisLevel);
            thisLevel = thatLevel;
        }
    }
    
    g->baseLevel = NULL;
}

void RemoveAllScenery(void)
{
    SceneryType		*thisST, *thatST;
    
    thisST = g->baseSceneryType;
    
    while(thisST)
    {
        thatST = thisST->next;
        
        DisposeGWorld(thisST->spriteGWorld);
        DisposeGWorld(thisST->maskGWorld);
        CFRelease(thisST->sceneryName);
        
        DisposePtr((Ptr)thisST);
        
        thisST = thatST;
    }
    
    g->baseSceneryType = NULL;
}

void LoadWeapons(void)
{
    LoadWeapon(1, 0.1, 2, 1, 0, 15, CFSTR("uzi"));
    LoadWeapon(2, 0.2, 5, 2, 0, 25, CFSTR("magnum"));
    LoadWeapon(3, 0.35, 8, 4, 0, 31, CFSTR("shotgun"));
    LoadWeapon(4, 0.5, 10, 8, 0, 45, CFSTR("flamer"));
    
    g->theWeapon = g->baseWeapon;
    
}


void LoadWeapon (short ID, float reload, float recoil, float scoreMultiplier, short topLeft, short botRight, CFStringRef name)
{
    Weapon			*newWeapon, *thisWeapon;
    OSErr			err;
    CFMutableStringRef		maskWith, maskWithout, maskDraw;
    
    newWeapon = (Weapon *)NewPtr(sizeof(Weapon));
    
    newWeapon->weaponID = ID;
    newWeapon->lastFired = 0;
    newWeapon->reloadTime = reload;
    newWeapon->recoil = recoil;
    newWeapon->scoreMultiplier = scoreMultiplier;
    newWeapon->holeRect.left = topLeft;
    newWeapon->holeRect.right = botRight;
    newWeapon->holeRect.top = topLeft;
    newWeapon->holeRect.bottom = botRight;
    
    err = NewGWorld(&newWeapon->holeTempMask,
                    1,
                    &newWeapon->holeRect,
                    NULL,
                    NULL,
                    0);
    if (err) CleanUp(true);
    
    maskWith = CFStringCreateMutableCopy(NULL, 0, name);
    maskWithout = CFStringCreateMutableCopy(NULL, 0, name);
    maskDraw = CFStringCreateMutableCopy(NULL, 0, name);
    
    CFStringAppend(maskWith, CFSTR("HoleFat"));
    CFStringAppend(maskWithout, CFSTR("HoleThin"));
    CFStringAppend(maskDraw, CFSTR("DrawMask"));
    
    LoadPicture(name, &newWeapon->holeSprite, false);
    LoadMask(maskWithout, &newWeapon->holeSpriteMaskWithoutOutline, false);
    LoadMask(maskWith, &newWeapon->holeSpriteMaskWithOutline, false);
    LoadMask(maskDraw, &newWeapon->holeSpriteDrawMask, false);
    
    newWeapon->next = NULL;
    
    if (g->baseWeapon)
    {
            thisWeapon = g->baseWeapon;
            
            while (thisWeapon->next)
            {
                    thisWeapon = thisWeapon->next;
            }
            
            thisWeapon->next = newWeapon;
    }else{
            g->baseWeapon = newWeapon;
    }
    
    CFRelease(maskWith);
    CFRelease(maskWithout);
    CFRelease(maskDraw);
}


//
//
//void LoadPicture(CFStringRef name, GWorldPtr *theGWorld, bool flipped)
//{
//    CFURLRef	backURL = NULL;
//    FSRef	backFSR;
//    FSSpec	backFSS;
//    OSErr	err;
//    
//    backURL = 	CFBundleCopyResourceURL( g->mainBundle,
//                name, 
//                CFSTR("tif"), 
//                CFSTR("Graphics") );
//    
//    if ( !CFURLGetFSRef(backURL, &backFSR))
//        CleanUp(true);
//    
//    err = FSGetCatalogInfo( &backFSR,
//                            kFSCatInfoNone,
//                            NULL,
//                            NULL,
//                            &backFSS,
//                            NULL);
//    if (err) CleanUp(true);
//    
//    DrawPictureToNewGWorld(&backFSS, theGWorld, flipped);
//    
//    CFRelease(backURL);
//}
//
//void LoadMask(CFStringRef name, GWorldPtr *theGWorld, bool flipped)
//{
//    CFURLRef	backURL = NULL;
//    FSRef	backFSR;
//    FSSpec	backFSS;
//    OSErr	err;
//    
//    backURL = 	CFBundleCopyResourceURL( g->mainBundle,
//                name, 
//                CFSTR("tif"), 
//                CFSTR("Graphics") );
//    
//    if ( !CFURLGetFSRef(backURL, &backFSR))
//        CleanUp(true);
//    
//    err = FSGetCatalogInfo( &backFSR,
//                            kFSCatInfoNone,
//                            NULL,
//                            NULL,
//                            &backFSS,
//                            NULL);
//    if (err) CleanUp(true);
//    
//    DrawMaskToNewGWorld(&backFSS, theGWorld, flipped);
//    
//    CFRelease(backURL);
//}
//


void DrawPictureToNewGWorld(FSSpec *fss, GWorldPtr *theGWorld, bool flipped)
{
    GDHandle			storeDevice;
    CGrafPtr			storePort;
    GraphicsImportComponent 	gi;
    Rect			boundsRect, flipRect;
    OSErr			err;

    GetGraphicsImporterForFile(fss, &gi);
    
    GraphicsImportGetNaturalBounds(gi, &boundsRect);
    
    err = NewGWorld(theGWorld,
                    16,
                    &boundsRect,
                    NULL,
                    NULL,
                    0);
    if (err)
    {
        CloseComponent(gi);
        CleanUp(true);
    }
    
    GetGWorld(&storePort, &storeDevice);
    SetGWorld(*theGWorld, NULL);
    
    GraphicsImportSetGWorld(gi, *theGWorld, NULL);
    
    if (flipped)
    {
        flipRect = boundsRect;
        flipRect.left = boundsRect.right;
        flipRect.right = boundsRect.left;
        GraphicsImportSetBoundsRect(gi, &flipRect);
    }
    GraphicsImportDraw(gi);
    CloseComponent(gi);
    
    SetGWorld(storePort, storeDevice);
}

void DrawMaskToNewGWorld(FSSpec *fss, GWorldPtr *theGWorld, bool flipped)
{
    GDHandle			storeDevice;
    CGrafPtr			storePort;
    GraphicsImportComponent 	gi;
    Rect			boundsRect, flipRect;
    OSErr			err;

    GetGraphicsImporterForFile(fss, &gi);
    
    GraphicsImportGetNaturalBounds(gi, &boundsRect);
//    GraphicsImportSetBoundsRect(gi, boundsRect);

    err = NewGWorld(theGWorld,
                    1,
                    &boundsRect,
                    NULL,
                    NULL,
                    0);
    
    if (err)
    {
        CloseComponent(gi);
        CleanUp(true);
    }
    
    GetGWorld(&storePort, &storeDevice);
    SetGWorld(*theGWorld, NULL);
    
    GraphicsImportSetGWorld(gi, *theGWorld, NULL);
    
    if (flipped)
    {
        flipRect = boundsRect;
        flipRect.left = boundsRect.right;
        flipRect.right = boundsRect.left;
        GraphicsImportSetBoundsRect(gi, &flipRect);
    }
    
    GraphicsImportDraw(gi);
    CloseComponent(gi);
    
    SetGWorld(storePort, storeDevice);
}










