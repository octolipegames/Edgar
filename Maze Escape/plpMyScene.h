//
//  plpMyScene.h
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
#import "JSTileMap.h"
#import "plpHero.h"
#import "plpEnemy.h"
#import "plpTrain.h"
#import "plpPlatform.h"
#import "plpItem.h"

#define MAXNUMBEROFDEATHS 10

#define SUICIDE_DEATH 0
#define CRASH_DEATH 1
#define FALLEN_DEATH 2
#define ALIEN_DEATH 3
#define HAMMER_DEATH 4
#define LAST_LEVEL_INDEX 6
#define USE_ALTERNATE_CONTROLS 0

float contextVelocityX;

@interface plpMyScene : SKScene <SKPhysicsContactDelegate>
{
    plpHero *Edgar;
    SKPhysicsBody *EdgarCircleBody;
    JSTileMap *myLevel;
    SKNode *myWorld;
    SKCameraNode *myCamera;
    BOOL fixedCamera;
    BOOL waitForTap;
    BOOL moveLeftRequested;
    BOOL moveRightRequested;
    BOOL moveUpRequested;
    BOOL stopRequested;
    BOOL gonnaCrash;
    BOOL moveLeft;
    BOOL moveRight;
    BOOL willLoseContextVelocity;
    BOOL listensToContactEvents;
    int deathCount;
    int globalCounter;
    float EdgarVelocity;
    CGPoint startPosition;
    SKSpriteNode *myFinishRectangle;
    int nextLevelIndex;
    SKAction *bougeDroite;
    SKAction *bougeGauche;
    SKAction *bougeGauche2;
    SKAction *bougeDroite2;
    SKAction *moveUp;
    SKAction *stoppe;
    CGPoint touchStartPosition;
    BOOL isJumping;
    BOOL ignoreNextTap;
}

-(void)loadAssets:(JSTileMap*) tileMap;
-(void)addStoneBlocks:(JSTileMap*) tileMap;
-(void)EdgarDiesOf:(int)deathType;
-(void)resetEdgar;
-(void)getsPaused;
-(void)resumeAfterPause;


@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) SKAction *hopSound;
@property (strong, nonatomic) SKAction *sgroSound;
//@property (nonatomic) float contextVelocityX;

@end
