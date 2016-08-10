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

#import "plpEnemy.h"


//´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´
//
//  The sweet aliens.
//  To do: more sprites, more colors
//
//................................................


@implementation plpEnemy

- (id)initAtPosition:(CGPoint)position withSize:(CGSize)size withMovement:(float)movement
{
    NSMutableArray *monstreMutant = [NSMutableArray array];
    SKTextureAtlas *monstreAtlas = [SKTextureAtlas atlasNamed:@"monstre"];
    for (int i=1; i <= 6; i++) {
        NSString *laTexture = [NSString stringWithFormat:@"Monstre%d", i];
        SKTexture *temp = [monstreAtlas textureNamed:laTexture];
        [monstreMutant addObject:temp];
    }
    [monstreMutant addObject:[monstreAtlas textureNamed:@"Monstre5"]];
    [monstreMutant addObject:[monstreAtlas textureNamed:@"Monstre4"]];
    [monstreMutant addObject:[monstreAtlas textureNamed:@"Monstre3"]];
    [monstreMutant addObject:[monstreAtlas textureNamed:@"Monstre2"]];
    
    self = [super initWithTexture:monstreMutant[0]];

    if (self) {
        self.size = size;
        self.position = position;
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
        
        self.physicsBody.mass = 2;
        self.physicsBody.allowsRotation = NO;
        self.physicsBody.friction = 0.5;
        self.physicsBody.collisionBitMask = 1;
        
        // Texture animation
        [self runAction:[SKAction repeatActionForever:
             [SKAction animateWithTextures:monstreMutant
              timePerFrame:0.1f
                    resize:NO
                   restore:YES]] withKey:@"monstreMarche"];
        
        // Continuous movement
        if(movement != 0)
        {
            SKAction *mvm1 = [SKAction moveByX:movement y:0 duration: 2];
            SKAction *mvm2 = [SKAction moveByX:-movement y:0 duration: 2];
            SKAction *maNewSequence = [SKAction sequence:@[mvm1, mvm2]];
            [self runAction:[SKAction repeatActionForever: maNewSequence]];
        }
    }
    
    return self;
}

@end
