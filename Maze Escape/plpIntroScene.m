//
//  plpIntroScene.m
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

#import "plpIntroScene.h"

@implementation plpIntroScene

-(id)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        NSLog(@"Init intro scene");
        
        self.size = CGSizeMake(2400, 1200);
        
        SKCameraNode *myCamera = [SKCameraNode node];
        
        self.camera = myCamera;
        [self addChild:myCamera];
        
        SKTextureAtlas *scenesAtlas = [SKTextureAtlas atlasNamed:@"scenes"];

        animationFrames = [NSMutableArray array];
        currentFrame = 0;
        for (int i = 0; i <= 3; i++) {
            NSString *textureName = [NSString stringWithFormat:@"scene1_%02d", i];
            SKTexture *temp = [scenesAtlas textureNamed:textureName];
            [animationFrames addObject: temp];
        }
        
        SKSpriteNode *upperCurtain = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(2400, 750) ];
        SKSpriteNode *lowerCurtain = [upperCurtain copy];
        upperCurtain.anchorPoint = CGPointMake(0.5, 0);
        upperCurtain.position = CGPointMake(0, self.size.height/2);
        upperCurtain.zPosition = 40;
        upperCurtain.name = @"upperCurtain";
        
        lowerCurtain.anchorPoint = CGPointMake(0.5, 1);
        lowerCurtain.position = CGPointMake(0, -self.size.height/2);
        lowerCurtain.zPosition = 40;
        lowerCurtain.name = @"lowerCurtain";
        [myCamera addChild:upperCurtain];
        [myCamera addChild:lowerCurtain];
        
        SKAction *openupperCurtain = [SKAction moveToY:600 duration: .5];
        SKAction *openlowerCurtain = [SKAction moveToY:-600 duration: .5];
        SKAction *openCurtainsAnimation = [SKAction runBlock:^{
            [upperCurtain runAction: openupperCurtain];
            [lowerCurtain runAction: openlowerCurtain completion:^{
                [self playScene1];
            }];
        }];
        
        [self runAction: openCurtainsAnimation];
    }
    return self;
}

-(void)playScene1{
    animationNode = [[SKSpriteNode alloc] initWithTexture: animationFrames[0]];
    if (animationNode) {
        NSLog(@"animationNode created");
        animationNode.size = CGSizeMake(2400, 1200);
        animationNode.position = CGPointMake(0, 0);
        animationNode.zPosition = 20;
        [self addChild: animationNode];
        
        SKShapeNode *labelBackground = [SKShapeNode shapeNodeWithRectOfSize: CGSizeMake( 2400, 200) ];
        [labelBackground setStrokeColor: [UIColor blackColor] ];
        [labelBackground setFillColor: [UIColor blackColor] ];
        [labelBackground setPosition: CGPointMake(0, -400)];
        [labelBackground setZPosition: 40];
        [labelBackground setName: @"subtitle-background"];
        [self addChild: labelBackground];
        
        subtitleNodeTop = [SKLabelNode labelNodeWithFontNamed:@"GillSans"];
        subtitleNodeTop.fontSize = 76;
        subtitleNodeTop.fontColor = [SKColor whiteColor];
        subtitleNodeTop.position = CGPointMake(0, 20);
        subtitleNodeTop.zPosition = 42;
        subtitleNodeTop.text = @"Aliens experiments have been";
        [labelBackground addChild: subtitleNodeTop];
        
        subtitleNodeBottom = [SKLabelNode labelNodeWithFontNamed:@"GillSans"];
        subtitleNodeBottom.fontSize = 76;
        subtitleNodeBottom.fontColor = [SKColor whiteColor];
        subtitleNodeBottom.position = CGPointMake(0, -70);
        subtitleNodeBottom.zPosition = 42;
        subtitleNodeBottom.text = @"forbidden for years.";
        [labelBackground addChild: subtitleNodeBottom];
    }
}

-(void)playScene2{
    SKVideoNode *videoNode = [SKVideoNode videoNodeWithFileNamed:@"introScene2.mov"];
    videoNode.size = CGSizeMake(2400, 1200);
    videoNode.position = CGPointMake(0, 0);
    videoNode.zPosition = 20;
    [self addChild: videoNode];
    [videoNode play];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touch event!");
    currentFrame++;
    if(currentFrame < [animationFrames count]){
        NSLog(@"continue");
        
        NSArray *subtitleTextsTop = @[@"1",
                               @"However, some scientists still keep aliens",
                               @"Green Alien must make sure that Bionic Labs Inc",
                               @"We need someone to infiltrate their laboratories"];
        NSArray *subtitleTextsBottom = @[@"1",
                               @"in cages in the name of science!",
                               @"stops illegals aliens experiments.",
                               @"and collect evidence. Any volonteers?"];
        
        [animationNode setTexture: animationFrames[currentFrame]];
        NSLog(@"%@", subtitleTextsTop[currentFrame]);
        [subtitleNodeTop setText: subtitleTextsTop[currentFrame]];
        [subtitleNodeBottom setText: subtitleTextsBottom[currentFrame]];
    } else if(currentFrame == [animationFrames count]) {
        NSLog(@"create video!");
        [ [self childNodeWithName:@"subtitle-background"] removeFromParent];
        [animationNode removeFromParent];
        [subtitleNodeTop removeFromParent];
        [self playScene2];
    } else {
        NSLog(@"Launch Game");
        SKView *spriteView = (SKView *)self.view;
        SKScene *myScene = [plpMyScene sceneWithSize: spriteView.bounds.size];
        myScene.scaleMode = SKSceneScaleModeAspectFill;
        [spriteView presentScene:myScene];
    }
    
}

@end
