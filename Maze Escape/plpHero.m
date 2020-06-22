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
    
    facingEdgar = [SKTexture textureWithImageNamed:@"FacingEdgar_x3.png"];
    //facingEdgar = [SKTexture textureWithImageNamed:@"Level_objects_img/facingEdgar.png"];
    self = [super initWithTexture:facingEdgar];
    
    if (self) {
        self.size = CGSizeMake(226, 236);
        
        NSMutableArray *walkFrames = [NSMutableArray array];
        SKTextureAtlas *EdgarAnimatedAtlas = [SKTextureAtlas atlasNamed:@"edgar"];

        //SKTextureAtlas *EdgarJumpAtlas = [SKTextureAtlas atlasNamed:@"edgarsaute"];
        NSMutableArray *jumpFrames = [NSMutableArray array];

        for (int i=1; i <= 3; i++) {
            NSString *textureName = [NSString stringWithFormat:@"EdgarMarche%d_x3", i];
            SKTexture *temp = [EdgarAnimatedAtlas textureNamed:textureName];
            [walkFrames addObject:temp];
        }
        [walkFrames addObject:[EdgarAnimatedAtlas textureNamed:@"EdgarMarche2_x3"]];
        
        /*for (int i=1; i<=3; i++){
            NSString *textureName = [NSString stringWithFormat:@"EdgarSaute%d_x3", i];
            SKTexture *temp = [EdgarAnimatedAtlas textureNamed:textureName];
            [jumpFrames addObject:temp];
        }*/
        
        [jumpFrames addObject:[EdgarAnimatedAtlas textureNamed:@"EdgarSaute1_x3"]];
        [jumpFrames addObject:[EdgarAnimatedAtlas textureNamed:@"EdgarSaute2_x3"]];
        [jumpFrames addObject:[EdgarAnimatedAtlas textureNamed:@"EdgarSaute3_x3"]];
        
        [jumpFrames addObject:[EdgarAnimatedAtlas textureNamed:@"EdgarSaute3_x3"]];
        [jumpFrames addObject:[EdgarAnimatedAtlas textureNamed:@"EdgarSaute2_x3"]];
        [jumpFrames addObject:[EdgarAnimatedAtlas textureNamed:@"EdgarSaute1_x3"]];

        _EdgarWalkingFrames = walkFrames;
        _EdgarJumpingFrames = jumpFrames;

        self.name = @"Edgar";
        self.position = position;
        
        SKPhysicsBody *topCircleBody = [SKPhysicsBody bodyWithCircleOfRadius: 63 center:CGPointMake(0, 48)]; // until March 18, 2016: center= (0, 18) // 0, 22
        SKPhysicsBody *rectangleBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(84, 160) center:CGPointMake(0, 0)];

        topCircleBody.categoryBitMask = 1;
        topCircleBody.friction = 0;
        topCircleBody.linearDamping = 0;
        
        rectangleBody.categoryBitMask = 1;
        rectangleNode = [SKSpriteNode node];
        rectangleNode.physicsBody = [SKPhysicsBody bodyWithBodies: @[topCircleBody, rectangleBody]];
        rectangleNode.physicsBody.mass = 90;
        rectangleNode.physicsBody.friction = 0; // “roughness of the surface”
        rectangleNode.physicsBody.restitution = 0; // “bounciness”
        rectangleNode.physicsBody.linearDamping = 0; // “reduces linear velocity”
        rectangleNode.physicsBody.categoryBitMask = 1; // = PhysicsCategoryEdgar
        
        
        // bottom circle
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:51 center:CGPointMake(0, -66)]; // -20
        self.physicsBody.mass = 150;
        self.physicsBody.friction = 0.6;
        self.physicsBody.friction = 0.1;
        
        self.physicsBody.linearDamping = 0;
        self.physicsBody.restitution = 0;
        self.physicsBody.allowsRotation = NO;
        
        self->lives = 5;

        [self addChild: rectangleNode];

        [self giveControl];
    }
    return self;
}

-(int)getLives
{
    return lives;
}
-(void)removeLife
{
    lives = lives - 1;
    if (lives < 1){
        // TODO
    }
}

-(void)walkingEdgar
{
    [self runAction:[SKAction repeatActionForever:
                       [SKAction animateWithTextures:_EdgarWalkingFrames
                                        timePerFrame:0.1f
                                              resize: NO
                                             restore: NO]] withKey:@"walkingInPlaceEdgar"];
    return;
}

-(void)facingEdgar{
    [self setTexture:facingEdgar];
}

-(void)jumpingEdgar
{
    [self runAction:[SKAction animateWithTextures:_EdgarJumpingFrames
                                      timePerFrame:0.05f
                                            resize: NO
                                           restore: NO] withKey:@"jumpingInPlaceEdgar"];
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
    if(!hasMasque){
        SKSpriteNode *masque = [SKSpriteNode spriteNodeWithImageNamed:@"ShadowMask.png"];
        masque.name = @"masque";
        masque.size = CGSizeMake(3600, 2400); // avant x3: 1200, 800
        [masque setZPosition: 22];
        [self addChild: masque];
        hasMasque = TRUE;
        NSLog(@"Masque added");
    }
}
-(void)removeMasque
{
    SKNode *masque = [self childNodeWithName:@"masque"];
    if(masque){
        [masque removeFromParent];
    }
    hasMasque = FALSE;
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

-(void)takeItem{
    hasUranium = TRUE;
}
-(void)resetItem{
    hasUranium = FALSE;
}

-(BOOL)hasItem{
    return hasUranium;
}

@end
