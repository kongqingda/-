//
//  ViewController.h
//  ECG Algo SDK Demo App
//
//  Copyright (c) 2015 NeuroSky. All rights reserved.
//

#import <UIKit/UIKit.h>
#if TARGET_IPHONE_SIMULATOR
#else
#import "TGStreamDelegate.h"
#endif
#import <AlgoSdk/NskAlgoSdk.h>
#import "MultiLineGraphView.h"
#import "MultiLineGraphContext.h"

#if TARGET_IPHONE_SIMULATOR
@interface ViewController : UIViewController <NskAlgoSdkDelegate>
#else
@interface ViewController : UIViewController <NskAlgoSdkDelegate, TGStreamDelegate>
#endif
@property (weak, atomic) IBOutlet UILabel *stateLabel;
@property (weak, atomic) IBOutlet UILabel *signalLabel;
@property (weak, atomic) IBOutlet UIButton *dataButton;
@property (weak, atomic) IBOutlet UIButton *startPauseButton;
@property (weak, atomic) IBOutlet UIButton *stopButton;


@property (weak, atomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UISwitch *checkboxHeartrate;
@property (weak, nonatomic) IBOutlet UISwitch *checkboxStress;
@property (weak, nonatomic) IBOutlet UISwitch *checkboxHRV;
@property (weak, nonatomic) IBOutlet UISwitch *checkboxAFib;
@property (weak, nonatomic) IBOutlet UISwitch *checkboxSmooth;
@property (weak, nonatomic) IBOutlet UISwitch *checkboxHeartage;
@property (weak, nonatomic) IBOutlet UISwitch *checkboxResp;
@property (weak, nonatomic) IBOutlet UISwitch *checkboxMood;
@property (weak, nonatomic) IBOutlet UISwitch *checkboxHRVFD;
@property (weak, nonatomic) IBOutlet UISwitch *checkboxHRVTD;

@property (weak, atomic) IBOutlet UILabel *ecgStatus;

@property (weak, atomic) IBOutlet UIButton *setAlgoButton;
@property (weak, nonatomic) IBOutlet MultiLineGraphView *lineGraph;
@property (weak, nonatomic) IBOutlet UILabel *ecgStatus2;

- (IBAction)startPausePress:(id)sender;
- (IBAction)dataPress:(id)sender;
- (IBAction)setAlgos:(id)sender;

@end

