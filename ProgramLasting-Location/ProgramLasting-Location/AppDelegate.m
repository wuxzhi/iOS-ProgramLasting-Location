//
//  AppDelegate.m
//  ProgramLasting-Location
//
//  Created by wxzhi on 2017/9/21.
//  Copyright © 2017年 wxzhi. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
@interface AppDelegate ()<CLLocationManagerDelegate>
/** 位置*/
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self authorizationLocationWithLaunchOptions:launchOptions];
    
    return YES;
}

#pragma mark ---授权并开启定位权限
/**
 持久授权

 @param launchOptions 判断拉起程序方法用的--UIApplicationLaunchOptionsLocationKey(持久定位拉起程序)
 */
- (void)authorizationLocationWithLaunchOptions:(NSDictionary *)launchOptions{
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyThreeKilometers];
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
        if ( [self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] )
        {
            [self.locationManager requestAlwaysAuthorization];
        }
    }
    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] > 8.0)
    {
        // 持久定位授权
        [_locationManager requestAlwaysAuthorization];
    }
    
    if ([_locationManager respondsToSelector:@selector(allowsBackgroundLocationUpdates)]) {
        [_locationManager setAllowsBackgroundLocationUpdates:YES];
    }
    
    _locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    
    self.locationManager.delegate = self;
    //定位开始
    [self.locationManager startUpdatingLocation];
}

/**
 *  进入后台就会调用
 *
 */
- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    //保持定位
    if ([CLLocationManager significantLocationChangeMonitoringAvailable])
    {
        [_locationManager stopUpdatingLocation];
        [_locationManager startMonitoringSignificantLocationChanges];
    }else{
        NSLog(@"Significant location change monitoring is not available.");
    }
    
    //一个后台任务标识符
    __block UIBackgroundTaskIdentifier background_task;
    background_task = [application beginBackgroundTaskWithExpirationHandler:^ {
        //系统强制关闭程序，将执行这个程序块，并停止运行应用程序（一般是用户点击耗电按钮关闭进程时）
        [application endBackgroundTask: background_task];
        background_task = UIBackgroundTaskInvalid;
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization]; // 永久授权
            [self.locationManager requestWhenInUseAuthorization]; //使用中授权
        }
        //可以通过backgroundTimeRemaining查看应用程序后台停留的时间
        NSLog(@"backgroundTimeRemaining = %f",application.backgroundTimeRemaining);
        [_locationManager startUpdatingLocation];
        
        //这里可以执行些其他东西，例如记时
        NSLog(@"...");
    });
}

//程序强制挂起(电话，锁屏等)完成后复原执行
- (void)applicationDidBecomeActive:(UIApplication *)application {
    if ([CLLocationManager significantLocationChangeMonitoringAvailable])
    {
        [_locationManager stopMonitoringSignificantLocationChanges];
        [_locationManager startUpdatingLocation];
    }else{
        NSLog(@"Significant location change monitoring is not available.");
    }
}

#pragma mark ----更新位置
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{//当用户位置改变时，系统会自动调用，这里必须写一点儿代码，否则后台时间刷新不管用
    
    CLLocation *location = [locations firstObject];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    //使用位置反编码对象获取位置信息
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks lastObject];
        
        NSString *address = ((NSArray *)placemark.addressDictionary[@"FormattedAddressLines"]).lastObject;
        
        NSLog(@"地址：%@",address);
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
