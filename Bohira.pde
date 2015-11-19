import geomerative.*;
import controlP5.*;

private ControlP5 cp5;

PImage sourceImg, compImg, toSave;

PImage[] tiles;
int tileCount = 60;
int tileSpacing = 10;
int tileSize = 32;

RShape masks;

void setup(){
  // ;)
  size(600,600,P2D);
  
  //controls setup
  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);
  
  RG.init(this);
  masks = RG.loadShape("masks.svg");
  
  if (sourceImg == null) selectInput("Choose a source image","sourceFile");
  if (compImg == null) selectInput("Choose a composition image","compFile");
  while (sourceImg == null || compImg == null) delay(200);
  
  rectMode(CENTER);
  noStroke();
  noiseDetail(3,1.0);
  noLoop();
}

void draw(){
  //turn this into a constant in to control the randomness!!
  int n = int(random(5555));
  noiseSeed(n);
  randomSeed(n);
  
  //make the tiles
  tiles = createTiles(tileCount);
  
  String[] imgArraySorted = sortColors(tileCount,tiles);
  
  background(0);
  
  //set sizes (hi-res)
  float maxWidth = 900;
  float maxHeight = 900;
  
  float sizex = maxWidth;
  float sizey = maxHeight;
  if (((maxWidth / maxHeight) < ((float)compImg.width / (float)compImg.height))){
    sizey = maxWidth / ((float)compImg.width / (float)compImg.height);
  }
  else{
    sizex = maxHeight / ((float)compImg.height / (float)compImg.width);
  }
  
  PGraphics blip = createGraphics(int(sizex),int(sizey));
  
  blip.beginDraw();
  for(int start = 0; start <= tileSpacing; start += tileSpacing){
    for(int x=start; x <= sizex; x+= tileSpacing * 2){
       for(int y=start; y <= sizey; y+=tileSpacing * 2){
         int normalX = int(map(x,0,sizex,0,compImg.width));
         int normalY = int(map(y,0,sizey,0,compImg.height));
         float val = red(compImg.get(normalX, normalY));
         int spr = floor(map(val,0,256,0,tiles.length));
         blip.pushMatrix();
         
         blip.translate(x,y);
         blip.rotate(radians(360*noise(x/10.00,y/10.00,55)));
         blip.image(tiles[int(imgArraySorted[spr])],-tileSize/2,-tileSize/2);
         blip.popMatrix();
       }
    }
  }
  blip.endDraw();
  PImage bb = blip.get();
 
  float displayScaleFactor = min(width/sizex,height/sizey) - 0.05;
  float xx = sizex * displayScaleFactor;
  float yy = sizey * displayScaleFactor;
  image(bb,width/2 - xx/2,height/2 - yy/2, xx, yy);
  cp5.draw();
  toSave = bb.get();
}

void sourceFile(File selected){
  if (selected == null) exit();
  sourceImg = loadImage(selected.getAbsolutePath());   
}

void compFile(File selected){     
  if (selected == null) exit();    
  compImg = loadImage(selected.getAbsolutePath());
  while (compImg == null) delay(200);
}

PImage[] createTiles(int arraySize){
  //create an array to hold the masked images
  PImage[] array = new PImage[arraySize];
  for(int i=0;i<arraySize;i++){
    PImage img = sourceImg.get(int(random(sourceImg.width-tileSize)),int(random(sourceImg.height-tileSize)),tileSize,tileSize);
    PGraphics mg = createGraphics(tileSize,tileSize);
    mg.beginDraw();
    mg.background(0);
    int n = int(random(999)) % masks.countChildren();
    RShape ms = masks.children[n];
    ms.centerIn(mg,0);
    mg.translate(tileSize/2,tileSize/2);
    mg.stroke(0);
    mg.fill(255);
    ms.draw(mg);
    mg.endDraw();
    PImage maskImg = mg.get();
    img.mask(maskImg);
    array[i] = img;
  }
  return array;
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
    toSave.save("output/" + str(millis()) + ".jpg");
  }
}

//Image selection class (methods for select buttons)
void selectSource(){
  selectInput("Choose a source image","sourceFile");
}
void selectComp(){
  selectInput("Choose a composition image","compFile");
}