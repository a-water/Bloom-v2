class BodyParticle {

	private float x;
	private float y;
	private float z;

	PVector location;
	PVector velocity;
	PVector acceleration;

	float radius;
	private color currentColor;

	int lives = 40;
	boolean isDead = false;

	BodyParticle(float x, float y, float z, color currentColor) {

		this.x = x;
		this.y = y;
		this.z = z;

		location = new PVector(this.x, this.y);
		velocity = new PVector(0, 0);
		acceleration = new PVector(0, 0);

		this.currentColor = currentColor;
		// this.radius = random(10, 20);
		this.radius = 20;

	}

	public void applyForce(PVector force) {
		PVector f = PVector.div(force, radius);
		acceleration.add(f);
		acceleration.mult(-10.0);
	}

	public void update() {
		velocity.add(acceleration);
		location.add(velocity);
		acceleration.mult(0);
	}

	public void draw() {
		noStroke();
	    fill(currentColor);       
	    // pushMatrix();
	    // translate(x, y, z);
	    lives--;
	    if(lives == 0) {
	    	isDead = true;
	    } else {
	    	point(location.x, location.y);
	    	ellipse(location.x, location.y, radius, radius);
	    }
	    // popMatrix();
	} 

	public boolean checkForCollision(SeedParticle seed) {

		if(dist(seed.vector.x, seed.vector.y, x, y) < seed.getSeedRadius() * 2) {
			println("COLLISION DETECTED! at bodyparticle.x:" + x + " bodyparticle.y:" + y + " z:" + z + " and x:"+ seed.vector.x + " y: " + seed.vector.y + " z:"+ seed.vector.z);
			return true;
		}

		return false;
	}
}
