package volute;

typedef BD = flash.display.BitmapData;
typedef Bitmap = flash.display.Bitmap;
typedef BitmapData = flash.display.BitmapData;
typedef Shape = flash.display.Shape;

#if starling
typedef Sprite = starling.display.Sprite;
typedef DisplayObject = starling.display.DisplayObject;
typedef DisplayObjectContainer = starling.display.DisplayObjectContainer;
typedef TextField = starling.text.TextField;
typedef DOC = starling.display.DisplayObjectContainer;

#else 
typedef Sprite = flash.display.Sprite;
typedef DisplayObject = flash.display.DisplayObject;
typedef DisplayObjectContainer = flash.display.DisplayObjectContainer;
typedef TextField = flash.text.TextField;
typedef DOC = flash.display.DisplayObjectContainer;

#end

typedef K = flash.ui.Keyboard

