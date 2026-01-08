//
//  GameView.h
//  MAFFia (Upgraded)
//
//  Created by Pascal Harris on 08/01/2026.
//

#import <Cocoa/Cocoa.h>

@interface GameView : NSView

// Redraw the game view
- (void)setNeedsRedraw;

@end

// Forward declarations for game functions used by GameView
extern void SelectWeapon(short weaponID);
extern void TogglePause(void);
extern void EndGame(bool immediate);
extern short GetInterfaceOption(int x, int y);
extern void DoShot(int x, int y);
extern void HandleMouseUp(int x, int y);
extern void HandleMouseMoved(int x, int y);
