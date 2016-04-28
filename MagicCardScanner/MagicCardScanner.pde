/*
Click and drag to select card. Click c to crop.
*/

//Image variables
PImage card, borderCard, noBorder, display, centerPic, textBox, type, setSym, name, cost, damage;
//List of image files
String[] cardList = {"Ajani_Vengeant.jpg", "Elgaud_Shieldmate.jpg", "Fiendslayer_Paladin.jpg", "Karn_Liberated.jpg", "Scoria_Elemental.jpg"};
//Ints used for cropping the image
int startx = 0, starty = 0, endx = 0, endy = 0;

void setup() {
  size(500, 500); // initial screen size
  surface.setResizable(true); // sets resizable screen
  card = loadImage(cardList[2]); // loads the image
  display = card; // sets initial display image
  surface.setSize(display.width, display.height); // resizes surface
  borderCard = card.copy(); // copies card to the borderless image for initial setup
  cropAll(borderCard); // isolates all of the areas to get each variable using borderCard
}

//Draws out all images and objects
void draw() {
  surface.setSize(display.width, display.height); // set surface size
  image(display, 0, 0); // display image
  stroke(255, 0, 0); // line color to red
  noFill(); // no fill
  if (mousePressed) { // on mouse press
    rect(startx, starty, mouseX-startx, mouseY-starty); // draws crop rectangle
  }
}

//Splits image into sections and calls functions to measure values
float[] takeData(PImage imgSource, int n, int m){
  int xDiff = imgSource.width / n; // width of each box
  int yDiff = imgSource.height / m; // height of each box
  float[] result = new float[n * m * 6]; // result array 6 = size of returned array from findColorValues
  int loopCount = 0; // loop counter
  for (int x = 0; x < n; x++){ // for each box wide
    for (int y = 0; y < m; y++){ // for each box tall
      float[] currData = findColorValues(imgSource, x * xDiff, y * yDiff, (x+1) * xDiff, (y+1) * yDiff);
      System.arraycopy(currData, 0, result, loopCount * currData.length, currData.length);
      loopCount += 1;
    }
  }
  return result;
}

//Used to find the average and median values
// format of output (so far):
// [0] = avg red
// [1] = avg green
// [2] = avg blue
// [3] = median red
// [4] = median green
// [5] = median blue
float[] findColorValues(PImage img, int startX, int startY, int endX, int endY){
  color currentColor;
  float[] redValues = new float[(endX - startX) * (endY - startY)];
  float[] greenValues = new float[(endX - startX) * (endY - startY)];
  float[] blueValues = new float[(endX - startX) * (endY - startY)];
  float sumRed = 0, sumGreen = 0, sumBlue = 0;
  float medianRed, medianGreen, medianBlue;
  float averageRed, averageGreen, averageBlue;
  
  // loop to calculate average and median
  for(int y = startY; y < endY; y++){
    for(int x = startX; x < endX; x++){
      currentColor = img.get(x, y); // color at x, y
      
      // red
      redValues[(endX-startX)*(y-startY)+(x-startX)] = red(currentColor); // median
      sumRed += red(currentColor); // average
      
      greenValues[(endX-startX)*(y-startY)+(x-startX)] = green(currentColor); // median
      sumGreen += green(currentColor); // average
      
      blueValues[(endX-startX)*(y-startY)+(x-startX)] = blue(currentColor); // median
      sumBlue += blue(currentColor); // average
    }
  }
  
  // sort arrays of color values for medain
  redValues = sort(redValues);
  greenValues = sort(greenValues);
  blueValues = sort(blueValues);
  
  // even number of colors median
  if(redValues.length % 2 == 0){
    medianRed = (redValues[int(redValues.length/2)] +  redValues[int(redValues.length/2 - 1)]) / 2;
    medianGreen = (greenValues[int(greenValues.length/2)] +  greenValues[int(greenValues.length/2 - 1)]) / 2;
    medianBlue = (blueValues[int(blueValues.length/2)] +  blueValues[int(blueValues.length/2 - 1)]) / 2;
  }
  // odd number of colors median
  else{
    medianRed = redValues[int(redValues.length/2)];
    medianGreen = greenValues[int(greenValues.length/2)];
    medianBlue = blueValues[int(blueValues.length/2)];
  }
  
  // average colors
  averageRed = sumRed / redValues.length;
  averageGreen = sumGreen / greenValues.length;
  averageBlue = sumBlue / blueValues.length;
  
  float[] result = {averageRed, averageGreen, averageBlue, medianRed, medianGreen, medianBlue};
  
  return result;
}

//Isolates all of the parts of the card
void cropAll(PImage cropSource){
  int wide = cropSource.width; // gets the width of the card
  int tall = cropSource.height; // get the height of the card
  // gets a card without a border
  noBorder = cropCard(cropSource, int(wide*0.05), int(wide*0.05), int(wide*0.95), int(tall-(wide*0.05)));
  // gets the center picture
  centerPic = cropCard(cropSource, int(wide*0.08), int(2*wide*0.085), int(wide-wide*0.08), int(tall/2 + wide*0.075));
  // gets the description text
  textBox = cropCard(cropSource, int(wide*0.072), int(tall*0.626), int(wide*0.92), int(tall*0.91));
  // gets the type of card
  type = cropCard(cropSource, int(wide*0.08),int(tall*0.56),int(wide*0.8),int(tall*0.626));
  // gets the set symbol
  setSym = cropCard(cropSource, int(wide*0.8),int(tall*0.56),int(wide*0.92),int(tall*0.626));
  // gets the card name
  name = cropCard(cropSource, int(wide*0.08),int(tall*0.05),int(wide*0.7),int(tall*0.11));
  // gets the cost of summoning
  cost = cropCard(cropSource, int(wide*0.7),int(tall*0.05),int(wide*0.92),int(tall*0.11));
  // gets the defense and damage
  damage = cropCard(cropSource, int(wide*0.74), int(tall*0.89), int(wide*0.93), int(tall*0.95));
}

//Function used to crop an image
PImage cropCard(PImage src, int sx, int sy, int ex, int ey){
  // the new image
  PImage cropped = new PImage(ex - sx, ey - sy, ARGB);
  // loops through the selected area and copies to new image
  for (int x = sx; x <= ex; x++){
    for (int y = sy; y <= ey; y++){
      cropped.set(x-sx, y-sy, src.get(x,y));
    }
  }
  return cropped;
}

void mousePressed(){
  // Starts card selection
  startx = mouseX;
  starty = mouseY;
}

void mouseReleased(){
  // Ends card selection
  endx = mouseX;
  endy = mouseY;
}

void keyPressed(){
  // crop the card
  if (key == 'c'){
    borderCard = cropCard(card, startx, starty, endx, endy);
    cropAll(borderCard);
    display = borderCard;
  }
  // samples the card saving the data to a file
  if (key == 's'){
    float[] data = takeData(centerPic, 3, 3);
  }
  // finds the closes match to known cards
  if (key == 'f'){
    float[] data = takeData(centerPic, 3, 3);
  }
  // display the original image
  if (key == '1'){
    display = card;
  }
  // display the cropped card
  if (key == '2'){
    display = borderCard;
  }
  // displays the borderless card
  if (key == '3'){
    display = noBorder;
  }
  // displays the center picture
  if (key == '4'){
    display = centerPic;
  }
  // display the description box
  if (key == '5'){
    display = textBox;
  }
  // display the type of card
  if (key == '6'){
    display = type;
  }
  // display the set symbol
  if (key == '7'){
    display = setSym;
  }
  // display the name of the card
  if (key == '8'){
    display = name;
  }
  // display the cost of the card
  if (key == '9'){
    display = cost;
  }
  // display the defense and attack of the card
  if (key == '0'){
    display = damage;
  }
}