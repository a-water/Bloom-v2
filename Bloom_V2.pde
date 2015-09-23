import SimpleOpenNI.*;
import processing.opengl.*;
import blobDetection.*;
import java.awt.Polygon;

SimpleOpenNI context;

color[] userClr = new color[] { 
	color(255,0,0),
	color(0,255,0),
	color(0,0,255),
	color(255,255,0),
	color(255,0,255),
	color(0,255,255)
};

PVector com = new PVector();                                   
PVector com2d = new PVector();  
ArrayList <SeedParticle> seedParticles;

// Experimental
float globalX, globalY, reScale;

int kinectWidth;
int kinectHeight;

PImage cam, blobs;

int NUM_FLOW_PARTICLES = 2200;

String[] palettes = {
	"-1117720,-13683658,-8410437,-9998215,-1849945,-5517090,-4250587,-14178341,-5804972,-3498634",
	"-67879,-9633503,-8858441,-144382,-4996094,-16604779,-588031",
	"-16711663,-13888933,-9029017,-5213092,-1787063,-11375744,-2167516,-15713402,-5389468,-2064585"
};

FlowParticle[] flowParticles = new FlowParticle[NUM_FLOW_PARTICLES];
PolygonBlob poly = new PolygonBlob();
BlobDetection blobDetection;


void setup() {
	size(displayWidth, displayHeight);
	background(0);

	kinectWidth = width;
	kinectHeight = height;
	//  strokeWeight(3);
	//  smooth();  

	// Init seed particles
	seedParticles = new ArrayList<SeedParticle>();
	for(int i=0; i<10; i++) {
		seedParticles.add(new SeedParticle());
	}

	// Init Kinect things
	context = new SimpleOpenNI(this);
	if(context.isInit() == false) {
		println("Can't init SimpleOpenNI, maybe the camera is not connected!");
		exit();
		return;  
	}

	// enable depthMap generation 
	// context.enableDepth();

	// enable skeleton generation for all joints
	context.enableUser();

	// Experimental
	blobs = createImage(width, height, RGB);
	blobDetection = new BlobDetection(blobs.width, blobs.height);
	blobDetection.setThreshold(0.2);
	reScale = (float) width/kinectWidth;
	setupFlowField();
}

void draw() {
	// DEBUG
	frame.setTitle(str((int)frameRate));
 
	background(0);

	// Update seed particles and check for collisions 
	for(int i=0; i<10; i++) {
		seedParticles.get(i).update();
		for(int x=0; x<10; x++) {
			if(i != x) {
				seedParticles.get(i).checkForCollision(seedParticles.get(x)); 
			}
		}
		seedParticles.get(i).draw();
	}

	// Update Kinect
	context.update(); 

	// Draw to an image what the camera data is seeing
	// image(context.userImage(),0,0);

	int[] userList = context.getUsers();
	cam = createImage(width, height, RGB);
	int[] depthValues = context.depthMap();
	int[] userMap = null;

	for(int i=0; i<userList.length; i++) {
		if(context.isTrackingSkeleton(userList[i])) {
			drawSkeleton(userList[i]);

			userMap = context.userMap();
			cam.loadPixels();

			for(int y=0; y<context.depthHeight(); y++) {
				for(int x=0; x<context.depthWidth(); x++) {
					int index = x + y * context.depthWidth();
					if(userMap != null && userMap[index] > 0) {
						cam.set(x, y, 255);
					}
				}
			}
			cam.updatePixels();      
			// copy the image into the smaller blob image
			blobs.copy(cam, 0, 0, cam.width, cam.height, 0, 0, blobs.width, blobs.height);
			// blur the blob image
			blobs.filter(BLUR);
			// detect the blobs
			blobDetection.computeBlobs(blobs.pixels);
			// clear the polygon (original functionality)
			poly.reset();
			// create the polygon from the blobs (custom functionality, see class)
			poly.createPolygon();
			drawFlowField();
		}
	}

	if(userList.length > 0) {

	}
}

void drawSkeleton(int userId) { 
	// Draw Head
	PVector jointPos = new PVector();
	context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_HEAD, jointPos);
	//  println(jointPos.x);
	//  println(jointPos.y);

	// convert real world point to projective space
	PVector jointPos_Proj = new PVector(); 
	context.convertRealWorldToProjective(jointPos,jointPos_Proj);

	// a 200 pixel diameter head
	float headsize = 200;

	// create a distance scalar related to the depth (z dimension)
	float distanceScalar = (525/jointPos_Proj.z);

	// set the fill colour to make the circle green
	fill(154, 201, 217); 

	// draw the circle at the position of the head with the head size scaled by the distance scalar
	ellipse(jointPos_Proj.x,jointPos_Proj.y, distanceScalar*headsize,distanceScalar*headsize);

  // draw limbs  
//  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
// 
//  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
//  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
//  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
// 
//  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
//  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
//  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
// 
//  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
//  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
// 
//  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
//  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
//  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);
// 
//  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
//  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
//  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);  

}

void onNewUser(SimpleOpenNI curContext, int userId) {
	println("onNewUser - userId: " + userId);
	println("\tstart tracking skeleton");

	curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId) {
	println("onLostUser - userId: " + userId);
}

void setupFlowField() {
	strokeWeight(1);

	// initialize all particles in the flow
	for(int i=0; i< flowParticles.length; i ++) {
		flowParticles[i] = new FlowParticle(i/10000.0);
	}

	setRandomColors(1);
}

void drawFlowField() {
	translate(0, (height-kinectHeight*reScale)/2); 
	scale(reScale);

	globalX = noise(frameCount * 0.01) * width/2 + width/4;
	globalY = noise(frameCount * 0.005 + 5) * height;

	for (FlowParticle p : flowParticles) {
		p.updateAndDisplay();
	}
}

void setRandomColors(int nthFrame) {
	if (frameCount % nthFrame == 0) {
		// turn a palette into a series of strings
		String[] paletteStrings = split(palettes[int(random(palettes.length))], ",");
		
		// turn strings into colors
		color[] colorPalette = new color[paletteStrings.length];
		for (int i=0; i < paletteStrings.length; i ++) {
			colorPalette[i] = int(paletteStrings[i]);
		}

		// set all particle colors randomly to color from palette (excluding first aka background color)
		for (int i=0; i < NUM_FLOW_PARTICLES; i ++) {
			flowParticles[i].col = colorPalette[int(random(1, colorPalette.length))];
		}
	}
}

void keyPressed() {

}
