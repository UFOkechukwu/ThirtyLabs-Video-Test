//
//  ViewController.h
//  Thirtylabs Test
//
//  Created by Rebecca Yaworsky on 6/8/15.
//  Copyright (c) 2015 U.F.Okechukwu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CMTime.h>

//Video Recorder
#import <MobileCoreServices/MobileCoreServices.h>
#import <MobileCoreServices/UTCoreTypes.h>

//Media Player
#import <MediaPlayer/MediaPlayer.h>


@class AVPlayerDemoPlaybackView;
@class AVPlayer;

@interface ViewController : UIViewController<UIImagePickerControllerDelegate,
UINavigationControllerDelegate, NSURLConnectionDelegate, UIAlertViewDelegate> {
    
    AVAssetExportSession *exporter;
    
    
    // Server Connection
    NSMutableData *_responseData;
    
    NSURL* videoPathUrl;
}

@property (strong, nonatomic) NSURL *videoPathUrl;

@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;

@property (strong, nonatomic) IBOutlet UIView *videoViewer_View;



- (IBAction)record_btn:(id)sender;
- (IBAction)share_btn:(id)sender;
- (IBAction)preview_btn:(id)sender;


@end

