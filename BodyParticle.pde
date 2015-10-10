class BodyParticle {

	private float x;
	private float y;
	private float width;
	private float height;
	private float raidus;


	BodyParticle(float x, float y, float width, float height) {

		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;

	}

	public void update() {
		
	}

	public void draw() {
		ellipse(x, y, width, height);
	} 

	public boolean checkForCollision(SeedParticle seed) {

		if(dist(seed.vector.x, seed.vector.y, x, y) < seed.getSeedRadius() * 2 + 10) {
			println("COLLISION DETECTED!");
			return true;
		}

		return false;
	}
}
