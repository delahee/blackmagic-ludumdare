package volute;

typedef DOC = flash.display.DisplayObjectContainer;
typedef BD = flash.display.BitmapData;
typedef Bitmap = flash.display.Bitmap;
typedef BitmapData = flash.display.BitmapData;

typedef Shape = flash.display.Shape;

#if starling
typedef Sprite = starling.display.Sprite;
typedef DisplayObject = starling.display.DisplayObject;
typedef DisplayObjectContainer = starling.display.DisplayObjectContainer;
#else 
typedef Sprite = flash.display.Sprite;
typedef DisplayObject = flash.display.DisplayObject;
typedef DisplayObjectContainer = flash.display.DisplayObjectContainer;
#end

typedef K = flash.ui.Keyboard

