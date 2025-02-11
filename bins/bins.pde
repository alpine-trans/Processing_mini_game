
import java.util.Arrays;

int number_of_bottle = 12;
int number_in_bottle = 6;
int number_of_empty = 2;
int addable_bottle = 1;
int add_bottle = 0;
final int window_width = 140+70*(number_of_bottle+addable_bottle);
final int window_height = 50*number_in_bottle+300;
final int circle_size = 50;
final int between_circles = 20;
final int distance_side_to_cicle = (window_width  -  (circle_size * (number_of_bottle+addable_bottle) + between_circles * (number_of_bottle+addable_bottle-1))) / 2;
final int distance_top_to_cicle = 150;
final int bottle_thickness = 5;

boolean isCarrying = false;
boolean isPlayingGame = false;

color bins[][] = new color[number_of_bottle+addable_bottle][number_in_bottle];
color caryying_ball_color = 0;

PImage image_explanation;



void settings(){

  size(window_width,window_height);

}


void setup(){

  initialize();
  image_explanation = loadImage("./data/explanation.png");

}


void draw(){

  background(255);

  for(int i = 0; i < number_of_bottle+add_bottle; i++){
    for(int j = number_in_bottle-1; j >= 0; j--){
      if(bins[i][j] != 0){
        continue;
      }
      for(int k = j; k > 0; k--){
        bins[i][k] = bins[i][k-1];
        bins[i][k-1] = 0;
      }
    }
  }


  for(int i = 0; i < number_of_bottle+add_bottle; i++){
    for(int j = 0; j < number_in_bottle; j++){
      if(bins[i][j] == 0)
        continue;
      fill(bins[i][j]);
      stroke(0);
      circle(i*(circle_size + between_circles) + distance_side_to_cicle + circle_size/2, j*circle_size + distance_top_to_cicle + circle_size/2, circle_size);
    }
  }
  fill(0,150);
  noStroke();
  for(int i = 0; i < number_of_bottle+add_bottle; i++){
    rect(distance_side_to_cicle + i*(circle_size + between_circles), distance_top_to_cicle, -bottle_thickness, circle_size * number_in_bottle);
    rect(distance_side_to_cicle + circle_size + i*(circle_size + between_circles), distance_top_to_cicle, bottle_thickness, circle_size * number_in_bottle);
    rect((distance_side_to_cicle - bottle_thickness) + i*(circle_size + between_circles), distance_top_to_cicle + circle_size * number_in_bottle, circle_size + bottle_thickness * 2, bottle_thickness);
  }
  
  int number_filled = 0;
  for(int i = 0; i < number_of_bottle+add_bottle; i++){
    for(int j = 1; j < number_in_bottle; j++){
      if(bins[i][0] != bins[i][j]){
        break;
      }
      if(j == number_in_bottle-1){
        number_filled++;
      }
    }
  }
  if(number_filled == number_of_bottle+add_bottle){
    fill(0);
    textSize(100);
    textAlign(CENTER,CENTER);
    text("congratulation",window_width/2,window_height/3);
    isPlayingGame = false;
  }

  image(image_explanation, 0, window_height-80);

  int wipe_x = 80;
  int wipe_y = 60;
  fill(125);
  square(wipe_x - circle_size/2 -5, wipe_y - circle_size/2 -5, circle_size +10);
  fill(255);
  square(wipe_x - circle_size/2 -1, wipe_y - circle_size/2 -1, circle_size +2);
  fill(caryying_ball_color != 0 ? caryying_ball_color : 255);
  stroke(caryying_ball_color != 0 ? 0 : 255);
  circle(wipe_x, wipe_y, circle_size);


}


void mouseClicked(){

  if(!isPlayingGame){
    return;
  }

  if(isCarrying){
    for(int i = 0; i < number_of_bottle+add_bottle; i++){
      if(bins[i][0] == 0  &&  mouseX > distance_side_to_cicle + i*(circle_size+between_circles) && mouseX < distance_side_to_cicle + i*(circle_size+between_circles) + circle_size){
        for(int j = 1; j < number_in_bottle; j++){
          if(bins[i][j] == caryying_ball_color || (j == number_in_bottle-1 && bins[i][j] == 0)){
            bins[i][0] = caryying_ball_color;
            isCarrying = false;
            caryying_ball_color = 0;
          }
          else if(bins[i][j] == 0){}
          else{
            break;
          }
        }
      }
    }
  }
  else{
    for(int i = 0; i < number_of_bottle+add_bottle; i++){
      for(int j = 0; j < number_in_bottle; j++){
        if(bins[i][j] == 0){
          continue;
        }
        else if(j != 0 && bins[i][j-1] != 0){
          break;
        }
        if(mouseX > distance_side_to_cicle + i*(circle_size+between_circles) && mouseX < distance_side_to_cicle + i*(circle_size+between_circles) + circle_size  &&  mouseY > distance_top_to_cicle + j*circle_size && mouseY < distance_top_to_cicle + j*circle_size + circle_size){
          // println(i*4+j);
          caryying_ball_color = bins[i][j];
          bins[i][j] = 0;
          isCarrying = true;
        }
      }
    }
  }

}


void keyPressed(){

  if(key == ENTER){
    initialize();
  }
  else if(key == 'a'){
    add_bottle = addable_bottle;
  }

}


void initialize(){
    
  for(int[] line : bins){
    Arrays.fill(line, 0);
  }

  caryying_ball_color = 0;

  isCarrying = false;
  isPlayingGame = true;

  add_bottle = 0;

  // for(int i = 0; i < number_of_bottle-1; i++){
  //   for(int j = 0; j < number_in_bottle; j++){
  //     bins[i][j] = color(i*20+j*40+50,i*60+j*10+50,i*j*20+50);
  //   }
  // }
  // for(int i = 1; i <= 3; i++){
  //   bins[0][i] = #FF0000;
  // }
  // bins[1][0] = #FF0000;
  // for(int i = 1; i <= 3; i++){
  //   bins[1][i] = #0000FF;
  // }
  // bins[0][0] = #0000FF;

  int position_random = 0;
  int count_empty = 0;
  int count_filled = 0;
  color[] colors = {#FF0000,#00FF00,#0000FF,#FFFF00,#00FFFF,#FF00FF,#FFBF00,#00FFBF,#BF00FF,#BFFF00,#00BFFF,#FF00BF};

  // for(int i = 0; i < 12; i++){
  //   bins[int(i/4)][int(i%4)] = colors[i];
  // }

  for(int i = 0; i < number_of_bottle-number_of_empty; i++){
    for(int j = 0; j < number_in_bottle; j++){
      if(bins[i][j] == 0){
        count_empty++;
      }
    }
  }

  for(int i = 0; i < number_of_bottle-number_of_empty; i++){
    for(int j = 0; j < number_in_bottle; j++){

      
      position_random = int(random(count_empty/10)*10);
      // println(count_empty);
      
      for(int k = 0; k < number_of_bottle-number_of_empty; k++){
        for(int l = 0; l < number_in_bottle; l++){
          if(bins[k][l] != 0){
            count_filled++;
            continue;
          }
          // println(k*number_in_bottle+l-count_filled , position_random);
          if(k*number_in_bottle+l-count_filled == position_random){
            bins[k][l] = colors[i];
            count_empty--;
          }
        }
        // println();
      }
      count_filled = 0;

    }
    // println(i);
  }




  // println(isFill(1));
}



boolean isFill(int num){
  for(int i = 0; i < number_in_bottle; i++){
    if(bins[num][i] != bins[num][0]){
      break;
    }
    if(i == number_in_bottle-1){
      return true;
    }
  }
  return false;
}


// boolean isSpacebelow(int num){
//   for(int i = number_in_bottle-1; i > 0; i--){
//     if(bins[num][i] == 0){
//       continue;
//     }
//     if(bins[num][i-1] != 0){
//       return true;
//     }
//   }
//   return false;
// }





