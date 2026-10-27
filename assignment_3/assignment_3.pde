// Assignment 3 - Typing Test Game
//
// Pick a difficulty by clicking a button, then type the letter shown on screen.
// Easy = 2 possible letters, Medium = 4, Hard = 6.
//
// Bonus 1 (Endless mode): every correct letter is followed by a new random one
//                         until you type a wrong letter.
// Bonus 2 (Speed test):   your reaction time is tracked for every letter, and
//                         the game-over screen shows your average time, WPM and a rank.

// ---------- game states ----------
final int MENU = 0;
final int SHOWING_LETTER = 1;
final int CORRECT = 2;
final int GAME_OVER = 3;
int gameState = MENU;

// ---------- menu buttons (each one is a rectangle: x, y, width, height) ----------
final int BUTTON_WIDTH = 120;
final int BUTTON_HEIGHT = 50;
final int BUTTON_Y = 380;
final int EASY_X = 40;
final int MEDIUM_X = 190;
final int HARD_X = 340;

// ---------- letters available for each difficulty ----------
final String EASY_LETTERS = "fj";          // 2 letters
final String MEDIUM_LETTERS = "asdf";      // 4 letters
final String HARD_LETTERS = "qwezxc";      // 6 letters

// ---------- current round ----------
String letterPool = EASY_LETTERS;
String difficultyName = "Easy";
color backgroundColor;
char targetLetter = 'a';
char typedLetter = 'a';
int score = 0;

// ---------- timing (all in milliseconds from millis()) ----------
final int FEEDBACK_TIME = 500;   // how long the "Great work!" message stays up
int letterShownTime = 0;
int correctShownTime = 0;
int totalReactionTime = 0;

String[] successMessages = {"That's correct!", "Great work!", "Nice one!", "You got it!", "Awesome!"};
String successMessage = successMessages[0];


void setup() {
  size(500, 500);
  textAlign(CENTER, CENTER);
}


void draw() {
  if (gameState == MENU) {
    drawMenu();
  } else if (gameState == SHOWING_LETTER) {
    drawLetterScreen();
  } else if (gameState == CORRECT) {
    drawCorrectScreen();
  } else if (gameState == GAME_OVER) {
    drawGameOverScreen();
  }
}


// ================= screens =================

void drawMenu() {
  background(0);

  fill(255);
  textSize(28);
  text("Typing Test. Select a difficulty", width / 2, 120);
  textSize(16);
  text("Type the letter you see. Keep going until you miss!", width / 2, 170);

  // Easy button
  drawButton(EASY_X, "Easy", color(0, 255, 0));
  // Medium button
  drawButton(MEDIUM_X, "Medium", color(255, 255, 0));
  // Hard button
  drawButton(HARD_X, "Hard", color(255, 0, 0));
}

void drawButton(int buttonX, String label, color buttonColor) {
  fill(buttonColor);
  stroke(255);
  strokeWeight(2);
  rect(buttonX, BUTTON_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
  noStroke();

  fill(0);
  textSize(24);
  text(label, buttonX + BUTTON_WIDTH / 2, BUTTON_Y + BUTTON_HEIGHT / 2);
}

void drawLetterScreen() {
  background(backgroundColor);
  fill(255);

  textSize(20);
  text(difficultyName + "  |  Score: " + score, width / 2, 50);
  text("Time: " + nf((millis() - letterShownTime) / 1000.0, 0, 1) + "s", width / 2, 85);

  textSize(48);
  text("Type " + targetLetter, width / 2, height / 2);
}

void drawCorrectScreen() {
  background(0, 120, 0);
  fill(255);

  textSize(20);
  text(difficultyName + "  |  Score: " + score, width / 2, 50);

  textSize(44);
  text(successMessage, width / 2, height / 2);

  // after a short pause, show a brand new random letter (endless mode)
  if (millis() - correctShownTime >= FEEDBACK_TIME) {
    pickNewLetter();
  }
}

void drawGameOverScreen() {
  background(140, 0, 0);
  fill(255);

  textSize(44);
  text("Wrong! Game over", width / 2, 90);

  textSize(22);
  text("You typed \"" + typedLetter + "\" but the letter was \"" + targetLetter + "\"", width / 2, 150);

  // ----- speed test results -----
  textSize(26);
  text("Score: " + score + "  (" + difficultyName + ")", width / 2, 215);

  if (score > 0) {
    float totalSeconds = totalReactionTime / 1000.0;
    float averageSeconds = totalSeconds / score;
    // standard typing convention: 1 "word" = 5 characters
    float wordsPerMinute = (score / 5.0) / (totalSeconds / 60.0);

    textSize(22);
    text("Average time per letter: " + nf(averageSeconds, 0, 2) + "s", width / 2, 265);
    text("Speed: " + nf(wordsPerMinute, 0, 1) + " WPM", width / 2, 300);
    text("Rank: " + getRank(averageSeconds), width / 2, 335);
  } else {
    textSize(22);
    text("Get at least one right to see your speed!", width / 2, 290);
  }

  textSize(18);
  text("Click anywhere to go back to the menu", width / 2, 450);
}


// ================= game logic =================

// Start a new game with the chosen difficulty's letters and colour
void startGame(String name, String letters, color bgColor) {
  difficultyName = name;
  letterPool = letters;
  backgroundColor = bgColor;
  score = 0;
  totalReactionTime = 0;
  pickNewLetter();
}

// Choose a random letter from the current difficulty and display it
void pickNewLetter() {
  targetLetter = letterPool.charAt(int(random(letterPool.length())));
  letterShownTime = millis();
  gameState = SHOWING_LETTER;
}

String getRank(float averageSeconds) {
  if (averageSeconds < 0.6) {
    return "Lightning";
  } else if (averageSeconds < 1.0) {
    return "Speedy";
  } else if (averageSeconds < 1.5) {
    return "Steady";
  } else {
    return "Warming up";
  }
}

boolean isOverButton(int buttonX) {
  // >= and <= so the border pixels of each button are clickable too
  return mouseX >= buttonX && mouseX <= buttonX + BUTTON_WIDTH
      && mouseY >= BUTTON_Y && mouseY <= BUTTON_Y + BUTTON_HEIGHT;
}


// ================= input =================

void mousePressed() {
  if (gameState == MENU) {
    // each difficulty has its own click handling
    if (isOverButton(EASY_X)) {
      startGame("Easy", EASY_LETTERS, color(30, 90, 160));
    } else if (isOverButton(MEDIUM_X)) {
      startGame("Medium", MEDIUM_LETTERS, color(120, 120, 0));
    } else if (isOverButton(HARD_X)) {
      startGame("Hard", HARD_LETTERS, color(90, 30, 120));
    }
  } else if (gameState == GAME_OVER) {
    gameState = MENU;
  }
}

void keyPressed() {
  // keys only count while a letter is on screen (so nothing happens in the menu)
  if (gameState != SHOWING_LETTER) {
    return;
  }
  // ignore shift, arrows, etc. and anything that isn't a letter
  if (key == CODED || !Character.isLetter(key)) {
    return;
  }

  char pressedLetter = Character.toLowerCase(key);

  if (pressedLetter == targetLetter) {
    score++;
    totalReactionTime += millis() - letterShownTime;
    successMessage = successMessages[int(random(successMessages.length))];
    correctShownTime = millis();
    gameState = CORRECT;
  } else {
    typedLetter = pressedLetter;
    gameState = GAME_OVER;
  }
}
