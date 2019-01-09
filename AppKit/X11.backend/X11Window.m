/* Copyright (c) 2008 Johannes Fortmann
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <AppKit/NSWindow.h>
#import <AppKit/NSPanel.h>
#import <AppKit/NSRaise.h>
#import <QuartzCore/CAWindowOpenGLContext.h>
#import <Foundation/NSProcessInfo.h>
#import <Foundation/NSException.h>
#import <Foundation/NSMutableData.h>
#import <Foundation/NSBundle.h>
#import <Onyx2D/O2Surface.h>
#import <Onyx2D/O2ImageSource.h>
#import <Onyx2D/O2BitmapContext.h>
#import "O2Context_builtin_FT.h"

#import <X11/Xutil.h>
#import "X11Display.h"
#import "X11Window.h"
#import "X11SubWindow.h"

@implementation X11Window

+(Visual*)visual {
   static Visual* ret=NULL;
   
   if(!ret) {
      int visuals_matched, i;
      XVisualInfo match={0};
      Display *dpy=[(X11Display*)[NSDisplay currentDisplay] display];
   
      XVisualInfo *info=XGetVisualInfo(dpy,0, &match, &visuals_matched);
      
      for(i=0; i<visuals_matched; i++) {
         if(info[i].depth == 32 &&
            (info[i].red_mask   == 0xff0000 &&
             info[i].green_mask == 0x00ff00 &&
             info[i].blue_mask  == 0x0000ff)) {
            ret=info[i].visual;
         }
      }
      XFree(info);
      if(!ret)
         ret=DefaultVisual(dpy, DefaultScreen(dpy));
   }

   return ret;
}

static NSData *makeWindowIcon() {
    static NSMutableData *res;

    if (res != nil) return res;

    // Figure out the path.
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *name = [bundle objectForInfoDictionaryKey: @"CFBundleIconFile"];
    if (name == nil || [name length] == 0) return nil;
    NSString *path = [bundle pathForImageResource: name];
    if (path == nil) {
        NSLog(@"Cannot find an icon file named %@", name);
    }
    NSURL *url = [NSURL fileURLWithPath: path];

    O2ImageSource *imageSource = [O2ImageSource newImageSourceWithURL: url options: nil];
    if (imageSource == nil) {
        NSLog(@"Cannot parse the icon");
        return nil;
    }

    res = [[NSMutableData alloc] initWithCapacity: 32 * 32 * 4 + 2];
    O2ColorSpace *colorSpace = O2ColorSpaceCreateDeviceRGB();

    // Go over the images, turning them into the required format
    // and appending them to res.
    for (NSUInteger i = 0; i < [imageSource count]; i++) {

        O2Image *image = [imageSource createImageAtIndex: i options: nil];
        NSUInteger width = O2ImageGetWidth(image);
        NSUInteger height = O2ImageGetHeight(image);

        // Render the image in ARGB.
        O2BitmapContext *context = (O2BitmapContext *) O2BitmapContextCreate(
            NULL, width, height,
            8, width * 4,
            colorSpace,
            kO2ImageAlphaPremultipliedFirst | kO2BitmapByteOrder32Host
        );

        [context drawImage: image inRect: O2RectMake(0, 0, width, height)];
        int *imageData = O2BitmapContextGetData(context);

        // Convert to the format accepted by Xlib.
        NSMutableData *data = [NSMutableData dataWithLength: width * height * sizeof(long)];
        long *dataPtr = (long *) [data mutableBytes];
        int count = width * height;
        for (int i = 0; i < count; i++) {
            dataPtr[i] = imageData[i];
        }

        struct { long w, h; } size = { width, height };
        [res appendBytes: &size length: sizeof(size)];
        [res appendData: data];

        [context release];
        [image release];
    }

    [colorSpace release];
    [imageSource release];

    return res;
}

- (void) setWindowIcon {

    NSData *data = makeWindowIcon();

    if (data == nil) return;

    XChangeProperty(_display, _window,
        XInternAtom(_display, "_NET_WM_ICON", False),
        XInternAtom(_display, "CARDINAL", False),
        32, PropModeReplace,
        [data bytes], [data length] / sizeof(long));
}


-initWithFrame:(O2Rect)frame styleMask:(NSUInteger)styleMask isPanel:(BOOL)isPanel backingType:(NSUInteger)backingType {
   _level=kCGNormalWindowLevel;
   _styleMask = styleMask;
   _backingType=backingType;
   _deviceDictionary=[NSMutableDictionary new];
   _display=[(X11Display*)[NSDisplay currentDisplay] display];
   int s = DefaultScreen(_display);
   _frame=[self transformFrame:frame];
   if(isPanel && styleMask&NSDocModalWindowMask)
    styleMask=NSBorderlessWindowMask;
    // TODO: get rid of these glX calls
   GLint att[] = {
    GLX_RGBA,
    GLX_DOUBLEBUFFER,
    GLX_RED_SIZE, 4,
    GLX_GREEN_SIZE, 4,
    GLX_BLUE_SIZE, 4,
    GLX_DEPTH_SIZE, 4,
    None
   };

      int screen = DefaultScreen(_display);

      if((_visualInfo=glXChooseVisual(_display,screen,att))==NULL){
       NSLog(@"glXChooseVisual failed at %s %d",__FILE__,__LINE__);
      }

      Colormap cmap = XCreateColormap(_display, RootWindow(_display, _visualInfo->screen), _visualInfo->visual, AllocNone);

      if(cmap<0){
       NSLog(@"XCreateColormap failed");
       [self dealloc];
       return nil;
      }

   XSetWindowAttributes xattr;
   unsigned long xattr_mask;
   xattr.override_redirect = styleMask == NSBorderlessWindowMask ? True : False;
   xattr_mask = CWOverrideRedirect|CWColormap;
      xattr.colormap=cmap;

   _window = XCreateWindow(_display, DefaultRootWindow(_display),
                              _frame.origin.x, _frame.origin.y, _frame.size.width, _frame.size.height,
                              0, (_visualInfo==NULL)?CopyFromParent:_visualInfo->depth, InputOutput,
                              (_visualInfo==NULL)?CopyFromParent:_visualInfo->visual,
                              xattr_mask, &xattr);

   [self syncDelegateProperties];

   Atom atm=XInternAtom(_display, "WM_DELETE_WINDOW", False);
   XSetWMProtocols(_display, _window, &atm , 1);

   const char *name = [[[NSProcessInfo processInfo] processName] UTF8String];

   XClassHint classHint = {
       .res_name = (char *) name,
       .res_class = (char *) name
   };
   XSetClassHint(_display, _window, &classHint);

   XSetWindowBackgroundPixmap(_display, _window, None);

   _cglWindow = CGLGetWindow(_window);

   [(X11Display*)[NSDisplay currentDisplay] setWindow:self forID:_window];

   if(styleMask == NSBorderlessWindowMask){
     [[self class] removeDecorationForWindow:_window onDisplay:_display];
    }

   [self setWindowIcon];

   return self;
}

-(void)dealloc {
   [self invalidate];
   [_deviceDictionary release];
   [super dealloc];
}

- (NSUInteger) styleMask {
    return _styleMask;
}

- (void) setStyleMask: (NSUInteger) mask {
    _styleMask = mask;
}

+(void)removeDecorationForWindow:(Window)w onDisplay:(Display*)dpy
{
   return;
   struct {
      unsigned long flags;
      unsigned long functions;
      unsigned long decorations;
      long input_mode;
      unsigned long status;
   } hints = {
      2, 0, 0, 0, 0,
   };
   XChangeProperty (dpy, w,
                    XInternAtom (dpy, "_MOTIF_WM_HINTS", False),
                    XInternAtom (dpy, "_MOTIF_WM_HINTS", False),
                    32, PropModeReplace,
                    (const unsigned char *) &hints,
                    sizeof (hints) / sizeof (long));
}

-(void)ensureMapped {
   if(!_mapped){
      XMapWindow(_display, _window);
      _mapped=YES;
   }
}


-(void)setDelegate:delegate {
   _delegate=delegate;
   [self syncDelegateProperties];
}

-delegate {
   return _delegate;
}

- (void) syncDelegateProperties {
    long mask = KeyPressMask | KeyReleaseMask |
        ExposureMask | StructureNotifyMask |
        ButtonPressMask | ButtonReleaseMask | ButtonMotionMask |
        VisibilityChangeMask | FocusChangeMask | SubstructureRedirectMask;

    if ([_delegate acceptsMouseMovedEvents]) {
        mask |= PointerMotionMask;
    }
    XSelectInput(_display, _window, mask);

    // TODO: background color
}

-(void) invalidate {
    // This is essentially dealloc; we release our contexts
    // and windows, but unlike dealloc, this method can be called
    // several times, so set everything to nil/NULL/0.
    [_context release];
    _context = nil;

    [_delegate platformWindowDidInvalidateCGContext: self];
    _delegate = nil;

    [_caContext release];
    _caContext = nil;

    if (_cglContext != NULL) {
        CGLReleaseContext(_cglContext);
        _cglContext = NULL;
    }
    if (_cglWindow != NULL) {
        CGLDestroyWindow(_cglWindow);
        _cglWindow = NULL;
    }

   if(_window) {
      [(X11Display*)[NSDisplay currentDisplay] setWindow:nil forID:_window];
      XDestroyWindow(_display, _window);
      _window=0;
   }
}

-(Window)windowHandle {
   return _window;
}

-(O2Context *)createCGContextIfNeeded {
   if(_context == nil) {
       O2ColorSpaceRef colorSpace = O2ColorSpaceCreateDeviceRGB();
       O2Surface *surface = [[O2Surface alloc]
                             initWithBytes: NULL
                             width: _frame.size.width
                             height: _frame.size.height
                             bitsPerComponent: 8
                             bytesPerRow: 0
                             colorSpace: colorSpace
                             bitmapInfo: kO2ImageAlphaPremultipliedFirst | kO2BitmapByteOrder32Little];
       O2ColorSpaceRelease(colorSpace);
       _context = [[O2Context_builtin_FT alloc] initWithSurface: surface flipped: NO];
   }
   return _context;
}

-(O2Context *)cgContext {
    return [self createCGContextIfNeeded];
}

-(void)invalidateContextWithNewSize:(NSSize) size forceRebuild:(BOOL) forceRebuild {
   if (!NSEqualSizes(_frame.size, size) || forceRebuild) {
    _frame.size=size;
    if(![_context resizeWithNewSize: size]){
     [_context release];
     _context=nil;
     [_delegate platformWindowDidInvalidateCGContext: self];
    }
   }
}

-(void)invalidateContextWithNewSize:(NSSize)size {
   [self invalidateContextWithNewSize:size forceRebuild:NO];
}

-(void)setTitle:(NSString *)title {
   XTextProperty prop;
   const char* text=[title cString];
   XStringListToTextProperty((char**)&text, 1, &prop);
   XSetWMName(_display, _window, &prop);
}

-(void)setFrame:(O2Rect)frame {
   frame=[self transformFrame:frame];
   XMoveResizeWindow(_display, _window, frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
   [self invalidateContextWithNewSize:frame.size];
   _frame = frame;
}

-(void)setLevel:(int)value {
    _level=value;
}

-(void)showWindowForAppActivation:(O2Rect)frame {
   NSUnimplementedMethod();
}

-(void)hideWindowForAppDeactivation:(O2Rect)frame {
   NSUnimplementedMethod();
}

-(void)hideWindow {
   XUnmapWindow(_display, _window);
   _mapped=NO;
}

-(void)placeAboveWindow:(NSInteger)otherNumber {
   X11Window *other=[X11Window windowWithWindowNumber:otherNumber];
   [self ensureMapped];

   if(!other) {
      XRaiseWindow(_display, _window);
   }
   else {
      Window w[2]={_window, other->_window};
      XRestackWindows(_display, w, 1);
   }
}

-(void)placeBelowWindow:(NSInteger)otherNumber {
   X11Window *other=[X11Window windowWithWindowNumber:otherNumber];
   [self ensureMapped];

   if(!other) {
      XLowerWindow(_display, _window);
   }
   else {
      Window w[2]={other->_window, _window};
      XRestackWindows(_display, w, 1);
   }
}

-(void)makeKey {
   [self ensureMapped];
   XRaiseWindow(_display, _window);
}

-(void)makeMain {
}

-(void)captureEvents {
   // FIXME: find out what this is supposed to do
}

-(void)miniaturize {
   NSUnimplementedMethod();

}

-(void)deminiaturize {
   NSUnimplementedMethod();
}

-(BOOL)isMiniaturized {
   return NO;
}

-(void) createCGLContextObjIfNeeded {
   if (_cglContext==NULL) {
    CGLError error;

    if ((error = CGLCreateContext(NULL, NULL, &_cglContext)) != kCGLNoError) {
       NSLog(@"CGLCreateContext failed at %s %d with error %d", __FILE__ , __LINE__, error);

       [NSException raise: NSGenericException
                   format: @"Failed to create GL context, CGL error %d", error];
    }
    if ((error = CGLContextMakeCurrentAndAttachToWindow(_cglContext, _cglWindow)) != kCGLNoError)
     NSLog(@"CGLContextMakeCurrentAndAttachToWindow failed with error %d", error);
   }
   if (_cglContext != nil && _caContext == nil){
    _caContext = [[CAWindowOpenGLContext alloc] initWithCGLContext:_cglContext];
   }
}

-(void) openGLFlushBuffer {
   CGLError error;

   [self createCGLContextObjIfNeeded];
   if (_caContext == nil)
    return;

   O2Surface *surface = [_context surface];
   size_t width = O2ImageGetWidth(surface);
   size_t height = O2ImageGetHeight(surface);

   [_caContext prepareViewportWidth: width height: height];
   [_caContext renderSurface: surface];

   glFlush();
   CGLSwapBuffers(_cglWindow);
}

-(void)flushBuffer {
    if (_context == nil) return;
    O2ContextFlush(_context);
    [self openGLFlushBuffer];
}


-(NSPoint)mouseLocationOutsideOfEventStream {
   NSUnimplementedMethod();
   return NSZeroPoint;
}


-(O2Rect)frame
{
   return [self transformFrame:_frame];
}

static int ignoreBadWindow(Display* display,
                        XErrorEvent* errorEvent) {
   if(errorEvent->error_code==BadWindow)
      return 0;
   char buf[512];
   XGetErrorText(display, errorEvent->error_code, buf, 512);
   [NSException raise:NSInternalInconsistencyException format:@"X11 error: %s", buf];
   return 0;
}

-(void)frameChanged
{
   XErrorHandler previousHandler=XSetErrorHandler(ignoreBadWindow);
   @try {
      Window root, parent;
      Window window=_window;
      int x, y;
      unsigned int w, h, d, b, nchild;
      Window* children;
      O2Rect rect=NSZeroRect;
      // recursively get geometry to get absolute position
      BOOL success=YES;
      while(window && success) {
         XGetGeometry(_display, window, &root, &x, &y, &w, &h, &b, &d);
         success = XQueryTree(_display, window, &root, &parent, &children, &nchild);
         if(children)
            XFree(children);
         
         // first iteration: save our own w, h
         if(window==_window)
            rect=NSMakeRect(0, 0, w, h);
         rect.origin.x+=x;
         rect.origin.y+=y;
         window=parent;
      };
      
     [self invalidateContextWithNewSize:rect.size];
     _frame = rect;
   }
   @finally {
      XSetErrorHandler(previousHandler);
   }
}

-(Visual*)visual {
   return DefaultVisual(_display, DefaultScreen(_display));
}

-(Drawable)drawable {
   return _window;
}

-(void)addEntriesToDeviceDictionary:(NSDictionary *)entries  {
   [_deviceDictionary addEntriesFromDictionary:entries];
}

-(O2Rect)transformFrame:(O2Rect)frame {
   return NSMakeRect(frame.origin.x, DisplayHeight(_display, DefaultScreen(_display)) - frame.origin.y - frame.size.height, fmax(frame.size.width, 1.0), fmax(frame.size.height, 1.0));
}

-(NSPoint)transformPoint:(NSPoint)pos;
{
   return NSMakePoint(pos.x, _frame.size.height-pos.y);
}

- (X11SubWindow *) createSubWindowWithFrame: (CGRect) frame {
    return [[[X11SubWindow alloc] initWithParentWindow: self frame: frame] autorelease];
}

@end
