/*
 *  CarbonCompat.m
 *  MAFFia
 *
 *  Implementation of Carbon compatibility functions.
 */

#import "CarbonCompat.h"
#include "Pomme.h"
#include <string.h>

// ============================================================================
// GetNamedResource - Find resource by name
// ============================================================================

Handle GetNamedResource(ResType type, const unsigned char* pascalName) {
    // Convert Pascal string to C string
    char cName[256];
    int len = pascalName[0];
    memcpy(cName, pascalName + 1, len);
    cName[len] = '\0';
    
    // Iterate through resources of this type to find by name
    short count = Count1Resources(type);
    for (short i = 1; i <= count; i++) {
        Handle h = Get1IndResource(type, i);
        if (h) {
            short id;
            ResType foundType;
            char foundName[256];
            GetResInfo(h, &id, &foundType, foundName);
            
            // foundName is a Pascal string from Pomme
            int foundLen = (unsigned char)foundName[0];
            
            // Compare names (case-insensitive)
            if (foundLen == len) {
                bool match = true;
                for (int j = 0; j < len; j++) {
                    char c1 = cName[j];
                    char c2 = foundName[j + 1];
                    // Simple case-insensitive compare
                    if (c1 >= 'A' && c1 <= 'Z') c1 += 32;
                    if (c2 >= 'A' && c2 <= 'Z') c2 += 32;
                    if (c1 != c2) {
                        match = false;
                        break;
                    }
                }
                if (match) {
                    return h;
                }
            }
            ReleaseResource(h);
        }
    }
    return NULL;
}
