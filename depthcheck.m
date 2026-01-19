/*
 *  depthcheck.c
 *  MAFFia
 *
 *  Created by William Reade on Tue Nov 05 2002.
 *  Copyright (c) 2002 William Reade. All rights reserved.
 *
 *  Updated 2026: Display depth switching is obsolete on modern macOS.
 *  Modern Macs always run in millions of colors (32-bit).
 *  These functions are now stubs for compatibility.
 */

#include "depthcheck.h"
#include "mafftypes.h"

extern GlobalStuff *g;

void CheckDepth(void)
{
    // Display depth switching is obsolete on modern macOS
    // Always assume we're running at the correct depth
    g->depthChanged = false;
    g->askSwitchDepthPreferences = false;
    g->wasDepth = 32;  // Modern Macs use 32-bit color
}

void ChangeDepth(void)
{
    // No-op on modern macOS
}

void ChangeDepthBack(void)
{
    // No-op on modern macOS
}

