#pragma once

/*
 * PommeTypes.h - Mac OS Type Definitions for Pomme Compatibility Layer
 * 
 * This header provides classic Mac OS types for modern macOS applications.
 * It handles two scenarios:
 * 
 * 1. If Cocoa/Carbon headers are included FIRST (__MACTYPES__ is defined):
 *    - Use system types for everything the system provides
 *    - Define only the Pomme-specific extensions
 * 
 * 2. If Pomme headers are included FIRST (__MACTYPES__ is NOT defined):
 *    - Define all types ourselves
 *    - Set guards to prevent system headers from redefining them
 */

#include <stdbool.h>
#include <stdint.h>

/*=============================================================================
 * SCENARIO 1: System headers were included first
 * We use system types and only add Pomme-specific stuff if needed
 *============================================================================*/
#ifdef __MACTYPES__

/* System types are already defined - nothing to do */

/*=============================================================================
 * SCENARIO 2: Pomme headers are included first
 * We define everything and set guards to block system headers
 *============================================================================*/
#else /* __MACTYPES__ not defined */

/*
 * Define ALL header guards to prevent ANY system Carbon/CarbonCore headers
 * from being included later. This is the comprehensive list.
 */

/* Core type headers */
#define __MACTYPES__
#define __MACERRORS__
#define __MIXEDMODE__
#define __CONDITIONALMACROS__

/* File system headers */
#define __FILES__
#define __FOLDERS__
#define __ALIASES__
#define __HFSVOLUMES__
#define __RESOURCES__
#define __FINDER__

/* Memory headers */
#define __MACMEMORY__

/* QuickDraw headers */
#define __QUICKDRAW__
#define __QDOFFSCREEN__
#define __QUICKDRAWTEXT__
#define __FONTS__
#define __PALETTES__
#define __PICTUTILS__
#define __VIDEO__
#define __DISPLAYS__

/* Text headers */
#define __SCRIPT__
#define __TEXTCOMMON__
#define __UNICODECONVERTER__
#define __UNICODEUTILITIES__
#define __TEXTENCODINGCONVERTER__
#define __TEXTUTILS__

/* Component/Mixed Mode headers */
#define __COMPONENTS__
#define __CODEFRAGMENTS__

/* Window/Control headers */
#define __MACWINDOWS__
#define __CONTROLS__
#define __APPEARANCE__
#define __MENUS__
#define __DIALOGS__
#define __LISTS__

/* Event headers */
#define __EVENTS__
#define __OSUTILS__
#define __PROCESSES__
#define __LOWMEM__

/* Sound headers */
#define __SOUND__

/* Time headers */
#define __TIMER__
#define __DATETIMEUTILS__
#define __UTCUTILS__

/* Thread headers */
#define __THREADS__

/* Collection headers */
#define __COLLECTIONS__

/* Gestalt/Debug headers */
#define __GESTALT__
#define __DEBUGGING__
#define __MACHINEEXCEPTIONS__

/* Multiprocessing headers */
#define __MULTIPROCESSING__
#define __MULTIPROCESSINGINFO__

/* Other CarbonCore headers that might cause conflicts */
#define __DRIVERSERVICES__
#define __NAMEREGISTRY__
#define __POWER__
#define __SCSI__
#define __AVLTREE__
#define __PEFBINARYFORMAT__
#define __HFSDATAEXTRACTOR__
#define __FSEVENTS__
#define __DEVICECONTROL__
#define __PATCHES__
#define __DRIVERSYNCHRONIZATION__
#define __INTERRUPTSSUPPORT__

/*=============================================================================
 * INTEGER TYPES
 *============================================================================*/

typedef int8_t                          SignedByte;
typedef int8_t                          SInt8;
typedef int16_t                         SInt16;
typedef int32_t                         SInt32;
typedef int64_t                         SInt64;

typedef uint8_t                         Byte;
typedef uint8_t                         UInt8;
typedef uint8_t                         Boolean;
typedef uint16_t                        UInt16;
typedef uint32_t                        UInt32;
typedef uint64_t                        UInt64;

/*=============================================================================
 * FLOATING POINT TYPES
 *============================================================================*/

typedef float                           Float32;
typedef double                          Float64;

typedef struct Float80 {
    SInt16                              exp;
    UInt16                              man[4];
} Float80;

typedef Float80                         extended80;

/*=============================================================================
 * CHARACTER AND STRING TYPES
 *============================================================================*/

typedef uint16_t                        UniChar;
typedef uint32_t                        UTF32Char;
typedef uint32_t                        UnicodeScalarValue;
typedef unsigned long                   UniCharCount;
typedef UInt16                          UniCharArrayOffset;

typedef struct HFSUniStr255 {
    UInt16                              length;
    UniChar                             unicode[255];
} HFSUniStr255;

typedef const HFSUniStr255*             ConstHFSUniStr255Param;

/*=============================================================================
 * TEXT TYPES
 *============================================================================*/

typedef unsigned char*                  TextPtr;
typedef const unsigned char*            ConstTextPtr;

typedef struct TextEncodingRun {
    unsigned long                       offset;
    UInt32                              textEncoding;
} TextEncodingRun;

typedef UInt32                          TextEncoding;
typedef TextEncoding*                   TextEncodingPtr;

/*=============================================================================
 * WIDE (64-BIT INTEGER) TYPES
 *============================================================================*/

#if defined(__BIG_ENDIAN__) || (defined(__BYTE_ORDER__) && __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__)
typedef struct wide { SInt32 hi; UInt32 lo; } wide;
typedef struct UnsignedWide { UInt32 hi; UInt32 lo; } UnsignedWide;
#else
typedef struct wide { UInt32 lo; SInt32 hi; } wide;
typedef struct UnsignedWide { UInt32 lo; UInt32 hi; } UnsignedWide;
#endif

/*=============================================================================
 * FIXED-POINT TYPES
 *============================================================================*/

typedef SInt32                          Fixed;
typedef SInt32                          Fract;
typedef UInt32                          UnsignedFixed;
typedef SInt16                          ShortFixed;

typedef Fixed*                          FixedPtr;
typedef Fract*                          FractPtr;
typedef UnsignedFixed*                  UnsignedFixedPtr;
typedef ShortFixed*                     ShortFixedPtr;

/*=============================================================================
 * BASIC SYSTEM TYPES
 *============================================================================*/

typedef SInt16                          OSErr;
typedef SInt32                          OSStatus;

typedef void*                           LogicalAddress;
typedef const void*                     ConstLogicalAddress;
typedef void*                           PhysicalAddress;

typedef UInt8*                          BytePtr;
typedef unsigned long                   ByteCount;
typedef unsigned long                   ByteOffset;

typedef SInt32                          Duration;
typedef UnsignedWide                    AbsoluteTime;
typedef UInt32                          OptionBits;
typedef unsigned long                   ItemCount;
typedef UInt32                          PBVersion;

typedef SInt16                          ScriptCode;
typedef SInt16                          LangCode;
typedef SInt16                          RegionCode;

typedef UInt32                          FourCharCode;
typedef FourCharCode                    OSType;
typedef FourCharCode                    ResType;
typedef OSType*                         OSTypePtr;
typedef ResType*                        ResTypePtr;

/*=============================================================================
 * POINTER AND HANDLE TYPES
 *============================================================================*/

typedef char*                           Ptr;
typedef Ptr*                            Handle;
typedef long                            Size;

/*=============================================================================
 * PROCEDURE POINTER TYPES
 *============================================================================*/

typedef long                            (*ProcPtr)(void);
typedef void*                           UniversalProcPtr;

typedef void*                           SRefCon;
typedef void*                           URefCon;

/*=============================================================================
 * QUICKDRAW TEXT STYLE
 *============================================================================*/

typedef UInt8                           Style;
typedef short                           StyleParameter;
typedef Style                           StyleField;

/*=============================================================================
 * PASCAL STRING TYPES
 *============================================================================*/

typedef unsigned char                   Str15[16];
typedef unsigned char                   Str31[32];
typedef unsigned char                   Str32[33];
typedef unsigned char                   Str63[64];
typedef unsigned char                   Str255[256];
typedef unsigned char*                  StringPtr;
typedef StringPtr*                      StringHandle;
typedef const unsigned char*            ConstStr255Param;
typedef const unsigned char*            ConstStr63Param;
typedef const unsigned char*            ConstStr32Param;
typedef const unsigned char*            ConstStr31Param;
typedef const unsigned char*            ConstStr27Param;
typedef const unsigned char*            ConstStr15Param;
typedef const unsigned char*            ConstStringPtr;

/*=============================================================================
 * POINT AND RECT TYPES
 *============================================================================*/

typedef struct Point {
    SInt16                              v;
    SInt16                              h;
} Point;

typedef struct Rect {
    SInt16                              top;
    SInt16                              left;
    SInt16                              bottom;
    SInt16                              right;
} Rect;

typedef Point*                          PointPtr;
typedef Rect*                           RectPtr;

typedef struct FixedPoint {
    Fixed                               x;
    Fixed                               y;
} FixedPoint;

typedef struct FixedRect {
    Fixed                               left;
    Fixed                               top;
    Fixed                               right;
    Fixed                               bottom;
} FixedRect;

/*=============================================================================
 * QUEUE ELEMENT TYPES (needed by Timer.h and others)
 *============================================================================*/

typedef struct QElem {
    struct QElem*                       qLink;
    short                               qType;
    short                               qData[1];
} QElem;

typedef QElem*                          QElemPtr;

typedef struct QHdr {
    volatile short                      qFlags;
    volatile QElemPtr                   qHead;
    volatile QElemPtr                   qTail;
} QHdr;

typedef QHdr*                           QHdrPtr;

/*=============================================================================
 * FILE SYSTEM TYPES
 *============================================================================*/

typedef struct FSSpec {
    short                               vRefNum;
    long                                parID;
    Str255                              cName;
} FSSpec;

typedef FSSpec*                         FSSpecPtr;
typedef const FSSpec*                   ConstFSSpecPtr;

typedef struct FSRef {
    UInt8                               hidden[80];
} FSRef;

typedef FSRef*                          FSRefPtr;
typedef const FSRef*                    ConstFSRefPtr;

typedef SInt16                          FSIORefNum;
typedef UInt32                          FSCatalogInfoBitmap;
typedef struct FSCatalogInfo            FSCatalogInfo;
typedef FSCatalogInfo*                  FSCatalogInfoPtr;

typedef Handle                          AliasHandle;
typedef SInt32                          FSVolumeRefNum;

/*=============================================================================
 * QUICKDRAW TYPES
 *============================================================================*/

typedef SInt16                          QDErr;

typedef struct RGBColor {
    UInt16                              red;
    UInt16                              green;
    UInt16                              blue;
} RGBColor;

typedef RGBColor*                       RGBColorPtr;
typedef RGBColorPtr*                    RGBColorHdl;

typedef struct Picture {
    SInt16                              picSize;
    Rect                                picFrame;
    Ptr                                 __pomme_pixelsARGB32;
} Picture;

typedef Picture*                        PicPtr;
typedef PicPtr*                         PicHandle;

typedef Handle                          GDHandle;

typedef struct PixMap {
    Rect                                bounds;
    short                               pixelSize;
    short                               rowBytes;
    Ptr                                 _impl;
} PixMap;

typedef PixMap*                         PixMapPtr;
typedef PixMapPtr*                      PixMapHandle;

typedef struct BitMap {
    Ptr                                 baseAddr;
    short                               rowBytes;
    Rect                                bounds;
} BitMap;

typedef BitMap*                         BitMapPtr;
typedef BitMapPtr*                      BitMapHandle;

typedef struct GrafPort {
    Rect                                portRect;
    void*                               _impl;
} GrafPort;

typedef GrafPort*                       GrafPtr;
typedef GrafPtr                         WindowPtr;
typedef GrafPort                        CGrafPort;
typedef GrafPtr                         CGrafPtr;
typedef CGrafPtr                        GWorldPtr;

/*=============================================================================
 * QUICKDRAW COLOR MANAGER TYPES
 *============================================================================*/

typedef struct ColorSpec {
    short                               value;
    RGBColor                            rgb;
} ColorSpec;

typedef ColorSpec*                      ColorSpecPtr;
typedef ColorSpec                       CSpecArray[1];

typedef struct ColorInfo {
    RGBColor                            ciRGB;
    short                               ciUsage;
    short                               ciTolerance;
    short                               ciDataFields[3];
} ColorInfo;

typedef ColorInfo*                      ColorInfoPtr;
typedef ColorInfoPtr*                   ColorInfoHandle;

typedef struct Palette {
    short                               pmEntries;
    short                               pmDataFields[7];
    ColorInfo                           pmInfo[1];
} Palette;

typedef Palette*                        PalettePtr;
typedef PalettePtr*                     PaletteHandle;

typedef struct ColorTable {
    SInt32                              ctSeed;
    short                               ctFlags;
    short                               ctSize;
    CSpecArray                          ctTable;
} ColorTable;

typedef ColorTable*                     CTabPtr;
typedef CTabPtr*                        CTabHandle;

/*=============================================================================
 * TIMER TYPES (to prevent Timer.h conflicts)
 *============================================================================*/

typedef struct TMTask*                  TMTaskPtr;
typedef void (*TimerProcPtr)(TMTaskPtr tmTaskPtr);
typedef TimerProcPtr                    TimerUPP;

typedef struct TMTask {
    QElemPtr                            qLink;
    short                               qType;
    TimerUPP                            tmAddr;
    long                                tmCount;
    long                                tmWakeUp;
    long                                tmReserved;
} TMTask;

#define NewTimerUPP(userRoutine)        ((TimerUPP)(userRoutine))
#define DisposeTimerUPP(userUPP)
#define InvokeTimerUPP(tmTaskPtr, userUPP) (*(userUPP))(tmTaskPtr)

/*=============================================================================
 * MULTIPROCESSING TYPES (to prevent Multiprocessing.h conflicts)
 *============================================================================*/

/* Opaque ID types */
typedef struct OpaqueMPProcessID*       MPProcessID;
typedef struct OpaqueMPTaskID*          MPTaskID;
typedef struct OpaqueMPQueueID*         MPQueueID;
typedef struct OpaqueMPSemaphoreID*     MPSemaphoreID;
typedef struct OpaqueMPCriticalRegionID* MPCriticalRegionID;
typedef struct OpaqueMPTimerID*         MPTimerID;
typedef struct OpaqueMPEventID*         MPEventID;
typedef struct OpaqueMPNotificationID*  MPNotificationID;
typedef struct OpaqueMPAddressSpaceID*  MPAddressSpaceID;
typedef struct OpaqueMPCoherenceID*     MPCoherenceID;
typedef struct OpaqueMPCpuID*           MPCpuID;
typedef struct OpaqueMPAreaID*          MPAreaID;
typedef struct OpaqueMPConsoleID*       MPConsoleID;
typedef struct OpaqueMPOpaqueID*        MPOpaqueID;

/* kOpaque* constants used by MultiprocessingInfo.h */
#define kOpaqueQueueID          ((MPOpaqueID)1)
#define kOpaqueSemaphoreID      ((MPOpaqueID)2)
#define kOpaqueEventID          ((MPOpaqueID)3)
#define kOpaqueCriticalRegionID ((MPOpaqueID)4)
#define kOpaqueNotificationID   ((MPOpaqueID)5)
#define kOpaqueAddressSpaceID   ((MPOpaqueID)6)
#define kOpaqueTimerID          ((MPOpaqueID)7)
#define kOpaqueAreaID           ((MPOpaqueID)8)
#define kOpaqueConsoleID        ((MPOpaqueID)9)

/* Task options and other constants */
typedef UInt32                          MPTaskOptions;
typedef UInt32                          TaskStorageIndex;
typedef UInt32                          TaskStorageValue;
typedef UInt32                          MPSemaphoreCount;
typedef UInt32                          MPTaskWeight;
typedef UInt32                          MPEventFlags;
typedef void*                           MPRemoteContext;
typedef ItemCount                       MPTaskStateKind;
typedef UInt32                          MPPageSizeClass;

/*=============================================================================
 * SOUND MANAGER TYPES
 *============================================================================*/

typedef struct SndCommand {
    unsigned short                      cmd;
    short                               param1;
    union {
        long                            param2;
        Ptr                             ptr;
    };
} SndCommand;

typedef struct SCStatus {
    UnsignedFixed                       scStartTime;
    UnsignedFixed                       scEndTime;
    UnsignedFixed                       scCurrentTime;
    Boolean                             scChannelBusy;
    Boolean                             scChannelDisposed;
    Boolean                             scChannelPaused;
    Boolean                             scUnused;
    unsigned long                       scChannelAttributes;
    long                                scCPULoad;
} SCStatus;

typedef SCStatus*                       SCStatusPtr;

typedef struct SndChannel*              SndChannelPtr;

typedef void (*SndCallBackProcPtr)(SndChannelPtr chan, SndCommand* cmd);
typedef SndCallBackProcPtr              SndCallbackUPP;

typedef struct SndChannel {
    SndChannelPtr                       nextChan;
    SndCallBackProcPtr                  callBack;
    long long                           userInfo;
    Ptr                                 channelImpl;
} SndChannel;

typedef struct ModRef {
    unsigned short                      modNumber;
    long                                modInit;
} ModRef;

typedef struct SndListResource {
    short                               format;
    short                               numModifiers;
    ModRef                              modifierPart[1];
    short                               numCommands;
    SndCommand                          commandPart[1];
    UInt8                               dataPart[1];
} SndListResource;

typedef SndListResource*                SndListPtr;
typedef SndListPtr*                     SndListHandle;
typedef SndListHandle                   SndListHndl;

typedef void (*FilePlayCompletionProcPtr)(SndChannelPtr chan);
typedef FilePlayCompletionProcPtr       FilePlayCompletionUPP;
#define NewFilePlayCompletionProc(userRoutine) (userRoutine)

/*=============================================================================
 * KEYBOARD INPUT TYPES
 *============================================================================*/

typedef UInt32                          KeyMap[4];
typedef UInt8                           KeyMapByteArray[16];

/*=============================================================================
 * VERSION TYPES
 *============================================================================*/

#if defined(__BIG_ENDIAN__) || (defined(__BYTE_ORDER__) && __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__)
typedef struct NumVersion {
    UInt8                               majorRev;
    UInt8                               minorAndBugRev;
    UInt8                               stage;
    UInt8                               nonRelRev;
} NumVersion;
#else
typedef struct NumVersion {
    UInt8                               nonRelRev;
    UInt8                               stage;
    UInt8                               minorAndBugRev;
    UInt8                               majorRev;
} NumVersion;
#endif

/*=============================================================================
 * THREAD TYPES
 *============================================================================*/

typedef UInt32                          ThreadID;
typedef void*                           ThreadTaskRef;

typedef struct SchedulerInfoRec {
    UInt32                              InfoRecSize;
    ThreadID                            CurrentThread;
    ThreadID                            SuggestedThread;
    ThreadID                            IteratedThread;
} SchedulerInfoRec;

typedef SchedulerInfoRec*               SchedulerInfoRecPtr;

/*=============================================================================
 * UNIVERSAL PROCEDURE POINTER TYPES (UPPs)
 * All UPPs are void* in Pomme - we don't use the complex STACK_UPP_TYPE system
 *============================================================================*/

typedef UniversalProcPtr                MemoryAllocationProcPtr;
typedef UniversalProcPtr                MemoryFreeProcPtr;
typedef UniversalProcPtr                CollectionExceptionUPP;
typedef UniversalProcPtr                CollectionFlattenUPP;
typedef UniversalProcPtr                SelectorFunctionUPP;
typedef UniversalProcPtr                DeferredTaskUPP;
typedef UniversalProcPtr                ExceptionHandlerUPP;
typedef UniversalProcPtr                DebugAssertOutputHandlerUPP;
typedef UniversalProcPtr                DebugComponentCallbackUPP;
typedef UniversalProcPtr                IndexToUCStringUPP;
typedef UniversalProcPtr                ThreadSchedulerUPP;
typedef UniversalProcPtr                ThreadSwitchUPP;
typedef UniversalProcPtr                ThreadTerminationUPP;
typedef UniversalProcPtr                ThreadEntryUPP;

/* ProcPtr versions */
typedef long (*CollectionExceptionProcPtr)(void);
typedef long (*CollectionFlattenProcPtr)(void);
typedef long (*SelectorFunctionProcPtr)(void);
typedef void (*DeferredTaskProcPtr)(void);

/*=============================================================================
 * EXCEPTION HANDLING TYPES
 *============================================================================*/

struct ExceptionInformation;
typedef OSStatus (*ExceptionHandlerProcPtr)(struct ExceptionInformation*);

/*=============================================================================
 * DEBUG SUPPORT TYPES
 *============================================================================*/

typedef void (*DebugAssertOutputHandlerProcPtr)(
    OSType, UInt32, const char*, const char*, const char*, const char*, long, void*, ConstStr255Param
);

typedef void (*DebugComponentCallbackProcPtr)(SInt32, UInt32, Boolean*);

/*=============================================================================
 * UNICODE / CORE FOUNDATION TYPES
 *============================================================================*/

#ifndef __COREFOUNDATION__
struct __CFString;
typedef const struct __CFString*        CFStringRef;
#endif

typedef UInt16                          UCTypeSelectOptions;

typedef Boolean (*IndexToUCStringProcPtr)(
    UInt32, void*, void*, CFStringRef*, UCTypeSelectOptions*
);

/*=============================================================================
 * ADDITIONAL COMPATIBILITY TYPES
 *============================================================================*/

typedef struct ProcessSerialNumber {
    UInt32                              highLongOfPSN;
    UInt32                              lowLongOfPSN;
} ProcessSerialNumber;

typedef ProcessSerialNumber*            ProcessSerialNumberPtr;

typedef struct OpaqueRgnHandle*         RgnHandle;

typedef struct Cursor {
    UInt16                              data[16];
    UInt16                              mask[16];
    Point                               hotSpot;
} Cursor;

typedef Cursor*                         CursPtr;
typedef CursPtr*                        CursHandle;

typedef UInt8                           Pattern[8];
typedef Pattern*                        PatPtr;
typedef PatPtr*                         PatHandle;

/*=============================================================================
 * DATE/TIME TYPES
 *============================================================================*/

typedef struct DateTimeRec {
    short                               year;
    short                               month;
    short                               day;
    short                               hour;
    short                               minute;
    short                               second;
    short                               dayOfWeek;
} DateTimeRec;

typedef DateTimeRec*                    DateTimeRecPtr;

#endif /* __MACTYPES__ not defined */
