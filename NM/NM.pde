
float r = 100;
float N = 0;
float radian = 0;
float degree = 0;
float theta = 0;
int num = 1;

float n = 0;
int keyP = 0;
int m = millis();
int ch = 0;
int count = 0;



void setup(){

  size(500, 500);
  background(255);
  N = 0;
  
  translate(width/2, height/2);
  
  fill(0);
  textSize(20);
  textAlign(CENTER, BOTTOM);
  text(N, 0, -100);
  
  scale(1, -1);
  noFill();
  circle(0, 0, 2*r);

}


void draw(){

  degree = 360/N;
  radian = degree / 180 * PI;
  polygon();
  //saveFrame("frames/####.png");

}


void initial(){

    N = n;
    num = 0;
    theta = 0;
    n = 0;
    ch = 0;
    count = 0;
    
}


void polygon(){
  
  if(sin(theta) <= 0.001  &&  sin(theta) > 0)
    return;
  
  theta = radian * num;
  translate(width/2, height/2);
  noStroke();
  fill(255);
  rect(-30, -105, 70, -20);
  fill(0);
  stroke(1);
  text(N, 0, -100);
  scale(1, -1);
  line(r*cos(theta), r*sin(theta), r*cos(radian*(num+1)), r*sin(radian*(num+1)));
  
  num++;
  
}


void keyPressed(){


  if((key != keyP) || (millis()-m >= 100)){
  
    if(key == '.')
      ch = 1;
    if(key == BACKSPACE){
      if(ch == 1){
        count--;
        n = floor(n*pow(10,count)) / pow(10,count);
        if(count <= 0)
          ch = 0;        
      }
      else
        n = floor(n/10);
    }
    
    if(keyCode >= 96 && keyCode <= 105){
    
      n = n*pow(10,count+1)+(keyCode-96);
      if(ch == 1){  
        count++;
        n /= pow(10,count);
      }
      
    }
    keyP = key;
    m = millis();
    
  }
  if(keyCode == ENTER)
    initial();
  if(keyCode == SHIFT)
    setup();
    
  println(n);

}
