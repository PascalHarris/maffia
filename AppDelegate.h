//
//  AppDelegate.h
//  MAFFia (Upgraded)
//
//  Created by Pascal Harris on 08/01/2026.
//

#import <Cocoa/Cocoa.h>
#include "mafftypes.h"

@class GameView;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>

// Main game window and view
@property (strong) IBOutlet NSWindow *mainWindow;
@property (strong) IBOutlet GameView *gameView;

// Dialog windows (connect these in Interface Builder)
@property (weak) IBOutlet NSWindow *aboutWindow;
@property (weak) IBOutlet NSWindow *instructionsWindow;
@property (weak) IBOutlet NSWindow *prefsWindow;
@property (weak) IBOutlet NSWindow *highScoreWindow;
@property (weak) IBOutlet NSWindow *gameOverWindow;
@property (weak) IBOutlet NSWindow *highScoresWindow;
@property (weak) IBOutlet NSWindow *levelSelectWindow;
@property (weak) IBOutlet NSWindow *autoPauseWindow;
@property (weak) IBOutlet NSWindow *askSwitchWindow;

// Game timer
@property (strong) NSTimer *gameTimer;

// Actions for menu items
- (IBAction)showAboutWindow:(id)sender;
- (IBAction)showPreferencesWindow:(id)sender;
- (IBAction)startNewGame:(id)sender;
- (IBAction)showHighScores:(id)sender;

@end

// Global game state
extern GlobalStuff *g;

// Forward declarations for game functions
extern void Initialise(void);
extern void CleanUp(bool instaQuit);
extern void DoFrame(void);
extern void LoadInterface(void);
extern void InstallEventHandlers(void);
extern void DrawBorder(void);
extern void DrawGWorldToWindow(GWorldPtr gworld, WindowRef window);
extern void LoadPreferences(void);
extern void LoadGlobalGraphics(void);
extern void LoadEveryThingElse(void);
extern void LoadSounds(void);
extern void EmptyFireBuffer(void);
