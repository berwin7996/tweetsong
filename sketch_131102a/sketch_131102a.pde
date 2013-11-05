//Build an ArrayList to hold all of the words that we get from the imported tweets
ArrayList<String> words = new ArrayList();
//A list of target words to search for in the query (in this case, organelles)
//String[] targetWords ={"mitochondria", "chloroplast", "cellwall", "endoplasmic", "lysosome", "membrane", "nucleus", "ribosome"};
String[] targetWords ={"packers", "bears"};

int count = 0;
 
void setup() {
  //Set the size of the stage, and the background to black.
  size(550,550);
  background(0);
  frameRate(30);
  smooth();
  
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
  
  query1.count(500); //number of tweets to receive
  query2.count(500); 
  for(int i = 0; i < targetWords.length; i++){
    println(targetWords[i]);
  }
 
  //Try making the query request.
  try {
    QueryResult result1 = twitter.search(query1);
    QueryResult result2 = twitter.search(query2);
    ArrayList tweets1 = (ArrayList) result1.getTweets();
    ArrayList tweets2 = (ArrayList) result2.getTweets();
    
    fillWords(tweets1);
    fillWords(tweets2);
   
     /*
    for (int i = 0; i < tweets1.size(); i++) {
      Status t = (Status) tweets1.get(i);
      //String user = t.getUser().getName();
      String msg = t.getText();
      
 
      //Date d = t.getCreatedAt();
      //println("Tweet by " + user + " at " + d + ": " + msg);
      //println(msg);
       
      
      //Break the tweet into words
      String[] input = msg.split(" ");
      for (int j = 0;  j < input.length; j++) {
       //Put each word into the words ArrayList
       for(int k = 0; k < targetWords.length; k++){
         if(input[j].toLowerCase().contains(targetWords[k])){
           words.add(input[j]);
           //break;
         }
         //words.add(msg);
       }
      }
      */
      
//      for(int a = 0; a < words.size(); a++){
//        println(words.get(a));
//      }
    }
  
  catch (TwitterException te) {
    println("Couldn't connect: " + te);
  }
}
 
void draw() {
  //Draw a faint black rectangle over what is currently on the stage so it fades over time.
  fill(0,1);
  rect(0,0,width,height);
   
  //Draw a word from the list of words that we've built
  //doesn't repeat using if condition
  if(count < words.size()){
    //int i = (frameCount % words.size());
    String word = words.get(count);
     
    //Put it somewhere random on the stage, with a random size and colour
    fill(255,random(50,150));
    textSize(random(10,30));
    text(word, random(width), random(height));
    count++;
  }
}

void fillWords(ArrayList tweets){
  for (int i = 0; i < tweets.size(); i++) {
      Status t = (Status) tweets.get(i);
      //String user = t.getUser().getName();
      String msg = t.getText();
      //Date d = t.getCreatedAt();
      //println("Tweet by " + user + " at " + d + ": " + msg);
      //println(msg);
       
       
      //Break the tweet into words
      String[] input = msg.split(" ");
      for (int j = 0;  j < input.length; j++) {
       //Put each word into the words ArrayList
       for(int k = 0; k < targetWords.length; k++){
         if(input[j].toLowerCase().contains(targetWords[k])){
           words.add(input[j]);
           //break;
         }
         //words.add(msg);
       }
      }
      
//      for(int a = 0; a < words.size(); a++){
//        println(words.get(a));
//      }
    }
}
