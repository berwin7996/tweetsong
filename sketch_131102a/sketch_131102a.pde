import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress broadcastLocation;

String ip = "127.0.0.1";
int port = 9002;
int incoming_port = 12312;


//Build an ArrayList to hold all of the words that we get from the imported tweets
ArrayList<String> words = new ArrayList();
//A list of target words to search for in the query (in this case, organelles)
//String[] targetWords ={"mitochondria", "chloroplast", "cellwall", "endoplasmic", "lysosome", "membrane", "nucleus", "ribosome"};
String[] targetWords ={"packers", "bears", "vikings", "lions"};
float[] count = {0,0,0,0};//num of each tweet

int numBalls = 4;
float spring = 0.09;
float gravity = 0.0;
float friction = -0.9;
Ball[] balls = new Ball[numBalls];
 
void setup() {
  //Set the size of the stage, and the background to black.
  size(666, 666);
  background(255);
  frameRate(60);
  noStroke();
  fill(255, 204);
  smooth();
  
  oscP5 = new OscP5(this, incoming_port);
  broadcastLocation = new NetAddress(ip, port);
  //sendMsg("/vol", 0.2);
  //sendMsg("/bypass", 1);

  
  //initialize balls
  for (int i = 0; i < numBalls; i++) {
    balls[i] = new Ball(random(width), random(height), random(30, 70), i, balls);
  }
  
  //Credentials
  ConfigurationBuilder cb = new ConfigurationBuilder();
  cb.setOAuthConsumerKey("Mdzh2RyFmTINcRfpRiJpIw");
  cb.setOAuthConsumerSecret("X0y9t9WB9tYizi1nVa6SgbER46msyX4L9IfGb9jllc");
  cb.setOAuthAccessToken("17716129-J1usf7Y0fLKurc4CgmqQ3T9cNOMNRDteFVTIVOsSo");
  cb.setOAuthAccessTokenSecret("YCmSboF7iyERupRUJJkZQvHZHKPMtUwaHKIBlkWpsFR8s");
 
  //Make the twitter object and prepare the query
  Twitter twitter = new TwitterFactory(cb.build()).getInstance();
  Query query1 = new Query("#bears");
  Query query2 = new Query("#packers");
  Query query3 = new Query("#vikings");
  Query query4 = new Query("#lions");
  
  query1.count(300); //number of tweets to receive
  query2.count(300); 
  query3.count(300); 
  query4.count(300); 
 
  //Try making the query request.
  try {
    QueryResult result1 = twitter.search(query1);
    QueryResult result2 = twitter.search(query2);
    QueryResult result3 = twitter.search(query3);
    QueryResult result4 = twitter.search(query4);
    ArrayList tweets1 = (ArrayList) result1.getTweets();
    ArrayList tweets2 = (ArrayList) result2.getTweets();
    ArrayList tweets3 = (ArrayList) result3.getTweets();
    ArrayList tweets4 = (ArrayList) result4.getTweets();
    
    fillWords(tweets1, 0);
    fillWords(tweets2, 1);
    fillWords(tweets3, 2);
    fillWords(tweets4, 3);
  }
  
  catch (TwitterException te) {
    println("Couldn't connect: " + te);
  }
}
 
void sendMsg(String label, float data) {
  OscMessage msg = new OscMessage(label);
  msg.add(data);
  oscP5.send(msg, broadcastLocation);
}

void mousePressed(){ //invokes movements of balls
  for(int i = 0; i < numBalls; i++){
    balls[i].explode(mouseX, mouseY);
  }
}

void draw() {
  
  sendMsg("/freq", 60 + (balls[1].getY()/height)*40);
  //println(60 + (balls[1].getY()/height)*40);
  background(0);
  for (int i = 0; i < numBalls; i++) { //drawing balls
    if(i == 0) fill(0,255,0);  //changes the colors of the balls
    else if(i == 1) fill(0,0,255);
    else if(i == 2) fill(255,0,255);
    else fill(0,255,255);
    
    if(balls[i].getDiameter() < count[i])
      balls[i].setDiameter(balls[i].getDiameter() + .05);         
    balls[i].collide();
    balls[i].move();
    balls[i].display();  
  }
  
}

void fillWords(ArrayList tweets, int countInd){
  for (int i = 0; i < tweets.size(); i++) {
      Status t = (Status) tweets.get(i);
      String msg = t.getText();
              
      //Break the tweet into words
      String[] input = msg.split(" ");
      for (int j = 0;  j < input.length; j++) {
       //Put each word into the words ArrayList
       for(int k = 0; k < targetWords.length; k++){
         if(input[j].toLowerCase().contains(targetWords[k])){
           words.add(input[j]);
           count[countInd]++;
           //break;
         }
         //words.add(msg);
       }
      }
    }
}

class Ball {
  
  float x, y;
  float diameter;
  float vx = 0;
  float vy = 0;
  int id;
  Ball[] others;
 
  Ball(float xin, float yin, float din, int idin, Ball[] oin) {
    x = xin;
    y = yin;
    diameter = din;
    id = idin;
    others = oin;
  } 
  
  void explode(float xloc, float yloc){ //give vel based on where clicked
    vx = (x - xloc)/50;
    vy = (y - yloc)/50;
  }
  
  void collide() {
    for (int i = id + 1; i < numBalls; i++) {
      float dx = others[i].x - x;
      float dy = others[i].y - y;
      float distance = sqrt(dx*dx + dy*dy);
      float minDist = others[i].diameter/2 + diameter/2;
      if (distance < minDist) { 
        float angle = atan2(dy, dx);
        float targetX = x + cos(angle) * minDist;
        float targetY = y + sin(angle) * minDist;
        float ax = (targetX - others[i].x) * spring;
        float ay = (targetY - others[i].y) * spring;
        vx -= ax;
        vy -= ay;
        others[i].vx += ax;
        others[i].vy += ay;
        
        sendMsg("/freq", (x +y)/100);
        //sendMsg("/vol", (float)(float)(height - mouseY)/(float) height);
        sendMsg("/bang", 1);
      }
      
    }   
  }
  
  void move() {
    vy += gravity;
    x += vx;
    y += vy;
    if (x + diameter/2 > width) {
      x = width - diameter/2;
      vx *= friction; 
    }
    else if (x - diameter/2 < 0) {
      x = diameter/2;
      vx *= friction;
    }
    if (y + diameter/2 > height) {
      y = height - diameter/2;
      vy *= friction; 
    } 
    else if (y - diameter/2 < 0) {
      y = diameter/2;
      vy *= friction;
    }
  }
  
  void display() {
    ellipse(x, y, diameter, diameter);
  }
  
  void setDiameter(float dim){
    diameter = dim;
  }
  
  float getDiameter(){
    return diameter;
  }
  
  float getY(){
    return y;
  }
  
}
