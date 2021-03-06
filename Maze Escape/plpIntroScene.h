//
//  plpIntroScene.h
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
#import <AVFoundation/AVFoundation.h>
#import "plpMyScene.h"
#import "plpSoundController.h"

#define SCENE_SLIDES 4
#define MAX_SLIDE 3

@interface plpIntroScene : SKScene <SKPhysicsContactDelegate>
{
    plpSoundController *soundController;
    SKSpriteNode *animationNode;
    SKLabelNode *subtitleNodeTop;
    SKLabelNode *subtitleNodeBottom;
    NSMutableArray *animationFrames;
    NSMutableArray *animateActions;
    
    int currentSlide;
    NSTimer *nextSlideTimer;
    NSTimer *launchGameTimer;
}

@end
