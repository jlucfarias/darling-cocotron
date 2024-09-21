#import <CoreText/CTFontDescriptor.h>

#include <stdio.h>

// const CFStringRef kCTFontURLAttribute = @"kCTFontURLAttribute";
// const CFStringRef kCTFontNameAttribute = @"kCTFontNameAttribute";
// const CFStringRef kCTFontDisplayNameAttribute =
// @"kCTFontDisplayNameAttribute"; const CFStringRef kCTFontFamilyNameAttribute
// = @"kCTFontFamilyNameAttribute"; const CFStringRef kCTFontStyleNameAttribute
// = @"kCTFontStyleNameAttribute"; const CFStringRef kCTFontTraitsAttribute =
// @"kCTFontTraitsAttribute"; const CFStringRef kCTFontVariationAttribute =
// @"kCTFontVariationAttribute"; const CFStringRef kCTFontSizeAttribute =
// @"kCTFontSizeAttribute"; const CFStringRef kCTFontMatrixAttribute =
// @"kCTFontMatrixAttribute"; const CFStringRef kCTFontCascadeListAttribute =
// @"kCTFontCascadeListAttribute"; const CFStringRef
// kCTFontCharacterSetAttribute = @"kCTFontCharacterSetAttribute"; const
// CFStringRef kCTFontLanguagesAttribute = @"kCTFontLanguagesAttribute"; const
// CFStringRef kCTFontBaselineAdjustAttribute =
// @"kCTFontBaselineAdjustAttribute"; const CFStringRef
// kCTFontMacintoshEncodingsAttribute = @"kCTFontMacintoshEncodingsAttribute";
const CFStringRef kCTFontFeaturesAttribute = @"kCTFontFeaturesAttribute";
// const CFStringRef kCTFontFeatureSettingsAttribute =
// @"kCTFontFeatureSettingsAttribute"; const CFStringRef
// kCTFontFixedAdvanceAttribute = @"kCTFontFixedAdvanceAttribute"; const
// CFStringRef kCTFontOrientationAttribute = @"kCTFontOrientationAttribute";
// const CFStringRef kCTFontEnabledAttribute = @"kCTFontEnabledAttribute";
// const CFStringRef kCTFontFormatAttribute = @"kCTFontFormatAttribute";
// const CFStringRef kCTFontRegistrationScopeAttribute =
// @"kCTFontRegistrationScopeAttribute"; const CFStringRef
// kCTFontPriorityAttribute = @"kCTFontPriorityAttribute";

CFTypeRef CTFontDescriptorCopyAttribute(CTFontDescriptorRef descriptor,
                                        CFStringRef attribute)
{
    printf("STUB %s\n", __PRETTY_FUNCTION__);
    return nil;
}
