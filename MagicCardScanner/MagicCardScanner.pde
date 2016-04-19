/*
Click and drag to select card. Click c to crop.
*/

PImage card, borderCard, noBorder, display, centerPic, textBox, type, setSym, name, cost, damage;
String[] cardList = {"Ajani_Vengeant.jpg", "Elgaud_Shieldmate.jpg", "Fiendslayer_Paladin.jpg", "Karn_Liberated.jpg", "Scoria_Elemental.jpg"};
int startx = 0, starty = 0, endx = 0, endy = 0;

void setup() {
  size(500, 500);
  surface.setResizable(true);
  card = loadImage(cardList[2]);
  display = card;
  surface.setSize(display.width, display.height);
  borderCard = card.copy();
  cropAll(borderCard);
}

void draw() {
  surface.setSize(display.width, display.height);
  image(display, 0, 0);
  stroke(255, 0, 0);
  noFill();
  if (mousePressed) {
    rect(startx, starty, mouseX-startx, mouseY-starty);
  }
}

void cropAll(PImage cropSource){
  int wide = cropSource.width;
  int tall = cropSource.height;
  noBorder = cropCard(cropSource, int(wide*0.05), int(wide*0.05), int(wide*0.95), int(tall-(wide*0.05)));
  centerPic = cropCard(cropSource, int(wide*0.08), int(2*wide*0.085), int(wide-wide*0.08), int(tall/2 + wide*0.075));
  textBox = cropCard(cropSource, int(wide*0.072), int(tall*0.626), int(wide*0.92), int(tall*0.91));
  type = cropCard(cropSource, int(wide*0.08),int(tall*0.56),int(wide*0.8),int(tall*0.626));
  setSym = cropCard(cropSource, int(wide*0.8),int(tall*0.56),int(wide*0.92),int(tall*0.626));
  name = cropCard(cropSource, int(wide*0.08),int(tall*0.05),int(wide*0.7),int(tall*0.11));
  cost = cropCard(cropSource, int(wide*0.7),int(tall*0.05),int(wide*0.92),int(tall*0.11));
  damage = cropCard(cropSource, int(wide*0.74), int(tall*0.89), int(wide*0.93), int(tall*0.95));
}

PImage cropCard(PImage src, int sx, int sy, int ex, int ey){
  // Crops the card to the selected box
  PImage cropped = new PImage(ex - sx, ey - sy, ARGB);
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
  if (key == 'c'){
    borderCard = cropCard(card, startx, starty, endx, endy);
    cropAll(borderCard);
    display = borderCard;
  }
  if (key == '1'){
    display = card;
  }
  if (key == '2'){
    display = borderCard;
  }
  if (key == '3'){
    display = noBorder;
  }
  if (key == '4'){
    display = centerPic;
  }
  if (key == '5'){
    display = textBox;
  }
  if (key == '6'){
    display = type;
  }
  if (key == '7'){
    display = setSym;
  }
  if (key == '8'){
    display = name;
  }
  if (key == '9'){
    display = cost;
  }
  if (key == '0'){
    display = damage;
  }
}