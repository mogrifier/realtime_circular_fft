import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer player;
AudioInput lineIn;

FFT fft;
PImage bg;
PImage img;
int h = 540;
int w = 960;
float x1 = w/2;
float y1 = h/2;
float x2 = 0;
float y2 = 0;
int radius = (int)(0.5 * x1);
float magnitude = 0;
float phase = 0;
int fps = 5;

void setup()
{
  hint(ENABLE_ASYNC_SAVEFRAME);
  size(960, 540);
  frameRate(fps);

  minim = new Minim(this);
  
  lineIn = minim.getLineIn();

  // an FFT needs to know how 
  // long the audio buffers it will be analyzing are
  // and also needs to know 
  // the sample rate of the audio it is analyzing
  fft = new FFT(lineIn.bufferSize(), lineIn.sampleRate());

  bg = loadImage("./backgrounds/galaxy_big.jpg");
  img = bg.get(329, 111, 1200, 1200);

}


void draw()
{
  background(0);
  
  
  //rotate the galaxy background image super slow
  
  pushMatrix();  
  translate(w/2, h/2); 
  //control rotational speed
  rotate((0.02 * frameCount) * TWO_PI/360);
  translate(-img.width/2, -img.height/2);
  image(img, 0, 0);
  popMatrix();
  
  
  // forward fft on audio buffer
  fft.forward(lineIn.mix);
  strokeWeight(1);  // Thicker

  //draw spectrum starting from inside a circle
  colorMode(HSB, 1);

  int steps =  360; //fft.specSize();

  for (float i = 0; i < steps; i++)
  {
    magnitude = radius - (fft.getBand((int)i) * radius);
    //need the phase angle -
    phase = (i/steps) * TWO_PI;

    //convert amplitude and phase (vector) to cartesian coordinates
    //translate from center of circle
    x2 = x1 + magnitude * cos(phase);
    y2 = y1 + magnitude * sin(phase);

    //use HSB model- use magnitude to affect brightness
    stroke(fft.getBand((int)i), 1 - fft.getBand((int)i), 1);

    //draw the line x1, y1, x2, y2
    line(x1, y1, x2, y2);
  }

  //save frames for making video
  //saveFrame("frame-####.tga");
  
  
  if (!player.isPlaying())
  {
    delay(10);
    exit();
  }
}