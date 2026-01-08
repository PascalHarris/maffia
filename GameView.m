//
//  GameView.m
//  MAFFia (Upgraded)
//
//  Created by Pascal Harris on 08/01/2026.
//

#import "GameView.h"
#include "Pomme.h"
#include "mafftypes.h"

extern GlobalStuff *g;

@implementation GameView

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        // Set up tracking area for mouse moved events
        NSTrackingAreaOptions options = NSTrackingMouseMoved | NSTrackingActiveInKeyWindow | NSTrackingInVisibleRect;
        NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:NSZeroRect
                                                                   options:options
                                                                     owner:self
                                                                  userInfo:nil];
        [self addTrackingArea:trackingArea];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        // Set up tracking area for mouse moved events
        NSTrackingAreaOptions options = NSTrackingMouseMoved | NSTrackingActiveInKeyWindow | NSTrackingInVisibleRect;
        NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:NSZeroRect
                                                                   options:options
                                                                     owner:self
                                                                  userInfo:nil];
        [self addTrackingArea:trackingArea];
    }
    return self;
}

- (void)setNeedsRedraw {
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Clear background
    [[NSColor blackColor] setFill];
    NSRectFill(dirtyRect);
    
    if (!g) return;
    
    // Draw the appropriate GWorld based on game state
    GWorldPtr gworldToDraw = g->swapGWorld;
    if (!g->inGame && g->interfaceBackGWorld) {
        gworldToDraw = g->interfaceBackGWorld;
    }
    
    if (!gworldToDraw) return;
    
    // Get pixel data from GWorld (Pomme stores ARGB32)
    PixMapHandle pixMap = GetGWorldPixMap(gworldToDraw);
    if (!pixMap) return;
    
    LockPixels(pixMap);
    
    // Get dimensions from the PixMap structure
    PixMap *pm = *pixMap;
    int width = pm->bounds.right - pm->bounds.left;
    int height = pm->bounds.bottom - pm->bounds.top;
    
    // Pomme stores 32-bit ARGB data
    Ptr baseAddr = GetPixBaseAddr(pixMap);
    int rowBytes = width * 4;  // 32-bit = 4 bytes per pixel
    
    // Create CGImage from ARGB32 pixel data
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Pomme uses ARGB format (Alpha in high byte)
    // On little-endian (Intel/ARM), this is stored as BGRA in memory
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little;
    
    CGContextRef bitmapContext = CGBitmapContextCreate(
        baseAddr,
        width,
        height,
        8,              // bits per component
        rowBytes,
        colorSpace,
        bitmapInfo
    );
    
    if (bitmapContext) {
        CGImageRef image = CGBitmapContextCreateImage(bitmapContext);
        
        if (image) {
            CGContextRef viewContext = [[NSGraphicsContext currentContext] CGContext];
            
            // Calculate draw position (centered with optional border)
            CGFloat offsetX = g->pref.border ? BORDER_WIDTH : 0;
            CGFloat offsetY = g->pref.border ? BORDER_HEIGHT : 0;
            
            // Save state before transformations
            CGContextSaveGState(viewContext);
            
            // Flip coordinates (Core Graphics is bottom-up, QuickDraw was top-down)
            CGContextTranslateCTM(viewContext, offsetX, self.bounds.size.height - offsetY);
            CGContextScaleCTM(viewContext, 1.0, -1.0);
            
            // Draw the image
            CGContextDrawImage(viewContext, CGRectMake(0, 0, width, height), image);
            
            CGContextRestoreGState(viewContext);
            CGImageRelease(image);
        }
        
        CGContextRelease(bitmapContext);
    }
    
    CGColorSpaceRelease(colorSpace);
    UnlockPixels(pixMap);
}

#pragma mark - Keyboard Input

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)keyDown:(NSEvent *)event {
    if ([event isARepeat]) return;
    
    NSString *chars = [event characters];
    if ([chars length] == 0) return;
    
    unichar key = [chars characterAtIndex:0];
    
    switch (key) {
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
        case 27:  // Escape
            if (g->inGame) {
                EndGame(FALSE);
            }
            break;
        default:
            [super keyDown:event];
            break;
    }
}

#pragma mark - Mouse Input

// Convert NSView coordinates to game coordinates
- (Point)gamePointFromEvent:(NSEvent *)event {
    NSPoint viewPoint = [self convertPoint:event.locationInWindow fromView:nil];
    
    // Flip Y coordinate (NSView is bottom-up, game is top-down)
    viewPoint.y = self.bounds.size.height - viewPoint.y;
    
    // Adjust for border if present
    if (g->pref.border) {
        viewPoint.x -= BORDER_WIDTH;
        viewPoint.y -= BORDER_HEIGHT;
    }
    
    Point pt;
    pt.h = (short)viewPoint.x;
    pt.v = (short)viewPoint.y;
    return pt;
}

- (void)mouseDown:(NSEvent *)event {
    Point pt = [self gamePointFromEvent:event];
    
    if (!g->inGame) {
        // Interface mode - check for button clicks
        short option = GetInterfaceOption(pt.h, pt.v);
        if (option) {
            g->clickedOnOption = option;
            [self setNeedsDisplay:YES];
        }
    } else {
        // Game mode - fire weapon
        DoShot(pt.h, pt.v);
    }
}

- (void)mouseUp:(NSEvent *)event {
    Point pt = [self gamePointFromEvent:event];
    HandleMouseUp(pt.h, pt.v);
}

- (void)mouseMoved:(NSEvent *)event {
    Point pt = [self gamePointFromEvent:event];
    HandleMouseMoved(pt.h, pt.v);
}

- (void)mouseDragged:(NSEvent *)event {
    // Treat drag same as move for continuous tracking
    Point pt = [self gamePointFromEvent:event];
    HandleMouseMoved(pt.h, pt.v);
}

@end
