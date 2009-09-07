/*
* Processing sketch to load an animated GIF and save it as Rainbowduino hex codes
* Uses the animated GIF library from http://www.extrapixel.ch/processing/gifAnimation/
* See also this thread: http://processing.org/discourse/yabb2/YaBB.pl?board=LibraryProblems;action=display;num=1199371244;start=0
*
* All frames in the animated GIF file must be 8x8 pixels, there will be an error if they aren't.
*/

import gifAnimation.*;

PImage[] animation;
boolean pause = false;
String inputFilename = "";

String changeExtension(String originalName, String newExtension) {
    int lastDot = originalName.lastIndexOf(".");
    if (lastDot != -1) {
        return originalName.substring(0, lastDot) + newExtension;
    } else {
        return originalName + newExtension;
    }
}//end changeExtension

public void setup() {
  size(200, 200);
  frameRate(100);
  
  println("gifAnimation library " + Gif.version());
  println("Select an 8x8 animated GIF to convert");
  // create the GifAnimation object for playback
  inputFilename = selectInput("Select an 8x8 animated GIF to convert");
  animation = Gif.getPImages(this, inputFilename);
  println("\nMoving the mouse across the window displays frames in the animation");
  println("Click anywhere in the window to convert the GIF to C-formatted data");
}

void draw() {
  background(255 / (float)height * mouseY);
  // This displays a frame of the animation depending on where the mouse is in the window
  int dispSize = 64;
  image(animation[(int) (animation.length / (float) (width) * mouseX)], width/2 - 10 - dispSize/2, height / 2 - dispSize / 2, dispSize, dispSize);
}

void mousePressed() {
  String outputFilename = changeExtension(inputFilename, ".h");
  println("Saving...");
  OutputStream os = createOutput(outputFilename);
  PrintWriter wr = new PrintWriter(os);
  try {
    wr.println("#ifndef ANIMDATA\n#define ANIMDATA");
    wr.println("// generated from " + inputFilename);
    // generate constant for number of frames
    wr.println("#define PREFAB_FRAMES " + animation.length);
    // generate the declaration with the right number of frames
    wr.println("unsigned char Prefabnicatel[PREFAB_FRAMES][3][8][4] PROGMEM =\n{");
      for (int i=0; i<animation.length; i++) {
        wr.println("{\n// frame " + (i+1));
        PImage frame = animation[i];
        dumpFrame(frame, i, wr);
        wr.println("}, // end frame " + (i+1));
      }
   wr.println("};");
   wr.println("#endif");
  println("Saved to " + outputFilename);   
  }
  finally {
    try {wr.close(); os.close();} catch (Throwable e) {};
  }
}

void dumpFrame(PImage frame, int frameNumber, PrintWriter wr) {
      String[] colourNames = {"green", "red", "blue"};
      frame.loadPixels();
      if (frame.height != 8 || frame.width != 8) {
        throw new RuntimeException("GIF frame " + frameNumber + " is " + frame.width + "x" + frame.height + ", must be 8x8");
      }
      // Separate array for each colour, GRB order
      for (int grb = 0; grb < 3; grb++) {
        wr.println("{ //" + colourNames[grb]);
        for (int row=0; row < frame.height; row++) {
          wr.print("{");
          for (int col=0; col<frame.width; col++) {
            color c = frame.get(col, row);
            float pixel=0;
            switch(grb) {
              case 0: pixel = green(c); break;
              case 1: pixel = red(c); break;
              case 2: pixel = blue(c); break;
            }
            // Convert 8-bit (0-255) colour to 4-bit
            int intensity = floor(pixel) >> 4; // TODO could improve scaling!
            if (col % 2 == 0) {
              wr.print("0x"+hex(intensity,1));
            }
            else {
              wr.print(hex(intensity,1)+",");
            }
          }
          wr.println("},");
        }
        wr.println("},");
    }
}


void keyPressed() {

}
