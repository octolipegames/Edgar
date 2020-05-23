//
//  plpEnemy.m
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

#import "plpScientist.h"


//´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´
//
//  The sweet aliens.
//  To do: more sprites, more colors
//
//................................................


@implementation plpScientist

- (id)initAtPosition:(CGPoint)position withSize:(CGSize)size
{
    self = [super initWithTexture: [SKTexture textureWithImageNamed: @"Scientifique_1.png"] ];

    if (self) {
        self.size = size;
        self.position = position;
        dangerous = TRUE;
        /*
        
        SKPhysicsBody *hitBody = [SKPhysicsBody bodyWithRectangleOfSize: bodySize center: CGPointMake(0, -size.height)];
        SKPhysicsBody *aggressiveBody = [SKPhysicsBody bodyWithRectangleOfSize: bodySize center: CGPointMake(0, size.height)];
        
        self.physicsBody = [SKPhysicsBody bodyWithBodies: @[hitBody, aggressiveBody]];
        
         */
        
        deadTexture = [SKTexture textureWithImageNamed: @"Scientifique_2.png"];
        CGSize bodySize = CGSizeMake(size.width / 2, size.height);
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: bodySize];
        
        self.physicsBody.mass = 2;
        self.physicsBody.allowsRotation = NO;
        self.physicsBody.friction = 0.5;
        self.physicsBody.collisionBitMask = 1;

    }
    
    return self;
}

- (BOOL) isDangerous {
    return dangerous;
}

- (void) dies {
    dangerous = FALSE;
    [self setTexture: deadTexture];
    [self.physicsBody setCollisionBitMask: 32];
}

@end
