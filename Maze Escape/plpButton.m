//
//  plpButton.m
//
//  Edgar The Explorer
//
//  Copyright (c) 2014-2019 Filipe Mathez and Paul Ronga
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

#import "plpButton.h"



@implementation plpButton

- (id)initAtPosition:(CGPoint)position withImage:(NSString*)image andRotation:(float)rotation;
{
    if (self = [super initWithImageNamed:image])
    {
        self.position = position;
        self.zPosition = 28;
        self.zRotation = rotation;
        self.alpha = 0.6;
//        self.userInteractionEnabled = YES;
//        self.exclusiveTouch = YES;
        
//        actionTouchDown = [SKAction scaleBy:0.8 duration:0.1];
//        actionTouchUp = [SKAction scaleBy:1.25 duration:0.1];

    }
    [self setScale: 0.5];
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Touch!");
    if (currentTouch == nil)
    {
        currentTouch = [touches anyObject];
    }
    else
    {
        //current touch occupied
    }

}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"End");
    
}

@end
