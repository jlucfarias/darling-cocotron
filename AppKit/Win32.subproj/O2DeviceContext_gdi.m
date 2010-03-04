/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <AppKit/O2DeviceContext_gdi.h>
#import <CoreGraphics/O2Path.h>
#import <CoreGraphics/O2Color.h>
#import <CoreGraphics/O2ColorSpace.h>

static inline void CMYKAToRGBA(const float *input,float *output){
   float white=1-input[3];
   
   output[0]=(input[0]>white)?0:white-input[0];
   output[1]=(input[1]>white)?0:white-input[1];
   output[2]=(input[2]>white)?0:white-input[2];
   output[3]=input[4];
}

static COLORREF gammaAdjustedRGBFromComponents(float r,float g,float b){
#if 0
// Do not use this, it's expensive, build a table for the byte components if needed
// lame gamma adjustment so that non-system colors appear similar to those on a Mac

   const float assumedGamma=1.3;
   const float displayGamma=2.2;
   float gammaAdjustment=assumedGamma/displayGamma
   r=pow(r,assumedGamma/displayGamma);
   if(r>1.0)
    r=1.0;

   g=pow(g,assumedGamma/displayGamma);
   if(g>1.0)
    g=1.0;

   b=pow(b,assumedGamma/displayGamma);
   if(b>1.0)
    b=1.0;
#endif
    
   return RGB(r*255,g*255,b*255);
}

COLORREF COLORREFFromColor(O2Color *color){
   O2ColorSpaceRef colorSpace=O2ColorGetColorSpace(color);
   const float    *components=O2ColorGetComponents(color);
   
   switch([colorSpace type]){

    case kO2ColorSpaceModelMonochrome:
     return gammaAdjustedRGBFromComponents(components[0],components[0],components[0]);
     
    case kO2ColorSpaceModelRGB:
     if(O2ColorSpaceIsPlatformRGB)
      return RGB(components[0]*255,components[1]*255,components[2]*255);
     else
      return gammaAdjustedRGBFromComponents(components[0],components[1],components[2]);
     
    case kO2ColorSpaceModelCMYK:{
      float rgba[4];
      
      CMYKAToRGBA(components,rgba);
      return gammaAdjustedRGBFromComponents(rgba[0],rgba[1],rgba[2]);
     }
     break;
               
    default:
     NSLog(@"GDI context can't translate from colorspace %@",colorSpace);
     return RGB(0,0,0);
   }
}

@implementation O2DeviceContext_gdi

-initWithDC:(HDC)dc {
   _dc=dc;
   
   SetGraphicsMode(_dc,GM_ADVANCED);

   if(SetMapMode(_dc,MM_ANISOTROPIC)==0)
    NSLog(@"SetMapMode failed");
   //SetICMMode(_dc,ICM_ON); MSDN says only available on 2000, not NT.

   SetBkMode(_dc,TRANSPARENT);
   SetTextAlign(_dc,TA_BASELINE);

   return self;
}

-(HDC)dc {
   return _dc;
}

-(Win32DeviceContextWindow *)windowDeviceContext {
   return nil;
}

static inline int float2int(float coord){
   return floorf(coord);
}

void O2DeviceContextEstablishDeviceSpacePath_gdi(HDC dc,O2Path *path,O2AffineTransform xform) {
   unsigned             opCount=O2PathNumberOfElements(path);
   const unsigned char *elements=O2PathElements(path);
   unsigned             pointCount=O2PathNumberOfPoints(path);
   const NSPoint       *points=O2PathPoints(path);
   unsigned             i,pointIndex;
       
   BeginPath(dc);
   
   pointIndex=0;
   for(i=0;i<opCount;i++){
    switch(elements[i]){

     case kO2PathElementMoveToPoint:{
       NSPoint point=O2PointApplyAffineTransform(points[pointIndex++],xform);
        
       MoveToEx(dc,float2int(point.x),float2int(point.y),NULL);
      }
      break;
       
     case kO2PathElementAddLineToPoint:{
       NSPoint point=O2PointApplyAffineTransform(points[pointIndex++],xform);
        
       LineTo(dc,float2int(point.x),float2int(point.y));
      }
      break;

     case kO2PathElementAddCurveToPoint:{
       NSPoint cp1=O2PointApplyAffineTransform(points[pointIndex++],xform);
       NSPoint cp2=O2PointApplyAffineTransform(points[pointIndex++],xform);
       NSPoint end=O2PointApplyAffineTransform(points[pointIndex++],xform);
       POINT   points[3]={
        { float2int(cp1.x), float2int(cp1.y) },
        { float2int(cp2.x), float2int(cp2.y) },
        { float2int(end.x), float2int(end.y) },
       };
        
       PolyBezierTo(dc,points,3);
      }
      break;

// FIX, this is wrong
     case kO2PathElementAddQuadCurveToPoint:{
       NSPoint cp1=O2PointApplyAffineTransform(points[pointIndex++],xform);
       NSPoint cp2=O2PointApplyAffineTransform(points[pointIndex++],xform);
       NSPoint end=cp2;
       POINT   points[3]={
        { float2int(cp1.x), float2int(cp1.y) },
        { float2int(cp2.x), float2int(cp2.y) },
        { float2int(end.x), float2int(end.y) },
       };
        
       PolyBezierTo(dc,points,3);
      }
      break;

     case kO2PathElementCloseSubpath:
      CloseFigure(dc);
      break;
    }
   }
   EndPath(dc);
}

void O2DeviceContextClipReset_gdi(HDC dc) {
   HRGN region=CreateRectRgn(0,0,GetDeviceCaps(dc,HORZRES),GetDeviceCaps(dc,VERTRES));
   SelectClipRgn(dc,region);
   DeleteObject(region);
}

void O2DeviceContextClipToPath_gdi(HDC dc,O2Path *path,O2AffineTransform xform,O2AffineTransform deviceXFORM,BOOL evenOdd){
   XFORM current;
   XFORM userToDevice={deviceXFORM.a,deviceXFORM.b,deviceXFORM.c,deviceXFORM.d,deviceXFORM.tx,deviceXFORM.ty};

   if(!GetWorldTransform(dc,&current))
    NSLog(@"GetWorldTransform failed");

   if(!SetWorldTransform(dc,&userToDevice))
    NSLog(@"ModifyWorldTransform failed");

   O2DeviceContextEstablishDeviceSpacePath_gdi(dc,path,xform);
   SetPolyFillMode(dc,evenOdd?ALTERNATE:WINDING);
   if(!SelectClipPath(dc,RGN_AND))
    NSLog(@"SelectClipPath failed (%i), path size= %d", GetLastError(),O2PathNumberOfElements(path));

   if(!SetWorldTransform(dc,&current))
    NSLog(@"SetWorldTransform failed");
}

void O2DeviceContextClipToNonZeroPath_gdi(HDC dc,O2Path *path,O2AffineTransform xform,O2AffineTransform deviceXFORM){
   O2DeviceContextClipToPath_gdi(dc,path,xform,deviceXFORM,NO);
}

void O2DeviceContextClipToEvenOddPath_gdi(HDC dc,O2Path *path,O2AffineTransform xform,O2AffineTransform deviceXFORM){
   O2DeviceContextClipToPath_gdi(dc,path,xform,deviceXFORM,YES);
}

-(void)beginPrintingWithDocumentName:(NSString *)name {
   // do nothing
}

-(void)endPrinting {
   // do nothing
}

-(void)beginPage {
   // do nothing
}

-(void)endPage {
   // do nothing
}

-(unsigned)bitsPerPixel {
   [self doesNotRecognizeSelector:_cmd];
   return 0;
}

-(NSSize)pixelsPerInch {
   [self doesNotRecognizeSelector:_cmd];
   return NSMakeSize(0,0);
}

-(NSSize)pixelSize {
   float pixelsWide=GetDeviceCaps(_dc,HORZRES);
   float pixelsHigh=GetDeviceCaps(_dc,VERTRES);
   
   return NSMakeSize(pixelsWide,pixelsHigh);
}

-(NSSize)pointSize {
   NSSize pixelPerInch=[self pixelsPerInch];
   NSSize pixelSize=[self pixelSize];

   float pointsWide=(pixelSize.width/pixelPerInch.width)*72.0;
   float pointsHigh=(pixelSize.height/pixelPerInch.height)*72.0;
   
   return NSMakeSize(pointsWide,pointsHigh);
}

-(NSRect)paperRect {
   NSRect result;
   
   result.size=[self pointSize];
   result.origin=NSMakePoint(0,0);
   
   return result;
}

-(NSRect)imageableRect {
   return [self paperRect];
}


@end