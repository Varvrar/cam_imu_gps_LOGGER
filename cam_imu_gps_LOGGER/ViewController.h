//
//  ViewController.h
//  cam_imu_gps_LOGGER
//
//  Created by Mac on 21/08/2018.
//  Copyright © 2018 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController : UIViewController<CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (IBAction)startAction:(id)sender;
//@property (strong, nonatomic) NSURL *videoURL;
//@property (strong, nonatomic) NSData *videoData;

@end

