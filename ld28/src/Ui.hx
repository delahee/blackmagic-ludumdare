import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.text.*;
import mt.deepnight.SpriteLibBitmap.BSprite;
using volute.Ex;

import Types;
import flash.media.Sound;
import flash.media.SoundMixer;



@:publicFields
class Tf {
	
	var tf:TextField;
	var fr:Int;
	
	@:isVar
	var y(default,set): Float;
	var sp:Float;
	
	var persist:Bool;
	var ylife = 0;
	var test:Void->Bool;
	var onEnd:Void->Void;
	function new(tf,fr,sp){
		this.tf = tf;
		y = tf.y;
		this.fr = fr;
		this.sp = sp;
		test = function() return true;
		onEnd = function() return ;
	}
	
	inline function setPersist(p,test) {
		persist = p;
		this.test = test;
		ylife = 10;
	}
	
	inline function set_y(v) {
		y = v;
		tf.y = Std.int( y );
		return v;
	}
}

class Ui extends Sprite
{
	public var score : Int;
	var prevScore : Int;
	
	var dols : Int;
	
	var tfScore : TextField;
	var tfDols : TextField;
	
	public var tfMsg : List<Tf>;
	
	var nokia : Font;
	
	var press : BSprite;
	var pa:BSprite;
	var pb:BSprite;
	
	var au : BSprite;
	var ad : BSprite;
	var ts : BSprite;
	
	
	public var fading = false;
	public function getTitle() :Array<BSprite>{
		return [press, ts, pa, pb, ts];
	}
	
	public function new() {
		
		super();
		
		tfMsg = new List();
		nokia = new Nokia();
		
		score = 1000000;
		dols = 0;
		
		var data = M.me.data;
		
		var spr = data.lib.getAndPlay("palmier_a");
		spr.x = 50;
		spr.y =  50;
		spr.blendMode = OVERLAY;
		addChild( pa = spr );
		
		var spr = data.lib.getAndPlay("palmier_b");
		spr.x = 240-50;
		spr.y = 50;
		spr.blendMode = OVERLAY;
		addChild( pb = spr );
		
		var spr = data.lib.getAndPlay("press");
		spr.x = 240>>1;
		spr.y = 200;
		addChild( press = spr );
		
		var spr = data.lib.getAndPlay("title_screen");
		spr.x = 240>>1;
		spr.y = 120;
		addChild( ts = spr );
		
		var spr = data.lib.getAndPlay("ambiant_down");
		spr.x = 120;
		spr.y = 240;
		spr.blendMode = OVERLAY;
		addChild( ad = spr );
		
		var spr = data.lib.getAndPlay("ambiant_up");
		spr.x = 120;
		spr.y = 80;
		spr.blendMode = OVERLAY;
		addChild( au = spr );
		
		
		{
			tfScore = new TextField();
			
			var tft = new TextFormat('nokiafc22',16,0x70bab5);
			tfScore.setTextFormat( tfScore.defaultTextFormat = tft ); 
			tfScore.embedFonts = true;
			
			tfScore.mouseEnabled = false;
			tfScore.selectable = false;
			
			tfScore.width = 500;
			tfScore.height = 100;
			
			tfScore.x = volute.Lib.w() - 180;
			tfScore.y = volute.Lib.h() - 25;
			
			tfScore.filters = [ new GlowFilter(0xc201e, 1, 4 , 4, 20) ];
			
			addChild( tfScore ); 
		}
		
		
	}
	
	public function getScoreTf(txt,?col=0xFF0707) {
		var tf = new TextField();
		
		var tft = new TextFormat('nokiafc22',8,col);
		tf.setTextFormat( tf.defaultTextFormat = tft ); 
		tf.embedFonts = true;
		
		tf.mouseEnabled = false;
		tf.selectable = false;
		
		tf.width = 100;
		tf.height = 30;
		tf.text = txt;
		tf.width = tf.textWidth + 5;
		
		tf.filters = [ new GlowFilter(0xc201e, 1, 4 , 4, 20) ];
		
		addChild( tf ); 
		
		return tf;
	}
	
	public function addScore( d:Int,x,y )
	{
		var dstr = Std.string(Std.int(Math.abs(d)));
		var tf = getScoreTf( (d>0?"+":"-")+"$"+dstr, d<0?null : 0xFFF27C);
		tf.x = x;
		tf.y = y;
		tfMsg.add(  new Tf(tf, 30, 0.3 ) );
		score += d;
		if ( score <= 0)
			score = 0;
		return tf;
	}
	
	public function addMessage( msg ,x:Float,y,c )
	{
		var tf = getScoreTf(msg,c);
		tf.x = x - tf.textWidth * 0.5;
		tf.y = y;
		var t = null;
		tfMsg.add( t=new Tf(tf, 30, 0.3 ) );
		return t;
	}
	
	public function addPersistMessage( msg ,x:Float,y,test )
	{
		var tf = getScoreTf(msg);
		tf.multiline = true;
		tf.wordWrap = true;
		tf.width = 150;
		tf.text = msg;
		tf.width = tf.textWidth+5;
		tf.height = tf.textHeight + 5;
		
		tf.x = x - tf.textWidth * 0.5;
		tf.y = y;
		var t = null;
		tfMsg.add( t=new Tf(tf, 30, 0.3 ) );
		t.persist = true;
		t.test = test;
		return t;
	}
	
	
	public function update() {
		var s = Std.int(score * 0.7 + prevScore * 0.3 +0.5);
		tfScore.text = "$" + s;
		prevScore = s;
		tfScore.width = tfScore.textWidth + 5;
		
		for ( t in tfMsg) {
			t.fr--;
			if ( t.fr <= 0 && !t.persist ) {
				t.tf.detach();
				t.onEnd();
				tfMsg.remove(t);
			}
			else {
				
				if ( t.persist && t.ylife<=0){
					
				}
				else{
					t.y -= t.sp;
					t.ylife--;
					
				}
				
				if ( t.persist ) {
					if ( t.test() ) {
						t.tf.detach();
						t.onEnd();
						tfMsg.remove(t);
					}
				}
			}
		}
	}
	
}