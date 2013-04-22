//
//  AppDelegate.m
//  KechengIphoneTest
//
//  Created by zuoyl on 4/17/13.
//  Copyright (c) 2013 zuoyl. All rights reserved.
//

#import "AppDelegate.h"
#import "ChatViewController.h"
#import "ChatManager.h"
#import "TestUser.h"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    [self setupChatManager];
    ChatViewController* rootVC = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
    TestUser* myFriend = [[TestUser alloc] init];
    myFriend.user_id = 2;
    myFriend.userName = @"userB";
    myFriend.password = @"userB";
    rootVC.myFriend = myFriend;
    TestUser* me = [[TestUser alloc] init];
    me.userName = @"userA";
    me.password = @"userA";
    me.user_id = 1;
    rootVC.me = me;
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:rootVC];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)setupChatManager
{
    [ChatManager sharedInstance].serverHost = @"localhost";
    [ChatManager sharedInstance].serverPort = 5222;
    TestUser * user = [[TestUser alloc] init];
    user.userName = @"userA";
    user.password = @"userA";
    [ChatManager sharedInstance].me = user;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ChatManager sharedInstance] login];
    });
    NSArray * documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * filePath = [[documents objectAtIndex:0] stringByAppendingFormat:@"/corner.friendsxx"];
    [ChatDBHelper sharedInstance].chatDBPath = filePath;
    [[ChatDBHelper sharedInstance] createChatMessageTable];
}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
