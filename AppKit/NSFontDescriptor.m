/* Copyright (c) 2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <AppKit/NSFontDescriptor.h>
#import <AppKit/NSRaise.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>

NSFontDescriptorAttributeName const NSFontFamilyAttribute =
        @"NSFontFamilyAttribute";
NSFontDescriptorAttributeName const NSFontNameAttribute =
        @"NSFontNameAttribute";
NSFontDescriptorAttributeName const NSFontFaceAttribute =
        @"NSFontFaceAttribute";
NSFontDescriptorAttributeName const NSFontSizeAttribute =
        @"NSFontSizeAttribute";
NSFontDescriptorAttributeName const NSFontVisibleNameAttribute =
        @"NSFontVisibleNameAttribute";
NSFontDescriptorAttributeName const NSFontMatrixAttribute =
        @"NSFontMatrixAttribute";
NSFontDescriptorAttributeName const NSFontVariationAttribute =
        @"NSCTFontVariationAttribute";
NSFontDescriptorAttributeName const NSFontCharacterSetAttribute =
        @"NSFontCharacterSetAttribute";
NSFontDescriptorAttributeName const NSFontCascadeListAttribute =
        @"NSCTFontCascadeListAttribute";
NSFontDescriptorAttributeName const NSFontTraitsAttribute =
        @"NSFontTraitsAttribute";
NSFontDescriptorAttributeName const NSFontFixedAdvanceAttribute =
        @"NSFontFixedAdvanceAttribute";
NSFontDescriptorAttributeName const NSFontFeatureSettingsAttribute =
        @"NSCTFontFeatureSettingsAttribute";

NSFontDescriptorFeatureKey const NSFontFeatureSelectorIdentifierKey =
        @"CTFeatureSelectorIdentifier";
NSFontDescriptorFeatureKey const NSFontFeatureTypeIdentifierKey =
        @"CTFeatureTypeIdentifier";

NSFontDescriptorTraitKey const NSFontSymbolicTrait = @"NSFontSymbolicTrait";
NSFontDescriptorTraitKey const NSFontWeightTrait = @"NSFontWeightTrait";
NSFontDescriptorTraitKey const NSFontWidthTrait = @"NSFontWidthTrait";
NSFontDescriptorTraitKey const NSFontSlantTrait = @"NSFontSlantTrait";

const NSFontWeight NSFontWeightThin = 0xbfe3333340000000;
const NSFontWeight NSFontWeightLight = 0xbfd99999a0000000;
const NSFontWeight NSFontWeightUltraLight = 0xbfe99999a0000000;
const NSFontWeight NSFontWeightBlack = 0x3fe3d70a40000000;
const NSFontWeight NSFontWeightHeavy = 0x3fe1eb8520000000;
const NSFontWeight NSFontWeightSemibold = 0x3fd3333340000000;
const NSFontWeight NSFontWeightBold = 0x3fd99999a0000000;
const NSFontWeight NSFontWeightMedium = 0x3fcd70a3e0000000;
const NSFontWeight NSFontWeightRegular = 0x0000000000000000;

@implementation NSFontDescriptor : NSObject

- initWithFontAttributes: (NSDictionary *) attributes {
    _attributes = [attributes copy];
    return self;
}

- (void) dealloc {
    [_attributes release];
    [super dealloc];
}

- copyWithZone: (NSZone *) zone {
    return [self retain];
}

- (NSString *) description {
    return [NSString stringWithFormat: @"<%@ %@>", [self class], _attributes];
}

+ fontDescriptorWithFontAttributes: (NSDictionary *) attributes {
    return [[[self allocWithZone: NULL] initWithFontAttributes: attributes]
            autorelease];
}

+ fontDescriptorWithName: (NSString *) name
                  matrix: (NSAffineTransform *) matrix
{
    NSDictionary *attributes = [NSDictionary
            dictionaryWithObjectsAndKeys: name, NSFontNameAttribute, matrix,
                                          NSFontMatrixAttribute, nil];
    return [[[self allocWithZone: NULL] initWithFontAttributes: attributes]
            autorelease];
}

+ fontDescriptorWithName: (NSString *) name size: (CGFloat) pointSize {
    NSDictionary *attributes = [NSDictionary
            dictionaryWithObjectsAndKeys: name, NSFontNameAttribute,
                                          [[NSNumber numberWithFloat: pointSize]
                                                  stringValue],
                                          NSFontSizeAttribute, nil];

    return [[[self allocWithZone: NULL] initWithFontAttributes: attributes]
            autorelease];
}

- (NSDictionary *) fontAttributes {
    return _attributes;
}

- objectForKey: (NSString *) attributeKey {
    return [_attributes objectForKey: attributeKey];
}

- (CGFloat) pointSize {
    return [[_attributes objectForKey: NSFontSizeAttribute] floatValue];
}

- (NSAffineTransform *) matrix {
    return [_attributes objectForKey: NSFontMatrixAttribute];
}

- (NSFontSymbolicTraits) symbolicTraits {
    NSDictionary *fontTraits =
            [_attributes objectForKey: NSFontTraitsAttribute];
    return [[fontTraits objectForKey: NSFontSymbolicTrait] unsignedIntValue];
}

- (NSFontDescriptor *) fontDescriptorByAddingAttributes:
        (NSDictionary *) attributes
{
    NSMutableDictionary *copy =
            [NSMutableDictionary dictionaryWithDictionary: _attributes];

    [copy addEntriesFromDictionary: attributes];

    return [[self class] fontDescriptorWithFontAttributes: copy];
}

- (NSFontDescriptor *) fontDescriptorWithFace: (NSString *) face {
    NSMutableDictionary *copy =
            [NSMutableDictionary dictionaryWithDictionary: _attributes];

    [copy setObject: face forKey: NSFontFaceAttribute];

    return [[self class] fontDescriptorWithFontAttributes: copy];
}

- (NSFontDescriptor *) fontDescriptorWithFamily: (NSString *) family {
    NSMutableDictionary *copy =
            [NSMutableDictionary dictionaryWithDictionary: _attributes];

    [copy setObject: family forKey: NSFontFamilyAttribute];

    return [[self class] fontDescriptorWithFontAttributes: copy];
}

- (NSFontDescriptor *) fontDescriptorWithMatrix: (NSAffineTransform *) matrix {
    NSMutableDictionary *copy =
            [NSMutableDictionary dictionaryWithDictionary: _attributes];

    [copy setObject: matrix forKey: NSFontMatrixAttribute];

    return [[self class] fontDescriptorWithFontAttributes: copy];
}

- (NSFontDescriptor *) fontDescriptorWithSize: (CGFloat) pointSize {
    NSMutableDictionary *copy =
            [NSMutableDictionary dictionaryWithDictionary: _attributes];

    [copy setObject: [NSNumber numberWithFloat: pointSize]
             forKey: NSFontSizeAttribute];

    return [[self class] fontDescriptorWithFontAttributes: copy];
}

- (NSFontDescriptor *) fontDescriptorWithSymbolicTraits:
        (NSFontSymbolicTraits) traits
{
    NSMutableDictionary *copy =
            [NSMutableDictionary dictionaryWithDictionary: _attributes];

    NSMutableDictionary *traitsCopy = [NSMutableDictionary
            dictionaryWithDictionary:
                    [_attributes objectForKey: NSFontTraitsAttribute]];
    [traitsCopy setObject: [NSNumber numberWithUnsignedInt: traits]
                   forKey: NSFontSymbolicTrait];
    [copy setObject: traitsCopy forKey: NSFontTraitsAttribute];

    return [[self class] fontDescriptorWithFontAttributes: copy];
}

- (NSArray *) matchingFontDescriptorsWithMandatoryKeys: (NSSet *) keys {
    NSUnimplementedMethod();
    return nil;
}

- (NSFontDescriptor *) matchingFontDescriptorWithMandatoryKeys: (NSSet *) keys {
    NSUnimplementedMethod();
    return nil;
}

@end
