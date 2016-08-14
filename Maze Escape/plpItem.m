//
//  plpItem.m
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

#import "plpItem.h"

//´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´
//
//  Class for pickable items: uranium, bonus
//  To do: make it less primitive
//
//................................................


@implementation plpItem


- (id)initAtPosition:(CGPoint)position withTexture:(NSString*)textureString andRadius:(int) radius
{
    if([textureString isEqualToString:@""])
    {
        self = [super initWithColor:[UIColor whiteColor] size:CGSizeMake(4, 4) ];
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:4 center:CGPointMake(0, 0)];
        self.physicsBody.dynamic = NO;
        self.alpha = 0.5;
        self.position = position;
    }
    else
    {
        SKTexture *mainTexture = [SKTexture textureWithImageNamed:textureString];

        self = [super initWithTexture:mainTexture];
        // radius = 22 for uranium, 5 for time bonus
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius: radius center:CGPointMake(0, 0)];
        self.physicsBody.dynamic = NO;
        self.position = position;
    }

    return self;
}

- (void) setSeconds: (int) theSeconds
{
    secondsBonus = theSeconds;
}
- (int) getSeconds
{
    return secondsBonus;
}


@end
