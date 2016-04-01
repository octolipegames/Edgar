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
    
    [self loadMenuBackgroundWithSize:skView.bounds.size];

    myScene = [plpMyScene sceneWithSize:skView.bounds.size];
    myScene.scaleMode = SKSceneScaleModeAspectFill;
    [super viewDidLoad];
}

- (void)loadMenuBackgroundWithSize:(CGSize)size
{
    float menuWidth = size.width;
    float menuHeight = size.height;
    float left = 0;
    float bottom = 0;
    if(menuWidth*9 != menuHeight*16)    // We preserve the aspect ratio by cropping the animation
    {
        if(menuWidth*9 > menuHeight*16) // -> 4s: 4320 < 5120
        {
            menuHeight = menuWidth * 0.5625;
            bottom = (size.height - menuHeight)/2;
        }else{
            menuWidth = menuHeight * 1.77777778;
            left = (size.width - menuWidth)/2;
        }
    }
    
    CGRect MenuBackgroundFrame = CGRectMake(left, bottom, menuWidth, menuHeight);
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



- (IBAction)presentChoosenScene:(id)sender {
    UIButton *clicked = (UIButton *) sender;
    NSInteger choosenLevel = clicked.tag;
    // We remove the UI
    
    UIView *containerView = [clicked superview];
    
    [[containerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [containerView removeFromSuperview];
    
    [self presentTheScene: choosenLevel];
}

- (void)presentTheScene: (NSInteger)startLevel
{
    self.pauseButton.hidden = NO;
    self.suicideButton.hidden = NO;
    
    if(self.MenuBackground)
    {
        [self.MenuBackground removeFromSuperview];
        self.MenuBackground = nil;
    }

    NSLog(@"We present the scene…");
    SKView * spriteView = (SKView *)self.view;
    [spriteView presentScene:myScene];

    if(gamePaused == FALSE && startLevel > 0)
    {
        [(plpMyScene*)myScene resumeFromLevel:startLevel];
    }
    
    if(gamePaused == TRUE)
    {
        if(startLevel == 0)
        {
            NSLog(@"New game after a pause");
            spriteView.paused = NO;
            gamePaused = FALSE;
            [(plpMyScene*)myScene resumeFromLevel:startLevel];
        }else{
            NSLog(@"Resume after a pause");
            spriteView.paused = NO;
            [(plpMyScene*)myScene resumeAfterPause];
            gamePaused = FALSE;
        }
    }
}

- (IBAction)playGame:(id)sender {
    // this method gets called:
    // 1) when the user launches the game
    // 2) when he resumes again after a pause
    
    self.playButton.hidden = YES;
    self.creditsButton.hidden = YES;
    self.creditsText.hidden = YES;

    
    // 1) the user launches the game
//    if(gamePaused==FALSE)   // we set up the dialog
    if(1==1)   // we set up the dialog
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSInteger savedLevel = [defaults integerForKey:@"savedLevel"];
        
        UIView *containerView = [[UIView alloc] init];
        containerView.backgroundColor = [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1];
        
        if(savedLevel>0) // dialog: continue or new game
        {
            [containerView setFrame: CGRectMake(50, 100, self.view.bounds.size.width-100, self.view.bounds.size.height-200)];
            
            UITextView *myTextView = [[UITextView alloc] init];
            myTextView.text = [NSString stringWithFormat:@"You were at level %li...", (long)savedLevel+1];
            myTextView.textColor = [UIColor whiteColor];
            myTextView.backgroundColor = [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1];
            myTextView.editable = NO;
            [myTextView setFont:[UIFont fontWithName:@"Gill Sans" size:18]];
            
            float outsideMargin = 60;
            float insideMargin = 30;
            float buttonsVerticalPosition = containerView.bounds.size.height-50;
            float buttonWidth = (containerView.bounds.size.width/2) - (outsideMargin + insideMargin);
            float buttonNewGamePositionX = outsideMargin;
            float buttonContinuePositionX = buttonWidth + outsideMargin + 2*insideMargin;
            
            [myTextView setFrame: CGRectMake(20, 5, containerView.bounds.size.width-40, containerView.bounds.size.height-70)];
            
            
            UIButton *myButtonNewGame  =   [UIButton buttonWithType:UIButtonTypeRoundedRect];
            myButtonNewGame.tag = 0;
            myButtonNewGame.frame      =   CGRectMake(buttonNewGamePositionX, buttonsVerticalPosition, buttonWidth, 30.0);
            [myButtonNewGame setBackgroundColor: [UIColor whiteColor]];
            
            [myButtonNewGame setTitleColor: [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1] forState:UIControlStateNormal];
            [[myButtonNewGame layer] setMasksToBounds:YES];
            [[myButtonNewGame layer] setCornerRadius:5.0f];
            
            [myButtonNewGame setTitle: @"New Game" forState:UIControlStateNormal];
            [myButtonNewGame addTarget: self
                                action: @selector(presentChoosenScene:)
                      forControlEvents: UIControlEventTouchUpInside];
            
            UIButton *myButtonContinue  =   [UIButton buttonWithType:UIButtonTypeRoundedRect];
            myButtonContinue.tag = savedLevel;
            myButtonContinue.frame      =   CGRectMake(buttonContinuePositionX, buttonsVerticalPosition, buttonWidth, 30.0);
            [myButtonContinue setBackgroundColor: [UIColor whiteColor]];
            
            [myButtonContinue setTitleColor: [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1] forState:UIControlStateNormal];
            [[myButtonContinue layer] setMasksToBounds:YES];
            [[myButtonContinue layer] setCornerRadius:5.0f];
            
            [myButtonContinue setTitle: @"Resume" forState:UIControlStateNormal];
            [myButtonContinue addTarget: self
                                 action: @selector(presentChoosenScene:)
                       forControlEvents: UIControlEventTouchUpInside];
            
            [self.view addSubview: containerView];
            [containerView addSubview:myTextView];
            [containerView addSubview:myButtonNewGame];
            [containerView addSubview:myButtonContinue];
        }
        else // introduction dialog
        {
            [containerView setFrame: CGRectMake(50, 40, self.view.bounds.size.width-100, self.view.bounds.size.height-90)];
            
            UITextView *myTextView = [[UITextView alloc] init];
            myTextView.text = [NSString stringWithFormat:@"Dear Edgar,\nThank you for enrolling at GreenAlien. Your first task is to inspect an underground laboratory which does illegal in vivo alien testing.\nIn each room, you will find a plutonium cell. Collect it to activate the elevator and gain access to the next room.\nBut first, use our training room to get ready."];
            myTextView.textColor = [UIColor whiteColor];
            myTextView.backgroundColor = [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1];
            myTextView.editable = NO;
            [myTextView setFont:[UIFont fontWithName:@"Gill Sans" size:18]];
            
            float outsideMargin = 60;
            float insideMargin = 30;
            float buttonsVerticalPosition = containerView.bounds.size.height-50;
            float buttonWidth = (containerView.bounds.size.width/2) - (outsideMargin + insideMargin);
            float buttonNewGamePositionX = containerView.bounds.size.width/2 - buttonWidth/2;
            
            [myTextView setFrame: CGRectMake(20, 5, containerView.bounds.size.width-40, containerView.bounds.size.height-70)];
            
            
            UIButton *myButtonStartTutorial  =   [UIButton buttonWithType:UIButtonTypeRoundedRect];
            myButtonStartTutorial.tag = 0;
            myButtonStartTutorial.frame      =   CGRectMake(buttonNewGamePositionX, buttonsVerticalPosition, buttonWidth, 30.0);
            [myButtonStartTutorial setBackgroundColor: [UIColor whiteColor]];
            
            [myButtonStartTutorial setTitleColor: [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1] forState:UIControlStateNormal];
            [[myButtonStartTutorial layer] setMasksToBounds:YES];
            [[myButtonStartTutorial layer] setCornerRadius:5.0f];
            
            [myButtonStartTutorial setTitle: @"Continue" forState:UIControlStateNormal];
            [myButtonStartTutorial addTarget: self
                                action: @selector(presentChoosenScene:)
                      forControlEvents: UIControlEventTouchUpInside];
            
            [self.view addSubview: containerView];
            [containerView addSubview:myTextView];
            [containerView addSubview:myButtonStartTutorial];
        }

    }
    else    // go back after the game was paused, without dialog
    {
        [self presentTheScene:0];
    }
}


- (BOOL)shouldAutorotate
{
    return NO;
}

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
    gamePaused = TRUE;

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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // We save the current level
    int currentLevel = [(plpMyScene*)myScene getNextLevelIndex];
    if(currentLevel > 0)
    {
        [defaults setInteger:currentLevel forKey:@"savedLevel"];
        [defaults synchronize];
    }
    
    NSLog(@"Tout va fermer: niveau sauvé, terminating...");
    // Next version: we save the current level index
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
