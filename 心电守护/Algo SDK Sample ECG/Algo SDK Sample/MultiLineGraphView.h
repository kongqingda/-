//
//  MultiLineGraphView.h
//  Algo SDK Sample
//
//  Created by Terence Yeung on 29/2/2016.
//  Copyright © 2016 NeuroSky. All rights reserved.
//

#ifndef MultiLineGraphView_h
#define MultiLineGraphView_h

#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>
#import <AVFoundation/AVFoundation.h>

#define AVERAGE_COUNT 50
#define CARDIO_SCALER 1
#define EEG_SCALER 1.0
#define GRID_ENABLED NO;
#define LINE_WIDTH 1.0
#define MAX_LINE_COUNT 5
#define MAX_BIG_GRID 5

@interface MultiLineGraphView : UIView {
    
    NSMutableArray * data[MAX_LINE_COUNT];
    
    double xAxisMin;
    double xAxisMax;
    double yAxisMin;
    double yAxisMax;
    int xAxisCompressFactor;
    
    NSLock *dataLock;
    
    int startIndex;
    
    int cursorIndex;
    double scaler;
    
    NSTimer *reDrawTimer;
    NSThread *redraw;
    
    UIColor * __weak backgroundColor;
    UIColor * __weak cursorColor;
    BOOL cursorEnabled;
    BOOL gridEnabled;
    BOOL touchEnabled;
    BOOL invertSignal;
    BOOL bandOnRightWrist;
    BOOL lineEnable[MAX_LINE_COUNT];
    
@private
    SEL addTo;
    id __weak tagert;
    
    UIPinchGestureRecognizer * pinch;
    UITapGestureRecognizer * taptap;
    BOOL newData;
    int dataCompressCount[MAX_LINE_COUNT];
    UIColor * lineColor[MAX_LINE_COUNT];
    
    /* DC offset removal */
    int averageCount;
    double average;
    BOOL offsetRemovalEnabled;
    
    // for bandpass filter
    float * ECGbuffer;
    float * filteredPoint;
    
    int ECGBufferCounter;
    int ECGBufferLength;
    int hpcoeffLength;
    
    UIBezierPath *smallGrid;
    UIBezierPath *grid;
    UIBezierPath *path;
    UIBezierPath *cursor;
    
}

- (void)notifyDataUpdate;
- (void)setDataRef:(NSMutableArray*)dataRef index:(int)index;
- (void)setCursor:(int)value;
- (void)setConfig:(int)xMin xMax:(int)xMax yMin:(int)yMin yMax:(int)yMax xCompress:(int)xCompress;
- (CGPoint)point2PixelsWithXValue:(double) xValue yValue:(double) yValue;
- (double)addValue:(double)value index:(int)index;
- (void)twoFingerPinch:(UIPinchGestureRecognizer *)recognizer;
- (void)doubleTap;
- (void)cleardata;
- (void)setAllLineEnable:(BOOL)enable;
- (void)setLineEnable:(BOOL)enable index:(int)line;

@property (weak) UIColor * backgroundColor;
@property (weak) UIColor * cursorColor;
@property BOOL cursorEnabled;
@property (weak)id tagert;
@property SEL addTo;
@property double scaler;

@end


#endif /* MultiLineGraphView_h */
