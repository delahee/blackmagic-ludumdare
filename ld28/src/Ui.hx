import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.text.*;
using volute.Ex;

@:font('nokiafc22.ttf')
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
	var dols : Int;
	
	var tfScore : TextField;
	var tfDols : TextField;
	
	var tfMsg : List<Tf>;
	
	var nokia : Font;
	public function new() {
		
		super();
		
		tfMsg = new List();
		nokia = new Nokia();
		
		score = 0;
		dols = 0;
		
		{
			tfScore = new TextField();
			
			var tft = new TextFormat(nokia.fontName,16,0x70bab5);
			tfScore.setTextFormat( tfScore.defaultTextFormat = tft ); 
			tfScore.embedFonts = true;
			
			tfScore.mouseEnabled = false;
			tfScore.selectable = false;
			
			tfScore.width = 500;
			tfScore.height = 100;
			
			tfScore.x = volute.Lib.w() - 40;
			tfScore.y = volute.Lib.h() - 40;
			
			//tfScore.x = 50;
			//tfScore.y = 50;
			tfScore.filters = [ new GlowFilter(0xc201e, 1, 4 , 4, 20) ];
			
			addChild( tfScore ); 
		}
	}
	
	public function getScoreTf(txt) {
		var tf = new TextField();
		
		var tft = new TextFormat(nokia.fontName,8,0xFF0707);
		tf.setTextFormat( tf.defaultTextFormat = tft ); 
		tf.embedFonts = true;
		
		tf.mouseEnabled = false;
		tf.selectable = false;
		
		tf.width = 100;
		tf.height = 30;
		tf.text = txt;
		tf.width = tf.textWidth + 5;
		
		addChild( tf ); 
		
		return tf;
	}
	
	public function addScore( d ,x,y )
	{
		var tf = getScoreTf((d>0?"+":"-")+Std.string(d));
		tf.x = x;
		tf.y = y;
		tfMsg.add(  new Tf(tf, 15, 0.3 ) );
		score += d;
	}
	
	public function addMessage( msg ,x,y )
	{
		var tf = getScoreTf(msg);
		tf.x = x;
		tf.y = y;
		tfMsg.add( new Tf(tf, 30, 0.3 ) );
	}
	
	
	public function update() {
		tfScore.text = Std.string(score);
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