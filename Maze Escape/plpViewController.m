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
    
//    [self presentTheScene: 3]; // dev: this is for screen captures
    [self presentTheScene: choosenLevel];
    [(plpMyScene*)myScene computeCenter];
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

    SKView * spriteView = (SKView *)self.view;
    [spriteView presentScene:myScene];

    if(gamePaused == FALSE && startLevel > 0)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        float totalTime = [defaults floatForKey:@"totalTime"];
        if(totalTime){
            [(plpMyScene*)myScene saveAdditionalTime:totalTime];
        }else{
            NSLog(@"Warning: no total time found");
        }
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
    // this method gets called when the round “play” button is pressed. It occurs:
    // 1) when the user launches the game
    // 2) when he resumes after a pause
    
    self.playButton.hidden = YES;
    self.creditsButton.hidden = YES;
    self.creditsText.hidden = YES;

    
    // 1) the user launches the game
    //    if(gamePaused==FALSE)
    if(1==1)   // we set up the dialog anyway
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
            [myTextView setFont:[UIFont fontWithName:@"GillSans" size:18]];
            
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
            [myTextView setFont:[UIFont fontWithName:@"GillSans" size:18]];
            
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

- (void)forcePause // if App goes to background
{
    SKView *spriteView = (SKView *)self.view;
    if(!spriteView.paused){
        spriteView.paused = YES;
        NSLog(@"Will resign active => Pause");
    }
    [(plpMyScene*)myScene getsPaused];
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

@end
