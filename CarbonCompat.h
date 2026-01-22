/*
 *  CarbonCompat.h
 *  MAFFia
 *
 *  Compatibility layer for Carbon APIs that don't exist in modern macOS.
 *  This bridges the gap between the original Carbon code and Cocoa.
 *
 *  IMPORTANT: This header includes Pomme headers BEFORE Cocoa to ensure
 *  Pomme's type definitions take precedence and block system Carbon headers.
 */

#ifndef __CARBONCOMPAT_H__
#define __CARBONCOMPAT_H__

/*
 * Include Pomme FIRST - this sets guards that block system Carbon headers
 * from being pulled in when Cocoa is included below.
 */
#include "Pomme/PommeTypes.h"
#include "Pomme/PommeEnums.h"

/* Now we can safely include Cocoa - the guards will prevent conflicts */
#import <Cocoa/Cocoa.h>
#import <CoreFoundation/CoreFoundation.h>

#ifdef __cplusplus
extern "C" {
#endif

// ============================================================================
// Type definitions for Carbon types not in Pomme
// ============================================================================

// Window types - we'll store NSWindow* in these
// Note: WindowPtr is defined by Pomme as GrafPtr
typedef void* WindowRef;
typedef void* ControlRef;
typedef void* MenuRef;

// Event types
typedef void* EventLoopTimerRef;
typedef void* EventHandlerRef;
typedef void* EventHandlerUPP;
typedef void* EventLoopTimerUPP;
typedef void* EventHandlerCallRef;
typedef void* EventRef;

// Control types
typedef struct {
    OSType signature;
    SInt32 id;
} ControlID;

typedef struct {
    short just;
    short size;
    short style;
} ControlFontStyleRec;

// Time
typedef double EventTime;
#define kEventDurationSecond 1.0

// Get current time (replaces GetCurrentEventTime)
static inline EventTime GetCurrentEventTime(void) {
    return CFAbsoluteTimeGetCurrent();
}

// ============================================================================
// NIB Loading - Stubs (NIBs loaded via Cocoa)
// ============================================================================

typedef void* IBNibRef;

static inline OSStatus CreateNibReference(CFStringRef name, IBNibRef* outRef) {
    // NIBs are loaded automatically by Cocoa via the main storyboard/nib
    // This is a no-op; windows will be connected via IBOutlets
    *outRef = NULL;
    return noErr;
}

static inline OSStatus CreateWindowFromNib(IBNibRef nib, CFStringRef name, WindowRef* outWindow) {
    // Windows are created by Cocoa when NIB loads
    // The actual window references should come from AppDelegate outlets
    *outWindow = NULL;
    return noErr;
}

static inline OSStatus SetMenuBarFromNib(IBNibRef nib, CFStringRef name) {
    // Menu bar is set automatically from MainMenu.nib
    return noErr;
}

static inline void DisposeNibReference(IBNibRef nib) {
    // No-op
}

// ============================================================================
// Window Management
// ============================================================================

static inline void ShowWindow(WindowRef w) {
    if (w) [(__bridge NSWindow*)w makeKeyAndOrderFront:nil];
}

static inline void HideWindow(WindowRef w) {
    if (w) [(__bridge NSWindow*)w orderOut:nil];
}

static inline void SelectWindow(WindowRef w) {
    if (w) [(__bridge NSWindow*)w makeKeyAndOrderFront:nil];
}

static inline void DisposeWindow(WindowRef w) {
    // Don't actually dispose - let Cocoa manage window lifecycle
}

static inline void MoveWindow(WindowRef w, short x, short y, Boolean bringToFront) {
    if (w) {
        NSWindow *nsw = (__bridge NSWindow*)w;
        NSRect frame = [nsw frame];
        NSPoint topLeft = NSMakePoint(x, [[NSScreen mainScreen] frame].size.height - y);
        [nsw setFrameTopLeftPoint:topLeft];
        if (bringToFront) [nsw makeKeyAndOrderFront:nil];
    }
}

static inline void SizeWindow(WindowRef w, short width, short height, Boolean update) {
    if (w) {
        NSWindow *nsw = (__bridge NSWindow*)w;
        NSRect frame = [nsw frame];
        frame.size.width = width;
        frame.size.height = height;
        [nsw setFrame:frame display:update];
    }
}

static inline OSStatus RepositionWindow(WindowRef w, WindowRef relativeTo, UInt32 method) {
    if (w) {
        NSWindow *nsw = (__bridge NSWindow*)w;
        [nsw center];
    }
    return noErr;
}

static inline WindowRef FrontNonFloatingWindow(void) {
    return (__bridge WindowRef)[NSApp mainWindow];
}

static inline WindowRef GetUserFocusWindow(void) {
    return (__bridge WindowRef)[NSApp keyWindow];
}

// Window bounds constants
enum {
    kWindowContentRgn = 0,
    kWindowGlobalPortRgn = 1,
    kWindowCenterOnMainScreen = 0
};

static inline OSStatus GetWindowBounds(WindowRef w, UInt32 regionCode, Rect* outBounds) {
    if (w && outBounds) {
        NSWindow *nsw = (__bridge NSWindow*)w;
        NSRect frame = [nsw frame];
        outBounds->left = (short)frame.origin.x;
        outBounds->top = (short)([[NSScreen mainScreen] frame].size.height - frame.origin.y - frame.size.height);
        outBounds->right = (short)(frame.origin.x + frame.size.width);
        outBounds->bottom = (short)([[NSScreen mainScreen] frame].size.height - frame.origin.y);
    }
    return noErr;
}

// ============================================================================
// Port/Drawing Context
// ============================================================================

static inline void SetPortWindowPort(WindowRef w) {
    // No-op in Cocoa - drawing is done via NSView
}

static inline void BeginUpdate(WindowRef w) {
    // No-op in Cocoa
}

static inline void EndUpdate(WindowRef w) {
    // No-op in Cocoa
}

static inline void DrawControls(WindowRef w) {
    // No-op - Cocoa handles control drawing
}

// ============================================================================
// Control Management (Stubs - need to be implemented with Cocoa controls)
// ============================================================================

static inline OSStatus GetControlByID(WindowRef w, const ControlID* id, ControlRef* outControl) {
    // This needs to be replaced with outlet-based access
    // For now, return an error to indicate it's not implemented
    *outControl = NULL;
    return -1;  // controlNotFoundErr
}

static inline OSStatus GetControlData(ControlRef c, short part, OSType tag, Size bufferSize, void* buffer, Size* actualSize) {
    return -1;  // Not implemented
}

static inline OSStatus GetControlDataSize(ControlRef c, short part, OSType tag, Size* outSize) {
    return -1;  // Not implemented
}

static inline OSStatus SetControlData(ControlRef c, short part, OSType tag, Size size, const void* data) {
    return -1;  // Not implemented
}

static inline void SetControl32BitValue(ControlRef c, SInt32 value) {
    // Not implemented
}

static inline SInt32 GetControl32BitValue(ControlRef c) {
    return 0;  // Not implemented
}

static inline void SetControlFontStyle(ControlRef c, const ControlFontStyleRec* style) {
    // Not implemented
}

static inline OSStatus SetKeyboardFocus(WindowRef w, ControlRef c, short part) {
    return noErr;  // Not implemented
}

// Control part codes
enum {
    kControlEditTextPart = 5,
    kControlEditTextTextTag = 'text'
};

// ============================================================================
// Event Loop (Replaced by Cocoa run loop)
// ============================================================================

static inline void RunApplicationEventLoop(void) {
    // This is replaced by NSApplicationMain in main.m
    // If this gets called, it's from old code that needs updating
    [[NSRunLoop currentRunLoop] run];
}

static inline void QuitApplicationEventLoop(void) {
    [NSApp terminate:nil];
}

// ============================================================================
// Event Handlers (Stubs - need notification-based implementation)
// ============================================================================

typedef struct {
    OSType eventClass;
    UInt32 eventKind;
} EventTypeSpec;

// Event classes and kinds
enum {
    kEventClassWindow = 'wind',
    kEventClassMouse = 'mous',
    kEventClassKeyboard = 'keyb',
    kEventClassCommand = 'cmds',
    kEventClassMenu = 'menu',
    kEventClassApplication = 'appl',
    
    kEventWindowClose = 1,
    kEventWindowActivated = 2,
    kEventWindowDeactivated = 3,
    kEventWindowUpdate = 4,
    kEventWindowCollapsed = 5,
    kEventWindowExpanded = 6,
    kEventWindowShown = 7,
    kEventWindowHidden = 8,
    kEventWindowDragStarted = 9,
    kEventWindowDragCompleted = 10,
    
    kEventMouseDown = 1,
    kEventMouseUp = 2,
    kEventMouseMoved = 3,
    
    kEventCommandProcess = 1,
    
    kEventMenuBeginTracking = 1,
    kEventMenuEndTracking = 2,
    
    kEventAppActivated = 1
};

typedef OSStatus (*EventHandlerProcPtr)(EventHandlerCallRef, EventRef, void*);

static inline EventHandlerUPP NewEventHandlerUPP(EventHandlerProcPtr proc) {
    return (EventHandlerUPP)proc;
}

static inline OSStatus InstallWindowEventHandler(WindowRef w, EventHandlerUPP upp, UInt32 count, const EventTypeSpec* types, void* userData, EventHandlerRef* outRef) {
    // Event handlers need to be replaced with Cocoa notifications/delegates
    if (outRef) *outRef = NULL;
    return noErr;
}

static inline OSStatus InstallApplicationEventHandler(EventHandlerUPP upp, UInt32 count, const EventTypeSpec* types, void* userData, EventHandlerRef* outRef) {
    // Event handlers need to be replaced with Cocoa notifications/delegates
    if (outRef) *outRef = NULL;
    return noErr;
}

// ============================================================================
// Event Loop Timer
// ============================================================================

typedef void (*EventLoopTimerProcPtr)(EventLoopTimerRef, void*);
typedef void* EventLoopRef;

static inline EventLoopRef GetMainEventLoop(void) {
    return NULL;  // Not used in Cocoa
}

static inline EventLoopTimerUPP NewEventLoopTimerUPP(EventLoopTimerProcPtr proc) {
    return (EventLoopTimerUPP)proc;
}

// Timer installation - this needs to be replaced with NSTimer
// See AppDelegate for the actual implementation
static inline OSStatus InstallEventLoopTimer(EventLoopRef loop, EventTime delay, EventTime interval,
                                             EventLoopTimerUPP upp, void* userData, EventLoopTimerRef* outRef) {
    // This is stubbed - actual timer is created in AppDelegate
    if (outRef) *outRef = NULL;
    return noErr;
}

static inline OSStatus RemoveEventLoopTimer(EventLoopTimerRef timer) {
    // Handled by AppDelegate
    return noErr;
}

// ============================================================================
// Menu Commands
// ============================================================================

enum {
    kHICommandPreferences = 'pref',
    kHICommandAbout = 'abou',
    kHICommandQuit = 'quit'
};

static inline OSStatus EnableMenuCommand(MenuRef menu, UInt32 command) {
    return noErr;  // Menus managed by Cocoa
}

// ============================================================================
// Keyboard
// ============================================================================

enum {
    alphaLock = 0x0400
};

static inline UInt32 GetCurrentKeyModifiers(void) {
    NSEventModifierFlags flags = [NSEvent modifierFlags];
    UInt32 result = 0;
    if (flags & NSEventModifierFlagCapsLock) result |= alphaLock;
    return result;
}

// ============================================================================
// Cursors - use Pomme's CursHandle type (already defined in PommeTypes.h)
// ============================================================================

static inline CursHandle GetCursor(short cursorID) {
    // Return a placeholder - cursors handled differently in Cocoa
    return NULL;
}

static inline void SetCursor(CursHandle cursor) {
    [[NSCursor arrowCursor] set];
}

// ============================================================================
// Resource Manager Extension for Named Resources
// ============================================================================

// Pomme doesn't have GetNamedResource, so we implement it
Handle GetNamedResource(ResType type, const unsigned char* pascalName);

#ifdef __cplusplus
}
#endif

#endif // __CARBONCOMPAT_H__
