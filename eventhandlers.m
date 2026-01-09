/*
 *  eventhandlers.m
 *  nibMAFF
 *
 *  Originally created by wibble on Tue Sep 10 2002.
 *  Copyright (c) 2002 William Reade. All rights reserved.
 *
 *  Updated 2026 for modern macOS using Cocoa instead of Carbon Events.
 *  Event handling is now done through:
 *  - NSTimer for game loop (in AppDelegate)
 *  - NSNotificationCenter for window events
 *  - GameView for mouse/keyboard input
 */

#include "Pomme.h"
#import <Cocoa/Cocoa.h>
#include "mafftypes.h"
#include "graphics.h"
#include "game.h"
#include "eventhandlers.h"

#define PRF_CUR kCFPreferencesCurrentApplication

extern GlobalStuff *g;

extern void CleanUp(bool instaQuit);
extern void SavePreferences(void);
extern void LoadSounds(void);
extern void FinishSounds(void);
extern void UpdateHighScores(void);
extern void UnloadHighScores(void);
extern void DefaultHighScores(void);
extern void ProcessAndDrawFire(GWorldPtr theGWorld);
extern void PlaySound(short channel, Handle sound);
extern void ChangeDepth(void);
extern void ChangeDepthBack(void);

// ============================================================================
// Timer/Event Loop Setup
// ============================================================================

// Note: Timer installation is now handled by AppDelegate using NSTimer
// These functions are kept as stubs for code compatibility

void InstallEventHandlers(void)
{
    // Event handlers are now set up in AppDelegate and GameView
    // This function is called from legacy initialization code but is now a no-op
    // The actual event handling is done via:
    // - NSApplicationDelegate methods in AppDelegate
    // - NSWindowDelegate methods in AppDelegate  
    // - NSView event methods in GameView
    
    // Start the timer (now handled by AppDelegate)
    // StartTimer();
}

void StartTimer(void)
{
    // Timer is now managed by AppDelegate using NSTimer
    // See AppDelegate's startGameTimer method
}

void ReStartTimer(void)
{
    // Called when g->pref.turbo changes
    // Notify AppDelegate to restart timer with new interval
    
    // Get the app delegate and call restartTimer
    id appDelegate = [[NSApplication sharedApplication] delegate];
    if ([appDelegate respondsToSelector:@selector(restartTimer)]) {
        [appDelegate performSelector:@selector(restartTimer)];
    }
}

// ============================================================================
// Window Event Handlers (Now just helper functions)
// ============================================================================

// These were Carbon event handlers, now they're just regular functions
// called from AppDelegate or stubs

OSStatus DoCloseMainWindow(EventHandlerCallRef nextHandler, EventRef theEvent, void *data)
{
    [NSApp terminate:nil];
    return noErr;
}

OSStatus AutoPauseIfInGame(EventHandlerCallRef nextHandler, EventRef theEvent, void *data)
{
    AutoPause();
    return noErr;
}

OSStatus ActivateMyWindow(EventHandlerCallRef nextHandler, EventRef theEvent, void *data)
{
    g->windowActive = 1;
    
    if (g->alreadyAutoPaused)
        g->alreadyAutoPaused = FALSE;
    else
        AutoPause();
    
    return noErr;
}

OSStatus DeactivateMyWindow(EventHandlerCallRef nextHandler, EventRef theEvent, void *data)
{
    g->windowActive = 0;
    return noErr;
}

OSStatus DrawMainWindow(EventHandlerCallRef nextHandler, EventRef theEvent, void *data)
{
    // Drawing is now handled by GameView's drawRect:
    // Just trigger a redraw
    DrawBorder();
    DrawGWorldToWindow(g->swapGWorld, g->theWindow);
    return noErr;
}

OSStatus DrawInstructionsWindow(EventHandlerCallRef nextHandler, EventRef theEvent, void *data)
{
    DrawGWorldToWindow(g->instructionsGWorld, g->instructionsWindow);
    return noErr;
}

OSStatus DrawAboutWindow(EventHandlerCallRef nextHandler, EventRef theEvent, void *data)
{
    DrawGWorldToWindow(g->aboutGWorld, g->aboutWindow);
    return noErr;
}

// ============================================================================
// Dialog Command Handlers (Simplified - need UI hookup)
// ============================================================================

OSStatus AskSwitchHandleCommand(EventHandlerCallRef nextHandler, EventRef theEvent, void *data)
{
    // Depth switching is obsolete on modern macOS
    // This dialog can be removed or simplified
    HideWindow(g->askSwitchWindow);
    SelectWindow(g->theWindow);
    return noErr;
}

OSStatus PrefsHandleCommand(EventHandlerCallRef nextHandler, EventRef theEvent, void *data)
{
    // This needs to be connected to UI buttons
    // For now, just provide the handler functions
    return noErr;
}

// Helper functions to be called from Cocoa UI
void PrefsOK(void)
{
    SetPrefs();
    HideWindow(g->prefsWindow);
    SelectWindow(g->theWindow);
    AutoPause();
}

void PrefsCancel(void)
{
    HideWindow(g->prefsWindow);
    SelectWindow(g->theWindow);
    AutoPause();
}

OSStatus HighScoresHandleCommand(EventHandlerCallRef nextHandler, EventRef theEvent, void *data)
{
    return noErr;
}

void HighScoresOK(void)
{
    HideWindow(g->highScoresWindow);
    SelectWindow(g->theWindow);
    
    if (g->startNewGameImmediately) {
        NewGame(g->startNewGameImmediately);
        g->startNewGameImmediately = 0;
    } else {
        AutoPause();
    }
}

void HighScoresReset(void)
{
    UnloadHighScores();
    DefaultHighScores();
    HighScores();
    SysBeep(1);
}

OSStatus LevelSelectHandleCommand(EventHandlerCallRef nextHandler, EventRef theEvent, void *data)
{
    return noErr;
}

void LevelSelectOK(int levelNumber)
{
    Level *theLevel = g->baseLevel;
    int i = 1;
    
    while (i < levelNumber && theLevel) {
        i++;
        theLevel = theLevel->next;
    }
    
    if (theLevel && levelNumber >= 1) {
        EndGame(FALSE);
        g->startNewGameImmediately = levelNumber;
        
        HideWindow(g->autoPauseWindow);
        HideWindow(g->prefsWindow);
        HideWindow(g->highScoresWindow);
        HideWindow(g->gameOverWindow);
        HideWindow(g->levelSelectWindow);
        HideWindow(g->instructionsWindow);
        HideWindow(g->aboutWindow);
        
        SelectWindow(g->theWindow);
    } else {
        SysBeep(1);
    }
}

void LevelSelectCancel(void)
{
    HideWindow(g->levelSelectWindow);
    SelectWindow(g->theWindow);
    AutoPause();
}

OSStatus AboutHandleMouse(EventHandlerCallRef nextHandler, EventRef theEvent, void *data)
{
    return noErr;
}

void AboutClick(void)
{
    if (GetCurrentEventTime() - g->lastAboutStyleWindowTime > 0.5) {
        HideWindow(g->aboutWindow);
        SelectWindow(g->theWindow);
        AutoPause();
    }
}

OSStatus InstructionsHandleMouse(EventHandlerCallRef nextHandler, EventRef theEvent, void *data)
{
    return noErr;
}

void InstructionsClick(void)
{
    if (GetCurrentEventTime() - g->lastAboutStyleWindowTime > 0.5) {
        HideWindow(g->instructionsWindow);
        SelectWindow(g->theWindow);
        
        if (g->firstRunDoAbout)
            g->firstRunDoAbout = FALSE;
        
        AutoPause();
    }
}

OSStatus HighScoreHandleCommand(EventHandlerCallRef nextHandler, EventRef theEvent, void *data)
{
    return noErr;
}

void HighScoreOK(CFStringRef playerName)
{
    if (playerName) {
        if (g->scores.lastName)
            CFRelease(g->scores.lastName);
        g->scores.lastName = CFStringCreateCopy(NULL, playerName);
    }
    
    UpdateHighScores();
    
    HideWindow(g->highScoreWindow);
    
    g->startNewGameImmediately = 1;
    HighScores();
}

OSStatus GameOverHandleCommand(EventHandlerCallRef nextHandler, EventRef theEvent, void *data)
{
    return noErr;
}

void GameOverOK(void)
{
    HideWindow(g->gameOverWindow);
    SelectWindow(g->theWindow);
    AutoPause();
}

void GameOverNewGame(void)
{
    HideWindow(g->gameOverWindow);
    SelectWindow(g->theWindow);
    g->startNewGameImmediately = 1;
}

OSStatus AutoPauseHandleCommand(EventHandlerCallRef nextHandler, EventRef theEvent, void *data)
{
    return noErr;
}

void AutoPauseResume(void)
{
    HideWindow(g->autoPauseWindow);
    SelectWindow(g->theWindow);
}

OSStatus HandleCommand(EventHandlerCallRef nextHandler, EventRef theEvent, void *data)
{
    return noErr;
}

OSStatus HandleMenu(EventHandlerCallRef nextHandler, EventRef theEvent, void *data)
{
    return noErr;
}

// ============================================================================
// Menu Command Processing
// ============================================================================

void ProcessMenuCommand(UInt32 commandID)
{
    switch (commandID)
    {
        case 'abou':
            About();
            break;
        
        case 'pref':
            Prefs();
            break;
        
        case 'newg':
            EndGame(FALSE);
            HideWindow(g->autoPauseWindow);
            HideWindow(g->prefsWindow);
            HideWindow(g->highScoresWindow);
            HideWindow(g->gameOverWindow);
            HideWindow(g->levelSelectWindow);
            HideWindow(g->instructionsWindow);
            HideWindow(g->aboutWindow);
            g->startNewGameImmediately = 1;
            break;
        
        case 'chlv':
            LevelSelect();
            break;
        
        case 'hisc':
            HighScores();
            break;
        
        case 'inst':
            Instructions();
            break;
        
        case 'endg':
            if (g->inGame) {
                g->alreadyAutoPaused = TRUE;
                HideWindow(g->autoPauseWindow);
                HideWindow(g->prefsWindow);
                HideWindow(g->highScoresWindow);
                HideWindow(g->gameOverWindow);
                HideWindow(g->levelSelectWindow);
                HideWindow(g->instructionsWindow);
                HideWindow(g->aboutWindow);
                EndGame(FALSE);
            }
            break;
        
        case 'mini':
            g->alreadyAutoPaused = TRUE;
            HideWindow(g->autoPauseWindow);
            break;
    }
}

// ============================================================================
// DoFrame - Main Game Loop (called by NSTimer in AppDelegate)
// ============================================================================

void DoFrame(void)
{
    static EventTime lastTime = 0;
    static EventTime thisTime = 0;
    
    lastTime = thisTime;
    thisTime = GetCurrentEventTime();
    
    if (g->windowActive)
    {
        if (g->startNewGameImmediately) {
            NewGame(g->startNewGameImmediately);
            g->startNewGameImmediately = 0;
        }
        
        CheckKeys();
        
        if (g->inGame)
        {
            g->sheepArrowsThisFrame = 0;
            
            switch (g->gameState)
            {
                case kLevelStart:
                    DrawBackground(g->swapGWorld);
                    DrawStuff(g->swapGWorld);
                    DrawScore(g->swapGWorld);
                    DrawLevelStartStuff(g->swapGWorld);
                    g->bonusChainLength = 0;
                    break;
                
                case kPlaying:
                    if (!(alphaLock & GetCurrentKeyModifiers()))
                        OneFrame();
                    else
                        DrawPausedStuff(g->swapGWorld);
                    break;
                
                case kLevelEnd:
                    DrawBackground(g->swapGWorld);
                    DrawStuff(g->swapGWorld);
                    DrawScore(g->swapGWorld);
                    DrawLevelEndStuff(g->swapGWorld);
                    break;
                
                case kGameOverScreen:
                    g->frameTime = GetCurrentEventTime();
                    ProcessSheep();
                    ProcessScoreEffects();
                    RemoveDeadStuff();
                    DrawBackground(g->swapGWorld);
                    DrawStuff(g->swapGWorld);
                    if (g->pref.fire == kOn)
                        ProcessAndDrawFire(g->swapGWorld);
                    DrawScoreEffects(g->swapGWorld);
                    DrawScore(g->swapGWorld);
                    DrawBonus(g->swapGWorld);
                    DrawGameOverScreenStuff(g->swapGWorld);
                    break;
                
                case kCompletedScreen:
                    DrawBackground(g->swapGWorld);
                    DrawStuff(g->swapGWorld);
                    if (g->pref.fire == kOn)
                        ProcessAndDrawFire(g->swapGWorld);
                    DrawScoreEffects(g->swapGWorld);
                    DrawScore(g->swapGWorld);
                    DrawBonus(g->swapGWorld);
                    DrawCompletedScreenStuff(g->swapGWorld);
                    break;
            }
        }
        else
        {
            InterfaceMousePos();
            DrawInterface(g->swapGWorld);
            
            if (g->askSwitchDepthPreferences)
                AskSwitchDepth();
            
            if (g->firstRunDoAbout)
                Instructions();
        }
    }
    
    CheckKeys();
    
    // Note: Actual drawing to window happens via GameView's drawRect:
    // which is triggered by setNeedsDisplay:YES in AppDelegate's doFrame
    
    if (lastTime > 0) {
        g->fps = 1.0 / (thisTime - lastTime);
    }
}

// ============================================================================
// Interface Mouse Handling
// ============================================================================

void InterfaceMousePos(void)
{
    Point mouseLoc;
    
    if (!g->windowActive)
        return;
    
    GetCompensatedMouse(&mouseLoc);
    
    if (mouseLoc.h >= 210 && mouseLoc.h < 410)
    {
        if (mouseLoc.v >= 110 && mouseLoc.v < 330)
        {
            short row = (mouseLoc.v - 110) / 55;
            g->mouseOverOption = row + 1;
            return;
        }
    }
    
    g->mouseOverOption = 0;
}

// Called from GameView on mouse click
void HandleInterfaceClick(int x, int y)
{
    if (!g->inGame)
    {
        if (x >= 210 && x < 410 && y >= 110 && y < 330)
        {
            short row = (y - 110) / 55;
            short option = row + 1;
            
            g->clickedOnOption = option;
        }
    }
}

// Called from GameView on mouse up
void HandleInterfaceRelease(int x, int y)
{
    if (!g->inGame && g->clickedOnOption)
    {
        short currentOption = 0;
        
        if (x >= 210 && x < 410 && y >= 110 && y < 330)
        {
            short row = (y - 110) / 55;
            currentOption = row + 1;
        }
        
        if (currentOption == g->clickedOnOption)
        {
            // Execute the option
            switch (g->clickedOnOption)
            {
                case kNewGame:
                    g->startNewGameImmediately = 1;
                    break;
                case kHighScores:
                    HighScores();
                    break;
                case kPreferences:
                    Prefs();
                    break;
                case kQuit:
                    [NSApp terminate:nil];
                    break;
            }
        }
        
        g->clickedOnOption = 0;
    }
}

// ============================================================================
// Keyboard Handling
// ============================================================================

void CheckKeys(void)
{
    // Keyboard is now handled by GameView's keyDown:
    // This function can check for global key states if needed
}

// Called from GameView
void HandleKeyPress(unichar key)
{
    if (g->inGame)
    {
        switch (key)
        {
            case '1':
                SelectWeapon(kUzi);
                break;
            case '2':
                SelectWeapon(kMagnum);
                break;
            case '3':
                SelectWeapon(kShotgun);
                break;
            case '4':
                SelectWeapon(kFlamer);
                break;
            case 'p':
            case 'P':
                TogglePause();
                break;
            case 27: // Escape
                EndGame(FALSE);
                break;
        }
    }
    else
    {
        // In interface mode
        switch (key)
        {
            case 27: // Escape
                Instructions();
                break;
        }
    }
}

// ============================================================================
// Game Actions
// ============================================================================

void SelectWeapon(short weaponID)
{
    if (g->gameState <= kPlaying)
    {
        Weapon *theWeapon = g->baseWeapon;
        while (theWeapon && theWeapon->weaponID != weaponID)
            theWeapon = theWeapon->next;
        
        if (theWeapon && theWeapon != g->theWeapon)
        {
            g->theWeapon = theWeapon;
            PlaySound(kBleepChannel, g->sounds.weaponSwitch);
        }
    }
}

void TogglePause(void)
{
    // Pause is handled by caps lock key in the original
    // This function can be used for explicit pause toggle
}

// ============================================================================
// Dialog Display Functions
// ============================================================================

void About(void)
{
    g->lastAboutStyleWindowTime = GetCurrentEventTime();
    ShowWindow(g->aboutWindow);
    SelectWindow(g->aboutWindow);
}

void Instructions(void)
{
    g->lastAboutStyleWindowTime = GetCurrentEventTime();
    ShowWindow(g->instructionsWindow);
    SelectWindow(g->instructionsWindow);
}

void Prefs(void)
{
    // Set up preferences controls based on current prefs
    // This requires connecting UI controls
    
    ShowWindow(g->prefsWindow);
    SelectWindow(g->prefsWindow);
}

void SetPrefs(void)
{
    // Read preferences from UI controls and apply them
    // This requires connecting UI controls
    
    // Check if sound preference changed
    // if (soundChanged) { FinishSounds(); LoadSounds(); }
    
    // Check if turbo preference changed
    // if (turboChanged) ReStartTimer();
    
    SavePreferences();
}

void HighScores(void)
{
    // Set up high scores display
    // This requires connecting UI controls
    
    ShowWindow(g->highScoresWindow);
    SelectWindow(g->highScoresWindow);
}

void LevelSelect(void)
{
    ShowWindow(g->levelSelectWindow);
    SelectWindow(g->levelSelectWindow);
}

void HighScore(void)
{
    PlaySound(kBonusChannel, g->sounds.SCBonus);
    
    // Set up high score entry dialog
    // This requires connecting UI controls
    
    ShowWindow(g->highScoreWindow);
    SelectWindow(g->highScoreWindow);
}

void GameOver(void)
{
    PlaySound(kBonusChannel, g->sounds.baa);
    
    g->scores.lastScoreIndex = -1;
    g->scores.lastKilledIndex = -1;
    g->scores.lastMultIndex = -1;
    g->scores.lastJuggleIndex = -1;
    
    // Set up game over dialog
    // This requires connecting UI controls
    
    ShowWindow(g->gameOverWindow);
    SelectWindow(g->gameOverWindow);
}

void AutoPause(void)
{
    if (g->theWindow == FrontNonFloatingWindow())
    {
        if (g->inGame)
        {
            if (!(alphaLock & GetCurrentKeyModifiers()))
            {
                ShowWindow(g->autoPauseWindow);
                SelectWindow(g->autoPauseWindow);
            }
        }
    }
}

void AskSwitchDepth(void)
{
    // Depth switching is obsolete on modern macOS
    // Just mark it as handled
    g->askSwitchDepthPreferences = FALSE;
}

// ============================================================================
// Mouse Position Helpers
// ============================================================================

void GetCompensatedMouse(Point *pt)
{
    // Get mouse position in window coordinates
    // This is now handled by GameView, but we provide this for compatibility
    
    NSPoint mouseLocation = [NSEvent mouseLocation];
    NSWindow *window = (__bridge NSWindow *)g->theWindow;
    
    if (window) {
        NSRect windowFrame = [window frame];
        NSRect contentRect = [window contentRectForFrameRect:windowFrame];
        
        pt->h = (short)(mouseLocation.x - contentRect.origin.x);
        pt->v = (short)(contentRect.size.height - (mouseLocation.y - contentRect.origin.y));
        
        if (g->pref.border) {
            pt->h -= BORDER_WIDTH;
            pt->v -= BORDER_HEIGHT;
        }
    } else {
        pt->h = 0;
        pt->v = 0;
    }
}

void WindowSizeHack(Boolean repos)
{
    if (!g->theWindow) return;
    
    NSWindow *window = (__bridge NSWindow *)g->theWindow;
    NSSize size;
    
    if (g->pref.border)
        size = NSMakeSize(620 + BORDER_WIDTH * 2, 420 + BORDER_HEIGHT * 2);
    else
        size = NSMakeSize(620, 420);
    
    [window setContentSize:size];
    
    if (repos)
        [window center];
    
    DrawBorder();
    DrawGWorldToWindow(g->swapGWorld, g->theWindow);
}

Point GetSubMainWindowPos(WindowRef theWindow, short stdHeightBelowMain)
{
    Point pos;
    
    NSWindow *mainWin = (__bridge NSWindow *)g->theWindow;
    NSWindow *thisWin = (__bridge NSWindow *)theWindow;
    
    if (mainWin && thisWin) {
        NSRect mainFrame = [mainWin frame];
        NSRect thisFrame = [thisWin frame];
        
        pos.h = (short)(mainFrame.origin.x + (g->pref.border ? BORDER_WIDTH : 0) + 310 - thisFrame.size.width / 2);
        pos.v = (short)([[NSScreen mainScreen] frame].size.height - mainFrame.origin.y - mainFrame.size.height + (g->pref.border ? BORDER_HEIGHT : 0) + stdHeightBelowMain);
    } else {
        pos.h = 100;
        pos.v = 100;
    }
    
    return pos;
}

// ============================================================================
// Stub functions for functions called from other files
// ============================================================================

short GetInterfaceOption(int x, int y)
{
    if (x >= 210 && x < 410 && y >= 110 && y < 330) {
        return (y - 110) / 55 + 1;
    }
    return 0;
}

void DoShot(int x, int y)
{
    if (g->inGame && g->gameState == kPlaying) {
        // Process weapon shot at coordinates
        Shot(x, y);
    }
}

void HandleMouseUp(int x, int y)
{
    HandleInterfaceRelease(x, y);
}

void HandleMouseMoved(int x, int y)
{
    // Update mouse tracking for interface
    if (!g->inGame) {
        if (x >= 210 && x < 410 && y >= 110 && y < 330) {
            g->mouseOverOption = (y - 110) / 55 + 1;
        } else {
            g->mouseOverOption = 0;
        }
    }
}
