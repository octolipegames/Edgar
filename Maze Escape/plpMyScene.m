//
//  plpMyScene.m: the scene subclass
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

#import "plpMyScene.h"
float x3 = 3;

//´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´
//
//  The main scene class: level loading, rendering, input
//
//................................................

@interface plpMyScene () <UITextFieldDelegate>
{
}
@end

dispatch_source_t CreateDispatchTimer(double interval, dispatch_queue_t queue, dispatch_block_t block)
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (timer)
    {
        dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, (1ull * NSEC_PER_SEC) / 10);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer);
    }
    return timer;
}

@implementation plpMyScene

NSArray *_monstreWalkingFrames;
SKSpriteNode *_monstre;

typedef NS_OPTIONS(uint32_t, MyPhysicsCategory) // We define 6 physics categories
{
    PhysicsCategoryEdgar = 1 << 0,   // 1
    PhysicsCategoryObjects = 1 << 1, // 2
    PhysicsCategoryTiles = 1 << 2,   // 4
    PhysicsCategoryEnemy = 1 << 3,  // 8
    PhysicsCategorySensors = 1 << 4, // 16
    PhysicsCategoryItems = 1 << 5    // 32
};



-(id)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        self.physicsWorld.contactDelegate = self;
        
        // self.size = CGSizeMake(1600, 800); // zoom for debug
        self.size = CGSizeMake(2400, 1200);
        self.name = @"mainScene";
        
        NSLog(@"Size: (%f, %f)", self.size.width, self.size.height);
        self.physicsWorld.gravity = CGVectorMake(0.0f, -9.8f * 3);
        
        myWorld = [SKNode node];         // Creation du "monde" sur lequel tout est fixe
        myWorld.name = @"world";
        
        [self addChild:myWorld];
        
        myCamera = [SKCameraNode node];
        
        self.camera = myCamera;
        [self addChild:myCamera];
        
        // PREFS AND SAVED VALUES
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        useSwipeGestures = [defaults boolForKey:@"useSwipeGestures"];
        enableDebug = [defaults boolForKey:@"enableDebug"];
        
        // TODO: implement & debug
        lifeCount = [defaults integerForKey:@"lifeCount"];
        fileCount = [defaults integerForKey:@"fileCount"];
        
        if (!lifeCount) {
            NSLog(@"Set life count for 1st time");
            lifeCount = 3;
        }
        if (!fileCount) {
            NSLog(@"Set file count for 1st time");
            fileCount = 0;
        }
        
        // HUD to display hints, life count and file count
        HUD = [SKNode node];
        HUD.name = @"HUD";
        HUD.zPosition = 28;
        [myCamera addChild:HUD];
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        screenRatio = screenHeight / screenWidth;

        NSLog(@"Device: %f, %f – %f", screenWidth, screenHeight, screenRatio);
        // We'll add life & file count later
        needsInfoBar = TRUE;

        if(!useSwipeGestures){
            // TODO: remove this
           
            SKNode *touchIndicator = [SKNode node];
            touchIndicator.name = @"touchIndicator";
            [HUD addChild: touchIndicator];
            
            SKShapeNode *horizontalLine = [SKShapeNode node];
            CGMutablePathRef pathToDraw = CGPathCreateMutable();
            
            // -400 = left bound, -200 = bottom bound
            CGPathMoveToPoint(pathToDraw, NULL, -400 * x3, -200 * x3);
            CGPathAddLineToPoint(pathToDraw, NULL, 400 * x3, -200 * x3);
            horizontalLine.path = pathToDraw;
            [horizontalLine setStrokeColor:[SKColor whiteColor]];
            SKShapeNode *horizontalLineTop = [horizontalLine copy];
            
            [horizontalLine setPosition:(CGPointMake(0, HUD_VERTICAL_THIRD))];
            [horizontalLineTop setPosition:CGPointMake(0, HUD_VERTICAL_THIRD*2)];
            
            
            SKShapeNode *verticalLineLeft = [SKShapeNode node];
            CGMutablePathRef verticalPath = CGPathCreateMutable();
            
            // from bottom bound to top bound
            CGPathMoveToPoint(verticalPath, NULL, 0, -200);
            CGPathAddLineToPoint(verticalPath, NULL, 0, 200);
            verticalLineLeft.path = verticalPath;
            [verticalLineLeft setStrokeColor:[SKColor whiteColor]];
            SKShapeNode *verticalLineRight = [verticalLineLeft copy];
            
            [verticalLineLeft setPosition:(CGPointMake(-HUD_VERTICAL_THIRD, 0))];
            [verticalLineRight setPosition:CGPointMake(HUD_VERTICAL_THIRD, 0)];
            
            [touchIndicator addChild:horizontalLine];
            [touchIndicator addChild:horizontalLineTop];
            
            [touchIndicator addChild: verticalLineLeft];
            [touchIndicator addChild: verticalLineRight];
            
            
            plpButton *buttonRight = [[plpButton alloc] initAtPosition:CGPointMake(BUTTON_HORIZONTAL_SPAN, BUTTON_VERTICAL_SPAN) withImage:@"Arrow.png" andRotation:0];
            buttonRight.name = @"right";
            [touchIndicator addChild: buttonRight];
            
            plpButton *buttonLeft = [[plpButton alloc] initAtPosition:CGPointMake(-BUTTON_HORIZONTAL_SPAN, BUTTON_VERTICAL_SPAN) withImage:@"Arrow.png" andRotation:3.14159];
            buttonLeft.name = @"left";
            [touchIndicator addChild: buttonLeft];
            
            
            plpButton *buttonUp = [[plpButton alloc] initAtPosition:CGPointMake(0, BUTTON_VERTICAL_SPAN+HUD_VERTICAL_THIRD*2) withImage:@"Arrow.png" andRotation:3.14159/2];
            buttonUp.name = @"up";
            [touchIndicator addChild: buttonUp];
            
            plpButton *buttonUpRight = [[plpButton alloc] initAtPosition:CGPointMake(BUTTON_HORIZONTAL_SPAN, BUTTON_VERTICAL_SPAN+HUD_VERTICAL_THIRD*2) withImage:@"Arrow.png" andRotation:0.8];
            buttonUpRight.name = @"upright";
            [touchIndicator addChild: buttonUpRight];
            
            plpButton *buttonUpLeft = [[plpButton alloc] initAtPosition:CGPointMake(-BUTTON_HORIZONTAL_SPAN, BUTTON_VERTICAL_SPAN+HUD_VERTICAL_THIRD*2) withImage:@"Arrow.png" andRotation:3.14159-0.8];
            buttonUpLeft.name = @"upleft";
            [touchIndicator addChild: buttonUpLeft];
            
            plpButton *buttonMiddleRight = [[plpButton alloc] initAtPosition:CGPointMake(BUTTON_HORIZONTAL_SPAN, BUTTON_VERTICAL_SPAN+HUD_VERTICAL_THIRD) withImage:@"Arrow.png" andRotation:0.5];
            buttonMiddleRight.name = @"middleright";
            [touchIndicator addChild: buttonMiddleRight];
            
            plpButton *buttonMiddleLeft = [[plpButton alloc] initAtPosition:CGPointMake(-BUTTON_HORIZONTAL_SPAN, BUTTON_VERTICAL_SPAN+HUD_VERTICAL_THIRD) withImage:@"Arrow.png" andRotation:3.14159-0.5];
            buttonMiddleLeft.name = @"middleleft";
            [touchIndicator addChild: buttonMiddleLeft];
        }
        
        // Actions
        SKAction *walkRight = [SKAction runBlock:^{
            [self->Edgar.physicsBody setVelocity:CGVectorMake(self->EdgarVelocity + contextVelocityX, self->Edgar.physicsBody.velocity.dy)];        }];
        SKAction *walkLeft = [SKAction runBlock:^{
            [self->Edgar.physicsBody setVelocity:CGVectorMake(-self->EdgarVelocity + contextVelocityX, self->Edgar.physicsBody.velocity.dy)];
        }];
        SKAction *wait = [SKAction waitForDuration:.05]; // = 20 fois par seconde vs 60
        
        /*
         INIT SOUND CONTROLLER
        */
        soundController = [[plpSoundController alloc] init];
        [self addChild: soundController];
        [self->soundController initSounds];
        platformNodes = [NSMutableArray array];

        // This speed gets higher when Edgar does a long jump.
        // He could also walk faster or slower with new items.
        EdgarVelocity = DEFAULT_EDGAR_VELOCITY;
        
        
        moveLeftAction = [SKAction repeatActionForever:[SKAction sequence:@[walkLeft, wait]]];
        moveRightAction = [SKAction repeatActionForever:[SKAction sequence:@[walkRight, wait]]];
        
        // We create our character Edgar
        Edgar = [[plpHero alloc] initAtPosition: CGPointMake(startPosition.x, startPosition.y)];
        myCamera.position = startPosition;
        self.listener = Edgar;
        
        Edgar.physicsBody.categoryBitMask = PhysicsCategoryEdgar;
        Edgar.physicsBody.collisionBitMask = PhysicsCategoryObjects|PhysicsCategoryTiles;
        Edgar.physicsBody.contactTestBitMask = PhysicsCategoryObjects|PhysicsCategoryTiles|PhysicsCategoryEnemy|PhysicsCategorySensors|PhysicsCategoryItems;
        
        Edgar->rectangleNode.physicsBody.categoryBitMask = PhysicsCategoryEdgar;
        Edgar->rectangleNode.physicsBody.collisionBitMask = PhysicsCategoryObjects|PhysicsCategoryTiles;
        Edgar->rectangleNode.physicsBody.contactTestBitMask = PhysicsCategoryObjects|PhysicsCategoryTiles|PhysicsCategoryEnemy|PhysicsCategorySensors|PhysicsCategoryItems;
        
        listensToContactEvents = TRUE;
        pauseEnabled = TRUE;
    }
    
    return self;
}

- (void)addInfoBar{
    float verticalHeight = 250 + 500 * screenRatio;
    
    // Show life count
    SKSpriteNode *edgarLife = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"Vie"] size: CGSizeMake(43, 100)];
    // edgarLife.anchorPoint = CGPointMake(0, 1);
    
    [HUD addChild: edgarLife];
    [edgarLife setPosition: CGPointMake(-960, verticalHeight)];
    [edgarLife setName: @"life0"];
    
    for(int i = 1; i < lifeCount; i++){
        SKSpriteNode *lifeCopy = [edgarLife copy];
                    
        [lifeCopy setPosition: CGPointMake(-960 + (i * 80), verticalHeight)];
        [lifeCopy setName: [NSString stringWithFormat:@"life%d", i]];
        [HUD addChild: lifeCopy];
    }
    
    // Show file count
    SKSpriteNode *file = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"Collectionnable"] size: CGSizeMake(100, 100)];
    [file setPosition: CGPointMake(-400, verticalHeight)];
    [HUD addChild: file];
    
    fileCountLabel = [SKLabelNode labelNodeWithFontNamed:@"GillSans"];
    fileCountLabel.fontSize = 30 * x3;
    fileCountLabel.fontColor = [SKColor whiteColor];
    fileCountLabel.position = CGPointMake(-290, verticalHeight); // decalage de 110
    fileCountLabel.zPosition = 10;
    [fileCountLabel setName: @"fileCountLabel"];
    
    [fileCountLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeLeft];
    [fileCountLabel setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
    [HUD addChild: fileCountLabel];
}

- (void)playAgain{
    NSLog(@"playAgain called");
    // We clean the UI
    SKNode *theTrophy = [myCamera childNodeWithName:@"trophy"];
    [theTrophy removeFromParent];
    
    [myCamera setScale: 1];
    
    [self->soundController doVolumeFade];
    
    // Curtains
    float halfHeight = 200 * x3;
    
    SKSpriteNode *lowerCurtain = (SKSpriteNode*)[myCamera childNodeWithName:@"lowerCurtain"];
    SKSpriteNode *upperCurtain = (SKSpriteNode*)[myCamera childNodeWithName:@"upperCurtain"];
    [lowerCurtain setColor: [UIColor blackColor]];
    [upperCurtain setColor: [UIColor blackColor]];
    
    /*SKSpriteNode *upperCurtain = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(800 * x3, 250 * x3) ];
    SKSpriteNode *lowerCurtain = [upperCurtain copy];*/
    upperCurtain.anchorPoint = CGPointMake(0.5, 0);
    upperCurtain.position = CGPointMake(0, halfHeight);
    upperCurtain.zPosition = 40;
    upperCurtain.name = @"upperCurtain";
    
    lowerCurtain.anchorPoint = CGPointMake(0.5, 1);
    lowerCurtain.position = CGPointMake(0, -halfHeight);
    lowerCurtain.zPosition = 40;
    lowerCurtain.name = @"lowerCurtain";
    // [myCamera addChild:upperCurtain];
    // [myCamera addChild:lowerCurtain];
    
    //  We need to make a new Edgar (removed for the final animation)
    Edgar = nil;
    Edgar = [[plpHero alloc] initAtPosition: CGPointMake(startPosition.x, startPosition.y)];
    Edgar.physicsBody.categoryBitMask = PhysicsCategoryEdgar;
    Edgar.physicsBody.collisionBitMask = PhysicsCategoryObjects|PhysicsCategoryTiles;
    Edgar.physicsBody.contactTestBitMask = PhysicsCategoryObjects|PhysicsCategoryTiles|PhysicsCategoryEnemy|PhysicsCategorySensors|PhysicsCategoryItems;
    
    Edgar->rectangleNode.physicsBody.categoryBitMask = PhysicsCategoryEdgar;
    Edgar->rectangleNode.physicsBody.collisionBitMask = PhysicsCategoryObjects|PhysicsCategoryTiles;
    Edgar->rectangleNode.physicsBody.contactTestBitMask = PhysicsCategoryObjects|PhysicsCategoryTiles|PhysicsCategoryEnemy|PhysicsCategorySensors|PhysicsCategoryItems;
    
    // Reset game data
    cheatsEnabled = FALSE;
    liftReady = FALSE;
    [self saveInitialTime];
    additionalSavedTime = 0;
    fileCount = 0;
    levelFileCount = 0;
    lifeCount = 3;
    
    [Edgar removeLight];
    [Edgar removeMasque];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:1 forKey:@"savedLevel"];
    [defaults setInteger:3 forKey:@"lifeCount"];
    [defaults setInteger:0 forKey:@"fileCount"];
    [defaults setFloat:0 forKey:@"totalTime"];
    [defaults synchronize];
    
    [HUD removeAllChildren];
    needsInfoBar = TRUE;
    
    [self resumeFromLevel:1];
}

- (IBAction)playAgainButtonClicked:(id)sender {
    // We remove all subviews (text field and buttons), then the container
    [[containerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [containerView removeFromSuperview];
    [self playAgain];
    pauseEnabled = TRUE;
}

- (IBAction)endGameNoSaveScore:(id)sender {
    [[containerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self showTrophy];
}

- (IBAction)endGameWithScore:(id)sender {
    
    // We remove all subviews (text field and buttons)
    [[containerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // custom size because the keyboard takes up half the screen
    [containerView setFrame:CGRectMake(50, 5, self.view.bounds.size.width-100, (self.view.bounds.size.height/2-10))];
    
    UITextView *usernameTextView = [[UITextView alloc] init];
    usernameTextView.text = [NSString stringWithFormat:@"Choose a name"];
    usernameTextView.textColor = [UIColor whiteColor];
    usernameTextView.backgroundColor = [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1];
    usernameTextView.editable = NO;
    [usernameTextView setFont:[UIFont fontWithName:@"GillSans" size:18]];
    
    UITextField *inputTextField = [[UITextField alloc] init];
    inputTextField.placeholder = [NSString stringWithFormat:@"Edgar"];
    inputTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    inputTextField.textColor = [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1];
    inputTextField.backgroundColor = [UIColor whiteColor];
    [inputTextField setFont:[UIFont fontWithName:@"GillSans" size:18]];
    
    inputTextField.returnKeyType = UIReturnKeyDone;
    
    float outsideMargin = 60;
    float insideMargin = 30;
    float buttonsVerticalPosition = containerView.bounds.size.height-50;
    float buttonWidth = (containerView.bounds.size.width/2) - (outsideMargin + insideMargin);
    float buttonYesPositionX = outsideMargin;
    float buttonNoPositionX = buttonWidth + outsideMargin + 2*insideMargin;
    float inputFieldPositionY = containerView.bounds.size.height/2 - 20;
    
    [usernameTextView setFrame: CGRectMake(20, 5, containerView.bounds.size.width-40, 40)];
    
    [inputTextField setFrame: CGRectMake(40, inputFieldPositionY, containerView.bounds.size.width-80, 40)];
    
    
    inputTextField.delegate = self;
    
    UIButton *myButtonYes  =   [UIButton buttonWithType:UIButtonTypeRoundedRect];
    myButtonYes.frame      =   CGRectMake(buttonYesPositionX, buttonsVerticalPosition, buttonWidth, 30.0);
    [myButtonYes setBackgroundColor: [UIColor whiteColor]];
    
    [myButtonYes setTitleColor: [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1] forState:UIControlStateNormal];
    [[myButtonYes layer] setMasksToBounds:YES];
    [[myButtonYes layer] setCornerRadius:5.0f];
    
    [myButtonYes setTitle: @"Save score" forState:UIControlStateNormal];
    [myButtonYes addTarget: self
                    action: @selector(saveScore:)
          forControlEvents: UIControlEventTouchUpInside];
    
    UIButton *myButtonNo  =   [UIButton buttonWithType:UIButtonTypeRoundedRect];
    myButtonNo.frame      =   CGRectMake(buttonNoPositionX, buttonsVerticalPosition, buttonWidth, 30.0);
    [myButtonNo setBackgroundColor: [UIColor whiteColor]];
    
    [myButtonNo setTitleColor: [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1] forState:UIControlStateNormal];
    [[myButtonNo layer] setMasksToBounds:YES];
    [[myButtonNo layer] setCornerRadius:5.0f];
    
    [myButtonNo setTitle: @"Cancel" forState:UIControlStateNormal];
    [myButtonNo addTarget: self
                   action: @selector(endGameNoSaveScore:)
         forControlEvents: UIControlEventTouchUpInside];
    
    [self.view addSubview: containerView];
    [containerView addSubview:usernameTextView];
    [containerView addSubview:inputTextField];
    [containerView addSubview:myButtonYes];
    [containerView addSubview:myButtonNo];
    [inputTextField becomeFirstResponder];
}

/*- (BOOL)multiTouchEnabled{
    return TRUE;
}*/

- (BOOL)textFieldShouldReturn:(UITextField *)theTextfield {
    [theTextfield resignFirstResponder];
    return YES;
}

- (BOOL)isPauseEnabled {
    return pauseEnabled;
}

- (void)showGameOver {
    pauseEnabled = FALSE;
    SKSpriteNode *lowerCurtain = (SKSpriteNode*)[myCamera childNodeWithName:@"lowerCurtain"];
    SKSpriteNode *upperCurtain = (SKSpriteNode*)[myCamera childNodeWithName:@"upperCurtain"];
    [lowerCurtain setColor: [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1]];
    [upperCurtain setColor: [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1]];
    [self->soundController playTune:@"Sounds/game_over" loops:0];
    
    if(upperCurtain && lowerCurtain){
        [upperCurtain runAction: [SKAction moveToY:-20 duration: 2]];
        [lowerCurtain runAction: [SKAction moveToY: 20 duration: 2] completion:^
        {
            NSLog(@"curtains closed");
            SKTexture *gameOverTexture = [SKTexture textureWithImageNamed:@"GameOver.png"];
            SKSpriteNode *gameOverNode = [SKSpriteNode spriteNodeWithTexture: gameOverTexture];
            gameOverNode.name = @"trophy";
            [gameOverNode setSize: CGSizeMake( 1000, 1000 )];
            [gameOverNode setPosition: CGPointMake(0, 1500)];
            [gameOverNode setZPosition: 100];
            [self->myCamera addChild: gameOverNode];
            [gameOverNode runAction: [SKAction moveTo: CGPointMake(0, 120) duration: .8] completion:^
            {
                self->containerView = [[UIView alloc] init];
                                       [self->containerView setFrame: CGRectMake(50, 100, self.view.bounds.size.width-100, self.view.bounds.size.height-100)]; // coordinates origin is upper left
                
                float outsideMargin = 60;
                float insideMargin = 30;
                float buttonsVerticalPosition = self->containerView.bounds.size.height-50;
                float buttonWidth = (self->containerView.bounds.size.width/2) - (outsideMargin + insideMargin);
                float buttonNewGamePositionX = self->containerView.bounds.size.width/2 - buttonWidth/2;
            
                
                UIButton *myButtonClose  =   [UIButton buttonWithType:UIButtonTypeRoundedRect];
                myButtonClose.frame      =   CGRectMake(buttonNewGamePositionX, buttonsVerticalPosition, buttonWidth, 30.0);
                
                [myButtonClose setBackgroundColor: [UIColor whiteColor]];
                
                [myButtonClose setTitleColor: [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1] forState:UIControlStateNormal];
                [[myButtonClose layer] setMasksToBounds:YES];
                [[myButtonClose layer] setCornerRadius:5.0f];
                
                [myButtonClose setTitle: @"Play again" forState:UIControlStateNormal];
                [myButtonClose addTarget: self
                                  action: @selector(playAgainButtonClicked:)
                        forControlEvents: UIControlEventTouchUpInside];
                
                [self->containerView addSubview: myButtonClose];
                [self.view addSubview: self->containerView];
                NSLog(@"End display game over");
            }];
        }];
    }

    
    
    //[containerView setFrame:CGRectMake(50*x3, 5*x3, self.view.bounds.size.width - (100 * x3), self.view.bounds.size.height/3)]; // upper half of the screen
    
    
}



- (void)showTrophy {
    pauseEnabled = FALSE;
    NSString *rankingString = @"Snail Edgar.";
    SKTexture *trophyTexture = [SKTexture textureWithImageNamed:@"TropheeSnail_x3.png"];
    
    float totalTime = [self getTotalTime];
    if(totalTime < 600) // 10 minutes
    {
        rankingString = @"Congrats, you’re the boss.";
        trophyTexture = [SKTexture textureWithImageNamed:@"TropheeElite_x3.png"];
    }else if(totalTime < 1200) // 20 minutes
    {
        rankingString = @"Good job!";
        trophyTexture = [SKTexture textureWithImageNamed:@"TropheeExplorer_x3.png"];
    }else{
        rankingString = @"Snail Edgar.";
    }
    
    
    SKSpriteNode *trophy = [SKSpriteNode spriteNodeWithTexture:trophyTexture];
    trophy.name = @"trophy";
    
    [containerView setFrame:CGRectMake(50*x3, 5*x3, self.view.bounds.size.width - (100 * x3), self.view.bounds.size.height/3)]; // upper half of the screen

    if(!myTextView)
    {
        myTextView = [[UITextView alloc] init];
    }
    
    myTextView.text = [NSString stringWithFormat:@"Your rank: %@", rankingString];
    myTextView.textColor = [UIColor whiteColor];
    myTextView.backgroundColor = [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1];
    myTextView.editable = NO;
    [myTextView setFont:[UIFont fontWithName:@"GillSans" size:18]];
    
    float outsideMargin = 60;
    float insideMargin = 30;
    float buttonsVerticalPosition = containerView.bounds.size.height-50;
    float buttonWidth = (containerView.bounds.size.width/2) - (outsideMargin + insideMargin);
    float buttonNewGamePositionX = containerView.bounds.size.width/2 - buttonWidth/2;
    
    [myTextView setFrame: CGRectMake(20, 5, containerView.bounds.size.width-40, 35)];
    
    UIButton *myButtonClose  =   [UIButton buttonWithType: UIButtonTypeRoundedRect];
    myButtonClose.frame      =   CGRectMake(buttonNewGamePositionX, buttonsVerticalPosition, buttonWidth, 30.0);
    
    [myButtonClose setBackgroundColor: [UIColor whiteColor]];
    
    [myButtonClose setTitleColor: [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1] forState:UIControlStateNormal];
    [[myButtonClose layer] setMasksToBounds:YES];
    [[myButtonClose layer] setCornerRadius:5.0f];
    
    [myButtonClose setTitle: @"Play again" forState:UIControlStateNormal];
    [myButtonClose addTarget: self
                      action: @selector(playAgainButtonClicked:)
            forControlEvents: UIControlEventTouchUpInside];
    
    [containerView addSubview:myTextView];
    [containerView addSubview:myButtonClose];
    [trophy setScale: 0.5];
    // Position: bottom left
    [trophy setPosition: CGPointMake(10 - trophy.size.width/2, 40 - trophy.size.height/2)];
    [trophy setZPosition: 100 * x3];
    [myCamera addChild: trophy];
}

- (IBAction)saveScore:(id)sender {

    // We get the choosen username...
    NSString* username;
    for (UIView* subView in containerView.subviews)
    {
        if ([subView isKindOfClass:[UITextField class]])
        {
            UITextField *usernameTextField = (UITextField*) subView;
            username = usernameTextField.text;
        }
    }

    [[containerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self showTrophy];
    
    // Save the score in the background
    [NSThread detachNewThreadSelector:@selector(saveHighScoreForUser:) toTarget:self withObject:username];
}


- (JSTileMap*)loadLevel:(int)levelIndex
{
    if(needsInfoBar){
        [self addInfoBar];
        needsInfoBar = FALSE;
    }
    
    if(levelIndex <= 1) // dev: need to this to the right place
    {
        freeCamera = FALSE;
    }
    
    JSTileMap *myTileMap;
    NSArray *levelFiles = [NSArray arrayWithObjects:
                           @"Levels/Level_0_tuto.tmx",
                           @"Levels/Level_1.tmx",
                           @"Levels/Level_2.tmx",
                           @"Levels/Level_3.tmx",
                           @"Levels/Level_4.tmx",
                           @"Levels/Level_5.tmx",
                           @"Levels/Level_6.tmx",
                           @"Levels/Level_7.tmx",
                           @"Levels/Level_8.tmx",
                           nil];
    
    NSString *myLevelFile;
    
    if(levelIndex < [levelFiles count])
    {
        myLevelFile = levelFiles[levelIndex];
        myTileMap = [JSTileMap mapNamed:myLevelFile];
        if(!myTileMap)
        {
            NSLog(@"Could not load the .tmx tilemap.");
            return false;
        }
    }
    else
    {
        NSLog(@"Next level out of the “levelFiles” array");
        return false;
    }
    return myTileMap;
}

-(void)addCollisionLayer: (JSTileMap*) tileMap
{
    BOOL useCollisionGroup = FALSE;
    
    // For debug
    // self.view.showsPhysics = YES;
    // self.view.showsFPS = YES;
    // self.view.showsNodeCount = YES;

    
    TMXObjectGroup *collisionRectangles = [tileMap groupNamed:@"CollisionRectangles"]; // Objets
    if(collisionRectangles){
        useCollisionGroup = TRUE;
        for (NSDictionary *collisionRectangle in [collisionRectangles objects]) {
            
            // create rectangular body according to tilemap
            SKPhysicsBody *rectangleBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake([collisionRectangle[@"width"] floatValue], [collisionRectangle[@"height"] floatValue])];
            rectangleBody.dynamic = NO;
            rectangleBody.categoryBitMask = PhysicsCategoryTiles;
            rectangleBody.collisionBitMask = 0;
            rectangleBody.friction = 0.5;
            rectangleBody.restitution = 0;

            // node containing the body
            SKNode *collisionNode = [SKNode node];
            [collisionNode setPosition: [self convertPosition: collisionRectangle]];
            collisionNode.physicsBody = rectangleBody;
            [tileMap addChild: collisionNode];
        }
    }else{
        NSLog(@"No collision layer found in the tilemap.");
    }
    
    TMXObjectGroup *collisionPolygons = [tileMap groupNamed:@"CollisionPolygons"]; // Objets
    if(collisionPolygons){
        for (NSDictionary *collisionPolygon in [collisionPolygons objects]) {
            NSArray *coordinates = [collisionPolygon[@"polygonPoints"] componentsSeparatedByString:@" "];
            
            // NSLog(@"Coordinates: %@", coordinates);
            
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, nil, 0, 0);
            for (NSString *coordinate in coordinates){
                NSArray *xy = [coordinate componentsSeparatedByString:@","];
                CGPathAddLineToPoint(path, nil, [xy[0] floatValue], -[xy[1] floatValue]);
            }
            
            // create polygonal body according to tilemap
            SKPhysicsBody *polygonBody = [SKPhysicsBody bodyWithPolygonFromPath: path];
            polygonBody.dynamic = NO;
            polygonBody.categoryBitMask = PhysicsCategoryTiles;
            polygonBody.friction = 0.5;
            polygonBody.restitution = 0;
            polygonBody.collisionBitMask = 0;

            // attach body to node
            SKNode *collisionNode = [SKNode node];
            [collisionNode setPosition: [self convertPosition: collisionPolygon]];
            collisionNode.physicsBody = polygonBody;
            [tileMap addChild: collisionNode];
        }
    }else{
        NSLog(@"No collision layer found in the tilemap.");
    }

    
    /*
     
    // When SpriteKit had less bugs
    
    TMXLayer* monLayer = [tileMap layerNamed:@"Solide"];
    
    for (int a = 0; a < tileMap.mapSize.width; a++)
    {
        for (int b = 0; b < tileMap.mapSize.height; b++)
        {
            CGPoint pt = CGPointMake(a, b);
            
            NSInteger gid = [monLayer tileGidAt:[monLayer pointForCoord:pt]];
            
            if (gid != 0 && !useCollisionGroup)
            {
                SKSpriteNode* node = [monLayer tileAtCoord:pt];
                // [node setSize:CGSizeMake(100 * x3.0f, 100 * x3.0f)];
                [node setSize:CGSizeMake(300 * x3.0f, 300 * x3.0f)];
                // node.physicsBody = [SKPhysicsBody bodyWithTexture:node.texture size:node.frame.size];
                node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(300 * x3, 300 * x3)];
                node.physicsBody.dynamic = NO;
                node.physicsBody.categoryBitMask = PhysicsCategoryTiles;
                node.physicsBody.friction = 0.5;
                node.physicsBody.restitution = 0;
                if(node.physicsBody){
                    node.shadowCastBitMask = 1;
                }else{
                    NSLog(@"%d, %d: The physicsBody was not created.", a, b);
                }
            }
        }
    }*/
}

// input: Tilemap rectangle, output: rectangle center
-(CGPoint) convertPosition:(NSDictionary*)objectDictionary
{
    CGPoint thePoint = CGPointMake([objectDictionary[@"x"] floatValue] + ([objectDictionary[@"width"] floatValue]/2),
                                   [objectDictionary[@"y"] floatValue] + ([objectDictionary[@"height"] floatValue]/2));
    return thePoint;
}

-(void)loadAssets:(JSTileMap*) tileMap
{
    // Edgar's starting position / Position de depart d'Edgar
    TMXObjectGroup *group = [tileMap groupNamed:@"Objets"]; // Objets
    if(!group) NSLog(@"Error: no object layer found in the tilemap.");
    NSArray *startPosObjects = [group objectsNamed:@"Start"];
    for (NSDictionary *startPos in startPosObjects) {
        startPosition = [self convertPosition:startPos];
    }
    
    if(currentLevelIndex>0) // Fin du niveau 1: on efface l'éventuel reste de flèche d'aide
    {
        SKNode *theNode;
        if(( theNode = [myCamera childNodeWithName:@"helpNode"]))
        {
            [theNode removeFromParent];
        }
    }
    
    if(currentLevelIndex>1)
    {
        SKSpriteNode *startLift = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"ascenseur-start.png"] size: CGSizeMake(313, 366)];
        startLift.position = startPosition;
        [tileMap addChild: startLift];
    }
    
    // Sensor (detects when the player reaches the center of the lift and triggers events like the alien vessel)
    // Senseur (utilisés pour déclencher la fin du  niveau et des événements comme la venue du vaisseau spatial)
    NSArray *sensorObjectMarker;
    if((sensorObjectMarker = [group objectsNamed:@"sensor"]))
    {
        SKSpriteNode *sensorNode;
        int sensorId = 0;
        
        for (NSDictionary *theSensor in sensorObjectMarker) {
            float width = [theSensor[@"width"] floatValue];
            float height = [theSensor [@"height"] floatValue];
            sensorNode = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:1 green: 1                                                                                blue: 1 alpha: 0] size: CGSizeMake(width, height)]; // change alpha e.g. to 0.3 to debug
            sensorNode.position = [self convertPosition:theSensor];
            
            if(sensorNode)
            {
                sensorNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(width, height)];
                sensorNode.physicsBody.dynamic = NO;
                sensorNode.physicsBody.categoryBitMask = PhysicsCategorySensors;
                sensorNode.physicsBody.collisionBitMask = 0;
                if(theSensor[@"nodename"])
                {
                    sensorNode.name = theSensor[@"nodename"];
                }
                else
                {
                    sensorNode.name = [NSString stringWithFormat:@"sensor%d", sensorId];
                }
                sensorId++;
                [tileMap addChild:sensorNode];
            }
            else
            {
                NSLog(@"Error while creating a sensor.");
            }
        }
    }
    
    // Crate / Caisse
    SKTexture *textureCaisse = [SKTexture textureWithImageNamed:@"caisse.png"];
    NSArray *placeCaisse = [group objectsNamed:@"Caisse"];
    for (NSDictionary *optionCaisse in placeCaisse) {
        CGFloat width = 216; //[optionCaisse[@"width"] floatValue];
        CGFloat height = 216; //[optionCaisse[@"height"] floatValue];
        
        SKSpriteNode *caisse = [SKSpriteNode spriteNodeWithTexture:textureCaisse size: CGSizeMake(width, height)];
        [caisse setZPosition: 20];
        caisse.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(width-2, height-2)]; // minus 1.5 so the crate doesn't float over the floor
        caisse.physicsBody.mass = 200; // auparavant: 40
        caisse.physicsBody.friction = 0.2;
        caisse.position = [self convertPosition:optionCaisse];
        caisse.physicsBody.categoryBitMask = PhysicsCategoryObjects;
        caisse.physicsBody.collisionBitMask = PhysicsCategoryEdgar|PhysicsCategoryObjects|PhysicsCategoryTiles;
        caisse.physicsBody.contactTestBitMask = PhysicsCategoryEdgar|PhysicsCategoryObjects|PhysicsCategoryTiles;
        caisse.name = @"caisse";
        [tileMap addChild: caisse];
    }
    
    if(currentLevelIndex == 1)
    {
        NSArray *treeArray;
        if((treeArray=[group objectsNamed:@"arbre"]))
        {
            for (NSDictionary *monTree in treeArray) {
                plpItem *myItem;
                
                myItem = [[plpItem alloc] initAtPosition:[self convertPosition:monTree] withTexture:@"Arbre_x3.png" andRadius: 22];
                
                if(myItem)
                {
                    myItem.physicsBody = [SKPhysicsBody bodyWithTexture: myItem.texture alphaThreshold: 0.5 size: CGSizeMake(760, 852)];
                    myItem.physicsBody.categoryBitMask = PhysicsCategoryTiles;
                    myItem.physicsBody.dynamic = NO;
                    [tileMap addChild:myItem];
                }
                else
                {
                    NSLog(@"Error while creating the tree.");
                }
                SKSpriteNode *bush = [SKSpriteNode spriteNodeWithImageNamed:@"Buisson_x3"];
                [bush setPosition:CGPointMake( 200, 1010)];
                [tileMap addChild:bush];
            }
        }
    }
    NSArray *semaphoreArray;
    if((semaphoreArray=[group objectsNamed:@"semaphore"]))
    {
        for (NSDictionary *monSemaphore in semaphoreArray) {
            plpItem *myItem;
            myItem = [[plpItem alloc] initAtPosition:[self convertPosition:monSemaphore] withTexture:@"Feu_vert.png" andRadius:22];
            //                float waitBeforeStart = [monSemaphore[@"waitBeforeStart"] floatValue];
            if(myItem)
            {
                //                    myItem.physicsBody.categoryBitMask = PhysicsCategoryItems;
                [tileMap addChild:myItem];
                // action
                
                SKTexture *semaphoreGreen = [SKTexture textureWithImageNamed:@"Feu_vert.png"];
                SKTexture *semaphoreRed = [SKTexture textureWithImageNamed:@"Feu_rouge.png"];
                SKAction *setGreen = [SKAction setTexture:semaphoreGreen];
                SKAction *setRed = [SKAction setTexture:semaphoreRed];
                SKAction *waitShort = [SKAction waitForDuration:2];
                SKAction *waitLong = [SKAction waitForDuration:4];
                SKAction *changeTexture = [SKAction sequence:@[waitShort, setGreen, waitShort, setRed, waitLong]];
                
                [myItem runAction: setRed completion: ^{
                    [myItem runAction:[SKAction repeatActionForever:changeTexture]];
                }];
                
            }
            else
            {
                NSLog(@"Error while creating the semaphore.");
            }
        }
    }
    
    
    SKSpriteNode *endLevelLiftNode; // Ascenseur de la fin du niveau
    NSArray *endLevelLift = [group objectsNamed:@"endLevelLift"];
    for (NSDictionary *final in endLevelLift) {
        CGFloat x = [final[@"x"] floatValue];
        CGFloat y = [final[@"y"] floatValue];
        CGFloat width = [final[@"width"] floatValue];
        CGFloat height = [final[@"height"] floatValue];
        
        SKTexture *textureCaisse = [SKTexture textureWithImageNamed:@"ascenseurF-01.png"];
        endLevelLiftNode = [SKSpriteNode spriteNodeWithTexture:textureCaisse size: CGSizeMake(width, height)];
        
        endLevelLiftNode.name = @"endLevelLiftNode";
        endLevelLiftNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(width, height) center:CGPointMake(width/2,height/2)];
        endLevelLiftNode.physicsBody.categoryBitMask = PhysicsCategorySensors;
        endLevelLiftNode.physicsBody.friction = 0.1; // la caisse glisse
        endLevelLiftNode.anchorPoint = CGPointMake(0, 0);
        endLevelLiftNode.position = CGPointMake(x,y);
        endLevelLiftNode.zPosition = -8; // derriere caisse, alien etc.
        endLevelLiftNode.physicsBody.dynamic = NO;
        
        myFinishRectangle = [SKSpriteNode node]; // for debug purposes / pour débugger: [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:1 green: 1                                                                                blue: 1 alpha: .5] size:CGSizeMake(6, 80)];
        myFinishRectangle.anchorPoint = CGPointMake(0.5, 0.5);
        myFinishRectangle.position = CGPointMake(endLevelLiftNode.position.x + endLevelLiftNode.size.width/2, endLevelLiftNode.position.y + endLevelLiftNode.size.height/2);
        myFinishRectangle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(6, 80) center:CGPointMake(8, 0)];
        myFinishRectangle.physicsBody.dynamic = NO;
        myFinishRectangle.physicsBody.categoryBitMask = PhysicsCategorySensors;
        myFinishRectangle.name = @"finish";
    }
    
    if(myFinishRectangle) [tileMap addChild: myFinishRectangle];
    if(endLevelLiftNode) [tileMap addChild: endLevelLiftNode];
    
    // Item: for batteries and other objects / Item: pour la pile et autres objets
    NSArray *tabItem;
    if((tabItem=[group objectsNamed:@"uranium"]))
    {
        for (NSDictionary *monItem in tabItem) {
            plpItem *myItem;
            myItem = [[plpItem alloc] initAtPosition:[self convertPosition:monItem] withTexture:@"Pile.png" andRadius: 66];
            if(myItem)
            {
                myItem.name = @"uranium";
                myItem.physicsBody.categoryBitMask = PhysicsCategoryItems;
                [tileMap addChild:myItem];
            }
            else
            {
                NSLog(@"Error while creating the uranium cell.");
            }
        }
    }
    
    NSArray *fileGroup;
    if((fileGroup=[group objectsNamed:@"file"]))
    {
        for (NSDictionary *filePosition in fileGroup) {
            plpItem *myFile = [[plpItem alloc] initAtPosition:[self convertPosition: filePosition] withTexture:@"File_no_glow.png" andRadius: 30];
            if(myFile)
            {
                myFile.name = @"file";
                myFile.physicsBody.categoryBitMask = PhysicsCategoryItems;
                [tileMap addChild: myFile];
            }
            else
            {
                NSLog(@"Error while adding a file to the map.");
            }
        }
        levelTotalFileCount = [fileGroup count];
        fileCountLabel.text = [ [NSString alloc] initWithFormat: @"%ld/%lu", (long) levelFileCount, (long)levelTotalFileCount];
    }

    // Train
    NSArray *trainObjectMarker;
    if((trainObjectMarker = [group objectsNamed:@"train"]))
    {
        plpTrain *trainNode;
        
        for (NSDictionary *theTrain in trainObjectMarker) {
            trainNode = [[plpTrain alloc] initAtPosition: [self convertPosition:theTrain] withMainTexture:@"ChariotParoi.png" andWheelTexture:@"ChariotRoue.png"];
            
            if(trainNode)
            {
                trainNode.physicsBody.categoryBitMask = PhysicsCategoryObjects;
                trainNode.physicsBody.collisionBitMask = PhysicsCategoryTiles|PhysicsCategoryObjects|PhysicsCategoryEdgar|PhysicsCategoryEnemy;
                trainNode.physicsBody.contactTestBitMask = PhysicsCategoryEdgar|PhysicsCategoryObjects|PhysicsCategoryTiles;
                
                [tileMap addChild:trainNode]; // vs myLevel
                [trainNode setVolume: [soundController getFxVolume]];
                
                [trainNode getLeftWheel].physicsBody.collisionBitMask = PhysicsCategoryTiles|PhysicsCategoryObjects|PhysicsCategoryEdgar|PhysicsCategoryEnemy;
                [trainNode getRightWheel].physicsBody.collisionBitMask = PhysicsCategoryTiles|PhysicsCategoryObjects|PhysicsCategoryEdgar|PhysicsCategoryEnemy;
                
                // DEV: Added on August 14th to solve bug when Edgar gets stuck - tests required [DONE]
                [trainNode getLeftWheel].physicsBody.categoryBitMask = PhysicsCategoryObjects;
                [trainNode getLeftWheel].physicsBody.contactTestBitMask = PhysicsCategoryEdgar|PhysicsCategoryObjects|PhysicsCategoryTiles;
                [trainNode getRightWheel].physicsBody.categoryBitMask = PhysicsCategoryObjects;
                [trainNode getRightWheel].physicsBody.contactTestBitMask = PhysicsCategoryEdgar|PhysicsCategoryObjects|PhysicsCategoryTiles;
                
                SKPhysicsJointPin *pinGauche = [SKPhysicsJointPin jointWithBodyA:[trainNode getLeftWheel].physicsBody bodyB:trainNode.physicsBody anchor:CGPointMake(trainNode.position.x-20*x3, trainNode.position.y-19*x3)];
                [self.physicsWorld addJoint:pinGauche];
                
                SKPhysicsJointPin *pinDroit = [SKPhysicsJointPin jointWithBodyA:[trainNode getRightWheel].physicsBody bodyB:trainNode.physicsBody anchor:CGPointMake(trainNode.position.x+20*x3, trainNode.position.y-19*x3)];
                [self.physicsWorld addJoint:pinDroit];
            }
        }
    }
    
    NSArray *verticalPlatformObjectMarker;
    if((verticalPlatformObjectMarker = [group objectsNamed:@"verticalPlatform"]))
    {
        plpPlatform *verticalPlatformNode;
        
        /*
         Inverted coordonate system in the Tiled app and in SpriteKit.
         Tiled:
         0, 0 = upper left / coin supérieur gauche
         SriteKit:
         0, 0 = bottom left / coin inférieur gauche
         =>
         if the platform has the "moveUpFirst" property: position = x, y - height; limite = y
         otherwise: position = x, y; limite = y - height
         */
        
        
        for (NSDictionary *theVerticalPlatform in verticalPlatformObjectMarker) {
            float idleDuration = [theVerticalPlatform[@"idleDuration"] floatValue];
            if(!idleDuration) idleDuration = 2;
            
            if([theVerticalPlatform[@"moveUpFirst"] intValue] == 1)
            {
                verticalPlatformNode = [[plpPlatform alloc] initAtPosition: CGPointMake([theVerticalPlatform[@"x"] floatValue], [theVerticalPlatform[@"y"] floatValue])
                                                                  withSize:CGSizeMake(296, 28)
                                                              withDuration:[theVerticalPlatform[@"movementDuration"] floatValue] upToX:[theVerticalPlatform[@"x"] floatValue] andY:[theVerticalPlatform[@"y"] floatValue] + [theVerticalPlatform[@"height"] floatValue] -28 andIdleDuration:idleDuration];
            }else{
                verticalPlatformNode = [[plpPlatform alloc] initAtPosition: CGPointMake([theVerticalPlatform[@"x"] floatValue], [theVerticalPlatform[@"y"] floatValue] + [theVerticalPlatform[@"height"] floatValue] - 28)
                                                                  withSize:CGSizeMake(296, 28)
                                                              withDuration:[theVerticalPlatform[@"movementDuration"] floatValue] upToX:[theVerticalPlatform[@"x"] floatValue] andY:[theVerticalPlatform[@"y"] floatValue] andIdleDuration:idleDuration];
            }
            
            if(verticalPlatformNode)
            {
                verticalPlatformNode.physicsBody.categoryBitMask = PhysicsCategoryObjects;
                verticalPlatformNode.physicsBody.collisionBitMask = PhysicsCategoryEdgar | PhysicsCategoryTiles;
                [tileMap addChild:verticalPlatformNode];
                
                if([theVerticalPlatform[@"noEmergencyStop"] intValue] == 1)
                {
                    [verticalPlatformNode setNoEmergencyStop];
                }
                
                [verticalPlatformNode setVolume: [soundController getFxVolume]];
                [platformNodes addObject: verticalPlatformNode];
            }
        }
    }
    
    
    NSArray *horizontalPlatformObjectMarker;
    if((horizontalPlatformObjectMarker = [group objectsNamed:@"horizontalPlatform"]))
    {
        plpPlatform *horizontalPlatformNode;
       
        
        for (NSDictionary *thehorizontalPlatform in horizontalPlatformObjectMarker) {
            float idleDuration = [thehorizontalPlatform[@"idleDuration"] floatValue];
            if(!idleDuration) idleDuration = 2;
            
            if([thehorizontalPlatform[@"moveLeftFirst"] intValue] == 1)
            {
                horizontalPlatformNode = [[plpPlatform alloc] initAtPosition: CGPointMake([thehorizontalPlatform[@"x"] floatValue]  + [thehorizontalPlatform[@"width"] floatValue] -300, [thehorizontalPlatform[@"y"] floatValue])
                    withSize:CGSizeMake(300, 28)
                withDuration:[thehorizontalPlatform[@"movementDuration"] floatValue] upToX:[thehorizontalPlatform[@"x"] floatValue] andY:[thehorizontalPlatform[@"y"] floatValue] andIdleDuration:idleDuration];
            }else{
                horizontalPlatformNode = [[plpPlatform alloc] initAtPosition: CGPointMake([thehorizontalPlatform[@"x"] floatValue], [thehorizontalPlatform[@"y"] floatValue])
                                                                  withSize:CGSizeMake(300, 28)
                                                              withDuration:[thehorizontalPlatform[@"movementDuration"] floatValue] upToX:[thehorizontalPlatform[@"x"] floatValue] + [thehorizontalPlatform[@"width"] floatValue] -300 andY:[thehorizontalPlatform[@"y"] floatValue] andIdleDuration:idleDuration];
            }
            
            if(horizontalPlatformNode)
            {
                horizontalPlatformNode.physicsBody.categoryBitMask = PhysicsCategoryObjects;
                horizontalPlatformNode.physicsBody.collisionBitMask = PhysicsCategoryEdgar | PhysicsCategoryTiles;
                [tileMap addChild:horizontalPlatformNode];
                
                if([thehorizontalPlatform[@"noEmergencyStop"] intValue] == 1)
                {
                    [horizontalPlatformNode setNoEmergencyStop];
                }
                
                [horizontalPlatformNode setVolume: [soundController getFxVolume]];
                [platformNodes addObject: horizontalPlatformNode];
            }
        }
    }
    
    
    NSArray *platformObjectMarker;
    if((platformObjectMarker = [group objectsNamed:@"platform"]))
    {
        plpPlatform *platformNode;
        
        for (NSDictionary *thePlatform in platformObjectMarker) {
            float y_limit = [thePlatform[@"y_limit"] floatValue];
            if(!y_limit)
            {
                y_limit = [thePlatform[@"y"] floatValue];
            }
            float idleDuration = [thePlatform[@"idleDuration"] floatValue];
            if(!idleDuration) idleDuration = 2;
            platformNode = [[plpPlatform alloc] initAtPosition: CGPointMake([thePlatform[@"x"] floatValue], [thePlatform[@"y"] floatValue])//[self convertPosition:thePlatform]
                                                      withSize:CGSizeMake([thePlatform[@"width"] floatValue], [thePlatform[@"height"] floatValue])
                                                  withDuration:[thePlatform[@"movementDuration"] floatValue] upToX:[thePlatform[@"x_limit"] floatValue] andY:y_limit andIdleDuration:idleDuration];
            
            if(platformNode)
            {
                platformNode.physicsBody.categoryBitMask = PhysicsCategoryObjects;
                platformNode.physicsBody.collisionBitMask = PhysicsCategoryEdgar | PhysicsCategoryTiles;
                //platformNode.zPosition = -15.0f;
                [tileMap addChild:platformNode];
            }
            [platformNode setVolume: [soundController getFxVolume]];
            [platformNodes addObject: platformNode];
        }
    }
    
    // Aliens / Extra-terrestres
    NSArray *tabAlien;
    if((tabAlien=[group objectsNamed:@"alien"]))
    {
        for (NSDictionary *monAlien in tabAlien) {
            plpAlien *alien;
            alien = [[plpAlien alloc] initAtPosition:[self convertPosition:monAlien] withSize:CGSizeMake(210, 135) withMovement:[monAlien[@"moveX"] floatValue]];
            if(alien)
            {
                alien.physicsBody.categoryBitMask = PhysicsCategoryEnemy;
                alien.physicsBody.collisionBitMask = PhysicsCategoryObjects | PhysicsCategoryTiles;
                [tileMap addChild:alien];
            }
            else
            {
                NSLog(@"Error while creating the alien.");
            }
        }
    }
    
    NSArray *scientistArray;
    if((scientistArray=[group objectsNamed:@"scientist"]))
    {
        for (NSDictionary *scientistPosition in scientistArray) {
            plpScientist *scientist = [[plpScientist alloc] initAtPosition:[self convertPosition: scientistPosition] withSize:CGSizeMake([scientistPosition[@"width"] floatValue], [scientistPosition[@"height"] floatValue])];
            if(scientist)
            {
                scientist.physicsBody.categoryBitMask = PhysicsCategoryEnemy;
                scientist.physicsBody.collisionBitMask = PhysicsCategoryObjects | PhysicsCategoryTiles;
                [tileMap addChild: scientist];
            }
            else
            {
                NSLog(@"Error while creating the scientist.");
            }
        }
    }
    
    NSArray *trapDoorArray;
    if((trapDoorArray=[group objectsNamed:@"trapDoor"]))
    {
        for (NSDictionary *trapDoorPosition in trapDoorArray) {
            
            CGPoint centerPosition = [self convertPosition: trapDoorPosition];

            SKTexture *trapDoorTexture = [SKTexture textureWithImageNamed: @"Trappe.png"];
            SKSpriteNode *trapDoor = [SKSpriteNode spriteNodeWithTexture: trapDoorTexture];
            
            // For rotation
            trapDoor.anchorPoint = CGPointMake(0.1, 0.5);
            SKSpriteNode *trapDoorRight = [trapDoor copy];
            
            [trapDoor setPosition: CGPointMake(centerPosition.x - 145, centerPosition.y)];
            
            trapDoor.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: CGSizeMake(150, 28) center:CGPointMake(60, 0)];
            trapDoor.physicsBody.allowsRotation = NO;
            trapDoor.physicsBody.affectedByGravity = NO;
            trapDoor.physicsBody.friction = 1.0;
            trapDoor.physicsBody.linearDamping = 0;
            trapDoor.physicsBody.mass = 10000000000;
            trapDoor.physicsBody.categoryBitMask = PhysicsCategoryObjects;
            [trapDoor setName: @"trapDoorLeft"];
            
            trapDoorRight.anchorPoint = CGPointMake(0.9, 0.5);
            [trapDoorRight setPosition: CGPointMake(centerPosition.x + 145, centerPosition.y)];
            trapDoorRight.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: CGSizeMake(150, 28) center:CGPointMake(-60, 0)];
            trapDoorRight.physicsBody.allowsRotation = NO;
            trapDoorRight.physicsBody.affectedByGravity = NO;
            trapDoorRight.physicsBody.friction = 1.0;
            trapDoorRight.physicsBody.linearDamping = 0;
            trapDoorRight.physicsBody.mass = 10000000000;
            trapDoorRight.physicsBody.categoryBitMask = PhysicsCategoryObjects;
            
            [trapDoorRight setName: @"trapDoorRight"];
            
            SKAudioNode *trapDoorSound = [[SKAudioNode alloc] initWithFileNamed:@"Sounds/fx_elevateur.wav"];
            trapDoorSound.autoplayLooped = false;
            trapDoorSound.position = CGPointMake(0, 0);
            trapDoorSound.positional = true;
            [trapDoor addChild: trapDoorSound];
            

            if(trapDoor)
            {
                
                [tileMap addChild: trapDoor];
                [tileMap addChild: trapDoorRight];
            }
            else
            {
                NSLog(@"Error while creating trapDoor.");
            }
        }
    }
}

// TIME TRACKER

/*

 - Start of each level: we do saveInitialTime
 - End of each level: saveAdditionalTime (total)
 
 - Pause: saveAdditionalTime + (!!!) saveLevelTime
 - Resume: saveInitialTime
 
 - Load a saved game (after the app was closed): we add the stored saved time
 
*/


-(void)saveInitialTime
{
    NSLog(@"T: Initial time saved.");
    initialTime = CFAbsoluteTimeGetCurrent();
}
-(void)saveAdditionalTime:(float)additionalTime{
    NSLog(@"T: Custom additional time saved: %f", additionalTime);
    additionalSavedTime += additionalTime;
}
-(void)saveAdditionalTime
{
    NSLog(@"T: Additional time saved.");
    additionalSavedTime += CFAbsoluteTimeGetCurrent() - initialTime;
}
-(void)saveAdditionalLevelTime
{
    NSLog(@"T: Additional level time saved");
    additionalLevelTime += CFAbsoluteTimeGetCurrent() - initialTime;
}

-(float)getTotalTime
{
    NSLog(@"%f, %f, %f", CFAbsoluteTimeGetCurrent(), initialTime, additionalSavedTime);
    return (CFAbsoluteTimeGetCurrent() - initialTime) + additionalSavedTime;
}

-(float)getLevelTime
{
    return (CFAbsoluteTimeGetCurrent() - initialTime) + additionalLevelTime;
}

-(NSString*)getTimeString: (float) theTime  // returns the time as a string, for example: "5 minutes and 30 seconds" or "30.15 seconds"
{
    float seconds = fmodf(theTime, 60);
    int minutes = roundf(theTime / 60);
    NSString* userTimeString;
    
    if (minutes < 1)    // we return only seconds with two digits
    {
        userTimeString = [NSString stringWithFormat:@"%.2f seconds", seconds];
    }
    else if(minutes == 1)
    {
        userTimeString = [NSString stringWithFormat:@"one minute and %.0f seconds", seconds];
    }
    else if(minutes < 60) // we return minutes and seconds
    {
        userTimeString = [NSString stringWithFormat:@"%d minutes and %.0f seconds", minutes, seconds];
    }
    else // more than 60 minutes: we return this text
    {
        userTimeString = @"more than an hour";
    }
    
    return userTimeString;
}

// PAUSE & RESUME ACTIONS, LEVELS, GAME OVER
- (void)getsPaused
{
    [Edgar removeControl];
    [self->soundController doVolumeFade];
    [self saveAdditionalTime]; // We save the elapsed time. When the player resumes, we set a new initial time.
    [self saveAdditionalLevelTime];
    
    // TODO for next release
    if(containerView){
        NSLog(@"Remove buttons and stuff");
        [[containerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [containerView removeFromSuperview];
    }
//    [[containerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    [containerView removeFromSuperview];
}

-(void)resumeAfterPause
{
    // check if game over was playing
    
    NSLog(@"resume after pause");
    [soundController updateVolumes];
    float fxVolume = [soundController getFxVolume];
    for (plpPlatform *platformNode in platformNodes) {
        [platformNode setVolume: fxVolume];
    }
    
    [self saveInitialTime];
    [Edgar giveControl];
    [self->soundController playTune:@"Sounds/main_music_loop" loops:-1];
    if((movingLeft || movingRight) && !isJumping){
        [self->soundController playFootstepSound];
    }
}

-(void)resumeFromLevel:(NSInteger)theLevel{
    levelTransitioning = TRUE;
    currentLevelIndex = (int)theLevel;
    
    // For users who played older versions and stayed at the tutorial
    if(currentLevelIndex == 0){
        currentLevelIndex = 1;
    }

    // if level <= 1: new game => reset game data (cheat enabled, time...)
//    if(currentLevelIndex <= 1)
//    {
//        [self resetGameData];
//        [Edgar removeLight];
//        [Edgar removeMasque];
//    }else{
//        [self saveInitialTime];
//    }
    
    [myFinishRectangle removeFromParent];
    myFinishRectangle = nil;
    
    [self startLevel];
    [self doFirstOpening];
}

-(void)updateVolumes{
    [soundController getStoredVolumes];
}

// Called when the user restarts a level (upper right button)
- (void)EdgarDiesOf:(int)deathType
{
    NSLog(@"Edgar Dies");
    
    // Player looses its current files
    fileCount -= levelFileCount;
    
    if(isDying == TRUE){
        NSLog(@"Already dying");
        return;
    }else{
        isDying = TRUE;
    }
    [Edgar removeControl];
    if(lifeCount < 0){
        NSLog(@"Already died -- can't restart");
        return;
    }
    [soundController playDeathSound];
    if(deathType == DEATH_RESET && levelTransitioning == TRUE){
        NSLog(@"Restart level disabled at this time");
        return;
    }
    lifeCount--;
    NSLog(@"Current life count: %ld | death type: %d", (long)lifeCount, deathType);
    
    SKAction *ouch = [SKAction sequence:@[
      [SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:1.0 duration: 0.1],
      [SKAction waitForDuration:0.1],
      [SKAction colorizeWithColorBlendFactor:0.0 duration: 0.1]]];
    
    if(deathType == DEATH_SPIKE){
        [Edgar.physicsBody applyImpulse: CGVectorMake(0, 100000)];
    }
    NSLog(@"...");
    
    [Edgar runAction: [SKAction repeatAction: ouch count: 2] completion:^{
        NSLog(@"death action complete");
        SKNode *lostLife = [self->HUD childNodeWithName: [NSString stringWithFormat:@"life%d", (int) self->lifeCount ]];
        [lostLife removeFromParent];
        
        if(self->lifeCount < 1){
            self->levelTransitioning = TRUE;
            
            // (just in case user pauses and comes back -- we actually reset this when “play again” button is pressed)
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            // 0 -> flag for new game
            [defaults setInteger:0 forKey:@"savedLevel"];
            [defaults setInteger:3 forKey:@"lifeCount"];
            [defaults setInteger:0 forKey:@"fileCount"];
            [defaults setFloat:0 forKey:@"totalTime"];
            [defaults synchronize];
            
            [self showGameOver];
            
        }else{
            self->levelTransitioning = TRUE;
            [self->myFinishRectangle removeFromParent];
            self->myFinishRectangle = nil;
            [self doLevelTransition_sameLevel:YES];
        }
    }];
}

- (void)resetEdgar
{
    stopRequested = TRUE;
    isDying = FALSE;
    liftReady = FALSE;
    [Edgar removeAllActions];
    [Edgar.physicsBody setVelocity:CGVectorMake(0, 0)];
    [Edgar setPosition:startPosition];
    
    // To tidy this, it would be better to add a single "reset" method to the plpHero class. Next step...
    
    [Edgar setScale:1];
    [Edgar resetItem];
    // [Edgar giveControl]; // ddd voir si ne fait pas doublon
    
    
    [Edgar setSpeed: 1.0];
    isJumping = FALSE;
    gonnaCrash = FALSE;
    movingLeft = FALSE;
    movingRight = FALSE;
    moveUpRequested = FALSE;
    bigJumpRequested = FALSE;
    moveLeftRequested = FALSE;
    moveRightRequested = FALSE;
    listensToContactEvents = TRUE;
    contextVelocityX = 0;
    EdgarVelocity = DEFAULT_EDGAR_VELOCITY;
}

// END PAUSE & RESUME ACTIONS


// Called just after update, before rendering the scene.
// See Apple's doc: https://developer.apple.com/library/ios/documentation/SpriteKit/Reference/SKScene_Ref/
- (void)didSimulatePhysics
{
    // New code with SKCameraNode, added in iOS 9
    
    // Explanation about how to fix "gap" problems: http://stackoverflow.com/questions/24921017/spritekit-nodes-adjusting-position-a-tiny-bit
    
    if(freeCamera != TRUE)
    {
        // We move the camera when Edgar is close from the edge
        
        // First, we get the horizontal and vertical distances between Edgar and the camera
        CGFloat xDistance = Edgar.position.x - myCamera.position.x; // gets > 0 if Edgar moves right
        CGFloat yDistance = Edgar.position.y - myCamera.position.y;

        // The camera position will stay at the same place if none of the following conditions is met
        CGPoint newCameraPosition = myCamera.position;
        
        if(xDistance < -100 * x3) // a gauche
        {
            newCameraPosition.x = roundf(Edgar.position.x + 100 * x3);
            [myCamera setPosition:CGPointMake(newCameraPosition.x, myCamera.position.y)];
        }
        else if(xDistance > 100 * x3) // a droite
        {
            newCameraPosition.x = roundf(Edgar.position.x - 100 * x3);
            [myCamera setPosition:CGPointMake(newCameraPosition.x, myCamera.position.y)];
        }
        if(yDistance < -100 * x3)
        {
            newCameraPosition.y = roundf(Edgar.position.y + 100 * x3);
            [myCamera setPosition:CGPointMake(myCamera.position.x, newCameraPosition.y)];
        }
        else if(yDistance > 100 * x3)
        {
            newCameraPosition.y = roundf(Edgar.position.y - 100 * x3);
            [myCamera setPosition:CGPointMake(myCamera.position.x, newCameraPosition.y)];
        }
        myCamera.position = CGPointMake(roundf(newCameraPosition.x), roundf(newCameraPosition.y));
    }
    /* Detect if Edgar will crash -- currently disabled
    if(![Edgar.physicsBody isResting]){
        if(Edgar.physicsBody.velocity.dy < -1400 * x3){
            gonnaCrash = TRUE;
        }
    }*/
}

- (void)setNearHero
{
    // Loop through platformnodes and
    // toggles "heroNear" for those in a box of 500 * x3x500 * x3 pixels near the hero.
    for (plpPlatform *platformNode in platformNodes) {
        
        // For debug
        /* float distance = fabs(Edgar.position.y - audioNode.parent.position.y);
         // NSLog(@"Position is %f", audioNode.parent.position.x); */

        if( (fabs(Edgar.position.x - platformNode.position.x) < 500 * x3) && (fabs(Edgar.position.y - platformNode.position.y) < 500 * x3) ){
            [platformNode setHeroNear];
        } else {
            [platformNode setHeroAway];
        }
    }
}



// Called when the user chooses "Save online">"YES" at the end game.
- (void) saveHighScoreForUser:(NSString*)userName
{
    float totalTime = [self getTotalTime];
    NSString *urlStr = [[NSString alloc]
                        initWithFormat:@"https://paulronga.ch/edgar-2/score.php?user=%@&time=%.2f&files=%ld", userName, totalTime, (long)fileCount];
    NSLog(@"%@", urlStr);
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSError *error = nil;
    NSStringEncoding encoding = 0;
    
    NSString *tryString = [[NSString alloc] initWithContentsOfURL:url
                                                     usedEncoding:&encoding
                                                            error:&error];
    if(tryString)
    {
        if(myTextView)
        {
            [self performSelectorOnMainThread:@selector(updateRank:) withObject:tryString waitUntilDone:NO];
        }
    }
}

// Small function to add the online rank to the final ranking textfield (we need to return to the main selector to perform this UI change)
-(void)updateRank:(NSString*)onlineRank
{
    int intRank = [onlineRank intValue];
    NSMutableString* onlineRankSentence = [NSMutableString stringWithFormat:@" Online rank: %d", intRank];
    if(intRank == 1)
    {
        [onlineRankSentence appendString:@"!!!"];
    }else if(intRank <= 10)
    {
        [onlineRankSentence appendString:@"!!"];
    }else{
        [onlineRankSentence appendString:@"!"];
    }
    myTextView.text = [myTextView.text stringByAppendingString:onlineRankSentence];
}

-(void)openCurtains{
    float halfHeight = 200 * x3;
    
    SKSpriteNode *upperCurtain = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(800 * x3, 250 * x3) ];
    SKSpriteNode *lowerCurtain = [upperCurtain copy];
    upperCurtain.anchorPoint = CGPointMake(0.5, 0);
    upperCurtain.position = CGPointMake(0, 0);
    upperCurtain.zPosition = 40;
    upperCurtain.name = @"upperCurtain";
    
    lowerCurtain.anchorPoint = CGPointMake(0.5, 1);
    lowerCurtain.position = CGPointMake(0, 0);
    lowerCurtain.zPosition = 40;
    lowerCurtain.name = @"lowerCurtain";
    [myCamera addChild:upperCurtain];
    [myCamera addChild:lowerCurtain];
    
    SKAction *openupperCurtain = [SKAction moveToY:halfHeight duration: .5];
    SKAction *openlowerCurtain = [SKAction moveToY:-halfHeight duration: .5];
    SKAction *openCurtainsAnimation = [SKAction runBlock:^{
        [upperCurtain runAction: openupperCurtain];
        [lowerCurtain runAction: openlowerCurtain completion:^{
            [self saveInitialTime];
            [self->soundController playTune:@"Sounds/main_music_loop" loops:-1];
            [self->Edgar giveControl];
        }];
    }];
    
    [myWorld runAction: openCurtainsAnimation];
}

-(void)doFirstOpening{
    [self openCurtains];
    
    SKNode *touchIndicator = [HUD childNodeWithName:@"//touchIndicator"];
    
    if(currentLevelIndex != 1){
        [touchIndicator runAction: [SKAction fadeOutWithDuration: 5.0] completion:^{
            [touchIndicator removeAllChildren];
            [touchIndicator removeFromParent];
        }];
    }
}


-(void)doLevelTransition_sameLevel:(BOOL)repeatingLevel{
    
    float halfHeight = 200 * x3;
    
    // A. Save to additionalTime; we call saveInitialTime when the curtains open again (we don't count time between levels, it wouldn't be fair!)
    
    float totalTime = [self getTotalTime];
    float levelTime = [self getLevelTime];
    [self saveAdditionalTime];
    
    // B. Prepare the time display
    
    /*
        Most examples about SKLabelNode are terribly inneficient. See this blog post: https://gilesey.wordpress.com/2015/01/14/ios-spritekit-font-loading-times-of-sklabelnodes/
        If you only write "Gill sans", it'll take ~4 seconds to load.
    */
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width-40, self.view.bounds.size.height-40,50,50)];
    [spinner startAnimating];
    [self.view addSubview:spinner];

    SKLabelNode *displayTime = [SKLabelNode labelNodeWithFontNamed:@"GillSans"];
    displayTime.fontSize = 30 * x3;
    displayTime.fontColor = [SKColor whiteColor];
    displayTime.position = CGPointMake(0, 30 * x3);
    displayTime.zPosition = 42;
    
    SKLabelNode *displayTime2 = [SKLabelNode labelNodeWithFontNamed:@"GillSans"];
    displayTime2.fontSize = 24 * x3;
    displayTime2.fontColor = [SKColor whiteColor];
    displayTime2.position = CGPointMake(0, -10 * x3);
    displayTime2.zPosition = 42;
    
    SKLabelNode *displayFiles = [SKLabelNode labelNodeWithFontNamed:@"GillSans"];
    displayFiles.fontSize = 24 * x3;
    displayFiles.fontColor = [SKColor whiteColor];
    displayFiles.position = CGPointMake(0, -50 * x3);
    displayFiles.zPosition = 42;
    
    
    
    NSLog(@"Screen center x: %f", screenCenterX);
    
    if(repeatingLevel == YES)
    {
        NSArray *quoteArray = @[@"Let’s do it again", @"Nice to see you again", @"Quel plaisir de vous revoir", @"“Only after disaster can we be resurrected”", @"“Everything in nature is resurrection” – Voltaire"];
        NSUInteger randomIndex = arc4random() % quoteArray.count;
        displayTime.text = [[NSString alloc] initWithFormat:@"%@", quoteArray[randomIndex]]; // plutot une citation random?
        displayTime2.text = [[NSString alloc] initWithFormat:@"Your total time: %@", [self getTimeString: totalTime]];
        
        displayFiles.text = [[NSString alloc] initWithFormat:@"%ld files collected until now", (long) fileCount];
    }
    else
    {
        displayTime.text = [[NSString alloc] initWithFormat:@"Total time: %@", [self getTimeString: totalTime]];
            
        displayTime2.text = [[NSString alloc] initWithFormat:@"This level: %@", [self getTimeString: levelTime]];
        
        displayFiles.text = [[NSString alloc] initWithFormat:@"%ld/%lu files collected", (long) levelFileCount, (long)levelTotalFileCount];
    }
    
    
    
    
    
    SKSpriteNode *upperCurtain = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(800 * x3, 250 * x3) ];
    SKSpriteNode *lowerCurtain = [upperCurtain copy];
    upperCurtain.anchorPoint = CGPointMake(0.5, 0);
    upperCurtain.position = CGPointMake(0, halfHeight);
    upperCurtain.zPosition = 40;
    upperCurtain.name = @"upperCurtain";
    
    lowerCurtain.anchorPoint = CGPointMake(0.5, 1);
    lowerCurtain.position = CGPointMake(0, -halfHeight);
    lowerCurtain.zPosition = 40;
    lowerCurtain.name = @"lowerCurtain";
    [myCamera addChild:upperCurtain];
    [myCamera addChild:lowerCurtain];

    // The three actions of the level transition are written in reverse order here:

    // 3. Third action: open curtains

    SKAction *openupperCurtain = [SKAction moveToY:halfHeight duration: .5];
    SKAction *openlowerCurtain = [SKAction moveToY:-halfHeight duration: .5];
    SKAction *openCurtainsAnimation = [SKAction runBlock:^{
        [upperCurtain runAction: openupperCurtain];
        [lowerCurtain runAction: openlowerCurtain completion:^{
            [self saveInitialTime];
            self->additionalLevelTime = 0;
            [self->Edgar giveControl];
            //   levelTransitioning = FALSE; -> too late, may cause unexpected behaviours
        }];
    }];

    // 2. Second action: present score and start level (completion = action 3: open curtains)
    SKAction *presentScore = [SKAction runBlock:^{
        [self->myCamera addChild:displayTime];
        [self->myCamera addChild:displayTime2];
        [self->myCamera addChild:displayFiles];
        
        SKAction *textFadeOut = [SKAction sequence: @[[SKAction fadeAlphaTo:1 duration:.3], [SKAction waitForDuration:1.5],[SKAction fadeAlphaTo:0 duration:1], [SKAction removeFromParent]]];
        [displayTime runAction:textFadeOut];
        [displayFiles runAction:textFadeOut];
        [displayTime2 runAction:textFadeOut completion:^{
            [self->myWorld runAction: openCurtainsAnimation];
        }];
        [self startLevel];
    }];

    
    // 1. First action: close curtains (completion = action 2: present score)
    [upperCurtain runAction: [SKAction moveToY:-20 duration: .5]];
    [lowerCurtain runAction: [SKAction moveToY:20 duration: .5] completion:^
    {
        [spinner removeFromSuperview];
        [self->myWorld runAction:presentScore];
    }];
    
}

-(void)startLevel{
    for (SKNode* theNode in [myLevel children]) {
        [theNode removeFromParent];
    }
    [platformNodes removeAllObjects];

    [myLevel removeFromParent]; // signal SIGABRT
    [Edgar removeFromParent];
    [self resetEdgar];
    levelFileCount = 0;
    
    if([myCamera hasActions]) // on annule effets de zoom, etc.
    {
        [myCamera removeAllActions];
    }
    
    if(currentLevelIndex == LAST_LEVEL_INDEX)
    {
        [Edgar removeLight];
        [Edgar removeMasque];
        // [self doVolumeFade]; -> no, we keep the music
    }
    
    myLevel = [self loadLevel: currentLevelIndex];
    
    myWorld.position = CGPointMake(0, 0);
    [myWorld addChild: myLevel];
    
    [self addCollisionLayer: myLevel];
    [self loadAssets: myLevel];
    Edgar.position = startPosition;
    myCamera.position = startPosition;
    
    [myLevel addChild: Edgar];
    
    setNearHeroTimer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                     target:self
                                   selector:@selector(setNearHero)
                                   userInfo:nil
                                    repeats:YES];
    
    SKPhysicsJointFixed *pinEdgar = [SKPhysicsJointFixed jointWithBodyA:Edgar.physicsBody bodyB:Edgar->rectangleNode.physicsBody anchor:CGPointMake(Edgar.position.x, Edgar.position.y)];
    [self.physicsWorld addJoint:pinEdgar];
    
    NSLog(@"Edgar gets control back");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger: currentLevelIndex forKey:@"savedLevel"];
    [defaults setInteger: lifeCount forKey:@"lifeCount"];
    [defaults setInteger: fileCount forKey:@"fileCount"];
    [defaults setFloat:[self getTotalTime] forKey:@"totalTime"];
    [defaults synchronize];
    
    NSLog(@"Level saved: %d", currentLevelIndex);
    
    if(currentLevelIndex > 1 && currentLevelIndex < LAST_LEVEL_INDEX)
    {
        [Edgar addLight]; // shadow effect for levels 2-6
        
        if(currentLevelIndex == FIRST_DARK_LEVEL)
        {
            SKNode *lampe = [Edgar childNodeWithName:@"light"];
            [Edgar addMasque];
            if(lampe)
            {
                [(SKLightNode*) lampe setShadowColor: [[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:0.88]];
            }
        }

    }
    levelTransitioning = FALSE;
}

- (void) didBeginContact:(SKPhysicsContact *)contact
{
    SKNode *contactNode = contact.bodyA.node;
    SKNode *userNode = contact.bodyB.node;
    
    if(!listensToContactEvents)
    {
        return;
    }
    
    if(contactNode.physicsBody.categoryBitMask == PhysicsCategoryEdgar)
    {
        // Then the nodes are inverted
        contactNode = contact.bodyB.node;
        userNode = contact.bodyA.node;
    }else{
        if(userNode.physicsBody.categoryBitMask != PhysicsCategoryEdgar)
        {
            // React only if we need to render a sound
            if(userNode.physicsBody.categoryBitMask == PhysicsCategoryObjects){
                if(contact.collisionImpulse > 2000000){
                    NSLog(@"Train: huge collision impulse");
                    // [self->soundController playTrainImpactSound];
                }
                //NSLog(@"Collision impulse is: %f", contact.collisionImpulse);
                // NSLog(@"Object vs object");
            }
            
            return; // It means Edgar isn't involved / Edgar n'est pas impliqué
        }
    }
    
    if(isJumping==TRUE)
    {
        if(contactNode.physicsBody.categoryBitMask == PhysicsCategoryTiles || contactNode.physicsBody.categoryBitMask == PhysicsCategoryObjects)
        {
            if([userNode.name isEqualToString:@"Edgar"])
            {
                isJumping = FALSE;
                EdgarVelocity = DEFAULT_EDGAR_VELOCITY;
                if(movingLeft || movingRight){
                    [self->soundController playFootstepSound];
                }
            }
        }
    }
    
    
    if(willLoseContextVelocity==TRUE)
    {
        contextVelocityX = 0;
        willLoseContextVelocity = FALSE;
    }
    
    if(contactNode.physicsBody.categoryBitMask == PhysicsCategorySensors)
    {
        if([contactNode.name isEqualToString:@"endLevelLiftNode"] && [Edgar hasItem])
        {
            if(!liftReady){
                SKAction *greenDoor = [SKAction setTexture:[SKTexture textureWithImageNamed:@"ascenseurO-01.png"]];
                [self->soundController playLiftReadySound];
                [contactNode runAction:greenDoor];
                liftReady = true;
            }
        }
        else if([contactNode.name isEqualToString:@"spike"])
        {
            NSLog(@"spike");
            [self EdgarDiesOf: DEATH_SPIKE];
        }
        else if([contactNode.name isEqualToString:@"platformSensor"])
        {
            NSLog(@"platform sensor...");
            [(plpPlatform *)contactNode.parent setHeroAbove];
        }
        else if([contactNode.name isEqualToString:@"finish"])
        {
            if(!levelTransitioning)
            {
                if([Edgar hasItem])
                {
                    /* SND: success - else: error sound */
                    
                    levelTransitioning = TRUE;
                    
                    // TODO Remove all FX sounds
                    [setNearHeroTimer invalidate];
                    setNearHeroTimer = nil;
                    
                    [Edgar removeControl];
                    [Edgar runAction: [SKAction sequence:@[[SKAction moveToX:myFinishRectangle.position.x duration: .2], [SKAction runBlock:^{
                        self->stopRequested = TRUE;
                        [self->soundController playTakeLiftSound];
                    }]]]];

                    [myFinishRectangle removeFromParent];
                    myFinishRectangle = nil;
                    currentLevelIndex++;
                    
                    NSLog(@"Loading level %d", currentLevelIndex);
                    
                    [self doLevelTransition_sameLevel:NO];
                } // end if [Edgar hasItem]
            } // end if !levelTransitioning
        } // end if finish

        if(currentLevelIndex==LAST_LEVEL_INDEX)
        {
            if([contactNode.name isEqualToString:@"finalAnimationSensor"] && contactNode != nil)
            {
                NSLog(@"Final animation 1 triggered");
                
                [contactNode removeFromParent];
                [Edgar removeControl];
                if(!movingRight)
                {
                    moveRightRequested = TRUE;
                }
                
                
                SKAction *audioPlayAction = [SKAction runBlock:^{
                    [self->soundController playTune:@"Sounds/final_theme" loops:0];
                }];
                
                SKAction *theScale = [SKAction scaleTo:1.5 duration:2];
                [myCamera runAction: theScale];
                
                // First animation
                SKNode *alienVessel;
                alienVessel = [SKSpriteNode spriteNodeWithImageNamed:@"UFO_x3.png"];
                alienVessel.name = @"alienVessel";
                
                SKSpriteNode *beam = [SKSpriteNode spriteNodeWithImageNamed:@"Rayon_x3.png"];
                beam.alpha = 0;
                beam.name = @"beam";
                
                CGPoint referencePoint = [myLevel childNodeWithName:@"referencePoint"].position;
                CGPoint referencePointAlien = CGPointMake(referencePoint.x, referencePoint.y - 90); // ddd precedemment: -100 * x3
                
                SKAction *waitAction = [SKAction waitForDuration: 1];
                
                SKAction *createAlien = [SKAction runBlock:^{
                    alienVessel.position = CGPointMake(self->Edgar.position.x, self->Edgar.position.y+400 * x3);
                    [self->myLevel addChild: alienVessel];
                    
                    [alienVessel addChild: beam];
                    beam.position = CGPointMake(0, -50);
                    beam.zPosition = -12;
                }];
                
                SKAction *moveAlien = [SKAction runAction:[SKAction moveTo:referencePointAlien duration:2] onChildWithName:@"//alienVessel"];
                moveAlien.timingMode = SKActionTimingEaseInEaseOut;
                
                [myLevel runAction:[SKAction sequence:@[waitAction, audioPlayAction, [SKAction scaleTo:1 duration:1], createAlien, moveAlien]]];
            }
            else if([contactNode.name isEqualToString:@"finalAnimationSensor2"])
            {
                NSLog(@"Final animation 2 triggered");
                
                if(levelTransitioning==TRUE)
                {
                    NSLog(@"Already transitioning");
                }else{
                    levelTransitioning = TRUE;
                    
                    // Second animation
                    CGPoint referencePoint = [myLevel childNodeWithName:@"referencePoint"].position;
                    [contactNode removeFromParent];
                    
                    SKAction *showBeam = [SKAction runAction:[SKAction fadeAlphaTo:1 duration:0] onChildWithName:@"beam"];
                    
                    SKAction *beamSound = [SKAction playSoundFileNamed:@"Sounds/fx_faisceau_alien.wav" waitForCompletion:NO];
                    
                    SKSpriteNode *beam = (SKSpriteNode*)[myLevel childNodeWithName:@"//beam"];
                    
//                    SKAction *shortWaitAction = [SKAction waitForDuration: 0.2];
                    SKAction *longWaitAction = [SKAction waitForDuration: 2];
                    
                    
                    SKAction *createBeam = [SKAction runBlock:^{
                        [beam setAlpha: 1.0f];
                        [self->soundController stopFootstepSound];
                        [self->Edgar removeActionForKey:@"bougeDroite"];
                        [self->Edgar removeActionForKey:@"walkingInPlaceEdgar"];
                        [self->Edgar.physicsBody setVelocity: CGVectorMake(0, 0)];
                        self->Edgar.physicsBody.affectedByGravity = false;
                        self->Edgar->rectangleNode.physicsBody.affectedByGravity = false;
                        self->freeCamera = TRUE;
                        [self->myCamera runAction:[SKAction moveToY:self->Edgar.position.y+200 * x3 duration:1]];
                        self->currentLevelIndex = 1;
                        [self runAction: beamSound];
                    }];
                    
                    SKAction *flyAway = [SKAction runAction:[SKAction moveTo:CGPointMake(2000 * x3, 2000 * x3) duration:4] onChildWithName:@"//alienVessel"];
                    [flyAway setTimingMode: SKActionTimingEaseIn];
                    SKAction *flyAwaySound = [SKAction playSoundFileNamed:@"Sounds/fx_vaisseau_part.wav" waitForCompletion:NO];
                    
                    SKAction *moveEdgar = [SKAction runAction:[SKAction moveTo:referencePoint duration:2] onChildWithName:@"//Edgar"];
                    moveEdgar.timingMode = SKActionTimingEaseInEaseOut;
                    
                    
                    SKAction *vanish = [SKAction runAction:[SKAction fadeAlphaTo:0 duration:0] onChildWithName:@"//Edgar"];
                    SKAction *removeBeam = [SKAction runBlock:^{
                        [beam removeFromParent];
                    }];
                    
                    SKAction *finalMessage = [SKAction runBlock:^{
                        self->containerView = [[UIView alloc] init];
                        [self->containerView setFrame: CGRectMake(50, 50, self.view.bounds.size.width-100, self.view.bounds.size.height-100)]; // coordinates origin is upper left
                        
                        self->containerView.backgroundColor = [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1];
                        
                        self->myTextView = [[UITextView alloc] init];
                        NSString* userTimeString = [self getTimeString: [self getTotalTime]];
                        
                        self->myTextView.text = [NSString stringWithFormat:@"You did it! \nYour time: %@.\nHowever, the alien vessel wasn’t part of the plan… \nStay tuned for the next part.\n\nSave your score online?", userTimeString];
                        
                        self->myTextView.textColor = [UIColor whiteColor];
                        self->myTextView.backgroundColor = [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1];
                        self->myTextView.editable = NO;
                        [self->myTextView setFont:[UIFont fontWithName:@"GillSans" size:18]];
                        
                        float outsideMargin = 60;
                        float insideMargin = 30;
                        float buttonsVerticalPosition = self->containerView.bounds.size.height-50;
                        float buttonWidth = (self->containerView.bounds.size.width/2) - (outsideMargin + insideMargin);
                        float buttonYesPositionX = outsideMargin;
                        float buttonNoPositionX = buttonWidth + outsideMargin + 2*insideMargin;
                        
                        [self->myTextView setFrame: CGRectMake(20, 5, self->containerView.bounds.size.width-40, self->containerView.bounds.size.height-70)];
                        
                        
                        UIButton *myButtonYes  =   [UIButton buttonWithType:UIButtonTypeRoundedRect];
                        myButtonYes.frame      =   CGRectMake(buttonYesPositionX, buttonsVerticalPosition, buttonWidth, 30.0);
                        [myButtonYes setBackgroundColor: [UIColor whiteColor]];
                        
                        [myButtonYes setTitleColor: [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1] forState:UIControlStateNormal];
                        [[myButtonYes layer] setMasksToBounds:YES];
                        [[myButtonYes layer] setCornerRadius:5.0f];
                        
                        
                        [myButtonYes setTitle: @"Yes" forState:UIControlStateNormal];
                        [myButtonYes addTarget: self
                                        action: @selector(endGameWithScore:)
                              forControlEvents: UIControlEventTouchUpInside];
                        
                        UIButton *myButtonNo  =   [UIButton buttonWithType:UIButtonTypeRoundedRect];
                        myButtonNo.frame      =   CGRectMake(buttonNoPositionX, buttonsVerticalPosition, buttonWidth, 30.0);
                        [myButtonNo setBackgroundColor: [UIColor whiteColor]];
                        [myButtonNo setTitleColor: [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1] forState:UIControlStateNormal];
                        [[myButtonNo layer] setMasksToBounds:YES];
                        [[myButtonNo layer] setCornerRadius:5.0f];
                        
                        [myButtonNo setTitle: @"No" forState:UIControlStateNormal];
                        [myButtonNo addTarget: self
                                       action: @selector(endGameNoSaveScore:)
                             forControlEvents: UIControlEventTouchUpInside];
                        
                        [self.view addSubview: self->containerView];
                        [self->containerView addSubview:self->myTextView];
                        [self->containerView addSubview:myButtonYes];
                        [self->containerView addSubview:myButtonNo];
                    }];
                    
                    [myLevel runAction:[SKAction sequence:@[createBeam, showBeam, moveEdgar, longWaitAction, vanish, removeBeam, longWaitAction, flyAwaySound, flyAway, longWaitAction, finalMessage]]];
                }
            } // end if LAST_LEVEL_INDEX
        }else if(currentLevelIndex==1) // Tutorial level
        {
            SKSpriteNode *helpNode;
            
            // First we remove any precedent help image
            if((helpNode = (SKSpriteNode*)[myCamera childNodeWithName:@"helpNode"]))
            {
                [helpNode removeFromParent];
                helpNode = nil;
            }
            
            if([contactNode.name isEqualToString:@"walk"])
            {
                if(useSwipeGestures){
                    helpNode = [SKSpriteNode spriteNodeWithImageNamed:@"UI_img/swipeRight.png"];
                }else{
                    SKNode *touchIndicator = [HUD childNodeWithName:@"//touchIndicator"];
                    for (SKNode* theNode in [touchIndicator children]) {
                        [theNode setAlpha: 0.2];
                    }
                    
                    SKNode *moveRight = [HUD childNodeWithName:@"//touchIndicator/right"];
                    SKAction *fadeIn = [SKAction fadeAlphaTo: 1 duration: .5];
                    SKAction *fadeOut = [SKAction fadeAlphaTo: 0.4 duration: .5];
                    [moveRight runAction: [SKAction repeatActionForever: [SKAction sequence:@[fadeIn, fadeOut]]]];
                }
            }else if([contactNode.name isEqualToString:@"run"])
            {
                if(useSwipeGestures){
                    helpNode = [SKSpriteNode spriteNodeWithImageNamed:@"UI_img/swipeJump.png"];
                }else{
                    SKNode *moveRight = [HUD childNodeWithName:@"//touchIndicator/right"];
                    [moveRight removeAllActions];
                    [moveRight setAlpha: 0.2];
                    
                    SKNode *middleRight = [HUD childNodeWithName:@"//touchIndicator/middleright"];
                    SKAction *fadeIn = [SKAction fadeAlphaTo: 1 duration: .5];
                    SKAction *fadeOut = [SKAction fadeAlphaTo: 0.4 duration: .5];
                    [middleRight runAction: [SKAction repeatActionForever: [SKAction sequence:@[fadeIn, fadeOut]]]];                }
            }else if([contactNode.name isEqualToString:@"jump"])
            {
                NSLog(@"jump sprite");
                SKNode *middleRight = [HUD childNodeWithName:@"//touchIndicator/middleright"];
                [middleRight removeAllActions];
                [middleRight setAlpha: 0.2];
                
                SKNode *upRight = [HUD childNodeWithName:@"//touchIndicator/upright"];
                SKAction *fadeIn = [SKAction fadeAlphaTo: 1 duration: .5];
                SKAction *fadeOut = [SKAction fadeAlphaTo: 0.4 duration: .5];
                [upRight runAction: [SKAction repeatActionForever: [SKAction sequence:@[fadeIn, fadeOut]]]];
            }else if([contactNode.name isEqualToString:@"showFile"])
            {
                [contactNode removeFromParent];
                helpNode = [SKSpriteNode spriteNodeWithImageNamed:@"UI_img/showFile.png"];
                [helpNode setPosition:[myLevel childNodeWithName:@"file"].position];
                [helpNode setSize:CGSizeMake(250, 250)];
                [helpNode runAction:[SKAction repeatAction:[SKAction sequence:@[[SKAction fadeAlphaTo:1 duration:1.5], [SKAction fadeAlphaTo:0 duration:.5]]] count:2]];
                [myLevel addChild: helpNode];
                
            }
            
            if(helpNode)
            {
                helpNode.name = @"helpNode";
                if(!helpNode.position.x)
                {
                    [helpNode setPosition:CGPointMake((30)*x3, -100.0f * x3)];
                    [myCamera addChild: helpNode];
                }
            }
            
        }
    }
    
    if(contactNode.physicsBody.categoryBitMask == PhysicsCategoryItems)
    {
        /* SND: item gathered */
        if([contactNode.name isEqualToString: @"uranium"])
        {
            [Edgar takeItem];
            if(contactNode.hidden == NO)
            {
                [self->soundController playTakeCellSound];
            }
            [myLevel childNodeWithName:@"uranium"].hidden = YES;  // <- to simply hide the object
            //            [(plpItem *)contactNode removeFromParent]; // <- if there is a need to remove the item
            if(currentLevelIndex==0)
            {
                SKNode* helpNode;
                if((helpNode = [myLevel childNodeWithName:@"//helpNode"]))
                {
                    [helpNode removeFromParent];
                }
            }
        }else if([contactNode.name isEqualToString: @"file"])
        {
            // TODO: store score
            [soundController playTakeFileSound];
            fileCount++;
            levelFileCount++;
            fileCountLabel.text = [ [NSString alloc] initWithFormat: @"%ld/%lu", (long) levelFileCount, (long)levelTotalFileCount];
            [(plpItem *)contactNode removeFromParent];
        }
    }
    
    
    if(contactNode.physicsBody.categoryBitMask == PhysicsCategoryObjects)
    {
        // son caisse
        if([contactNode.name isEqual: @"caisse"]){
            NSLog(@"Vitesse caisse: %f", contactNode.physicsBody.velocity.dx);
            
            //NSLog(@"Vitesse caisse: %f", contactNode.physicsBody.);
            
            // TODO Dans l’idéal: à lier au frottement de la caisse sur le sol
            // Si la caisse bouge assez vite...
            if(fabs(contactNode.physicsBody.velocity.dx) > 200){
                // ... et n’est pas contre le mur de gauche
                if(contactNode.position.x > 310){
                    [soundController playCrateSound];
                }
            }
            return;
        }
        
        if([contactNode isKindOfClass:[plpTrain class]])
        {
            /* SND: train runs */
            if( (Edgar.position.x + Edgar.frame.size.width > contactNode.position.x) && (Edgar.position.x < contactNode.position.x + contactNode.frame.size.width) ){
                
                plpTrain *theTrain = (plpTrain *)contactNode;
                [theTrain setHeroAbove];
            
                [(plpTrain *)contactNode accelerateAtRate:20 toMaxSpeed: 100]; // previous max speed: 200 * x3
            }
            return;
        }
        
        if([contactNode isKindOfClass:[plpPlatform class]])
        {
            float deltaX = Edgar.position.x - contactNode.position.x;
            
            // NSLog(@"Edgar : %f, plateforme: %f", Edgar.position.y, contactNode.position.y + 28);
            
            // NSLog(@"Edgar x : %f, plateforme: %f, delta: %f", Edgar.position.x, contactNode.position.x, deltaX);
            
            // Determine vertical position, check if the platform should stop
            
            if([(plpPlatform *)contactNode getIsVertical] == TRUE)
            {
                // TODO: check this number
                if (Edgar.position.y < contactNode.position.y + 28)
                {
                    [(plpPlatform *)contactNode emergencyStop];
                    
                    // Edgar has its feet on the ground and is well under the platform
                    if( (deltaX < 330) && (deltaX > -35) && (!isJumping) ){
                        NSLog(@"†");
                        [self EdgarDiesOf: DEATH_PLATFORM];
                    }
                }
            }
            else // If horizontal, also check if a horizontal stop is needed
            {
                if (Edgar.position.y < contactNode.position.y + 28){
                    [(plpPlatform *)contactNode horizontalEmergencyStop:Edgar.position.x];
                }
            }
        }
    }
    
    if(contactNode.physicsBody.categoryBitMask == PhysicsCategoryEnemy)
    {
        if([contactNode isKindOfClass:[plpAlien class]])
        {
            if([(plpAlien*)contactNode canGiveLife])
            {
                [soundController playAlienSound];
                SKAction *getPurple = [SKAction sequence:@[
                [SKAction colorizeWithColor:[SKColor purpleColor] colorBlendFactor:0.8 duration:0.15],
                [SKAction waitForDuration:.5],
                [SKAction colorizeWithColorBlendFactor:0.0 duration:0.3]]];
                [Edgar runAction: getPurple withKey: @"collectLife"];
                
                SKSpriteNode *edgarLife = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"Vie"] size: CGSizeMake(43, 100)];
                [edgarLife setPosition: CGPointMake(0, 100)];
                [edgarLife setScale: 2.0];
                
                [edgarLife setName: [NSString stringWithFormat:@"life%ld", (long)lifeCount]];
                [HUD addChild: edgarLife];
                [edgarLife runAction: [SKAction moveTo: CGPointMake(-320 * x3 + (lifeCount * 80), 250 + 500 * screenRatio) duration: 1.0]];
                [edgarLife runAction: [SKAction scaleTo: 1.0 duration: 1.0]];
                
                lifeCount++;
            }
        }else if([contactNode isKindOfClass:[plpScientist class]]){
            if([(plpScientist *)contactNode isDangerous]){
                // physicsbody du dessus ou du dessous?
                if(Edgar.position.y - 126 > contactNode.position.y){
                    [(plpScientist *)contactNode dies];
                    [soundController playKillScientistSound];
                    
                    SKSpriteNode *trapDoorLeft = (SKSpriteNode*)[myLevel childNodeWithName:@"trapDoorLeft"];
                    if(trapDoorLeft){
                        [trapDoorLeft runAction: [SKAction rotateByAngle: -1.5708 duration: 1]];
                    }
                    SKSpriteNode *trapDoorRight = (SKSpriteNode*)[myLevel childNodeWithName:@"trapDoorRight"];
                    if(trapDoorRight){
                        [trapDoorRight runAction: [SKAction rotateByAngle: 1.5708 duration: 1]];
                    }
                }else{
                    [self EdgarDiesOf: DEATH_ENEMY];
                }
            }
        }
    }
}

// Called from NSTimer after didEndContact
-(void)removeContextVelocity
{
    NSLog(@"Remove velocity");
    willLoseContextVelocity = TRUE;
}

-(void)didEndContact:(SKPhysicsContact *)contact
{
    SKNode *contactNode = contact.bodyA.node;
    
    
    if(contactNode.physicsBody.categoryBitMask == PhysicsCategoryEdgar)
    {
        contactNode = contact.bodyB.node;
    }else{
        if(contact.bodyB.node.physicsBody.categoryBitMask != PhysicsCategoryEdgar)
        {
            return; // It means Edgar isn't involved / Edgar n'est pas impliqué
        }
    }
    
    if(contactNode.physicsBody.categoryBitMask == PhysicsCategoryObjects)
    {
        // fin son caisse
        if([contactNode.name isEqualToString: @"caisse"]){
            [soundController stopCrateSound];
            return;
        }
        
        if([contactNode isKindOfClass:[plpTrain class]])
        {
//            NSLog(@"Leaves the train => deceleration");
            [(plpTrain *)contactNode decelerateAtRate:15];
            [(plpTrain *)contactNode HeroWentAway];
            willLoseContextVelocity = TRUE;
            return;
        }
        
        /*if([contactNode isKindOfClass:[plpPlatform class]])
        {
            NSLog(@"End contact");
            [(plpPlatform *)contactNode HeroWentAway];
            willLoseContextVelocity = TRUE; // ou pour effet immédiat:  contextVelocityX = 0;
        }*/
    }
    
    if(contactNode.physicsBody.categoryBitMask == PhysicsCategorySensors)
    {
        if([contactNode.name isEqualToString: @"platformSensor"])
        {
            
            [(plpPlatform *)contactNode.parent HeroWentAway];
            willLoseContextVelocity = TRUE; // ou pour effet immédiat:  contextVelocityX = 0;
        }
    }
    
    
    if(currentLevelIndex==1) // Tutorial
    {
        if(contactNode.physicsBody.categoryBitMask == PhysicsCategorySensors)
        {
            if( (![contactNode.name isEqualToString:@"finish"]) && (![contactNode.name isEqualToString:@"endLevelLiftNode"]) )
            {
                SKNode* helpNode;
                
                if(useSwipeGestures){
                    if((helpNode = (SKSpriteNode*)[myCamera childNodeWithName:@"//helpNode"]))
                    {
                        [helpNode removeFromParent];
                        helpNode = nil;
                        [contactNode removeFromParent]; // We remove the sensor / On enlève le senseur
                    }
                }else{ // move on touch
                    if([contactNode.name isEqualToString:@"run"])
                    {
                        SKNode *middleRight = [HUD childNodeWithName:@"//touchIndicator/middleright"];
                        [middleRight removeAllActions];
                        [middleRight setAlpha: 0.2];
                    }else if([contactNode.name isEqualToString:@"jump"]){
                        NSLog(@"remove jump");
                             SKNode *upright = [HUD childNodeWithName:@"//touchIndicator/upright"];
                             [upright removeAllActions];
                             [upright setAlpha: 0.2];
                    }
                }
            }
        }
    }
}


- (void)startTimerWithDelay:(double) secondsToFire
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    _timer = CreateDispatchTimer(secondsToFire, queue, ^{
        self->stopRequested = TRUE;
    });
}

- (void)cancelTimer
{
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // We get touches events before the update() function.
    // On detecte les mouvements et la position du personnage avant de transmettre à update().
    
    if([Edgar hasControl]==TRUE)
    {
        for (UITouch *touch in touches) {
            
            if(useSwipeGestures){
                // store start position to get gesture in "touch end"
                touchStartPosition = [touch locationInNode:self];
            }else{
                [self cancelTimer];
                touchStartPosition = [touch locationInNode: myCamera];
                if( !movingRight && touchStartPosition.x > HUD_HORIZONTAL_SPAN)
                {
                    moveRightRequested = true;
                    stopRequested = false;
                } else if ( !movingLeft && touchStartPosition.x < -HUD_HORIZONTAL_SPAN){
                    moveLeftRequested = true;
                    stopRequested = false;
                }
                if(touchStartPosition.y > HUD_VERTICAL_SPAN){
                    bigJumpRequested = true;
                    moveUpRequested = true;
                    stopRequested = false;
                }else if(touchStartPosition.y > -HUD_VERTICAL_SPAN){
                    moveUpRequested = true;
                    stopRequested = false;
                }else{
                    if(!moveRightRequested && !moveLeftRequested){
                        // show HUD?
                    }
                }
                    
            }
            
            if(cheatsEnabled == TRUE)
            {
                if(touch.tapCount == 4)
                {
                    if(!self.view.showsPhysics)
                    {
                        self.view.showsPhysics = YES;
                        self.view.showsFPS = YES;
                        self.view.showsNodeCount = YES;
                    }
                    else
                    {
                        self.view.showsPhysics = NO;
                        self.view.showsFPS = NO;
                        self.view.showsNodeCount = NO;
                    }
                }
                else if(touch.tapCount == 5) // Shortcut to the next level | Raccourci vers le niveau suivant
                {
                    if(currentLevelIndex < LAST_LEVEL_INDEX && !levelTransitioning)
                    {
                        levelTransitioning = TRUE;
                        [myFinishRectangle removeFromParent];
                        myFinishRectangle = nil;
                        currentLevelIndex++;
                        NSLog(@"Loading level %d", currentLevelIndex);
                        [self startLevel];
                    }
                }
                else if(touch.tapCount == 6)
                {
                    if(!levelTransitioning)
                    {
                        levelTransitioning = TRUE;
                        [myFinishRectangle removeFromParent];
                        myFinishRectangle = nil;
                        currentLevelIndex = 8;
                        [self startLevel];
                    }
                }
            }
            
            if(enableDebug && !cheatsEnabled && touch.tapCount == 5)
            {
                cheatsEnabled = TRUE;
                SKLabelNode *cheatEnabledMessage = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
                cheatEnabledMessage.fontSize = 100;
                [cheatEnabledMessage setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
                
                cheatEnabledMessage.fontColor = [SKColor redColor];
                cheatEnabledMessage.position = CGPointMake(0, 0); // should be ~ 100 * x3 for an iPad air -> find a way to do it better
                cheatEnabledMessage.zPosition = 30;
                cheatEnabledMessage.text = @"Cheats active. Time penalty!";
                cheatEnabledMessage.alpha = 0;
                [myCamera addChild: cheatEnabledMessage];

                [cheatEnabledMessage runAction:[SKAction sequence:@[[SKAction fadeAlphaTo: 1 duration: .5], [SKAction waitForDuration: 1], [SKAction fadeAlphaTo: 0 duration: .5], [SKAction removeFromParent]]]];

                additionalSavedTime += 60000;
            }
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if([Edgar hasControl]){
        
        for (UITouch *touch in touches) {

            if(!useSwipeGestures){
                //stopRequested = true;
                CGPoint endPosition = [touch locationInNode: myCamera];
                float delay_s = 0.1;

                if(endPosition.y > -HUD_VERTICAL_SPAN){
                    delay_s = .2;
                }
                
                [self startTimerWithDelay: delay_s];
                
            }else{
                CGPoint endPosition = [touch locationInNode:self];

                if(endPosition.y - 10 * x3 > touchStartPosition.y)
                {
                    moveUpRequested = TRUE;
                    if(endPosition.y - 130 * x3 > touchStartPosition.y)
                    {
                        bigJumpRequested = TRUE;
                    }
                }
                
                if(endPosition.x -30 * x3 > touchStartPosition.x)
                {
                    moveRightRequested = TRUE;
                }
                else if(endPosition.x + 30 * x3 < touchStartPosition.x)
                {
                    moveLeftRequested = TRUE;
                }else if (!moveUpRequested){
                    stopRequested = TRUE;
                }
            }
        }
    }
}


-(void)update:(CFTimeInterval)currentTime {
    
    if(stopRequested == TRUE && !isJumping){
        stopRequested = FALSE;
        movingLeft = FALSE;
        movingRight = FALSE;
        moveRightRequested = FALSE;
        moveLeftRequested = FALSE;
        Edgar.xScale = 1.0;
        [Edgar setSpeed:1.0];
        [Edgar.physicsBody setVelocity: CGVectorMake(0 + contextVelocityX, Edgar.physicsBody.velocity.dy)];
        [Edgar facingEdgar];
        [self->soundController stopFootstepSound];
        
        [Edgar removeActionForKey:@"moveRightKey"];
        [Edgar removeActionForKey:@"moveLeftKey"];
        [Edgar removeActionForKey:@"walkingInPlaceEdgar"];
    }
    
    /*if(isEdgarPinned == TRUE){
        if(moveUpRequested || moveRightRequested || moveLeftRequested){
            NSLog(@"remove joint");
            isEdgarPinned = FALSE;
        }else{
            NSLog(@"asdf");
            [Edgar.physicsBody applyForce: CGVectorMake( 0, -500000)];
        }
    }*/
    
    
    if (moveRightRequested == TRUE && !isJumping){ // pas suffisant: ajouter s'il a pied / vitesse verticale
        moveRightRequested = false;
        if((movingRight!=TRUE) || moveUpRequested){ // ddd why "or moveUpRequested"?
            Edgar.xScale = 1.0;
            
            [Edgar removeActionForKey:@"moveRightKey"];
            [Edgar removeActionForKey:@"moveLeftKey"];
            [Edgar removeActionForKey:@"walkingInPlaceEdgar"];
            
            [Edgar walkingEdgar];
            [Edgar runAction:moveRightAction withKey:@"moveRightKey"];
            [self->soundController stopFootstepSound];
            [self->soundController playFootstepSound];
            movingRight = TRUE;
            movingLeft = FALSE;
        }
    }else if (moveLeftRequested == true && !isJumping){
        moveLeftRequested = false;
        if((movingLeft != TRUE) || moveUpRequested){
            Edgar.xScale = -1.0;
            [Edgar removeActionForKey:@"moveRightKey"];
            [Edgar removeActionForKey:@"moveLeftKey"];
            [Edgar removeActionForKey:@"walkingInPlaceEdgar"];
            
            [Edgar walkingEdgar];
            [Edgar runAction: moveLeftAction withKey:@"moveLeftKey"];
            [self->soundController stopFootstepSound];
            [self->soundController playFootstepSound];
            movingLeft = true;
            movingRight = false;
            Edgar.speed = 1.0;
        }
    }
    
    if (moveUpRequested == true && !isJumping){
        [self->soundController stopFootstepSound];
        [self->soundController playJumpSound];
        
        moveUpRequested = FALSE;
        isJumping = TRUE;
        
        if(bigJumpRequested)
        {
            // Long touch: could be managed with applyForce
            [Edgar.physicsBody applyImpulse: CGVectorMake(0, 400000)]; // auparavant 500 * x300 * x3 puis 4500 * x30 puis 4800 * x30
            bigJumpRequested = FALSE;
        }
        else
        {
            EdgarVelocity = DEFAULT_EDGAR_VELOCITY * 1.8;
            [Edgar.physicsBody applyImpulse: CGVectorMake(0, 200000)];
        }
        
        if(movingLeft||movingRight)
        {
            [Edgar jumpingEdgar];
        }
        
    }
}

- (void) computeSceneCenter
{
    float theScale = 400 * x3 / self.view.bounds.size.height; // usually 1.25
    screenCenterX = 400 * x3 - ((self.view.bounds.size.width * theScale)/2);
}

@end
