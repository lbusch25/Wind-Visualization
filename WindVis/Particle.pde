class Particle {
  float x, y;
  int lifeTime;
  
  Particle(float tx, float ty, int tl) {
    x = tx;
    y = ty;
    lifeTime = tl;
  }
  
  void setX(float nx) {
    x = nx;
  }
  
    void setY(float ny) {
    y = ny;
  }
  
  void decreaseLife() {
    lifeTime--;
  }
}