//
//  Scene.m
//  Curling
//
//  Created by Dominik Lingnau on 24.04.14.
//  Copyright (c) 2014 Dominik Lingnau. All rights reserved.
//

#import "Scene.h"
#import "Math.h"

@implementation Scene
{
    NSTimeInterval lastUpdate;
    NSTimeInterval deltaTime;
    
    SKSpriteNode *background;
    NSMutableArray *rockArrayP1;
    NSMutableArray *rockArrayP2;
    SKSpriteNode *currentRock;
    CGPoint startPosition;
    SKSpriteNode *broom1;
    SKSpriteNode *broom2;
    SKAction *swipe;
    
    BOOL turn;
    SKLabelNode *player1Score;
    SKLabelNode *player2Score;
    
    BOOL span;
    BOOL rockIsSliding;
    CGFloat length;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        length = 0.0;
        turn = YES;
        startPosition = CGPointMake(162, 270);
        
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        
        background = [SKSpriteNode spriteNodeWithImageNamed:@"Curling_half"];
        background.anchorPoint = CGPointZero;
        background.position = CGPointZero;
        background.zPosition = 1;
        background.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:background.frame];
        background.physicsBody.categoryBitMask = PhysicsCategoryBackground;
        background.physicsBody.contactTestBitMask = PhysicsCategoryRock;
        background.physicsBody.collisionBitMask = PhysicsCategoryRock;
        [self addChild:background];
        
        [self createHUD];
        
        rockArrayP1 = [[NSMutableArray alloc] initWithCapacity:4];
        rockArrayP2 = [[NSMutableArray alloc] initWithCapacity:4];

        [self createRocksForPlayer:1 inArray:rockArrayP1];
        [self createRocksForPlayer:2 inArray:rockArrayP2];
        
        [self nextRock];
    }
    
    return self;
}

- (void)createHUD
{
    player1Score = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    player1Score.position = CGPointMake(10, 460);
    player1Score.fontSize = 20;
    player1Score.fontColor = [SKColor blueColor];
    player1Score.text = @"0";
    player1Score.zPosition = 2;
    [self addChild:player1Score];
    
    player2Score = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    player2Score.position = CGPointMake(310, 460);
    player2Score.fontSize = 20;
    player2Score.fontColor = [SKColor redColor];
    player2Score.text = @"0";
    player2Score.zPosition = 2;
    [self addChild:player2Score];
    
}

- (void)createRocksForPlayer:(int)player inArray:(NSMutableArray *)array
{
    
    for (NSUInteger i = 0; i < 4; i++) {
        SKSpriteNode *rock = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"rock%d", player]];
        rock.name = [NSString stringWithFormat:@"rock%d", player];
        rock.position = startPosition;
        rock.zPosition = 5;
        rock.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:rock.size.width / 2];
        rock.physicsBody.categoryBitMask = PhysicsCategoryRock;
        rock.physicsBody.contactTestBitMask = PhysicsCategoryBackground | PhysicsCategoryRock;
        rock.physicsBody.collisionBitMask = PhysicsCategoryBackground | PhysicsCategoryRock;
        rock.physicsBody.usesPreciseCollisionDetection = YES;
        rock.physicsBody.mass = 19.0;
        
        [array addObject:rock];
    }
}

- (void)nextRock
{
    if ([rockArrayP1 count] && turn) {
        currentRock = [rockArrayP1 lastObject];
        [background addChild:currentRock];
        [rockArrayP1 removeLastObject];
    } else if ([rockArrayP2 count] && !turn) {
        currentRock = [rockArrayP2 lastObject];
        [background addChild:currentRock];
        [rockArrayP2 removeLastObject];
    } else {
        // currentRock = nil;
        [self countPoint];
    }
    
    turn = !turn;
}

- (void)countPoint
{
    static int scoreP1 = 0;
    static int scoreP2 = 0;
    [background enumerateChildNodesWithName:@"rock1" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y > 1300) {
            scoreP1 += 1;
            [player1Score setText:[NSString stringWithFormat:@"%i", scoreP1]];
        }
    }];
    [background enumerateChildNodesWithName:@"rock2" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y > 1300) {
            scoreP2 += 1;
            [player2Score setText:[NSString stringWithFormat:@"%i", scoreP2]];
        }
    }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    CGPoint touchLocation = [[touches anyObject] locationInNode:background];
    
    if (!rockIsSliding && CGRectContainsPoint(currentRock.frame, touchLocation)) {
        NSLog(@"touch");
        span = YES;
    } else {
        span = NO;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (span && !rockIsSliding) {
        CGPoint touchLocation = [[touches anyObject] locationInNode:self];
        
        // Rechne Vektor, Winkel, Länge und normalisierten Vektor
        CGPoint vector = vectorSub(touchLocation, startPosition);
        CGPoint normalVector = vectorNorm(vector);
        CGFloat angleRads = vectorAngle(normalVector);
        int angleDegs = (int)radiansToDegrees(angleRads);
        length = vectorLength(vector);
        
        while (angleDegs < 0) {
            angleDegs += 360;
        }
        
        // Limit für die Länge
        if (length > 200) {
            length = 200;
        }
        
        // NSLog(@"%i", angleDegs);
        
        // Set new position
        currentRock.position = vectorAdd(startPosition, vectorScalarMult(normalVector, length));
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (rockIsSliding) {
        NSLog(@"swipe");
        SKAction *broomSweep = [SKAction playSoundFileNamed:@"broom-sweep-1.wav" waitForCompletion:NO];
        [self runAction:broomSweep];
        return;
    }
    CGPoint vector = vectorSub(startPosition, currentRock.position);
    
    CGPoint velocity = vectorScalarMult(vector, length * 0.2);
    
    [currentRock.physicsBody applyImpulse:CGVectorMake(velocity.x, velocity.y)];
    
    span = NO;
    rockIsSliding = YES;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    deltaTime = currentTime - lastUpdate;
    if (deltaTime > 0.02) {
        deltaTime = 0.02;
    }
    lastUpdate = currentTime;
    
    [self centerViewpoint:currentRock.position];
    
    if ([currentRock.physicsBody isResting] && rockIsSliding) {
        rockIsSliding = NO;
        [self deleteOutOfBounceRocks];
        [self nextRock];
    }
}

- (void)deleteOutOfBounceRocks
{
    // SKAction *fadeOut = [SKAction fadeOutWithDuration:0.5];
    SKAction *remove = [SKAction removeFromParent];
    // SKAction *fadeRemove = [SKAction sequence:@[fadeOut, remove]];
    
    [background enumerateChildNodesWithName:@"rock1" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y < 1000 || node.position.y > 1650) {
            NSLog(@"%@ out of Bounce", node);
            
            [node runAction:remove];
        }
    }];
    [background enumerateChildNodesWithName:@"rock2" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y < 1000 || node.position.y > 1650) {
            NSLog(@"%@ out of Bounce", node);
            
            [node runAction:remove];
        }
    }];
}

- (void)centerViewpoint:(CGPoint)position
{
    NSInteger x = MAX(position.x, self.size.width / 2);
    NSInteger y = MAX(position.y, self.size.height / 2);
    x = MIN(x, background.size.width - self.size.width / 2);
    y = MIN(y, background.size.height - self.size.height / 2);
    
    CGPoint actualPosition = CGPointMake(x, y);
    CGPoint centerOfView = CGPointMake(self.size.width / 2, self.size.height / 2);
    CGPoint viewPoint = vectorSub(centerOfView, actualPosition);
    background.position = viewPoint;
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKNode *firstBody = contact.bodyA.node;
    SKNode *secondBody = contact.bodyB.node;
    
    uint32_t collision = firstBody.physicsBody.categoryBitMask | secondBody.physicsBody.categoryBitMask;
    
    // NSLog(@"firstbody: %@", firstBody);
    // NSLog(@"secondbody: %@", secondBody);
    
    if (collision == (PhysicsCategoryRock | PhysicsCategoryRock)) {
        NSLog(@"Two rocks hit");
    } else if (collision == (PhysicsCategoryRock | PhysicsCategoryBackground)) {
        NSLog(@"rock hits the Wall");
    } else {
        NSLog(@"ERROR");
    }
}

@end
