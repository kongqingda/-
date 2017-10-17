//
//  MultiLineGraphContext.m
//  Algo SDK Sample
//
//  Created by Terence Yeung on 2/3/2016.
//  Copyright © 2016 NeuroSky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MultiLineGraphContext.h"
#import "MultiLineGraphView.h"

@implementation MultiLineGraphContext {
    int cursorIndex;
    int xCompressCount;
    NSMutableArray * data[MAX_LINE_COUNT];
}

@synthesize xMax, lineCount;

- (void)setXMax:(int)new {
    xMax = new;
    [self initBuffer];
}

- (int)xMax {
    return xMax;
}

- (void)setLineCount:(int)new {
    lineCount = new;
    [self initBuffer];
}

- (int)lineCount {
    return lineCount;
}

- (void) initBuffer {
    if (xMax == 0 || lineCount == 0)
        return;
    for (int i = 0; i < lineCount; ++i) {
        data[i] = [[NSMutableArray alloc] init];
    }
    cursorIndex = 0;
    xCompressCount = 0;
}

- (void) pushCursor {
    cursorIndex++;
}

- (void) pushValue:(double)value index:(int)index {
    if (index > lineCount - 1)
        return;
    xCompressCount++;
    if (xCompressCount < [self xCompressRate]) {
        return;
    } else {
        xCompressCount = 0;
    }
    
    if (cursorIndex > [self xMax] / [self xCompressRate] - 1) {
        cursorIndex = 0;
    }
    
    if(data[index].count < [self xMax] / [self xCompressRate]) {
        [data[index] insertObject:[NSNumber numberWithDouble:value] atIndex:cursorIndex];
    }else {
        [data[index] replaceObjectAtIndex:cursorIndex withObject:[NSNumber numberWithDouble:value] ];
    }
}

- (NSMutableArray *) getBuffer:(int)index {
    if (index > lineCount - 1)
        return NULL;
    return data[index];
}

- (int) getCursorIndex {
    return cursorIndex;
}

@end