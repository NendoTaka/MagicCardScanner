/*
Click and drag to select card. Click c to crop.
*/

PImage card, borderCard, noBorder, display, centerPic, textBox, type, setSym, name, cost;
String[] cardList = {"Ajani_Vengeant.jpg", "Elgaud_Shieldmate.jpg", "Fiendslayer_Paladin.jpg", "Karn_Liberated.jpg", "Scoria_Elemental.jpg"};
int startx = 0, starty = 0, endx = 0, endy = 0;

void setup() {
  size(500, 500);
  surface.setResizable(true);
  card = loadImage(cardList[2]);
  display = card;
  surface.setSize(display.width, display.height);
  borderCard = card.copy();
  noBorder = cropCard(borderCard, int(borderCard.width*0.05), int(borderCard.width*0.05), int(borderCard.width*0.95), int(borderCard.height-(borderCard.width*0.05)));
  centerPic = cropCard(borderCard, int(borderCard.width*0.08), int(2*borderCard.width*0.085), int(borderCard.width-borderCard.width*0.08), int(borderCard.height/2 + borderCard.width*0.075));
  textBox = cropCard(borderCard, int(borderCard.width*0.072), int(borderCard.height*0.626), int(borderCard.width*0.92), int(borderCard.height*0.91));
  type = cropCard(borderCard, int(borderCard.width*0.08),int(borderCard.height*0.56),int(borderCard.width*0.8),int(borderCard.height*0.626));
  setSym = cropCard(borderCard, int(borderCard.width*0.8),int(borderCard.height*0.56),int(borderCard.width*0.92),int(borderCard.height*0.626));
  name = cropCard(borderCard, int(borderCard.width*0.08),int(borderCard.height*0.05),int(borderCard.width*0.7),int(borderCard.height*0.11));
  cost = cropCard(borderCard, int(borderCard.width*0.7),int(borderCard.height*0.05),int(borderCard.width*0.92),int(borderCard.height*0.11));
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
    noBorder = cropCard(borderCard, int(borderCard.width*0.05), int(borderCard.width*0.05), int(borderCard.width*0.95), int(borderCard.height-(borderCard.width*0.05)));
    centerPic = cropCard(borderCard, int(borderCard.width*0.08), int(2*borderCard.width*0.075), int(borderCard.width-borderCard.width*0.075), int(borderCard.height/2 + borderCard.width*0.075));
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
}