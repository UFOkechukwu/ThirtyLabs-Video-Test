//
//  ViewController.m
//  Thirtylabs Test
//
//  Created by Rebecca Yaworsky on 6/8/15.
//  Copyright (c) 2015 U.F.Okechukwu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    videoPathUrl = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)record_btn:(id)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = @[(NSString*)kUTTypeMovie];
        
        imagePicker.videoQuality = UIImagePickerControllerQualityTypeLow;
        imagePicker.videoMaximumDuration = 2;
        imagePicker.delegate = self;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"Sorry, there's no camera on this device!" delegate:nil cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil];
        [alertView show];
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    
    // grab our movie URL
    NSURL *chosenMovie = info[UIImagePickerControllerMediaURL];
    
    [self exportVideoWithPath:[chosenMovie path]];
    
    // save it to the Camera Roll
    //UISaveVideoAtPathToSavedPhotosAlbum([chosenMovie path], nil, nil, nil);
    
    // and dismiss the picker
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)exportVideoWithPath:(NSString *)videoPathName{
    
    //loading Asset
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:videoPathName]];
    
    //create track
    AVAssetTrack *clipVideoTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
    
    AVMutableVideoComposition* videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.frameDuration = CMTimeMake(1, 30);
    //here we are setting its render size to its height x height (Square)
    videoComposition.renderSize = CGSizeMake(clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.height);

    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30));
    
    AVMutableVideoCompositionLayerInstruction* transformer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:clipVideoTrack];
    
    //shift the viewing square up to the video TOP
    CGAffineTransform t1 = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, 0 );
    
    //Make video square portrait
    CGAffineTransform t2 = CGAffineTransformRotate(t1, M_PI_2);
    
    CGAffineTransform finalTransform = t2;
    [transformer setTransform:finalTransform atTime:kCMTimeZero];
    
    //add the transformer layer instructions, then add to video composition
    instruction.layerInstructions = @[transformer];
    videoComposition.instructions = @[instruction];
    
    //Create an Export Path, save video
    NSString * documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *exportPath = [documentsPath stringByAppendingFormat:@"/squaredVideo.mov"];
    NSURL *exportUrl = [NSURL fileURLWithPath:exportPath];
    
    [[NSFileManager defaultManager]  removeItemAtURL:exportUrl error:nil];
    
    //Export
    exporter = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality] ;
    exporter.videoComposition = videoComposition;
    exporter.outputURL = exportUrl;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             //Call when finished
             [self exportDidFinish:exporter];
         });
     }];
    
    
    
}

- (void)exportDidFinish:(AVAssetExportSession*)session
{
    //Play the New Cropped video
    NSURL *outputURL = session.outputURL;
    
    
    
    
    videoPathUrl = outputURL;
    
    NSLog(@"saved!!!! %@",[videoPathUrl path]);
    
    if (![[videoPathUrl path] isEqualToString:@"null"]) {
        [self playTheVideoPlayer];
    }
    
    
    
    UISaveVideoAtPathToSavedPhotosAlbum([outputURL path], nil, nil, nil);
    
}


- (IBAction)share_btn:(id)sender {
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Uploader"
                                                    message:@"Share with friends"
                                                   delegate:self
                                          cancelButtonTitle:@"CANCEL"
                                          otherButtonTitles:@"Post Now!",nil];
    [alert show];
    
    
    /*
     NSData *data = [NSData dataWithContentsOfFile:[videoPathUrl path]];
     NSMutableString *urlString = [[NSMutableString alloc] initWithFormat:@"name=thefile&&filename=recording"];
     [urlString appendFormat:@"%@", data];
     NSData *postData = [urlString dataUsingEncoding:NSASCIIStringEncoding
     allowLossyConversion:YES];
     NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
     NSString *baseurl = @"http://skillsetng.com/ugo_upload/interview/photoUploder.php";
     
     NSURL *url = [NSURL URLWithString:baseurl];
     NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
     [urlRequest setHTTPMethod: @"POST"];
     [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
     [urlRequest setValue:@"application/x-www-form-urlencoded"
     forHTTPHeaderField:@"Content-Type"];
     [urlRequest setHTTPBody:postData];
     
     
     NSURLResponse *response = nil;
     NSError *error = nil;
     
     NSData *data2 = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
     
     NSString *myString = [[NSString alloc] initWithData:data2 encoding:NSUTF8StringEncoding];
     
     NSLog( @"data:: %@" , myString ) ;
     
     //NSURLConnection *connection = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
     //[connection start];
     
     
     NSLog(@"Video Upload Started!");
     */

}

/*
 - (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
 // A response has been received, this is where we initialize the instance var you created
 // so that we can append data to it in the didReceiveData method
 // Furthermore, this method is called each time there is a redirect so reinitializing it
 // also serves to clear it
 _responseData = [[NSMutableData alloc] init];
 }
 
 - (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
 // Append the new data to the instance variable you declared
 [_responseData appendData:data];
 
 NSLog(@"didReceiveData");
 NSLog(@"%d",[_responseData length]);
 
 NSString *responsestring = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
 NSLog(@"Response =>> %@", responsestring);
 }
 
 - (NSCachedURLResponse *)connection:(NSURLConnection *)connection
 willCacheResponse:(NSCachedURLResponse*)cachedResponse {
 // Return nil to indicate not necessary to store a cached response for this connection
 return nil;
 }
 
 - (void)connectionDidFinishLoading:(NSURLConnection *)connection {
 // The request is complete and data has been received
 // You can parse the stuff in your instance variable now
 
 NSLog(@"connectionDidFinishLoading");
 NSLog(@"%d",[_responseData length]);
 
 }
 
 - (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
 // The request has failed for some reason!
 // Check the error var
 }
 
 */

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle=[alertView buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:@"Post Now!"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Uploader"
                                                        message:@"Your Video has been uploaded"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    
}


- (IBAction)preview_btn:(id)sender {
    
    if (![[videoPathUrl path] isEqualToString:@"null"]) {
        [self playTheVideoPlayer];
        
        NSLog(@"--- PLAY ---");
        [_moviePlayer play];
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Uploader"
                                                        message:@"Sorry this feature not working at present (TEST TIME LIMIT)"
                                                       delegate:nil
                                              cancelButtonTitle:@"CANCEL"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    
}


- (void)playTheVideoPlayer{
    
    NSURL *url = [NSURL URLWithString: [videoPathUrl path]];
    
    
    _moviePlayer =  [[MPMoviePlayerController alloc]
                     initWithContentURL:url];
    
    _moviePlayer.controlStyle = MPMovieControlStyleDefault;
    _moviePlayer.shouldAutoplay = NO;
    [_moviePlayer.view setFrame:_videoViewer_View.frame];
    [_moviePlayer setScalingMode:MPMovieScalingModeAspectFit];
    _moviePlayer.movieSourceType    = MPMovieSourceTypeStreaming;
    
    // prevent mute switch from switching off audio from movie player
    NSError *_error = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &_error];
    
    [self.view addSubview:_moviePlayer.view];
    [_moviePlayer setFullscreen:NO animated:YES];
}





@end
