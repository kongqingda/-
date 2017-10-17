//
//  MultiLineGraphContext.h
//  Algo SDK Sample
//
//  Created by Terence Yeung on 2/3/2016.
//  Copyright © 2016 NeuroSky. All rights reserved.
//

#ifndef MultiLineGraphContext_h
#define MultiLineGraphContext_h

typedef struct _ALGO_SETTING {
    float xRange;
    float plotMinY;
    float plotMaxY;
    
    int interval;
    
    int minInterval;
    int maxInterval;
    
    // for BCQ
    int bcqThreshold;
    int bcqValid;
    int bcqWindow;
} ALGO_SETTING;

@interface MultiLineGraphContext : NSObject  {
}

@property int interval;
@property int xCompressRate;
@property int xMax;
@property int lineCount;
@property int bcqValid;
@property int bcqThreshold;
@property int bcqWindow;
@property BOOL plotAvailable;

- (void) pushValue:(double)value index:(int)index;
- (void) pushCursor;
- (NSMutableArray *) getBuffer:(int)index;
- (int) getCursorIndex;

@end
#endif /* MultiLineGraphContext_h */
