/* Copyright (c) 2006-2007 Christopher J. W. Lloyd <cjwl@objc.net>

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

#import <AppKit/NSPrintInfo.h>
#import <ApplicationServices/ApplicationServices.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSString.h>
#import <Foundation/NSThread.h>
#import <Foundation/NSValue.h>

NSPrintInfoAttributeKey const NSPrintPaperName = @"NSPrintPaperName";
NSPrintInfoAttributeKey const NSPrintPaperSize = @"NSPrintPaperSize";
NSPrintInfoAttributeKey const NSPrintOrientation = @"NSPrintOrientation";

NSPrintInfoAttributeKey const NSPrintLeftMargin = @"NSPrintLeftMargin";
NSPrintInfoAttributeKey const NSPrintRightMargin = @"NSPrintRightMargin";
NSPrintInfoAttributeKey const NSPrintTopMargin = @"NSPrintTopMargin";
NSPrintInfoAttributeKey const NSPrintBottomMargin = @"NSPrintBottomMargin";
NSPrintInfoAttributeKey const NSPrintHorizontallyCentered =
        @"NSPrintHorizontallyCentered";
NSPrintInfoAttributeKey const NSPrintVerticallyCentered =
        @"NSPrintVerticallyCentered";
NSPrintInfoAttributeKey const NSPrintHorizontalPagination =
        @"NSPrintHorizontalPagination";
NSPrintInfoAttributeKey const NSPrintVerticalPagination =
        @"NSPrintVerticalPagination";

NSPrintInfoAttributeKey const NSPrintAllPages = @"NSPrintAllPages";
NSPrintInfoAttributeKey const NSPrintCopies = @"NSPrintCopies";
NSPrintInfoAttributeKey const NSPrintDetailedErrorReporting =
        @"NSPrintDetailedErrorReporting";
NSPrintInfoAttributeKey const NSPrintFirstPage = @"NSPrintFirstPage";
NSPrintInfoAttributeKey const NSPrintHeaderAndFooter =
        @"NSPrintHeaderAndFooter";
NSPrintInfoAttributeKey const NSPrintJobDisposition = @"NSPrintJobDisposition";
NSPrintInfoAttributeKey const NSPrintJobSavingURL = @"NSJobSavingURL";
NSPrintInfoAttributeKey const NSPrintLastPage = @"NSPrintLastPage";
NSPrintInfoAttributeKey const NSPrintMustCollate = @"NSPrintMustCollate";
NSPrintInfoAttributeKey const NSPrintPrinter = @"NSPrintPrinter";
NSPrintInfoAttributeKey const NSPrintPrinterName = @"NSPrintPrinterName";
NSPrintInfoAttributeKey const NSPrintSelectionOnly = @"NSPrintSelectionOnly";

NSPrintJobDispositionValue const NSPrintSpoolJob = @"NSPrintSpoolJob";
NSPrintJobDispositionValue const NSPrintPreviewJob = @"NSPrintPreviewJob";
NSPrintJobDispositionValue const NSPrintSaveJob = @"NSPrintSaveJob";
NSPrintJobDispositionValue const NSPrintCancelJob = @"NSPrintCancelJob";

NSString *const NSPrintSavePath = @"NSPrintSavePath";

const NSPrintingPaginationMode NSFitPagination = NSPrintingPaginationModeFit;
const NSPrintingPaginationMode NSAutoPagination =
        NSPrintingPaginationModeAutomatic;
const NSPrintingPaginationMode NSClipPagination = NSPrintingPaginationModeClip;

@implementation NSPrintInfo

+ (NSPrintInfo *) sharedPrintInfo {
    return NSThreadSharedInstance(@"NSPrintInfo");
}

- initWithDictionary: (NSDictionary *) dictionary {
    _attributes = [[NSMutableDictionary alloc] initWithDictionary: dictionary];
    return self;
}

- init {
    NSDictionary *defaults = [NSDictionary
            dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithInt: 1], NSPrintCopies,
                    [NSNumber numberWithBool: YES], NSPrintAllPages,
                    @"US Letter", NSPrintPaperName,
                    [NSValue valueWithSize: NSMakeSize(612, 792)],
                    NSPrintPaperSize, [NSNumber numberWithFloat: 36],
                    NSPrintTopMargin, [NSNumber numberWithFloat: 36],
                    NSPrintLeftMargin, [NSNumber numberWithFloat: 36],
                    NSPrintRightMargin, [NSNumber numberWithFloat: 36],
                    NSPrintBottomMargin,
                    [NSNumber numberWithInt: NSPortraitOrientation],
                    NSPrintOrientation, nil];

    return [self initWithDictionary: defaults];
}

- (void) dealloc {
    [_attributes release];
    [super dealloc];
}

- copyWithZone: (NSZone *) zone {
    NSPrintInfo *copy = NSCopyObject(self, 0, zone);

    copy->_attributes = [_attributes mutableCopy];

    return copy;
}

- (NSMutableDictionary *) dictionary {
    return _attributes;
}

- (NSPrinter *) printer {
    return [_attributes objectForKey: NSPrintPrinter];
}

- (NSString *) jobDisposition {
    return [_attributes objectForKey: NSPrintJobDisposition];
}

- (NSString *) paperName {
    return [_attributes objectForKey: NSPrintPaperName];
}

- (NSSize) paperSize {
    return [[_attributes objectForKey: NSPrintPaperSize] sizeValue];
}

- (NSPrintingOrientation) orientation {
    return [[_attributes objectForKey: NSPrintOrientation] intValue];
}

- (NSPrintingPaginationMode) horizontalPagination {
    return [[_attributes objectForKey: NSPrintHorizontalPagination] intValue];
}

- (NSPrintingPaginationMode) verticalPagination {
    return [[_attributes objectForKey: NSPrintVerticalPagination] intValue];
}

- (CGFloat) topMargin {
    return [[_attributes objectForKey: NSPrintTopMargin] floatValue];
}

- (CGFloat) bottomMargin {
    return [[_attributes objectForKey: NSPrintBottomMargin] floatValue];
}

- (CGFloat) leftMargin {
    return [[_attributes objectForKey: NSPrintLeftMargin] floatValue];
}

- (CGFloat) rightMargin {
    return [[_attributes objectForKey: NSPrintRightMargin] floatValue];
}

- (BOOL) isHorizontallyCentered {
    return [[_attributes objectForKey: NSPrintHorizontallyCentered] boolValue];
}

- (BOOL) isVerticallyCentered {
    return [[_attributes objectForKey: NSPrintVerticallyCentered] boolValue];
}

- (NSString *) localizedPaperName {
    return [self paperName];
}

- (NSRect) imageablePageBounds {
    NSRect result;
    NSValue *imageable = [_attributes objectForKey: @"_imageableRect"];

    if (imageable != nil)
        result = [imageable rectValue];
    else {
        result.origin.x = 0;
        result.origin.y = 0;
        result.size = [self paperSize];
    }

    if ([self orientation] == NSLandscapeOrientation) {
        NSRect portrait = result;

        result.origin.x = portrait.origin.y;
        result.size.width = portrait.size.height;
        result.origin.y = portrait.origin.x;
        result.size.height = portrait.size.width;
    }

    return result;
}

- (void) setPrinter: (NSPrinter *) printer {
    [_attributes setObject: printer forKey: NSPrintPrinter];
}

- (void) setJobDisposition: (NSString *) value {
    [_attributes setObject: value forKey: NSPrintJobDisposition];
}

- (void) setPaperName: (NSString *) value {
    [_attributes setObject: value forKey: NSPrintPaperName];
}

- (void) setPaperSize: (NSSize) value {
    [_attributes setObject: [NSValue valueWithSize: value]
                    forKey: NSPrintPaperSize];
}

- (void) setOrientation: (NSPrintingOrientation) value {
    [_attributes setObject: [NSNumber numberWithInt: value]
                    forKey: NSPrintOrientation];
}

- (void) setHorizontalPagination: (NSPrintingPaginationMode) value {
    [_attributes setObject: [NSNumber numberWithInt: value]
                    forKey: NSPrintHorizontalPagination];
}

- (void) setVerticalPagination: (NSPrintingPaginationMode) value {
    [_attributes setObject: [NSNumber numberWithInt: value]
                    forKey: NSPrintVerticalPagination];
}

- (void) setTopMargin: (CGFloat) value {
    [_attributes setObject: [NSNumber numberWithFloat: value]
                    forKey: NSPrintTopMargin];
}

- (void) setBottomMargin: (CGFloat) value {
    [_attributes setObject: [NSNumber numberWithFloat: value]
                    forKey: NSPrintBottomMargin];
}

- (void) setLeftMargin: (CGFloat) value {
    [_attributes setObject: [NSNumber numberWithFloat: value]
                    forKey: NSPrintLeftMargin];
}

- (void) setRightMargin: (CGFloat) value {
    [_attributes setObject: [NSNumber numberWithFloat: value]
                    forKey: NSPrintRightMargin];
}

- (void) setHorizontallyCentered: (BOOL) value {
    [_attributes setObject: [NSNumber numberWithBool: value]
                    forKey: NSPrintHorizontallyCentered];
}

- (void) setVerticallyCentered: (BOOL) value {
    [_attributes setObject: [NSNumber numberWithBool: value]
                    forKey: NSPrintVerticallyCentered];
}

- (void) setUpPrintOperationDefaultValues {
    // do nothing ?
}

@end
