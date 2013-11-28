import flash.text.TextField;
using volute.com.Ex;
import volute.Types;
import volute.algo.Pool;
import mt.deepnight.Tweenie;

typedef Msg = 
{
	txt : flash.text.TextField,
	?bmp : flash.display.Bitmap,
	life:Int,
	?rd:Int,
}

class Ui 
{
	public var root : flash.display.Sprite;
	public var msgRoot : flash.display.Sprite;
	var msgQueue : List<Msg>;
	
	var score : TextField;
	var loweringScore : volute.algo.Pool<TextField>;
	
	var timer : TextField;
	
	public function new()
	{
		root = new flash.display.Sprite();
		msgQueue = new List();
		
		msgRoot = new flash.display.Sprite();
		var b = 2;
		msgRoot.graphics.beginFill(0xffffff);
		msgRoot.graphics.drawRoundRect( b, b, Tools.gw()-b*2,20-b*2,2,2 );
		msgRoot.graphics.endFill();
		msgRoot.filters = [ new flash.filters.GlowFilter(0xFF0000,1,4,4,100)];
		msgRoot.y = Tools.gh() - 20;
		msgRoot.alpha = 0;
		
		root.addChild(msgRoot);
		
		score = getTf( "0000", false );
		root.addChild(score);
		score.x = 8;
		score.y = 8;
		score.filters = [ new flash.filters.GlowFilter(0x0, 1, 4, 4, 100)];
		timer = getTf( "00:00", true );
		root.addChild(timer);
		timer.x = Tools.gw() -  timer.width;
		timer.y = 8;
		timer.filters = [ new flash.filters.GlowFilter(0x0, 1, 4, 4, 100)];
		loweringScore = new Pool(
			function()
			{
				return getTf("", false);
			}
		);
	}
	
	public function reapScore( v : Int )
	{
		var t = loweringScore.create();
		t.alpha = 1;
		t.text = (v > 0?"+":"") + v;
		
		t.y = score.y;
		t.x = score.x + score.width - t.width;
		var d = 1000;
		
		var c = M.tweenie.create( t, "y", t.y + 50, TType.TEaseOut,d );
		root.addChild( t );
		c.onEnd  = function()
		{
			root.removeChild( t);
		}
	}
	
	public function updateReap()
	{
		for ( t in loweringScore.getUsed())
		{
			var r = t.textColor >> 16; r -= 4;
			t.textColor=(r<<16) | (t.textColor&0xFFFF);
		}
	}
	
	public function update()
	{
		var sc =  Std.string(M.char.score);
		for ( i in sc.length...4) sc = "0" + sc;
		score.text = sc;
		
		var timerS = Std.int( M.GAME_DUR - (M.char.timer / 1000.0) );
		var m = Std.string( Std.int(timerS/60));
		var s = Std.string(timerS % 60);
		for ( i in s.length...2) s = "0" + s;
		for ( i in m.length...2) m = "0" + m;
		timer.text =  m +":" + s;
		
		updateReap();
		var f = msgQueue.first();
		if (f == null) return;
		
		f.life--;
		if(f.life>0)
		{
			return;
		}
		else
		{
			var d = getD();
			
			if ( f.life == 0 )
			{
				f.bmp = mt.deepnight.Lib.flatten( f.txt );
				var idx = msgRoot.getChildIndex( f.txt );
				msgRoot.addChildAt( f.bmp, idx );
				f.txt.detach();
				f.bmp.x = f.txt.x;
				f.bmp.y = f.txt.y;
			}
			else 
			if ( f.life < 0 )
			{
				var b  = f.bmp.bitmapData;
				b.pixelDissolve( b, b.rect, new flash.geom.Point(0, 0), Std.random(57831186), Std.int(b.width*b.height * 12 / 100.0 / d) , 0 );
			}
			
			if ( f.life < Std.int( d * -13) )
			{
				msgQueue.pop();
				f.bmp.bitmapData.dispose();
				f.bmp.detach();
				f.bmp.bitmapData = null;
				
				if(msgQueue.length>=1)
					msgRoot.addChild( msgQueue.first().txt );
				else
					M.tweenie.create(msgRoot, "alpha", 0, TType.TEaseIn,Std.int(d*180));
				
			}
		}
	}
	
	
	public static function getTf(str,x2=false)
	{
		var tf = new TextField();
		tf.htmlText = str.toUpperCase();
		var tformat = new flash.text.TextFormat("pixel", x2?20:10, 0xFF0000);
		tformat.letterSpacing = -1;
		tf.embedFonts = true;
		tf.setTextFormat( tf.defaultTextFormat = tformat);
		tf.multiline = true;
		tf.autoSize = flash.text.TextFieldAutoSize.LEFT;
		tf.width = Tools.gw();
		
		tf.height = 20;
		tf.selectable = false;
		tf.mouseEnabled = false;
		return tf;
	}
	
	public function isMsgQueueFull()
	{
		return msgQueue.length > 2;
	}
	
	public function getD()
	{
		return isMsgQueueFull() ? 0.8: 2.0;
	}

	public function mkMsg(str) : Msg
	{
		var d = getD();
		
		var tf;
		var t = 
		{
			txt: tf=getTf(str),
			life: Std.int(d*60),
		};
		t.txt.x = 10;
		t.txt.y = 5;
		msgQueue.add(t);
		if(msgQueue.length==1)
			msgRoot.addChild( tf );
		M.tweenie.terminate( root, "alpha");
		msgRoot.alpha = 1;
		return t;
	}
}