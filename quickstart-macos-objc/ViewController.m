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

@property (nonatomic, strong) NSMutableArray* masks;
@property (nonatomic, assign) NSInteger currentMaskIndex;

@property (nonatomic, strong) NSMutableArray* effects;
@property (nonatomic, assign) NSInteger currentEffectIndex;

@property (nonatomic, strong) NSMutableArray* filters;
@property (nonatomic, assign) NSInteger currentFilterIndex;

@property (nonatomic, assign) NSInteger currentMode;

@property (nonatomic, strong) IBOutlet NSButton* masksButton;
@property (nonatomic, strong) IBOutlet NSButton* effectsButton;
@property (nonatomic, strong) IBOutlet NSButton* filtersButton;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.masksButton.layer.backgroundColor = NSColor.lightGrayColor.CGColor;
    self.effectsButton.layer.backgroundColor = NSColor.clearColor.CGColor;
    self.filtersButton.layer.backgroundColor = NSColor.clearColor.CGColor;
    self.currentMode = 0;
    self.currentMaskIndex = 0;
    self.currentEffectIndex = 0;
    self.currentFilterIndex = 0;

    // Instantiate DeepAR and add it to view hierarchy.
    self.deepAR = [[DeepAR alloc] init];
    [self.deepAR setLicenseKey:@"your_license_key_goes_here"];
    self.deepAR.delegate = self;

    self.arview = [self.deepAR initializeViewWithFrame:[NSScreen mainScreen].visibleFrame];

    [self.view addSubview:self.arview positioned:NSWindowBelow relativeTo:nil];

    self.cameraController = [[CameraController alloc] init];
    self.cameraController.deepAR = self.deepAR;

    [self.cameraController startCamera];

    // Create the list of masks, effects and filters.
    self.masks = [NSMutableArray array];
    [self.masks addObject:@"none"];
    [self.masks addObject:[[NSBundle mainBundle]  pathForResource:@"aviators" ofType:@""]];
    [self.masks addObject:[[NSBundle mainBundle]  pathForResource:@"bigmouth" ofType:@""]];
    [self.masks addObject:[[NSBundle mainBundle]  pathForResource:@"dalmatian" ofType:@""]];
    [self.masks addObject:[[NSBundle mainBundle]  pathForResource:@"fatify" ofType:@""]];
    [self.masks addObject:[[NSBundle mainBundle]  pathForResource:@"flowers" ofType:@""]];
    [self.masks addObject:[[NSBundle mainBundle]  pathForResource:@"grumpycat" ofType:@""]];
    [self.masks addObject:[[NSBundle mainBundle]  pathForResource:@"koala" ofType:@""]];
    [self.masks addObject:[[NSBundle mainBundle]  pathForResource:@"lion" ofType:@""]];
    [self.masks addObject:[[NSBundle mainBundle]  pathForResource:@"mudMask" ofType:@""]];
    [self.masks addObject:[[NSBundle mainBundle]  pathForResource:@"pug" ofType:@""]];
    [self.masks addObject:[[NSBundle mainBundle]  pathForResource:@"slash" ofType:@""]];
    [self.masks addObject:[[NSBundle mainBundle]  pathForResource:@"sleepingmask" ofType:@""]];
    [self.masks addObject:[[NSBundle mainBundle]  pathForResource:@"smallface" ofType:@""]];
    [self.masks addObject:[[NSBundle mainBundle]  pathForResource:@"teddycigar" ofType:@""]];
    [self.masks addObject:[[NSBundle mainBundle]  pathForResource:@"tripleface" ofType:@""]];
    [self.masks addObject:[[NSBundle mainBundle]  pathForResource:@"twistedFace" ofType:@""]];

    self.effects = [NSMutableArray array];
    [self.effects addObject:@"none"];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"fire" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"heart" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"blizzard" ofType:@""]];
    [self.effects addObject:[[NSBundle mainBundle]  pathForResource:@"rain" ofType:@""]];

    self.filters = [NSMutableArray array];
    [self.filters addObject:@"none"];
    [self.filters addObject:[[NSBundle mainBundle]  pathForResource:@"tv80" ofType:@""]];
    [self.filters addObject:[[NSBundle mainBundle]  pathForResource:@"drawingmanga" ofType:@""]];
    [self.filters addObject:[[NSBundle mainBundle]  pathForResource:@"sepia" ofType:@""]];
    [self.filters addObject:[[NSBundle mainBundle]  pathForResource:@"bleachbypass" ofType:@""]];
    [self.filters addObject:[[NSBundle mainBundle]  pathForResource:@"realvhs" ofType:@""]];
    [self.filters addObject:[[NSBundle mainBundle]  pathForResource:@"filmcolorperfection" ofType:@""]];
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
    switch (self.currentMode) {
        case 0:
            [self masksSelected:self];
            break;
        case 1:
            [self effectsSelected:self];
            break;
        case 2:
            [self filtersSelected:self];
            break;
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
    
    switch (self.currentMode) {
        case 0:
            self.currentMaskIndex++;
            if (self.currentMaskIndex >= self.masks.count) {
                self.currentMaskIndex = 0;
            }
            [self switchEffect:self.masks index:self.currentMaskIndex slot:@"mask"];
            break;
        case 1:
            self.currentEffectIndex++;
            if (self.currentEffectIndex >= self.effects.count) {
                self.currentEffectIndex = 0;
            }
            [self switchEffect:self.effects index:self.currentEffectIndex slot:@"effect"];
            break;
        case 2:
            self.currentFilterIndex++;
            if (self.currentFilterIndex >= self.filters.count) {
                self.currentFilterIndex = 0;
            }
            [self switchEffect:self.filters index:self.currentFilterIndex slot:@"filter"];
            break;
            
        default:
            break;
    }
}

- (IBAction)prevEffect:(id)sender {
    
    switch (self.currentMode) {
        case 0:
            self.currentMaskIndex--;
            if (self.currentMaskIndex < 0) {
                self.currentMaskIndex = self.masks.count - 1;
            }
            [self switchEffect:self.masks index:self.currentMaskIndex slot:@"mask"];
            break;
        case 1:
            self.currentEffectIndex--;
            if (self.currentEffectIndex < 0) {
                self.currentEffectIndex = self.effects.count - 1;
            }
            [self switchEffect:self.effects index:self.currentEffectIndex slot:@"effect"];
            break;
        case 2:
            self.currentFilterIndex--;
            if (self.currentFilterIndex < 0) {
                self.currentFilterIndex = self.filters.count - 1;
            }
            [self switchEffect:self.filters index:self.currentFilterIndex slot:@"filter"];
            break;
            
        default:
            break;
    }
}

- (IBAction)takeScreenshot:(id)sender {
    [self.deepAR takeScreenshot];
}

- (IBAction)masksSelected:(id)sender {
    self.currentMode = 0;
    self.masksButton.layer.backgroundColor = NSColor.lightGrayColor.CGColor;
    self.effectsButton.layer.backgroundColor = NSColor.clearColor.CGColor;
    self.filtersButton.layer.backgroundColor = NSColor.clearColor.CGColor;
}

- (IBAction)effectsSelected:(id)sender {
    self.currentMode = 1;
    self.masksButton.layer.backgroundColor = NSColor.clearColor.CGColor;
    self.effectsButton.layer.backgroundColor = NSColor.lightGrayColor.CGColor;
    self.filtersButton.layer.backgroundColor = NSColor.clearColor.CGColor;
}

- (IBAction)filtersSelected:(id)sender {
    self.currentMode = 2;
    self.masksButton.layer.backgroundColor = NSColor.clearColor.CGColor;
    self.effectsButton.layer.backgroundColor = NSColor.clearColor.CGColor;
    self.filtersButton.layer.backgroundColor = NSColor.lightGrayColor.CGColor;
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
