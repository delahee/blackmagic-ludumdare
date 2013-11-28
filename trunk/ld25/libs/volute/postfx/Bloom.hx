package volute.postfx;

//ref http://philippseifried.com/blog/2011/07/30/real-time-bloom-effects-in-as3/
import flash.display.BitmapData;
import flash.filters.ColorMatrixFilter;
import flash.geom.Point;
import Types;
import Lib;

using com.Ex;

/**
 * ...
 * @author de
 */

enum BloomFlags
{
	FULLSCREEN;
	BLOOM_ONLY;
}

class Bloom extends scene.Scene
{
	var src : DOC;
	var fl : haxe.EnumFlags<BloomFlags>;
	var result : BitmapData;
	var render : BitmapData;
	var resStub : Bitmap;
	
	static var grayMatrix :Array<Float> = [
	  0.3, 0.59, 0.11, 0, 0,
	  0.3, 0.59, 0.11, 0, 0,
	  0.3, 0.59, 0.11, 0, 0,
	  0,    0,    0,    1, 0];
	 
	public var grayFilter : flash.filters.ColorMatrixFilter;
	public var blurFilter : flash.filters.BlurFilter;
	
	var bmpResult : Bitmap;
	var bmpRender : Bitmap;
	var mat : flash.geom.Matrix;
	
	// each pass multiplies shine
	//0 for flat bright
	//1 for contrasted
	//2 for very contrasted+faded
	public var nbPowPass:Int; 
	public var rtRes(default,set):Null<Float>;
	
	public function setBlurFactors( rg:Int,qual : Int = 1){
		blurFilter.blurX = blurFilter.blurY = rg;
		blurFilter.quality = qual;
	}
	
	public function new( r : DOC, fl:haxe.EnumFlags<BloomFlags>) 
	{
		var p = r.parent;
		var idx = p.getChildIndex( r );
		p.addChildAt( this,idx-1 );
		p.removeChild( r );
		
		this.fl = fl;
		src = r;
		
		rtRes = null;
		
		var w = fl.has(FULLSCREEN) ? Lib.w() : Std.int( src.width);
		var h = fl.has(FULLSCREEN) ? Lib.h() : Std.int( src.height);
		
		makeBufs(w,h);
	
		grayFilter = new ColorMatrixFilter( grayMatrix );
		blurFilter = new flash.filters.BlurFilter(12, 12, 1);
		
		nbPowPass = 0;
		mat = new flash.geom.Matrix();
		mat.identity();
		
		super();
	}
	
	function dispose()
	{
		if(result!=null) result.dispose();
		if(render!=null) render.dispose();
		
		bmpRender.detach();	bmpRender = null;
		bmpResult.detach();	bmpResult = null;
	}
	
	function makeBufs(w,h)
	{
		var r = (rtRes == null) ? 1.0 : rtRes; 
		result = new BitmapData( Std.int(r*w) , Std.int(r*h) , false, 0x0 );
		render = new BitmapData( w, h , false, 0x0 );
		
		addChild( bmpRender = new Bitmap( render));
		addChild( bmpResult = new Bitmap( result));
		bmpResult.blendMode = flash.display.BlendMode.ADD;
	}
	
	public function set_rtRes(v:Null<Float>)
	{
		dispose();
		rtRes = v;
		var w = fl.has(FULLSCREEN) ? Lib.w() : Std.int( src.width);
		var h = fl.has(FULLSCREEN) ? Lib.h() : Std.int( src.height);
		makeBufs(w, h);
		return v;
	}
	
	
	public override function kill()
	{
		var idx = parent.getChildIndex( this );
		var p = parent;
		parent.removeChild( this );
		p.addChildAt( src, idx - 1 );
		
		super.kill();
	}
	
	public function drawDirect()
	{
		result.fillRect(result.rect, 0x0);
		render.fillRect(render.rect, 0x0);
		
		render.draw( src );
		result.applyFilter( render, result.rect, Const.Point_ZERO, grayFilter); //grey it
		
		for ( i in 0...nbPowPass) result.draw( result, flash.display.BlendMode.MULTIPLY); //power it
			
		result.draw( render, flash.display.BlendMode.MULTIPLY); //Restore color

		if( blurFilter != null) result.applyFilter( result, result.rect, Const.Point_ZERO, blurFilter);
			
		bmpRender.visible = !fl.has( BLOOM_ONLY );
	}
	
	public function drawIndirect()
	{
		mat.identity();
		mat.scale( rtRes, rtRes);
		
		
		result.fillRect(result.rect, 0x0);
		render.fillRect(render.rect, 0x0);
		
		render.draw( src);
		result.draw( render,mat);
		
		result.applyFilter( result, result.rect, Const.Point_ZERO, grayFilter); //grey it
		
		for ( i in 0...nbPowPass) result.draw( result, flash.display.BlendMode.MULTIPLY); //power it
		result.draw( render, mat,flash.display.BlendMode.MULTIPLY); //Restore color

		if ( blurFilter != null)	result.applyFilter( result, result.rect, Const.Point_ZERO, blurFilter);
		
		bmpRender.visible = !fl.has( BLOOM_ONLY );
	}
	
	public override function update(_)
	{
		var s = (rtRes == null)?1.0 : 1.0/rtRes;
		bmpResult.scaleX = s;
		bmpResult.scaleY = s;
	
		if( rtRes==null)
			drawDirect();
		else
			drawIndirect();
	}
	
}