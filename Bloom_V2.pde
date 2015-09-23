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

void setup() {
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

  void draw(){
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

void drawSkeleton(int userId){ 
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

void onNewUser(SimpleOpenNI curContext, int userId){
	println("onNewUser - userId: " + userId);
	println("\tstart tracking skeleton");

	curContext.startTrackingSkeleton(userId);
}

void keyPressed(){

}
