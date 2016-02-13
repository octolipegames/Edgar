//
//  plpMyScene.m
//  Maze Escape
//
//  Created by Paul on 16.08.14.
//  Copyright (c) 2014 Polip. All rights reserved.
//

#import "plpMyScene.h"

@implementation plpMyScene


NSArray *_monstreWalkingFrames;
SKSpriteNode *_monstre;

typedef NS_OPTIONS(uint32_t, MyPhysicsCategory) // pour eviter le contact entre certains objets
{
    PhysicsCategoryEdgar = 1 << 0,
    PhysicsCategoryObject = 1 << 1,
    PhysicsCategoryEnemy = 1 << 2,
};


-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.physicsWorld.contactDelegate = self;
        
        self.size = CGSizeMake(800, 400);// => moitie de la largeur = 400 // En fait, coordonnees: 754 x 394
        
        myWorld = [SKNode node];         // Creation du "monde" sur lequel tout est fixe
        myWorld.name = @"world";
        [self addChild:myWorld];
        
        // Actions
//        bougeDroite = [SKAction moveByX:120 y:0 duration: 1];
//        bougeGauche = [SKAction moveByX:-120 y:0 duration: 1];
        SKAction *mvm1 = [SKAction runBlock:^{
//              [Edgar.physicsBody applyForce:CGVectorMake(100000, 0)];
            [Edgar.physicsBody setVelocity:CGVectorMake(100, Edgar.physicsBody.velocity.dy)]; // ne fonctionne pas sur train / plateforme
        }];
        SKAction *mvm2 = [SKAction runBlock:^{
            [Edgar.physicsBody setVelocity:CGVectorMake(-100, Edgar.physicsBody.velocity.dy)];
        }];
        SKAction *wait = [SKAction waitForDuration:.05];
//        SKAction *wait2 = [SKAction waitForDuration:1];

        bougeDroite = [SKAction sequence:@[mvm1, wait]];
        bougeGauche = [SKAction sequence:@[mvm2, wait]];
        
        bougeGauche2 = [SKAction repeatActionForever:bougeGauche];

        stoppe = [SKAction setTexture:[SKTexture textureWithImageNamed:@"edgarDeFace.png"]];
        
        // Chargement de la carte des tiles
        myLevel = [self loadLevel:1];
        [myWorld addChild: myLevel];
        [self addStoneBlocks:myLevel];

        // Preload sound effects
        self.hopSound = [SKAction playSoundFileNamed:@"Sounds/Hop.caf" waitForCompletion:NO];
        self.sgroSound = [SKAction playSoundFileNamed:@"Sounds/Sgrogneugneu.caf" waitForCompletion:NO];
        
        [self loadAssets:myLevel];

        Edgar = [[plpHero alloc] initAtPosition: CGPointMake(startPosition.x, startPosition.y)];
//        Edgar.physicsBody.categoryBitMask = PhysicsCategoryEdgar;

        [myLevel addChild: Edgar];
        
/*        [Edgar addMasque];*/
//        [Edgar addLight];


    }
    return self;
}

- (JSTileMap*)loadLevel:(int)levelIndex
{
    JSTileMap *myTileMap;
    NSArray *levelFiles = [NSArray arrayWithObjects: //@"_Level00b.tmx",
                           //@"_Level0x_reverse.tmx",
                           //@"_Level01_v1_100px.tmx",
                           @"_Level04_MindTheGap.tmx",
                           @"_Level01_v1_100px.tmx",
                           @"_Level01_v1_100px-essaitrain.tmx",
                           @"_Level00b.tmx", @"_Level02_v1_100px.tmx", @"_Level03_v1_100px.tmx", @"_Level02b_v1_100px.tmx", @"stop", nil];
    NSArray *levelNames = [NSArray arrayWithObjects:
                           @"Entrance",
                           @"Tchouc Tchouc",
                           @"The Big Cave",
                           @"Mind The Gap", nil];
    
    NSString *myLevelFile = levelFiles[levelIndex];
    
    if(myLevelFile)
    {
        myTileMap = [JSTileMap mapNamed:myLevelFile];
        if(!myTileMap)
        {
            NSLog(@"Erreur de chargement de la carte.");
        }
    }
    
    if(levelNames[levelIndex] && levelIndex > 0)
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
                node.physicsBody = [SKPhysicsBody bodyWithTexture:node.texture size:node.frame.size];
                //node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:node.frame.size];
                node.physicsBody.dynamic = NO;
                node.physicsBody.friction = .6;
                node.physicsBody.restitution = 0.2;
                if(node.physicsBody){
                    node.shadowCastBitMask = 1;
                }else{
                    NSLog(@"Le physicsBody n'a pas été créé, pas d'ombre");
                }
                //NSLog(@"BRICK AT (%d, %d) is (%.2f, %.2f, %.2f, %.2f)", a, b, node.frame.origin.x, node.frame.origin.y, node.frame.size.width, node.frame.size.height);
                //NSLog(@"Brique à (%d, %d) - gid: %d", a, b, gid);

            }else{
                //NSLog(@"Pas de brique à (%d, %d)", a, b);
            }
        }
    }
}

-(void)loadAssets:(JSTileMap*) tileMap
{
    // Position de depart d'Edgar
    TMXObjectGroup *group = [tileMap groupNamed:@"Objets"]; // Objets
    if(!group) NSLog(@"Erreur: pas de calque Objets dans la carte.");
    NSArray *enemyObjects = [group objectsNamed:@"Start"];
    for (NSDictionary *enemyObj in enemyObjects) {
        CGFloat x = [enemyObj[@"x"] floatValue];
        CGFloat y = [enemyObj[@"y"] floatValue];
        NSLog(@"SPAWN: %f, %f", x, y);
        startPosition = CGPointMake(x, y);
    }
    
    // Fin du niveau
    NSArray *pointFinal = [group objectsNamed:@"Finish"]; // CGRectIntersectsRect
    for (NSDictionary *final in pointFinal) {
        CGFloat a = [final[@"x"] floatValue];
        CGFloat b = [final[@"y"] floatValue];
        CGFloat c = [final[@"width"] floatValue];
        CGFloat d = [final[@"height"] floatValue];
        myFinishRectangle = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:1 green: 1                                                                                blue: 1 alpha: .5] size:CGSizeMake(c, d)];
        myFinishRectangle.anchorPoint = CGPointMake(0, 0);
        myFinishRectangle.position = CGPointMake(a, b);
    }

    // Caisses
    SKTexture *textureCaisse = [SKTexture textureWithImageNamed:@"crate.png"];
    NSArray *placeCaisse = [group objectsNamed:@"Caisse"];
    for (NSDictionary *optionCaisse in placeCaisse) {
        CGFloat x = [optionCaisse[@"x"] floatValue];
        CGFloat y = [optionCaisse[@"y"] floatValue];
        CGFloat width = [optionCaisse[@"width"] floatValue];
        CGFloat height = [optionCaisse[@"height"] floatValue];
        
        SKSpriteNode *caisse = [SKSpriteNode spriteNodeWithTexture:textureCaisse size: CGSizeMake(width, height)];
        caisse.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(width, height)];
        caisse.physicsBody.mass = 40;
        caisse.physicsBody.friction = 0.1; //.01; // la caisse glisse
        caisse.position = CGPointMake(x,y);
        
        caisse.physicsBody.collisionBitMask = 1;
        //caisse.physicsBody.categoryBitMask = PhysicsCategoryObject; -> rendait la caisse "traversable"
        [tileMap addChild: caisse];
    }


    
    // the alien
    
/*    NSArray *tabAlien;
    plpEnemy *alien;
    if((tabAlien=[group objectsNamed:@"alien1"]))
    {
        for (NSDictionary *monAlien in tabAlien) {
            alien = [[plpEnemy alloc] initAtPosition:CGPointMake([monAlien[@"x"] floatValue], [monAlien[@"y"] floatValue]) withSize:CGSizeMake([monAlien[@"width"] floatValue], [monAlien[@"height"] floatValue]) withMovement:[monAlien[@"moveX"] floatValue]];
        }
        if(alien)
        {
            [tileMap addChild:alien]; // fonctionne alors que ne fonctionnait pas avec myLevel puisqu'il n'etait pas encore charge
        }
        else
        {
            NSLog(@"Erreur lors de la création de l'alien.");
        }
    }*/
    
    
    NSArray *tabAlien;
     if((tabAlien=[group objectsNamed:@"alien1"]))
     {
         for (NSDictionary *monAlien in tabAlien) {
             plpEnemy *alien;
             alien = [[plpEnemy alloc] initAtPosition:CGPointMake([monAlien[@"x"] floatValue], [monAlien[@"y"] floatValue]) withSize:CGSizeMake([monAlien[@"width"] floatValue], [monAlien[@"height"] floatValue]) withMovement:[monAlien[@"moveX"] floatValue]];
             if(alien)
             {
                 [tileMap addChild:alien]; // myLevel n'est pas encore charge
             }
             else
             {
                 NSLog(@"Erreur lors de la création de l'alien.");
             }
         }
     }
    
    SKSpriteNode *endLevelCaisseNode;
    NSArray *endLevelCrate = [group objectsNamed:@"endLevelCrate"];
    for (NSDictionary *final in endLevelCrate) {
        CGFloat x = [final[@"x"] floatValue];
        CGFloat y = [final[@"y"] floatValue];
        CGFloat width = [final[@"width"] floatValue];
        CGFloat height = [final[@"height"] floatValue];
        
        SKTexture *textureCaisse = [SKTexture textureWithImageNamed:@"crate.png"];
        endLevelCaisseNode = [SKSpriteNode spriteNodeWithTexture:textureCaisse size: CGSizeMake(width, height)];
        
        endLevelCaisseNode.name = @"endLevelCaisseNode";
        endLevelCaisseNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(width, height)];
        endLevelCaisseNode.physicsBody.collisionBitMask = 1;
//        endLevelCaisseNode.physicsBody.categoryBitMask = PhysicsCategoryObject;
        endLevelCaisseNode.physicsBody.friction = 0.01; // la caisse glisse
        endLevelCaisseNode.anchorPoint = CGPointMake(0, 0);
        endLevelCaisseNode.position = CGPointMake(x,y);
        endLevelCaisseNode.physicsBody.mass = 30;
        //endLevelCaisseNode.zRotation = 0;
        NSLog(@"Rotation caisse: %f", endLevelCaisseNode.zRotation);
        endLevelCaisseNode.physicsBody.dynamic = NO;
        //endLevelCaisseNode.physicsBody.affectedByGravity = NO;
    }

    // avec la securite
    if(myFinishRectangle) [tileMap addChild: myFinishRectangle];
    if(endLevelCaisseNode) [tileMap addChild: endLevelCaisseNode];
    
    // Item
    
    
    NSArray *tabItem;
    if((tabItem=[group objectsNamed:@"uranium"]))
    {
        for (NSDictionary *monItem in tabItem) {
            plpItem *myItem;
            myItem = [[plpItem alloc] initAtPosition:CGPointMake([monItem[@"x"] floatValue], [monItem[@"y"] floatValue]) withTexture:@"uranium.png"];
            if(myItem)
            {
                [tileMap addChild:myItem]; // myLevel n'est pas encore charge
            }
            else
            {
                NSLog(@"Erreur lors de la création de l'Item.");
            }
        }
    }

    
    // Train
    
    NSArray *trainObjectMarker;
    if((trainObjectMarker = [group objectsNamed:@"train"]))
    {
        plpTrain *trainNode;

        for (NSDictionary *theTrain in trainObjectMarker) {
            trainNode = [[plpTrain alloc] initAtPosition: CGPointMake([theTrain[@"x"] floatValue], [theTrain[@"y"] floatValue]) withMainTexture:@"Train-chassis.png" andWheelTexture:@"Train-roue.png"];
            
            if(trainNode)
            {
                NSLog(@"Ajout d'un pin. Position: %f, %f", trainNode.position.x, trainNode.position.y);
                NSLog(@"Position du niveau: %f, %f", tileMap.position.x, tileMap.position.y);
                NSLog(@"Position du monde: %f, %f", myWorld.position.x, myWorld.position.y); // -> 2015-08-30 18:53:57.081 Maze Escape[39855:1606182] Position du monde: -1299.871582, 0.000000

//                trainNode.physicsBody.categoryBitMask = PhysicsCategoryObject;
                
                [tileMap addChild:trainNode]; // vs myLevel
                SKPhysicsJointPin *pinGauche = [SKPhysicsJointPin jointWithBodyA:[trainNode getLeftWheel].physicsBody bodyB:trainNode.physicsBody anchor:CGPointMake(trainNode.position.x-30, trainNode.position.y-5)];
                // convertir selon la position dans le monde?
                
                [self.physicsWorld addJoint:pinGauche];
                
                SKPhysicsJointPin *pinDroit = [SKPhysicsJointPin jointWithBodyA:[trainNode getRightWheel].physicsBody bodyB:trainNode.physicsBody anchor:CGPointMake(trainNode.position.x+30, trainNode.position.y-5)];
                [self.physicsWorld addJoint:pinDroit];

                /*SKPhysicsJointPin *pinGauche = [SKPhysicsJointPin jointWithBodyA:[trainNode getLeftWheel].physicsBody bodyB:trainNode.physicsBody anchor:CGPointMake(trainNode.position.x-30, trainNode.position.y-5)];
                
                [self.physicsWorld addJoint:pinGauche];
                
                SKPhysicsJointPin *pinDroit = [SKPhysicsJointPin jointWithBodyA:[trainNode getRightWheel].physicsBody bodyB:trainNode.physicsBody anchor:CGPointMake(trainNode.position.x+30, trainNode.position.y-5)];
                [self.physicsWorld addJoint:pinDroit];*/
            }

        }
    }
    
    
    NSArray *platformObjectMarker;
    if((platformObjectMarker = [group objectsNamed:@"platform"]))
    {
        plpPlatform *platformNode;
        
        for (NSDictionary *thePlatform in platformObjectMarker) {
/*            platformNode = [[plpPlatform alloc] initAtPosition: CGPointMake([thePlatform[@"x"] floatValue], [thePlatform[@"y"] floatValue])
                                                      withSize:CGSizeMake([thePlatform[@"width"] floatValue], [thePlatform[@"height"] floatValue])
                                                  withMovement: 200 withDuration:5];*/
            platformNode = [[plpPlatform alloc] initAtPosition: CGPointMake([thePlatform[@"x"] floatValue], [thePlatform[@"y"] floatValue])
        withSize:CGSizeMake([thePlatform[@"width"] floatValue], [thePlatform[@"height"] floatValue])
                                               withDuration:[thePlatform[@"movementDuration"] floatValue] upTo:[thePlatform[@"x_limit"] floatValue]];
            
            // [thePlatform[@"speed"] floatValue]
            
            if(platformNode)
            {
                NSLog(@"Ajout d'un pin. Position: %f, %f", platformNode.position.x, platformNode.position.y);
                NSLog(@"Position du niveau: %f, %f", tileMap.position.x, tileMap.position.y);
                NSLog(@"Position du monde: %f, %f", myWorld.position.x, myWorld.position.y);
                
                [tileMap addChild:platformNode]; // vs myLevel
            }
            
        }
    }

    
    NSLog(@"Ouverture fichier audio...");
/*    if(self.audioPlayer != nil)
    {
        [self.audioPlayer stop];
        [self.audioPlayer release]; -> inutile avec ARC (Automatic reference counting)
    }*/
    NSURL *url = [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"Sounds/piste%d", nextLevelIndex] withExtension:@"caf"];
    NSError *error = nil;

    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    if (!self.audioPlayer) {
        NSLog(@"Error creating player: %@", error);
    }
    
    [self.audioPlayer play];
    

    if(nextLevelIndex > 1)[self runAction:self.sgroSound];
}


- (BOOL) didFinish  // Cf. FieldNode
{
    if(myFinishRectangle == nil){
//        NSLog(@"Niveau %d: pas de myFinishRectangle", nextLevelIndex);
        return FALSE;
    }
    if([Edgar intersectsNode: myFinishRectangle])
    {
        [myFinishRectangle removeFromParent];
        myFinishRectangle = nil;
        SKNode *endLevelCaisseNode = [self childNodeWithName: @"//endLevelCaisseNode"];
      endLevelCaisseNode.physicsBody.dynamic = YES;
//        endLevelCaisseNode.physicsBody.affectedByGravity = YES;
        return TRUE;
        
    //[endLevelCaisseNode removeFromParent];
    }
    return FALSE;
}

- (void)EdgarDiesOf:(int)deathType
{
    // deathsCount ou livesCount
    if(deathType == 1)
    {
//        [Edgar takeDamage];
    }
    lifeStatus.text = [lifeStatus.text stringByAppendingString:@"†"];
    [Edgar removeFromParent];
    [Edgar removeAllActions];
    moveLeft = false;
    moveRight = false;
    vitesseX = 0;
    Edgar.physicsBody.velocity = CGVectorMake(0)
    Edgar.position = startPosition;
    [myLevel addChild:Edgar];
}

- (void)didSimulatePhysics
{
    CGPoint edgarPosition = Edgar.position;
    
    // 1e possibilite: fixer la camera:
   /* myWorld.position = CGPointMake(-(edgarPosition.x-(self.size.width/2)), -(edgarPosition.y-(self.size.height/2)));*/
  
    // 2e possibilite: faire glisser l'ecran

    CGPoint worldPosition = myWorld.position;
    CGFloat xCoordinate = worldPosition.x + edgarPosition.x;
    CGFloat yCoordinate = worldPosition.y + edgarPosition.y;
    
    if(![Edgar.physicsBody isResting]){
        if(Edgar.physicsBody.velocity.dy < -1000){
            NSLog(@"Va se crasher. - %f", Edgar.physicsBody.velocity.dy);
            gonnaCrash = TRUE;
         //   willCrash = TRUE;
        }
    }
    
    if(xCoordinate < 300) // a gauche
    {
        worldPosition.x =  worldPosition.x - xCoordinate + 300;
    }
    
    else if(xCoordinate > (self.frame.size.width - 300)) // a droite
    {
        worldPosition.x = worldPosition.x + (self.frame.size.width - xCoordinate) - 300;
    }

    if(yCoordinate < 30 && worldPosition.y < 600) // il tombe
    {
        worldPosition.y = worldPosition.y + 335;
    }
    else if(yCoordinate > (self.frame.size.height - 30))
    {
        worldPosition.y = worldPosition.y - 335;
    }else if(yCoordinate < 30){
        lifeStatus.text = [lifeStatus.text stringByAppendingString:@"†"];
        [Edgar removeAllActions];
        [Edgar removeFromParent];
        moveLeft = false;
        moveRight = false;
        Edgar.position = startPosition; // Prevoir une fonction lorsqu'il meurt + fonction de retour au debut du niveau
        [myLevel addChild:Edgar];
        NSLog(@"Au fond du trou. startPosition: %f, %f", startPosition.x, startPosition.y);
    }
    
    myWorld.position = worldPosition;
//    NSLog(@"WorldPosition: %f, %f", worldPosition.x, worldPosition.y);
    
    if([self didFinish])
    {
        nextLevelIndex++;
        NSLog(@"Chargement du niveau %d", nextLevelIndex);
        
//        [self fadeWithDuration:2]
        id fade = [SKAction fadeAlphaTo:0 duration:1];
        id wait = [SKAction waitForDuration:.5];
        id run = [SKAction runBlock:^{
            [self startLevel];
        }];
        [myWorld runAction:[SKAction sequence:@[wait, fade, wait, run]]];
    }


    // 3e possibilite: passer d'un ecran a l'autre
/*
    CGPoint worldPosition = myWorld.position;
    CGFloat xCoordinate = worldPosition.x + edgarPosition.x; // donne la position en pixels depuis la gauche
    CGFloat yCoordinate = worldPosition.y + edgarPosition.y;
 
    if(xCoordinate < 150) // a gauche de l'ecran
    {
        worldPosition.x =  worldPosition.x + 500;
        //        self.worldMovedForUpdate = YES;
    }
    
    else if(xCoordinate > (self.frame.size.width - 150)) // a droite de l'ecran
    {
        worldPosition.x = worldPosition.x - 500;
        //        self.worldMovedForUpdate = YES;
    }
    
    if(yCoordinate < 10 && worldPosition.y < 600) // il tombe
    {
        worldPosition.y = worldPosition.y + 200;
    }
    else if(yCoordinate > (self.frame.size.height - 10))
    {
        worldPosition.y = worldPosition.y - 200;
    }
    myWorld.position = worldPosition;
  */

}

-(void)startLevel{
    [myLevel removeFromParent];
    [Edgar removeFromParent];
    [Edgar removeAllActions];
    moveLeft = false;
    moveRight = false;
    
    if(nextLevelIndex > 4) // ajouter constante: lastLevelIndex
    {
        NSLog(@"Fin de partie");
        lifeStatus.text =@"You won!";
        return;
    }
    if(nextLevelIndex>0)
    {
//        [Edgar addMasque];
//        [Edgar addLight];
    }

    myLevel = [self loadLevel:nextLevelIndex];
    myWorld.position = CGPointMake(0, 0);
    [myWorld addChild: myLevel];
    
    [self addStoneBlocks:myLevel];
    [self loadAssets:myLevel]; // charge la position d'Edgar
    [myWorld runAction:[SKAction fadeAlphaTo:1 duration:1.0]];
    Edgar.position = startPosition;
    [myWorld addChild: Edgar];
}

-(void)didMoveToView:(SKView *)view {
    lifeStatus = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    lifeStatus.text = @"";
    lifeStatus.fontSize = 65;
    lifeStatus.fontColor = [SKColor greenColor];
    lifeStatus.position = CGPointMake(400, 300);
    [self addChild:lifeStatus];
}


- (void) didBeginContact:(SKPhysicsContact *)contact
{
    SKNode *contactNode = contact.bodyA.node;

    if(contactNode.physicsBody.collisionBitMask != 1) return;
    if(contact.bodyB.collisionBitMask != 1) return;
    
    if([contactNode isKindOfClass:[plpHero class]])
    {
     //   NSLog(@"BodyA = Edgar");
        contactNode = contact.bodyB.node;
    }else{
        //SKNode *secondNode = contact.bodyB.node;
        if([contact.bodyB.node isKindOfClass:[plpHero class]])
        {
        //    NSLog(@"BodyB = Edgar");
            // Code
        }
        else
        {
            // Edgar pas impliqué
            return;
        }
    }

    if(contactNode.physicsBody.collisionBitMask == 1)
    {
        if([contactNode isKindOfClass:[plpTrain class]])
        {
            NSLog(@"Train!");
            // Le setup du train devra etre precise au chargement du niveau et base sur les donnees de la carte
            [(plpTrain *)contactNode accelerateAtRate:5 toMaxSpeed:200 invertDirection:FALSE];

            stopRequested = TRUE;
            
//            [(plpTrain *)contactNode moveToSpeed:-50];
            return;
        }
        if([contactNode isKindOfClass:[plpEnemy class]])
        {
            [Edgar getsInfected];

            /*            SKAction *aie = [SKAction runBlock:^{
                [Edgar takeDamage];
            }];
            SKAction *mort = [SKAction runBlock:^{
                [self EdgarDiesOf:1];
            }];
            
            SKAction *wait = [SKAction waitForDuration:.5];
            [Edgar runAction: [SKAction sequence:@[aie, wait, mort]]];*/

//            [Edgar removeControl];
//            [Edgar takeDamage];
//            [self EdgarDies];
            return;
        }
        if([contactNode isKindOfClass:[plpItem class]])
        {
            NSLog(@"Objet (uranium?) ramassé");
            [Edgar takeItem];
            [(plpItem *)contactNode removeFromParent];
        }
        if([contactNode isKindOfClass:[plpPlatform class]])
        {
            NSLog(@"Plateforme");
            stopRequested = TRUE;
        }

    }
    else
    {
        NSLog(@"ploc");
        if(gonnaCrash==TRUE)
        {
                        NSLog(@"Crash");
            [Edgar removeFromParent];

        }
        // Simple sol ou mur.
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // On detecte les mouvements et la position du personnage avant de transmettre a update().
    if([Edgar hasControl]==TRUE)
    {
        for (UITouch *touch in touches) {
            CGPoint location = [touch locationInNode:self];
            
            if(location.y > 200){ // partie superieure de l'ecran
                moveUpRequested = true;
            }
                
            if(location.x > 450) // partie droite de l'ecran
            {
                moveRightRequested = true;
            } else if (location.x < 350){
                moveLeftRequested = true;
            }else{
                stopRequested = true;
            }
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // a faire: mise en pause
//    for (UITouch *touch in touches) {
//        CGPoint location = [touch locationInNode:self];
//        NSLog(@"Edgar: (%f, %f); souris: (%f, %f)", edgar.position.x, edgar.position.y, location.x, location.y);
//        SKNode *edgar = [self childNodeWithName: @"//Edgar"];
//        edgar.position = CGPointMake(400, 200);
//    }
}



-(void)update:(CFTimeInterval)currentTime {
    // Mouvements

    float vitesseXEdgar = Edgar.physicsBody.velocity.dx;
    float vitesseYEdgar = Edgar.physicsBody.velocity.dy;
    
    if(vitesseYEdgar < 0.01 && vitesseYEdgar > -0.01){
        vitesseYEdgar = 0;
    }

    if(stopRequested == true){// && vitesseYEdgar < .5){
        stopRequested = false;
        moveLeft = false;
        moveRight = false;
        Edgar.xScale = 1.0;
//        [Edgar runAction: [SKAction repeatAction:stoppe count:1]];
        vitesseX = 0;
        [Edgar removeAllActions];
/*        [Edgar removeActionForKey:@"bougeDroite"];
        [Edgar removeActionForKey:@"bougeGauche"];*/
    }

    /*  if(edgar.physicsBody.resting == TRUE)
     {
     NSLog(@"resting");
     }*/
    
    if (moveRightRequested == true){// && vitesseXEdgar < 0.5){
        moveRightRequested = false;
        if(moveRight != true){
            Edgar.xScale = 1.0;
            [Edgar removeAllActions];
            [Edgar walkingEdgar];
//            [Edgar runAction: [SKAction repeatActionForever:bougeDroite]];
//            newVitesseXEdgar = 400;
            vitesseX = 150;
            moveRight = true;
            moveLeft = false;
        }
    }else if (moveLeftRequested == true && vitesseXEdgar > -0.5){
        moveLeftRequested = false;
        if(moveLeft != true){
            Edgar.xScale = -1.0;
            [Edgar removeAllActions];
            [Edgar walkingEdgar];
            //[Edgar runAction: bougeGauche2];
            vitesseX = -150;
            moveLeft = true;
            moveRight = false;
        }
    }

    if (moveUpRequested == true){// && vitesseYEdgar == 0){
        moveUpRequested = false;
        [Edgar.physicsBody applyImpulse: CGVectorMake(0, 50000)];
        [self runAction:self.hopSound];
    }
    
    CGFloat rate = .5;
    CGVector relativeVelocity = CGVectorMake(vitesseX-vitesseXEdgar, vitesseYEdgar);
    Edgar.physicsBody.velocity=CGVectorMake(vitesseXEdgar+relativeVelocity.dx*rate, Edgar.physicsBody.velocity.dy);

//    Edgar.physicsBody.velocity.dx = vitesseXEdgar + relativeVelocity.dx * rate;
    

}

@end
