class BodyParticle {

	private float x;
	private float y;

	PVector location;
	color particleColor;
	float radius;

	BodyParticle(float x, float y, color particleColor) {

		this.x = x + random(-35, 35);
		this.y = y + random(-35, 35);

		location = new PVector(this.x, this.y);

		this.particleColor = particleColor;
	
		this.radius = 20;
	}

	public void draw() {
		float randomPoint = random(-70, 70);
	    stroke(particleColor);
	    beginShape(LINES);
		vertex(location.x, location.y);
		vertex(location.x + randomPoint, location.y + randomPoint);
		endShape();
	} 
}
