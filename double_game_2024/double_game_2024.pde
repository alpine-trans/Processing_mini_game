import ddf.minim.*;

int [][] arrangement = new int[4][4];    //スクエアの配置
int square_mode = 0;
int able_max = 1048576;
int max_num = 0;
int best_num = 0;
int score_ranking[];                     //スコアランキング
int score = 0;                           //現スコア
int filled_number = 0;                   //スクエアの埋まり具合
int generate_place = -1;                 //生成位置
int combine_place = -1;                  //合成位置
boolean movable = true;                  //移動可能か
boolean isGenerating = false;            //生成中か
boolean isCombining = false;             //合成中か
boolean isPlusingScore = true;           //スコア加算中か
boolean isSelecting = true;
boolean isPlayingMusic = true;
float p = 1;                             //現スクエア膨張度
float p_generating = 0;                  //生成時スクエア膨張度
float p_combining = 0;                   //合成時スクエア膨張度
PFont font_score;                        //スコア用フォント
PFont font_num;                          //数字用フォント
PFont font_over;                         //ゲームオーバー時用フォント
Minim minim;                             //音声ファイル
AudioPlayer player;                      //ゲーム時音声
AudioPlayer over_player;                 //ゲームオーバー時音声
AudioPlayer combine;
PImage[] fruits;
String[] atoms = {"H" ,                                                                                                                                                      "He",
                  "Li","Be",                                                                                                                        "B" ,"C" ,"N" ,"O" ,"F" ,"Ne",
                  "Na","Mg",                                                                                                                        "Al","Si","P" ,"S" ,"Cl","Ar",
                  "K" ,"Ca","Sc",                                                                      "Ti","V" ,"Cr","Mn","Fe","Co","Ni","Cu","Zn","Ga","Ge","As","Se","Br","Kr",
                  "Rb","Sr","Y" ,                                                                      "Zr","Nb","Mo","Tc","Ru","Rh","Pd","Ag","Cd","In","Sn","Sb","Te","I" ,"Xe",
                  "Cs","Ba","La","Ce","Pr","Nd","Pm","Sm","Eu","Gd","Tb","Dy","Ho","Er","Tm","Yb","Lu","Hf","Ta","W" ,"Re","Os","Ir","Pt","Au","Hg","Tl","Pb","Bi","Po","At","Rn",
                  "Fr","Ra","Ac","Th","Pa","U" ,"Np","Pu","Am","Cm","Bk","Cf","Es","Fm","Md","No","Lr","Rf","Db","Sg","Bh","Hs","Mt","Ds","Rg","Cn","Nh","Fl","Mc","Lv","Ts","Og"
                  };


void setup(){
  //描画設定
  colorMode(HSB, 20, 1, 1);
  size(460,500);
  background(9,0.3,1);
  //外部ファイル
  font_score = loadFont("./data/AgencyFB-Reg-48.vlw");
  font_num = loadFont("./data/ArialNarrow-48.vlw");
  font_over = loadFont("./data/ImprintMT-Shadow-48.vlw");
  minim = new Minim(this);
  player = minim.loadFile("./data/sample.mp3");
  over_player = minim.loadFile("./data/over.mp3");
  combine = minim.loadFile("./data/combine.mp3");
  fruits = new PImage[11];
  fruits[0] = loadImage("./data/cherry.png");
  fruits[1] = loadImage("./data/strawberry.png");
  fruits[2] = loadImage("./data/grape.png");
  fruits[3] = loadImage("./data/mangerin.png");
  fruits[4] = loadImage("./data/persimmon.png");
  fruits[5] = loadImage("./data/apple.png");
  fruits[6] = loadImage("./data/pear.png");
  fruits[7] = loadImage("./data/peach.png");
  fruits[8] = loadImage("./data/pineapple.png");
  fruits[9] = loadImage("./data/melon.png");
  fruits[10] = loadImage("./data/watermelon.png");
  //初期化
  initialize();
}


void draw(){
  //描画初期化
  background(9,0.3,1);
  translate(30,0);
  
  //描画
  if(isSelecting){
    display_select();
  }
  else{
    display_layout();
    display_square();
    //ゲームオーバー時処理
    if(!movable){
      scores();
      display_over();
    }
  }
}


void keyPressed(){

  if(keyCode == ENTER){  //やり直し
    initialize();
  }
  if(keyCode == SHIFT){
    isSelecting = true;
    initialize();
  }

  if(!isMovable()){  //ゲームオーバー時
    movable = false;
    return;
  }

  move();

}


void mouseClicked(){
  
  if(!isSelecting){
    return;
  }
  
  if((mouseX >= 120 && mouseX <= 280 && mouseY >= 70 && mouseY <= 150)){
    isSelecting = false;
    square_mode = 0;
  }
  if((mouseX >= 120 && mouseX <= 280 && mouseY >= 170 && mouseY <= 250)){
    isSelecting = false;
    square_mode = 1;
    able_max = 2048;
  }
  if((mouseX >= 120 && mouseX <= 280 && mouseY >= 270 && mouseY <= 350)){
    isSelecting = false;
    square_mode = 2;
    able_max = 2109999999;
  }
  if((mouseX >= 220 && mouseX <= 270 && mouseY >= 400 && mouseY <= 450)){
    BGM();
  }
  if((mouseX >= 300 && mouseX <= 350 && mouseY >= 400 && mouseY <= 450)){
    isPlayingMusic = false;
    player.pause();
  }
  
}


void stop() {  //音声ファイル停止
  player.close();
  minim.stop();
  super.stop();
}



void initialize(){  //初期化

  //配置配列初期化
  for(int x = 0; x < 4; x++){
    for(int y = 0; y < 4; y++){
      arrangement[y][x] = 0;
    }
  }

  //各変数初期化
  score = 0;
  filled_number = 0;
  generate_place = -1;
  combine_place = -1;
  movable = true;
  isGenerating = false;
  isCombining = false;
  isPlusingScore = true;
  p = 1;
  p_generating = 0;
  p_combining = 0;
  max_num = 0;
  
  //音声初期化
  over_player.pause();
  over_player.rewind();
  if(isPlayingMusic){
    BGM();
  }

  //過去スコア取得  
  Table contents = loadTable("./data/score.csv");
  int scores[] = new int[contents.getColumnCount()+1];
  int highest_score = 0;
  score_ranking = new int[scores.length];

  for(int i = 0; i < scores.length; i++){
    if(i == scores.length-1){
      scores[i] = score;
    }
    else{
      scores[i] = contents.getInt(0,i);
    }
  }
  for(int i = 0; i < scores.length; i++){
    highest_score = i;
    for(int j = i; j < scores.length; j++){
      if(scores[j] > scores[highest_score]){
        highest_score = j;
      }
    }
    score_ranking[i] = scores[highest_score];
    scores[highest_score] = scores[i];
    scores[i] = score_ranking[i];
  }
  best_num = contents.getInt(0,1);


  //  for(int i = 0; i < 4; i++){
  //    for(int j = 0; j < 4; j++){
  //      arrangement[j][i] = int(pow(2,4*(i+4)+j));
  //    }
  //  }
  //  arrangement[0][0] = int(pow(2,17));

  // for(int i = 0; i < 4; i++){
  //   for(int j = 0; j < 4; j++){
  //     arrangement[j][i] = 4096;
  //   }
  // }

  //生成
  generate();

}


void BGM(){
  isPlayingMusic = true;
  player.rewind();
  player.loop();
}


void display_select(){

  fill(0,0,1);
  rectMode(CORNER);
  rect(120,70,160,80,10);
  rect(120,170,160,80,10);
  rect(120,270,160,80,10);
  rect(220,400,50,50,20);
  rect(300,400,50,50,20);
  fill(0);
  textAlign(CENTER,CENTER);
  textFont(font_score,28);
  text("NUMBER_MODE",200,110);
  text("FRUIT_MODE",200,210);
  text("ATOM_MODE",200,310);
  text("BGM_ON",245,425);
  text("BGM_OFF",325,425);
}


void display_layout(){  //背景などの描画
  
  //格子
  for(int i = 0; i < 4; i++){
    for(int j = 0; j < 4; j++){
      rectMode(CORNER);
      fill(10,0.1,1);
      square(i*100,j*100+50,100);
    }
  }
  
  //スコア
  fill(0);
  textFont(font_score,28);
  textAlign(RIGHT, TOP);
  textSize(40);
  text("score:  "+score,350,460);

  switch(square_mode){
    case 0:
      rectMode(CENTER);
      fill(11 - log(max_num)/log(2), 1, 1);  //数字に応じた配色
      square(380,475,35);
      fill(11 - log(max_num)/log(2), 0.5, 1);
      square(380,475,31);
      fill(11 - log(best_num)/log(2), 1, 1);  //数字に応じた配色
      square(280,22,35);
      fill(11 - log(best_num)/log(2), 0.5, 1);
      square(280,22,31);

      textFont(font_num,1);
      textAlign(CENTER, CENTER);
      fill(10,1,1);
      textSize(60 / max(str(max_num).length(), 2));
      text(max_num, 380 , 475);  //数字に応じたサイズ
      textSize(60 / max(str(best_num).length(), 2));
      text(best_num,280,22);  //数字に応じたサイズ
      fill(0);
      textSize(60 / max(str(max_num).length(), 2));
      text(max_num, 380 , 475);
      textSize(60 / max(str(best_num).length(), 2));
      text(best_num,280,22);
      break;
    case 1:
      imageMode(CENTER);
      image(fruits[int(log(max_num)/log(2))-1],380,475,35,35);
      image(fruits[int(log(best_num)/log(2))-1],280,22,35,35);
      break;
    case 2:
      rectMode(CENTER);
      fill(11 - log(max_num)/log(2), 1, 1);  //数字に応じた配色
      square(380,475,35);
      fill(11 - log(max_num)/log(2), 0.5, 1);
      square(380,475,31);
      fill(11 - log(best_num)/log(2), 1, 1);  //数字に応じた配色
      square(280,22,35);
      fill(11 - log(best_num)/log(2), 0.5, 1);
      square(280,22,31);

      textFont(font_num,1);
      textAlign(CENTER, CENTER);
      fill(10,1,1);
      textSize(60 / max(atoms[int(log(max_num)/log(2))-1].length(), 2));
      text(atoms[int(log(max_num)/log(2))-1], 380 , 475);  //数字に応じたサイズ
      textSize(60 / max(atoms[int(log(best_num)/log(2))-1].length(), 2));
      text(atoms[int(log(best_num)/log(2))-1],280,22);  //数字に応じたサイズ
      fill(0);
      textSize(60 / max(atoms[int(log(max_num)/log(2))-1].length(), 2));
      text(atoms[int(log(max_num)/log(2))-1], 380 , 475);
      textSize(60 / max(atoms[int(log(best_num)/log(2))-1].length(), 2));
      text(atoms[int(log(best_num)/log(2))-1],280,22);
      break;
    default:
      break;
  }

  textFont(font_score,28);
  textAlign(LEFT,TOP);
  textSize(40);
  text("best score:  "+score_ranking[0],0,8);
  
}


void display_square(){  //メイン描画
  
  for(int y = 0; y < 4; y++){
    for(int x = 0; x < 4; x++){
      
      //合成・生成時アニメーション
      isGenerating = (generate_place == x+4*y ? true:false);
      isCombining = (combine_place == x+4*y ? true:false);
      
      if(isGenerating){
        
        p = p_generating;
        if(p <= 0.96){
          p += 0.04;
          p_generating = p;
        }
        else{
          isGenerating = false;
          generate_place = -1;
          p_generating = 0;
        }
        
      }
      else if(isCombining){
        
        p = p_combining;
        combine.play();
        if(p < 0.97){
          p += 0.3;
          p_combining = p;
        }
        else if(p > 1.02){
          p -= 0.02;
          p_combining = p;
        }
        else{
          isCombining = false;
          combine_place = -1;
          p_combining = 0;
          combine.rewind();
        }

      }
      else{
        p = 1;
      }
      
      //スクエア描画
      if(arrangement[y][x] > 0){

        switch(square_mode){
          case 0:
            rectMode(CENTER);
            fill(11 - log(arrangement[y][x])/log(2), 1, 1);  //数字に応じた配色
            square(100*x+50,100*(y+1),100*p);
            fill(11 - log(arrangement[y][x])/log(2), 0.5, 1);
            square(100*x+50,100*(y+1),90*p);

            if(round(p) == 1){
              textFont(font_num,1);
              textAlign(CENTER, CENTER);
              fill(10,1,1);
              textSize(180 / max(str(arrangement[y][x]).length(), 2));
              text(arrangement[y][x], 100*x+52 , 100*y + 96 + 3*str(arrangement[y][x]).length());  //数字に応じたサイズ
              fill(0);
              textSize(180 / max(str(arrangement[y][x]).length(), 2));
              text(arrangement[y][x], 100*x+50 , 100*y + 96 + 3*str(arrangement[y][x]).length());
            }
            break;
          case 1:
            imageMode(CENTER);
            image(fruits[int(log(arrangement[y][x])/log(2))-1],100*x+50,100*y+100,98*p,98*p);
            break;
          case 2:
            rectMode(CENTER);
            fill(11 - log(arrangement[y][x])/log(2), 1, 1);  //数字に応じた配色
            square(100*x+50,100*(y+1),100*p);
            fill(11 - log(arrangement[y][x])/log(2), 0.5, 1);
            square(100*x+50,100*(y+1),90*p);

            if(round(p) == 1){
              textFont(font_num,1);
              textAlign(CENTER, CENTER);
              fill(10,1,1);
              textSize(180 / max(atoms[int(log(arrangement[y][x])/log(2))-1].length(), 2));
              text(atoms[round(log(arrangement[y][x])/log(2))-1], 100*x+52 , 100*y + 99);  //数字に応じたサイズ
              fill(0);
              textSize(180 / max(atoms[int(log(arrangement[y][x])/log(2))-1].length(), 2));
              text(atoms[round(log(arrangement[y][x])/log(2))-1], 100*x+50 , 100*y + 99);
            }
            break;
          default:
            break;	
        }
        
      }
      
    }
  }

}


void display_over(){  //ゲームオーバー時描画

  //背景
  rectMode(CENTER);
  textAlign(CENTER, CENTER);
  fill(0,0.4,0.9,240);
  rect(0,0,width*2,height*2);
  scale(0.5);
  translate(50, 250);
  display_square();
  //スコア
  textFont(font_over,28);
  fill(0);
  textSize(180);
  text("O V E R",350,-80);
  text(score,350,560);
  fill(0,0,1,200);
  rect(580,240,300,420);
  //音声
  player.pause();
  player.rewind();
  over_player.play();

  //ランキング
  textSize(50);
  String rank[] = {"1st","2nd","3rd"};
  color c[] = {#E6B422,#C9CACA,#B87333};
  fill(#880000);
  text("[Top Scores]",580,70);
  for(int i = 0; i < 3; i++){
    if(score_ranking.length-1 < i){
      break;
    }
    fill(c[i]);
    text(rank[i]+": "+score_ranking[i],580,100*(i+1.7));
  }

}


void generate(){  //生成

  int generate_size = 0;
  int generate_x = -1;
  int generate_y = -1;
  int position_random = -1;
  int count_filled = 0;
  
  generate_size = (random(1) > 0.2 ? 2:4);  //2か4の決定
  filled_number = 0;  //埋まり具合
  for(int x = 0; x < 4; x++){
    for(int y = 0; y < 4; y++){
      if(arrangement[y][x] != 0){
        filled_number++;
      }
    }
  }

  //生成位置の決定
  position_random = int(random(float(16-filled_number)/10)*10);
  for(int y = 0; y < 4; y++){
    for(int x = 0; x < 4; x++){
      if(arrangement[y][x] != 0){
        count_filled++;
        continue;
      }
      if(x+4*y-count_filled == position_random){
        generate_x = x;
        generate_y = y;
      }
    }
  }
  if(generate_x >= 0){
    arrangement[generate_y][generate_x] = generate_size;
    generate_place = generate_x+4*generate_y;
  }
  
  //スコア
  for(int i = 0; i < 4; i++){
    for(int j = 0; j < 4; j++){
      if(arrangement[i][j] > max_num){
        max_num = arrangement[i][j];
      }
    }
  }

}


void move(){  //移動  ※簡略化推奨


  int count_moved = 0;

  if(keyCode==LEFT){

    //合成
    for(int y = 0; y < 4; y++){
      for(int x = 0; x < 3; x++){
        for(int i = 1; i <= 3-x; i++){

          if(arrangement[y][x] >= able_max || (arrangement[y][x] == 0) || (arrangement[y][x+i] != 0 && arrangement[y][x] != arrangement[y][x+i])){
            break;
          }
          if(arrangement[y][x] == arrangement[y][x+i]){
            arrangement[y][x+i] = 0;
            arrangement[y][x] *= 2;
            add_score(y,x);
            combine_place = x+4*y;
            count_moved++;
            break;
          }
        }
      }
    }
    //移動
    for(int y = 0; y < 4; y++){
      for(int x = 0; x < 3; x++){
        for(int i = 1; i <= 3-x; i++){
          if(arrangement[y][x] != 0){
            break;
          }
          if(arrangement[y][x+i] != 0){
            arrangement[y][x] = arrangement[y][x+i];
            arrangement[y][x+i] = 0;
            count_moved++;
          }
        }
      }
    }

  }
  else if(keyCode==UP){

    //合成
    for(int x = 0; x < 4; x++){
      for(int y = 0; y < 3; y++){
        for(int i = 1; i <= 3-y; i++){

          if(arrangement[y][x] >= able_max || (arrangement[y][x] == 0) || (arrangement[y+i][x] != 0 && arrangement[y][x] != arrangement[y+i][x])){
            break;
          }
          if(arrangement[y][x] == arrangement[y+i][x]){
            arrangement[y+i][x] = 0;
            arrangement[y][x] *= 2;
            add_score(y,x);
            combine_place = x+4*y;
            count_moved++;
            break;
          }
        }
      }
    }
    //移動
    for(int x = 0; x < 4; x++){
      for(int y = 0; y < 3; y++){
        for(int i = 1; i <= 3-y; i++){
          if(arrangement[y][x] != 0){
            break;
          }
          if(arrangement[y+i][x] != 0){
            arrangement[y][x] = arrangement[y+i][x];
            arrangement[y+i][x] = 0;
            count_moved++;
          }
        }
      }
    }

  }
  if(keyCode==RIGHT){

    //合成
    for(int y = 0; y < 4; y++){
      for(int x = 3; x > 0; x--){
        for(int i = 1; i <= x; i++){

          if(arrangement[y][x] >= able_max || (arrangement[y][x] == 0) || (arrangement[y][x-i] != 0 && arrangement[y][x] != arrangement[y][x-i])){
            break;
          }
          if(arrangement[y][x] == arrangement[y][x-i]){
            arrangement[y][x-i] = 0;
            arrangement[y][x] *= 2;
            add_score(y,x);
            combine_place = x+4*y;
            count_moved++;
            break;
          }
        }
      }
    }
    //移動
    for(int y = 0; y < 4; y++){
      for(int x = 3; x > 0; x--){
        for(int i = 1; i <= x; i++){
          if(arrangement[y][x] != 0){
            break;
          }
          if(arrangement[y][x-i] != 0){
            arrangement[y][x] = arrangement[y][x-i];
            arrangement[y][x-i] = 0;
            count_moved++;
          }
        }
      }
    }

  }
  else if(keyCode==DOWN){

    //合成
    for(int x = 0; x < 4; x++){
      for(int y = 3; y > 0; y--){
        for(int i = 1; i <= y; i++){

          if(arrangement[y][x] >= able_max || (arrangement[y][x] == 0) || (arrangement[y-i][x] != 0 && arrangement[y][x] != arrangement[y-i][x])){
            break;
          }
          if(arrangement[y][x] == arrangement[y-i][x]){
            arrangement[y-i][x] = 0;
            arrangement[y][x] *= 2;
            add_score(y,x);
            combine_place = x+4*y;
            count_moved++;
            break;
          }
        }
      }
    }
    //移動
    for(int x = 0; x < 4; x++){
      for(int y = 3; y > 0; y--){
        for(int i = 1; i <= y; i++){
          if(arrangement[y][x] != 0){
            break;
          }
          if(arrangement[y-i][x] != 0){
            arrangement[y][x] = arrangement[y-i][x];
            arrangement[y-i][x] = 0;
            count_moved++;
          }
        }
      }
    }

  }
  else if(key=='/'){
    for(int k=0; k<10; k++){

      //合成
      for(int y = 0; y < 4; y++){
        for(int x = 0; x < 3; x++){
          for(int i = 1; i <= 3-x; i++){

            if(arrangement[y][x] >= able_max || (arrangement[y][x] == 0) || (arrangement[y][x+i] != 0 && arrangement[y][x] != arrangement[y][x+i])){
              break;
            }
            if(arrangement[y][x] == arrangement[y][x+i]){
              arrangement[y][x+i] = 0;
              arrangement[y][x] *= 2;
              add_score(y,x);
              combine_place = x+4*y;
              count_moved++;
              break;
            }
          }
        }
      }
      //移動
      for(int y = 0; y < 4; y++){
        for(int x = 0; x < 3; x++){
          for(int i = 1; i <= 3-x; i++){
            if(arrangement[y][x] != 0){
              break;
            }
            if(arrangement[y][x+i] != 0){
              arrangement[y][x] = arrangement[y][x+i];
              arrangement[y][x+i] = 0;
              count_moved++;
            }
          }
        }
      }

      //移動時生成
      if(count_moved != 0){
        generate();
      }


      //合成
      for(int x = 0; x < 4; x++){
        for(int y = 0; y < 3; y++){
          for(int i = 1; i <= 3-y; i++){

            if(arrangement[y][x] >= able_max || (arrangement[y][x] == 0) || (arrangement[y+i][x] != 0 && arrangement[y][x] != arrangement[y+i][x])){
              break;
            }
            if(arrangement[y][x] == arrangement[y+i][x]){
              arrangement[y+i][x] = 0;
              arrangement[y][x] *= 2;
              add_score(y,x);
              combine_place = x+4*y;
              count_moved++;
              break;
            }
          }
        }
      }
      //移動
      for(int x = 0; x < 4; x++){
        for(int y = 0; y < 3; y++){
          for(int i = 1; i <= 3-y; i++){
            if(arrangement[y][x] != 0){
              break;
            }
            if(arrangement[y+i][x] != 0){
              arrangement[y][x] = arrangement[y+i][x];
              arrangement[y+i][x] = 0;
              count_moved++;
            }
          }
        }
      }

  
    }
  }


  //移動時生成
  if(count_moved != 0){
    generate();
  }

  //スコア
  for(int i=0; i<4; i++){
    for(int j=0; j<4; j++){
      if(arrangement[i][j] > max_num)
        max_num = arrangement[i][j];
    }
  }

}


boolean isMovable(){  //移動可不可判断

  int count_filled = 0;

  //埋まり具合
  for(int y = 0; y < 4; y++){
    for(int x = 0; x < 4; x++){
      if(arrangement[y][x] != 0){
        count_filled++;
      }
    }
  }
  if(count_filled < 16){
    return true;
  }

  //移動判断
  for(int y = 0; y < 4; y++){
    for(int x = 0; x < 3; x++){
      if(arrangement[y][x] != able_max && arrangement[y][x] == arrangement[y][x+1]){
        return true;
      }
    }
  }
  for(int x = 0; x < 4; x++){
    for(int y = 0; y < 3; y++){
      if(arrangement[y][x] != able_max && arrangement[y][x] == arrangement[y+1][x]){
        return true;
      }
    }
  }

  return false;

}


void add_score(int a,int b){  //スコア加算
  score += (int(log(arrangement[a][b])/log(2)) -1)*5;
}


void scores(){  //スコア記録、ソート

  if(!isPlusingScore){
    return;
  }
  
  Table contents = loadTable("score.csv");
  int scores[] = new int[contents.getColumnCount()+1];
  PrintWriter file = createWriter("./data/score.csv");
  int highest_score = 0;
  score_ranking = new int[scores.length];

  //CSVファイルの読み込み
  for(int i = 0; i < scores.length; i++){
    if(i == scores.length-1){
      scores[i] = score;
    }
    else{
      scores[i] = contents.getInt(0,i);
    }
  }

  //スコアのソート
  for(int i = 0; i < scores.length; i++){
    highest_score = i;
    for(int j = i; j < scores.length; j++){
      if(scores[j] > scores[highest_score]){
        highest_score = j;
      }
    }
    score_ranking[i] = scores[highest_score];
    scores[highest_score] = scores[i];
    scores[i] = score_ranking[i];
  }

  //スコアの保存
  for(int i = 0; i < scores.length; i++){
    if(i < scores.length -1){
      file.print(scores[i]);
      file.print(",");
    }
    else{
      file.println(scores[i]);
    }
  }
  file.print(max(max_num,best_num));
  file.flush();
  file.close();
  isPlusingScore = false;

}
