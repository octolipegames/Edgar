//
//  plpPlatform.m
//  Maze Escape
//
//  Created by Paul on 21.08.15.
//  Copyright (c) 2015 Polip. All rights reserved.
//

#import "plpPlatform.h"

@implementation plpPlatform

- (float)calculateSpeedForDuration:(float)duration andLimit:(float)x_limit
{
    float speed;
    float distance = initXPosition - x_limit;
    NSLog(@"Distance: %f", distance);
    
    
    return speed;
}

- (id)initAtPosition:(CGPoint)position withSize:(CGSize)size withAcceleration:(float)acceleration upTo:(float)x_limit
{
    SKTexture *plateformeTexture = [SKTexture textureWithImageNamed:@"plateforme.png"];
    
    //    plateformeTexture.textureRect
    
    self = [super initWithTexture:plateformeTexture];
    
    if (self) {
        self.size = size;
        self.position = position;
        initXPosition = position.x;
        NSLog(@"Position init: %f", initXPosition);
        decelerationLimit = x_limit - ((x_limit - initXPosition)/2);
        
        //        self.centerRect = CGRectMake(8, 0, 10, 30);
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
        self.physicsBody.mass = 20000000000; // ajouter un override pour la plateforme qui tombe
        self.physicsBody.allowsRotation = NO;
        self.physicsBody.affectedByGravity = NO;
        self.physicsBody.friction = 1; //100;
        self.physicsBody.collisionBitMask = 1;
        self.physicsBody.linearDamping = 0;
        
        SKAction *waitDuration = [SKAction waitForDuration:1];
        
/*        SKAction *theMove = [SKAction runBlock:^{
            float newSpeed;
            if(movingLeft==FALSE){
                if(self.position.x > x_limit){
                    newSpeed = 0;
                    movingLeft = TRUE;
                }else{
                    if(self.position.x < decelerationLimit){
                        newSpeed = self.physicsBody.velocity.dx + acceleration;
                    }else{
                        NSLog(@"Décélération");
                        newSpeed = self.physicsBody.velocity.dx - (acceleration/2);
                    }
                }
            }else{
                if(self.position.x < initXPosition)
                {
                    NSLog(@"Pos plateforme: %f, initPosition: %f -> Fin du retour en arrière", self.position.x, initXPosition);
                    newSpeed = 0;
                    movingLeft = FALSE;
                }else{
                    if(self.position.x > decelerationLimit){
                        NSLog(@"On accélère dans l'autre sens");
                        newSpeed = self.physicsBody.velocity.dx - acceleration;
                    }
                }
            }
            
            [self.physicsBody setVelocity:CGVectorMake(newSpeed, 0)];
        }];*/
        
        SKAction *theMove = [SKAction runBlock:^{
            float newSpeed;
            if(movingLeft==FALSE){
                if(self.position.x > x_limit){
                    newSpeed = 0;
                    movingLeft = TRUE;
                    NSLog(@"Inversion direction.");
                }else{
                        newSpeed = acceleration * 3;
//                        newSpeed = self.physicsBody.velocity.dx - (acceleration/2);
                }
            }else{
                if(self.position.x < initXPosition)
                {
                    NSLog(@"Pos plateforme: %f, initPosition: %f -> Fin du retour en arrière", self.position.x, initXPosition);
                    newSpeed = 0;
                    movingLeft = FALSE;
                }else{
                    newSpeed = acceleration * -3;
                }
            }
            
            [self.physicsBody setVelocity:CGVectorMake(newSpeed, 0)];
        }];
/*        SKAction *theMove = [SKAction runBlock:^{
            if(movingLeft==FALSE){
                if(self.position.x < initXPosition+5){//x_limit+100){
                    movingLeft = TRUE;
                    [self.physicsBody applyForce:CGVectorMake(100000000000000, 0)];
                }
            }else{
                if(self.position.x > x_limit/2){
                    [self.physicsBody applyImpulse:CGVectorMake(-100000000000000, 0)];
                    movingLeft = FALSE;
                }
            }
        }];*/
        
        SKAction *maNewSequence = [SKAction sequence:@[waitDuration, theMove]];
        
        [self runAction:[SKAction repeatActionForever: maNewSequence]];
    }
    
    return self;
}

- (id)initAtPosition:(CGPoint)position withSize:(CGSize)size withMovement:(float)movement withDuration:(float)duration
{
    
    SKTexture *plateformeTexture = [SKTexture textureWithImageNamed:@"plateforme.png"];
    
//    plateformeTexture.textureRect
    
    self = [super initWithTexture:plateformeTexture];
    
    if (self) {
        self.size = size;
        self.position = position;
//        self.centerRect = CGRectMake(8, 0, 10, 30);
        
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
        
//        self.physicsBody.dynamic = NO;
        
        self.physicsBody.mass = 20000000000; // ajouter un override pour la plateforme qui tombe
        self.physicsBody.allowsRotation = NO;
        self.physicsBody.affectedByGravity = NO;
        self.physicsBody.friction = 1; //100;
        self.physicsBody.collisionBitMask = 1;
        
        
        // Mouvement continu
//        SKAction *mvm1 = [SKAction moveByX:movement y:0 duration: 5];
//        SKAction *mvm2 = [SKAction moveByX:-movement y:0 duration: 5];
//        SKAction *mvm1 = [SKAction applyImpulse:CGVectorMake(5000, 0) duration: 5]; -> ios 9
//        SKAction *mvm2 = [SKAction applyImpulse:CGVectorMake(-5000, 0) duration: 5];
//        SKAction *maNewSequence = [SKAction sequence:@[mvm1, mvm2]];

        SKAction *stopDuration = [SKAction waitForDuration:2.5];
        SKAction *movementDuration = [SKAction waitForDuration:duration];
        
        SKAction *mvm1 = [SKAction runBlock:^{
//            [self.physicsBody applyImpulse:CGVectorMake(5000000000000, 0)];
            [self.physicsBody setVelocity:CGVectorMake(movement, 0)];
        }];
        
        SKAction *mvm2 = [SKAction runBlock:^{
//            [self.physicsBody applyImpulse:CGVectorMake(-5000000000000, 0)];
            [self.physicsBody setVelocity:CGVectorMake(-movement, 0)];
        }];
        
        SKAction *stop = [SKAction runBlock:^{
            [self.physicsBody setVelocity:CGVectorMake(0, 0)];
        }];
        SKAction *maNewSequence = [SKAction sequence:@[stopDuration, mvm1, movementDuration, stop, stopDuration, mvm2, movementDuration, stop]];

        [self runAction:[SKAction repeatActionForever: maNewSequence]];
    }
    
    return self;

}

@end
