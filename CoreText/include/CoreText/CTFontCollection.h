#import <CoreFoundation/CoreFoundation.h>
#import <CoreText/CoreTextExport.h>

typedef struct __CTFontCollection* CTFontCollectionRef;

CORETEXT_EXPORT CTFontCollectionRef CTFontCollectionCreateFromAvailableFonts(CFDictionaryRef options);
CORETEXT_EXPORT CFArrayRef CTFontCollectionCreateMatchingFontDescriptors(CTFontCollectionRef collection);
CORETEXT_EXPORT CTFontCollectionRef CTFontCollectionCreateWithFontDescriptors(CFArrayRef queryDescriptors, CFDictionaryRef options);
