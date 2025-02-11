//ver 1.0 2023/02/17
//to-do 
//  ハードドロップ
//  ホールド
//  スコア表示

import java.util.Arrays;


color[][] archive = new color[20][10];
color[][] work = new color[20][10];
int[][][] position = new int[4][4][3];

final int magnification = 40;
final int heightRange = 19;
final int widthRange = 9;
final color lightBlue = #c8c8fa;
final color red = #ff0000;
final color lightGreen = #78ff00;
final color blue = #0000c8;
final color orange = #ff9600;
final color yellow = #ffff00;
final color purple = #c800c8;

int score = 0;
int nadir = 0;
int downCount = 0;
color objectColor = 0;

boolean gameContinuable = true;
boolean generatable = true;
boolean movableUnder = true;
boolean movableRight = true;
boolean movableLeft = true;
boolean rotatableClockWise = true;
boolean rotatableCounterClockWise = true;



void setup(){
  
  size(400,800);
  background(255);
  
  generate();
  
}


void draw(){
  
  update();
  mino();
  judgment();
  autoDown();
  end();
  
}


void keyPressed(){

  if(keyCode == UP){gameContinuable = false;
    drop();
  }
  else if(keyCode == DOWN  &&  movableUnder){
    down();
  }
  else if(keyCode == RIGHT  &&  movableRight){
    moveRight();
  }
  else if(keyCode == LEFT  &&  movableLeft){
    moveLeft();
  }
  else if(key == 'x'  &&  rotatableClockWise){
    revolve("right");
  }
  else if(key == 'z'  &&  rotatableCounterClockWise){
    revolve("left");
  }
  else if(keyCode == ENTER){
    reload();
  }
  
}


void generate(){
  
  if(!gameContinuable){
    return;
  }
  
  for(int[] line : work){
    Arrays.fill(line, 0);
  }
  
  for(int i = 0; i < 4; i++){
    for(int j = 0; j < 4; j++){
      position[i][j][0] = 0;
      position[i][j][1] = i-1;
      position[i][j][2] = j+3;
    }
  }
  
  switch(int(random(7))){
    
    case 0:  //I
      objectColor = lightBlue;
      for(int i = 0; i < 4; i++){
        position[2][i][0] = 1;
      }   
      break;
  
    case 1:  //Z
      objectColor = red;
      for(int i = 1; i < 3; i++){
        for(int j = 0; j < 2; j++){
          position[i][j+i-1][0] = 1;
        }
      }
      break;
  
    case 2:  //S
      objectColor = lightGreen;
      for(int i = 1; i < 3; i++){
        for(int j = 1; j < 3; j++){
          position[i][j-i+1][0] = 1;
        }
      }
      break;
  
    case 3:  //J
      objectColor = blue;
      position[1][0][0] = 1;
      for(int i = 0; i < 3; i++){
        position[2][i][0] = 1;
      }
      break;

    case 4:  //L
      objectColor = orange;
      position[1][2][0] = 1;
      for(int i = 0; i < 3; i++){
        position[2][i][0] = 1;
      }
      break;
  
    case 5:  //O
      objectColor = yellow;
      for(int i = 1; i < 3; i++){
        for(int j = 1; j < 3; j++){
          position[i][j][0] = 1;
        }
      }
      break;
  
    case 6:  //T
      objectColor = purple;
      position[1][1][0] = 1;
      for(int i = 0; i < 3; i++){
        position[2][i][0] = 1;
      }
      break;
      
    default:
      break;
      
  }
  
}


void update(){
  
  if(!gameContinuable){
    return;
  }
  
  background(255);
  noFill();
  strokeWeight(1);
  
  movableUnder = true;
  movableRight = true;
  movableLeft = true;
  rotatableClockWise = true;
  rotatableCounterClockWise = true;
  
  downCount = 0;
  
  for(int i = 0; i <= heightRange; i++){
    line(0,magnification*i,width,magnification*i);
  }
  for(int i = 0; i <= widthRange; i++){
    line(magnification*i,0,magnification*i,height);
  }
  
  for(int[] line : work){
    Arrays.fill(line, 0);
  }
  end:
  for(int i = 0; i < 4; i++){
    for(int j = 0; j < 4; j++){
      if(archive[0][i] != 0  &&  position[i][j][0] == 1  &&  position[i][j][1] < 0){
        gameContinuable = false;
        break end;
      }
      if(position[i][j][0] == 1){
        if(position[i][j][1] < 0){
          return;
        }
        work[position[i][j][1]][position[i][j][2]] = objectColor;
      }
    }
  }
  
}


void mino(){
  
  if(!gameContinuable){
    return;
  }

  for(int i = 0; i <= heightRange; i++){
    for(int j = 0; j <= widthRange; j++){
      if(archive[i][j] != 0  ||  work[i][j] != 0){
        strokeWeight(3);
        fill(archive[i][j] != 0  ?  archive[i][j]  :  (work[i][j] != 0  ?  work[i][j]  :  #ffffff));
        square(j*magnification,i*magnification,magnification);
      }
    }
  }
  
}


void judgment(){
  
  if(!gameContinuable){
    return;
  }
  
  Under:
  for(int i = 3; i >= 0; i--){
    for(int j = 0; j < 4; j++){
      if(position[i][j][0] == 1  &&  (position[i][j][1] >= heightRange  ||  archive[position[i][j][1]+1][position[i][j][2]] != 0)){
        movableUnder = false;
        break Under;
      }
    }
  }
  
  Right:
  for(int j = 3; j >= 0; j--){
    for(int i = 0; i < 4; i++){
      if(position[i][j][0] == 1  &&  (position[i][j][2] >= widthRange  ||  archive[position[i][j][1]][position[i][j][2]+1] != 0)){
        movableRight = false;
        break Right;
      }
    }
  }

  Left:
  for(int j = 0; j < 4; j++){
    for(int i = 0; i < 4; i++){
      if(position[i][j][0] == 1  &&  (position[i][j][2] <= 0  ||  archive[position[i][j][1]][position[i][j][2]-1] != 0)){
        movableLeft = false;
        break Left;
      }
    }
  }
  
  ClockWise:
  for(int i = 0; i < 4; i++){
    for(int j = 0; j < 4; j++){
      if(position[i][j][0] == 1  &&  (position[j][3-i][1] > heightRange  ||  position[j][3-i][2] > widthRange  ||  position[j][3-i][1] < 0  ||  position[j][3-i][2] < 0  ||  archive[position[j][3-i][1]][position[j][3-i][2]] != 0)){
        rotatableClockWise = false;
        break ClockWise;
      }
    }
  }
  
  CounterClockWise:
  for(int i = 0; i < 4; i++){
    for(int j = 0; j < 4; j++){
      if(position[i][j][0] == 1  &&  (position[3-j][i][1] > heightRange  ||  position[3-j][i][2] > widthRange  ||  position[3-j][i][1] < 0  ||  position[3-j][i][2] < 0  ||  archive[position[3-j][i][1]][position[3-j][i][2]] != 0)){
        rotatableCounterClockWise = false;
        break CounterClockWise;
      }
    }
  }
  
}


void autoDown(){
  
  if(!gameContinuable){
    return;
  }
  
  if(frameCount % 50 == 0){
    if(movableUnder){
      down();
    }
    else{
      record();
      score();
      generate();
    } 
  } 
}


void record(){
  for(int i = 0; i < 4; i++){
    for(int j = 0; j < 4; j++){
      if(position[i][j][0] == 1){
        archive[position[i][j][1]][position[i][j][2]] = work[position[i][j][1]][position[i][j][2]];
      }
    }
  }
}


void score(){
  
  ArrayList<Integer> hierarchyNumber = new ArrayList<Integer>();
  
  for(int i = 0; i <= heightRange; i++){
    
    for(int j = 0; j <= widthRange; j++){
      if(archive[i][j] == 0){
        break;
      }
      if(j == widthRange){
        hierarchyNumber.add(i);
      }
    }
    
  }
  if(hierarchyNumber.size() == 0){
    return;
  }
  
  for(int i = 0; i < hierarchyNumber.size(); i++){
    for(int j = 0; j <= widthRange; j++){
      archive[hierarchyNumber.get(i)][j] = 0;
    }
    score += 10;
    println(score);
  }
  
  for(int h = 0; h < hierarchyNumber.size(); h++){
    for(int i = hierarchyNumber.get(h); i > 0; i--){
      for(int j = 0; j <= widthRange; j++){
        archive[i][j] = archive[i-1][j];
      }
    }
  }
  
}


void end(){
  if(!gameContinuable){
    int textSize = 120;
    background(0);
    fill(180,0,0);
    PFont font = loadFont("Chiller-Regular-48.vlw");
    textFont(font);
    textSize(textSize);
    textAlign(CENTER);
    text("G A M E",width/2 ,height/2-textSize);
    text("O V E R",width/2 ,height/2);
  }
}


void down(){
  
  if(downCount != 0){
    return;
  }
  
  for(int i = 0; i < 4; i++){
    for(int j = 0; j < 4; j++){
      position[i][j][1]++;
    }
  }
  
  downCount++;
  
}


void moveRight(){
  for(int i = 0; i < 4; i++){
    for(int j = 0; j < 4; j++){
      position[i][j][2]++;
    }
  }
}


void moveLeft(){
  for(int i = 0; i < 4; i++){
    for(int j = 0; j < 4; j++){
      position[i][j][2]--;
    }
  }
}


void revolve(String direction){
  
  int[][] temporary = new int[4][4];
  
  for(int i = 0; i < 4; i++){
    for(int j = 0; j < 4; j++){
      temporary[i][j] = position[i][j][0];
    }
  }
  
  for(int i = 0; i < 4; i++){
    for(int j = 0; j < 4; j++){
      if(direction == "right"){
        position[i][j][0] = temporary[3-j][i];
      }
      else if(direction == "left"){
        position[i][j][0] = temporary[j][3-i];
      }
    }
  }
  
}


void drop(){
}


void reload(){
  gameContinuable = true;
  score = 0;
  generate();
  for(int[] line : archive){
    Arrays.fill(line, 0);
  }
  
}
         
