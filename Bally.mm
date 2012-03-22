//
//  Bally.mm
//  Bally
//
//  Created by Saida Memon on 3/8/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// Import the interfaces
#import "Bally.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

// enums that will be used as tags
enum {
	kTagTileMap = 1,
	kTagBatchNode = 1,
	kTagAnimation1 = 1,
};


// Bally implementation
@implementation Bally

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	Bally *layer = [Bally node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}
/*
 // on "init" you need to initialize your instance
 -(id) init
 {
 // always call "super" init
 // Apple recommends to re-assign "self" with the "super" return value
 if( (self=[super init])) {
 
 // enable touches
 self.isTouchEnabled = YES;
 
 // enable accelerometer
 self.isAccelerometerEnabled = YES;
 
 CGSize screenSize = [CCDirector sharedDirector].winSize;
 CCLOG(@"Screen width %0.2f screen height %0.2f",screenSize.width,screenSize.height);
 
 // Define the gravity vector.
 b2Vec2 gravity;
 gravity.Set(0.0f, -10.0f);
 
 // Do we want to let bodies sleep?
 // This will speed up the physics simulation
 bool doSleep = true;
 
 // Construct a world object, which will hold and simulate the rigid bodies.
 world = new b2World(gravity, doSleep);
 
 world->SetContinuousPhysics(true);
 
 // Debug Draw functions
 m_debugDraw = new GLESDebugDraw( PTM_RATIO );
 world->SetDebugDraw(m_debugDraw);
 
 uint32 flags = 0;
 flags += b2DebugDraw::e_shapeBit;
 //		flags += b2DebugDraw::e_jointBit;
 //		flags += b2DebugDraw::e_aabbBit;
 //		flags += b2DebugDraw::e_pairBit;
 //		flags += b2DebugDraw::e_centerOfMassBit;
 m_debugDraw->SetFlags(flags);		
 
 
 // Define the ground body.
 b2BodyDef groundBodyDef;
 groundBodyDef.position.Set(0, 0); // bottom-left corner
 
 // Call the body factory which allocates memory for the ground body
 // from a pool and creates the ground box shape (also from a pool).
 // The body is also added to the world.
 b2Body* groundBody = world->CreateBody(&groundBodyDef);
 
 // Define the ground box shape.
 b2PolygonShape groundBox;		
 
 // bottom
 groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(screenSize.width/PTM_RATIO,0));
 groundBody->CreateFixture(&groundBox,0);
 
 // top
 groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO));
 groundBody->CreateFixture(&groundBox,0);
 
 // left
 groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(0,0));
 groundBody->CreateFixture(&groundBox,0);
 
 // right
 groundBox.SetAsEdge(b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,0));
 groundBody->CreateFixture(&groundBox,0);
 
 
 //Set up sprite
 
 CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"blocks.png" capacity:150];
 [self addChild:batch z:0 tag:kTagBatchNode];
 
 [self addNewSpriteWithCoords:ccp(screenSize.width/2, screenSize.height/2)];
 
 CCLabelTTF *label = [CCLabelTTF labelWithString:@"Tap screen" fontName:@"Marker Felt" fontSize:32];
 [self addChild:label z:0];
 [label setColor:ccc3(0,0,255)];
 label.position = ccp( screenSize.width/2, screenSize.height-50);
 
 [self schedule: @selector(tick:)];
 }
 return self;
 }
 */

-(id)init

{
    
    if( (self=[super init])) { 
        
        // enable touches
        
        self.isTouchEnabled = YES; 
        
        // enable accelerometer
        
        self.isAccelerometerEnabled = YES; 
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        CCLOG(@"Screen width %0.2f screen height %0.2f",screenSize.width,screenSize.height); 
        
        // Define the gravity vector.
        
        b2Vec2 gravity;
        
        gravity.Set(0.0f, -10.0f); 
        
        // Do we want to let bodies sleep?
        
        // This will speed up the physics simulation
        
        bool doSleep = true; 
        
        // Construct a world object, which will hold and simulate the rigid bodies.
        
        world = new b2World(gravity, doSleep); 
        
        world->SetContinuousPhysics(true); 
        
        // Debug Draw functions
        
        m_debugDraw = new GLESDebugDraw( PTM_RATIO );
        
        world->SetDebugDraw(m_debugDraw); 
        
        uint32 flags = 0;
        
        flags += b2DebugDraw::e_shapeBit;
        
        //  flags += b2DebugDraw::e_jointBit;
        
        //  flags += b2DebugDraw::e_aabbBit;
        
        //  flags += b2DebugDraw::e_pairBit;
        
        //  flags += b2DebugDraw::e_centerOfMassBit;
        
        m_debugDraw->SetFlags(flags);  
        
        b2Body* ground = NULL;
        b2BodyDef bd;
        ground = world->CreateBody(&bd);
        b2BodyDef bodyDef,bodyDef1;
        
        
        bodyDef.type=b2_dynamicBody;
        b2Vec2 initVel;
        b2PolygonShape shape;
        b2CircleShape circleShape;
        b2FixtureDef fd;
        b2RevoluteJointDef revJointDef;
        b2DistanceJointDef jointDef;
        b2Vec2 pos;
        
        //Box
        b2BodyDef groundBodyDef;
        b2Body* groundBody = world->CreateBody(&groundBodyDef);
        
        shape.SetAsEdge(b2Vec2(0.000000f, 0.000000f), b2Vec2(15.000000f, 0.000000f)); //bottom wall
        groundBody->CreateFixture(&shape,0);
        shape.SetAsEdge(b2Vec2(15.000000f, 0.000000f), b2Vec2(15.000000f, 10.000000f)); //right wall
        groundBody->CreateFixture(&shape,0);
        shape.SetAsEdge(b2Vec2(15.000000f, 10.000000f), b2Vec2(0.000000f, 10.000000f)); //top wall
        groundBody->CreateFixture(&shape,0);
        shape.SetAsEdge(b2Vec2(0.000000f, 10.000000f), b2Vec2(0.000000f, 0.000000f)); //;left wall
        groundBody->CreateFixture(&shape,0);
        
        //Polygons
        
        //polygon1
        bodyDef.position.Set(4.764226f, 7.320508f);
        bodyDef.angle = 0.000000f;
        b2Body* polygon1 = world->CreateBody(&bodyDef);
        initVel.Set(0.000000f, 0.000000f);
        polygon1->SetLinearVelocity(initVel);
        polygon1->SetAngularVelocity(0.000000f);
        b2PolygonShape boxy;
        boxy.SetAsBox(1.65f, 0.35f);
        
        fd.shape = &boxy;
        fd.density = 0.015000f;
        fd.friction = 0.300000f;
        fd.restitution = 0.600000f;
        fd.filter.groupIndex = int16(0);
        fd.filter.categoryBits = uint16(65535);
        fd.filter.maskBits = uint16(65535);
        polygon1->CreateFixture(&fd);
        
        boxy.SetAsBox(0.35f,1.65f);
        fd.shape = &boxy;
        fd.density = 0.015000f;
        fd.friction = 0.300000f;
        fd.restitution = 0.600000f;
        fd.filter.groupIndex = int16(0);
        fd.filter.categoryBits = uint16(65535);
        fd.filter.maskBits = uint16(65535);
        polygon1->CreateFixture(&fd);
        
        
        //polygon2
        bodyDef.position.Set(1.779086f, 5.100423f);
        bodyDef.angle = 0.000000f;
        b2Body* polygon2 = world->CreateBody(&bodyDef);
        initVel.Set(0.000000f, 0.000000f);
        polygon2->SetLinearVelocity(initVel);
        polygon2->SetAngularVelocity(0.000000f);
        //b2PolygonShape boxy;
        boxy.SetAsBox(1.65f, 0.35f);
        
        fd.shape = &boxy;
        fd.density = 0.015000f;
        fd.friction = 0.300000f;
        fd.restitution = 0.600000f;
        fd.filter.groupIndex = int16(0);
        fd.filter.categoryBits = uint16(65535);
        fd.filter.maskBits = uint16(65535);
        polygon2->CreateFixture(&fd);
        
        boxy.SetAsBox(0.35f,1.65f);
        fd.shape = &boxy;
        fd.density = 0.015000f;
        fd.friction = 0.300000f;
        fd.restitution = 0.600000f;
        fd.filter.groupIndex = int16(0);
        fd.filter.categoryBits = uint16(65535);
        fd.filter.maskBits = uint16(65535);
        polygon2->CreateFixture(&fd);    
        
        
        //staticBody1
        bodyDef1.position.Set(1.379107f, 8.495184f);
        bodyDef1.angle = -0.222508f;
        b2Body* staticBody1 = world->CreateBody(&bodyDef1);
        initVel.Set(0.000000f, 0.000000f);
        staticBody1->SetLinearVelocity(initVel);
        staticBody1->SetAngularVelocity(0.000000f);
        boxy.SetAsBox(1.35f, 0.20f);
        fd.shape = &boxy;
        fd.density = 0.015000f;
        fd.friction = 0.300000f;
        fd.restitution = 0.600000f;
        fd.filter.groupIndex = int16(0);
        fd.filter.categoryBits = uint16(65535);
        fd.filter.maskBits = uint16(65535);        
        staticBody1->CreateFixture(&boxy,0);
        
        //staticBody2
        
        bodyDef1.position.Set(5.946951f, 2.903825f);
        bodyDef1.angle = -0.025254f;
        b2Body* staticBody2 = world->CreateBody(&bodyDef1);
        /*   
         //this adds a ball at the end but change the vertices to 0, 6 from -3 and 3 to make it go at the end
         circleShape.m_radius = 0.406489f;
         fd.shape = &circleShape;
         fd.density = 0.196374f;
         fd.friction = 0.300000f;
         fd.restitution = 0.600000f;
         staticBody2->CreateFixture(&fd);
         */ 
        initVel.Set(0.000000f, 0.000000f);
        staticBody2->SetLinearVelocity(initVel);
        staticBody2->SetAngularVelocity(0.000000f);
        b2Vec2 staticBody2_vertices[4];
        staticBody2_vertices[0].Set(-3.053178f, -0.361702f);
        staticBody2_vertices[1].Set(3.053178f, -0.361702f);
        staticBody2_vertices[2].Set(3.053178f, 0.361702f);
        staticBody2_vertices[3].Set(-3.053178f, 0.361702f);
        shape.Set(staticBody2_vertices, 4);
        fd.shape = &shape;
        fd.density = 0.015000f;
        fd.friction = 0.300000f;
        fd.restitution = 0.600000f;
        fd.filter.groupIndex = int16(0);
        fd.filter.categoryBits = uint16(65535);
        fd.filter.maskBits = uint16(65535);
        staticBody2->CreateFixture(&shape,0);
        
        //staticBody3
        bodyDef1.position.Set(8.670213f, 1.212766f);
        bodyDef1.angle = -0.507438f;
        b2Body* staticBody3 = world->CreateBody(&bodyDef1);
        initVel.Set(0.000000f, 0.000000f);
        staticBody3->SetLinearVelocity(initVel);
        staticBody3->SetAngularVelocity(0.000000f);
        b2Vec2 staticBody3_vertices[4];
        staticBody3_vertices[0].Set(-1.521277f, -0.382979f);
        staticBody3_vertices[1].Set(1.521277f, -0.382979f);
        staticBody3_vertices[2].Set(1.521277f, 0.382979f);
        staticBody3_vertices[3].Set(-1.521277f, 0.382979f);
        shape.Set(staticBody3_vertices, 4);
        fd.shape = &shape;
        fd.density = 0.015000f;
        fd.friction = 0.300000f;
        fd.restitution = 0.600000f;
        fd.filter.groupIndex = int16(0);
        fd.filter.categoryBits = uint16(65535);
        fd.filter.maskBits = uint16(65535);
        staticBody3->CreateFixture(&shape,0);
        
        //staticBody4
        bodyDef1.position.Set(11.574468f, 2.851064f);
        bodyDef1.angle = 0.020196f;
        b2Body* staticBody4 = world->CreateBody(&bodyDef1);
        initVel.Set(0.000000f, 0.000000f);
        staticBody4->SetLinearVelocity(initVel);
        staticBody4->SetAngularVelocity(0.000000f);
        b2Vec2 staticBody4_vertices[4];
        staticBody4_vertices[0].Set(-1.723404f, -0.404255f);
        staticBody4_vertices[1].Set(1.723404f, -0.404255f);
        staticBody4_vertices[2].Set(1.723404f, 0.404255f);
        staticBody4_vertices[3].Set(-1.723404f, 0.404255f);
        shape.Set(staticBody4_vertices, 4);
        fd.shape = &shape;
        fd.density = 0.015000f;
        fd.friction = 0.300000f;
        fd.restitution = 0.600000f;
        fd.filter.groupIndex = int16(0);
        fd.filter.categoryBits = uint16(65535);
        fd.filter.maskBits = uint16(65535);
        staticBody4->CreateFixture(&shape,0);
        
        //block
        bodyDef.position.Set(11.914894f, 0.882979f);
        bodyDef.angle = 0.000000f;
        
        // bodyDef.userData=blockSprite;
        b2Body* block = world->CreateBody(&bodyDef);
        initVel.Set(0.000000f, 0.000000f);
        block->SetLinearVelocity(initVel);
        block->SetAngularVelocity(0.000000f);
        b2Vec2 block_vertices[4];
        block_vertices[0].Set(-0.851064f, -0.840426f);
        block_vertices[1].Set(0.851064f, -0.840426f);
        block_vertices[2].Set(0.851064f, 0.840426f);
        block_vertices[3].Set(-0.851064f, 0.840426f);
        shape.Set(block_vertices, 4);
        fd.shape = &shape;
        fd.density = 0.015000f;
        fd.friction = 0.300000f;
        fd.restitution = 0.600000f;
        fd.filter.groupIndex = int16(0);
        fd.filter.categoryBits = uint16(65535);
        fd.filter.maskBits = uint16(65535);
        block->CreateFixture(&fd);
        
        //Circles
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"rolly.plist"];
        CCSpriteBatchNode*  spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"rolly.png"];
        [self addChild:spriteSheet];
        
        //circle1
        CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"ball.png"];
        sprite.position = ccp(480.0f/2, 50/PTM_RATIO);
        [self addChild:sprite z:-11 tag:11];
        bodyDef.userData = sprite;
        bodyDef.position.Set(0.468085f, 9.574468f);
        bodyDef.angle = 0.000000f;
        b2Body* circle1 = world->CreateBody(&bodyDef);
        initVel.Set(0.000000f, 0.000000f);
        circle1->SetLinearVelocity(initVel);
        circle1->SetAngularVelocity(0.000000f);
        //circleShape.m_radius = 0.406489f;
        circleShape.m_radius = (sprite.contentSize.width / 32.0) * 0.5f;
        fd.shape = &circleShape;
        fd.density = 0.196374f;
        fd.friction = 0.300000f;
        fd.restitution = 0.600000f;
        fd.filter.groupIndex = int16(0);
        fd.filter.categoryBits = uint16(65535);
        fd.filter.maskBits = uint16(65535);
        circle1->CreateFixture(&fd);
        
        
        //circle2
        bodyDef.position.Set(9.361702f, 4.276596f);
        bodyDef.angle = 0.000000f;
        b2Body* circle2 = world->CreateBody(&bodyDef);
        initVel.Set(0.000000f, 0.000000f);
        circle2->SetLinearVelocity(initVel);
        circle2->SetAngularVelocity(0.000000f);
        circleShape.m_radius = 1.175038f;
        fd.shape = &circleShape;
        fd.density = 0.015000f;
        fd.friction = 0.300000f;
        fd.restitution = 0.600000f;
        fd.filter.groupIndex = int16(0);
        fd.filter.categoryBits = uint16(65535);
        fd.filter.maskBits = uint16(65535);
        circle2->CreateFixture(&fd);
        
        
        //Revolute joints
        
        pos.Set(4.764226f, 7.320508f);
        revJointDef.Initialize(polygon1, ground, pos);
        revJointDef.collideConnected = false;
        world->CreateJoint(&revJointDef);
        pos.Set(1.779086f, 5.100423f);
        revJointDef.Initialize(polygon2, ground, pos);
        revJointDef.collideConnected = false;
        world->CreateJoint(&revJointDef); 
        
        //Hole
        bodyDef.position.Set(480.0f/2/PTM_RATIO, 6.574468f);
        bodyDef.angle = 0.000000f;
        bodyDef.type = b2_staticBody;
        circle1 = world->CreateBody(&bodyDef);
        initVel.Set(0.000000f, 0.000000f);
        circle1->SetLinearVelocity(initVel);
        circle1->SetAngularVelocity(0.000000f);
        circleShape.m_radius = 0.406489f;
        fd.shape = &circleShape;
        fd.density = 0.196374f;
        fd.friction = 0.300000f;
        fd.restitution = 0.600000f;
        fd.filter.groupIndex = int16(0);
        fd.filter.categoryBits = uint16(65535);
        fd.filter.maskBits = uint16(65535);
        circle1->CreateFixture(&fd);
        
        
        [self schedule: @selector(tick:)]; 
        
    }
    
    return self; 
    
}


-(void) draw
{
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	world->DrawDebugData();
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
}

-(void) addNewSpriteWithCoords:(CGPoint)p
{
	CCLOG(@"Add sprite %0.2f x %02.f",p.x,p.y);
	CCSpriteBatchNode *batch = (CCSpriteBatchNode*) [self getChildByTag:kTagBatchNode];
	
	//We have a 64x64 sprite sheet with 4 different 32x32 images.  The following code is
	//just randomly picking one of the images
	int idx = (CCRANDOM_0_1() > .5 ? 0:1);
	int idy = (CCRANDOM_0_1() > .5 ? 0:1);
	CCSprite *sprite = [CCSprite spriteWithBatchNode:batch rect:CGRectMake(32 * idx,32 * idy,32,32)];
	[batch addChild:sprite];
	
	sprite.position = ccp( p.x, p.y);
	
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
    
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	bodyDef.userData = sprite;
	b2Body *body = world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox(.5f, .5f);//These are mid points for our 1m box
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;	
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
	body->CreateFixture(&fixtureDef);
}



-(void) tick: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);
    
	
	//Iterate over the bodies in the physics world
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			CCSprite *myActor = (CCSprite*)b->GetUserData();
			myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
			myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
		}	
	}
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
		
		[self addNewSpriteWithCoords: location];
	}
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
	static float prevX=0, prevY=0;
	
	//#define kFilterFactor 0.05f
#define kFilterFactor 1.0f	// don't use filter. the code is here just as an example
	
	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
	prevX = accelX;
	prevY = accelY;
	
	// accelerometer values are in "Portrait" mode. Change them to Landscape left
	// multiply the gravity by 10
	b2Vec2 gravity( -accelY * 10, accelX * 10);
	
	world->SetGravity( gravity );
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	delete world;
	world = NULL;
	
	delete m_debugDraw;
    
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
