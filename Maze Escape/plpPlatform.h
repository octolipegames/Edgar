//
//  plpPlatform.h
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

#import <SpriteKit/SpriteKit.h>
#import "plpSoundController.h"

@interface plpPlatform : SKSpriteNode
{
    BOOL isVertical;
    BOOL movingLeft;
    BOOL firstMovement;
    BOOL emergencyStopTriggered;
    float motionSpeed;
    BOOL heroNear; // TODO implement this
    BOOL heroAbove;
    BOOL noEmergencyStop;
    float initXPosition;
    float initYPosition;
    float endXPosition; // added for the new movement model (June 1, 2016)
    float endYPosition;
    float movementDuration;
    SKAction *standardSequence;
    SKAudioNode *platformSound;
}

- (id)initAtPosition:(CGPoint)position withSize:(CGSize)size withDuration:(float)duration upToX:(float)x_limit andY:(float)y_limit andIdleDuration:(float)idleDuration;

- (id)initAtPosition:(CGPoint)position withSize:(CGSize)size withDuration:(float)duration upToX:(float)x_limit andY:(float)y_limit;

- (id)initAtPosition:(CGPoint)position withSize:(CGSize)size withDuration:(float)duration withMovement:(float)movement;

- (BOOL) heroIsNearby;
- (float) getVelocityX;

- (void) setHeroAbove;
- (void) HeroWentAway;

- (void) setHeroNear;
- (void) setHeroAway;

- (BOOL) getIsVertical;
- (void) setNoEmergencyStop;
- (void) emergencyStop;
- (void) horizontalEmergencyStop: (float) EdgarXPosition;

- (void) setVolume: (float) fxVolume;

@end
