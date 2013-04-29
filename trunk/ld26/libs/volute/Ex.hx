package volute.com;

typedef EmbedLbd	= Lambda;
typedef EmbedLbdEx 	= LbdEx;
typedef EmbedArrEx 	= ArrEx;


import flash.display.DisplayObject;

class Ex
{
	public static function detach(v : DisplayObject)
	{
		if (v!=null && v.parent != null)
			v.parent.removeChild( v );
	}
	
	public static function putBehind(v0 : DisplayObject, v1 : DisplayObject)
	{
		if ( v0 == null || v1 == null) return;
		
		detach( v0 );
		
		var idx = v1.parent.getChildIndex(v1);
		v1.parent.addChildAt( v0, idx );
	}
	
	public static function putInFront(v0 : DisplayObject, v1 : DisplayObject)
	{
		if ( v0 == null || v1 == null) return;
		detach( v0 );
		var idx = v1.parent.getChildIndex(v1);
		v1.parent.addChildAt( v0, idx+1 );
	}
	
	public static function toFront( mc : DisplayObject ) {
		detach(mc);
		if( mc.parent != null)
			mc.parent.setChildIndex( mc , mc.parent.numChildren-1 );
	}
	
	public static function toBack( mc : DisplayObject) {
		detach(mc);
		if( mc.parent != null)
			mc.parent.setChildIndex( mc , 0);
	}
	
		
}