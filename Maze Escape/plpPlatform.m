//
//  plpPlatform.m
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

#import "plpPlatform.h"
#import "plpMyScene.h"

@implementation plpPlatform

typedef NS_OPTIONS(uint32_t, MyPhysicsCategory)
{
    PhysicsCategoryEdgar = 1 << 0,
    PhysicsCategoryObjects = 1 << 1,
    PhysicsCategoryTiles = 1 << 2,
};

- (float)calculateSpeedForDuration:(float)duration fromPosition:(float)initPosition toLimit:(float)limit
{
    float distance = limit - initPosition;
    return distance/duration;
}

- (id)initAtPosition:(CGPoint)position withSize:(CGSize)size withDuration:(float)duration upToX:(float)x_limit andY:(float)y_limit andIdleDuration:(float)idleDuration
{
    NSString *texturePath;
    if(x_limit == position.x) // vertical platform
    {
        texturePath = [NSString stringWithFormat:@"elevateur-01.png"];
    }else{
        texturePath = [NSString stringWithFormat:@"elevateur-02-horizontal.png"];
    }
    
    SKTexture *plateformeTexture = [SKTexture textureWithImageNamed:texturePath];
    
    self = [super initWithTexture:plateformeTexture];
    
    if (self) {
        self.size = size;
        self.position = position;
        initXPosition = position.x;
        initYPosition = position.y;
        
        self.anchorPoint = CGPointMake(0, 0);
        
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size center:CGPointMake(size.width/2,size.height/2)];
        self.physicsBody.mass = 20000000000;
        self.physicsBody.allowsRotation = NO;
        self.physicsBody.affectedByGravity = NO;
        self.physicsBody.friction = 1;
        self.physicsBody.collisionBitMask = 1;
        self.physicsBody.linearDamping = 0;
        
        self.physicsBody.categoryBitMask = PhysicsCategoryObjects;
        
        SKAction *waitDuration = [SKAction waitForDuration:idleDuration];
        SKAction *moveDuration = [SKAction waitForDuration:duration];
        
        float Xspeed = [self calculateSpeedForDuration:duration fromPosition:initXPosition toLimit:x_limit];
        float Yspeed = [self calculateSpeedForDuration:duration fromPosition:initYPosition toLimit:y_limit];
        

        
        // Horizontal platform: a SKAction won't work with physics (Edgar will fall).
        // Very primitive movement: we just set a constant speed.
        
        if(initXPosition == x_limit)
        {
            isVertical = TRUE;
            if(Yspeed > 0)
            {
                motionSpeed = Yspeed;
            }
            else
            {
                motionSpeed = -Yspeed;
            }
        }
        
        SKAction *theMoveReNew = [SKAction runBlock:^{
            float newSpeed = [self calculateSpeedForDuration: 2 fromPosition:1 toLimit:2];
            [self.physicsBody setVelocity:CGVectorMake(Xspeed, Yspeed)];
            {
                contextVelocityX = Xspeed;
            }
        }];
        
        SKAction *theMove = [SKAction runBlock:^{
            if(movingLeft==FALSE){
                [self.physicsBody setVelocity:CGVectorMake(Xspeed, Yspeed)];
                movingLeft = TRUE;
                if(heroAbove)
                {
                    contextVelocityX = Xspeed;
                }
            }else{
                [self.physicsBody setVelocity:CGVectorMake(-Xspeed, -Yspeed)];
                movingLeft = FALSE;
                if(heroAbove)
                {
                    contextVelocityX = -Xspeed;
                }
            }
        }];
        SKAction *stop = [SKAction runBlock:^{
            [self.physicsBody setVelocity:CGVectorMake(0, 0)];
            if(heroAbove)
            {
                contextVelocityX = 0;
            }
        }];

        SKAction *wholeSequence = [SKAction sequence:@[waitDuration, theMove, moveDuration, stop]];

    
        [self runAction:[SKAction repeatActionForever: wholeSequence]];
    }
    return self;
}

- (id)initAtPosition:(CGPoint)position withSize:(CGSize)size withDuration:(float)duration upToX:(float)x_limit andY:(float)y_limit
{
    
    return [self initAtPosition:position withSize:size withDuration:duration upToX:x_limit andY:y_limit andIdleDuration:2];
}

- (id)initAtPosition:(CGPoint)position withSize:(CGSize)size withDuration:(float)duration withMovement:(float)movement
{
    return [self initAtPosition:position withSize:size withDuration:duration upToX:position.x + movement andY:position.y];
}

- (float) getVelocityX
{
    return self.physicsBody.velocity.dx;
}

- (void) setHeroAbove
{
    heroAbove = TRUE;
}
- (void) HeroWentAway
{
    heroAbove = FALSE;
}

- (void) emergencyStop
{
    if(isVertical && self.physicsBody.velocity.dy < 0 && !emergencyStopTriggered) // only if the platform is moving down
    {
        NSLog(@"Emergency stop!");
        emergencyStopTriggered = TRUE; // to avoid simoultaneous calls
        
        [self setSpeed: 0]; // We pause the animation
        [self.physicsBody setVelocity:CGVectorMake(0, motionSpeed)]; // We invert the direction
        
        SKAction *delay = [SKAction waitForDuration: .5];

        [self.scene runAction: delay completion:^
        {
            [self.physicsBody setVelocity:CGVectorMake(0, 0)];
            [self.scene runAction: [SKAction waitForDuration: 2] completion:^
            {
                [self.physicsBody setVelocity:CGVectorMake(0, -motionSpeed)];
                

                [self.scene runAction: delay completion:^
                {
                    NSLog(@"Animation runs again");
                    emergencyStopTriggered = FALSE;

                    [self setSpeed: 1]; // animation runs again
                }];

            }];
        }];
    }
}

@end
