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

@interface plpMyScene () <UITextFieldDelegate>
{
}
@end

@implementation plpMyScene

NSArray *_monstreWalkingFrames;
SKSpriteNode *_monstre;

typedef NS_OPTIONS(uint32_t, MyPhysicsCategory) // pour eviter le contact entre certains objets
{
    PhysicsCategoryEdgar = 1 << 0,   // 1
    PhysicsCategoryObjects = 1 << 1, // 2
    PhysicsCategoryTiles = 1 << 2,   // 4
    PhysicsCategoryAliens = 1 << 3,  // 8
    PhysicsCategorySensors = 1 << 4, // 16
    PhysicsCategoryItems = 1 << 5    // 32
};


-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.physicsWorld.contactDelegate = self;
        self.size = CGSizeMake(800, 400);// => moitie de la largeur = 400 // En fait, coordonnees: 754 x 394
        
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
//        SKAction *wait = [SKAction waitForDuration:1]; // = 20 fois par seconde vs 60

        EdgarVelocity = 140;
        
        bougeDroite = [SKAction sequence:@[mvm1, wait]];
        bougeGauche = [SKAction sequence:@[mvm2, wait]];
        
        bougeGauche2 = [SKAction repeatActionForever:bougeGauche];
        bougeDroite2 = [SKAction repeatActionForever:bougeDroite];
        
        // Premier chargement de la carte des tiles
        
        myLevel = [self loadLevel:0];
        [myWorld addChild: myLevel];
        [self addStoneBlocks:myLevel];

        [self loadAssets:myLevel];

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
        
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"Sounds/Juno" withExtension:@"mp3"];
        NSError *error = nil;
        
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        self.audioPlayer.numberOfLoops = -1;
        if (!self.audioPlayer) {
            NSLog(@"Error creating player: %@", error);
        }
// ddd        [self.audioPlayer play];
    }
    return self;
}

- (void)endGameAnimation{
    NSLog(@"End game animation start");
    
    float theHeight = 400; //self.view.bounds.size.width;
    float halfHeight = theHeight/2;
    
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
    
    
    
    
    [myCamera setScale:1];
    
    nextLevelIndex = 1;

    //  We need to make a new Edgar
    Edgar = nil;
    Edgar = [[plpHero alloc] initAtPosition: CGPointMake(startPosition.x, startPosition.y)];
    Edgar.physicsBody.categoryBitMask = PhysicsCategoryEdgar;
    Edgar.physicsBody.collisionBitMask = PhysicsCategoryObjects|PhysicsCategoryTiles;
    Edgar.physicsBody.contactTestBitMask = PhysicsCategoryObjects|PhysicsCategoryTiles|PhysicsCategoryAliens|PhysicsCategorySensors|PhysicsCategoryItems;
    
    Edgar->rectangleNode.physicsBody.categoryBitMask = PhysicsCategoryEdgar;
    Edgar->rectangleNode.physicsBody.collisionBitMask = PhysicsCategoryObjects|PhysicsCategoryTiles;
    Edgar->rectangleNode.physicsBody.contactTestBitMask = PhysicsCategoryObjects|PhysicsCategoryTiles|PhysicsCategoryAliens|PhysicsCategorySensors|PhysicsCategoryItems;

    
    /*
    //  Camera animation
    SKAction *movingCamera = [SKAction group:@[
                                               [SKAction moveTo:[myLevel childNodeWithName:@"referencePoint"].position duration:5],
                                               ]];
    
    [myCamera runAction:[SKAction sequence:@[[SKAction waitForDuration:1.5],movingCamera]]];*/
    
    
}

// endGameNoScore -> closeEndGameDialog
- (IBAction)closeEndGameDialog:(id)sender {
    // We remove all subviews (text field and buttons), then the container
    [[containerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [containerView removeFromSuperview];

    NSLog(@"End game dialog closed.");
    [self endGameAnimation];
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
    [usernameTextView setFont:[UIFont fontWithName:@"Gill Sans" size:18]];
    
    UITextField *inputTextField = [[UITextField alloc] init];
    inputTextField.placeholder = [NSString stringWithFormat:@"Edgar"];
    inputTextField.autocorrectionType = UITextAutocorrectionTypeNo;

    inputTextField.textColor = [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1];
    inputTextField.backgroundColor = [UIColor whiteColor];
    [inputTextField setFont:[UIFont fontWithName:@"Gill Sans" size:18]];
    
    inputTextField.returnKeyType = UIReturnKeyDone;
    
    float outsideMargin = 60;
    float insideMargin = 30;
    float buttonsVerticalPosition = containerView.bounds.size.height-50;
    float buttonWidth = (containerView.bounds.size.width/2) - (outsideMargin + insideMargin);
    float buttonYesPositionX = outsideMargin;
    float buttonNoPositionX = buttonWidth + outsideMargin + 2*insideMargin;
    float inputFieldPositionY = containerView.bounds.size.height/2 - 20;
    
    NSLog(@"Hauteur : %f", inputFieldPositionY);
    
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
                   action: @selector(closeEndGameDialog:)
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
    NSLog(@"Return key pressed");
    
    return YES;
}


- (IBAction)saveScore:(id)sender {
    // We try to save the score...
    
    NSString* username;
    
    for (UIView* subView in containerView.subviews)
    {
        if ([subView isKindOfClass:[UITextField class]])
        {
            UITextField *usernameTextField = (UITextField*) subView;
            username = usernameTextField.text;
        }
    }
    
    // To improve this: UITextFieldDelegate etc.

    
    [[containerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UITextView *statusTextView = [[UITextView alloc] init];
    

    
    
    // < 4:30 = King Edgar
    // < 6:00 = Knight Edgar
    // else = Snail Edgar
    
    NSString* rankingString = @"Snail Edgar.";
    
    float totalTime = [self getTotalTime];
    if(totalTime < 270)
    {
        rankingString = @"King Edgar. Congrats, boss.";
    }else if(totalTime < 360)
    {
        rankingString = @"Knight Edgar. Very good.";
    }
    
    
    statusTextView.text = [NSString stringWithFormat:@"Your rank: %@", rankingString];
    statusTextView.textColor = [UIColor whiteColor];
    statusTextView.backgroundColor = [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1];
    statusTextView.editable = NO;
    [statusTextView setFont:[UIFont fontWithName:@"Gill Sans" size:18]];

    float outsideMargin = 60;
    float insideMargin = 30;
    float buttonsVerticalPosition = containerView.bounds.size.height-50;
    float buttonWidth = (containerView.bounds.size.width/2) - (outsideMargin + insideMargin);
    float buttonNewGamePositionX = containerView.bounds.size.width/2 - buttonWidth/2;

    [statusTextView setFrame: CGRectMake(20, 5, containerView.bounds.size.width-40, 80)];

    UIButton *myButtonClose  =   [UIButton buttonWithType:UIButtonTypeRoundedRect];
    myButtonClose.frame      =   CGRectMake(buttonNewGamePositionX, buttonsVerticalPosition, buttonWidth, 30.0);

    [myButtonClose setBackgroundColor: [UIColor whiteColor]];
    
    [myButtonClose setTitleColor: [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1] forState:UIControlStateNormal];
    [[myButtonClose layer] setMasksToBounds:YES];
    [[myButtonClose layer] setCornerRadius:5.0f];
    
    [myButtonClose setTitle: @"Close" forState:UIControlStateNormal];
    [myButtonClose addTarget: self
                   action: @selector(closeEndGameDialog:)
         forControlEvents: UIControlEventTouchUpInside];

    [containerView addSubview:statusTextView];
    [containerView addSubview:myButtonClose];
    
    NSLog(@"Saving the score…");
    
    [NSThread detachNewThreadSelector:@selector(saveHighScoreForUser:) toTarget:self withObject:username];
}


- (JSTileMap*)loadLevel:(int)levelIndex
{
    //  ddd Find new "title" & tutorial music? Or better: new function to load the music
/*    if(levelIndex == 1)
    {
        NSLog(@"(Re)-creating player");
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"Sounds/Juno" withExtension:@"mp3"];
        NSError *error = nil;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        self.audioPlayer.numberOfLoops = -1;
        if (!self.audioPlayer) {
            NSLog(@"Error creating player: %@", error);
        }
        [self.audioPlayer play];

    }*/
    
    if(levelIndex <= 1)
    {
        // We reset the intial and the saved time
        NSLog(@"First level => initial time saved");
        [self saveInitialTime];
        additionalSavedTime = 0;
        initialLevelTime = CFAbsoluteTimeGetCurrent();
        freeCamera = FALSE;
    }else{
        // We save the initial level time
        initialLevelTime = CFAbsoluteTimeGetCurrent();
    }
    
    
//    NSLog(@" \n\n Elapsed time: %f - %f = \n %f \n\n ", CFAbsoluteTimeGetCurrent(), initialTime, CFAbsoluteTimeGetCurrent() - initialTime); // ddd
    
    JSTileMap *myTileMap;
    NSArray *levelFiles = [NSArray arrayWithObjects:
                           @"Level_1_tuto.tmx",
                           @"Level_2.tmx",
                           @"Level_3.tmx",
                           @"Level_4.tmx",
                           @"Level_5.tmx",
                           @"Level_6.tmx", // !! erreur si fichier ne se charge pas! Ajouter un test
                           @"Level_7.tmx",
                           nil];
/*    NSArray *levelNames = [NSArray arrayWithObjects:  -> removed: level names
                           @"Entrance",
                           @"Cloakroom",
                           @"Control room",
                           @"Laboratory",
                           @"The Cell",
                           nil];*/
    
    NSString *myLevelFile;
    
    if(levelIndex < [levelFiles count])
    {
         myLevelFile = levelFiles[levelIndex];
    }
    
    if(myLevelFile)
    {
        // !!!!! Ajouter un try / catch ou similaire
        myTileMap = [JSTileMap mapNamed:myLevelFile];
        if(!myTileMap)
        {
            NSLog(@"Erreur de chargement de la carte.");
        }
    }
    
/*    if(levelIndex > -1)   To display level names
    {
        if(levelIndex < [levelNames count])
        {
            SKLabelNode *levelName= [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
            levelName.text = [NSString stringWithFormat:@"Level %d: %@", levelIndex + 1, levelNames[levelIndex]];//@"";
            levelName.fontSize = 50;
            levelName.fontColor = [SKColor redColor];
            levelName.position = CGPointMake(400, 200);
            [self addChild:levelName];
            
            SKAction *titleVanish = [SKAction sequence: @[[SKAction waitForDuration:1.5],[SKAction fadeAlphaTo:0 duration:.5], [SKAction removeFromParent]]];
            [levelName runAction:titleVanish];
        }
    }*/
    
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
//                [node setScale: 1.01f]; // ddd tentative
                [node setSize:CGSizeMake(101.0f, 101.0f)];
                node.physicsBody = [SKPhysicsBody bodyWithTexture:node.texture size:node.frame.size];
                node.physicsBody.dynamic = NO;
                node.physicsBody.categoryBitMask = PhysicsCategoryTiles;
                node.physicsBody.friction = 0.5;
                node.physicsBody.restitution = 0;
                if(node.physicsBody){
                    node.shadowCastBitMask = 1;
                }else{
                    NSLog(@"%d, %d: Le physicsBody n'a pas été créé", a, b);
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
    // Position de depart d'Edgar
    TMXObjectGroup *group = [tileMap groupNamed:@"Objets"]; // Objets
    if(!group) NSLog(@"Erreur: pas de calque Objets dans la carte.");
    NSArray *startPosObjects = [group objectsNamed:@"Start"];
    for (NSDictionary *startPos in startPosObjects) {
        startPosition = [self convertPosition:startPos];
    }
    
    if(nextLevelIndex==1) // Fin du niveau 1: on efface l'éventuel reste de flèche d'aide
    {
        SKNode *theNode;
        if(( theNode = [myCamera childNodeWithName:@"helpNode"]))
        {
            [theNode removeFromParent];
        }
    }
    
    if(nextLevelIndex>1)
    {
        SKSpriteNode *startLift = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"ascenseur-start.png"] size: CGSizeMake(88, 106)];
        startLift.position = startPosition;
        [tileMap addChild: startLift];
    }
 
    // Senseur (utilisés pour déclencher la fin du  niveau et des événements comme la venue du vaisseau spatial)
    // Sensor (detects when the player reaches the center of the lift and triggers events like the alien vessel)
    NSArray *sensorObjectMarker;
    if((sensorObjectMarker = [group objectsNamed:@"sensor"]))
    {
        SKSpriteNode *sensorNode;
        int sensorId;
        
        for (NSDictionary *theSensor in sensorObjectMarker) {
            NSLog(@"Création d'un senseur");
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
                    NSLog(@"Senseur avec nom _%@_ créé", theSensor[@"nodename"]);
                }
                else
                {
                    sensorNode.name = [NSString stringWithFormat:@"sensor%d", sensorId];
                    NSLog(@"Senseur avec id %d créé", sensorId);
                }
                sensorId++;
                [tileMap addChild:sensorNode];
                NSLog(@"Senseur ajouté.");
            }
            else
            {
                NSLog(@"Erreur lors de la création d'un senseur");
            }
        }
    }
    
    // Crate / Caisse
    SKTexture *textureCaisse = [SKTexture textureWithImageNamed:@"box-08.png"];
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
//        caisse.zPosition = -4; // devant les autres objets
        caisse.physicsBody.collisionBitMask = PhysicsCategoryEdgar|PhysicsCategoryObjects|PhysicsCategoryTiles;
//        caisse.shadowCastBitMask = 1;
        [tileMap addChild: caisse];
    }

    if(nextLevelIndex == 4)
    {
        // semaphore
        
        NSArray *semaphoreArray;
        if((semaphoreArray=[group objectsNamed:@"semaphore"]))
        {
            for (NSDictionary *monSemaphore in semaphoreArray) {
                plpItem *myItem;
                myItem = [[plpItem alloc] initAtPosition:[self convertPosition:monSemaphore] withTexture:@"FeuRouge.png"];
//                float waitBeforeStart = [monSemaphore[@"waitBeforeStart"] floatValue];
                if(myItem)
                {
//                    myItem.physicsBody.categoryBitMask = PhysicsCategoryItems;
                    [tileMap addChild:myItem];
                    // action
                    
                    SKTexture *semaphoreGreen = [SKTexture textureWithImageNamed:@"FeuVert.png"];
                    SKTexture *semaphoreRed = [SKTexture textureWithImageNamed:@"FeuRouge.png"];
                    SKAction *setGreen = [SKAction setTexture:semaphoreGreen];
                    SKAction *setRed = [SKAction setTexture:semaphoreRed];
                    SKAction *wait = [SKAction waitForDuration:2];
                    SKAction *changeTexture = [SKAction sequence:@[wait, setGreen, wait, setRed]];
                    
                    [myItem runAction:[SKAction repeatActionForever:changeTexture]];
                }
                else
                {
                    NSLog(@"Error while creating semaphore.");
                }
            }
        }
        
//        [caisse runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:1.0 duration:.2],[SKAction waitForDuration:2.8],[SKAction colorizeWithColor:[SKColor greenColor] colorBlendFactor:1.0 duration:.2], [SKAction waitForDuration:2.8]]]]];
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
            myItem = [[plpItem alloc] initAtPosition:[self convertPosition:monItem] withTexture:@"pile.png"];
            if(myItem)
            {
                myItem.name = @"uranium";
                myItem.physicsBody.categoryBitMask = PhysicsCategoryItems;
                [tileMap addChild:myItem];
            }
            else
            {
                NSLog(@"Erreur lors de la création de la pile d’uranium.");
            }
        }
    }

    // Train
    NSArray *trainObjectMarker;
    if((trainObjectMarker = [group objectsNamed:@"train"]))
    {
        plpTrain *trainNode;

        for (NSDictionary *theTrain in trainObjectMarker) {
/*            trainNode = [[plpTrain alloc] initAtPosition: [self convertPosition:theTrain] withMainTexture:@"Train_chassis_02.png" andWheelTexture:@"Train-roue.png"];*/
            trainNode = [[plpTrain alloc] initAtPosition: [self convertPosition:theTrain] withMainTexture:@"ChariotSocle.png" andWheelTexture:@"ChariotRoue--correct.png"];
            
            if(trainNode)
            {
                trainNode.physicsBody.categoryBitMask = PhysicsCategoryObjects;
                trainNode.physicsBody.collisionBitMask = PhysicsCategoryTiles|PhysicsCategoryObjects|PhysicsCategoryEdgar|PhysicsCategoryAliens;
//                trainNode.shadowCastBitMask = 1;
                [tileMap addChild:trainNode]; // vs myLevel
                [trainNode getLeftWheel].physicsBody.collisionBitMask = PhysicsCategoryTiles|PhysicsCategoryObjects|PhysicsCategoryEdgar|PhysicsCategoryAliens;
                [trainNode getRightWheel].physicsBody.collisionBitMask = PhysicsCategoryTiles|PhysicsCategoryObjects|PhysicsCategoryEdgar|PhysicsCategoryAliens;
                
                SKPhysicsJointPin *pinGauche = [SKPhysicsJointPin jointWithBodyA:[trainNode getLeftWheel].physicsBody bodyB:trainNode.physicsBody anchor:CGPointMake(trainNode.position.x-20, trainNode.position.y-18)];
                [self.physicsWorld addJoint:pinGauche];
                
                SKPhysicsJointPin *pinDroit = [SKPhysicsJointPin jointWithBodyA:[trainNode getRightWheel].physicsBody bodyB:trainNode.physicsBody anchor:CGPointMake(trainNode.position.x+20, trainNode.position.y-18)];
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
                NSLog(@"Erreur lors de la création de l'alien.");
            }
        }
    }
}

// TIME TRACKER

-(void)saveInitialTime
{
    initialTime = CFAbsoluteTimeGetCurrent();
    NSLog(@"Initial time = %f", initialTime);
}
-(void)saveAdditionalTime
{
    additionalSavedTime += CFAbsoluteTimeGetCurrent() - initialTime;
    NSLog(@"\n \n Additional time = %f \n \n", additionalSavedTime);
}
-(float)getTotalTime
{
    return (CFAbsoluteTimeGetCurrent() - initialTime) + additionalSavedTime;
}
-(NSString*)getTotalTimeString  // returns the time as a string, for example: "5 minutes and 30 seconds" or "30.15 seconds"
{
    float theTotalTime = [self getTotalTime];
    float seconds = fmodf(theTotalTime, 60);
    int minutes = roundf(theTotalTime / 60);
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
-(float)getLevelTime
{
    return CFAbsoluteTimeGetCurrent() - initialLevelTime;
}

// END TIME TRACKER

-(void)startPlaying
{
    if(self.audioPlayer)
        [self.audioPlayer play];
}

-(void)playTune:(NSString*)filename
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:filename withExtension:@"mp3"];
    NSError *error = nil;

    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    self.audioPlayer.numberOfLoops = -1;
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
    [myFinishRectangle removeFromParent];
    myFinishRectangle = nil;
    nextLevelIndex = (int)theLevel;
    NSLog(@"On repart du niveau %d", nextLevelIndex);
    [self startLevel];
}

-(int)getNextLevelIndex{
    return nextLevelIndex;
}

- (void)EdgarDiesOf:(int)deathType
{
    //  Death count disabled in current version / Décompte des morts désactivé dans la version actuelle
    //  deathCount++;
    
    if(deathType == SUICIDE_DEATH)
    {
        [myFinishRectangle removeFromParent];
        myFinishRectangle = nil;
        NSLog(@"On recharge le niveau %d", nextLevelIndex);
        [self startLevel];
    }
    else
    {
        [self resetEdgar];
    }
}

- (void)resetEdgar
{
    stopRequested = TRUE;
    [Edgar removeAllActions];
    [Edgar.physicsBody setVelocity:CGVectorMake(0, 0)];
    [Edgar setPosition:startPosition];
    [Edgar setScale:1];
    [Edgar resetItem];
    [Edgar giveControl]; // ddd voir si ne fait pas doublon
    [Edgar setSpeed: 1.0];
    isJumping = FALSE;
    gonnaCrash = FALSE;
    moveLeft = FALSE;
    moveRight = FALSE;
    moveUpRequested = FALSE;
    moveLeftRequested = FALSE;
    moveRightRequested = FALSE;
    listensToContactEvents = TRUE;
    [myLevel childNodeWithName:@"uranium"].hidden = FALSE;
}

// END PAUSE & RESUME ACTIONS

/*
- (void)didEvaluateActions
{
    
    
}
*/


// This method is called just after update, before rendering the scene
- (void)didSimulatePhysics
{
    // New code with SKCameraNode, added in iOS 9
    //    NSLog(@"Position: %f", myCamera.position.x);
    
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
    /*
     Detect if Edgar will crash -- currently disabled
     if(![Edgar.physicsBody isResting]){
     if(Edgar.physicsBody.velocity.dy < -1400){
     gonnaCrash = TRUE;
     }
     }*/
}

- (void)loadAudioFile
{
    
    
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

- (void) saveHighScoreForUser:(NSString*)userName
{
    float totalTime = [self getTotalTime];
    NSLog(@"Total time: %f", totalTime);
    
    NSString *urlStr = [[NSString alloc]
                        initWithFormat:@"http://paulronga.ch/edgar/score.php?user=%@&score=%.2f", userName, totalTime];
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSError *error = nil;
    NSStringEncoding encoding = 0;
    
    NSString *tryString = [[NSString alloc] initWithContentsOfURL:url
                                                     usedEncoding:&encoding
                                                            error:&error];
    NSLog(@"URL -> result: %@", tryString);
}

-(void)startLevel{
    [myLevel removeFromParent];
    [Edgar removeFromParent];
    [self resetEdgar];

    if([myCamera hasActions]) // on annule effets de zoom, etc.
    {
        [myCamera removeAllActions];
    }
    
    if((nextLevelIndex == LAST_LEVEL_INDEX) && (self.audioPlayer != nil))
    {
        [self doVolumeFade];
    }
    
    myLevel = [self loadLevel:nextLevelIndex];
    
    myWorld.position = CGPointMake(0, 0);
    [myWorld addChild: myLevel];
    
    [self addStoneBlocks:myLevel];
    [self loadAssets:myLevel]; // charge la position d'Edgar
//    [myWorld runAction:[SKAction fadeAlphaTo:1 duration:1.0]]; inutile avec le "rideau"
    Edgar.position = startPosition;
    myCamera.position = startPosition;

    [myLevel addChild: Edgar];
    
    SKPhysicsJointFixed *pinEdgar = [SKPhysicsJointFixed jointWithBodyA:Edgar.physicsBody bodyB:Edgar->rectangleNode.physicsBody anchor:CGPointMake(Edgar.position.x, Edgar.position.y)];
    [self.physicsWorld addJoint:pinEdgar];
    
    [Edgar giveControl];
    
    if(nextLevelIndex > 0) // we store the accomplished level
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:nextLevelIndex forKey:@"savedLevel"];
        [defaults synchronize];
        NSLog(@"Niveau sauvé: %d", nextLevelIndex);
    }
    
    if(nextLevelIndex > 1 && nextLevelIndex <= LAST_LEVEL_INDEX)
    {
        [Edgar addLight]; // shadow effect for levels 2-6
    }
}

- (void) didBeginContact:(SKPhysicsContact *)contact
{
    SKNode *contactNode = contact.bodyA.node;
    SKNode *userNode = contact.bodyB.node;
    
    if(!listensToContactEvents)
    {
        return;
    }

/*    if(isJumping==TRUE)
    {
        if([contactNode isKindOfClass:[plpHero class]] || [contact.bodyB.node isKindOfClass:[plpHero class]])
        {
            isJumping = FALSE;
        }
    }*/
    
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
            SKAction *greenDoor = [SKAction setTexture:[SKTexture textureWithImageNamed:@"ascenseurO-01.png"]];
            [contactNode runAction:greenDoor];
        }
        
        if([contactNode.name isEqualToString:@"finish"])
        {
            if([Edgar hasItem])
            {
                [Edgar removeControl];
                [Edgar runAction: [SKAction sequence:@[[SKAction moveToX:myFinishRectangle.position.x duration: .2], [SKAction runBlock:^{
                    stopRequested = TRUE;
                }]]]];
                
                [myFinishRectangle removeFromParent];
                myFinishRectangle = nil;
                nextLevelIndex++;
                
                NSLog(@"Chargement du niveau %d", nextLevelIndex);
                
                float theHeight = 400; //self.view.bounds.size.width;
                float halfHeight = theHeight/2;
                
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

                SKLabelNode *displayTime = [SKLabelNode labelNodeWithFontNamed:@"Gill sans"];
                displayTime.fontSize = 24;
                displayTime.fontColor = [SKColor whiteColor];
                displayTime.position = CGPointMake(40, 10);
                displayTime.zPosition = 30;
                
                SKLabelNode *displayTime2 = [SKLabelNode labelNodeWithFontNamed:@"Gill sans"];
                displayTime2.fontSize = 20;
                displayTime2.fontColor = [SKColor whiteColor];
                displayTime2.position = CGPointMake(40, -30);
                displayTime2.zPosition = 30;
                
                if(nextLevelIndex > 1)
                {
                    displayTime.text = [[NSString alloc]
                                        initWithFormat:@"Total time: %@", [self getTotalTimeString]];
                    
                    NSLog(@"User played %.2f.", [self getTotalTime]);
                    displayTime2.text = [[NSString alloc]
                                         initWithFormat:@"This level: %.2f seconds", [self getLevelTime]];
                }
                else
                {
                    displayTime.text = [[NSString alloc]
                                        initWithFormat:@"You made this tutorial in %.2f seconds", [self getLevelTime]];
                    
                    NSLog(@"User played %.2f.", [self getTotalTime]);
                    displayTime2.text = [[NSString alloc]
                                         initWithFormat:@"Get ready for the game!"];
                }
                
                // The three actions of the level transition are written in reverse order here:
                
                // 3. Third action: open curtains
                
                SKAction *openCurtain1 = [SKAction moveToY:halfHeight duration: .5];
                SKAction *openCurtain2 = [SKAction moveToY:-halfHeight duration: .5];
                SKAction *openCurtains = [SKAction runBlock:^{
                    [curtain1 runAction: openCurtain1];
                    [curtain2 runAction: openCurtain2];
                }];
                
                // 2. Second action: present score and start level (completion = action 3: open curtains)
                SKAction *presentScore = [SKAction runBlock:^{
                    [myCamera addChild:displayTime];
                    [myCamera addChild:displayTime2];

                    // we load the level in background
                    [self startLevel];
                    
                    SKAction *timeVanish = [SKAction sequence: @[[SKAction waitForDuration:2],[SKAction fadeAlphaTo:0 duration:1], [SKAction removeFromParent]]];
                    [displayTime runAction:timeVanish];
                    [displayTime2 runAction:timeVanish completion:^{
                        [myWorld runAction: openCurtains];
                    }];
                }];

                
                // 1. First action: close curtains (completion = action 2: present score)
                [curtain1 runAction: [SKAction moveToY:-20 duration: .5]];
                [curtain2 runAction: [SKAction moveToY:20 duration: .5] completion:^
                {
                     [myWorld runAction:presentScore];
                }];
            }
        }
        
        if(nextLevelIndex==LAST_LEVEL_INDEX)
        {
            
            if([contactNode.name isEqualToString:@"finalAnimationSensor"])
            {
                NSLog(@"Final animation 1 triggered");
                
                [contactNode removeFromParent];
                [Edgar removeControl];
                if(!moveRight)
                {
                    moveRightRequested = TRUE;
                }

                
                
/*                NSURL *url = [[NSBundle mainBundle] URLForResource:@"Sounds/EndGame" withExtension:@"mp3"];
                NSError *error = nil;
                
                if(self.audioPlayer != nil)
                {
                    [self.audioPlayer stop];
                }
                self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
                
                if (!self.audioPlayer) {
                    NSLog(@"Error creating player: %@", error);
                }
                */
                
                SKAction *audioPlayAction = [SKAction runBlock:^{
                    [self playTune:@"Sounds/EndGame"];
                    //[self.audioPlayer play];
                }];

                SKAction *theScale = [SKAction scaleTo:1.5 duration:2];
                [myCamera runAction: theScale];

                // First animation
                SKNode *alienVessel;
                alienVessel = [SKSpriteNode spriteNodeWithImageNamed:@"UFO1-02.png"];
                alienVessel.name = @"alienVessel";

                SKSpriteNode *beam = [SKSpriteNode spriteNodeWithImageNamed:@"rayonb.png"];
                beam.alpha = 0;
                beam.name = @"beam";
                
                CGPoint referencePoint = [myLevel childNodeWithName:@"referencePoint"].position;
                CGPoint referencePointAlien = CGPointMake(referencePoint.x, referencePoint.y-90); // ddd precedemment: -100
                
                SKAction *waitAction = [SKAction waitForDuration: 1];
                SKAction *longWaitAction = [SKAction waitForDuration: 2];
                
                
                SKAction *createAlien = [SKAction runBlock:^{
                    alienVessel.position = CGPointMake(Edgar.position.x, Edgar.position.y+400);
                    [myLevel addChild: alienVessel];
                    
                    [alienVessel addChild: beam];
                    beam.position = CGPointMake(0, -50);
                    beam.zPosition = -12;

                    NSLog(@"alien vessel added");
                }];
                
                SKAction *moveAlien = [SKAction runAction:[SKAction moveTo:referencePointAlien duration:2] onChildWithName:@"//alienVessel"];
                moveAlien.timingMode = SKActionTimingEaseInEaseOut;
                
                [myLevel runAction:[SKAction sequence:@[waitAction, audioPlayAction, [SKAction scaleTo:1 duration:1], longWaitAction, createAlien, moveAlien]]];
//                [myLevel runAction:[SKAction sequence:@[waitAction, fixedCameraAction, [SKAction scaleTo:1 duration:1], longWaitAction, createAlien, moveAlien, longWaitAction, createBeam, showBeam, moveEdgar, longWaitAction, vanish, removeBeam, moveAlien2, longWaitAction, flyAway, finalMessage]]];
                
                
            }
            else if([contactNode.name isEqualToString:@"finalAnimationSensor2"])
            {
                NSLog(@"Final animation TWO triggered");

                // Second animation
                CGPoint referencePoint = [myLevel childNodeWithName:@"referencePoint"].position;
                
                NSLog(@"Contact pos: %f, %f", contactNode.position.x, contactNode.position.y);
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
                    [Edgar->rectangleNode removeFromParent];    // => interdire de recommencer la scène, ou ça va planter
                }];
                
                SKAction *flyAway = [SKAction runAction:[SKAction moveTo:CGPointMake(2000, 2000) duration:4] onChildWithName:@"//alienVessel"];
                [flyAway setTimingMode: SKActionTimingEaseIn];
//                flyAway.timingMode = SKActionTimingEaseIn;

//                SKAction *moveAlien2 = [SKAction runAction:[SKAction moveByX: 0 y: 50 duration:1] onChildWithName:@"//alienVessel"];
//                moveAlien2.timingMode = SKActionTimingEaseInEaseOut;
                
                SKAction *moveEdgar = [SKAction runAction:[SKAction moveTo:referencePoint duration:2] onChildWithName:@"//Edgar"];
                moveEdgar.timingMode = SKActionTimingEaseInEaseOut;

                
                SKAction *vanish = [SKAction runAction:[SKAction fadeAlphaTo:0 duration:0] onChildWithName:@"//Edgar"];
                SKAction *removeBeam = [SKAction runBlock:^{
                    [beam removeFromParent];
                }];
                
                SKAction *finalMessage = [SKAction runBlock:^{
                    containerView = [[UIView alloc] init];
//                    [containerView setUserInteractionEnabled:NO];
                    [containerView setFrame: CGRectMake(50, 50, self.view.bounds.size.width-100, self.view.bounds.size.height-100)]; // origin is upper left; width and height relative to…
                    
                    //self.view.bounds.size.width-80, self.view.bounds.size.height-80)];
                    // bounds = 568, 320
                    
                    NSLog(@"Bounds: %f, %f", self.view.bounds.size.width, self.view.bounds.size.height);
                    containerView.backgroundColor = [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1];

                    
                    myTextView = [[UITextView alloc] init];

                    // We get the user's time
/*                    float theTotalTime = [self getTotalTime];
                    float seconds = fmodf(theTotalTime, 60);
                    int minutes = roundf(theTotalTime / 60);
                    
                    NSString* userTimeString = [NSString stringWithFormat:@"In %d minutes and %0f seconds.", minutes, seconds];
                    
                    if (minutes > 60)
                    {
                        userTimeString = @"In more than an hour.";
                    }*/
                    
                    NSString* userTimeString = [self getTotalTimeString];
                    
                    myTextView.text = [NSString stringWithFormat:@"You did it! \nYour time: %@.\nHowever, the alien vessel wasn’t part of the plan… \nStay tuned for the next part.\n\nSave your score online?", userTimeString];
                    
                    // More information on the «Edgar The Explorer» Facebook page.\nThis is a Creative Commons and GLP game. Our assets and source code are freely available on GitHub (search for: Edgar The Explorer).
                    
                    myTextView.textColor = [UIColor whiteColor]; // yellow: [UIColor colorWithRed:1 green:.953f blue:.533f alpha:1];
                    myTextView.backgroundColor = [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1];
                    myTextView.editable = NO;
                    [myTextView setFont:[UIFont fontWithName:@"Gill Sans" size:18]];
                    
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
                    [myButtonNo setBackgroundColor: [UIColor whiteColor]]; // yellow: [UIColor colorWithRed:1 green:.953f blue:.533f alpha:1]];
                    
                    [myButtonNo setTitleColor: [UIColor colorWithRed:.349f green:.259f blue:.447f alpha:1] forState:UIControlStateNormal];
                    [[myButtonNo layer] setMasksToBounds:YES];
                    [[myButtonNo layer] setCornerRadius:5.0f];
                    
                    [myButtonNo setTitle: @"No" forState:UIControlStateNormal];
                    [myButtonNo addTarget: self
                                   action: @selector(closeEndGameDialog:)
                         forControlEvents: UIControlEventTouchUpInside];

                    [self.view addSubview: containerView];
                    [containerView addSubview:myTextView];
                    [containerView addSubview:myButtonYes];
                    [containerView addSubview:myButtonNo];
                }];
                
                SKAction *freeCameraAction = [SKAction runBlock:^{
                    NSLog(@"Caméra fixée");
                    freeCamera = TRUE;
                }];

//                [myLevel runAction: finalMessage];
                [myLevel runAction:[SKAction sequence:@[createBeam, showBeam, moveEdgar, longWaitAction, vanish, removeBeam, longWaitAction, flyAway, longWaitAction, freeCameraAction, finalMessage]]];

            }
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
                helpNode = [SKSpriteNode spriteNodeWithImageNamed:@"swipeRight.png"];
            }else if([contactNode.name isEqualToString:@"jump"])
            {
                helpNode = [SKSpriteNode spriteNodeWithImageNamed:@"swipeJump.png"];
            }else if([contactNode.name isEqualToString:@"goUpstairs"])
            {
                helpNode = [SKSpriteNode spriteNodeWithImageNamed:@"swipeJump.png"];
            }else if([contactNode.name isEqualToString:@"showUranium"])
            {
                helpNode = [SKSpriteNode spriteNodeWithImageNamed:@"showUranium.png"];
                [helpNode setPosition:[myLevel childNodeWithName:@"uranium"].position];
                [helpNode setSize:CGSizeMake(100, 100)];
                [helpNode runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction fadeAlphaTo:1 duration:.5], [SKAction fadeAlphaTo:0 duration:.5]]]]];
            }else if([contactNode.name isEqualToString:@"moveToExit"])
            {
                helpNode = [SKSpriteNode spriteNodeWithImageNamed:@"goLeft.png"];
                
                SKTexture *menuButtonHelp = [SKTexture textureWithImageNamed:@"showMenu.png"];
                SKAction *showButtonHelp = [SKAction setTexture:menuButtonHelp resize:YES];
                SKTexture *suicideButtonHelp = [SKTexture textureWithImageNamed:@"showRepeat.png"];
                SKAction *showSuicideButtonHelp = [SKAction setTexture:suicideButtonHelp resize:YES];
                
                SKAction *fadeOutAndWait = [SKAction sequence:@[[SKAction waitForDuration: 1.5], [SKAction fadeAlphaTo:0 duration:.5], [SKAction waitForDuration:.5]]];
                SKAction *fadeIn = [SKAction fadeAlphaTo:1 duration: .5];
                
                SKAction *showButtonSequence = [SKAction sequence:@[fadeOutAndWait, showButtonHelp, fadeIn, fadeOutAndWait, showSuicideButtonHelp, fadeIn, fadeOutAndWait]];
                
                [helpNode runAction: showButtonSequence];
            }
            
            if(helpNode)
            {
                helpNode.name = @"helpNode";
                if(!helpNode.position.x)
                {
//                    [helpNode setPosition:CGPointMake(40.0f, -20.0f)];
                    [helpNode setPosition:CGPointMake(110.0f, -20.0f)];
                    [myCamera addChild: helpNode];

                    
                    
                    //[myLevel runAction: [SKAction fadeAlphaTo:0.5 duration:.5]];
                }else{
                    [myLevel addChild: helpNode];
                }

            }else{
                NSLog(@"Pas de nom de senseur correspondant");
            }

        }
    }
    
    if(contactNode.physicsBody.categoryBitMask == PhysicsCategoryItems)
    {
        if([contactNode isKindOfClass:[plpItem class]]) // à simplifier
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
        }
    }
    
    
    if(contactNode.physicsBody.categoryBitMask == PhysicsCategoryObjects)
    {
        if([contactNode isKindOfClass:[plpTrain class]])
        {
            plpTrain *theTrain = (plpTrain *)contactNode;
            [theTrain setHeroAbove];
            [(plpTrain *)contactNode accelerateAtRate:5 toMaxSpeed:200 invertDirection:FALSE];
            return;
        }

        if([contactNode isKindOfClass:[plpPlatform class]])
        {
            NSLog(@"Edgar : %f, plateforme: %f", Edgar.position.y - 42, contactNode.position.y);
            if(Edgar.position.y - 42 > contactNode.position.y){ /// ddd verifier hauteur. Probleme: plus correct (Edgar 290 / pateforme 292 ou 158 / 159.7
                [(plpPlatform *)contactNode setHeroAbove];
                NSLog(@"Hero set above");
            }
        }
    }
    
    if(contactNode.physicsBody.categoryBitMask == PhysicsCategoryAliens)
    {
        if([contactNode isKindOfClass:[plpEnemy class]])
        {
            if(![Edgar alreadyInfected])
            {
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
            NSLog(@"Quitte le train => décélération");
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
                    NSLog(@"Uranium end contact");
                    
                    [helpNode removeFromParent];
                    helpNode = nil;
                    [contactNode removeFromParent]; // We remove the sensor / On enlève le senseur
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
            
            CGPoint location = [touch locationInNode:self];
            
            // Contrôles alternatifs pour le simulateur iOS | Alternate controls for the iOS simulator
            if(USE_ALTERNATE_CONTROLS==1)
            {
                if(!moveLeft && !moveRight)
                {
                    if(location.x > 400)
                    {
                        moveRightRequested = true;
                    } else if (location.x < 400){
                        moveLeftRequested = true;
                    }
                    ignoreNextTap = TRUE;
                }
            }

            touchStartPosition = location; //location;// [touch locationInView:self.view];

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
                if(nextLevelIndex < LAST_LEVEL_INDEX)
                {
                    [myFinishRectangle removeFromParent];
                    myFinishRectangle = nil;
                    nextLevelIndex++;
                    self.view.showsPhysics = NO;
                    self.view.showsFPS = NO;
                    self.view.showsNodeCount = NO;
                    
                    NSLog(@"Chargement du niveau %d", nextLevelIndex);
                    [self startLevel];
                }
            }
            else if(touch.tapCount == 6)
            {
                [myFinishRectangle removeFromParent];
                myFinishRectangle = nil;
                nextLevelIndex = 6;
                self.view.showsPhysics = NO;
                self.view.showsFPS = NO;
                
                [self startLevel];
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
            }
/*            else if (endPosition.y + 10 < touchStartPosition.y)
            {
                stopRequested = TRUE; // trop court
            }*/
            
            if(endPosition.x -15 > touchStartPosition.x)
            {
                moveRightRequested = TRUE;
            }
            else if(endPosition.x + 15 < touchStartPosition.x)
            {
                moveLeftRequested = TRUE;
            }
            
            if((!moveUpRequested)&&(!moveLeftRequested)&&(!moveRightRequested))
            {
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
        EdgarVelocity = 140;
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
        if((moveRight!=TRUE) || moveUpRequested){
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
        moveUpRequested = false;
        isJumping = TRUE;
        [Edgar.physicsBody applyImpulse: CGVectorMake(0, 48000)]; // auparavant 50000 puis 45000
//        [Edgar.physicsBody setVelocity: CGVectorMake(Edgar.physicsBody.velocity.dx, 1550)];
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

@end
