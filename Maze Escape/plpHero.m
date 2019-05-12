//
//  plpHero.m
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

#import "plpHero.h"

//´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´
//
//  Our beloved main character Edgar {:-[-<
//
//................................................

@implementation plpHero

- (id)initAtPosition:(CGPoint)position{
    
    facingEdgar = [SKTexture textureWithImageNamed:@"Level_objects_img/facingEdgar.png"];
    //facingEdgar = [SKTexture textureWithImageNamed:@"Level_objects_img/facingEdgar.png"];
    self = [super initWithTexture:facingEdgar];
    
    if (self) {
        
        self.size = CGSizeMake(59, 74); // ratio 1,25 / avant: 47, 73 = ratio 1,574
        
        NSMutableArray *walkFrames = [NSMutableArray array];
        SKTextureAtlas *EdgarAnimatedAtlas = [SKTextureAtlas atlasNamed:@"edgar"];

        SKTextureAtlas *EdgarJumpAtlas = [SKTextureAtlas atlasNamed:@"edgarsaute"];
        NSMutableArray *jumpFrames = [NSMutableArray array];

        for (int i=1; i <= 3; i++) {
            NSString *textureName = [NSString stringWithFormat:@"EdgarMarche%d", i];
            SKTexture *temp = [EdgarAnimatedAtlas textureNamed:textureName];
            [walkFrames addObject:temp];
        }
        [walkFrames addObject:[EdgarAnimatedAtlas textureNamed:@"EdgarMarche2"]];
        
        for (int i=1; i<=3; i++){
            NSString *textureName = [NSString stringWithFormat:@"Saut%d-01", i];
            SKTexture *temp = [EdgarJumpAtlas textureNamed:textureName];
            [jumpFrames addObject:temp];
        }

        [jumpFrames addObject:[EdgarJumpAtlas textureNamed:@"Saut3-01"]];
        [jumpFrames addObject:[EdgarJumpAtlas textureNamed:@"Saut2-01"]];
        [jumpFrames addObject:[EdgarJumpAtlas textureNamed:@"Saut1-01"]];

        _EdgarWalkingFrames = walkFrames;
        _EdgarJumpingFrames = jumpFrames;

        self.name = @"Edgar";
        self.position = position;
        
        
        SKPhysicsBody *topCircleBody = [SKPhysicsBody bodyWithCircleOfRadius:18 center:CGPointMake(0, 12)]; // until March 18, 2016: center= (0, 18) // 0, 22
        SKPhysicsBody *rectangleBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(28, 36) center:CGPointMake(0, -2)];

        topCircleBody.categoryBitMask = 1;
        rectangleBody.categoryBitMask = 1;
        rectangleNode = [SKSpriteNode node];
        rectangleNode.physicsBody = [SKPhysicsBody bodyWithBodies:@[topCircleBody, rectangleBody]];
        rectangleNode.physicsBody.mass = 30;
        rectangleNode.physicsBody.friction = 0;
        rectangleNode.physicsBody.restitution = 0;
        rectangleNode.physicsBody.linearDamping = 0;
        rectangleNode.physicsBody.categoryBitMask = 1; // = PhysicsCategoryEdgar
        
        
        // bottom circle
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:16 center:CGPointMake(0, -18)]; // -20
        self.physicsBody.mass = 50;
        self.physicsBody.friction = 0.6;
        self.physicsBody.friction = 0.1;
        
        self.physicsBody.linearDamping = 0;
        self.physicsBody.restitution = 0;
        self.physicsBody.allowsRotation = NO;
        

        [self addChild: rectangleNode];

        [self giveControl];
    }
    return self;
}

-(void)walkingEdgar
{
    [self runAction:[SKAction repeatActionForever:
                       [SKAction animateWithTextures:_EdgarWalkingFrames
                                        timePerFrame:0.1f
                                              resize:NO
                                             restore:YES]] withKey:@"walkingInPlaceEdgar"];
    return;
}

-(void)facingEdgar{
    [self setTexture:facingEdgar];
}

-(void)jumpingEdgar
{
    [self runAction:[SKAction animateWithTextures:_EdgarJumpingFrames
                                      timePerFrame:0.05f
                                            resize:NO
                                           restore:YES] withKey:@"jumpingInPlaceEdgar"];
    return;
}

-(void)addLight
{
    SKNode *lightNode = [self childNodeWithName:@"light"];
    
    if(!lightNode)
    {
        // The light which produces shadow
        SKLightNode* lampe = [[SKLightNode alloc] init];
        lampe.name = @"light";
        lampe.zPosition = 20;
        lampe.categoryBitMask = 1;
        lampe.falloff = 1;
        lampe.ambientColor = [UIColor whiteColor];
        lampe.lightColor = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:0.0 alpha:0.5];
        lampe.shadowColor = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        [self addChild:lampe];
        NSLog(@"LightNode added");
    }
    else
    {
        NSLog(@"LightNode already created");
    }
}

-(void)removeLight
{
    SKNode *lightNode = [self childNodeWithName:@"light"];
    if(lightNode)
    {
        [lightNode removeFromParent];
    }
}

-(void)addMasque
{
    SKSpriteNode *masque = [SKSpriteNode spriteNodeWithImageNamed:@"Level_objects_img/masque_120.png"];
    masque.name = @"masque";
    masque.size=CGSizeMake(1200, 800);
    [self addChild: masque];
    NSLog(@"Masque added");
}
-(void)removeMasque
{
    SKNode *masque = [self childNodeWithName:@"masque"];
    if(masque){
        [masque removeFromParent];
    }
}

-(void)giveControl
{
    boolHasControl = TRUE;
}
-(void)removeControl{
    boolHasControl = FALSE;
}
-(void)toggleControl{
    if(boolHasControl==TRUE)
    {
        boolHasControl=FALSE;
    }else{
        boolHasControl=TRUE;
    }
}
-(BOOL)hasControl{
    return boolHasControl;
}
-(void)takeDamage{
    SKAction *ouch = [SKAction sequence:@[
      [SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:1.0 duration:0.15],
      [SKAction waitForDuration:0.1],
      [SKAction colorizeWithColorBlendFactor:0.0 duration:0.15]]];
    [self runAction: ouch];
}
-(void)getsInfected{
    if(isInfected == FALSE){
        [self removeControl];
        isInfected = TRUE;
        SKAction *getBlue = [SKAction sequence:@[
             [SKAction colorizeWithColor:[SKColor blueColor] colorBlendFactor:0.8 duration:0.15],
             [SKAction waitForDuration:.5],
             [SKAction colorizeWithColorBlendFactor:0.5 duration:0.15]]];
        
        int random_distance = 20 + rand() % 30;
        float random_duration = 1.0f / (1.0f + rand() % 5);
        
        NSLog(@"Random: %d, %f, %d", random_distance, random_duration, rand() % 5);
        
        SKAction *strangeMove = [SKAction sequence:@[
             [SKAction moveByX:10 y:0 duration:.1],
             [SKAction moveByX:-random_distance y:0 duration:random_duration],
             [SKAction moveByX:random_distance+5 y:0 duration:.1]]];
        
        SKAction *giveBackControl = [SKAction runBlock:^{
            [self giveControl];
            self->isInfected = FALSE;
            NSLog(@"Control given back");
        }];
        SKAction *getWhite = [SKAction colorizeWithColorBlendFactor:0.0 duration:0.3];

        [self runAction: [SKAction sequence:@[getBlue, strangeMove, getWhite, giveBackControl]]];
    }
}
-(BOOL)alreadyInfected{
    return isInfected;
}
-(void)takeItem{
    hasUranium = TRUE;
}
-(void)resetItem{
    hasUranium = FALSE;
}
-(void)resetInfected{
    isInfected = FALSE;
}

-(BOOL)hasItem{
    return hasUranium;
}

@end
