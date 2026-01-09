/*
 *  eventhandlers.h
 *  nibMAFF
 *
 *  Created by wibble on Tue Sep 10 2002.
 *  Copyright (c) 2002 William Reade. All rights reserved.
 *
 *  Updated 2026 for modern macOS.
 */

#ifndef __EVENTHANDLERS_H__
#define __EVENTHANDLERS_H__

#include "Pomme.h"
#include "mafftypes.h"

#ifdef __cplusplus
extern "C" {
#endif

// ============================================================================
// Timer/Event Loop
// ============================================================================

void InstallEventHandlers(void);
void StartTimer(void);
void ReStartTimer(void);

// ============================================================================
// Main Game Loop
// ============================================================================

void DoFrame(void);

// ============================================================================
// Legacy Event Handlers (kept for compatibility, now stubs)
// ============================================================================

OSStatus DoCloseMainWindow(EventHandlerCallRef nextHandler, EventRef theEvent, void *data);
OSStatus AutoPauseIfInGame(EventHandlerCallRef nextHandler, EventRef theEvent, void *data);
OSStatus ActivateMyWindow(EventHandlerCallRef nextHandler, EventRef theEvent, void *data);
OSStatus DeactivateMyWindow(EventHandlerCallRef nextHandler, EventRef theEvent, void *data);
OSStatus DrawMainWindow(EventHandlerCallRef nextHandler, EventRef theEvent, void *data);
OSStatus DrawInstructionsWindow(EventHandlerCallRef nextHandler, EventRef theEvent, void *data);
OSStatus DrawAboutWindow(EventHandlerCallRef nextHandler, EventRef theEvent, void *data);
OSStatus AskSwitchHandleCommand(EventHandlerCallRef nextHandler, EventRef theEvent, void *data);
OSStatus PrefsHandleCommand(EventHandlerCallRef nextHandler, EventRef theEvent, void *data);
OSStatus HighScoresHandleCommand(EventHandlerCallRef nextHandler, EventRef theEvent, void *data);
OSStatus LevelSelectHandleCommand(EventHandlerCallRef nextHandler, EventRef theEvent, void *data);
OSStatus AboutHandleMouse(EventHandlerCallRef nextHandler, EventRef theEvent, void *data);
OSStatus InstructionsHandleMouse(EventHandlerCallRef nextHandler, EventRef theEvent, void *data);
OSStatus HighScoreHandleCommand(EventHandlerCallRef nextHandler, EventRef theEvent, void *data);
OSStatus GameOverHandleCommand(EventHandlerCallRef nextHandler, EventRef theEvent, void *data);
OSStatus AutoPauseHandleCommand(EventHandlerCallRef nextHandler, EventRef theEvent, void *data);
OSStatus HandleMenu(EventHandlerCallRef nextHandler, EventRef theEvent, void *data);
OSStatus HandleCommand(EventHandlerCallRef nextHandler, EventRef theEvent, void *data);

// ============================================================================
// Dialog Functions
// ============================================================================

void Prefs(void);
void SetPrefs(void);
void HighScores(void);
void About(void);
void Instructions(void);
void LevelSelect(void);
void HighScore(void);
void GameOver(void);
void AutoPause(void);
void AskSwitchDepth(void);

// Dialog action helpers (called from Cocoa UI)
void PrefsOK(void);
void PrefsCancel(void);
void HighScoresOK(void);
void HighScoresReset(void);
void LevelSelectOK(int levelNumber);
void LevelSelectCancel(void);
void AboutClick(void);
void InstructionsClick(void);
void HighScoreOK(CFStringRef playerName);
void GameOverOK(void);
void GameOverNewGame(void);
void AutoPauseResume(void);

// ============================================================================
// Interface/Input Handling
// ============================================================================

void InterfaceMousePos(void);
void HandleInterfaceClick(int x, int y);
void HandleInterfaceRelease(int x, int y);
void CheckKeys(void);
void HandleKeyPress(unichar key);
void ProcessMenuCommand(UInt32 commandID);

// ============================================================================
// Game Actions
// ============================================================================

void SelectWeapon(short weaponID);
void TogglePause(void);

// ============================================================================
// Utility Functions
// ============================================================================

void GetCompensatedMouse(Point *pt);
void WindowSizeHack(Boolean repos);
Point GetSubMainWindowPos(WindowRef theWindow, short stdHeightBelowMain);

// Functions called from GameView
short GetInterfaceOption(int x, int y);
void DoShot(int x, int y);
void HandleMouseUp(int x, int y);
void HandleMouseMoved(int x, int y);

#ifdef __cplusplus
}
#endif

#endif // __EVENTHANDLERS_H__
