#import <CoreText/CTFontDescriptor.h>

#include <stdio.h>

const CFStringRef kCTFontURLAttribute = @"NSCTFontFileURLAttribute";
const CFStringRef kCTFontNameAttribute = @"NSFontNameAttribute";
const CFStringRef kCTFontDisplayNameAttribute = @"NSFontVisibleNameAttribute";
const CFStringRef kCTFontFamilyNameAttribute = @"NSFontFamilyAttribute";
const CFStringRef kCTFontStyleNameAttribute = @"NSFontFaceAttribute";
const CFStringRef kCTFontTraitsAttribute = @"NSCTFontTraitsAttribute";
const CFStringRef kCTFontVariationAttribute = @"NSCTFontVariationAttribute";
const CFStringRef kCTFontSizeAttribute = @"NSFontSizeAttribute";
const CFStringRef kCTFontMatrixAttribute = @"NSCTFontMatrixAttribute";
const CFStringRef kCTFontCascadeListAttribute = @"NSCTFontCascadeListAttribute";
const CFStringRef kCTFontCharacterSetAttribute = @"NSCTFontCharacterSetAttribute";
const CFStringRef kCTFontLanguagesAttribute = @"NSCTFontLanguagesAttribute";
const CFStringRef kCTFontBaselineAdjustAttribute = @"NSCTFontBaselineAdjustAttribute";
const CFStringRef kCTFontMacintoshEncodingsAttribute = @"NSCTFontMacintoshEncodingsAttribute";
const CFStringRef kCTFontFeaturesAttribute = @"NSCTFontFeaturesAttribute";
const CFStringRef kCTFontFeatureSettingsAttribute = @"NSCTFontFeatureSettingsAttribute";
const CFStringRef kCTFontFixedAdvanceAttribute = @"NSCTFontFixedAdvanceAttribute";
const CFStringRef kCTFontOrientationAttribute = @"NSCTFontOrientationAttribute";
const CFStringRef kCTFontEnabledAttribute = @"NSCTFontEnabledAttribute";
const CFStringRef kCTFontFormatAttribute = @"NSCTFontFormatAttribute";
const CFStringRef kCTFontRegistrationScopeAttribute = @"NSCTFontRegistrationScopeAttribute";
const CFStringRef kCTFontPriorityAttribute = @"NSCTFontPriorityAttribute";

CFTypeRef CTFontDescriptorCopyAttribute(CTFontDescriptorRef descriptor, CFStringRef attribute)
{
    printf("STUB %s\n", __PRETTY_FUNCTION__);
    return nil;
}
