//
//  AppDelegate.m
//  MAFFia (Upgraded)
//
//  Created by Pascal Harris on 08/01/2026.
//

#import "AppDelegate.h"
#import "GameView.h"

// Include Pomme for GWorld operations
#include "Pomme.h"

GlobalStuff *g = NULL;

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    // Initialize Pomme (for GWorld, Sound Manager, Resources)
    Pomme::Init();
    
    // Set up the sound resource file path for Pomme
    NSString *rsrcPath = [[NSBundle mainBundle] pathForResource:@"sound" ofType:@"rsrc"];
    if (rsrcPath) {
        // Open the resource file so Pomme can access 'snd ' resources
        short refNum = OpenResFile([rsrcPath fileSystemRepresentation]);
        if (refNum != -1) {
            UseResFile(refNum);
        }
    }
    
    // Allocate and initialize global state
    g = (GlobalStuff *)NewPtrClear(sizeof(GlobalStuff));
    if (!g) {
        [NSApp terminate:nil];
        return;
    }
    
    g->mainBundle = CFBundleGetMainBundle();
    
    // Load preferences (uses CFPreferences - still works!)
    LoadPreferences();
    
    // Initialize game state
    g->inGame = 0;
    g->windowActive = 1;
    
    SetRect(&g->swapBounds, 0, 0, 620, 420);
    g->fireBounds = g->swapBounds;
    InsetRect(&g->fireBounds, 1, 1);
    
    g->fireSwap = 0;
    EmptyFireBuffer();
    
    // Initialize linked list pointers
    g->baseScoreEffect = NULL;
    g->baseShotEffect = NULL;
    g->baseSheep = NULL;
    g->baseWeapon = NULL;
    g->baseLevel = NULL;
    g->baseSceneryType = NULL;
    g->baseBackground = NULL;
    g->theWeapon = NULL;
    g->theLevel = NULL;
    
    // Load graphics and game data
    LoadGlobalGraphics();
    LoadEveryThingElse();
    LoadSounds();
    
    // Store window references in global struct
    // (These are set via IBOutlets from the NIB)
    g->theWindow = (__bridge WindowRef)self.mainWindow;
    g->aboutWindow = (__bridge WindowRef)self.aboutWindow;
    g->instructionsWindow = (__bridge WindowRef)self.instructionsWindow;
    g->prefsWindow = (__bridge WindowRef)self.prefsWindow;
    g->highScoreWindow = (__bridge WindowRef)self.highScoreWindow;
    g->gameOverWindow = (__bridge WindowRef)self.gameOverWindow;
    g->highScoresWindow = (__bridge WindowRef)self.highScoresWindow;
    g->levelSelectWindow = (__bridge WindowRef)self.levelSelectWindow;
    g->autoPauseWindow = (__bridge WindowRef)self.autoPauseWindow;
    g->askSwitchWindow = (__bridge WindowRef)self.askSwitchWindow;
    
    // Set up main window
    if (self.mainWindow) {
        [self.mainWindow setDelegate:self];
        [self.mainWindow makeKeyAndOrderFront:nil];
        
        // Set window size based on border preference
        NSSize size;
        if (g->pref.border) {
            size = NSMakeSize(620 + BORDER_WIDTH * 2, 420 + BORDER_HEIGHT * 2);
        } else {
            size = NSMakeSize(620, 420);
        }
        [self.mainWindow setContentSize:size];
        [self.mainWindow center];
    }
    
    // Draw initial interface
    DrawBorder();
    if (g->interfaceBackGWorld && self.gameView) {
        [self.gameView setNeedsDisplay:YES];
    }
    
    // Start the game timer
    [self startGameTimer];
    
    // Show about window on first run
    if (g->firstRunDoAbout && self.aboutWindow) {
        [self.aboutWindow makeKeyAndOrderFront:nil];
    }
}

- (void)startGameTimer {
    // Stop existing timer if any
    [self.gameTimer invalidate];
    
    // Set frame rate based on turbo preference
    NSTimeInterval interval = g->pref.turbo ? (1.0/60.0) : (1.0/30.0);
    
    __weak typeof(self) weakSelf = self;
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                     repeats:YES
                                                       block:^(NSTimer *timer) {
        [weakSelf doFrame];
    }];
    
    // Make sure timer fires during event tracking (e.g., window dragging)
    [[NSRunLoop currentRunLoop] addTimer:self.gameTimer forMode:NSEventTrackingRunLoopMode];
}

- (void)doFrame {
    // Call the game's frame update
    DoFrame();
    
    // Trigger view redraw
    [self.gameView setNeedsDisplay:YES];
}

// Called when turbo preference changes
- (void)restartTimer {
    [self startGameTimer];
}

#pragma mark - NSApplicationDelegate

- (void)applicationWillTerminate:(NSNotification *)notification {
    [self.gameTimer invalidate];
    self.gameTimer = nil;
    
    CleanUp(false);
    Pomme::Shutdown();
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    g->windowActive = 1;
}

- (void)applicationDidResignActive:(NSNotification *)notification {
    g->windowActive = 0;
    // Auto-pause if in game
    // AutoPause(); // Uncomment when AutoPause is available
}

#pragma mark - NSWindowDelegate

- (void)windowDidBecomeMain:(NSNotification *)notification {
    g->windowActive = 1;
}

- (void)windowDidResignMain:(NSNotification *)notification {
    g->windowActive = 0;
}

- (BOOL)windowShouldClose:(NSWindow *)sender {
    if (sender == self.mainWindow) {
        [NSApp terminate:nil];
        return NO;
    }
    return YES;
}

#pragma mark - Menu Actions

- (IBAction)showAboutWindow:(id)sender {
    if (self.aboutWindow) {
        [self.aboutWindow makeKeyAndOrderFront:nil];
    }
}

- (IBAction)showPreferencesWindow:(id)sender {
    if (self.prefsWindow) {
        [self.prefsWindow makeKeyAndOrderFront:nil];
    }
}

- (IBAction)startNewGame:(id)sender {
    // StartGame(); // Call when implemented
}

- (IBAction)showHighScores:(id)sender {
    if (self.highScoresWindow) {
        [self.highScoresWindow makeKeyAndOrderFront:nil];
    }
}

@end

