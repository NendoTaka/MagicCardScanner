PImage card;
String[] cardList = {"Ajani_Vengeant.jpg", "Elgaud_Shieldmate.jpg", "Fiendslayer_Paladin.jpg", "Karn_Liberated.jpg", "Scoria_Elemental.jpg"};
int startx = 0, starty = 0, endx = 0, endy = 0;

void setup() {
  size(500, 500);
  surface.setResizable(true);
  card = loadImage(cardList[1]);
  surface.setSize(card.width, card.height);
}

void draw() {
  image(card, 0, 0);
  stroke(255, 0, 0);
  noFill();
  if (mousePressed) {
    rect(startx, starty, mouseX, mouseY);
  }
}

void cropCard(){
  // Crops the card to the selected box
  PImage cropped = new PImage(endx - startx, endy - starty, ARGB);
  for (int x = startx; x <= endx; x++){
    for (int y = starty; y <= endy; y++){
      cropped.set(x-startx, y-starty, card.get(x,y));
    }
  }
  card = cropped;
  surface.setSize(card.width, card.height);
  startx = 0;
  starty = 0;
  endx = 0;
  endy = 0;
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
    cropCard();
  }
}