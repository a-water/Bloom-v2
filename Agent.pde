class Agent {

	PVector p;
	PVector pOld;

	float noiseZ = 0.01;
	float noiseZVelocity = 0.01;

	float stepSize;
	float angle;


	Agent() {
		p = new PVector(random(width), random(height));
		pOld = new PVector(p.x, p.y);

		stepSize = random(1, 5);
		setNoiseZRange(0.4);
	}

	void updateAgent() {
		angle = noise(p.x/noiseScale, p.y/noiseScale, noiseZ) * noiseStrength;

		p.x += cos(angle) * stepSize;
		p.y += sin(angle) * stepSize;

		// offscreen wrap
		if(p.x < -10) {
			p.x = pOld.x = width + 10;
		}

		if(p.x > width+10) {
			p.x = pOld.x = -10;
		}

    	if(p.y < -10) {
    		p.y = pOld.y = height + 10;
    	} 

    	if (p.y > height + 10) {
    		p.y = pOld.y = -10;
    	} 

    	strokeWeight(strokeWidth * stepSize);
    	line(pOld.x, pOld.y, p.x, p.y);

    	point(p.x, p.y);
    	

    	pOld.set(p);
    	noiseZ += noiseZVelocity;
	}

	void setNoiseZRange(float noiseZRange) {
		noiseZ = random(noiseZRange);
	}
}