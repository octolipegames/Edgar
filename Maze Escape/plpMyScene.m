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

//´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´
//
//  The main scene class: level loading, rendering, input
//
//................................................

@interface plpMyScene () <UITextFieldDelegate>
{
}
@end

@implementation plpMyScene

NSArray *_monstreWalkingFrames;
SKSpriteNode *_monstre;

typedef NS_OPTIONS(uint32_t, MyPhysicsCategory) // We define 6 physics categories
{
    PhysicsCategoryEdgar = 1 << 0,   // 1
    PhysicsCategoryObjects = 1 << 1, // 2
    PhysicsCategoryTiles = 1 << 2,   // 4
    PhysicsCategoryAliens = 1 << 3,  // 8
    PhysicsCategorySensors = 1 << 4, // 16
    PhysicsCategoryItems = 1 << 5    // 32
};


-(id)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        self.physicsWorld.contactDelegate = self;
        self.size = CGSizeMake(800, 400);// => moitie de la largeur = 400 // En fait, coordonnees: 754 x 394 (?)
        
        myWorld = [SKNode node];         // Creation du "monde" sur lequel tout est fixe
        myWorld.name = @"world";
        [self addChild:myWorld];
        
        myCamera = [SKCameraNode node];
        self.camera = myCamera;
        [self addChild:myCamera];
        
        // Actions
        SKAction *mvm1 = [SKAction runBlock:^{
            [Edgar.physicsBody setVelocity:CGVectorMake(EdgarVelocity + contextVelocityX, Edgar.physicsBody.velocity.dy)];        }];
        SKAction *mvm2 = [SKAction runBlock:^{
            [Edgar.physicsBody setVelocity:CGVectorMake(-EdgarVelocity + contextVelocityX, Edgar.physicsBody.velocity.dy)];
        }];
        SKAction *wait = [SKAction waitForDuration:.05]; // = 20 fois par seconde vs 60
        
        EdgarVelocity = 140;
        
        bougeDroite = [SKAction sequence:@[mvm1, wait]];
        bougeGauche = [SKAction sequence:@[mvm2, wait]];
        
        bougeGauche2 = [SKAction repeatActionForever:bougeGauche];
        bougeDroite2 = [SKAction repeatActionForever:bougeDroite];
        

        // First call to loadLevel
        
        myLevel = [self loadLevel:0]; // levelIndex
        if(myLevel)
        {
            [myWorld addChild: myLevel];
            [self addStoneBlocks:myLevel];
            [self loadAssets:myLevel];
        }
        else
        {
            NSLog(@"Could not load level");
            return false;
        }
        
        // We create our character Edgar
        
        Edgar = [[plpHero alloc] initAtPosition: CGPointMake(startPosition.x, startPosition.y)];
        myCamera.position = startPosition;
        
        Edgar.physicsBody.categoryBitMask = PhysicsCategoryEdgar;
        Edgar.physicsBody.collisionBitMask = PhysicsCategoryObjects|PhysicsCategoryTiles;
        Edgar.physicsBody.contactTestBitMask = PhysicsCategoryObjects|PhysicsCategoryTiles|PhysicsCategoryAliens|PhysicsCategorySensors|PhysicsCategoryItems;
        
        Edgar->rectangleNode.physicsBody.categoryBitMask = PhysicsCategoryEdgar;
        Edgar->rectangleNode.physicsBody.collisionBitMask = PhysicsCategoryObjects|PhysicsCategoryTiles;
        Edgar->rectangleNode.physicsBody.contactTestBitMask = PhysicsCategoryObjects|PhysicsCategoryTiles|PhysicsCategoryAliens|PhysicsCategorySensors|PhysicsCategoryItems;
        
        listensToContactEvents = TRUE;
        
        [myLevel addChild: Edgar];
        
        SKPhysicsJointFixed *pinEdgar = [SKPhysicsJointFixed jointWithBodyA:Edgar.physicsBody bodyB:Edgar->rectangleNode.physicsBody anchor:CGPointMake(Edgar.position.x, Edgar.position.y)];
        [self.physicsWorld addJoint:pinEdgar];
        
        [self playTune:@"Sounds/Juno" loops:-1];
        
        [self saveInitialTime];
        additionalSavedTime = 0;
    }
    return self;
}

- (void)playAgain{
    // We clean the UI
    SKNode *theTrophy = [myCamera childNodeWithName:@"trophy"];
    [theTrophy removeFromParent];
    [myCamera setScale:1];
    
    [self doVolumeFade];
    
    // Curtains
    float halfHeight = 200;
    
    SKSpriteNode *curtain1 = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(800, 250) ];
    SKSpriteNode *curtain2 = [curtain1 copy];
    curtain1.anchorPoint = CGPointMake(0.5, 0);
    curtain1.position = CGPointMake(0, halfHeight);
    curtain1.zPosition = 20;
    curtain1.name = @"curtain1";
    
    curtain2.anchorPoint = CGPointMake(0.5, 1);
    curtain2.position = CGPointMake(0, -halfHeight);
    curtain2.zPosition = 20;
    curtain2.name = @"curtain2";
    [myCamera addChild:curtain1];
    [myCamera addChild:curtain2];
    
    //  We need to make a new Edgar (removed for the final animation)
    Edgar = nil;
    Edgar = [[plpHero alloc] initAtPosition: CGPointMake(startPosition.x, startPosition.y)];
    Edgar.physicsBody.categoryBitMask = PhysicsCategoryEdgar;
    Edgar.physicsBody.collisionBitMask = PhysicsCategoryObjects|PhysicsCategoryTiles;
    Edgar.physicsBody.contactTestBitMask = PhysicsCategoryObjects|PhysicsCategoryTiles|PhysicsCategoryAliens|PhysicsCategorySensors|PhysicsCategoryItems;
    
    Edgar->rectangleNode.physicsBody.categoryBitMask = PhysicsCategoryEdgar;
    Edgar->rectangleNode.physicsBody.collisionBitMask = PhysicsCategoryObjects|PhysicsCategoryTiles;
    Edgar->rectangleNode.physicsBody.contactTestBitMask = PhysicsCategoryObjects|PhysicsCategoryTiles|PhysicsCategoryAliens|PhysicsCategorySensors|PhysicsCategoryItems;
    
    // Let's go! (tutorial = level 0, first level = 1)
    [self resetGameData];
    [self resumeFromLevel:1];
    [self runAction:[SKAction waitForDuration:2] completion:^{
        [self playTune:@"Sounds/Juno" loops:-1];
    }];
}

- (IBAction)playAgainButtonClicked:(id)sender {
    // We remove all subviews (text field and buttons), then the container
    [[containerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [containerView removeFromSuperview];
    [self playAgain];
}

- (IBAction)endGameNoSaveScore:(id)sender {
    [[containerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self showTrophy];
}

- (IBAction)endGameWithScore:(id)sender {
    
    // We remove all subviews (text field and buttons)
    [[containerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // custom size because the keyboard takes up half the screen
    [containerView setFrame:CGRectMake(50, 5, self.view.bounds.size.width-100, self.view.bounds.size.height/2-10)];
    
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

- (BOOL)textFieldShouldReturn:(UITextField *)theTextfield {
    [theTextfield resignFirstResponder];
    return YES;
}

- (void)showTrophy {
    NSString *rankingString = @"Snail Edgar.";
    SKTexture *trophyTexture = [SKTexture textureWithImageNamed:@"UI_img/Trophy1-03.png"];
    
    float totalTime = [self getTotalTime];
    if(totalTime < 600) // 10 minutes
    {
        rankingString = @"King Edgar. Congrats, boss.";
        trophyTexture = [SKTexture textureWithImageNamed:@"UI_img/Trophy3-03.png"];
    }else if(totalTime < 1200) // 20 minutes
    {
        rankingString = @"Knight Edgar. Very good.";
        trophyTexture = [SKTexture textureWithImageNamed:@"UI_img/Trophy2-03.png"];
    }else{
        rankingString = @"Snail Edgar.";
    }
    
    
    SKSpriteNode *trophy = [SKSpriteNode spriteNodeWithTexture:trophyTexture];
    trophy.name = @"trophy";
    
    [containerView setFrame:CGRectMake(50, 5, self.view.bounds.size.width-100, self.view.bounds.size.height/3)]; // upper half of the screen

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
    
    [containerView addSubview:myTextView];
    [containerView addSubview:myButtonClose];
    [trophy setScale: 0.5];
    // Position: bottom left
    [trophy setPosition: CGPointMake(10 - trophy.size.width/2, 40 - trophy.size.height/2)];
    [trophy setZPosition: 100];
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
    if(levelIndex <= 1)
    {
        // We reset the intial, the saved time and the cheat code activation
/*        [self saveInitialTime];
        additionalSavedTime = 0;
        
        cheatsEnabled = FALSE;*/

        initialLevelTime = CFAbsoluteTimeGetCurrent();
        freeCamera = FALSE;
    }else{
        // We save the initial level time
        initialLevelTime = CFAbsoluteTimeGetCurrent();
    }
    
    JSTileMap *myTileMap;
    NSArray *levelFiles = [NSArray arrayWithObjects:
                           @"Levels/Level_1_tuto.tmx",
                           @"Levels/Level_2.tmx",
                           @"Levels/Level_3.tmx",
                           @"Levels/Level_4.tmx",
                           @"Levels/Level_5.tmx",
                           @"Levels/Level_6.tmx",
                           @"Levels/Level_7.tmx",
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

-(void)addStoneBlocks: (JSTileMap*) tileMap
{
    TMXLayer* monLayer = [tileMap layerNamed:@"Solide"];
    
    for (int a = 0; a < tileMap.mapSize.width; a++)
    {
        for (int b = 0; b < tileMap.mapSize.height; b++)
        {
            CGPoint pt = CGPointMake(a, b);
            
            NSInteger gid = [monLayer tileGidAt:[monLayer pointForCoord:pt]];
            
            if (gid != 0)
            {
                SKSpriteNode* node = [monLayer tileAtCoord:pt];
                [node setSize:CGSizeMake(101.0f, 101.0f)];
                node.physicsBody = [SKPhysicsBody bodyWithTexture:node.texture size:node.frame.size];
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
    }
}

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
    
    if(nextLevelIndex>0) // Fin du niveau 1: on efface l'éventuel reste de flèche d'aide
    {
        SKNode *theNode;
        if(( theNode = [myCamera childNodeWithName:@"helpNode"]))
        {
            [theNode removeFromParent];
        }
    }
    
    if(nextLevelIndex>1)
    {
        SKSpriteNode *startLift = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"Level_objects_img/ascenseur-start.png"] size: CGSizeMake(88, 106)];
        startLift.position = startPosition;
        [tileMap addChild: startLift];
    }
    
    // Sensor (detects when the player reaches the center of the lift and triggers events like the alien vessel)
    // Senseur (utilisés pour déclencher la fin du  niveau et des événements comme la venue du vaisseau spatial)
    NSArray *sensorObjectMarker;
    if((sensorObjectMarker = [group objectsNamed:@"sensor"]))
    {
        SKSpriteNode *sensorNode;
        int sensorId;
        
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
    SKTexture *textureCaisse = [SKTexture textureWithImageNamed:@"Level_objects_img/box-08.png"];
    NSArray *placeCaisse = [group objectsNamed:@"Caisse"];
    for (NSDictionary *optionCaisse in placeCaisse) {
        CGFloat width = [optionCaisse[@"width"] floatValue];
        CGFloat height = [optionCaisse[@"height"] floatValue];
        
        SKSpriteNode *caisse = [SKSpriteNode spriteNodeWithTexture:textureCaisse size: CGSizeMake(width, height)];
        caisse.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(width, height)];
        caisse.physicsBody.mass = 20; // auparavant: 40
        caisse.physicsBody.friction = 0.1;
        caisse.position = [self convertPosition:optionCaisse];
        caisse.physicsBody.categoryBitMask = PhysicsCategoryObjects;
        caisse.physicsBody.collisionBitMask = PhysicsCategoryEdgar|PhysicsCategoryObjects|PhysicsCategoryTiles;
        [tileMap addChild: caisse];
    }
    
    if(nextLevelIndex == 1)
    {
        NSArray *treeArray;
        if((treeArray=[group objectsNamed:@"arbre"]))
        {
            for (NSDictionary *monTree in treeArray) {
                plpItem *myItem;
                myItem = [[plpItem alloc] initAtPosition:[self convertPosition:monTree] withTexture:@"Level_objects_img/arbre-09.png"];
                
                //                float waitBeforeStart = [montree[@"waitBeforeStart"] floatValue];
                if(myItem)
                {
                    //                    myItem.physicsBody.categoryBitMask = PhysicsCategoryItems;
                    myItem.physicsBody = [SKPhysicsBody bodyWithTexture: myItem.texture alphaThreshold: 0.5 size: CGSizeMake(253, 285)];
                    myItem.physicsBody.categoryBitMask = PhysicsCategoryTiles;
                    myItem.physicsBody.dynamic = NO;
                    [tileMap addChild:myItem];
                }
                else
                {
                    NSLog(@"Error while creating the tree.");
                }
            }
        }
    }
    else if(nextLevelIndex == 4)
    {
        // semaphore
        
        NSArray *semaphoreArray;
        if((semaphoreArray=[group objectsNamed:@"semaphore"]))
        {
            for (NSDictionary *monSemaphore in semaphoreArray) {
                plpItem *myItem;
                myItem = [[plpItem alloc] initAtPosition:[self convertPosition:monSemaphore] withTexture:@"Level_objects_img/FeuVert.png"];
                //                float waitBeforeStart = [monSemaphore[@"waitBeforeStart"] floatValue];
                if(myItem)
                {
                    //                    myItem.physicsBody.categoryBitMask = PhysicsCategoryItems;
                    [tileMap addChild:myItem];
                    // action
                    
                    SKTexture *semaphoreGreen = [SKTexture textureWithImageNamed:@"Level_objects_img/FeuVert.png"];
                    SKTexture *semaphoreRed = [SKTexture textureWithImageNamed:@"Level_objects_img/FeuRouge.png"];
                    SKAction *setGreen = [SKAction setTexture:semaphoreGreen];
                    SKAction *setRed = [SKAction setTexture:semaphoreRed];
                    SKAction *wait = [SKAction waitForDuration:2];
                    SKAction *changeTexture = [SKAction sequence:@[setGreen, wait, setRed, wait]];
                    
                    [myItem runAction:[SKAction repeatActionForever:changeTexture]];
                }
                else
                {
                    NSLog(@"Error while creating the semaphore.");
                }
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
        
        SKTexture *textureCaisse = [SKTexture textureWithImageNamed:@"Level_objects_img/ascenseurF-01.png"];
        endLevelLiftNode = [SKSpriteNode spriteNodeWithTexture:textureCaisse size: CGSizeMake(width, height)];
        
        endLevelLiftNode.name = @"Level_objects_img/endLevelLiftNode";
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
            myItem = [[plpItem alloc] initAtPosition:[self convertPosition:monItem] withTexture:@"Level_objects_img/pile.png"];
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
    
    NSArray *tabBonus;
    if((tabBonus=[group objectsNamed:@"timeBonus"]))
    {
        for (NSDictionary *monBonus in tabBonus) {
            plpItem *myBonus;
            myBonus = [[plpItem alloc] initAtPosition:[self convertPosition:monBonus] withTexture:@""];
            if(myBonus)
            {
                myBonus.name = @"timeBonus";
                myBonus.physicsBody.categoryBitMask = PhysicsCategoryItems;
                [myBonus setSeconds: [monBonus[@"seconds"] intValue]];
                [tileMap addChild:myBonus];
            }
            else
            {
                NSLog(@"Error while creating a bonus.");
            }
        }
    }

    
    // Train
    NSArray *trainObjectMarker;
    if((trainObjectMarker = [group objectsNamed:@"train"]))
    {
        plpTrain *trainNode;
        
        for (NSDictionary *theTrain in trainObjectMarker) {
            trainNode = [[plpTrain alloc] initAtPosition: [self convertPosition:theTrain] withMainTexture:@"Level_objects_img/ChariotSocle.png" andWheelTexture:@"Level_objects_img/RoueChariot-03.png"];
            
            if(trainNode)
            {
                trainNode.physicsBody.categoryBitMask = PhysicsCategoryObjects;
                trainNode.physicsBody.collisionBitMask = PhysicsCategoryTiles|PhysicsCategoryObjects|PhysicsCategoryEdgar|PhysicsCategoryAliens;
                //                trainNode.shadowCastBitMask = 1;
                [tileMap addChild:trainNode]; // vs myLevel
                [trainNode getLeftWheel].physicsBody.collisionBitMask = PhysicsCategoryTiles|PhysicsCategoryObjects|PhysicsCategoryEdgar|PhysicsCategoryAliens;
                [trainNode getRightWheel].physicsBody.collisionBitMask = PhysicsCategoryTiles|PhysicsCategoryObjects|PhysicsCategoryEdgar|PhysicsCategoryAliens;
                
                SKPhysicsJointPin *pinGauche = [SKPhysicsJointPin jointWithBodyA:[trainNode getLeftWheel].physicsBody bodyB:trainNode.physicsBody anchor:CGPointMake(trainNode.position.x-20, trainNode.position.y-19)];
                [self.physicsWorld addJoint:pinGauche];
                
                SKPhysicsJointPin *pinDroit = [SKPhysicsJointPin jointWithBodyA:[trainNode getRightWheel].physicsBody bodyB:trainNode.physicsBody anchor:CGPointMake(trainNode.position.x+20, trainNode.position.y-19)];
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
                verticalPlatformNode = [[plpPlatform alloc] initAtPosition: CGPointMake([theVerticalPlatform[@"x"] floatValue], [theVerticalPlatform[@"y"] floatValue] + [theVerticalPlatform[@"height"] floatValue]-8)
                                                                  withSize:CGSizeMake([theVerticalPlatform[@"width"] floatValue], 8)
                                                              withDuration:[theVerticalPlatform[@"movementDuration"] floatValue] upToX:[theVerticalPlatform[@"x"] floatValue] andY:[theVerticalPlatform[@"y"] floatValue] andIdleDuration:idleDuration];
            }else{
                verticalPlatformNode = [[plpPlatform alloc] initAtPosition: CGPointMake([theVerticalPlatform[@"x"] floatValue], [theVerticalPlatform[@"y"] floatValue])
                                                                  withSize:CGSizeMake([theVerticalPlatform[@"width"] floatValue], 8)
                                                              withDuration:[theVerticalPlatform[@"movementDuration"] floatValue] upToX:[theVerticalPlatform[@"x"] floatValue] andY:[theVerticalPlatform[@"y"] floatValue] + [theVerticalPlatform[@"height"] floatValue] -8 andIdleDuration:idleDuration];
            }
            
            if(verticalPlatformNode)
            {
                verticalPlatformNode.physicsBody.categoryBitMask = PhysicsCategoryObjects;
                [tileMap addChild:verticalPlatformNode];
                
                if([theVerticalPlatform[@"noEmergencyStop"] intValue] == 1)
                {
                    [verticalPlatformNode setNoEmergencyStop];
                }
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
                [tileMap addChild:platformNode];
            }
        }
    }
    
    // Aliens / Extra-terrestres
    NSArray *tabAlien;
    if((tabAlien=[group objectsNamed:@"alien1"]))
    {
        for (NSDictionary *monAlien in tabAlien) {
            plpEnemy *alien;
            alien = [[plpEnemy alloc] initAtPosition:[self convertPosition:monAlien] withSize:CGSizeMake([monAlien[@"width"] floatValue], [monAlien[@"height"] floatValue]) withMovement:[monAlien[@"moveX"] floatValue]];
            if(alien)
            {
                alien.physicsBody.categoryBitMask = PhysicsCategoryAliens;
                alien.physicsBody.collisionBitMask = PhysicsCategoryObjects | PhysicsCategoryTiles;
                
                [tileMap addChild:alien];
            }
            else
            {
                NSLog(@"Error while creating the alien.");
            }
        }
    }
}

// TIME TRACKER

-(void)saveInitialTime
{
    initialTime = CFAbsoluteTimeGetCurrent();
}
-(void)saveAdditionalTime:(float)additionalTime{
    additionalSavedTime += additionalTime;
}
-(void)saveAdditionalTime
{
    additionalSavedTime += CFAbsoluteTimeGetCurrent() - initialTime;
}
-(float)getTotalTime
{
    return (CFAbsoluteTimeGetCurrent() - initialTime) + additionalSavedTime;
}

-(float)getLevelTime
{
    return CFAbsoluteTimeGetCurrent() - initialLevelTime;
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

// MUSIC
-(void)startPlaying
{
    if(self.audioPlayer)
        [self.audioPlayer play];
}

-(void)playTune:(NSString*)filename loops:(int)loops
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:filename withExtension:@"mp3"];
    NSError *error = nil;
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    self.audioPlayer.numberOfLoops = loops;
    if (!self.audioPlayer) {
        NSLog(@"Error creating player: %@", error);
    }
    [NSThread detachNewThreadSelector:@selector(startPlaying) toTarget:self withObject:nil];
}


// PAUSE & RESUME ACTIONS, LEVELS, GAME OVER
- (void)getsPaused
{
    [Edgar removeControl];
    [self doVolumeFade];
    [self saveAdditionalTime]; // We save the elapsed time. When the player resumes, we set a new initial time.
}

-(void)resumeAfterPause
{
    [self saveInitialTime];
    [Edgar giveControl];
    if(self.audioPlayer != nil)
    {
        [self.audioPlayer play];
    }
}

-(void)resumeFromLevel:(NSInteger)theLevel{
    levelTransitioning = TRUE;
    nextLevelIndex = (int)theLevel;
    
    // if level == 0: new game => reset game data (cheat enabled, time...)
    if(nextLevelIndex == 0)
    {
        NSLog(@"Level == 0 => remove light and masque");
        [self resetGameData];
        [Edgar removeLight];
        [Edgar removeMasque];
    }
    
    [myFinishRectangle removeFromParent];
    myFinishRectangle = nil;
    [self startLevel];
}

- (int) getNextLevelIndex
{
    return nextLevelIndex;
}

- (void) resetGameData
{
    cheatsEnabled = FALSE;
    [self saveInitialTime];
    additionalSavedTime = 0;
}

// Called when the user restarts a level (upper right button)
- (void)EdgarDiesOf:(int)deathType
{
    //  Deaths and death count disabled in current version / Décompte des morts désactivé dans la version actuelle
    
    if(!levelTransitioning) // Check if restart level is currently disabled
    {
        [Edgar removeControl];
        levelTransitioning = TRUE;
        [myFinishRectangle removeFromParent];
        myFinishRectangle = nil;
        [self doLevelTransition_sameLevel:YES];
        [Edgar giveControl];
    }
    else
    {
        NSLog(@"Restart level disabled at this time");
    }
}

- (void)resetEdgar
{
    stopRequested = TRUE;
    [Edgar removeAllActions];
    [Edgar.physicsBody setVelocity:CGVectorMake(0, 0)];
    [Edgar setPosition:startPosition];
    
    // To tidy this, it would be better to add a single "reset" method to the plpHero class. Next step...
    
    [Edgar setScale:1];
    [Edgar resetItem];
    [Edgar resetInfected];
    [Edgar giveControl]; // ddd voir si ne fait pas doublon
    [Edgar setSpeed: 1.0];
    isJumping = FALSE;
    gonnaCrash = FALSE;
    moveLeft = FALSE;
    moveRight = FALSE;
    moveUpRequested = FALSE;
    bigJumpRequested = FALSE;
    moveLeftRequested = FALSE;
    moveRightRequested = FALSE;
    listensToContactEvents = TRUE;
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
        // We move the camera when Edgar is close from the edge / On bouge la vue quand Edgar approche du bord du cadre:
        CGFloat xDistance = Edgar.position.x - myCamera.position.x; // gets > 0 if Edgar moves right
        CGFloat yDistance = Edgar.position.y - myCamera.position.y;
        CGPoint newCameraPosition = myCamera.position;
        
        if(xDistance < -100) // a gauche
        {
            newCameraPosition.x = Edgar.position.x + 100;
            [myCamera setPosition:CGPointMake(newCameraPosition.x, myCamera.position.y)];
        }
        else if(xDistance > 100) // a droite
        {
            newCameraPosition.x = Edgar.position.x - 100;
            [myCamera setPosition:CGPointMake(newCameraPosition.x, myCamera.position.y)];
        }
        if(yDistance < -100)
        {
            newCameraPosition.y = Edgar.position.y + 100;
            [myCamera setPosition:CGPointMake(myCamera.position.x, newCameraPosition.y)];
        }
        else if(yDistance > 100)
        {
            newCameraPosition.y = Edgar.position.y - 100;
            [myCamera setPosition:CGPointMake(myCamera.position.x, newCameraPosition.y)];
        }
        myCamera.position = CGPointMake(roundf(newCameraPosition.x), roundf(newCameraPosition.y));
    }
    /* Detect if Edgar will crash -- currently disabled
    if(![Edgar.physicsBody isResting]){
        if(Edgar.physicsBody.velocity.dy < -1400){
            gonnaCrash = TRUE;
        }
    }*/
}


- (void)doVolumeFade
{
    if (self.audioPlayer.volume > 0.1) {
        self.audioPlayer.volume = self.audioPlayer.volume - 0.1;
        [self performSelector:@selector(doVolumeFade) withObject:nil afterDelay:0.1];
    } else {
        // Stop and get the sound ready for playing again
        [self.audioPlayer stop];
        self.audioPlayer.currentTime = 0;
        [self.audioPlayer prepareToPlay];
        self.audioPlayer.volume = 1.0;
    }
}

// Called when the user chooses "Save online">"YES" at the end game.
- (void) saveHighScoreForUser:(NSString*)userName
{
    float totalTime = [self getTotalTime];
    NSString *urlStr = [[NSString alloc]
                        initWithFormat:@"http://paulronga.ch/edgar/score.php?user=%@&score=%.2f", userName, totalTime];
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

-(void)doLevelTransition_sameLevel:(BOOL)repeatingLevel{
    float halfHeight = 200;
    
    // A. Prepare the time display
    
    /*
        Most examples about SKLabelNode are terribly inneficient. See this blog post: https://gilesey.wordpress.com/2015/01/14/ios-spritekit-font-loading-times-of-sklabelnodes/
        If you only write "Gill sans", it'll take ~4 seconds to load.
    */
    
    SKLabelNode *displayTime = [SKLabelNode labelNodeWithFontNamed:@"GillSans"];
    displayTime.fontSize = 30;
    displayTime.fontColor = [SKColor whiteColor];
    displayTime.position = CGPointMake(screenCenterX, 10);
    displayTime.zPosition = 30;
    
    SKLabelNode *displayTime2 = [SKLabelNode labelNodeWithFontNamed:@"GillSans"];
    displayTime2.fontSize = 24;
    displayTime2.fontColor = [SKColor whiteColor];
    displayTime2.position = CGPointMake(screenCenterX, -30);
    displayTime2.zPosition = 30;
    
    if(repeatingLevel == YES)
    {
        if(nextLevelIndex == 0)
        {
            displayTime.text = [[NSString alloc] initWithFormat:@"Welcome back to the tutorial"];
        }else{
            displayTime.text = [[NSString alloc] initWithFormat:@"Welcome back to level %d", nextLevelIndex];
        }
        displayTime2.text = [[NSString alloc] initWithFormat:@"Your total time: %@", [self getTimeString: [self getTotalTime]]];
    }
    else
    {
        if(nextLevelIndex > 1)
        {
            displayTime.text = [[NSString alloc]
                                initWithFormat:@"Total time: %@", [self getTimeString: [self getTotalTime]]];
            
            displayTime2.text = [[NSString alloc]
                                 initWithFormat:@"This level: %@", [self getTimeString: [self getLevelTime]]];
        }
        else
        {
            displayTime.text = [[NSString alloc]
                                initWithFormat:@"You made this tutorial in %@", [self getTimeString:[self getLevelTime]]];
            
            displayTime2.text = [[NSString alloc]
                                 initWithFormat:@"Get ready for the game!"];
        }
    }
    
    // B. Save to additionalTime; we call saveInitialTime when the curtains open again
    [self saveAdditionalTime];

    
    
    SKSpriteNode *curtain1 = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(800, 250) ];
    SKSpriteNode *curtain2 = [curtain1 copy];
    curtain1.anchorPoint = CGPointMake(0.5, 0);
    curtain1.position = CGPointMake(0, halfHeight);
    curtain1.zPosition = 20;
    curtain1.name = @"curtain1";
    
    curtain2.anchorPoint = CGPointMake(0.5, 1);
    curtain2.position = CGPointMake(0, -halfHeight);
    curtain2.zPosition = 20;
    curtain2.name = @"curtain2";
    [myCamera addChild:curtain1];
    [myCamera addChild:curtain2];
    
    
    // The three actions of the level transition are written in reverse order here:

    // 3. Third action: open curtains

    SKAction *openCurtain1 = [SKAction moveToY:halfHeight duration: .5];
    SKAction *openCurtain2 = [SKAction moveToY:-halfHeight duration: .5];
    SKAction *openCurtains = [SKAction runBlock:^{
        [curtain1 runAction: openCurtain1];
        [curtain2 runAction: openCurtain2 completion:^{
            [self saveInitialTime];
            //   levelTransitioning = FALSE; -> too late, may cause unexpected behaviours
        }];
    }];

    // 2. Second action: present score and start level (completion = action 3: open curtains)
    SKAction *presentScore = [SKAction runBlock:^{
        [myCamera addChild:displayTime];
        [myCamera addChild:displayTime2];
        
        SKAction *timeVanish = [SKAction sequence: @[[SKAction fadeAlphaTo:1 duration:.7], [SKAction waitForDuration:.6],[SKAction fadeAlphaTo:0 duration:.7], [SKAction removeFromParent]]];
        [displayTime runAction:timeVanish];
        [displayTime2 runAction:timeVanish completion:^{
            [myWorld runAction: openCurtains];
        }];
        [self startLevel];
        // [NSThread detachNewThreadSelector:@selector(startLevel) toTarget:self withObject:nil];
    }];

    // 1. First action: close curtains (completion = action 2: present score)
    [curtain1 runAction: [SKAction moveToY:-20 duration: .5]];
    [curtain2 runAction: [SKAction moveToY:20 duration: .5] completion:^
    {
        [myWorld runAction:presentScore];
    }];
    
}

-(void)startLevel{
    for (SKNode* theNode in [myLevel children]) {
        [theNode removeFromParent];
    }

    [myLevel removeFromParent]; // signal SIGABRT
    [Edgar removeFromParent];
    [self resetEdgar];
    
    if([myCamera hasActions]) // on annule effets de zoom, etc.
    {
        [myCamera removeAllActions];
    }
    
    if((nextLevelIndex == LAST_LEVEL_INDEX) && (self.audioPlayer != nil))
    {
        [Edgar removeLight];
        [Edgar removeMasque];
        [self doVolumeFade];
    }
    
    myLevel = [self loadLevel:nextLevelIndex];
    
    myWorld.position = CGPointMake(0, 0);
    [myWorld addChild: myLevel];
    
    [self addStoneBlocks:myLevel];
    [self loadAssets:myLevel];
    Edgar.position = startPosition;
    myCamera.position = startPosition;
    
    [myLevel addChild: Edgar];
    
    SKPhysicsJointFixed *pinEdgar = [SKPhysicsJointFixed jointWithBodyA:Edgar.physicsBody bodyB:Edgar->rectangleNode.physicsBody anchor:CGPointMake(Edgar.position.x, Edgar.position.y)];
    [self.physicsWorld addJoint:pinEdgar];
    
    [Edgar giveControl];
    
    if(nextLevelIndex > 0) // we store the last accomplished level
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:nextLevelIndex forKey:@"savedLevel"];
        [defaults setFloat:[self getTotalTime] forKey:@"totalTime"];
        [defaults synchronize];
        NSLog(@"Level saved: %d", nextLevelIndex);
    }
    
    if(nextLevelIndex > 1 && nextLevelIndex < LAST_LEVEL_INDEX)
    {
        [Edgar addLight]; // shadow effect for levels 2-6
        
        if(nextLevelIndex == 5)
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
            SKAction *greenDoor = [SKAction setTexture:[SKTexture textureWithImageNamed:@"Level_objects_img/ascenseurO-01.png"]];
            [contactNode runAction:greenDoor];
        }
        
        if([contactNode.name isEqualToString:@"finish"])
        {
            if(!levelTransitioning)
            {
                if([Edgar hasItem])
                {
                    /* SND: success - else: error sound */
                    levelTransitioning = TRUE;
                    [Edgar removeControl];
                    [Edgar runAction: [SKAction sequence:@[[SKAction moveToX:myFinishRectangle.position.x duration: .2], [SKAction runBlock:^{
                        stopRequested = TRUE;
                    }]]]];

                    [myFinishRectangle removeFromParent];
                    myFinishRectangle = nil;
                    nextLevelIndex++;
                    
                    NSLog(@"Loading level %d", nextLevelIndex);
                    
                    [self doLevelTransition_sameLevel:NO];
                } // end if [Edgar hasItem]
            } // end if !levelTransitioning
        } // end if finish

        if(nextLevelIndex==LAST_LEVEL_INDEX)
        {
            if([contactNode.name isEqualToString:@"finalAnimationSensor"] && contactNode != nil)
            {
                NSLog(@"Final animation 1 triggered");
                
                [contactNode removeFromParent];
                [Edgar removeControl];
                if(!moveRight)
                {
                    moveRightRequested = TRUE;
                }
                
                
                SKAction *audioPlayAction = [SKAction runBlock:^{
                    [self playTune:@"Sounds/EndGame" loops:1];
                }];
                
                SKAction *theScale = [SKAction scaleTo:1.5 duration:2];
                [myCamera runAction: theScale];
                
                // First animation
                SKNode *alienVessel;
                alienVessel = [SKSpriteNode spriteNodeWithImageNamed:@"Level_objects_img/UFO1-02.png"];
                alienVessel.name = @"alienVessel";
                
                SKSpriteNode *beam = [SKSpriteNode spriteNodeWithImageNamed:@"Level_objects_img/rayonb.png"];
                beam.alpha = 0;
                beam.name = @"beam";
                
                CGPoint referencePoint = [myLevel childNodeWithName:@"referencePoint"].position;
                CGPoint referencePointAlien = CGPointMake(referencePoint.x, referencePoint.y-90); // ddd precedemment: -100
                
                SKAction *waitAction = [SKAction waitForDuration: 1];
                
                SKAction *createAlien = [SKAction runBlock:^{
                    alienVessel.position = CGPointMake(Edgar.position.x, Edgar.position.y+400);
                    [myLevel addChild: alienVessel];
                    
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
                    
                    SKSpriteNode *beam = (SKSpriteNode*)[myLevel childNodeWithName:@"//beam"];
                    
                    //                SKAction *waitAction = [SKAction waitForDuration: 1];
                    SKAction *longWaitAction = [SKAction waitForDuration: 2];
                    
                    
                    SKAction *createBeam = [SKAction runBlock:^{
                        [beam setAlpha: 1.0f];
                        [Edgar removeActionForKey:@"bougeDroite"];
                        [Edgar removeActionForKey:@"walkingInPlaceEdgar"];
                        [Edgar.physicsBody setVelocity: CGVectorMake(0, 0)];
                        Edgar.physicsBody.affectedByGravity = false;
                        Edgar->rectangleNode.physicsBody.affectedByGravity = false;
                        freeCamera = TRUE;
                        [myCamera runAction:[SKAction moveToY:Edgar.position.y+200 duration:1]];
                        nextLevelIndex = 1;
                    }];
                    
                    SKAction *flyAway = [SKAction runAction:[SKAction moveTo:CGPointMake(2000, 2000) duration:4] onChildWithName:@"//alienVessel"];
                    [flyAway setTimingMode: SKActionTimingEaseIn];
                    
                    SKAction *moveEdgar = [SKAction runAction:[SKAction moveTo:referencePoint duration:2] onChildWithName:@"//Edgar"];
                    moveEdgar.timingMode = SKActionTimingEaseInEaseOut;
                    
                    
                    SKAction *vanish = [SKAction runAction:[SKAction fadeAlphaTo:0 duration:0] onChildWithName:@"//Edgar"];
                    SKAction *removeBeam = [SKAction runBlock:^{
                        [beam removeFromParent];
                    }];
                    
                    SKAction *finalMessage = [SKAction runBlock:^{
                        containerView = [[UIView alloc] init];
                        [containerView setFrame: CGRectMake(50, 50, self.view.bounds.size.width-100, self.view.bounds.size.height-100)]; // coordinates origin is upper left
                        
                        containerView.backgroundColor = [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1];
                        
                        myTextView = [[UITextView alloc] init];
                        NSString* userTimeString = [self getTimeString: [self getTotalTime]];
                        
                        NSLog(@"Preparing textview");
                        myTextView.text = [NSString stringWithFormat:@"You did it! \nYour time: %@.\nHowever, the alien vessel wasn’t part of the plan… \nStay tuned for the next part.\n\nSave your score online?", userTimeString];
                        
                        myTextView.textColor = [UIColor whiteColor];
                        myTextView.backgroundColor = [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1];
                        myTextView.editable = NO;
                        [myTextView setFont:[UIFont fontWithName:@"GillSans" size:18]];
                        
                        float outsideMargin = 60;
                        float insideMargin = 30;
                        float buttonsVerticalPosition = containerView.bounds.size.height-50;
                        float buttonWidth = (containerView.bounds.size.width/2) - (outsideMargin + insideMargin);
                        float buttonYesPositionX = outsideMargin;
                        float buttonNoPositionX = buttonWidth + outsideMargin + 2*insideMargin;
                        
                        [myTextView setFrame: CGRectMake(20, 5, containerView.bounds.size.width-40, containerView.bounds.size.height-70)];
                        
                        
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
                        
                        [self.view addSubview: containerView];
                        [containerView addSubview:myTextView];
                        [containerView addSubview:myButtonYes];
                        [containerView addSubview:myButtonNo];
                    }];
                    
                    [myLevel runAction:[SKAction sequence:@[createBeam, showBeam, moveEdgar, longWaitAction, vanish, removeBeam, longWaitAction, flyAway, longWaitAction, finalMessage]]];
                }
            } // end if LAST_LEVEL_INDEX
        }else if(nextLevelIndex==0) // Tutorial level
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
                helpNode = [SKSpriteNode spriteNodeWithImageNamed:@"UI_img/swipeRight.png"];
            }else if([contactNode.name isEqualToString:@"jump"])
            {
                helpNode = [SKSpriteNode spriteNodeWithImageNamed:@"UI_img/swipeJump.png"];
            }else if([contactNode.name isEqualToString:@"goUpstairs"])
            {
                helpNode = [SKSpriteNode spriteNodeWithImageNamed:@"UI_img/swipeJump.png"];
            }else if([contactNode.name isEqualToString:@"showUranium"])
            {
                helpNode = [SKSpriteNode spriteNodeWithImageNamed:@"UI_img/showUranium.png"];
                [helpNode setPosition:[myLevel childNodeWithName:@"uranium"].position];
                [helpNode setSize:CGSizeMake(100, 100)];
                [helpNode runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction fadeAlphaTo:1 duration:.5], [SKAction fadeAlphaTo:0 duration:.5]]]]];
            }else if([contactNode.name isEqualToString:@"moveToExit"])
            {
                helpNode = [SKSpriteNode spriteNodeWithImageNamed:@"UI_img/goLeft.png"];
            }
            
            if(helpNode)
            {
                helpNode.name = @"helpNode";
                if(!helpNode.position.x)
                {
                    [helpNode setPosition:CGPointMake(110.0f, -20.0f)];
                    [myCamera addChild: helpNode];
                }else{
                    [myLevel addChild: helpNode];
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
            [myLevel childNodeWithName:@"uranium"].hidden = YES;  // <- to simply hide the object
            //            [(plpItem *)contactNode removeFromParent]; // <- if there is a need to remove the item
            if(nextLevelIndex==0)
            {
                SKNode* helpNode;
                if((helpNode = [myLevel childNodeWithName:@"//helpNode"]))
                {
                    [helpNode removeFromParent];
                }
            }
        }else if([contactNode.name isEqualToString: @"timeBonus"])
        {
            SKSpriteNode *bonusDisplayNode = [SKSpriteNode spriteNodeWithImageNamed:@"UI_img/Time_bonus.png"];
            [bonusDisplayNode setSize:CGSizeMake(600, 111)];
            [bonusDisplayNode setPosition:CGPointMake(0, 0)];
            [bonusDisplayNode setZPosition: 30]; // devdev
            
            int theBonusSeconds = 30;
            [myCamera addChild: bonusDisplayNode];
            [bonusDisplayNode runAction:[SKAction sequence:@[[SKAction fadeAlphaTo: 1 duration: .5], [SKAction waitForDuration: 1], [SKAction fadeAlphaTo: 0 duration: 1.5], [SKAction removeFromParent]]]];
            
            
            /*
             
            // [No SKLabel for now]
             
            int theBonusSeconds = [(plpItem *)contactNode getSeconds];
            SKLabelNode *bonusLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
            bonusLabel.fontSize = 36;
            [bonusLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
            
            bonusLabel.fontColor = [SKColor colorWithRed:0 green:.8 blue:.5 alpha:1];
            bonusLabel.position = CGPointMake(screenCenterX, 0); // should be ~ 100 for an iPad air -> find a way to do it better
            bonusLabel.zPosition = 30;
            bonusLabel.text = [NSString stringWithFormat:@"Bonus! -%d seconds", theBonusSeconds];
            bonusLabel.alpha = 0;
            [myCamera addChild: bonusLabel];
            
            [bonusLabel runAction:[SKAction sequence:@[[SKAction fadeAlphaTo: 1 duration: .5], [SKAction waitForDuration: 5], [SKAction fadeAlphaTo: 0 duration: .5], [SKAction removeFromParent]]]];
            */
            
            
            initialTime -= theBonusSeconds;
            [(plpItem *)contactNode removeFromParent];
        }
    }
    
    
    if(contactNode.physicsBody.categoryBitMask == PhysicsCategoryObjects)
    {
        if([contactNode isKindOfClass:[plpTrain class]])
        {
            /* SND: train runs */
            plpTrain *theTrain = (plpTrain *)contactNode;
            [theTrain setHeroAbove];
            [(plpTrain *)contactNode accelerateAtRate:20 toMaxSpeed:200];
            return;
        }
        
        if([contactNode isKindOfClass:[plpPlatform class]])
        {
//            NSLog(@"Edgar : %f, plateforme: %f", Edgar.position.y - 42, contactNode.position.y);
            
            // Determine vertical position, check if the platform should stop
            if(Edgar.position.y - 42 > contactNode.position.y) /// dev: check the height again
            {
                /* SND: foot on platform */
                [(plpPlatform *)contactNode setHeroAbove];
            }
            else
            {
                if([(plpPlatform *)contactNode getIsVertical] == TRUE)
                {
                    if (Edgar.position.y < contactNode.position.y)
                    {
                        [(plpPlatform *)contactNode emergencyStop];
                    }
                }
                else // If horizontal, also check if a horizontal stop is needed
                {
                    [(plpPlatform *)contactNode horizontalEmergencyStop:Edgar.position.x];
                }
            }
        }
    }
    
    if(contactNode.physicsBody.categoryBitMask == PhysicsCategoryAliens)
    {
        if([contactNode isKindOfClass:[plpEnemy class]])
        {
            if(![Edgar alreadyInfected])
            {
                /* SND: Edgar gets infected */
                if(!bougeDroite && !bougeGauche) // essai pour éviter l'immobilisation
                {
                    moveRightRequested = TRUE;
                }
                [Edgar getsInfected];
            }
        }
    }
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
        if([contactNode isKindOfClass:[plpTrain class]])
        {
            /* SND: the train stops */
            [self removeActionForKey:@"trainSoundAction"];
//            NSLog(@"Leaves the train => deceleration");
            [(plpTrain *)contactNode decelerateAtRate:15];
            [(plpTrain *)contactNode HeroWentAway];
            willLoseContextVelocity = TRUE;
            return;
        }
        
        if([contactNode isKindOfClass:[plpPlatform class]])
        {
            [(plpPlatform *)contactNode HeroWentAway];
            willLoseContextVelocity = TRUE; // ou pour effet immédiat:  contextVelocityX = 0;
        }
    }
    
    if(nextLevelIndex==0) // Tutorial
    {
        if(contactNode.physicsBody.categoryBitMask == PhysicsCategorySensors)
        {
            if(![contactNode.name isEqualToString:@"finish"])
            {
                SKNode* helpNode;
                
                if((helpNode = (SKSpriteNode*)[myCamera childNodeWithName:@"//helpNode"]))
                {
                    [myLevel runAction: [SKAction fadeAlphaTo:1 duration:.5]];
                    
                    [helpNode removeFromParent];
                    helpNode = nil;
                    [contactNode removeFromParent]; // We remove the sensor / On enlève le senseur
                }
                else
                {
                    if((helpNode = (SKSpriteNode*)[myLevel childNodeWithName:@"//helpNode"]))
                    {
                        [helpNode removeFromParent];
                        helpNode = nil;
                        [contactNode removeFromParent]; // We remove the sensor / On enlève le senseur
                    }
                }
            }
        }
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // We get touches events before the update() function.
    // On detecte les mouvements et la position du personnage avant de transmettre à update().
    
    if([Edgar hasControl]==TRUE) // && spriteView.paused == NO => plutot: faire variable plus globale
    {
        for (UITouch *touch in touches) {
            touchStartPosition = [touch locationInNode:self];
            
            // Contrôles alternatifs pour le simulateur iOS | Alternate controls for the iOS simulator
            if(USE_ALTERNATE_CONTROLS==1)
            {
                if(!moveLeft && !moveRight)
                {
                    if(touchStartPosition.x > 400)
                    {
                        moveRightRequested = true;
                    } else if (touchStartPosition.x < 400){
                        moveLeftRequested = true;
                    }
                    ignoreNextTap = TRUE;
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
                    if(nextLevelIndex < LAST_LEVEL_INDEX && !levelTransitioning)
                    {
                        levelTransitioning = TRUE;
                        [myFinishRectangle removeFromParent];
                        myFinishRectangle = nil;
                        nextLevelIndex++;
                        self.view.showsPhysics = NO;
                        self.view.showsFPS = NO;
                        self.view.showsNodeCount = NO;
                        
                        NSLog(@"Loading level %d", nextLevelIndex);
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
                        nextLevelIndex = 6;
                        self.view.showsPhysics = NO;
                        self.view.showsFPS = NO;
                        
                        [self startLevel];
                    }
                }
            }
            
            if(!cheatsEnabled && touch.tapCount == 7)
            {
                cheatsEnabled = TRUE;
                SKLabelNode *cheatEnabledMessage = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
                cheatEnabledMessage.fontSize = 36;
                [cheatEnabledMessage setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
                
                cheatEnabledMessage.fontColor = [SKColor redColor];
                cheatEnabledMessage.position = CGPointMake(screenCenterX, 0); // should be ~ 100 for an iPad air -> find a way to do it better
                cheatEnabledMessage.zPosition = 30;
                cheatEnabledMessage.text = @"Cheater! Time penalty";
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
            CGPoint endPosition = [touch locationInNode:self];

            if(endPosition.y - 10 > touchStartPosition.y)
            {
                moveUpRequested = TRUE;
                if(endPosition.y - 130 > touchStartPosition.y)
                {
                    bigJumpRequested = TRUE;
                }
            }
            
            if(endPosition.x -30 > touchStartPosition.x)
            {
                moveRightRequested = TRUE;
            }
            else if(endPosition.x + 30 < touchStartPosition.x)
            {
                moveLeftRequested = TRUE;
            }else if (!moveUpRequested){
                stopRequested = TRUE;
            }
            

            // Contrôles alternatifs pour le simulateur iOS | Alternate controls for the iOS simulator
            if(USE_ALTERNATE_CONTROLS==1)
            {
                if((ignoreNextTap==FALSE) && (moveLeft || moveRight))
                {
                    if(endPosition.x > 400)
                    {
                        moveRightRequested = true;
                    } else if (endPosition.x < 400){
                        moveLeftRequested = true;
                    }
                }else{
                    ignoreNextTap = FALSE;
                }
            }
        }
    }
}

-(void)update:(CFTimeInterval)currentTime {
    
    if(stopRequested == TRUE && !isJumping){
        stopRequested = FALSE;
        moveLeft = FALSE;
        moveRight = FALSE;
        moveRightRequested = FALSE;
        moveLeftRequested = FALSE;
        Edgar.xScale = 1.0;
        [Edgar setSpeed:1.0];
        [Edgar.physicsBody setVelocity: CGVectorMake(0 + contextVelocityX, Edgar.physicsBody.velocity.dy)];
        /*        SKAction *doTheStop = [SKAction runBlock:^{
         [Edgar.physicsBody setVelocity: CGVectorMake(0 + contextVelocityX, Edgar.physicsBody.velocity.dy)];
         }];*/
        [Edgar facingEdgar];
        [Edgar removeActionForKey:@"bougeDroite"];
        [Edgar removeActionForKey:@"bougeGauche"];
        [Edgar removeActionForKey:@"walkingInPlaceEdgar"];
        //        [Edgar runAction:[SKAction repeatAction:doTheStop count:2]];
    }
    
    if (moveRightRequested == TRUE && !isJumping){ // pas suffisant: ajouter s'il a pied / vitesse verticale
        moveRightRequested = false;
        if((moveRight!=TRUE) || moveUpRequested){ // ddd why "or moveUpRequested"?
            Edgar.xScale = 1.0;
            [Edgar removeAllActions];
            [Edgar walkingEdgar];
            [Edgar runAction:bougeDroite2 withKey:@"bougeDroite"];
            moveRight = TRUE;
            moveLeft = FALSE;
        }else{
            // il s'arrete. OU: il court 2x plus vite
            //             stopRequested = TRUE;
            //            EdgarVelocity = 280; -> problème avec stopRequested
            //            Edgar.speed = 1.6;
        }
    }else if (moveLeftRequested == true && !isJumping){
        moveLeftRequested = false;
        if((moveLeft != TRUE) || moveUpRequested){
            Edgar.xScale = -1.0;
            [Edgar removeAllActions];
            [Edgar walkingEdgar];
            [Edgar runAction: bougeGauche2 withKey:@"bougeGauche"];
            moveLeft = true;
            moveRight = false;
            Edgar.speed = 1.0;
        }else{
            // il s'arrete
            //            stopRequested = TRUE;
            //            EdgarVelocity = 280;
            //            Edgar.speed = 1.6;
        }
    }
    
    if (moveUpRequested == true && !isJumping){
        /* SND: swoosh */
        moveUpRequested = FALSE;
        isJumping = TRUE;
        
        if(bigJumpRequested)
        {
            [Edgar.physicsBody applyImpulse: CGVectorMake(0, 45000)]; // auparavant 50000 puis 45000 puis 48000
            bigJumpRequested = FALSE;
        }
        else
        {
            EdgarVelocity = 250;
            [Edgar.physicsBody applyImpulse: CGVectorMake(0, 25000)];        }
        
        if(moveLeft||moveRight)
        {
            [Edgar jumpingEdgar];
        }
        
    }
    
    /*    if(moveLeft)
     {
     [Edgar.physicsBody setVelocity:CGVectorMake(-EdgarVelocity + contextVelocityX, Edgar.physicsBody.velocity.dy)];
     }else if(moveRight)
     {
     [Edgar.physicsBody setVelocity:CGVectorMake(EdgarVelocity + contextVelocityX, Edgar.physicsBody.velocity.dy)];
     }*/
}

- (void) computeCenter
{
    float theScale = 400 / self.view.bounds.size.height; // usually 1.25
    screenCenterX = 400 - ((self.view.bounds.size.width * theScale)/2);
}

@end
