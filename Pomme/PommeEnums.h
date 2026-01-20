#pragma once

/*
 * PommeEnums.h - Mac OS Enumeration Definitions for Pomme Compatibility Layer
 * 
 * This header provides classic Mac OS enumerations and constants.
 * Like PommeTypes.h, it handles coexistence with system headers.
 */

/*
 * Check if system Mac errors have already been defined.
 * If __MACERRORS__ is defined, system headers were included first.
 */
#ifndef __MACERRORS__

/* Set guard to prevent system MacErrors.h from being included later */
#define __MACERRORS__

/*=============================================================================
 * FILE SYSTEM PERMISSION CONSTANTS
 *============================================================================*/

enum EFSPermissions
{
    fsCurPerm   = 0,
    fsRdPerm    = 1,
    fsWrPerm    = 2,
    fsRdWrPerm  = 3,
};

/*=============================================================================
 * FILE POSITION MODE CONSTANTS
 *============================================================================*/

enum {
    fsAtMark    = 0,
    fsFromStart = 1,
    fsFromLEOF  = 2,
    fsFromMark  = 3
};

/*=============================================================================
 * FOLDER TYPE CONSTANTS
 *============================================================================*/

enum
{
    kSystemFolderType               = 'macs',
    kDesktopFolderType              = 'desk',
    kSystemDesktopFolderType        = 'sdsk',
    kTrashFolderType                = 'trsh',
    kSystemTrashFolderType          = 'strs',
    kWhereToEmptyTrashFolderType    = 'empt',
    kPrintMonitorDocsFolderType     = 'prnt',
    kStartupFolderType              = 'strt',
    kShutdownFolderType             = 'shdf',
    kAppleMenuFolderType            = 'amnu',
    kControlPanelFolderType         = 'ctrl',
    kSystemControlPanelFolderType   = 'sctl',
    kExtensionFolderType            = 'extn',
    kFontsFolderType                = 'font',
    kPreferencesFolderType          = 'pref',
    kSystemPreferencesFolderType    = 'sprf',
    kTemporaryFolderType            = 'temp'
};

/*=============================================================================
 * VOLUME/DOMAIN CONSTANTS
 *============================================================================*/

enum {
    kOnSystemDisk       = -32768L,
    kOnAppropriateDisk  = -32767,
    kSystemDomain       = -32766,
    kLocalDomain        = -32765,
    kNetworkDomain      = -32764,
    kUserDomain         = -32763,
    kClassicDomain      = -32762
};

#define kCreateFolder       true
#define kDontCreateFolder   false
#define kInvalidID          0

/*=============================================================================
 * ERROR CODES (OSErr)
 *============================================================================*/

enum EErrors
{
    noErr               = 0,

    unimpErr            = -4,

    controlErr          = -17,
    statusErr           = -18,
    readErr             = -19,
    writErr             = -20,
    badUnitErr          = -21,
    unitEmptyErr        = -22,
    openErr             = -23,
    closErr             = -24,

    abortErr            = -27,
    notOpenErr          = -28,

    dirFulErr           = -33,
    dskFulErr           = -34,
    nsvErr              = -35,
    ioErr               = -36,
    bdNamErr            = -37,
    fnOpnErr            = -38,
    eofErr              = -39,
    posErr              = -40,
    mFulErr             = -41,
    tmfoErr             = -42,
    fnfErr              = -43,
    wPrErr              = -44,
    fLckdErr            = -45,
    vLckdErr            = -46,
    fBsyErr             = -47,
    dupFNErr            = -48,
    opWrErr             = -49,
    paramErr            = -50,
    rfNumErr            = -51,
    gfpErr              = -52,
    volOffLinErr        = -53,
    permErr             = -54,
    volOnLinErr         = -55,
    nsDrvErr            = -56,
    noMacDskErr         = -57,
    extFSErr            = -58,
    fsRnErr             = -59,
    badMDBErr           = -60,
    wrPermErr           = -61,

    memROZWarn          = -99,
    memROZError         = -99,
    memROZErr           = -99,
    memFullErr          = -108,
    nilHandleErr        = -109,
    memAdrErr           = -110,
    memWZErr            = -111,
    memPurErr           = -112,
    memAZErr            = -113,
    memPCErr            = -114,
    memBCErr            = -115,
    memSCErr            = -116,
    memLockedErr        = -117,

    dirNFErr            = -120,
    tmwdoErr            = -121,
    badMovErr           = -122,
    wrgVolTypErr        = -123,
    volGoneErr          = -124,
    fsDSIntErr          = -127,

    userCanceledErr     = -128,

    badExtResource      = -185,
    CantDecompress      = -186,
    resourceInMemory    = -188,
    writingPastEnd      = -189,
    inputOutOfBounds    = -190,
    resNotFound         = -192,
    resFNotFound        = -193,
    addResFailed        = -194,
    addRefFailed        = -195,
    rmvResFailed        = -196,
    rmvRefFailed        = -197,
    resAttrErr          = -198,
    mapReadErr          = -199,

    notEnoughHardwareErr    = -201,
    queueFull               = -203,
    resProblem              = -204,
    badChannel              = -205,
    badFormat               = -206,
    notEnoughBufferSpace    = -207,
    badFileFormat           = -208,
    channelBusy             = -209,
    buffersTooSmall         = -210,
    siInvalidCompression    = -223,
};

/*=============================================================================
 * SCRIPT MANAGER ENUMS
 *============================================================================*/

enum EScriptManager
{
    smSystemScript      = -1,
    smCurrentScript     = -2,
    smAllScripts        = -3,

    smRoman             = 0,

    langEnglish         = 0,
    langFrench          = 1,
    langGerman          = 2,
    langItalian         = 3,
    langDutch           = 4,
    langSwedish         = 5,
    langSpanish         = 6,
    langDanish          = 7,
    langPortuguese      = 8,
    langNorwegian       = 9,
};

/*=============================================================================
 * EVENT ENUMS
 *============================================================================*/

enum EEvents
{
    everyEvent = ~0
};

/*=============================================================================
 * MEMORY ENUMS
 *============================================================================*/

enum EMemory
{
    maxSize = 0x7FFFFFF0
};

/*=============================================================================
 * RESOURCE TYPE ENUMS
 *============================================================================*/

enum EResTypes
{
    rAliasType = 'alis',
};

/*=============================================================================
 * SOUND MANAGER ENUMS
 *============================================================================*/

enum ESndPitch
{
    kMiddleC = 60L,
};

enum ESndSynth
{
    squareWaveSynth = 1,
    waveTableSynth  = 3,
    sampledSynth    = 5
};

enum ESndInit
{
    initChanLeft        = 0x0002,
    initChanRight       = 0x0003,
    initMono            = 0x0080,
    initStereo          = 0x00C0,
    initMACE3           = 0x0300,
    initMACE6           = 0x0400,
    initNoInterp        = 0x0004,
    initNoDrop          = 0x0008,
};

enum ESndVolume
{
    kFullVolume = 0x0100,
    kNoVolume   = 0,
};

enum ESndCmds
{
    nullCmd                 = 0,
    initCmd                 = 1,
    freeCmd                 = 2,
    quietCmd                = 3,
    flushCmd                = 4,
    reInitCmd               = 5,
    waitCmd                 = 10,
    pauseCmd                = 11,
    resumeCmd               = 12,
    callBackCmd             = 13,
    syncCmd                 = 14,
    availableCmd            = 24,
    versionCmd              = 25,
    totalLoadCmd            = 26,
    loadCmd                 = 27,
    freqDurationCmd         = 40,
    restCmd                 = 41,
    freqCmd                 = 42,
    ampCmd                  = 43,
    timbreCmd               = 44,
    getAmpCmd               = 45,
    volumeCmd               = 46,
    getVolumeCmd            = 47,
    clockComponentCmd       = 50,
    getClockComponentCmd    = 51,
    scheduledSoundCmd       = 52,
    linkSoundComponentsCmd  = 53,
    waveTableCmd            = 60,
    phaseCmd                = 61,
    soundCmd                = 80,
    bufferCmd               = 81,
    rateCmd                 = 82,
    continueCmd             = 83,
    doubleBufferCmd         = 84,
    getRateCmd              = 85,
    rateMultiplierCmd       = 86,
    getRateMultiplierCmd    = 87,
    sizeCmd                 = 90,
    convertCmd              = 91,
    
    pommeSetLoopCmd         = 0x7001,
    pommePausePlaybackCmd   = 0x7002,
    pommeResumePlaybackCmd  = 0x7003,
};

/*=============================================================================
 * KEYBOARD ENUMS
 *============================================================================*/

enum
{
    kVK_ANSI_A                    = 0x00,
    kVK_ANSI_S                    = 0x01,
    kVK_ANSI_D                    = 0x02,
    kVK_ANSI_F                    = 0x03,
    kVK_ANSI_H                    = 0x04,
    kVK_ANSI_G                    = 0x05,
    kVK_ANSI_Z                    = 0x06,
    kVK_ANSI_X                    = 0x07,
    kVK_ANSI_C                    = 0x08,
    kVK_ANSI_V                    = 0x09,
    kVK_ANSI_B                    = 0x0B,
    kVK_ANSI_Q                    = 0x0C,
    kVK_ANSI_W                    = 0x0D,
    kVK_ANSI_E                    = 0x0E,
    kVK_ANSI_R                    = 0x0F,
    kVK_ANSI_Y                    = 0x10,
    kVK_ANSI_T                    = 0x11,
    kVK_ANSI_1                    = 0x12,
    kVK_ANSI_2                    = 0x13,
    kVK_ANSI_3                    = 0x14,
    kVK_ANSI_4                    = 0x15,
    kVK_ANSI_6                    = 0x16,
    kVK_ANSI_5                    = 0x17,
    kVK_ANSI_Equal                = 0x18,
    kVK_ANSI_9                    = 0x19,
    kVK_ANSI_7                    = 0x1A,
    kVK_ANSI_Minus                = 0x1B,
    kVK_ANSI_8                    = 0x1C,
    kVK_ANSI_0                    = 0x1D,
    kVK_ANSI_RightBracket         = 0x1E,
    kVK_ANSI_O                    = 0x1F,
    kVK_ANSI_U                    = 0x20,
    kVK_ANSI_LeftBracket          = 0x21,
    kVK_ANSI_I                    = 0x22,
    kVK_ANSI_P                    = 0x23,
    kVK_ANSI_L                    = 0x25,
    kVK_ANSI_J                    = 0x26,
    kVK_ANSI_Quote                = 0x27,
    kVK_ANSI_K                    = 0x28,
    kVK_ANSI_Semicolon            = 0x29,
    kVK_ANSI_Backslash            = 0x2A,
    kVK_ANSI_Comma                = 0x2B,
    kVK_ANSI_Slash                = 0x2C,
    kVK_ANSI_N                    = 0x2D,
    kVK_ANSI_M                    = 0x2E,
    kVK_ANSI_Period               = 0x2F,
    kVK_ANSI_Grave                = 0x32,
    kVK_ANSI_KeypadDecimal        = 0x41,
    kVK_ANSI_KeypadMultiply       = 0x43,
    kVK_ANSI_KeypadPlus           = 0x45,
    kVK_ANSI_KeypadClear          = 0x47,
    kVK_ANSI_KeypadDivide         = 0x4B,
    kVK_ANSI_KeypadEnter          = 0x4C,
    kVK_ANSI_KeypadMinus          = 0x4E,
    kVK_ANSI_KeypadEquals         = 0x51,
    kVK_ANSI_Keypad0              = 0x52,
    kVK_ANSI_Keypad1              = 0x53,
    kVK_ANSI_Keypad2              = 0x54,
    kVK_ANSI_Keypad3              = 0x55,
    kVK_ANSI_Keypad4              = 0x56,
    kVK_ANSI_Keypad5              = 0x57,
    kVK_ANSI_Keypad6              = 0x58,
    kVK_ANSI_Keypad7              = 0x59,
    kVK_ANSI_Keypad8              = 0x5B,
    kVK_ANSI_Keypad9              = 0x5C
};

enum
{
    kVK_Return                    = 0x24,
    kVK_Tab                       = 0x30,
    kVK_Space                     = 0x31,
    kVK_Delete                    = 0x33,
    kVK_Escape                    = 0x35,
    kVK_Command                   = 0x37,
    kVK_Shift                     = 0x38,
    kVK_CapsLock                  = 0x39,
    kVK_Option                    = 0x3A,
    kVK_Control                   = 0x3B,
    kVK_RightShift                = 0x3C,
    kVK_RightOption               = 0x3D,
    kVK_RightControl              = 0x3E,
    kVK_Function                  = 0x3F,
    kVK_F17                       = 0x40,
    kVK_VolumeUp                  = 0x48,
    kVK_VolumeDown                = 0x49,
    kVK_Mute                      = 0x4A,
    kVK_F18                       = 0x4F,
    kVK_F19                       = 0x50,
    kVK_F20                       = 0x5A,
    kVK_F5                        = 0x60,
    kVK_F6                        = 0x61,
    kVK_F7                        = 0x62,
    kVK_F3                        = 0x63,
    kVK_F8                        = 0x64,
    kVK_F9                        = 0x65,
    kVK_F11                       = 0x67,
    kVK_F13                       = 0x69,
    kVK_F16                       = 0x6A,
    kVK_F14                       = 0x6B,
    kVK_F10                       = 0x6D,
    kVK_F12                       = 0x6F,
    kVK_F15                       = 0x71,
    kVK_Help                      = 0x72,
    kVK_Home                      = 0x73,
    kVK_PageUp                    = 0x74,
    kVK_ForwardDelete             = 0x75,
    kVK_F4                        = 0x76,
    kVK_End                       = 0x77,
    kVK_F2                        = 0x78,
    kVK_PageDown                  = 0x79,
    kVK_F1                        = 0x7A,
    kVK_LeftArrow                 = 0x7B,
    kVK_RightArrow                = 0x7C,
    kVK_DownArrow                 = 0x7D,
    kVK_UpArrow                   = 0x7E
};

/*=============================================================================
 * QUICKDRAW 2D ENUMS
 *============================================================================*/

enum
{
    whiteColor      = 30,
    blackColor      = 33,
    yellowColor     = 69,
    magentaColor    = 137,
    redColor        = 205,
    cyanColor       = 273,
    greenColor      = 341,
    blueColor       = 409,
};

enum
{
    srcCopy             = 0,
    srcOr               = 1,
    srcXor              = 2,
    srcBic              = 3,
    notSrcCopy          = 4,
    notSrcOr            = 5,
    notSrcXor           = 6,
    notSrcBic           = 7,
    patCopy             = 8,
    patOr               = 9,
    patXor              = 10,
    patBic              = 11,
    notPatCopy          = 12,
    notPatOr            = 13,
    notPatXor           = 14,
    notPatBic           = 15,
    grayishTextOr       = 49,
    hilitetransfermode  = 50,
    hilite              = 50,
    blend               = 32,
    addPin              = 33,
    addOver             = 34,
    subPin              = 35,
    addMax              = 37,
    adMax               = 37,
    subOver             = 38,
    adMin               = 39,
    ditherCopy          = 64,
    transparent         = 36
};

enum
{
    pmCourteous     = 0x0000,
    pmTolerant      = 0x0002,
    pmAnimated      = 0x0004,
    pmExplicit      = 0x0008,
    pmWhite         = 0x0010,
    pmBlack         = 0x0020,
    pmInhibitG2     = 0x0100,
    pmInhibitC2     = 0x0200,
    pmInhibitG4     = 0x0400,
    pmInhibitC4     = 0x0800,
    pmInhibitG8     = 0x1000,
    pmInhibitC8     = 0x2000,
};

#endif /* __MACERRORS__ not defined */
