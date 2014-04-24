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
    
    BOOL span;
    CGFloat length;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        
        background = [SKSpriteNode spriteNodeWithImageNamed:@"Curling_half"];
        background.anchorPoint = CGPointZero;
        background.position = CGPointZero;
        background.zPosition = 1;
        background.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:background.frame];
        // background.physicsBody.friction = 1;
        background.physicsBody.categoryBitMask = PhysicsCategoryBackground;
        background.physicsBody.collisionBitMask = PhysicsCategoryRock;
        [self addChild:background];
        
        rockArray = [[NSMutableArray alloc] initWithCapacity:4];
        
        for (NSUInteger i = 0; i < 4; i++) {
            SKSpriteNode *rock = [SKSpriteNode spriteNodeWithImageNamed:@"rock"];
            rock.position = CGPointMake(162, 155);
            rock.zPosition = 5;
            rock.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:rock.size.width / 2];
            rock.physicsBody.categoryBitMask = PhysicsCategoryRock;
            rock.physicsBody.collisionBitMask = PhysicsCategoryBackground | PhysicsCategoryRock;
            rock.physicsBody.mass = 1;
            rock.physicsBody.friction = 1;
            
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
    
    if (CGRectContainsPoint(currentRock.frame, touchLocation)) {
        NSLog(@"touch");
        span = YES;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (span) {
        CGPoint touchLocation = [[touches anyObject] locationInNode:self];
        CGPoint startPosition = CGPointMake(162, 155);
        
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
        if (length > 50) {
            length = 50;
        }
        
        NSLog(@"%i", angleDegs);
        
        // Set new position
        currentRock.position = vectorAdd(startPosition, vectorScalarMult(normalVector, length));
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint vector = vectorSub(CGPointMake(162, 155), currentRock.position);
    
    CGPoint velocity = vectorScalarMult(vector, length);
    
    [currentRock.physicsBody applyImpulse:CGVectorMake(velocity.x, velocity.y)];
    
    span = NO;
    
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
    
    if ([currentRock.physicsBody isResting] && span) {
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

@end
