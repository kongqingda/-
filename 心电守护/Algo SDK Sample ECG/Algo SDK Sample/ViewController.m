//
//  ViewController.m
//  ECG Algo SDK Demo App
//
//  Copyright (c) 2015 NeuroSky. All rights reserved.
//

#import "ViewController.h"

#undef TARGET_IPHONE_SIMULATOR
#if defined __arm__ || defined __thumb__ || __arm64__
#define TARGET_OS_IPHONE
#else
#define TARGET_IPHONE_SIMULATOR 1
#undef TARGET_OS_IPHONE
#endif

#define ECG_RANGE   (512 * 2)
#define X_RANGE     256

#define IOS_DEVICE

/*
 * Uncomment USE_CANNED_DATA to work with Neurosky biometric device
 * This works on iPad / iPhone, but not on simulators
 */
#define USE_CANNED_DATA

#ifdef IOS_DEVICE
#include <sys/time.h>
#endif

#ifndef TARGET_IPHONE_SIMULATOR
#import "TGStream.h"
#endif

typedef NS_ENUM(NSInteger, SegmentIndexType) {
    SegmentECG,
    SegmentMax
};

@interface ViewController () {
@private
    BOOL bRunning;
    BOOL bPaused;
    
    NskAlgoType algoTypes;
    NSTimer *graphTimer;
    MultiLineGraphContext * graphContextList[SegmentMax];
    
    NSInteger activeProfile;
    
    BOOL bRcvQ;
    BOOL bSendQ;
    
    char license[128];
    
#ifdef USE_CANNED_DATA
    NSArray *rawArray;
    int rawIndex;
    int  rawNum;
    NSThread* sendDataThread;
    bool exitRawThread;
#endif
}

@end

@implementation ViewController
@synthesize checkboxHRV, checkboxAFib, checkboxMood, checkboxResp, checkboxSmooth, checkboxStress, checkboxHeartage, checkboxHeartrate, checkboxHRVFD, checkboxHRVTD, ecgStatus, ecgStatus2, startPauseButton, dataButton, stopButton, textView, lineGraph;

NSMutableString *stateStr;
NSMutableString *signalStr;

long long tStart, tEnd;

const ALGO_SETTING defaultAlgoSetting[SegmentMax] = {
    /*  lineCount   xRange          plotMinY    plotMaxY   interval    minInterval maxInterval bcqThreshold                bcqValid    bcqWindow */
    {ECG_RANGE,    -8000,     17000,        1,          1,          1,          0,                          0,          0}
};

typedef struct _PLOT_PARAM {
    int plotCount;
    int xCompressRate;
    BOOL plotAvailable;
    char *graphTitle;
    
    char *plotName[5];
} PLOT_PARAM;

PLOT_PARAM defaultPlotParam[SegmentMax] = {
    /*    plotAvaliable graphTitle                  plotName */
    { 1, 4, YES,          "HR",                       {"HR Value",     nil} }
};

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"viewwillappear");
    [self hideGraph];
}

- (IBAction)setAlgos:(id)sender {
    algoTypes = 0;
    
    [self showGraph];
    [textView setText:@""];
    [textView setHidden:YES];
    
    [stateStr setString:@""];
    [signalStr setString:@""];
    
    [stopButton setEnabled:NO];
    
    if ([checkboxHeartrate isOn]) {
        algoTypes |= NskAlgoEcgTypeHeartRate;
    }
    
    if ([checkboxHeartage isOn]) {
        algoTypes |= NskAlgoEcgTypeHeartAge;
    }
    
    if ([checkboxStress isOn]) {
        algoTypes |= NskAlgoEcgTypeStress;
    }
    
    if ([checkboxSmooth isOn]) {
        algoTypes |= NskAlgoEcgTypeSmooth;
    }
    
    if ([checkboxResp isOn]) {
        algoTypes |= NskAlgoEcgTypeRespiratory;
    }
    
    if ([checkboxMood isOn]) {
        algoTypes |= NskAlgoEcgTypeMood;
    }
    
    if ([checkboxAFib isOn]) {
        algoTypes |= NskAlgoEcgTypeAfib;
    }
    
    if ([checkboxHRV isOn]) {
        algoTypes |= NskAlgoEcgTypeHRV;
    }
    
    if ([checkboxHRVFD isOn]) {
        algoTypes |= NskAlgoEcgTypeHRVFD;
    }
    
    if ([checkboxHRVTD isOn]) {
        algoTypes |= NskAlgoEcgTypeHRVTD;
    }
    
    if (algoTypes == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Please select at least ONE algorithm"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        int ret;
#ifdef USE_CANNED_DATA
        // kill the current sending first
        if (sendDataThread != NULL) {
            exitRawThread = true;
        }
#endif
        
        NskAlgoSdk *handle = [NskAlgoSdk sharedInstance];
        handle.delegate = self;
        
        if ((ret = (int)[[NskAlgoSdk sharedInstance] setAlgorithmTypes:algoTypes licenseKey:license]) != 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[NSString stringWithFormat:@"Fail to init EEG SDK [%d]", ret]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        if ((ret = [[NskAlgoSdk sharedInstance] setSampleRate:NskAlgoDataTypeECG sampleRate:NskAlgoSampleRate512]) != YES) {
            NSLog(@"Fail to set the baud rate");
            return;
        }
        
//        if ((ret = [[NskAlgoSdk sharedInstance] setSignalQualityWatchDog:NskAlgoDataTypeECG timeout:20 recoveryTimeOut:5]) != YES) {
//            NSLog(@"Fail to set the watchdog timeout");
//            return;
//        }
        
        [self configureProfile];
        [self configECG];
        
        NSMutableString *version = [NSMutableString stringWithFormat:@"SDK Ver.: %@", [[NskAlgoSdk sharedInstance] getSdkVersion]];
        if ((algoTypes & NskAlgoEcgTypeHeartRate) == NskAlgoEcgTypeHeartRate) {
            [version appendFormat:@"\nHR Ver.: %@", [[NskAlgoSdk sharedInstance] getAlgoVersion:NskAlgoEcgTypeHeartRate]];
        }
        if ((algoTypes & NskAlgoEcgTypeStress) == NskAlgoEcgTypeStress) {
            [version appendFormat:@"\nStress Ver.: %@", [[NskAlgoSdk sharedInstance] getAlgoVersion:NskAlgoEcgTypeStress]];
        }
        if ((algoTypes & NskAlgoEcgTypeMood) == NskAlgoEcgTypeMood) {
            [version appendFormat:@"\nMood Ver.: %@", [[NskAlgoSdk sharedInstance] getAlgoVersion:NskAlgoEcgTypeMood]];
        }
        if ((algoTypes & NskAlgoEcgTypeHeartAge) == NskAlgoEcgTypeHeartAge) {
            [version appendFormat:@"\nHeartAge Ver.: %@", [[NskAlgoSdk sharedInstance] getAlgoVersion:NskAlgoEcgTypeHeartAge]];
        }
        if ((algoTypes & NskAlgoEcgTypeHRV) == NskAlgoEcgTypeHRV) {
            [version appendFormat:@"\nHRV Ver.: %@", [[NskAlgoSdk sharedInstance] getAlgoVersion:NskAlgoEcgTypeHRV]];
        }
        if ((algoTypes & NskAlgoEcgTypeSmooth) == NskAlgoEcgTypeSmooth) {
            [version appendFormat:@"\nSmooth Ver.: %@", [[NskAlgoSdk sharedInstance] getAlgoVersion:NskAlgoEcgTypeSmooth]];
        }
        if ((algoTypes & NskAlgoEcgTypeRespiratory) == NskAlgoEcgTypeRespiratory) {
            [version appendFormat:@"\nResp Ver.: %@", [[NskAlgoSdk sharedInstance] getAlgoVersion:NskAlgoEcgTypeRespiratory]];
        }
        if ((algoTypes & NskAlgoEcgTypeAfib) == NskAlgoEcgTypeAfib) {
            [version appendFormat:@"\nAfib Ver.: %@", [[NskAlgoSdk sharedInstance] getAlgoVersion:NskAlgoEcgTypeAfib]];
        }
        if ((algoTypes & NskAlgoEcgTypeHRVTD) == NskAlgoEcgTypeHRVTD) {
            [version appendFormat:@"\nHRVTD Ver.:%@", [[NskAlgoSdk sharedInstance] getAlgoVersion:NskAlgoEcgTypeHRVTD]];
        }
        if ((algoTypes & NskAlgoEcgTypeHRVFD) == NskAlgoEcgTypeHRVFD) {
            [version appendFormat:@"\nHRVFD Ver.:%@", [[NskAlgoSdk sharedInstance] getAlgoVersion:NskAlgoEcgTypeHRVFD]];
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:version
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert show];
        
    }
    if (graphTimer == nil) {
        graphTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(reloadGraph) userInfo:nil repeats:YES];
    }
}

- (void)reloadGraph {
    @synchronized(lineGraph) {
        if (lineGraph) {
            UIColor * fillColor = [UIColor clearColor];
            [lineGraph setBackgroundColor:fillColor];
        }
    }
}

#ifdef USE_CANNED_DATA
-(void)sendRawFromFile {
    rawArray = [[NSArray alloc] init];
    rawIndex = 0;
    rawNum = 0;
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *filePath = [mainBundle pathForResource:@"raw_3min_log" ofType:@"txt"];
    NSString *contents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    if (contents == nil) {
        NSLog(@"empty file");
    }else{
        rawArray = [contents componentsSeparatedByString:@"\n"];
    }
    
    [[self dataButton] setEnabled:NO];
    exitRawThread = false;
    sendDataThread = [[NSThread alloc] initWithTarget:self selector:@selector(sendRawdata) object:nil];
    [sendDataThread start];
}
#endif


static float snn50 = 0.0, ssdnn = 0.0, spnn50 = 0.0, srr = 0.0, rmssdv = 0.0;
static float shf = 0.0, slf = 0.0, lfhfr = 0.0, hflfr = 0.0;
- (void) updateHRVAnalysis {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString * str = [NSString stringWithFormat:@"[nn50=%f sdnn=%f pnn50=%f rr=%f rmssd=%f] [hf=%f lf=%f lfhfr=%f hflfr=%f]", snn50, ssdnn, spnn50, srr, rmssdv, shf, slf, lfhfr, hflfr];
        [ecgStatus2 setText:str];
    });
}

-(void) ecgHRVTDAlgoValue: (NSNumber*)nn50 sdnn:(NSNumber*)sdnn pnn50:(NSNumber*)pnn50 rrTranIndex:(NSNumber*)rrTranIndex rmssd:(NSNumber*)rmssd {
    snn50 = [nn50 floatValue];
    ssdnn = [sdnn floatValue];
    spnn50 = [pnn50 floatValue];
    srr = [rrTranIndex floatValue];
    rmssdv = [rmssd floatValue];
    [self updateHRVAnalysis];
}

-(void) ecgHRVFDAlgoValue: (NSNumber*)hf lf:(NSNumber*)lf lfhf_ratio:(NSNumber*)lfhf_ratio hflf_ratio:(NSNumber*)hflf_ratio {
    shf = [hf floatValue];
    slf = [lf floatValue];
    lfhfr = [lfhf_ratio floatValue];
    hflfr = [hflf_ratio floatValue];
    [self updateHRVAnalysis];
}

#ifdef USE_CANNED_DATA
-(void) sendRawdata {
    static long long lasttimestamp = 0;
    
    if (rawArray == NULL || [rawArray count] == 0) {
        NSLog(@"raw data is not found!");
        exit(1);
    }
    
    //fill the pq first
    while (!exitRawThread) {
        if (rawIndex == 0 || rawIndex % 200 == 0) {
            int16_t poor_signal[1];
            poor_signal[0] = 200;
            [[NskAlgoSdk sharedInstance] dataStream:NskAlgoDataTypeECGPQ data:poor_signal length:1];
            
        }
        //fill raw into SDK
        int16_t eeg_data[1];
        int value = [[rawArray objectAtIndex:rawIndex] intValue];
        eeg_data[0] = value;
        //NSLog(@"raw %d", value);
        
        [[NskAlgoSdk sharedInstance] dataStream:NskAlgoDataTypeECG data:eeg_data length:1];
        rawNum++;
        
        if (rawIndex < rawArray.count - 1) {
            rawIndex ++;
        }else{
            if (bSendQ == FALSE) {
                [[NskAlgoSdk sharedInstance] queryOveralQuality:NskAlgoDataTypeECG];
                bRcvQ = FALSE;
                bSendQ = TRUE;
            }
            
            if (bRcvQ == TRUE) {
                NSLog(@"all canned data are sent");
                [[NskAlgoSdk sharedInstance] stopProcess];
                return;
            }
        }
        
        if (rawIndex == 1) {
            lasttimestamp = [ViewController current_timestamp];
        } else if (rawIndex % 512 == 0) {
            long long ts = [ViewController current_timestamp];
            // NSLog(@"send ts %lld %d", ts - lasttimestamp, rawIndex);
            lasttimestamp = ts;
        }
        
        usleep(200);
    }
}
#endif

- (void) toggleSDK {
    if (bPaused) {
        [[NskAlgoSdk sharedInstance] startProcess];
    } else {
        [[NskAlgoSdk sharedInstance] pauseProcess];
    }
}

- (IBAction)startPausePress:(id)sender {
    [self toggleSDK];
}

- (IBAction)stopPress:(id)sender {
    [[NskAlgoSdk sharedInstance] stopProcess];
}

- (IBAction)dataPress:(id)sender {
#if defined TARGET_IPHONE_SIMULATOR || defined USE_CANNED_DATA
    [self sendRawFromFile];
#else
    static BOOL connected = false;
    if (connected == NO) {
        [[TGStream sharedInstance] initConnectWithAccessorySession];
    } else {
        [[TGStream sharedInstance] tearDownAccessorySession];
    }
#endif
}

- (int)convertSegmentToEegType {
    return -1;
}

- (void)hideGraph {
    [lineGraph setHidden:YES];
}

- (void)showGraph {
    [lineGraph setHidden:NO];
    [textView setHidden:YES];
    int xMax = defaultAlgoSetting[0].xRange;
    int yMin = defaultAlgoSetting[0].plotMinY;
    int yMax = defaultAlgoSetting[0].plotMinY + defaultAlgoSetting[0].plotMaxY;
    
    [lineGraph setConfig:0 xMax:xMax yMin:yMin yMax:yMax xCompress:defaultPlotParam[0].xCompressRate];
    [lineGraph setAllLineEnable:NO];
    for (int i = 0; i < defaultPlotParam[0].plotCount; ++i) {
        [lineGraph setDataRef:[graphContextList[0] getBuffer:i] index:i];
        [lineGraph setLineEnable:YES index:i];
    }
    [lineGraph setCursor:[graphContextList[0] getCursorIndex]];
}

+ (long long)current_timestamp {
    NSDate *date = [NSDate date];
    return [@(floor([date timeIntervalSince1970] * 1000)) longLongValue];
}

- (void)configECG {
    NskAlgoSdk *handle = [NskAlgoSdk sharedInstance];
    if ([checkboxStress isOn])
        assert([handle setECGStressAlgoConfig:30 stressPara:30] == YES);
    if ([checkboxHeartage isOn])
        assert([handle setECGHeartageAlgoConfig:30] == YES);
    if ([checkboxHRV isOn])
        assert([handle setECGHRVAlgoConfig:30] == YES);
    if ([checkboxAFib isOn])
        assert([handle setECGAFIBAlgoConfig:3.5] == YES);
    if ([checkboxHRVFD isOn])
        assert([handle setECGHRVFDAlgoConfig:30 interval:10] == YES);
    if ([checkboxHRVTD isOn])
        assert([handle setECGHRVTDAlgoConfig:30 interval:10] == YES);
}

- (void)configureProfile {
    /* Here do some api test on the profile api too */
    
    NskAlgoSdk *handle = [NskAlgoSdk sharedInstance];
    NSArray<NskProfile*> * profiles = [handle getProfiles];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    
    NskProfile * profile = [[NskProfile alloc] init];
    
    /* Add a sample profile */
    profile.userName = @"Bob";
    profile.gender = NO;
    profile.dob = [df dateFromString:@"1976-1-1"];
    profile.height = 170;
    profile.weight = 70;
    
    if ([handle updateProfile:profile] == NO) {
        NSLog(@"Cant create new profile");
        exit(-1);
    }
    
    /* Get the profile back */
    assert((profiles = [handle getProfiles]) != NULL);
    assert(profiles.count == 1);
    
    /* Remove all profiles */
    for (int i = 0; i < profiles.count; ++i) {
        assert([handle deleteProfile:profiles[i].userId] == YES);
    }
    
    profiles = [handle getProfiles];
    assert(profiles.count == 0);
    
    assert([handle updateProfile:profile] == YES);
    assert([handle updateProfile:profile] == NO);           /* only 1 profile is allowed at the moment */
    
    assert((profiles = [handle getProfiles]) != NULL);
    assert(profiles.count == 1);
    
    // set the first profile as active
    activeProfile = profiles[0].userId;
    if ([handle setActiveProfile:activeProfile] == NO) {
        NSLog(@"Cant set active profile");
        exit(-1);
    }
    
    NSUserDefaults * pre = [NSUserDefaults standardUserDefaults];
    NSData * data = [pre objectForKey:@"ecg data"];
    if ([handle setProfileBaseline:activeProfile type:NskAlgoEcgTypeHeartRate data:data] == YES) {
        NSLog(@"Set the baseline successfully");
    } else {
        NSLog(@"Fail to set the baseline");
    }
}

- (void)enableCheckbox:(NSString*)name {
    UISwitch * sw = NULL;
    if ([name isEqualToString:@"sm"]) {
        sw = checkboxSmooth;
    } else if ([name isEqualToString:@"af"]) {
        sw = checkboxAFib;
    } else if ([name isEqualToString:@"hv"]) {
        sw = checkboxHRV;
    } else if ([name isEqualToString:@"st"]) {
        sw = checkboxStress;
    } else if ([name isEqualToString:@"stv2"]) {
        sw = checkboxStress;
    } else if ([name isEqualToString:@"hr"]) {
        sw = checkboxHeartrate;
    } else if ([name isEqualToString:@"md"]) {
        sw = checkboxMood;
    } else if ([name isEqualToString:@"rr"]) {
        sw = checkboxResp;
    } else if ([name isEqualToString:@"ha"]) {
        sw = checkboxHeartage;
    } else if ([name isEqualToString:@"td"]) {
        sw = checkboxHRVTD;
    } else if ([name isEqualToString:@"fd"]) {
        sw = checkboxHRVFD;
    }
    
    if (sw != NULL) {
        [sw setEnabled:YES];
        [sw setOn:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // setup the ui
    NSArray * lines = [[NSArray alloc] init];
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *filePath = [mainBundle pathForResource:@"setupinfo" ofType:@"txt"];
    NSString *contents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    lines = [contents componentsSeparatedByString:@"\n"];
    
    if ([lines count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Invalid setup file"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        for (int i = 0; i < [lines count]; ++i) {
            [self enableCheckbox:[lines objectAtIndex:i]];
        }
    }
    
    // load the license
    // note: developer can hardcode the license key instead of loading from file
    lines = [[NSArray alloc] init];
    mainBundle = [NSBundle mainBundle];
    filePath = [mainBundle pathForResource:@"license" ofType:@"txt"];
    contents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    if (contents != NULL) {
        lines = [contents componentsSeparatedByString:@"\n"];
        for (int i = 0; i < [lines count]; ++i) {
            NSString * s = [lines objectAtIndex:i];
            NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:@"^license key=\"(.+?)\"" options:0 error:nil];
            NSTextCheckingResult * match = [regex firstMatchInString:s options:NSMatchingAnchored range:NSMakeRange(0, [s length])];
            NSRange needleRange = [match rangeAtIndex:1];
            
            if (needleRange.location != NSNotFound && needleRange.length > 0) {
                NSString * l = [s substringWithRange:needleRange];
                strcpy(license, [l UTF8String]);
            }
        }
    }
    
#if defined USE_CANNED_DATA || defined TARGET_IPHONE_SIMULATOR
    [[self dataButton] setTitle:@"Start Canned Data" forState:UIControlStateNormal];
#else
    [[self dataButton] setTitle:@"Connect ECG Device" forState:UIControlStateNormal];
    [[TGStream sharedInstance] setDelegate:self];
#endif
    // we use canned data for simulator
    [dataButton setHidden:NO];
    [dataButton setEnabled:NO];
    
    [startPauseButton setHidden:NO];
    [startPauseButton setEnabled:NO];
    
    for (int i=0;i<SegmentMax;i++) {
        graphContextList[i] = [[MultiLineGraphContext alloc] init];
        graphContextList[i].interval = defaultAlgoSetting[i].interval;
        graphContextList[i].xCompressRate = 1;
        graphContextList[i].xMax = defaultAlgoSetting[i].xRange;
        graphContextList[i].lineCount = defaultPlotParam[i].plotCount;
        graphContextList[i].bcqThreshold = defaultAlgoSetting[i].bcqThreshold;
        graphContextList[i].bcqValid = defaultAlgoSetting[i].bcqValid;
        graphContextList[i].bcqWindow = defaultAlgoSetting[i].bcqWindow;
        
        graphContextList[i].plotAvailable = defaultPlotParam[i].plotAvailable;
        
    }
    bRunning = FALSE;
}

- (NSString*)GetCurrentTimeStamp
{
    NSDate *now = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"hh:mm:ss:SSS";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    return [dateFormatter stringFromDate:now];
}

- (NSString *)timeInMiliSeconds
{
    NSDate *date = [NSDate date];
    NSString * timeInMS = [NSString stringWithFormat:@"%lld", [@(floor([date timeIntervalSince1970] * 1000)) longLongValue]];
    return timeInMS;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)labelForDateAtIndex:(NSInteger)index {
    return @"";
}

-(NSString *) NowString{
    
    NSDate *date=[NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return [dateFormatter stringFromDate:date];
}

#ifdef IOS_DEVICE

int rawCount = 0;

#pragma mark
#pragma COMM SDK Delegate

#ifndef TARGET_IPHONE_SIMULATOR
-(void)onDataReceived:(NSInteger)datatype data:(int)data obj:(NSObject *)obj deviceType:(DEVICE_TYPE)deviceType {
    if (deviceType != DEVICE_TYPE_MindWaveMobile && deviceType != DEVICE_TYPE_CardioChipStarterKit) {
        return;
    }
    switch (datatype) {
            
        case MindDataType_CODE_POOR_SIGNAL:
        {
            int16_t poor_signal[1];
            poor_signal[0] = (int16_t)data;
            [[NskAlgoSdk sharedInstance] dataStream:NskAlgoDataTypeECGPQ data:poor_signal length:1];
        }
            break;
            
        case MindDataType_CODE_RAW:
            rawCount++;
            if (bRunning == FALSE) {
                return;
            }
            
        {
            int16_t raw[1];
            raw[0] = (int16_t)data;
            [[NskAlgoSdk sharedInstance] dataStream:NskAlgoDataTypeECG data:raw length:1];
            //NSLog(@"raw %d\n",data);
        }
            break;
            
        default:
            //NSLog(@"%@\n NO defined data type %ld %d\n",[self NowString],(long)datatype,data);
            break;
    }
}
#endif

static NSUInteger checkSum=0;
bool bTGStreamInited = false;

-(void) onChecksumFail:(Byte *)payload length:(NSUInteger)length checksum:(NSInteger)checksum{
    checkSum++;
    NSLog(@"%@\n Check sum Fail:%lu\n",[self NowString],(unsigned long)checkSum);
    NSLog(@"CheckSum lentgh:%lu  CheckSum:%lu",(unsigned long)length,(unsigned long)checksum);
}

#ifndef TARGET_IPHONE_SIMULATOR
static ConnectionStates lastConnectionState = -1;
-(void)onStatesChanged:(ConnectionStates)connectionState{
    //NSLog(@"%@\n Connection States:%lu\n",[self NowString],(unsigned long)connectionState);
    if (lastConnectionState == connectionState) {
        return;
    }
    lastConnectionState = connectionState;
    switch (connectionState) {
        case STATE_COMPLETE:
            NSLog(@"TGStream: complete");
            break;
        case STATE_CONNECTED:
            NSLog(@"TGStream: connected");
            if (bTGStreamInited == false) {
                [[TGStream sharedInstance] initConnectWithAccessorySession];
                bTGStreamInited = true;
            }
            break;
        case STATE_CONNECTING:
            NSLog(@"TGStream: connecting");
            break;
        case STATE_DISCONNECTED:
            NSLog(@"TGStream: disconnected");
            if (bTGStreamInited == true) {
                [[TGStream sharedInstance] tearDownAccessorySession];
                bTGStreamInited= false;
            }
            break;
        case STATE_ERROR:
            NSLog(@"TGStream: error");
            break;
        case STATE_FAILED:
            NSLog(@"TGStream: failed");
            break;
        case STATE_INIT:
            NSLog(@"TGStream: init");
            break;
        case STATE_RECORDING_END:
            NSLog(@"TGStream: record end");
            break;
        case STATE_RECORDING_START:
            NSLog(@"TGStream: record start");
            break;
        case STATE_STOPPED:
            NSLog(@"TGStream: stopped");
            break;
        case STATE_WORKING:
            NSLog(@"TGStream: working");
            break;
    }
}

-(void)onRecordFail:(RecrodError)flag{
    NSLog(@"%@\n Record Fail:%lu\n",[self NowString],(unsigned long)flag);
}
#endif

#endif

#pragma mark
#pragma NSK EEG SDK Delegate
- (void) overallSignalQuality:(NSNumber *)signalQuality {
    if (signalStr == nil) {
        signalStr = [[NSMutableString alloc] init];
    }
    [signalStr setString:@""];
    [signalStr appendString:@"Signal quailty: "];
    
    bRcvQ = YES;
    NSString *str = [NSString stringWithFormat:@"overall-%@", signalQuality];
    [signalStr appendString:str];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.signalLabel.text = signalStr;
    });
}

- (void)signalQuality: (NskAlgoSignalQuality)signalQuality {
    if (signalStr == nil) {
        signalStr = [[NSMutableString alloc] init];
    }
    [signalStr setString:@""];
    [signalStr appendString:@"Signal quailty: "];
    
    switch (signalQuality) {
        case NskAlgoSignalQualityGood:
            [signalStr appendString:@"Good"];
            break;
        case NskAlgoSignalQualityMedium:
            [signalStr appendString:@"Medium"];
            break;
        case NskAlgoSignalQualityNotDetected:
            [signalStr appendString:@"Not detected"];
            break;
        case NskAlgoSignalQualityPoor:
            [signalStr appendString:@"Poor"];
            break;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        //code you want on the main thread.
        self.signalLabel.text = signalStr;
    });
}

- (void)stateChanged:(NskAlgoState)state reason:(NskAlgoReason)reason {
    bool showAlert = NO;
    
    if (stateStr == nil) {
        stateStr = [[NSMutableString alloc] init];
    }
    [stateStr setString:@""];
    [stateStr appendString:@"SDK State: "];
    switch (state) {
        case NskAlgoStateInited:
        {
            bRunning = FALSE;
            bPaused = TRUE;
            bRcvQ = FALSE;
            bSendQ = FALSE;
            [stateStr appendString:@"Inited"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [startPauseButton setTitle:@"Start" forState:UIControlStateNormal];
                [startPauseButton setEnabled:YES];
                [stopButton setEnabled:NO];
                [dataButton setEnabled:NO];
            });
        }
            break;
        case NskAlgoStatePause:
        {
            bPaused = TRUE;
            [stateStr appendString:@"Pause"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [startPauseButton setTitle:@"Start" forState:UIControlStateNormal];
                [startPauseButton setEnabled:YES];
                [stopButton setEnabled:YES];
                [dataButton setEnabled:NO];
            });
        }
            break;
        case NskAlgoStateRunning:
        {
            [stateStr appendString:@"Running"];
            bRunning = TRUE;
            bPaused = FALSE;
            dispatch_async(dispatch_get_main_queue(), ^{
                [startPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
                [startPauseButton setEnabled:YES];
                [stopButton setEnabled:YES];
                [dataButton setEnabled:YES];
            });
        }
            break;
        case NskAlgoStateStop:
        {
            [stateStr appendString:@"Stop"];
            bRunning = FALSE;
            bPaused = TRUE;
            dispatch_async(dispatch_get_main_queue(), ^{
                [startPauseButton setTitle:@"Start" forState:UIControlStateNormal];
                [startPauseButton setEnabled:YES];
                [stopButton setEnabled:NO];
                [dataButton setEnabled:NO];
            });
        }
            break;
        case NskAlgoStateUninited:
            [stateStr appendString:@"Uninit"];
            break;
            
            // Reserved states
        case NskAlgoStateAnalysingBulkData:
        case NskAlgoStateCollectingBaselineData:
            break;
    }
    switch (reason) {
        case NskAlgoReasonBaselineExpired:
            [stateStr appendString:@" | Baseline expired"];
            break;
        case NskAlgoReasonConfigChanged:
            [stateStr appendString:@" | Config changed"];
            break;
        case NskAlgoReasonNoBaseline:
            [stateStr appendString:@" | No Baseline"];
            break;
        case NskAlgoReasonSignalQuality:
            [stateStr appendString:@" | Signal quality"];
            showAlert = YES;
            break;
        case NskAlgoReasonUserProfileChanged:
            [stateStr appendString:@" | User profile changed"];
            break;
        case NskAlgoReasonUserTrigger:
            [stateStr appendString:@" | By user"];
            break;
        case NskAlgoReasonExpired:
        case NskAlgoReasonInternetError:
        case NskAlgoReasonKeyError:
            break;
    }
    printf("%s",[stateStr UTF8String]);
    printf("\n");
    dispatch_async(dispatch_get_main_queue(), ^{
        //code you want on the main thread.
        self.stateLabel.text = stateStr;
        if (showAlert == YES) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SDK Aborted"
                                                            message:stateStr
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    });
}

- (void)updateMultiLineGraphIfNeed:(int)segment{
    [lineGraph setCursor:[graphContextList[segment] getCursorIndex]];
}

- (void)ecgAlgoValue:(NskAlgoECGValueType)type ecg_value:(NSNumber *)value ECG_valid:(BOOL)ECG_valid {
    static int hr = 0, rhv = 0, m = 0, r2r = 0, hrv = 0, ha = 0, afib = 0, rd = 0, stress = 0, heartbeat = 0, respiR = 0;
    static int updateStatus = 0;
    
    if (ECG_valid == false) {
        return;
    }
    switch (type) {
        case NskAlgoEcgValueTypeStress:
            stress = [value intValue];
            break;
        case NskAlgoEcgValueTypeHeartRate:
            hr = [value intValue];
            updateStatus++;
            break;
        case NskAlgoEcgValueTypeRobust:
            rhv = [value intValue];
            updateStatus++;
            break;
        case NskAlgoEcgValueTypeMood:
            m = [value intValue];
            updateStatus++;
            break;
        case NskAlgoEcgValueTypeR2R:
            r2r = [value intValue];
            updateStatus++;
            break;
        case NskAlgoEcgValueTypeHRV:
            hrv = [value intValue];
            updateStatus++;
            break;
        case NskAlgoEcgValueTypeHeartage:
            ha = [value intValue];
            updateStatus++;
            break;
        case NskAlgoEcgValueTypeAFIB:
            afib = [value intValue];
            updateStatus++;
            break;
        case NskAlgoEcgValueTypeRDetected:
            ++rd;
            updateStatus++;
            break;
        case NskAlgoEcgValueTypeHeartbeat:
            heartbeat = [value intValue];
            break;
        case NskAlgoEcgValueTypeSmoothed: {
            static long long lasttimestamp = 0;
            static int cnt = 0;
            
            ++cnt;
            [graphContextList[SegmentECG] pushValue:([value doubleValue] * -1) index:0];
            [graphContextList[SegmentECG] pushCursor];
            [self updateMultiLineGraphIfNeed:SegmentECG];
            
            if (cnt == 1) {
                lasttimestamp = [ViewController current_timestamp];
            } else if (cnt % 512 == 0) {
                long long ts = [ViewController current_timestamp];
                // NSLog(@"rcv %lld %d", ts - lasttimestamp, cnt);
                lasttimestamp = ts;
            }
            
        }
            break;
        case NskAlgoEcgValueTypeRespiratoryRate:
            respiR = [value intValue];
            break;
        case NskAlgoEcgValueTypeBaselineUpdated:
        {
            //
            // save the baseline into preference
            // this can be saved in local device or to the cloud
            NSUserDefaults * pre = [NSUserDefaults standardUserDefaults];
            NskAlgoSdk * handle = [NskAlgoSdk sharedInstance];
            NSData * data = [handle getProfileBaseline:activeProfile type:NskAlgoEcgTypeHeartRate];
            [pre setObject:data forKey:@"ecg data"];
            [pre synchronize];
            NSLog(@"new baseline saved");
        }
            break;
        default:
            NSLog(@"type %ld value %@", (long)type, value);
            break;
    }
    
    if (updateStatus) {
        dispatch_async(dispatch_get_main_queue(), ^{
            while (updateStatus > 0) {
                ecgStatus.text = [NSString stringWithFormat:@"hr=%d,rhv=%d,m=%d,r2r=%d,hrv=%d,ha=%d,stress=%d,afib=%d,heartbeat=%d,respiR=%d", hr, rhv, m, r2r, hrv, ha, stress, afib, heartbeat, respiR];
                updateStatus--;
            }
        });
        
    }
}


@end
