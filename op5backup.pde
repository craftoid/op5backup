
//////////////////////////////////////////
//                                      //
//        Open Processing Backup        //
//                                      //
//////////////////////////////////////////

// (c) Martin Schneider 2012

// Quick and dirty script to backup all your 
// sketches from OpenProcessing.org

// Please use this script with great responsibility!

// Sinan, who runs Openprocessing has to pay for 
// the bandwidth and will have to close the site down, 
// if he can't afford it anymore.

// Consider supporting Openprocessing
// by signing up for a Plus+ Membership:
// https://www.openprocessing.org/membership/

// HOW TO USE:

// 0. Replace your User ID below.

int userid = 1;

// 1. run the sketch
// 2. press [l] to list the sketches
// 3. press [s] to save the sketches


Portfolio portfolio;

String host = "http://www.openprocessing.org/";
String tmp;
String target;

void setup() {
  
  tmp = savePath("tmp");
  target = savePath("download");
  
}

void draw() {}

void keyPressed() {
  
  switch(key) {
    
    case 'l': 
      println( "LOL: Load Our List ( userid " + userid + " )" );
      portfolio = new Portfolio( userid );
      println( portfolio.username + "has " + portfolio.size() + " sketches." );
      break;
      
    case 's':
      if( portfolio != null ) {
        println( "SOS: Save Our Sketches ( This may take a while )" );
        portfolio.download();
      }
      break;
      
  }
  
}

// extending TreeSet so we can maintain a sorted set of sketches
class Portfolio extends TreeSet<Sketch> {
  
  int userid;
  String username;
  String userdir;
  
  Portfolio(int userid) { 
    getData(userid);
    userdir = target + File.separator + username;
  }
  
  void getData( int userid ) {
    
    String url = host + "user/" + userid;
    String[] matches;
    String[] index = loadStrings( url );

    println( url );
    
    for( int i = 0; i < index.length; i++ ) {
      
      // get sketch ids
      matches = match(index[i], "<a href=\"/sketch/(.*?)\">");
      if( matches != null) {
        add( new Sketch( matches[1] ));
      }
      
      // get username
      matches = match(index[i], "<title>The Processing Portfolio of (.*?) - OpenProcessing</title>");
      if( matches != null ) {
        username = matches[1]; 
      }
      
    }
 
  }

  
  void download() {
    
    File tmpdir = new File( tmp );
    
    println( "Creating temp directory " + tmp );
    tmpdir.mkdirs();
   
    for( Sketch s : this ) {
      s.download( userdir );
    }
       
    println( "Removing temp Directory" ); 
    tmpdir.delete();
    
   }
  
}


// implementing the comparable interface, so sketches can be sorted by their id
class Sketch implements Comparable<Sketch> {
  
  int id;
  
  Sketch( String id ) {
    this.id = int(id); 
  }
  
  int compareTo( Sketch s ) {
    return Float.compare(id, s.id);
  }
  
  void download( String target ) {
    
    String url = host + "sketch/" + id + "/download/sketch.zip";
    String tmpfile = savePath( tmp + File.separator + "sketch.zip" );
    
    println( "Downloading Sketch " + this.id + " : " + url + " --> " + tmp );
    byte[] file = loadBytes( url );

    if(file != null ) {
    
      saveBytes( tmpfile, file );
    
      println( "Extracting" ); 
      unzip(tmpfile, savePath( target ));
    
      println( "Cleaning up" );
	  new File( tmpfile ).delete();
      
    } else {
      
      println( "failed to download URL.");
      println( "Maybe it's a Processing.js sketch ( download not yet implemented )." );  
      
    }
    

    
  }
  
}

void unzip(String zipfile, String target) {
  
  try {
    doUnzip(zipfile, target);
  } catch (IOException e) {}
  
}
  
