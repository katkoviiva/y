#include <Adafruit_NeoPixel.h>
#ifdef __AVR__
 #include <avr/power.h> // Required for 16 MHz Adafruit Trinket
#endif

// Which pin on the Arduino is connected to the NeoPixels?
#define PIN        11 // On Trinket or Gemma, suggest changing this to 1

// How many NeoPixels are attached to the Arduino?
#define NUMPIXELS 300 // Popular NeoPixel ring size

// When setting up the NeoPixel library, we tell it how many pixels,
// and which pin to use to send signals. Note that for older NeoPixel
// strips you might need to change the third parameter -- see the
// strandtest example for more information on possible values.
Adafruit_NeoPixel pixels(NUMPIXELS, PIN, NEO_GRB + NEO_KHZ800);

#define DELAYVAL 500 // Time (in milliseconds) to pause between pixels

void setup() {
  // These lines are specifically to support the Adafruit Trinket 5V 16 MHz.
  // Any other board, you can remove this part (but no harm leaving it):
#if defined(__AVR_ATtiny85__) && (F_CPU == 16000000)
  clock_prescale_set(clock_div_1);
#endif
  // END of Trinket-specific code.

  pixels.begin(); // INITIALIZE NeoPixel strip object (REQUIRED)
}

void loop() {
  pixels.clear(); // Set all pixel colors to 'off'

  // The first NeoPixel in a strand is #0, second is 1, all the way up
  pixels.setPixelColor(0, pixels.Color(14, 15, 0));
  pixels.setPixelColor(1, pixels.Color(14, 15, 0));
  pixels.setPixelColor(2, pixels.Color(14, 15, 0));
  pixels.setPixelColor(3, pixels.Color(14, 15, 0));
  pixels.setPixelColor(4, pixels.Color(14, 15, 0));
  pixels.setPixelColor(5, pixels.Color(14, 15, 0));
  pixels.setPixelColor(6, pixels.Color(14, 15, 0));
  pixels.setPixelColor(7, pixels.Color(14, 15, 0));
  pixels.setPixelColor(8, pixels.Color(14, 15, 0));
  pixels.setPixelColor(9, pixels.Color(14, 15, 0));
  pixels.setPixelColor(10, pixels.Color(14, 15, 0));
  pixels.setPixelColor(11, pixels.Color(14, 15, 0));
  pixels.setPixelColor(12, pixels.Color(14, 15, 0));
  pixels.setPixelColor(13, pixels.Color(14, 15, 0));
  pixels.setPixelColor(14, pixels.Color(14, 15, 0));
  pixels.setPixelColor(15, pixels.Color(14, 15, 0));
  pixels.setPixelColor(16, pixels.Color(14, 15, 0));
  pixels.setPixelColor(17, pixels.Color(14, 15, 0));
  pixels.setPixelColor(18, pixels.Color(14, 15, 0));
  pixels.setPixelColor(19, pixels.Color(14, 15, 0));
  pixels.setPixelColor(20, pixels.Color(14, 15, 0));
  pixels.setPixelColor(21, pixels.Color(14, 15, 0));
  pixels.setPixelColor(22, pixels.Color(14, 15, 0));
  pixels.setPixelColor(23, pixels.Color(14, 15, 0));
  pixels.setPixelColor(24, pixels.Color(14, 15, 0));
  pixels.setPixelColor(25, pixels.Color(14, 15, 0));
  pixels.setPixelColor(26, pixels.Color(14, 15, 0));
  pixels.setPixelColor(27, pixels.Color(14, 15, 0));
  pixels.setPixelColor(28, pixels.Color(14, 15, 0));
  pixels.setPixelColor(29, pixels.Color(14, 15, 0));
  pixels.setPixelColor(30, pixels.Color(14, 15, 0));
  pixels.setPixelColor(31, pixels.Color(14, 15, 0));
  pixels.setPixelColor(32, pixels.Color(14, 15, 0));
  pixels.setPixelColor(33, pixels.Color(14, 15, 0));
  pixels.setPixelColor(34, pixels.Color(14, 15, 0));
  pixels.setPixelColor(35, pixels.Color(14, 15, 0));
  pixels.setPixelColor(36, pixels.Color(14, 15, 0));
  pixels.setPixelColor(37, pixels.Color(14, 15, 0));
  pixels.setPixelColor(38, pixels.Color(14, 15, 0));
  pixels.setPixelColor(39, pixels.Color(14, 15, 0));
  pixels.setPixelColor(40, pixels.Color(14, 15, 0));
  pixels.setPixelColor(41, pixels.Color(14, 15, 0));
  pixels.setPixelColor(42, pixels.Color(14, 15, 0));
  pixels.setPixelColor(43, pixels.Color(14, 15, 0));
  pixels.setPixelColor(44, pixels.Color(14, 15, 0));
  pixels.setPixelColor(45, pixels.Color(14, 15, 0));
  pixels.setPixelColor(46, pixels.Color(14, 15, 0));
  pixels.setPixelColor(47, pixels.Color(14, 15, 0));
  pixels.setPixelColor(48, pixels.Color(14, 15, 0));
  pixels.setPixelColor(49, pixels.Color(14, 15, 0));
  pixels.setPixelColor(50, pixels.Color(14, 15, 0));
  pixels.setPixelColor(51, pixels.Color(14, 15, 0));
  pixels.setPixelColor(52, pixels.Color(14, 15, 0));
  pixels.setPixelColor(53, pixels.Color(14, 15, 0));
  pixels.setPixelColor(54, pixels.Color(14, 15, 0));
  pixels.setPixelColor(55, pixels.Color(14, 15, 0));
  pixels.setPixelColor(56, pixels.Color(14, 15, 0));
  pixels.setPixelColor(57, pixels.Color(14, 15, 0));
  pixels.setPixelColor(58, pixels.Color(14, 15, 0));
  pixels.setPixelColor(59, pixels.Color(14, 15, 0));
  pixels.setPixelColor(60, pixels.Color(14, 15, 0));
  pixels.setPixelColor(61, pixels.Color(14, 15, 0));
  pixels.setPixelColor(62, pixels.Color(14, 15, 0));
  pixels.setPixelColor(63, pixels.Color(14, 15, 0));
  pixels.setPixelColor(64, pixels.Color(14, 15, 0));
  pixels.setPixelColor(65, pixels.Color(14, 15, 0));
  pixels.setPixelColor(66, pixels.Color(14, 15, 0));
  pixels.setPixelColor(67, pixels.Color(14, 15, 0));
  pixels.setPixelColor(68, pixels.Color(14, 15, 0));
  pixels.setPixelColor(64, pixels.Color(14, 15, 0));
  pixels.setPixelColor(66, pixels.Color(14, 15, 0));
  pixels.setPixelColor(67, pixels.Color(14, 15, 0));
  pixels.setPixelColor(68, pixels.Color(14, 15, 0));
  pixels.setPixelColor(69, pixels.Color(14, 15, 0));
  pixels.setPixelColor(70, pixels.Color(14, 15, 0));
  pixels.setPixelColor(71, pixels.Color(14, 15, 0));
  pixels.setPixelColor(72, pixels.Color(14, 15, 0));
  pixels.setPixelColor(73, pixels.Color(14, 15, 0));
  pixels.setPixelColor(74, pixels.Color(14, 15, 0));
  pixels.setPixelColor(75, pixels.Color(14, 15, 0));
  pixels.setPixelColor(76, pixels.Color(14, 15, 0));
  pixels.setPixelColor(77, pixels.Color(14, 15, 0));
  pixels.setPixelColor(78, pixels.Color(14, 15, 0));
  pixels.setPixelColor(79, pixels.Color(14, 15, 0));
  pixels.setPixelColor(80, pixels.Color(14, 15, 0));
  pixels.setPixelColor(81, pixels.Color(14, 15, 0));
  pixels.setPixelColor(82, pixels.Color(14, 15, 0));
  pixels.setPixelColor(83, pixels.Color(14, 15, 0));
  pixels.setPixelColor(84, pixels.Color(14, 15, 0));
  pixels.setPixelColor(85, pixels.Color(14, 15, 0));
  pixels.setPixelColor(86, pixels.Color(14, 15, 0));
  pixels.setPixelColor(87, pixels.Color(14, 15, 0));
  pixels.setPixelColor(88, pixels.Color(14, 15, 0));
  pixels.setPixelColor(89, pixels.Color(14, 15, 0));
  pixels.setPixelColor(90, pixels.Color(14, 15, 0));
  pixels.setPixelColor(91, pixels.Color(14, 15, 0));
  pixels.setPixelColor(92, pixels.Color(14, 15, 0));
  pixels.setPixelColor(93, pixels.Color(14, 15, 0));
  pixels.setPixelColor(94, pixels.Color(14, 15, 0));
  pixels.setPixelColor(95, pixels.Color(14, 15, 0));
  pixels.setPixelColor(96, pixels.Color(14, 15, 0));
  pixels.setPixelColor(97, pixels.Color(14, 15, 0));
  pixels.setPixelColor(98, pixels.Color(14, 15, 0));
  pixels.setPixelColor(99, pixels.Color(14, 15, 0));
  pixels.setPixelColor(100, pixels.Color(14, 15, 0));
  pixels.setPixelColor(101, pixels.Color(14, 15, 0));
  pixels.setPixelColor(102, pixels.Color(14, 15, 0));
  pixels.setPixelColor(103, pixels.Color(14, 15, 0));
  pixels.setPixelColor(104, pixels.Color(14, 15, 0));
  pixels.setPixelColor(105, pixels.Color(14, 15, 0));
  pixels.setPixelColor(106, pixels.Color(14, 15, 0));
  pixels.setPixelColor(107, pixels.Color(14, 15, 0));
  pixels.setPixelColor(108, pixels.Color(14, 15, 0));
  pixels.setPixelColor(109, pixels.Color(14, 15, 0));
  pixels.setPixelColor(110, pixels.Color(14, 15, 0));
  pixels.setPixelColor(111, pixels.Color(14, 15, 0));
  pixels.setPixelColor(112, pixels.Color(14, 15, 0));
  pixels.setPixelColor(113, pixels.Color(14, 15, 0));
  pixels.setPixelColor(114, pixels.Color(14, 15, 0));
  pixels.setPixelColor(115, pixels.Color(14, 15, 0));
  pixels.setPixelColor(116, pixels.Color(14, 15, 0));
  pixels.setPixelColor(117, pixels.Color(14, 15, 0));
  pixels.setPixelColor(118, pixels.Color(14, 15, 0));
  pixels.setPixelColor(119, pixels.Color(14, 15, 0));
  pixels.setPixelColor(120, pixels.Color(14, 15, 0));
  pixels.setPixelColor(121, pixels.Color(14, 15, 0));
  pixels.setPixelColor(122, pixels.Color(14, 15, 0));
  pixels.setPixelColor(123, pixels.Color(14, 15, 0));
  pixels.setPixelColor(124, pixels.Color(14, 15, 0));
  pixels.setPixelColor(125, pixels.Color(14, 15, 0));
  pixels.setPixelColor(126, pixels.Color(14, 15, 0));
  pixels.setPixelColor(127, pixels.Color(14, 15, 0));
  pixels.setPixelColor(128, pixels.Color(14, 15, 0));
  pixels.setPixelColor(129, pixels.Color(14, 15, 0));
  pixels.setPixelColor(130, pixels.Color(14, 15, 0));
  pixels.setPixelColor(131, pixels.Color(14, 15, 0));
  pixels.setPixelColor(132, pixels.Color(14, 15, 0));
  pixels.setPixelColor(133, pixels.Color(14, 15, 0));
  pixels.setPixelColor(134, pixels.Color(14, 15, 0));
  pixels.setPixelColor(135, pixels.Color(14, 15, 0));
  pixels.setPixelColor(136, pixels.Color(14, 15, 0));
  pixels.setPixelColor(137, pixels.Color(14, 15, 0));
  pixels.setPixelColor(138, pixels.Color(14, 15, 0));
  pixels.setPixelColor(139, pixels.Color(14, 15, 0));
  pixels.setPixelColor(140, pixels.Color(14, 15, 0));
  pixels.setPixelColor(141, pixels.Color(14, 15, 0));
  pixels.setPixelColor(142, pixels.Color(14, 15, 0));
  pixels.setPixelColor(143, pixels.Color(14, 15, 0));
  pixels.setPixelColor(144, pixels.Color(14, 15, 0));
  pixels.setPixelColor(145, pixels.Color(14, 15, 0));
  pixels.setPixelColor(146, pixels.Color(14, 15, 0));
  pixels.setPixelColor(147, pixels.Color(14, 15, 0));
  pixels.setPixelColor(148, pixels.Color(14, 15, 0));
  pixels.setPixelColor(149, pixels.Color(14, 15, 0));
  pixels.setPixelColor(150, pixels.Color(14, 15, 0));
  pixels.setPixelColor(151, pixels.Color(14, 15, 0));
  pixels.setPixelColor(152, pixels.Color(14, 15, 0));
  pixels.setPixelColor(153, pixels.Color(14, 15, 0));
  pixels.setPixelColor(154, pixels.Color(14, 15, 0));
  pixels.setPixelColor(155, pixels.Color(14, 15, 0));
  pixels.setPixelColor(156, pixels.Color(14, 15, 0));
  pixels.setPixelColor(157, pixels.Color(14, 15, 0));
  pixels.setPixelColor(158, pixels.Color(14, 15, 0));
  pixels.setPixelColor(159, pixels.Color(14, 15, 0));
  pixels.setPixelColor(160, pixels.Color(14, 15, 0));
    pixels.show();   // Send the updated pixel colors to the hardware.to the count of pixels minus one.
  
}
