class SeedParticle {

	private float speedX;
	private float speedY;
	private float rotation;
	public PVector vector;
	PShape seedSVG;

	private final int seedRadius = 4;

	SeedParticle() {

		vector = new PVector(random(width), random(height));
		speedX = random(-1, 1);
		speedY = random(-1, 1);
	}

	public void update() {
		vector.x += speedX;
		vector.y += speedY;

		// Check Y values for the seed
		if(vector.y > height - seedRadius) {
			vector.y = seedRadius;
		} else if (vector.y < seedRadius) {
			vector.y = height;
		}

		// Check X values for the seed
		if(vector.x > width-seedRadius) {
			vector.x = seedRadius;
		} else if (vector.x < seedRadius) {
			vector.x = width;
		}
	}

	public void draw() {
		// shape(seedSVG, vector.x, vector.y, seedSvgWidth/2.5, seedSvgHeight/2.5);
		// imageMode(CENTER);
		// image(img, vector.x, vector.y);
		ellipse(vector.x, vector.y, seedRadius, seedRadius);
	} 

	public boolean checkForCollision(SeedParticle seed) {

		if(dist(seed.vector.x, seed.vector.y, vector.x, vector.y) < seedRadius) {
			speedX *= -1;
			speedY *= -1;
			return true;
			// println("COLLISION DETECTED!");  
		}

		return false;
	}

	public int getSeedRadius() {
		return seedRadius;
	}
}
