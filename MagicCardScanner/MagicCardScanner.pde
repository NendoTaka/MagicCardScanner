PImage card;
String[] cardList = {"Ajani_Vengeant.jpg", "Elgaud_Shieldmate.jpg", "Fiendslayer_Paladin.jpg", "Karn_Liberated.jpg", "Scoria_Elemental.jpg"};

void setup() {
  size(500, 500);
  surface.setResizable(true);
  card = loadImage(cardList[0]);
  surface.setSize(card.width, card.height);
}

void draw() {
  image(card, 0, 0);
}