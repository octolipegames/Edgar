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

//´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´
//
//  Our controller. Called when we launch the app.
//
//................................................


@implementation plpViewController

- (void)viewDidLoad
{
    /* Animation */
    SKView * skView = (SKView *)self.view;
    [self loadMenuBackgroundWithSize:skView.bounds.size];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pauseWhileInBackground)
                                                 name:@"pauseWhileInBackground"
                                               object:nil];
    
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
                                           [UIImage imageNamed:@"UI_img/MenuBackground/M1-01.png"],
                                           [UIImage imageNamed:@"UI_img/MenuBackground/M2-01.png"],
                                           [UIImage imageNamed:@"UI_img/MenuBackground/M3-01.png"],
                                           [UIImage imageNamed:@"UI_img/MenuBackground/M4-01.png"],
                                           [UIImage imageNamed:@"UI_img/MenuBackground/M5-01.png"],
                                           [UIImage imageNamed:@"UI_img/MenuBackground/M6-01.png"],
                                           [UIImage imageNamed:@"UI_img/MenuBackground/M7-01.png"],
                                           [UIImage imageNamed:@"UI_img/MenuBackground/M8-01.png"],
                                           [UIImage imageNamed:@"UI_img/MenuBackground/M9-01.png"],
                                           [UIImage imageNamed:@"UI_img/MenuBackground/M10-01.png"],
                                           [UIImage imageNamed:@"UI_img/MenuBackground/M11-01.png"],
                                           [UIImage imageNamed:@"UI_img/MenuBackground/M12-01.png"],
                                           [UIImage imageNamed:@"UI_img/MenuBackground/M13-01.png"],
                                           [UIImage imageNamed:@"UI_img/MenuBackground/M14-01.png"],
                                           [UIImage imageNamed:@"UI_img/MenuBackground/M15-01.png"],
                                           [UIImage imageNamed:@"UI_img/MenuBackground/M16-01.png"],
                                           [UIImage imageNamed:@"UI_img/MenuBackground/M17-01.png"],
                                           nil];
    
    self.MenuBackground.animationDuration = 1;
    self.MenuBackground.animationRepeatCount = 0;
    [self.MenuBackground startAnimating];
    [self.view insertSubview: self.MenuBackground atIndex:1];
    
    //   To touch the screen closes the credits
    UITapGestureRecognizer *newTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeCredits)];
    [self.MenuBackground setUserInteractionEnabled:YES];
    [self.MenuBackground addGestureRecognizer:newTap];
}



- (IBAction)doTutorial:(id)sender {
    UIButton *clicked = (UIButton *) sender;
    UIView *containerView = [clicked superview];
    [[containerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [containerView removeFromSuperview];
    
    [self newGameWithTutorial: TRUE];
    [(plpMyScene*)myScene computeSceneCenter];
}

- (IBAction)skipTutorial:(id)sender {
    UIButton *clicked = (UIButton *) sender;
    UIView *containerView = [clicked superview];
    [[containerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [containerView removeFromSuperview];
    
    [self newGameWithTutorial: FALSE];
    [(plpMyScene*)myScene computeSceneCenter];
}

- (IBAction)newGameButtonClicked:(id)sender {
    UIButton *clicked = (UIButton *) sender;
    UIView *containerView = [clicked superview];
    [[containerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [containerView removeFromSuperview];

    [self displayIntroductionDialog];
}

- (IBAction)resumeFreezedGame:(id)sender {
    UIView *container = [(UIGestureRecognizer *)sender view];
    if(container)
    {
        [container removeFromSuperview];
    }
    [self resumePausedGame];
}

- (IBAction)continueButtonClicked:(id)sender {
    UIButton *clicked = (UIButton *) sender;
    UIView *containerView = [clicked superview];
    [[containerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [containerView removeFromSuperview];
    // to use when the user doesn't want to do a new game!
    
    if(gamePaused == TRUE)
    {
        [self resumePausedGame];
    }else{
        [self loadSavedGame:clicked.tag];
    }
    [(plpMyScene*)myScene computeSceneCenter];
}

- (void)newGameWithTutorial: (BOOL) doTutorial
{
    self.pauseButton.hidden = NO;
    self.suicideButton.hidden = NO;
 
    
    if(gamePaused == FALSE){
        SKView * skView = (SKView *)self.view;
        myScene = [plpMyScene sceneWithSize:skView.bounds.size];
        myScene.scaleMode = SKSceneScaleModeAspectFill;
    }
    
    if(self.MenuBackground)
    {
        [self.MenuBackground removeFromSuperview];
        self.MenuBackground = nil;
    }
    
    // We start the new game
    SKView * spriteView = (SKView *)self.view;
    [spriteView presentScene:myScene];

    if(doTutorial == FALSE)
    {
        [(plpMyScene*)myScene resumeFromLevel:1];
    }
    
    if(gamePaused == TRUE)
    {
        spriteView.paused = NO;
        gamePaused = FALSE;
        if(doTutorial == TRUE)
        {
            [(plpMyScene*)myScene resumeFromLevel:0];
        }
    }
}

- (void)loadSavedGame: (NSInteger)startLevel
{
    self.pauseButton.hidden = NO;
    self.suicideButton.hidden = NO;
    
    if(gamePaused == FALSE){
        SKView * skView = (SKView *)self.view;
        myScene = [plpMyScene sceneWithSize:skView.bounds.size];
        myScene.scaleMode = SKSceneScaleModeAspectFill;
    }
    
    if(self.MenuBackground)
    {
        [self.MenuBackground removeFromSuperview];
        self.MenuBackground = nil;
    }
    
    SKView * spriteView = (SKView *)self.view;
    [spriteView presentScene:myScene];
    
    if(startLevel > 0)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        float totalTime = [defaults floatForKey:@"totalTime"];
        NSLog(@"T: retrieved totalTime: %f", totalTime);
        if(totalTime){
            NSLog(@"T: Saved totalTime loaded.");
            [(plpMyScene*)myScene saveAdditionalTime:totalTime];
        }else{
            NSLog(@"Warning: no total time found");
        }
    }
    [(plpMyScene*)myScene resumeFromLevel:startLevel];
}

- (void)resumePausedGame
{
    self.pauseButton.hidden = NO;
    self.suicideButton.hidden = NO;
    
    if(self.MenuBackground)
    {
        [self.MenuBackground removeFromSuperview];
        self.MenuBackground = nil;
    }
    
    SKView * spriteView = (SKView *)self.view;
    [spriteView presentScene:myScene];
    NSLog(@"Resume after a pause");
    spriteView.paused = NO;
    [(plpMyScene*)myScene resumeAfterPause];
    gamePaused = FALSE;
}

- (IBAction)playButtonClicked:(id)sender {
    // this method gets called when the round “play” button is pressed. It occurs:
    // - when the user launches the game
    // - when he resumes after a pause
    
    self.playButton.hidden = YES;
    self.creditsButton.hidden = YES;
    self.creditsText.hidden = YES;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger savedLevel = [defaults integerForKey:@"savedLevel"];
    
    
    if(savedLevel == 0)
    {
        if(gamePaused == TRUE) // Player is still doing tutorial
        {
            [self resumePausedGame];
        }else{
            [self displayIntroductionDialog];  // 1) New game; introduction dialog
        }
    }
    else // 2: savedLevel > 0 => “New Game” or “Resume”
    {
        UIView *containerView = [[UIView alloc] init];
        containerView.backgroundColor = [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1];
        [containerView setFrame: CGRectMake(50, 100, self.view.bounds.size.width-100, self.view.bounds.size.height-200)];
        
        // Text: “You were at level 1...”
        UITextView *myTextView = [[UITextView alloc] init];
        myTextView.text = [NSString stringWithFormat:@"You were at level %li...", (long)savedLevel];
        myTextView.textColor = [UIColor whiteColor];
        myTextView.backgroundColor = [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1];
        myTextView.editable = NO;
        [myTextView setFont:[UIFont fontWithName:@"GillSans" size:18]];
        [myTextView setFrame: CGRectMake(20, 5, containerView.bounds.size.width-40, containerView.bounds.size.height-70)];
        
        float outsideMargin = 60;
        float insideMargin = 30;
        float buttonsVerticalPosition = containerView.bounds.size.height-50;
        float buttonWidth = (containerView.bounds.size.width/2) - (outsideMargin + insideMargin);
        float buttonNewGamePositionX = outsideMargin;
        float buttonContinuePositionX = buttonWidth + outsideMargin + 2*insideMargin;
        
        // Left: “New Game”
        UIButton *buttonNewGame  =   [UIButton buttonWithType:UIButtonTypeRoundedRect];
        buttonNewGame.tag = 0;
        buttonNewGame.frame      =   CGRectMake(buttonNewGamePositionX, buttonsVerticalPosition, buttonWidth, 30.0);
        [buttonNewGame setBackgroundColor: [UIColor whiteColor]];
        [buttonNewGame setTitleColor: [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1] forState:UIControlStateNormal];
        [[buttonNewGame layer] setMasksToBounds:YES];
        [[buttonNewGame layer] setCornerRadius:5.0f];
        [buttonNewGame setTitle: @"New Game" forState:UIControlStateNormal];
        [buttonNewGame addTarget: self
                            action: @selector(newGameButtonClicked:)
                  forControlEvents: UIControlEventTouchUpInside];
        
        // Right: “Resume”
        UIButton *buttonContinue  =   [UIButton buttonWithType:UIButtonTypeRoundedRect];
        buttonContinue.tag = savedLevel;
        buttonContinue.frame      =   CGRectMake(buttonContinuePositionX, buttonsVerticalPosition, buttonWidth, 30.0);
        [buttonContinue setBackgroundColor: [UIColor whiteColor]];
        [buttonContinue setTitleColor: [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1] forState:UIControlStateNormal];
        [[buttonContinue layer] setMasksToBounds:YES];
        [[buttonContinue layer] setCornerRadius:5.0f];
        [buttonContinue setTitle: @"Resume" forState:UIControlStateNormal];
        [buttonContinue addTarget: self
                             action: @selector(continueButtonClicked:)
                   forControlEvents: UIControlEventTouchUpInside];
        
        [self.view addSubview: containerView];
        [containerView addSubview:myTextView];
        [containerView addSubview:buttonNewGame];
        [containerView addSubview:buttonContinue];
    }
}

- (void) displayIntroductionDialog
{
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1];
    
    [containerView setFrame: CGRectMake(50, 40, self.view.bounds.size.width-100, self.view.bounds.size.height-90)];
    
    UITextView *myTextView = [[UITextView alloc] init];
    myTextView.text = [NSString stringWithFormat:@"Dear Edgar,\nThank you for enrolling at GreenAlien. Your first task is to inspect an underground laboratory which does illegal in vivo alien testing.\nIn each room, you will find a plutonium cell. Collect it to activate the elevator and gain access to the next room.\nBut first, use our training room to get ready."];
    myTextView.textColor = [UIColor whiteColor];
    myTextView.backgroundColor = [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1];
    myTextView.editable = NO;
    [myTextView setFont:[UIFont fontWithName:@"GillSans" size:18]];
    
    float outsideMargin = 60;
    float insideMargin = 30;
    float buttonsVerticalPosition = containerView.bounds.size.height-50;
    float buttonWidth = (containerView.bounds.size.width/2) - (outsideMargin + insideMargin);
    float leftButtonPositionX = outsideMargin;
    float rightButtonPositionX = buttonWidth + outsideMargin + 2*insideMargin;
    
    [myTextView setFrame: CGRectMake(20, 5, containerView.bounds.size.width-40, containerView.bounds.size.height-70)];
    
    // Left: “Skip tutorial”
    UIButton *buttonSkip  =   [UIButton buttonWithType:UIButtonTypeRoundedRect];
    buttonSkip.tag = 1;
    buttonSkip.frame      =   CGRectMake(leftButtonPositionX, buttonsVerticalPosition, buttonWidth, 30.0);
    [buttonSkip setBackgroundColor: [UIColor whiteColor]];
    [buttonSkip setTitleColor: [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1] forState:UIControlStateNormal];
    [[buttonSkip layer] setMasksToBounds:YES];
    [[buttonSkip layer] setCornerRadius:5.0f];
    [buttonSkip setTitle: @"Skip tutorial" forState:UIControlStateNormal];
    [buttonSkip addTarget: self
                   action: @selector(skipTutorial:)
         forControlEvents: UIControlEventTouchUpInside];
    
    // Right: “Continue”
    UIButton *buttonStartTutorial  =   [UIButton buttonWithType:UIButtonTypeRoundedRect];
    buttonStartTutorial.tag = 0;
    buttonStartTutorial.frame      =   CGRectMake(rightButtonPositionX, buttonsVerticalPosition, buttonWidth, 30.0);
    [buttonStartTutorial setBackgroundColor: [UIColor whiteColor]];
    [buttonStartTutorial setTitleColor: [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1] forState:UIControlStateNormal];
    [[buttonStartTutorial layer] setMasksToBounds:YES];
    [[buttonStartTutorial layer] setCornerRadius:5.0f];
    [buttonStartTutorial setTitle: @"Continue" forState:UIControlStateNormal];
    [buttonStartTutorial addTarget: self
                            action: @selector(doTutorial:)
                  forControlEvents: UIControlEventTouchUpInside];
    
    [self.view addSubview: containerView];
    [containerView addSubview:myTextView];
    [containerView addSubview:buttonStartTutorial];
    [containerView addSubview:buttonSkip];
}

/* Credits */

- (IBAction)creditsButtonClicked:(id)sender {
    self.creditsText.hidden = NO;
}

-(void)closeCredits{
    self.creditsText.hidden = YES;
}

/* In-game UI buttons: pause, restart */

- (void)pauseWhileInBackground{
    SKView *spriteView = (SKView *)self.view;
    if(!myScene){
        NSLog(@"No scene"); // tested
        return;
    }
    if(spriteView.paused){
        NSLog(@"Already paused"); // tested
    }else{
        NSLog(@"We pause because going to background");
        gamePaused = TRUE;

        [spriteView setPaused:YES];
        [(plpMyScene*)myScene getsPaused];
        
        
        UIView *containerView = [[UIView alloc] init];
        containerView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:.5];
        [containerView setFrame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        [self.view addSubview: containerView];
        
        UITapGestureRecognizer *newTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resumeFreezedGame:)];
        [containerView setUserInteractionEnabled:YES];
        [containerView addGestureRecognizer:newTap];


        UILabel *scoreLabel = [ [UILabel alloc ] initWithFrame:CGRectMake(0.0, (self.view.bounds.size.height/2)-20, self.view.bounds.size.width, 40.0) ];
        scoreLabel.textAlignment =  NSTextAlignmentCenter;
        scoreLabel.textColor = [UIColor whiteColor];
        // scoreLabel.backgroundColor = [UIColor blackColor];
        scoreLabel.font = [UIFont fontWithName:@"GillSans" size:42];
        [containerView addSubview:scoreLabel];
        scoreLabel.text = @"Tap to resume";
    }
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

-(void)saveCurrentProgress
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int currentLevel = [(plpMyScene*)myScene getNextLevelIndex];
    if(currentLevel > 0)
    {
        [defaults setInteger:currentLevel forKey:@"savedLevel"];
        [defaults synchronize];
    }
}



- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSLog(@"Running on iPad");
        runningOniPad = TRUE;
    }
    if([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone)
    {
        NSLog(@"Not on an iPhone");
    }
    return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"Memory warning!");
    [super didReceiveMemoryWarning];
}


@end
