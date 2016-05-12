/*  
  MagicCardScanner
  
  Programmed by:
    Klayton Hawkins
    Radeeb Bashir
    Sam Bumgardner
    Zachary Olson
    TJ Wallis
    
  Created for CSC 545: Computer Speech, Music and Images
    Final Project


  This program processes images of cards from Magic: The Gathering
  in a few different ways. It can...
  
    1)  Crop the base image down to a user-specified area, used to
        remove any unwanted (any non-card) sections of the image.
        
    2)  Further crop (and display) a card image to a variety of useful 
        sub-images, such as the borderless card, as well as the card's name, 
        mana cost, card type, set symbol, body text, power and toughness, 
        and the card art.
        
    3)  Inspect the pixels of the card's different sub-images to
        create a sort of "image processing profile" of the card image.
        This involves a series of steps:
          
          A)  It samples pixels just inside the border to determine
              the card's overall color.
          
          B)  For the sub-images card name, card type, body text, and 
              power and toughness it thresholds the image and 
              finds the percentage of black pixels in that sub-image.
              A small margin around the body text is further cropped 
              during this step, to reduce any inconsistencies from the
              border surrounding it.
  
          C)  For the sub-images mana cost, set symbol, and card art
              it finds the mean and median red, green, and blue values
              of all of the pixels in those areas (a total of 6 floating
              point numbers). The card art section, being significantly 
              larger than the other two, is first divided into 9 
              subcomponents. Each subcomponent's mean and median r, g, and b
              values are determined seperately.
              
    4)  Write the current card's "image processing profile" and name to a 
        text file (cards.txt). The profile is entered as a series of 
        comma-separated floating point numbers, which is followed by a 
        single space, then the filename of the card that was processed 
        (without its extension).
        
    5)  Compare the current card's "image processing profile" against all
        of the entries stored in our text file (cards.txt). It computes
        a total difference measure between the current card and each
        card from the file, based on the differences between each
        of the fields in their profiles. Each card's total difference
        measure is printed, then the card with the lowest total difference
        measure is selected to be the most similar.
        

  A complete list of the program's hotkeys and controls follows:
    
    Click and drag with the mouse to: 
      select an area to crop down to. 
      (Note: should only use this to remove extraneous, non-card 
       parts of the main image)
  
    Press 'c' to:
      crop the full image down to the mouse-selected area.
    
    Press 's' to: 
      find the current card's "image processing profile" and append 
      it to the end of the file "cards.txt".
    
    Press 'f' to:
      find the current card's "image processing profile" and compare
      it against all entries in "cards.txt", printing results and
      most similar entry at the end.
      (Note: This assumes that there is at least 1 entry in cards.txt,
       and that there are no extraneous blank lines in the file. We 
       cannot guarantee the program will work as expected if these 
       requirements are not met.) 
       
    Press '1' to:
      display the original image.
      
    Press '2' to:
      display the user-cropped image.
      
    Press '3' to:
      display the bordless card.
      
    Press '4' to:
      display the card's center picture sub-image.
      
    Press '5' to:
      display the body text sub-image.
      
    Press '6' to:
      display the card type sub-image.
      
    Press '7' to:
      display the set symbol sub-image.
      
    Press '8' to:
      display the card name sub-image.
      
    Press '9' to:
      display the mana cost sub-image.
      
    Press '0' to:
      display the power and toughness sub-image.
*/

//Image variables
PImage card, borderCard, noBorder, display, centerPic, bodyText, type, setSym, name, cost, damage;
//List of image files
String[] cardList = {"Sam_Sleeved_Castellan.jpg", "Sam_Unsleeved_Castellan.jpg", "Ajani_Vengeant.jpg", "Back_from_the_Brink.jpg", "Other_Elgaud_Shieldmate.jpg", "Elgaud_Shieldmate.jpg", "Fiendslayer_Paladin.jpg", "Karn_Liberated.jpg", "Scoria_Elemental.jpg", "Citadel_Castellan.jpg", "Valeron_Wardens.jpg", "Dromoka's_Command.jpg", "Managorger_Hydra.jpg", "Patron_of_the_Valiant.jpg", "Topan_Freeblade.jpg"};
int currentCard = 3;
//Ints used for cropping the image
int startx = 0, starty = 0, endx = 0, endy = 0;

void setup() {
  size(500, 500); // initial screen size
  surface.setResizable(true); // sets resizable screen
  card = loadImage(cardList[currentCard]); // loads the image
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

//Takes data from the images and returns it
//[CardColor(C),Name(B),Type(B),Description(B),Attack/Defense(B),Cost(A1),Set(A1),Image(A9)]
float[] takeData(){
  float[] result = new float[1];
  result[0] = CardColor(noBorder); // get card color
  
  float bName = blackPixelCount(name, false); // count black pixels of name
  result = append(result, bName);
  
  float bType = blackPixelCount(type, false); // count black pixels of type
  result = append(result, bType);
  
  float bDesc = blackPixelCount(bodyText, true); // count black pixels of description
  result = append(result, bDesc);
  
  float bAtt = blackPixelCount(damage, false); // count black pixels of attack and defense
  result = append(result, bAtt);
  
  float[] aCost = sampleBoxes(cost, 1, 1); // color samples the cost
  result = concat(result, aCost);
  
  float[] aSet = sampleBoxes(setSym, 1, 1); // color samples the set symbol
  result = concat(result, aSet);
  
  float[] aImage = sampleBoxes(centerPic, 3, 3); // color samples the center image
  result = concat(result, aImage);
  
  return result;
}

//Splits image into sections and calls functions to measure values
float[] sampleBoxes(PImage imgSource, int n, int m){
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
  
  // sort arrays of color values for median
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

float CardColor(PImage src){
  //get the borderless image
  
  int wide = src.width; // gets the width of the borderless card
  int tall = src.height; // get the height of the borderless card
  
  int x1 = int(wide*0.005); //to sample card color pixels
  int x2 = int(wide*0.009);
  
  int y1 = int(tall* 0.085);
  int y2 = int(tall* 0.25);
  
  float r = 0, g = 0, b = 0; // red green blue values
  int count = 0;//to count the no of pixels
  
  //add the pixels to the respective colors
  for (int y = y1; y <= y2; y++){
    for (int x = x1; x <= x2; x++){
      color c = src.get(x,y);
      r += red(c); 
      g += green(c);
      b += blue(c);
      count += 1;
    }
  }
  
  r = r/count; //average values
  g = g/count;
  b = b/count;
  
  float colorCode = 0;
  
  //conditions:
  if (r > g + b){colorCode = 0;} //red
  else if (g > 100 && g - r >= 20 && g - b >= 20){colorCode = 1;} //green
  else if ( b - (r + g) < 50 && b - (r + g) > - 50 && b > 100 ){colorCode = 2;} //blue
  else if ( r + g + b > 570 ){colorCode = 3;} //white
  else if (r < 90 && g < 90 && b < 90 ){colorCode = 4;} //black 
  else if (r > 140 && r < 255 && g > 130 && g < 230 && b < 130 && (r + g) > 180) {colorCode = 5;} //gold
  else if (r > 100 && r < 170 && g > 100 && g < 170 && b > 100 && b < 170){colorCode = 6;} //gray
  
  return colorCode; 
}

//Isolates all of the parts of the card
// Note: Measurements for cropping were determined empirically.
void cropAll(PImage cropSource){
  int wide = cropSource.width; // gets the width of the card
  int tall = cropSource.height; // get the height of the card
  // gets a card without a border
  noBorder = cropCard(cropSource, int(wide*0.05), int(wide*0.05), int(wide*0.95), int(tall-(wide*0.05)));
  // gets the center picture
  centerPic = cropCard(cropSource, int(wide*0.08), int(2*wide*0.085), int(wide-wide*0.08), int(tall/2 + wide*0.075));
  // gets the description text
  bodyText = cropCard(cropSource, int(wide*0.072), int(tall*0.626), int(wide*0.92), int(tall*0.91));
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
  if (sx - ex == 0 || sy - ey == 0){
    return src;
  }
  PImage cropped = new PImage(ex - sx, ey - sy, ARGB);
  // loops through the selected area and copies to new image
  for (int x = sx; x <= ex; x++){
    for (int y = sy; y <= ey; y++){
      cropped.set(x-sx, y-sy, src.get(x,y));
    }
  }
  return cropped;
}

//Function used to compare the current card against all others
// Actual comparison handled inside of a helper funciton, compareCards()
void compareData(float[] data){
  String[][] cardsStringData = readText();
  int cardArraySize = split(cardsStringData[0][0], ',').length;
  float[] cardFloatData = new float[cardArraySize];
  String[] tempStringList = new String[cardArraySize];
  float[] comparisonScores = new float[cardsStringData.length];
  
  //Convert the string representation of a card into an array of floats
  for(int i = 0; i < cardsStringData.length; i++){
    tempStringList = split(cardsStringData[i][0], ',');
    for(int j = 0; j < cardFloatData.length; j++){
      cardFloatData[j] = float(tempStringList[j]);
    }
    comparisonScores[i] = compareCards(data, cardFloatData);
    print(cardsStringData[i][1], ": ", comparisonScores[i], "\n");
  }
  
  print("\n");
  
  float minDifference = comparisonScores[0];
  int minIndex = 0;
  for(int i = 1; i < comparisonScores.length; i++){
    if(comparisonScores[i] < minDifference){
      minDifference = comparisonScores[i];
      minIndex = i;
    }
  }
  
  print("The most similar card found was ", cardsStringData[minIndex][1]);
  print("\nwhich had a difference measure of ", comparisonScores[minIndex], "\n\n");
}


//Calculates the total difference between two cards based on their
//pixel statistics.
float compareCards(float[] card1, float[] card2){
  /*
    For reference, this is the format of the card arrays:
    
    Array = [CardColor(C),Name(B),Type(B),Description(B),Attack/Defense(B),Cost(A1),Set(A1),Image(A9)]
    
    C = Color [white,blue,black,red,green,gold,gray] (float 0-6 related to position in array)
    B = Percent black (0-100 float % of area that is black/text)
    Ax = Average and Median Colors (6 * x = number of spaces where x is number of squares) 
        [avgRed,avgGreen,avgBlue,medRed,medGreen,medBlue]
  */
  
  float totalDiff = 0;

  //If card colors do not match, add 10000 to total difference
  if(card1[0] != card2[0]){
    totalDiff += 10000;
  }
  //For comparisons between percentages of black pixels,
  // add the square of their difference to the totalDiff.
  for(int i = 1; i <= 4; i++){
    totalDiff += pow(card1[i] - card2[i], 2);
  }
  //For comparisons between median and average color values,
  // Simply add the differences between the values to the totalDiff.
  for(int i = 5; i < card1.length; i++){
    totalDiff += abs(card1[i] - card2[i]);
  }
  
  return totalDiff;
}


//reading info from text file
String[][] readText(){
  String[] data=loadStrings("cards.txt");
  String[][] result = new String[data.length][2];
  
  for(int i = 0; i < data.length; i++){
    result[i] = split(data[i], " ");
  }
  
  return result;
}

//Thresholds the image and finds the percentage of black pixels.
// If cutOffMargin is true, it does an extra small crop first.
float blackPixelCount(PImage img, boolean cutOffMargin)
{
  int pixCount = 0;
  if(cutOffMargin == true)
  {
      img = cropCard(img, int(img.width * 0.02), int(img.height* 0.05), int(img.width* 0.98), int(img.height*0.93));
  }
  float thr = avgPixel(img);
  PImage newImage = img.get();
  newImage.loadPixels();
  
  for (int i = 0; i < newImage.pixels.length; i++) {
    float val = int(red(newImage.pixels[i]));
    if (val > thr) val = 255;
    else val = 0;
    newImage.pixels[i] = color(val, val, val);
    if(val == 0)
    {
     pixCount++; 
    }
  }
  float percentBlack = ((pixCount*1.0) / (img.width * img.height)) * 100;
  return percentBlack;
}

// Helper function used in blackPixelCount.
float avgPixel(PImage img)
{
  float total = 0;
  for (int i = 0; i < img.pixels.length; i++) {
    total += red(img.pixels[i]);
  }
  float avg = total/img.pixels.length;
  return avg;
}

//Samples the card and appends the data to cards.txt
void cardSample(){
  // gets the card data
  float[] data = takeData();
  String outArray = ""; // initialize output string
  for (int x = 0; x < data.length; x++){
    outArray += str(data[x]) + ","; // append array data to output string
  }
  outArray = outArray.substring(0, outArray.length() - 1); // removes the last comma
  outArray += " " + cardList[currentCard]; // adds the card name
  outArray = outArray.substring(0, outArray.length() - 4); // removes the extension
  // opens and reads the current contents of cards.txt
  String lines[] = loadStrings("cards.txt");
  // appends the output string to the current contents
  lines = append(lines, outArray);
  //saves the strings to the file
  saveStrings("data/cards.txt", lines);

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
    borderCard = cropCard(card, min(startx,endx), min(starty,endy), max(startx,endx), max(starty,endy));
    cropAll(borderCard);
    display = borderCard;
  }
  // samples the card saving the data to a file
  if (key == 's'){
    cardSample();
  }
  // finds the closes match to known cards
  if (key == 'f'){
    float[] data = takeData();
    compareData(data, "data/cards.txt");
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
  // display the body text
  if (key == '5'){
    display = bodyText;
  }
  // display the card type
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
  // display the card's power and toughness
  if (key == '0'){
    display = damage;
  }
}