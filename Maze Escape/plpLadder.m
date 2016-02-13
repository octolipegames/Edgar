//
//  plpLadder.m
//  Maze Escape
//
//  Created by Paul on 22.09.15.
//  Copyright © 2015 Polip. All rights reserved.
//

#import "plpLadder.h"

@implementation plpLadder

- (id)initAtPosition:(CGPoint)position withSize:(CGSize)size withTextureNumber:(float)number
{
    SKTexture *ladderTexture = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"hammer%f.png", number]];
    
    self = [super initWithTexture:ladderTexture];
    
    if (self){
        self.size = size;
        self.position = position;
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
        self.physicsBody.density = 1000;
        self.physicsBody.dynamic = NO;
    }else{
        NSLog(@"Error while initiating a ladder.");
    }
    
    return self;
}

@end
