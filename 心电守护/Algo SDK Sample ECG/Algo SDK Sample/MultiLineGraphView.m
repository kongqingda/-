//
//  MultiLineGraphView.m
//  Algo SDK Sample
//
//  Created by Terence Yeung on 29/2/2016.
//  Copyright © 2016 NeuroSky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MultiLineGraphView.h"

@implementation MultiLineGraphView

@synthesize backgroundColor;
@synthesize cursorColor;
@synthesize cursorEnabled;
@synthesize addTo;
@synthesize tagert;
@synthesize scaler;

float numberOfBigBlocks;
float numberOfSmallBlocks;
float bigBlockSize;
float smallBlockSize;
float lineOffset;
float gridScale;

/* size in pixels */
float frameWidth;
float frameHeight;
float bigBlockH;
float bigBlockW;
float smallBlockH;
float smallBlockW;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self refreshDim];
}

- (void)initialize {
    
    xAxisMin = 0;    //seconds
    xAxisMax = 6;    //seconds
    yAxisMin = -20;
    yAxisMax = 20;
    xAxisCompressFactor = 1;
    
    averageCount = 0;
    offsetRemovalEnabled = NO;
    lineOffset = 1;
    
    invertSignal = YES;
    
    cursorIndex = 0;
    for (int i = 0; i < MAX_LINE_COUNT; ++i) {
        data[i] = NULL;
        dataCompressCount[i] = 0;
    }
    
    scaler = CARDIO_SCALER;
    dataLock = [[NSLock alloc] init];
    
    redraw = [[NSThread alloc] initWithTarget:self selector:@selector(redrawThread) object:nil];
    [redraw start];
    
    if(backgroundColor == nil) {
        backgroundColor = [UIColor clearColor];
        self.backgroundColor = backgroundColor;
    }
    
    lineColor[0] = [UIColor blackColor];
    lineColor[1] = [UIColor magentaColor];
    lineColor[2] = [UIColor greenColor];
    lineColor[3] = [UIColor purpleColor];
    lineColor[4] = [UIColor cyanColor];
    cursorColor = [UIColor redColor];
    
    cursorEnabled = YES;
    gridEnabled = YES;
    touchEnabled = NO;
    
    if(touchEnabled) {
        pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerPinch:)];
        [self addGestureRecognizer:pinch];
        taptap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap)];
        taptap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:taptap];
    }
    
    ECGBufferCounter = 0;
}

- (UIColor *)backgroundColor {
    return backgroundColor;
}

- (void)setBackgroundColor:(UIColor *)color {
    backgroundColor = color;
}

- (void)dealloc {
    free(ECGbuffer);
    free(filteredPoint);
}

- (void)refreshDim {
    int width = self.frame.size.width;
    int height = self.frame.size.height;

    frameHeight = height;
    frameWidth = width;
    numberOfBigBlocks = ((xAxisMax - xAxisMin) / 0.2);
    if (numberOfBigBlocks > MAX_BIG_GRID)
        numberOfBigBlocks = MAX_BIG_GRID;
    numberOfSmallBlocks = numberOfBigBlocks * 5;
    
    bigBlockH = height / numberOfBigBlocks;
    bigBlockW = width / numberOfBigBlocks;
    smallBlockH = bigBlockH / 5;
    smallBlockW = bigBlockW / 5;
    
    gridScale = scaler - CARDIO_SCALER;
}

- (void)drawRect:(CGRect)clientRect {
    if(gridEnabled) {
        // Small Blocks
        smallGrid = [UIBezierPath bezierPath];
        [smallGrid removeAllPoints];
        [smallGrid setLineWidth:0.1];
        
        // Vertical lines
        [smallGrid moveToPoint:[self point2PixelsWithXValue:0.0 yValue:yAxisMax]];
        for (int i = 0; i < numberOfSmallBlocks; i++) {
            double x = i * smallBlockW;
            double xp = (i + 1) * smallBlockW;
            [smallGrid addLineToPoint: CGPointMake(x, 0)];
            [smallGrid moveToPoint: CGPointMake(xp, frameHeight)];
        }
        
        // Horizontal lines
        [smallGrid moveToPoint:[self point2PixelsWithXValue:0.0 yValue:yAxisMax + lineOffset]];
        for (int i = 0; i < numberOfSmallBlocks; i++) {
            double y = i * smallBlockH;
            double yp = (i + 1) * smallBlockH;
            
            [smallGrid addLineToPoint:CGPointMake(0, y)];
            [smallGrid moveToPoint:CGPointMake(frameWidth, yp)];
        }
        
        [[UIColor redColor] set];
        [smallGrid stroke];
        
        // Large blocks
        grid = [UIBezierPath bezierPath];
        [grid removeAllPoints];
        [grid setLineWidth:0.3];
        
        // Vertical lines
        [grid moveToPoint:[self point2PixelsWithXValue:0.0 yValue:yAxisMax]];
        for (int i = 0; i < numberOfBigBlocks + 1; i++) {
            double x = i * bigBlockW;
            double xp = (i + 1) * bigBlockW;
            
            [grid addLineToPoint:CGPointMake(x, 0)];
            [grid moveToPoint:CGPointMake(xp, frameHeight)];
        }
        
        // Horizontal lines
        [grid moveToPoint:[self point2PixelsWithXValue:0.0 yValue:yAxisMax + lineOffset]];
        for (int i = 0; i < numberOfBigBlocks + 1; i++) {
            double y = i * bigBlockH;
            double yp = (i + 1) * bigBlockH;
            
            [grid addLineToPoint:CGPointMake(0, y)];
            [grid moveToPoint:CGPointMake(frameWidth, yp)];
        }
        [[UIColor redColor] set];
        [grid stroke];
    }

    for (int j = 0; j < MAX_LINE_COUNT; ++j) {
        if (lineEnable[j] == false) {
            continue;
        }
        path = [UIBezierPath bezierPath];
        [path removeAllPoints];
        
        [path setLineWidth:LINE_WIDTH];
        [path moveToPoint:CGPointMake(0, clientRect.size.height/2)];
        
        for(int i = 0; (data[j] != NULL) && (i < data[j].count); i++) {
            
            NSNumber *tempValue = (NSNumber *)[data[j] objectAtIndex:i];
            CGPoint tempPixel = [self point2PixelsWithXValue:i
                                                      yValue:([tempValue doubleValue] * scaler)];
            [path addLineToPoint:tempPixel];
        }
        [lineColor[j] set];
        [path stroke];
    }
    if(cursorEnabled) {
        cursor = [UIBezierPath bezierPath];
        [cursor removeAllPoints];
        
        [cursor setLineWidth:2];
        [cursor moveToPoint:[self point2PixelsWithXValue:(cursorIndex - 1)  yValue:yAxisMax]];
        [cursor addLineToPoint:[self point2PixelsWithXValue:(cursorIndex - 1) yValue:yAxisMin]];
        [cursorColor set];
        [cursor stroke];
    }
    newData = NO;
}

- (CGPoint)point2PixelsWithXValue:(double) xValue yValue:(double) yValue {
    CGPoint temp = {0, 0};
    
    int width = self.frame.size.width;
    int height = self.frame.size.height;
    
    temp.x = (xValue - xAxisMin) *  width / (xAxisMax - xAxisMin);
    temp.y = ((yValue - yAxisMin) / (yAxisMax - yAxisMin) * height);
    
    if(!invertSignal) temp.y = self.bounds.size.height - temp.y;
    //NSLog(@"pixel: %f, %f", temp.x, temp.y);
    return temp;
}


- (double)addValue:(double)value index:(int)line {
    
    double newValue = value;
    dataCompressCount[line]++;
    if (dataCompressCount[line] < xAxisCompressFactor) {
        return newValue;
    } else {
        dataCompressCount[line] = 0;
    }
    if (cursorIndex > xAxisMax / xAxisCompressFactor - 1) {
        
        //
        //cursorEnabled=YES;
        
        if (cursorEnabled) {
            //NSLog(@"cursorEnabled======YES");
        }
        else{
            //NSLog(@"cursorEnabled======NO");
        }
        
        //        [self.tagert performSelector:addTo withObject:nil];
        cursorIndex = 0;
    }
    
    if(offsetRemovalEnabled){
        if(averageCount < AVERAGE_COUNT) averageCount++;
        //        [self.tagert performSelector:addTo withObject:nil];
        
        average = (average*(averageCount - 1) + newValue)/averageCount;
    }else {
        average = 0;
    }
    
    [dataLock lock];
    
    if(data[line].count < xAxisMax / xAxisCompressFactor) {
        [data[line] insertObject:[NSNumber numberWithDouble:newValue - average] atIndex:cursorIndex];
    }else {
        [data[line] replaceObjectAtIndex:cursorIndex withObject:[NSNumber numberWithDouble:newValue - average] ];
    }
    
    //NSLog(@"data count: %d", data.count);
    cursorIndex++;
    [dataLock unlock];
    newData = YES;
    
    return newValue;
}

- (void)twoFingerPinch:(UIPinchGestureRecognizer *)recognizer {
    scaler += recognizer.scale - 1;
    if(scaler < 0.4)
        scaler = 0.4;
    else if (scaler > 5)
        scaler = 5;
    //NSLog(@"Pinch scale: %f", scaler);
}

- (void)doubleTap {
    scaler = 1;
}

- (void)redrawThread {
    while (true) {
        if (newData) {
            [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
        }
        [NSThread sleepForTimeInterval:0.033];
    }
    
}

-(void)cleardata{
    
    [dataLock lock];
    for (int i = 0; i < MAX_LINE_COUNT; ++i) {
        data[i] = NULL;
        dataCompressCount[i] = 0;
    }
    cursorIndex = 0;
    averageCount = 0;
    [dataLock unlock];
}

- (void)setAllLineEnable:(BOOL)enable {
    for (int i = 0; i < MAX_LINE_COUNT; ++i)
        lineEnable[i] = enable;
}

- (void)setLineEnable:(BOOL)enable index:(int)line {
    lineEnable[line] = enable;
}

- (void)setConfig:(int)xMin xMax:(int)xMax yMin:(int)yMin yMax:(int)yMax xCompress:(int)xCompress {
    [self cleardata];
    xAxisMin = xMin;
    xAxisMax = xMax;
    yAxisMin = yMin;
    yAxisMax = yMax;
    xAxisCompressFactor = xCompress;
    [self refreshDim];
}

- (void)setLineColor:(UIColor*)color index:(int)line {
    lineColor[line] = color;
}

- (void)setDataRef:(NSMutableArray*)dataRef index:(int)index{
    data[index] = dataRef;
    newData = YES;
}

- (void)setCursor:(int)value {
    cursorIndex = value;
    newData = YES;
}

- (void)notifyDataUpdate {
    newData = YES;
}

@end
