import java.awt.Frame;
import java.awt.BorderLayout;
import controlP5.*;

private ControlP5 cp5;

ControlFrame cf;


PGraphics[] mskArray;
PImage[] imgArray;
String[] imgArraySorted;
PImage sourceImg, compImg, toSave;
PGraphics cmsk;
int sprites = 20;
int spacing = 10;
int cellSize = 53;

void setup(){
  cp5 = new ControlP5(this);
  cf = addControlFrame("Controls", 200, 200);
  if (sourceImg == null) selectInput("Choose a source image","sourceFile");
  if (compImg == null) selectInput("Choose a composition image","compFile");
  while (sourceImg == null || compImg == null) delay(200);
  size(compImg.width,compImg.height);
  ellipseMode(CENTER);
  noStroke();
  noiseDetail(3,10);
  noLoop();
}


void sourceFile(File selected){     
  if (selected == null) exit();      
  sourceImg = loadImage(selected.getAbsolutePath());   
}

void compFile(File selected){     
  if (selected == null) exit();    
  compImg = null; 
  compImg = loadImage(selected.getAbsolutePath());
  while (compImg == null) delay(200);
  setSize(compImg.width,compImg.height); 
  frame.setSize(compImg.width,compImg.height);
}

void draw(){
  noiseSeed(int(random(0,5555)));
  mskArray = createMasks(sprites);
  imgArray = createImages(sprites, mskArray);
  imgArraySorted = sortColors(sprites,imgArray);
  background(2);
  PGraphics blip = createGraphics(width,height);
  blip.beginDraw();
  for(int x=0;x < width/spacing+1;x++){
     for(int y=0;y < height/spacing+1;y++){
       float val = red(compImg.get(x*spacing,y*spacing));
       int spr = floor(map(val,0,256,0,imgArray.length));
       blip.pushMatrix();
       //rotate(radians(360*noise(x/10.00,y/10.00,55)));
       blip.translate(x*spacing,y*spacing);
       blip.rotate(radians(360*noise(x/10.00,y/10.00,55)));
       blip.image(imgArray[int(imgArraySorted[spr])],-cellSize/2,-cellSize/2);
       blip.popMatrix();
     }
  }
  blip.endDraw();
  PImage bb = blip.get();
  image(bb,0,0);
  toSave = get();
}

PImage[] createImages(int arraySize, PGraphics[] masks){
//create an array to hold the masked images
  PImage[] array = new PImage[arraySize];
  for(int i=0;i<arraySize;i++){
     PImage img = sourceImg.get(int(random(sourceImg.width-cellSize)),int(random(sourceImg.height-cellSize)),cellSize,cellSize);
     img.mask(masks[i]);
     array[i] = img;
  }
  return array;
}

PGraphics[] createMasks(int arraySize){
//create an array to hold the mask layers
  PGraphics[] array = new PGraphics[arraySize];
  for(int i=0;i<arraySize;i++){
    PGraphics msk = createGraphics(cellSize,cellSize);
    msk.beginDraw();
    msk.noStroke();
//generate a bunch of triangle masks
    msk.background(0);
    msk.fill(255);
    int[] r = new int[6];
    for(int p=0;p<8;p++){
      for(int j=0; j<6; j++){
        r[j] = int(random(2,cellSize-2));
      }
      msk.triangle(r[0],r[1],r[2],r[3],r[4],r[5]);
    }
    msk.fill(0);
    msk.endDraw();
    array[i] = msk;
  }
  return array;
}

PGraphics createNoise(){
  PGraphics canvas = createGraphics(width,height);
  canvas.loadPixels();
  float xoff = 0;
  float yoff = 0;
  for(int x=0;x<width;x++){
    xoff += 0.003;   // Increment xoff
    yoff = 0;
    for(int y=0;y<height;y++){
      yoff += 0.003;
      float c = noise(xoff,yoff) * 255;
      canvas.pixels[x+y*width] = color(c) >> 9;
    }
  }
  canvas.updatePixels();
  return canvas;
}

String[] sortColors(int arraySize, PImage[] images){
  FloatDict sorted = new FloatDict();
  for(int i=0;i<arraySize;i++){
    sorted.set(str(i),getAverageColor(images[i])); 
  }
  sorted.sortValues();
  String[] keyArray = sorted.keyArray();
  return keyArray;
}

int getAverageColor(PImage img) {
  img.loadPixels();
  int r = 0, g = 0, b = 0;
  for (int i=0; i<img.pixels.length; i++) {
    color c = img.pixels[i];
    r += c>>16&0xFF;
    g += c>>8&0xFF;
    b += c&0xFF;
  }
  r /= img.pixels.length;
  g /= img.pixels.length;
  b /= img.pixels.length;
  int value = r + g + b;
  return value;
}


void mousePressed() {
  redraw();
}

void keyPressed() {
 if(key == ' '){
   toSave.save(str(millis()) + ".jpg");
 }
}

ControlFrame addControlFrame(String theName, int theWidth, int theHeight) {
  println("new window");
  Frame f = new Frame(theName);
  ControlFrame p = new ControlFrame(this, theWidth, theHeight);
  f.add(p);
  p.init();
  f.setTitle(theName);
  f.setSize(p.w, p.h);
  f.setLocation(100, 100);
  f.setResizable(false);
  f.setVisible(true);
  return p;
}

//Image selection class (methods for select buttons)
public class Selector{
   void selectSource(){
     selectInput("Choose a source image","sourceFile");
   }
   void selectComp(){
     selectInput("Choose a composition image","compFile");
   }
}

public class ControlFrame extends PApplet {

  int w, h;
  
  public void setup() {
    size(w, h);
    frameRate(25);
    cp5 = new ControlP5(this);
    Selector selector = new Selector();
    //parameters
    cp5.addSlider("Tiles")
       .plugTo(parent,"sprites")
       .setValue(16)
       .setNumberOfTickMarks(12)
       .setRange(2, 24)
       .setSize(100,24)
       .setPosition(10,20);
    cp5.addSlider("Tile Size")
       .plugTo(parent,"cellSize")
       .setValue(64)
       .setNumberOfTickMarks(7)
       .setRange(32, 128)
       .setSize(100,24)
       .setPosition(10,60);
    cp5.addSlider("Tile Spacing")
       .plugTo(parent,"spacing")
       .setValue(16)
       .setNumberOfTickMarks(8)
       .setRange(8, 64)
       .setSize(100,24)
       .setPosition(10,100);
    //file buttons
    cp5.addButton("selectSource")
       .plugTo(selector);
    cp5.addButton("selectComp")
       .plugTo(selector);
  }
  
  public void draw(){}
  
  private ControlFrame() {
  }

  public ControlFrame(Object theParent, int theWidth, int theHeight) {
    parent = theParent;
    w = theWidth;
    h = theHeight;
  }


  public ControlP5 control() {
    return cp5;
  }
  
  
  ControlP5 cp5;

  Object parent;

  
}

