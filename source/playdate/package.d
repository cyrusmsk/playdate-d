/// See_Also: <a href="https://sdk.play.date/1.12.3/Inside Playdate with C.html">Inside Playdate with C</a> - Official Playdate SDK Documentation
///
/// Authors: Chance Snow
/// Copyright: $(UL
///   $(LI Copyright © 2014-2017 Panic, Inc. All rights reserved.)
///   $(LI Copyright © 2022 Chance Snow.)
/// )
/// License: MIT License
module playdate;

import std.meta : Alias;
import core.stdc.stdarg : va_list;
import core.stdc.stdlib : strtol;
import core.stdc.string : strcmp;

@nogc nothrow:

/// Attribute specifying which version a symbol was added to the Playdate C SDK.
struct AddedIn {
  ///
  this(ubyte major, ubyte minor, ubyte patch = 0) {}
}

alias LCDPattern = ubyte[16];
alias LCDColor = ubyte;

alias LCDBitmap = Alias!(void*);
alias LCDBitmapTable = Alias!(void*);
alias LCDFont = Alias!(void*);
alias LCDFontData = Alias!(void*);
alias LCDFontPage = Alias!(void*);
alias LCDFontGlyph = Alias!(void*);
alias LCDVideoPlayer = Alias!(void*);
alias PDMenuItem = Alias!(void*);
alias SDFile = Alias!(void*);

///
enum PDButtons : int {
  ///
  buttonLeft  = (1<<0),
  ///
  buttonRight = (1<<1),
  ///
  buttonUp    = (1<<2),
  ///
  buttonDown  = (1<<3),
  ///
  buttonB     = (1<<4),
  ///
  buttonA     = (1<<5)
}

///
enum PDLanguage {
	///
  english,
	///
  japanese,
	///
  unknown,
}

///
@AddedIn(1, 13)
struct PDDateTime {
  ///
  ushort year;
  /// 1-12
  ubyte month;
  /// 1-31
  ubyte day;
  /// 1 = Monday, 7 = Sunday
  ubyte weekday;
  /// 0-23
  ubyte hour;
  ///
  ubyte minute;
  ///
  ubyte second;
}

///
enum PDPeripherals : int {
	none            = 0,
	accelerometer   = (1<<0),
	allPeripherals  = 0xffff
}

///
struct LCDRect {
  @nogc nothrow:

  /// Left edge along x-axis.
	int left;
	/// Right edge along x-axis, not inclusive.
  int right;
  /// Top edge along y-axis.
	int top;
	/// Bottom edge along y-axis, not inclusive.
  int bottom;

  ///
	pragma(inline) LCDRect translate(int dx, int dy) const {
		return LCDRect(this.left + dx, this.right + dx, this.top + dy, this.bottom + dy);
	}
}

/// Remarks: Assumes width and height are positive.
pragma(inline) LCDRect makeRect(int x, int y, int width, int height) {
	return LCDRect(x, x + width, y, y + height);
}

unittest {
  const rect = makeRect(5, 10, 20, 40);
  assert(rect.left == 5);
  assert(rect.right == 25);
  assert(rect.top == 10);
  assert(rect.bottom == 50);

  const translatedRect = rect.translate(20, 20);
  assert(translatedRect.left == 25);
  assert(translatedRect.right == 45);
  assert(translatedRect.top == 30);
  assert(translatedRect.bottom == 70);
}

///
enum LCD_COLUMNS =	400;
///
enum LCD_ROWS =		240;
///
enum LCD_ROWSIZE =	52;
///
enum LCD_SCREEN_RECT = makeRect(0, 0, LCD_COLUMNS, LCD_ROWS);

///
enum LCDBitmapDrawMode {
	copy,
	whiteTransparent,
	blackTransparent,
	fillWhite,
	fillBlack,
	xor,
	nxor,
	inverted
}

///
enum LCDBitmapFlip {
	unflipped,
	flippedX,
	flippedY,
	flippedXy
}

///
enum LCDSolidColor {
	black,
	white,
	clear,
	xor
}

///
enum LCDLineCapStyle {
	butt,
	square,
	round
}

///
enum PDStringEncoding {
	asciiEncoding,
	utf8Encoding,
	_16BitLeEncoding
}

///
enum LCDPolygonFillRule {
	nonZero,
	evenOdd
}

///
enum PDSystemEvent {
	init,
	initLua,
	lock,
	unlock,
	pause,
	resume,
	terminate,
	keyPressed,
	keyReleased,
	lowPower
}

///
alias PDCallbackFunction = int function(void* userData) @nogc;
///
alias PDMenuItemCallbackFunction = void function(void* userdata) @nogc;
///
alias PDButtonCallbackFunction = int function(PDButtons button, int down, uint when, void* userdata) @nogc;

/// Fill the passed-in `left` buffer (and `right` if it’s a stereo source) with `len` samples each and return `true`, or `false` if the source is silent through the cycle.
alias AudioSourceFunction = bool function(void* context, short* left, short* right, int len) @nogc;

/// Called with the recorded audio data, a monophonic stream of samples.
///
/// Return `true` to continue recording, `false` to stop recording.
/// See_Also: `Sound.setMicCallback`
alias RecordCallback = bool function (void* context, short* buffer, int length) @nogc;

/// `bufactive` is `true` if samples have been set in the left or right buffers.
/// Return `true` if it changed the buffer samples, otherwise `false`.
/// `left` and `right` (if the effect is on a stereo channel) are sample buffers in signed Q8.24 format.
alias effectProc = bool function(SoundEffect e, int* left, int* right, int nsamples, bool bufactive) @nogc;

extern (C):

///
struct System {
  @nogc nothrow:

	/// ptr = NULL -> malloc, size = 0 -> free
	void* function(void* ptr, size_t size) realloc;
  ///
	int function(char **ret, const char *fmt, ...) formatString;
  ///
	void function(const char* fmt, ...) logToConsole;
  ///
	void function(const char* fmt, ...) error;
	///
  PDLanguage function() getLanguage;
	///
  uint function() getCurrentTimeMilliseconds;
	///
  uint function(uint *milliseconds) getSecondsSinceEpoch;
	///
  void function(int x, int y) drawFPS;

	///
  void function(PDCallbackFunction update, void* userdata) setUpdateCallback;
	///
  void function(PDButtons* current, PDButtons* pushed, PDButtons* released) getButtonState;
	///
  void function(PDPeripherals mask) setPeripheralsEnabled;
	/// Returns the last-read accelerometer data.
  void function(float* outx, float* outy, float* outz) getAccelerometer;

	/// Returns the angle change of the crank since the last time this function was called. Negative values are anti-clockwise.
  float function() getCrankChange;
	/// Returns the current position of the crank, in the range 0-360.
  /// Zero is pointing up, and the value increases as the crank moves clockwise, as viewed from the right side of the device.
  float function() getCrankAngle;
	/// Returns `true` or `false` indicating whether or not the crank is folded into the unit.
  bool function() isCrankDocked;
	/// Returns the previous value for this setting.
  /// Remarks:
  /// 0.12 adds sound effects for various system events, such as the menu opening or closing, USB cable plugged or
  /// unplugged, and the crank docked or undocked. Since games can receive notification of the crank docking and
  /// undocking, and may incorporate this into the game, we’ve provided a function for muting the default sounds for
  /// these events.
	int function(int flag) setCrankSoundsDisabled;

	///
  int function() getFlipped;
	/// Disables or enables the 60 second auto lock feature. When called, the timer is reset to 60 seconds.
  /// Remarks:
  /// As of 0.10.3, the device will automatically lock if the user doesn’t press any buttons or use the crank for more
  /// than 60 seconds. In order for games that expect longer periods without interaction to continue to function, it is
  /// possible to manually disable the auto lock feature. Note that when disabling the timeout, developers should take
  /// care to re-enable the timeout when appropiate.
  void function(bool disable) setAutoLockDisabled;

	///
  void function(LCDBitmap* bitmap, int xOffset) setMenuImage;
	///
  PDMenuItem* function(const char *title, PDMenuItemCallbackFunction callback, void* userdata) addMenuItem;
	///
  PDMenuItem* function(
		const char *title, int value, PDMenuItemCallbackFunction callback, void* userdata
	) addCheckmarkMenuItem;
	///
  PDMenuItem* function(
		const char *title, const char** optionTitles, int optionsCount, PDMenuItemCallbackFunction f, void* userdata
	) addOptionsMenuItem;
	///
  void function() removeAllMenuItems;
	///
  void function(PDMenuItem *menuItem) removeMenuItem;
	///
  int function(PDMenuItem *menuItem) getMenuItemValue;
	///
  void function(PDMenuItem *menuItem, int value) setMenuItemValue;
	///
  const(char*) function(PDMenuItem *menuItem) getMenuItemTitle;
	///
  void function(PDMenuItem *menuItem, const char *title) setMenuItemTitle;
	///
  void* function(PDMenuItem *menuItem) getMenuItemUserdata;
	///
  void function(PDMenuItem *menuItem, void *ud) setMenuItemUserdata;

	///
  bool function() getReduceFlashing;

	///
  @AddedIn(1, 1)
  float function() getElapsedTime;
	///
  @AddedIn(1, 1)
  void function() resetElapsedTime;

	///
  @AddedIn(1, 4)
  float function() getBatteryPercentage;
	///
  @AddedIn(1, 4)
  float function() getBatteryVoltage;

  ///
  @AddedIn(1, 13)
  int function() getTimezoneOffset;
  ///
  @AddedIn(1, 13)
  bool function() shouldDisplay24HourTime;
  ///
  @AddedIn(1, 13)
  void function(uint epoch, PDDateTime* datetime) convertEpochToDateTime;
  ///
  @AddedIn(1, 13)
  int function(PDDateTime* datetime) convertDateTimeToEpoch;
  ///
  @AddedIn(2, 0)
  void function() clearICache;
  ///
  @AddedIn(2, 4)
	void function(PDButtonCallbackFunction cb, void* buttonud, int queuesize) setButtonCallback;
  ///
  @AddedIn(2, 4)
	void function(void function(const char* data) callback) setSerialMessageCallback;
  ///
  @AddedIn(2, 4)
	int function(char **outstr, const char *fmt, va_list args) vaFormatString;
  ///
  @AddedIn(2, 4)
	int function(const char *str, const char *format, ...) parseString;
}

///
T* alloc(T)(System* system) {
  import std.conv : castFrom;
  return castFrom!(void*).to!(T*)(system.realloc(null, T.sizeof));
}
///
T[] alloc(T)(System* system, ulong size) {
  import std.conv : castFrom;
  return castFrom!(void*).to!(T*)(system.realloc(null, T.sizeof * size))[0..size];
}

///
void free(T)(System* system, T* value) {
  system.realloc(value, 0);
}

///
void logToConsole(System* system, string message) {
  system.logToConsole(message.ptr);
}

version (unittest) {
  static message = "test";
  extern (C) void log(const(char*) msg, ...) {
    assert(msg == message.ptr);
  }
}

unittest {
  auto system = System();
  system.logToConsole = &log;
  logToConsole(&system, message);
}

///
enum FileOptions {
	///
  read      = (1<<0),
	///
  readData  = (1<<1),
	///
  write     = (1<<2),
	///
  append    = (2<<2)
}

///
struct FileStat {
	/// Whether the file is a directory.
  bool isDir;
	/// Size of the file, in bytes.
  uint size;
	/// Year component of the file's last modified date.
  int year;
	/// Month component of the file's last modified date.
  int month;
	/// Day component of the file's last modified date.
  int day;
	/// Hour component of the file's last modified date.
  int hour;
	/// Minute component of the file's last modified date.
  int minute;
	/// Second component of the file's last modified date.
  int second;
}

///
struct File {
  @nogc nothrow:

  ///
  const(char*) function() geterr;

	///
  int function(
    const char* path, void function(const char* path, void* userdata) callback, void* userdata,
    bool showHidden
  ) listfiles;
	///
  int function(const char* path, FileStat* stat) stat;
	///
  int function(const char* path) mkdir;
	///
  int function(const char* name, int recursive) unlink;
  ///
	int function(const char* from, const char* to) rename;

	///
  SDFile function(const char* name, FileOptions mode) open;
	///
  int function(SDFile file) close;
	///
  int function(SDFile file, void* buf, uint len) read;
	///
  int function(SDFile file, const void* buf, uint len) write;
	///
  int function(SDFile file) flush;
	///
  int function(SDFile file) tell;
	///
  int function(SDFile file, int pos, int whence) seek;
}

///
struct Video {
  @nogc nothrow:

	///
  LCDVideoPlayer*function (const char* path) loadVideo;
	///
  void function(LCDVideoPlayer* p) freePlayer;
	///
  int function(LCDVideoPlayer* p, LCDBitmap* context) setContext;
	///
  void function(LCDVideoPlayer* p) useScreenContext;
	///
  int function(LCDVideoPlayer* p, int n) renderFrame;
	///
  const(char*) function(LCDVideoPlayer* p) getError;
  ///
	void function(
		LCDVideoPlayer* p, int* outWidth, int* outHeight, float* outFrameRate, int* outFrameCount, int* outCurrentFrame
	) getInfo;
  ///
	LCDBitmap* function (LCDVideoPlayer *p) getContext;
}

///
struct Graphics {
  @nogc nothrow:

  ///
	Video* video;

	// Drawing Functions
	///
  void function(LCDColor color) clear;
	///
  void function(LCDSolidColor color) setBackgroundColor;
  /// Deprecated: In favor of `setStencilImage`, which adds a "tile" flag
  void function(LCDBitmap* stencil) setStencil;
	///
  void function(LCDBitmapDrawMode mode) setDrawMode;
	///
  void function(int dx, int dy) setDrawOffset;
	///
  void function(int x, int y, int width, int height) setClipRect;
	///
  void function() clearClipRect;
	///
  void function(LCDLineCapStyle endCapStyle) setLineCapStyle;
	///
  void function(LCDFont* font) setFont;
	///
  void function(int tracking) setTextTracking;
	///
  void function(LCDBitmap* target) pushContext;
	///
  void function() popContext;

	///
  void function(LCDBitmap* bitmap, int x, int y, LCDBitmapFlip flip) drawBitmap;
	///
  void function(LCDBitmap* bitmap, int x, int y, int width, int height, LCDBitmapFlip flip) tileBitmap;
	///
  void function(int x1, int y1, int x2, int y2, int width, LCDColor color) drawLine;
	///
  void function(int x1, int y1, int x2, int y2, int x3, int y3, LCDColor color) fillTriangle;
	///
  void function(int x, int y, int width, int height, LCDColor color) drawRect;
	///
  void function(int x, int y, int width, int height, LCDColor color) fillRect;
	/// stroked inside the rect
	void function(
		int x, int y, int width, int height, int lineWidth, float startAngle, float endAngle, LCDColor color
	) drawEllipse;
	///
  void function(
    int x, int y, int width, int height, float startAngle, float endAngle, LCDColor color
  ) fillEllipse;
	///
  void function(LCDBitmap* bitmap, int x, int y, float xscale, float yscale) drawScaledBitmap;
	///
  int  function(const void* text, size_t len, PDStringEncoding encoding, int x, int y) drawText;

	// LCDBitmap
	///
  LCDBitmap* function(int width, int height, LCDColor bgcolor) newBitmap;
	///
  void function(LCDBitmap*) freeBitmap;
	///
  LCDBitmap* function(const char* path, const char** outerr) loadBitmap;
	///
  LCDBitmap* function(LCDBitmap* bitmap) copyBitmap;
	///
  void function(const char* path, LCDBitmap* bitmap, const char** outerr) loadIntoBitmap;
	///
  void function(
    LCDBitmap* bitmap, int* width, int* height, int* rowbytes, ubyte** mask, ubyte** data
  ) getBitmapData;
	///
  void function(LCDBitmap* bitmap, LCDColor bgcolor) clearBitmap;
	///
  LCDBitmap* function(
    LCDBitmap* bitmap, float rotation, float xscale, float yscale, int* allocedSize
  ) rotatedBitmap;

	// LCDBitmapTable
	///
  LCDBitmapTable* function(int count, int width, int height) newBitmapTable;
	///
  void function(LCDBitmapTable* table) freeBitmapTable;
	///
  LCDBitmapTable* function(const char* path, const char** outerr) loadBitmapTable;
	///
  void function(const char* path, LCDBitmapTable* table, const char** outerr) loadIntoBitmapTable;
	///
  LCDBitmap* function(LCDBitmapTable* table, int idx) getTableBitmap;

	// LCDFont
	///
  LCDFont* function(const char* path, const char** outErr) loadFont;
	///
  LCDFontPage* function(LCDFont* font, uint c) getFontPage;
	///
  LCDFontGlyph* function(LCDFontPage* page, uint c, LCDBitmap** bitmap, int* advance) getPageGlyph;
	///
  int function(LCDFontGlyph* glyph, uint glyphcode, uint nextcode) getGlyphKerning;
	///
  int function(LCDFont* font, const void* text, size_t len, PDStringEncoding encoding, int tracking) getTextWidth;

	// raw framebuffer access
	///
  ubyte* function() getFrame; // row stride = LCD_ROWSIZE
	///
  ubyte* function() getDisplayFrame; // row stride = LCD_ROWSIZE
	///
  LCDBitmap* function() getDebugBitmap; // valid in simulator only, function is NULL on device
	///
  LCDBitmap* function() copyFrameBufferBitmap;
	///
  void function(int start, int end) markUpdatedRows;
	///
  void function() display;

	/// misc util.
  void function(LCDColor* color, LCDBitmap* bitmap, int x, int y) setColorToPattern;
  ///
	int function(
		LCDBitmap* bitmap1, int x1, int y1, LCDBitmapFlip flip1,
		LCDBitmap* bitmap2, int x2, int y2, LCDBitmapFlip flip2,
		LCDRect rect
	) checkMaskCollision;

	///
  @AddedIn(1, 1)
	void function(int x, int y, int width, int height) setScreenClipRect;

	///
  @AddedIn(1, 1, 1)
	void function(int nPoints, int* coords, LCDColor color, LCDPolygonFillRule fillrule) fillPolygon;
	///
  @AddedIn(1, 1, 1)
  ubyte function(LCDFont* font) getFontHeight;

	///
  @AddedIn(1, 7)
	LCDBitmap* function() getDisplayBufferBitmap;
  ///
  @AddedIn(1, 7)
	void function(
		LCDBitmap* bitmap, int x, int y, float rotation, float centerx, float centery, float xscale, float yscale
	) drawRotatedBitmap;
  ///
  @AddedIn(1, 7)
	void function(int lineHeightAdustment) setTextLeading;

	///
  @AddedIn(1, 8)
	int function(LCDBitmap* bitmap, LCDBitmap* mask) setBitmapMask;
  ///
	LCDBitmap* function(LCDBitmap* bitmap) getBitmapMask;

	///
  @AddedIn(1, 10)
	void function(LCDBitmap* stencil, int tile) setStencilImage;

	///
  @AddedIn(1, 12)
	LCDFont* function(LCDFontData* data, int wide) makeFontFromData;

	///
  @AddedIn(2, 1)
  int function() getTextTracking;

	///
  @AddedIn(2, 5)
  void function(int x, int y, LCDColor c) setPixel;

	///
  @AddedIn(2, 5)
	LCDSolidColor function(LCDBitmap* bitmap, int x, int y) getBitmapPixel;

	///
  @AddedIn(2, 5)
	void function(LCDBitmapTable* table, int* count, int* width) getBitmapTableInfo;
}

///
int drawText(Graphics* gfx, string text, int x, int y, PDStringEncoding encoding = PDStringEncoding.utf8Encoding) {
  return gfx.drawText(text.ptr, text.length, encoding, x, y);
}

version (unittest) {
  static txt = "test";
  extern (C) int drawTextTest(const void* text, size_t len, PDStringEncoding encoding, int x, int y) {
    assert(text == txt.ptr);
    assert(len == txt.length);
    assert(encoding == PDStringEncoding.utf8Encoding);
    assert(x >= 0);
    assert(y >= 0);
    return 0;
  }
}

unittest {
  auto gfx = Graphics();
  gfx.drawText = &drawTextTest;
  assert(drawText(&gfx, message, 5, 5) == 0);
}

///
enum SpriteCollisionResponseType {
  ///
  slide,
  ///
  freeze,
  /// 
  overlap,
  /// 
  bounce
}

///
struct PDRect {
  ///
	float x;
  ///
	float y;
  ///
	float width;
  ///
	float height;
}

/// 
struct CollisionPoint {
  /// 
  float x;
  /// 
  float y;
}

/// 
struct CollisionVector {
  /// 
  int x;
  /// 
  int y;
}

/// 
alias LCDSprite = Alias!(void*);
/// 
alias CWCollisionInfo = Alias!(void*);
/// 
alias CWItemInfo = Alias!(void*);

/// 
alias LCDSpriteDrawFunction = void function(LCDSprite* sprite, PDRect bounds, PDRect drawrect) @nogc;
/// 
alias LCDSpriteUpdateFunction = void function(LCDSprite* sprite) @nogc;
/// 
alias LCDSpriteCollisionFilterProc = SpriteCollisionResponseType function(LCDSprite* sprite, LCDSprite* other) @nogc;

///
struct SpriteCollisionInfo
{
  ///
	LCDSprite* sprite;		  // The sprite being moved
  ///
	LCDSprite* other;		    // The sprite colliding with the sprite being moved
  ///
	SpriteCollisionResponseType responseType;	// The result of collisionResponse
  ///
	uint overlaps;		      // True if the sprite was overlapping other when the collision started. False if it didn’t overlap but tunneled through other.
  ///
	float ti;				        // A number between 0 and 1 indicating how far along the movement to the goal the collision occurred
  ///
	CollisionPoint move;	  // The difference between the original coordinates and the actual ones when the collision happened
  ///
	CollisionVector normal;	// The collision normal; usually -1, 0, or 1 in x and y. Use this value to determine things like if your character is touching the ground.
  ///
	CollisionPoint touch;	  // The coordinates where the sprite started touching other
  ///
	PDRect spriteRect;		  // The rectangle the sprite occupied when the touch happened
  ///
	PDRect otherRect; 		  // The rectangle the sprite being collided with occupied when the touch happened
}

/// 
struct SpriteQueryInfo
{
  ///
	LCDSprite* sprite;          // The sprite being intersected by the segment
	      							        // ti1 and ti2 are numbers between 0 and 1 which indicate how far from the starting point of the line segment the collision happened
  ///
	float ti1;					        // entry point
  ///
	float ti2;					        // exit point
  ///
	CollisionPoint entryPoint;	// The coordinates of the first intersection between sprite and the line segment
  ///
	CollisionPoint exitPoint;	  // The coordinates of the second intersection between sprite and the line segment
}

///
struct Sprite {
  @nogc nothrow:
  
  ///
  void function(int flag) setAlwaysRedraw;
  ///
	void function(LCDRect dirtyRect) addDirtyRect;
  ///
	void function() drawSprites;
  ///
	void function() updateAndDrawSprites;

  ///
	LCDSprite* function() newSprite;
  ///
	void function(LCDSprite* sprite) freeSprite;
  ///
	LCDSprite* function(LCDSprite* sprite) copy;

  ///
	void function(LCDSprite* sprite) addSprite;
  ///
	void function(LCDSprite* sprite) removeSprite;
  ///
	void function(LCDSprite** sprites, int count) removeSprites;
  ///
	void function() removeAllSprites;
  ///
	int function() getSpriteCount;

  ///
	void function(LCDSprite* sprite, PDRect bounds) setBounds;
  ///
	PDRect function(LCDSprite* sprite) getBounds; 
  ///
	void function(LCDSprite* sprite, float x, float y) moveTo;
  ///
	void function(LCDSprite* sprite, float dx, float dy) moveBy; 

  ///
	void function(LCDSprite *sprite, LCDBitmap *image, LCDBitmapFlip flip) setImage;
  ///
	LCDBitmap* function(LCDSprite *sprite) getImage;
  ///
	void function(LCDSprite *s, float width, float height) setSize;
  ///
	void function(LCDSprite *sprite, short zIndex) setZIndex;
  ///
	short function(LCDSprite *sprite) getZIndex;

  ///
	void function(LCDSprite *sprite, LCDBitmapDrawMode mode) setDrawMode;
  ///
	void function(LCDSprite *sprite, LCDBitmapFlip flip) setImageFlip;
  ///
	LCDBitmapFlip function(LCDSprite *sprite) getImageFlip;
  ///
	void function(LCDSprite *sprite, LCDBitmap* stencil) setStencil; // deprecated in favor of setStencilImage()

  ///
	void function(LCDSprite *sprite, LCDRect clipRect) setClipRect;
  ///
	void function(LCDSprite *sprite) clearClipRect;
  ///
	void function(LCDRect clipRect, int startZ, int endZ) setClipRectsInRange;
  ///
	void function(int startZ, int endZ) clearClipRectsInRange;

  ///
	void function(LCDSprite *sprite, int flag) setUpdatesEnabled;
  ///
	int  function(LCDSprite *sprite) updatesEnabled;
  ///
	void function(LCDSprite *sprite, int flag) setCollisionsEnabled;
  ///
	int  function(LCDSprite *sprite) collisionsEnabled;
  ///
	void function(LCDSprite *sprite, int flag) setVisible;
  ///
	int  function(LCDSprite *sprite) isVisible;
  ///
	void function(LCDSprite *sprite, int flag) setOpaque;
  ///
	void function(LCDSprite *sprite) markDirty;

  ///
	void function(LCDSprite *sprite, ubyte tag) setTag;
  ///
	ubyte function(LCDSprite *sprite) getTag;

  ///
	void function(LCDSprite *sprite, int flag) setIgnoresDrawOffset;

  ///
	void function(LCDSprite *sprite, LCDSpriteUpdateFunction *func) setUpdateFunction;
  ///
	void function(LCDSprite *sprite, LCDSpriteDrawFunction *func) setDrawFunction;

  ///
	void function(LCDSprite *sprite, float *x, float *y) getPosition;

	// Collisions
  ///
	void function() resetCollisionWorld;

  ///
	void function(LCDSprite *sprite, PDRect collideRect) setCollideRect;
  ///
	PDRect function(LCDSprite *sprite) getCollideRect;
  ///
	void function(LCDSprite *sprite) clearCollideRect;

	// caller is responsible for freeing the returned array for all collision methods
  ///
	void function(LCDSprite *sprite, LCDSpriteCollisionFilterProc *func) setCollisionResponseFunction;
  ///
	SpriteCollisionInfo* function(LCDSprite *sprite, float goalX, float goalY, float *actualX, float *actualY, int *len) checkCollisions;			// access results using SpriteCollisionInfo *info = &results[i];
  ///
	SpriteCollisionInfo* function(LCDSprite *sprite, float goalX, float goalY, float *actualX, float *actualY, int *len) moveWithCollisions;
  ///
	LCDSprite** function(float x, float y, int *len) querySpritesAtPoint;
  ///
	LCDSprite** function(float x, float y, float width, float height, int *len) querySpritesInRect;
  ///
	LCDSprite** function(float x1, float y1, float x2, float y2, int *len) querySpritesAlongLine;
  ///
	SpriteQueryInfo* function(float x1, float y1, float x2, float y2, int *len) querySpriteInfoAlongLine;		// access results using SpriteQueryInfo *info = &results[i];
  ///
	LCDSprite** function(LCDSprite *sprite, int *len) overlappingSprites;
  ///
	LCDSprite** function(int *len) allOverlappingSprites;

  ///
  @AddedIn(1, 7)
	void function(LCDSprite* sprite, ubyte[8] pattern) setStencilPattern;
  ///
  @AddedIn(1, 7)
	void function(LCDSprite* sprite) clearStencil;

  ///
  @AddedIn(1, 7)
	void  function(LCDSprite* sprite, void* userdata) setUserdata;
  ///
  @AddedIn(1, 7)
	void* function(LCDSprite* sprite) getUserdata;

  ///
  @AddedIn(1, 10)
	void function(LCDSprite *sprite, LCDBitmap* stencil, int tile) setStencilImage;
	
  ///
  @AddedIn(2, 1)
	void function(LCDSprite* s, float x, float y) setCenter;
  ///
  @AddedIn(2, 1)
	void function(LCDSprite* s, float* x, float* y) getCenter;
}

///
struct Display {
  @nogc nothrow:

	///
  int function() getWidth;
	///
  int function() getHeight;

	///
  void function(float rate) setRefreshRate;

	///
  void function(int flag) setInverted;
	///
  void function(uint s) setScale;
	///
  void function(uint x, uint y) setMosaic;
	///
  void function(int x, int y) setFlipped;
	///
  void function(int x, int y) setOffset;
}

/// A SoundChannel contains `SoundSource`s and `SoundEffect`s.
alias SoundChannel = Alias!(void*);

///
struct SoundChannelApi {
  @nogc nothrow:

  ///
  SoundChannel function() newChannel;
	///
  void function(SoundChannel channel) freeChannel;
	///
  int function(SoundChannel channel, SoundSource* source) addSource;
	///
  int function(SoundChannel channel, SoundSource* source) removeSource;
  /// Creates a new `SoundSource` using the given data provider `callback` and adds it to the default channel.
  /// Remarks: The caller takes ownership of the allocated `SoundSource`, and should free it with `playdate.system.realloc(source, NULL);` when it is no longer in use.
  SoundSource* function(
    SoundChannel channel, AudioSourceFunction* callback, void* context, int stereo
  ) addCallbackSource;
	///
  void function(SoundChannel channel, SoundEffect* effect) addEffect;
	///
  void function(SoundChannel channel, SoundEffect* effect) removeEffect;
	///
  void function(SoundChannel channel, float volume) setVolume;
	///
  float function(SoundChannel channel) getVolume;
	///
  void function(SoundChannel channel, PDSynthSignalValue mod) setVolumeModulator;
	///
  PDSynthSignalValue function(SoundChannel channel) getVolumeModulator;
	///
  void function(SoundChannel channel, float pan) setPan;
	///
  void function(SoundChannel channel, PDSynthSignalValue mod) setPanModulator;
	///
  PDSynthSignalValue function(SoundChannel channel) getPanModulator;
	///
  PDSynthSignalValue function(SoundChannel channel) getDryLevelSignal;
	///
  PDSynthSignalValue function(SoundChannel channel) getWetLevelSignal;
}

///
struct SoundFileplayer {
  @nogc nothrow:
  // TODO: Implement Playdate Sound Fileplayer API
}

///
struct SoundSample {
  @nogc nothrow:
  // TODO: Implement Playdate Sound Sample API
}

///
struct SoundSampleplayer {
  @nogc nothrow:
  // TODO: Implement Playdate Sound Sampleplayer API
}

///
struct SoundSynth {
  @nogc nothrow:
  // TODO: Implement Playdate Sound Synth API
}

///
struct SoundSequence {
  @nogc nothrow:
  // TODO: Implement Playdate Sound Sequence API
}

///
alias SoundEffect = Alias!(void*);

///
struct SoundEffectApi {
  @nogc nothrow:
  // TODO: Implement Playdate Sound Effect API
}

///
struct SoundLfo {
  @nogc nothrow:
  // TODO: Implement Playdate Sound Lfo API
}

///
struct SoundEnvelope {
  @nogc nothrow:
  // TODO: Implement Playdate Sound Envelope API
}

///
struct SoundSource {
  @nogc nothrow:
  // TODO: Implement Playdate Sound Source API
}

///
struct ControlSignal {
  @nogc nothrow:
  // TODO: Implement Playdate Contr olSignal API
}

///
struct SoundTrack {
  @nogc nothrow:
  // TODO: Implement Playdate Sound Track API
}

///
struct SoundInstrument {
  @nogc nothrow:
  // TODO: Implement Playdate Sound Instrument API
}

/// A PDSynthSignalValue represents a signal that can be used as an input to a modulator.
/// Its `PDSynthSignal` subclass is used for "active" signals that change their values automatically.
/// `PDSynthLFO` and `PDSynthEnvelope` are subclasses of `PDSynthSignal`.
alias PDSynthSignalValue = Alias!(void*);
alias PDSynthSignal = Alias!(void*);

///
struct SoundSignal {
  @nogc nothrow:
  // TODO: Implement Playdate Sound Signal API
}

///
struct Sound {
  @nogc nothrow:

	///
  SoundChannelApi* channel;
	///
  SoundFileplayer* fileplayer;
	///
  SoundSample* sample;
	///
  SoundSampleplayer* sampleplayer;
	///
  SoundSynth* synth;
	///
  SoundSequence* sequence;
	///
  SoundEffectApi* effect;
	///
  SoundLfo* lfo;
	///
  SoundEnvelope* envelope;
	///
  SoundSource* source;
	///
  ControlSignal* controlsignal;
	///
  SoundTrack* track;
	///
  SoundInstrument* instrument;

	///
  uint function() getCurrentTime;
	/// The `callback` function you pass in will be called every audio render cycle.
  SoundSource* function(AudioSourceFunction callback, void* context, bool stereo) addSource;

	///
  SoundChannel function() getDefaultChannel;

	///
  void function(SoundChannel channel) addChannel;
	///
  void function(SoundChannel channel) removeChannel;

	/// The `callback` you pass in will be called every audio cycle.
  ///
  /// If `forceInternal` is set, the device microphone is used regardless of whether the headset has a microphone.
  void function(RecordCallback callback, void* context, bool forceInternal) setMicCallback;
	/// If `headphone` contains a non-null pointer, the value is set to `true` if headphones are currently plugged in.
  /// Likewise, mic is set if the headphones include a microphone.
  /// If `changeCallback` is provided, it will be called when the headset or mic status changes, and audio output
  /// will not automatically switch from speaker to headphones when headphones are plugged in (and vice versa).
  /// In this case, the callback should use `playdate.sound.setOutputsActive()` to change the output if needed.
  void function(
    bool* headphone, bool* headsetmic, void function(bool headphone, bool mic) changeCallback
  ) getHeadphoneState;
	/// Force audio output to the given outputs, regardless of headphone status.
  void function(bool headphone, bool speaker) setOutputsActive;

	///
  @AddedIn(1, 5)
  void function(SoundSource* source) removeSource;

	///
  @AddedIn(1, 12)
	SoundSignal* signal;
}

/// 
alias lua_State = void* function() @nogc;

/// 
alias lua_CFunction = int* function(lua_State* L) @nogc;

/// 
alias LuaUDObject = Alias!(void*);

///
enum LuaValType {
  /// 
  Int,
  /// 
  Float,
  /// 
  Str
}

/// 
struct LuaReg{
  /// 
  const char* name;
  /// 
  lua_CFunction func;
}

///
enum LuaType
{
	typeNil,
	typeBool,
	typeInt,
	typeFloat,
	typeString,
	typeTable,
	typeFunction,
	typeThread,
	typeObject
}

/// 
struct LuaVal{
  /// 
  const char* name;
  /// 
  LuaValType type;
  ///
  union
  {
    ///
    uint intval;
    ///
    float floatval;
    ///
    const char* strval;
  }
}

///
struct Lua {
  @nogc nothrow:

	// these two return 1 on success, else 0 with an error message in outErr
  ///
	int function(lua_CFunction f, const char* name, const char** outErr) addFunction;
  ///
	int function(
    const char* name, 
    const LuaReg* reg, 
    const LuaVal* vals, 
    int isstatic, 
    const char** outErr
  ) registerClass;

  ///
	void function(lua_CFunction f) pushFunction;
  ///
	int function() indexMetatable;

  ///
	void function() stop;
  ///
	void function() start; 
	
	// stack operations
  ///
	int function() getArgCount; 
  ///
	LuaType function(int pos, const char** outClass) getArgType;

  ///
	int function(int pos) argIsNil;
  ///
	int function(int pos) getArgBool;
  ///
	int function(int pos) getArgInt;
  ///
	float function(int pos) getArgFloat;
  ///
	const char* function(int pos) getArgString;
  ///
	const char* function(int pos, size_t* outlen) getArgBytes;
  ///
	void* function(int pos, char* type, LuaUDObject** outud) getArgObject;
	
  ///
	LCDBitmap* function(int pos) getBitmap;
  ///
	LCDSprite* function(int pos) getSprite;

	// for returning values back to Lua
  ///
	void function() pushNil;
  ///
	void function(int val) pushBool;
  ///
	void function(int val) pushInt;
  ///
	void function(float val) pushFloat;
  ///
	void function(const char* str) pushString;
  ///
	void function(const char* str, size_t len) pushBytes;
  ///
	void function(LCDBitmap* bitmap) pushBitmap;
  ///
	void function(LCDSprite* sprite) pushSprite;
	
  ///
	LuaUDObject* function(void* obj, char* type, int nValues) pushObject;
  ///
	LuaUDObject* function(LuaUDObject* obj) retainObject;
  ///
	void function(LuaUDObject* obj) releaseObject;
	
  ///
	void function(LuaUDObject* obj, uint slot) setUserValue; // sets item on top of stack and pops it
  ///
	int function(LuaUDObject* obj, uint slot) getUserValue; // pushes item at slot to top of stack, returns stack position

	// calling lua from C has some overhead. use sparingly!
  ///
	void function(const char* name, int nargs) callFunction_deprecated;
  ///
	int function(const char* name, int nargs, const char** outerr) callFunction;
}

/// 
enum ValueType {
  Null,
  True,
  False,
  Integer,
  Float,
  String,
  Array,
  Table
}

/// 
struct Value {
  ///
  char type;

  union
  {
    ///
    int intval;
    ///
    float floatval;
    ///
    char* stringval;
    ///
    void* arrayval;
    ///
    void* tableval;
  }
}

///
pragma(inline) int intValue(Value value) {
  switch ( value.type )
  {
    case ValueType.Integer:
      return value.intval;
    case ValueType.Float:
      return cast(int)value.floatval;
    case ValueType.String:
      return cast(int)strtol(value.stringval, null, 10);
    case ValueType.True:
      return 1;
    default:
      return 0;
  }
}

///
pragma(inline) float floatValue(Value value) {
  switch ( value.type )
  {
    case ValueType.Integer:
      return cast(float) value.intval;
    case ValueType.Float:
      return value.floatval;
    case ValueType.String:
      return 0;
    case ValueType.True:
      return 1.0;
    default:
      return 0.0;
  }
}

///
pragma(inline) int boolValue(Value value) {
  return value.type == ValueType.String ? strcmp(value.stringval,"") != 0 : intValue(value);
}

///
pragma(inline) char* stringValue(Value value) {
  return value.type == ValueType.String ? value.stringval : null;
}

///
struct Json {
  @nogc nothrow:
	// TODO: Implement Playdate Json API
}

///
struct PDScore {
  ///
  uint rank;
  ///
  uint value;
  ///
  char* player;
}

///
struct PDScoresList {
  ///
  char* boardID;
  ///
	uint count;
  ///
	uint lastUpdated;
  ///
	int playerIncluded;
  ///
	uint limit;
  ///
	PDScore* scores;
}

///
struct PDBoard {
  ///
  char* boardID;
  ///
  char* name;
}

///
struct PDBoardsList {
  /// 
  uint count;
  /// 
  uint lastUpdated;
  /// 
  PDBoard* boards;
}

///
alias AddScoreCallback = void* function(PDScore* score, const char* errorMessage) @nogc;
///
alias PersonalBestCallback = void* function(PDScore* score, const char* errorMessage) @nogc;
///
alias BoardsListCallback = void* function(PDBoardsList* boards, const char* errorMessage) @nogc;
///
alias ScoresCallback = void* function(PDScoresList* scores, const char* errorMessage) @nogc;

///
struct Scoreboards {
  @nogc nothrow:
  ///
	int function(const char* boardId, uint value, AddScoreCallback callback) addScore;
  ///
	int function(const char* boardId, PersonalBestCallback callback) getPersonalBest;
  ///
	void function(PDScore* score) freeScore;

  ///
	int function(BoardsListCallback callback) getScoreboards;
  ///
	void function(PDBoardsList* boardsList) freeBoardsList;

  ///
	int function(const char* boardId, ScoresCallback callback) getScores;
  ///
	void function(PDScoresList* scoresList) freeScoresList;
}

///
struct PlaydateAPI {
  ///
  System* system;
	///
  File* file;
	///
  Graphics* graphics;
	///
  Sprite* sprite;
	///
  Display* display;
	///
  Sound* sound;
	///
  Lua* lua;
	///
  Json* json;
	///
  Scoreboards* scoreboards;
}

/// Generates a shim around your `eventHandler` used by the Playdate OS as the entry-point to your application.
mixin template EventHandlerShim() {
  extern (C) int eventHandlerShim(PlaydateAPI* playdate, PDSystemEvent event, uint arg) @nogc nothrow {
    return eventHandler(playdate, event, arg);
  }
}
