import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.text.*;
using volute.Ex;

@:font('asset/nokiafc22.ttf')
class Nokia extends Font{
	
}

@:publicFields
class Tf {
	
	var tf:TextField;
	var fr:Int;
	
	@:isVar
	var y(default,set): Float;
	var sp:Float;
	
	public function new(tf,fr,sp){
		this.tf = tf;
		y = tf.y;
		this.fr = fr;
		this.sp = sp;
	}
	
	public inline function set_y(v) {
		y = v;
		tf.y = Std.int( y );
		return v;
	}
}

class Ui extends Sprite
{
	var score : Int;
	var prevScore : Int;
	
	var dols : Int;
	
	var tfScore : TextField;
	var tfDols : TextField;
	
	var tfMsg : List<Tf>;
	
	var nokia : Font;
	public function new() {
		
		super();
		
		tfMsg = new List();
		nokia = new Nokia();
		
		score = 1000000;
		dols = 0;
		
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
			tfScore.y = volute.Lib.h() - 40;
			
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
	
	public function addScore( d ,x,y )
	{
		var tf = getScoreTf((d>0?"+":"")+Std.string(d), d<0?null : 0xFFF27C);
		tf.x = x;
		tf.y = y;
		tfMsg.add(  new Tf(tf, 30, 0.3 ) );
		score += d;
		if ( score <= 0)
			score = 0;
		return tf;
	}
	
	public function addMessage( msg ,x:Float,y )
	{
		var tf = getScoreTf(msg);
		tf.x = x - tf.textWidth * 0.5;
		tf.y = y;
		tfMsg.add( new Tf(tf, 30, 0.3 ) );
		return tf;
	}
	
	
	public function update() {
		var s = Std.int(score * 0.7 + prevScore * 0.3 +0.5);
		tfScore.text = "$" + s;
		prevScore = s;
		tfScore.width = tfScore.textWidth + 5;
		
		for ( t in tfMsg) {
			t.fr--;
			if ( t.fr <= 0) {
				t.tf.detach();
				tfMsg.remove(t);
			}
			else 
				t.y-=t.sp;
		}
	}
	
}