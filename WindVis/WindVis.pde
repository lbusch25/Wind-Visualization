// uwnd stores the 'u' component of the wind.
// The 'u' component is the east-west component of the wind.
// Positive values indicate eastward wind, and negative
// values indicate westward wind.  This is measured
// in meters per second.
Table uwnd;

// vwnd stores the 'v' component of the wind, which measures the
// north-south component of the wind.  Positive values indicate
// northward wind, and negative values indicate southward wind.
Table vwnd;

// An image to use for the background.  The image I provide is a
// modified version of this wikipedia image:
//https://commons.wikimedia.org/wiki/File:Equirectangular_projection_SW.jpg
// If you want to use your own image, you should take an equirectangular
// map and pick out the subset that corresponds to the range from
// 135W to 65W, and from 55N to 25N
PImage img;


Particle[] particles;

int maxLife;
int numParticles;

void setup() {
  // If this doesn't work on your computer, you can remove the 'P3D'
  // parameter.  On many computers, having P3D should make it run faster
  size(700, 400, P3D);
  pixelDensity(displayDensity());
  
  img = loadImage("background.png");
  uwnd = loadTable("uwnd.csv");
  vwnd = loadTable("vwnd.csv");
  
  maxLife = 200;
  numParticles = 10000;
  
  particles = new Particle[numParticles];
  
  for(int i = 0; i < numParticles; i++) {
    float x = random(0, width); // * uwnd.getColumnCount() / width; //Convert to data coordinates
    float y = random(0, height); //* uwnd.getRowCount() / height;
    int lifeTime = (int) random(0, maxLife);
    Particle p = new Particle(x, y, lifeTime);
    particles[i] = p;
  }
}

void draw() {
  background(255);
  image(img, 0, 0, width, height);
  drawMouseLine();
  
  beginShape(POINTS);
  for(int i = 0; i < numParticles; i++) {
    
    if(particles[i].lifeTime <= 0) {
      particles[i].x = random(0, width);
      particles[i].y = random(0, height);
    }
    
    float x = particles[i].x;
    float y = particles[i].y;
    
    vertex(x, y);
    
    float vx = readInterp(uwnd, x * uwnd.getColumnCount() / width,
        y * uwnd.getRowCount() / height);
    float vy = readInterp(vwnd, x * uwnd.getColumnCount() / width,
        y * uwnd.getRowCount() / height);

    
    //println(vy);
    float h = 0.5;
    float xk1 = h*vx;
    float yk1 = h*vy;
    
    float vx2 = readInterp(uwnd, (x + 0.5*xk1) * uwnd.getColumnCount() / width,
        (y + 0.5*xk1)* uwnd.getRowCount() / height);
    float vy2 = readInterp(vwnd, (x + 0.5*yk1) * uwnd.getColumnCount() / width,
        (y + 0.5*yk1) * uwnd.getRowCount() / height);
        
    float xk2 = 1.5*h*vx2; //1.5 times the time
    float yk2 = 1.5*h*vy2; //1.5 times the time
    
    float vx3 = readInterp(uwnd, (x + 0.5*xk2) * uwnd.getColumnCount() / width,
        (y + 0.5*xk2) * uwnd.getRowCount() / height);
    float vy3 = readInterp(vwnd, (x + + 0.5*yk2) * uwnd.getColumnCount() / width,
        (y + 0.5*yk2) * uwnd.getRowCount() / height);
        
    float xk3 = 1.5*h*vx3; //1.5 times the time
    float yk3 = 1.5*h*vy3; //1.5 times the time
    
    float vx4 = readInterp(uwnd, (x + xk3) * uwnd.getColumnCount() / width,
        (y + xk3) * uwnd.getRowCount() / height);
    float vy4 = readInterp(vwnd, (x + yk3) * uwnd.getColumnCount() / width,
        (y + yk3) * uwnd.getRowCount() / height);
        
    float xk4 = 2*h*vx4; //1.5 times the time
    float yk4 = 2*h*vy4; //1.5 times the time
    
    println(xk4);
    
    float nx = RK4(x, xk1, xk2, xk3, xk4);
    float ny = RK4(y, yk1, yk2, yk3, yk4);
    
    //Euler s1 = s0 + v(s0)*dt
    //float nx = x + vx*.5;
    //float ny = y - vy*.5;
    
    
    
    particles[i].setX(nx);
    particles[i].setY(ny);
    
    particles[i].decreaseLife();
  }
  endShape();
}

void drawMouseLine() {
  // Convert from pixel coordinates into coordinates
  // corresponding to the data.
  float a = mouseX * uwnd.getColumnCount() / width;
  float b = mouseY * uwnd.getRowCount() / height;
  
  // Since a positive 'v' value indicates north, we need to
  // negate it so that it works in the same coordinates as Processing
  // does.
  //float dx = readInterp(uwnd, a, b) * 10;
  //float dy = -readInterp(vwnd, a, b) * 10;
  float dx = readRaw(uwnd, (int) a, (int) b) * 10;
  float dy = -readRaw(vwnd, (int) a, (int) b) * 10;
  line(mouseX, mouseY, mouseX + dx, mouseY + dy);
}

// Reads a bilinearly-interpolated value at the given a and b
// coordinates.  Both a and b should be in data coordinates.
float readInterp(Table tab, float a, float b) {
  float x = a; //Column number
  float y = b; // Row number
  
  //Ask bret about what we should be interpolating since a and b just pull a data point from the csv
  // TODO: do bilinear interpolation
  int x1 = floor(a);
  int x2 = x1 + 1;
  int y1 = floor(b);
  int y2 = y1 + 1;
  
  //int x1 = x - 1;
  //int x2 = x + 1;
  //int y1 = y - 1;
  //int y2 = y + 1;
  
  float q11 = readRaw(tab, x1, y1);
  float q12 = readRaw(tab, x1, y2);
  float q21 = readRaw(tab, x2, y1);
  float q22 = readRaw(tab, x2, y2);
  
  float px2 = percentTo(x, x1, x2);
  float px1 = percentFrom(x, x1, x2);
  //println(px2);
  
  float xy1 = BiInterp(px2, px1, q11, q21);
  float xy2 = BiInterp(px2, px1, q12, q22);
  
  float py2 = percentTo(y, y1, y2);
  float py1 = percentFrom(y, y1, y2);
  
  float fxy = BiInterp(py2, py1, xy1, xy2);
  //print(fxy);
  
  //return readRaw(tab, x, y);
  return fxy;
}

//float calcK(float pos, float step) {
//  return step*pos;
//}

//float calcK2(float pos, float time, float step

float RK4(float pos, float k1, float k2, float k3, float k4) {
  float newpos = pos + (1/6)*k1 + (1/3)*k2 + (1/3)*k3 + (1/6)*k4;
  //println(newpos);
  return newpos;
}

float BiInterp(float percentTo, float percentFrom, float q1, float q2) {
  return (percentTo * q1) + (percentFrom * q2);
}

float percentTo(float x, float x1, float x2) {
  return (x2 - x)/(x2 - x1);
}

float percentFrom(float x, float x1, float x2) {
  return (x - x1) / (x2 - x1);
}

// Reads a raw value 
float readRaw(Table tab, int x, int y) {
  if (x < 0) {
    x = 0;
  }
  if (x >= tab.getColumnCount()) {
    x = tab.getColumnCount() - 1;
  }
  if (y < 0) {
    y = 0;
  }
  if (y >= tab.getRowCount()) {
    y = tab.getRowCount() - 1;
  }
  return tab.getFloat(y,x);
}