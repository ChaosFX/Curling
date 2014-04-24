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
    NSMutableArray *rockArray;
    SKSpriteNode *currentRock;
    SKSpriteNode *broom1;
    SKSpriteNode *broom2;
    SKAction *swipe;
    
    BOOL span;
    BOOL rockIsSliding;
    CGFloat length;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        length = 0.0;
        
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        
        background = [SKSpriteNode spriteNodeWithImageNamed:@"Curling_half"];
        background.anchorPoint = CGPointZero;
        background.position = CGPointZero;
        background.zPosition = 1;
        background.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:background.frame];
        background.physicsBody.friction = 0;
        background.physicsBody.categoryBitMask = PhysicsCategoryBackground;
        background.physicsBody.contactTestBitMask = PhysicsCategoryRock;
        background.physicsBody.collisionBitMask = PhysicsCategoryRock;
        [self addChild:background];
        
        rockArray = [[NSMutableArray alloc] initWithCapacity:4];
        
        for (NSUInteger i = 0; i < 4; i++) {
            SKSpriteNode *rock = [SKSpriteNode spriteNodeWithImageNamed:@"rock"];
            rock.name = @"rock";
            rock.position = CGPointMake(162, 350);
            rock.zPosition = 5;
            rock.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:rock.size.width / 2];
            rock.physicsBody.categoryBitMask = PhysicsCategoryRock;
            rock.physicsBody.contactTestBitMask = PhysicsCategoryBackground | PhysicsCategoryRock;
            rock.physicsBody.collisionBitMask = PhysicsCategoryBackground | PhysicsCategoryRock;
            rock.physicsBody.usesPreciseCollisionDetection = YES;
            rock.physicsBody.mass = 19.0;
            
            [rockArray addObject:rock];
        }
        
        [self nextRock];
    }
    return self;
}

- (void)nextRock
{
    if ([rockArray count]) {
        currentRock = [rockArray lastObject];
        [background addChild:currentRock];
        [rockArray removeLastObject];
    } else {
        currentRock = nil;
    }
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
        CGPoint startPosition = CGPointMake(162, 400);
        
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
        
        NSLog(@"%i", angleDegs);
        
        // Set new position
        currentRock.position = vectorAdd(startPosition, vectorScalarMult(normalVector, length));
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (rockIsSliding) {
        return;
    }
    CGPoint vector = vectorSub(CGPointMake(162, 400), currentRock.position);
    
    CGPoint velocity = vectorScalarMult(vector, length * 0.1);
    
    [currentRock.physicsBody applyImpulse:CGVectorMake(velocity.x, velocity.y)];
    
    span = NO;
    rockIsSliding = YES;
    
    //[self nextRock];
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
        [self nextRock];
    }
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
    
    NSLog(@"firstbody: %@", firstBody);
    NSLog(@"secondbody: %@", secondBody);
    
    if (collision == (PhysicsCategoryRock | PhysicsCategoryRock)) {
        NSLog(@"Two rocks hit");
    } else if (collision == (PhysicsCategoryRock | PhysicsCategoryBackground)) {
        NSLog(@"rock hits background");
    } else {
        NSLog(@"ERROR");
    }
}

@end
