//
//  plpAppDelegate.m
//
//  Edgar The Explorer
//
//  Copyright (c) 2014-2016 Filipe Mathez and Paul Ronga
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU Lesser General Public License as published by
//  the Free Software Foundation; either version 2.1 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU Lesser General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public License
//  along with this program; if not, write to the Free Software Foundation,
//  Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
//
////////////////////////////////////////////////////////////////////////////////////////////

#import "plpAppDelegate.h"
#import "plpViewController.h"

//´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´
//
//  Our delegate responds to key changes in the app state
//  Example: app will quit or become inactive
//
//................................................


@implementation plpAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Apple: “Override point for customization after application launch.”
    return YES;
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"Delegate says: Memory warning!");
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // To do: call [CONTROLLER forcePause] here
    
    // Apple: “Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.”
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"Delegate says: app did enter background");
    // Apple: “Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.”
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Apple: “Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.”
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Apple: “Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.”
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"Delegate say: app will terminate.");
    // Apple: “Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.”
}

@end
