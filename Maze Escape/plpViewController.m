//
//  plpViewController.m: the controller
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

#import "plpViewController.h"
#import "plpMyScene.h"

@implementation plpViewController

- (void)viewDidLoad
{
    /* Animation */
    SKView * skView = (SKView *)self.view;
    NSLog(@"Bounds: %f, %f", skView.bounds.size.width, skView.bounds.size.height);
//    skView.showsFPS = YES;
//    [skView setValue:@(YES) forKey:@"_showsCulledNodesInNodeCount"];
    
    [self loadMenuBackgroundWithSize:skView.bounds.size];
    
    myScene = [plpMyScene sceneWithSize:skView.bounds.size];
    myScene.scaleMode = SKSceneScaleModeAspectFill;
    [super viewDidLoad];
}

- (void)loadMenuBackgroundWithSize:(CGSize)size
{
    CGRect MenuBackgroundFrame = CGRectMake(0.0f, 0.0f, size.width, size.height);
    self.MenuBackground = [[UIImageView alloc] initWithFrame:MenuBackgroundFrame];

    self.MenuBackground.animationImages = [NSArray arrayWithObjects:
                                           [UIImage imageNamed:@"MenuBackground/M1-01.png"],
                                           [UIImage imageNamed:@"MenuBackground/M2-01.png"],
                                           [UIImage imageNamed:@"MenuBackground/M3-01.png"],
                                           [UIImage imageNamed:@"MenuBackground/M4-01.png"],
                                           [UIImage imageNamed:@"MenuBackground/M5-01.png"],
                                           [UIImage imageNamed:@"MenuBackground/M6-01.png"],
                                           [UIImage imageNamed:@"MenuBackground/M7-01.png"],
                                           [UIImage imageNamed:@"MenuBackground/M8-01.png"],
                                           [UIImage imageNamed:@"MenuBackground/M9-01.png"],
                                           [UIImage imageNamed:@"MenuBackground/M10-01.png"],
                                           [UIImage imageNamed:@"MenuBackground/M11-01.png"],
                                           [UIImage imageNamed:@"MenuBackground/M12-01.png"],
                                           [UIImage imageNamed:@"MenuBackground/M13-01.png"],
                                           [UIImage imageNamed:@"MenuBackground/M14-01.png"],
                                           [UIImage imageNamed:@"MenuBackground/M15-01.png"],
                                           [UIImage imageNamed:@"MenuBackground/M16-01.png"],
                                           [UIImage imageNamed:@"MenuBackground/M17-01.png"],
                                           nil];
    
    self.MenuBackground.animationDuration = 1;
    self.MenuBackground.animationRepeatCount = 0;
    [self.MenuBackground startAnimating];
    [self.view insertSubview: self.MenuBackground atIndex:1];
    
    //     Toucher l'image permet de fermer les crédits / To touch the screen closes the credits
    UITapGestureRecognizer *newTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeCredits)];
    [self.MenuBackground setUserInteractionEnabled:YES];
    [self.MenuBackground addGestureRecognizer:newTap];
    
}

- (IBAction)playGame:(id)sender {
    self.playButton.hidden = YES;
    self.pauseButton.hidden = NO;
    self.suicideButton.hidden = NO;
    self.creditsButton.hidden = YES;
    self.creditsText.hidden = YES;

    if(self.MenuBackground)
    {
        [self.MenuBackground removeFromSuperview];
        self.MenuBackground = nil;
        SKView * skView = (SKView *)self.view;
        [skView presentScene:myScene];
    }

    SKView *spriteView = (SKView *)self.view;

    if([spriteView isPaused])
    {
        spriteView.paused = NO;
        [(plpMyScene*)myScene resumeAfterPause];
        NSLog(@"Retour au jeu depuis le menu");
    }else{
        NSLog(@"Non pas aen pause");
    }
}


- (BOOL)shouldAutorotate
{
    return NO;
}

/*- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}*/
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskLandscape;
    } else {
        return UIInterfaceOrientationMaskLandscape;
    }
}
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskLandscape;
    } else {
        return UIInterfaceOrientationMaskLandscape;
    }
}
#endif

- (void)didReceiveMemoryWarning
{
    NSLog(@"Memory warning!");
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (IBAction)pauseButtonClicked:(id)sender {
    SKView *spriteView = (SKView *)self.view;
    if(!spriteView.paused){
        [spriteView setPaused:YES];
        [(plpMyScene*)myScene getsPaused];

        self.playButton.hidden = NO;
        self.creditsButton.hidden = NO;

        self.pauseButton.hidden = YES;
        self.suicideButton.hidden = YES;
        
        [self loadMenuBackgroundWithSize:spriteView.bounds.size];
    }
}

- (IBAction)suicideButtonClicked:(id)sender {
    [(plpMyScene*)myScene EdgarDiesOf:0];
}

- (IBAction)creditsButtonClicked:(id)sender {
    self.creditsText.hidden = NO;
}

-(void)closeCredits{
    self.creditsText.hidden = YES;
}

- (void)addButton
{
    NSLog(@"boum.");
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"app will resign active...");
    
    SKView *spriteView = (SKView *)self.view;
    if(!spriteView.paused){
        spriteView.paused = YES;
        NSLog(@"Will resign active => Mise en pause");
    }
    [(plpMyScene*)myScene getsPaused];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"did enter background");
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"Revient au premier plan");
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    SKView *spriteView = (SKView *)self.view;
    NSLog(@"Redevient active");
    if(spriteView.paused){
        spriteView.paused = NO;
    }
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"Tout va fermer: terminating...");
    // Next version: we save the current level index
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
