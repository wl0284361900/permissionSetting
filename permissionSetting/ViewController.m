//
//  ViewController.m
//  permissionSetting
//
//  Created by ChunYi on 2020/4/17.
//  Copyright © 2020 ES711-apple-2. All rights reserved.
//

#import "ViewController.h"
#import <Photos/Photos.h>

#define iOS10 ([[UIDevice currentDevice].systemVersion doubleValue] >= 10.0)

@interface ViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *mImage;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

}
- (IBAction)accessPhoto:(id)sender {

    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if(status == PHAuthorizationStatusAuthorized){
                NSLog(@"允許使用");
                // 設定影像來源 這裡設定為相簿
                //iOS 9 之後 詢問相簿權限改成使用 PHPhotoLibrary
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                dispatch_async(dispatch_get_main_queue(), ^{
                    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    // 設置 delegate
                    imagePicker.delegate = self;
                    // 設定選完照片後可以編輯
                    imagePicker.allowsEditing = YES;
                    // 顯示相簿
                    [self presentViewController:imagePicker animated:YES completion:nil];
                });
                
            }else if(status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted){
                NSLog(@"使用者拒絕提供權限");
                NSLog(@"不允许状态，可以弹出一个alertview提示用户在隐私设置中开启权限");
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"跳轉至隱私權設定" message:@"相機權限存取未開啟，是否要設定" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *settingAction = [UIAlertAction actionWithTitle:@"設定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        NSString * urlString = @"App-Prefs:root=Privacy";
                        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]]) {
                            if (iOS10) {
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
                            }
                        }
                    }];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction: settingAction];
                    [alertController addAction: cancelAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                });
            }
        }];
    }else {
        //提示使用者，目前設備不支援相簿
        NSLog(@"提示使用者，目前設備不支援相簿");
    }
}

- (IBAction)takePicture:(id)sender {
    //檢查是否支援此Source Type(相機)
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){
                NSLog(@"允許權限:使用相機");
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //設定影像來源為相機
                    imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
                    imagePicker.delegate = self;
                    imagePicker.allowsEditing = YES;

                    //顯示UIImagePickerController
                    [self presentViewController:imagePicker animated:YES completion:^{}];
                });
                
            }else{
                NSLog(@"不允許");
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"跳轉至隱私權設定" message:@"相機權限存取未開啟，是否要設定" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *settingAction = [UIAlertAction actionWithTitle:@"設定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        NSString * urlString = @"App-Prefs:root=Privacy";
                        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]]) {
                            if (iOS10) {
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
                            }
                        }
                    }];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction: settingAction];
                    [alertController addAction: cancelAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                });
            }
        }];
    }
    else {
        //提示使用者，目前設備不支援相機
        NSLog(@"提示使用者，目前設備不支援相機");
    }
}

#pragma mark - UIImagePicker Delegate
//使用者按下確定時
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString * urlString = @"App-Prefs:root=Privacy";
    //取得剛拍攝的相片(或是由相簿中所選擇的相片)
    self.mImage.image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (self.mImage.image == nil) {
           // 如果沒有編輯 則是取得原始拍照的照片 UIImage
        self.mImage.image = [info objectForKey:UIImagePickerControllerOriginalImage];
       }

    //將照片存入相簿
    
    
//    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if(status == PHAuthorizationStatusAuthorized){
            NSLog(@"允許訪問");
            UIImageWriteToSavedPhotosAlbum(self.mImage.image, self, nil, nil);
        }else if(status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted){
            // 使用者拒絕提供權限
            NSLog(@"使用者拒絕提供權限");
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"跳轉至隱私權設定" message:@"相簿權限存取未開啟，是否要設定" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *settingAction = [UIAlertAction actionWithTitle:@"設定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]]) {
                        if (iOS10) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
                        }
                    }
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction: settingAction];
            [alertController addAction: cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }];
    [picker dismissViewControllerAnimated:YES completion:^{}];
}


//使用者按下取消時
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    //一般情況下沒有什麼特別要做的事情
    [picker dismissViewControllerAnimated:YES completion:^{}];
}

@end
