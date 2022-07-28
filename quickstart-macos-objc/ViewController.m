//
//  ViewController.m
//  deepar-macos-example
//
//  Created by Kod Biro on 07/08/2020.
//  Copyright © 2020 Kod Biro. All rights reserved.
//

#import "ViewController.h"
#import <DeepAR/DeepAR.h>
#import <DeepAR/CameraController.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

#define USE_EXTERNAL_CAMERA 0

@interface ViewController () <DeepARDelegate> {
    NSTimer* timer;
    CVPixelBufferRef selfie;
    BOOL liveMode;
    BOOL offscreen;
}

@property (nonatomic, strong) NSView* arview;
@property (nonatomic, strong) DeepAR* deepAR;
@property (nonatomic, strong) CameraController* cameraController;

@property (nonatomic, strong) NSMutableArray* effects;
@property (nonatomic, assign) NSInteger currentEffectIndex;


@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.currentEffectIndex = 0;

    // Instantiate DeepAR and add it to view hierarchy.
    self.deepAR = [[DeepAR alloc] init];
    [self.deepAR setLicenseKey:@"your_license_key_goes_here"];
    self.deepAR.delegate = self;

    self.arview = [self.deepAR initializeViewWithFrame:[NSScreen mainScreen].visibleFrame];

    [self.view addSubview:self.arview positioned:NSWindowBelow relativeTo:nil];

    self.cameraController = [[CameraController alloc] init];
    self.cameraController.deepAR = self.deepAR;
    
    //External camera device
    //self.cameraController.videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeExternalUnknown mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified];

    [self.cameraController startCamera];
    self.effects = [NSMutableArray array];
    [self.effects addObject:@"none"];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"viking_helmet.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"MakeupLook.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"Split_View_Look.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"Emotions_Exaggerator.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"Emotion_Meter.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"Stallone.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"flower_face.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"galaxy_background.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"Humanoid.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"Neon_Devil_Horns.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"Ping_Pong.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"Pixel_Hearts.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"Snail.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"Hope.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"Vendetta_Mask.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"Fire_Effect.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"burning_effect.deepar" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"Elephant_Trunk.deepar" ofType:@""]];

}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)viewWillLayout {
    [super viewWillLayout];
    if (self.arview) {
        self.arview.frame = self.view.bounds;
    }
}

- (void)viewWillAppear {
    [super viewWillAppear];
    [self.deepAR resume];
}

- (void)viewWillDisappear {
    [super viewWillDisappear];
    [self.deepAR pause];
}

- (void)switchEffect:(NSMutableArray*)array index:(NSInteger)index slot:(NSString*)slot {
    if ([array[index] isEqualToString:@"none"]) {
        // To clear slot, just pass nil as the path parameter.
        [self.deepAR switchEffectWithSlot:slot path:nil];
    } else {
        // Switches the effects in the slot. Path parameter is the absolute path to the effect file.
        // Slot is a way to have multiple effects active at the same time. There is no limitation to
        // the number of slots, but there can be only one active effect in one slot. If we load
        // the new effect in already occupied slot, the old effect will be removed and the new one
        // will be added.
        [self.deepAR switchEffectWithSlot:slot path:array[index]];
    }
}

- (IBAction)nextEffect:(id)sender {
    self.currentEffectIndex++;
    if (self.currentEffectIndex >= self.effects.count) {
        self.currentEffectIndex = 0;
    }
    [self switchEffect:self.effects index:self.currentEffectIndex slot:@"effect"];
}

- (IBAction)prevEffect:(id)sender {
    self.currentEffectIndex--;
    if (self.currentEffectIndex < 0) {
        self.currentEffectIndex = self.effects.count - 1;
    }
    [self switchEffect:self.effects index:self.currentEffectIndex slot:@"effect"];
}

- (IBAction)takeScreenshot:(id)sender {
    [self.deepAR takeScreenshot];
}

-(void)dealloc {
    [self.deepAR shutdown];
    if (self.arview) {
        [self.arview removeFromSuperview];
    }
}

- (void)didTakeScreenshot:(NSImage*)screenshot {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *picturesDirectory = [NSSearchPathForDirectoriesInDomains(NSPicturesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *newFilePath = [picturesDirectory stringByAppendingPathComponent:@"screenshot.jpeg"];
    if ([fileManager createFileAtPath:newFilePath contents:[@"DeepAR Screenshot" dataUsingEncoding:NSUTF8StringEncoding] attributes:nil]) {
        NSData *imageData = [screenshot TIFFRepresentation];
        NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
        NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
        imageData = [imageRep representationUsingType:NSBitmapImageFileTypeJPEG properties:imageProps];
        [imageData writeToFile:newFilePath atomically:NO];
    } else {
        NSLog(@"Create error!");
    }
}

- (void)didInitialize {
    
}

- (void)faceVisiblityDidChange:(BOOL)faceVisible {
    
}

@end
