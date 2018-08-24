//
//  ViewController.m
//  cam_imu_gps_LOGGER
//
//  Created by Mac on 21/08/2018.
//  Copyright © 2018 Mac. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    CMMotionManager *motionManager;
    CLLocationManager *locationManager;
    UIImagePickerController *pickerController;
    
    double currentAccelX;
    double currentAccelY;
    double currentAccelZ;
    double currentRotX;
    double currentRotY;
    double currentRotZ;
    double currentPitchX;
    double currentRollY;
    double currentYawZ;
    
    double currentLatitude;
    double currentLongitude;
    
    double currentMaxAccelX;
    double currentMaxAccelY;
    double currentMaxAccelZ;
    double currentMaxRotX;
    double currentMaxRotY;
    double currentMaxRotZ;
    
    bool isRecording;
    
    NSString *theDate;
    NSDateFormatter *dateFormat;
    
    NSTimer *_timer;
    
    double FPS;
    
    NSString *logString;
    long long millisecondedDate;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //--------
    FPS = 30.;
    //logString = @"";
    
    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy||HH:mm:SS"];
    
    currentMaxAccelX = 0;
    currentMaxAccelY = 0;
    currentMaxAccelZ = 0;
    
    currentMaxRotX = 0;
    currentMaxRotY = 0;
    currentMaxRotZ = 0;
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
    }
    NSArray *availableMediaTypes = [UIImagePickerController
                                    availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    if (![availableMediaTypes containsObject:(NSString *)kUTTypeMovie]) {
        // Video recording is not supported.
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no video support"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        [myAlertView show];
        
    }
    pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    pickerController.allowsEditing = NO;
    pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    pickerController.mediaTypes = [NSArray arrayWithObjects: (NSString *) kUTTypeMovie, nil];
    pickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
    pickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
    isRecording = false;
    //--------
    motionManager = [[CMMotionManager alloc] init];
    motionManager.accelerometerUpdateInterval = 1./FPS;
    motionManager.gyroUpdateInterval = 1./FPS;
    motionManager.deviceMotionUpdateInterval = 1./FPS;
    
    [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                                 [self outputAccelertionData:accelerometerData.acceleration];
                                                 if(error){
                                                     UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Can't start accelerometer update" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                                     [myAlertView show];
                                                 }
                                             }];
    
    [motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue]
                                    withHandler:^(CMGyroData *gyroData, NSError *error) {
                                        [self outputRotationData:gyroData.rotationRate];
                                        if(error){
                                            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Can't start gyroscope update" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                            [myAlertView show];
                                        }
                                    }];
    
    [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
                                            withHandler:^(CMDeviceMotion *devmotData, NSError *error) {
                                                [self outputDeviceMotionData:devmotData.attitude];
                                                if(error){
                                                    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Can't start deviceMotion update" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                                    [myAlertView show];
                                                }
                                            }];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    currentAccelX = acceleration.x;
    currentAccelY = acceleration.y;
    currentAccelZ = acceleration.z;
    
    if(fabs(currentAccelX) > fabs(currentMaxAccelX))
    {
        currentMaxAccelX = currentAccelX;
    }
    if(fabs(currentAccelY) > fabs(currentMaxAccelY))
    {
        currentMaxAccelY = currentAccelY;
    }
    if(fabs(currentAccelZ) > fabs(currentMaxAccelZ))
    {
        currentMaxAccelZ = currentAccelZ;
    }
}

-(void)outputRotationData:(CMRotationRate)rotation
{
    currentRotX = rotation.x;
    currentRotY = rotation.y;
    currentRotZ = rotation.z;
    
    if(fabs(currentRotX) > fabs(currentMaxRotX))
    {
        currentMaxRotX = currentRotX;
    }
    if(fabs(currentRotY) > fabs(currentMaxRotY))
    {
        currentMaxRotY = currentRotY;
    }
    if(fabs(currentRotZ) > fabs(currentMaxRotZ))
    {
        currentMaxRotZ = currentRotZ;
    }
}

-(void)outputDeviceMotionData:(CMAttitude *)attitude
{
    currentPitchX = attitude.pitch;
    currentRollY = attitude.roll;
    currentYawZ = attitude.yaw;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:@"Failed to get location"
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        currentLatitude = currentLocation.coordinate.latitude;
        currentLongitude = currentLocation.coordinate.longitude;
    }
}


- (IBAction)startAction:(id)sender {
    UIView *overlayView;
    overlayView = [[UIView alloc] initWithFrame:self.view.bounds];

    UIView *ssView;
    
    /*CGRect vRect = CGRectMake(self.view.frame.size.width - 86, self.view.frame.size.height/2 - 35, 70, 70);
    CGRect hRect = CGRectMake(self.view.frame.size.width/2 - 35, self.view.frame.size.height - 86, 70, 70);
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
    {
        ssView = [[UIView alloc] initWithFrame:vRect];    }
    else
    {
        ssView = [[UIView alloc] initWithFrame:hRect];    }*/
    
    CGRect ipadRect = CGRectMake(self.view.frame.size.width - 86, self.view.frame.size.height/2 - 35, 70, 70);
    CGRect iphoneRect = CGRectMake(self.view.frame.size.width/2 - 35, self.view.frame.size.height - 86, 70, 70);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        ssView = [[UIView alloc] initWithFrame:ipadRect];    }
    else
    {
        ssView = [[UIView alloc] initWithFrame:iphoneRect];    }
    
    [ssView setUserInteractionEnabled:YES];
    // Background color below is only there to make sure myt pseudo-button overlaps native Start/Stop button
    [ssView setBackgroundColor:[UIColor colorWithRed:0 green:1 blue:0 alpha:0.5f]];
    
    UITapGestureRecognizer *t = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [ssView addGestureRecognizer:t];
    
    [overlayView addSubview:ssView];
    
    pickerController.cameraOverlayView = overlayView;
    
    [self presentViewController:pickerController animated:YES completion:NULL];
    
}

-(void)tapped:(id)sender {
    
    if (isRecording) {
        [pickerController stopVideoCapture];
        //NSLog(@"Video capturing stopped...");
        // add your business logic here ie stop updating progress bar etc...
        [pickerController.cameraOverlayView setHidden:YES];
        isRecording = NO;
        
        if ([_timer isValid]) {
            [_timer invalidate];
        }
        _timer = nil;
        
        logString = [NSString stringWithFormat:@"%@\r\nMax Values: %f, %f, %f, %f, %f, %f \r\n",
                     logString,
                     currentMaxAccelX, currentMaxAccelY, currentMaxAccelZ,
                     currentMaxRotX, currentMaxRotY, currentMaxRotZ];
        
        return;
    }
    
    if ([pickerController startVideoCapture]) {
        //NSLog(@"Video capturing started...");
        // add your business logic here ie start updating progress bar etc...
        
        NSDate *now = [[NSDate alloc] init];
        theDate = [dateFormat stringFromDate:now];
        
        isRecording = YES;
        
        currentMaxAccelX = 0;
        currentMaxAccelY = 0;
        currentMaxAccelZ = 0;
        
        currentMaxRotX = 0;
        currentMaxRotY = 0;
        currentMaxRotZ = 0;
        
        logString = @"Timestamp AccellX AccelY AccelZ RotX RotY RotZ Pitch Roll Yaw Latitude Longitude\r\n(Ms from 1970) (g) (g) (g) (r/s) (r/s) (r/s) (r) (r) (r) (deg) (deg)\r\n";
        
        if (!_timer) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:1./FPS
                                                      target:self
                                                    selector:@selector(_timerFired:)
                                                    userInfo:nil
                                                     repeats:YES];
        }
    }
    
}

- (void)_timerFired:(NSTimer *)timer {
    //NSLog(@"ping");
    millisecondedDate = (long long)([[NSDate date] timeIntervalSince1970]* 1000.0);
    logString = [NSString stringWithFormat:@"%@%lld, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f\r\n",
                 logString,
                 millisecondedDate,
                 currentAccelX, currentAccelY, currentAccelZ,
                 currentRotX, currentRotY, currentRotZ,
                 currentPitchX, currentRollY, currentYawZ,
                 currentLatitude, currentLongitude];
}

-(BOOL) writeVideoToFile:(NSURL *)aURL{
    NSData *videoData = [NSData dataWithContentsOfURL:aURL];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    /*NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"Default Album"];
     if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
     [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];*/
    
    NSString *videopath= [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@/%@.MOV",documentsDirectory,theDate]];
    
    BOOL success = [videoData writeToFile:videopath atomically:YES];
    
    return success;
}

-(BOOL) writeStringToFile:(NSString *)aString{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *filepath= [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@/%@.txt",documentsDirectory,theDate]];
    
    BOOL success = [[aString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:filepath atomically:YES];
    
    return success;
}

- (void)imagePickerController:(UIImagePickerController *)pickerController didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [pickerController dismissViewControllerAnimated:YES completion:NULL];
    NSURL *videoURL = info[UIImagePickerControllerMediaURL];
    
    /*
     NSString *tempFilePath = [videoURL path];
     if(UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(tempFilePath)){
        UISaveVideoAtPathToSavedPhotosAlbum(tempFilePath, self, @selector(video:didFinishSavingWithError:contextInfo:), (__bridge void*) tempFilePath);
    }*/
    
    //NSLog(@"%@", logString);
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Saving"
                                 message:@"Saving the Data"
                                 preferredStyle:UIAlertControllerStyleAlert];
    //[self presentViewController:alert animated:YES completion:nil];
    
    [self writeVideoToFile:videoURL];
    [self writeStringToFile:logString];
    
    //[self dismissViewControllerAnimated:YES completion:nil];

    //BOOL success = [videoData writeToURL:videopath atomically:YES];
    

    //NSLog(@"Successs:::: %@", success ? @"YES" : @"NO");
    //NSLog(@"video path --> %@",videopath);
}

- (void) video: (NSString *) videoPath
didFinishSavingWithError: (NSError *) error
   contextInfo: (void *) contextInfo {
    if(error){
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                          message:[NSString stringWithFormat:@"Finished saving video with error: %@", error]
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles: nil];
    
        [myAlertView show];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)pickerController {
    
    isRecording = NO;
    [pickerController dismissViewControllerAnimated:YES completion:NULL];
    
}

@end
