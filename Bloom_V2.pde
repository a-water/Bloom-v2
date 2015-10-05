import SimpleOpenNI.*;
import processing.opengl.*;
import java.util.Iterator;

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

int kinectWidth = 640;
int kinectHeight = 480;

PImage cam, blobs;

int NUM_FLOW_PARTICLES = 2200;
int NUM_INITIAL_SEEDS = 30;

String[] palettes = {
	"-1117720,-13683658,-8410437,-9998215,-1849945,-5517090,-4250587,-14178341,-5804972,-3498634",
	"-67879,-9633503,-8858441,-144382,-4996094,-16604779,-588031",
	"-16711663,-13888933,-9029017,-5213092,-1787063,-11375744,-2167516,-15713402,-5389468,-2064585"
};

void setup() {
	size(displayWidth/2, displayHeight/2);

	//  strokeWeight(3);
	//  smooth();  

	// Init seed particles
	seedParticles = new ArrayList<SeedParticle>();
	for(int i=0; i<NUM_INITIAL_SEEDS; i++) {
		seedParticles.add(new SeedParticle());
	}

	// Init Kinect things
	context = new SimpleOpenNI(this);
	if(context.isInit() == false) {
		println("Can't init SimpleOpenNI, maybe the camera is not connected?");
		exit();
		return;  
	}

	// enable depthMap generation 
	context.enableDepth();

	// enable skeleton generation for all joints
	context.enableUser();

	// mirror the kinect to be more naturl
	// context.setMirror(true);
}

void draw() {
	// DEBUG
	frame.setTitle(str((int)frameRate));
 
	background(27, 20, 49);

	// Update seed particles and check for collisions 
	for(int i=0; i<seedParticles.size(); i++) {
		seedParticles.get(i).update();
		for(int x=0; x<seedParticles.size(); x++) {
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
	cam = context.userImage();
	int[] depthValues = context.depthMap();
	int[] userMap = null;

	for(int i=0; i<userList.length; i++) {
		if(context.isTrackingSkeleton(userList[i])) {
			drawSkeleton(userList[i]);
		}
	}

}

void drawSkeleton(int userId) { 

	ArrayList<BodyParticle> bodyParticles = getBodyParticlesForUser(userId);

	Iterator<BodyParticle> x = bodyParticles.iterator();
	while(x.hasNext()) {

		BodyParticle particle = x.next();
		particle.draw();

		// Loop through seeds and check for collison with users body particles
		for(int i=0; i<seedParticles.size(); i++) {

			if(particle.checkForCollision(seedParticles.get(i))) {
				seedParticles.remove(i);
			}
		}
	}


	// // Draw Head
	// PVector jointPos = new PVector();
	// context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_HEAD, jointPos);
	//  // println(jointPos.x);
	//  // println(jointPos.y);

	// // convert real world point to projective space
	// PVector jointPos_Proj = new PVector(); 
	// context.convertRealWorldToProjective(jointPos, jointPos_Proj);

	// // a 200 pixel diameter head
	// float headsize = 200;

	// // create a distance scalar related to the depth (z dimension)
	// float distanceScalar = (525/jointPos_Proj.z);

	// // set the fill color to make the circle green
	// fill(255, 255, 255); 

	// BodyParticle headParticle = new BodyParticle(jointPos_Proj.x,jointPos_Proj.y, distanceScalar*headsize, distanceScalar*headsize);
	// headParticle.draw();

	// draw all limbs  
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

ArrayList<BodyParticle> getBodyParticlesForUser(int userId) {

	ArrayList<Integer> bodyPartsList = new ArrayList<Integer>();
	bodyPartsList.add(SimpleOpenNI.SKEL_HEAD);
	bodyPartsList.add(SimpleOpenNI.SKEL_NECK);
	bodyPartsList.add(SimpleOpenNI.SKEL_LEFT_SHOULDER);
	bodyPartsList.add(SimpleOpenNI.SKEL_LEFT_ELBOW);
	bodyPartsList.add(SimpleOpenNI.SKEL_LEFT_HAND);
	bodyPartsList.add(SimpleOpenNI.SKEL_RIGHT_SHOULDER);
	bodyPartsList.add(SimpleOpenNI.SKEL_RIGHT_ELBOW);
	bodyPartsList.add(SimpleOpenNI.SKEL_RIGHT_HAND);
	bodyPartsList.add(SimpleOpenNI.SKEL_TORSO);
	bodyPartsList.add(SimpleOpenNI.SKEL_LEFT_HIP);
	bodyPartsList.add(SimpleOpenNI.SKEL_LEFT_KNEE);
	bodyPartsList.add(SimpleOpenNI.SKEL_LEFT_FOOT);
	bodyPartsList.add(SimpleOpenNI.SKEL_RIGHT_HIP);
	bodyPartsList.add(SimpleOpenNI.SKEL_RIGHT_KNEE);
	bodyPartsList.add(SimpleOpenNI.SKEL_RIGHT_FOOT);

	ArrayList<BodyParticle> bodyParticles = new ArrayList<BodyParticle>();

	for(int i=0; i<bodyPartsList.size(); i++) {

		PVector jointPosition = new PVector();
		context.getJointPositionSkeleton(userId, bodyPartsList.get(i), jointPosition);

		PVector jointPositionProjective = new PVector(); 
		context.convertRealWorldToProjective(jointPosition, jointPositionProjective);

		float PARTICLE_SIZE = 50;

		// create a distance scalar related to the depth (z dimension)
		float distanceScalar = (525/jointPositionProjective.z);

		fill(255, 255, 255); 

		BodyParticle bodyParticle = new BodyParticle(jointPositionProjective.x, jointPositionProjective.y, distanceScalar*PARTICLE_SIZE, distanceScalar*PARTICLE_SIZE);
		bodyParticles.add(bodyParticle);

	}

	return bodyParticles;
}

void onNewUser(SimpleOpenNI curContext, int userId) {
	println("onNewUser - userId: " + userId);
	println("\tstart tracking skeleton");

	curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId) {
	println("onLostUser - userId: " + userId);
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
	}
}

void keyPressed() {

}
