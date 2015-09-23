import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import SimpleOpenNI.*; 
import processing.opengl.*; 
import blobDetection.*; 
import java.awt.Polygon; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Bloom_v2 extends PApplet {







SimpleOpenNI context;
int[] userClr = new int[] { 
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

public void setup() {
	size(640, 480);
	background(0, 0, 0);
  	// strokeWeight(3);
  	smooth();  

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
  	context.enableDepth();

  	// enable skeleton generation for all joints
  	context.enableUser();
  }

  public void draw(){
  	background(0);
  	frame.setTitle(str((int)frameRate));

	// Update Kinect
	context.update(); 

	// Draw to an image what the camera data is seeing
	// image(context.userImage(),0,0);

	int[] userList = context.getUsers();
	for(int i=0; i<userList.length; i++){
		if(context.isTrackingSkeleton(userList[i])){
			// stroke(userClr[ (userList[i] - 1) % userClr.length ] );
			drawSkeleton(userList[i]);
		}      

	// draw the center of mass
	//    if(context.getCoM(userList[i],com))
	//    {
	//      context.convertRealWorldToProjective(com,com2d);
	//      stroke(100,255,0);
	//      strokeWeight(1);
	//      beginShape(LINES);
	//        vertex(com2d.x,com2d.y - 5);
	//        vertex(com2d.x,com2d.y + 5);
	//
	//        vertex(com2d.x - 5,com2d.y);
	//        vertex(com2d.x + 5,com2d.y);
	//      endShape();
	//      
	//      fill(0,255,100);
	//      text(Integer.toString(userList[i]),com2d.x,com2d.y);
	//    }
	}

	// Update seed particles and check for collisions 
	for(int i=0; i<10; i++) {
		seedParticles.get(i).update();
		for(int x=0; x<10; x++) {
			if(i != x) {
				seedParticles.get(i).checkForCollision(seedParticles.get(x));
			}
		}
	}

	for(int k=0; k<10; k++) {
		seedParticles.get(k).draw();
	}
}

public void drawSkeleton(int userId){ 
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
  // context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  // context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  // context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  // context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  // context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  // context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  // context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  // context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  // context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  // context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  // context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  // context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  // context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  // context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  // context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);  
  
}

public void onNewUser(SimpleOpenNI curContext, int userId){
	println("onNewUser - userId: " + userId);
	println("\tstart tracking skeleton");

	curContext.startTrackingSkeleton(userId);
}

public void keyPressed(){

}
class SeedParticle {

	private int speedX;
	private int speedY;
	public PVector vector;
	private final int SEED_RADIUS = 5;

	SeedParticle() {

		vector = new PVector(random(width), random(height));
		speedX = (int)random(1, 5);
		speedY = (int)random(1, 5);

	}

	public void update() {
		vector.x = vector.x + speedX;
		vector.y = vector.y + speedY;

		// Check Y values for the seed
		if(vector.y > height-SEED_RADIUS) {
			vector.y = height-SEED_RADIUS;
			speedY = speedY * -1;
		}

		if (vector.y < SEED_RADIUS) {
			vector.y = SEED_RADIUS;
			speedY = speedY * -1;
		}

		// Check X values for the seed
		if(vector.x > width-SEED_RADIUS){
			vector.x = width-SEED_RADIUS;
			speedX = speedX * -1;
		}

		if (vector.x < SEED_RADIUS) {
			vector.x = SEED_RADIUS;
			speedX = speedX * -1;
		}
	}

	public void draw() {
		ellipse(vector.x, vector.y, SEED_RADIUS, SEED_RADIUS);
	} 

	public void checkForCollision(SeedParticle seed) {

		if(dist(seed.vector.x, seed.vector.y, vector.x, vector.y) < SEED_RADIUS * 2) {
			speedX *= -1;
			speedY *= -1;
			println("COLLISION DETECTED!");  
		}
	}
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--hide-stop", "Bloom_v2" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
