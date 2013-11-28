package mt.deepnight;

enum Day {
	Sunday;
	Monday;
	Tuesday;
	Wednersday;
	Thursday;
	Friday;
	Saturday;
}

class Lib {
	public static inline function countDaysUntil(now:Date, day:Day) {
		var delta = Type.enumIndex(day) - now.getDay();
		return if(delta<0) 7+delta else delta;
	}

	public static inline function getDay(date:Date) : Day {
		return Type.createEnumIndex(Day, date.getDay());
	}

	public static inline function setTime(date:Date, h:Int, ?m=0,?s=0) {
		var str = "%Y-%m-%d "+StringTools.lpad(""+h,"0",2)+":"+StringTools.lpad(""+m,"0",2)+":"+StringTools.lpad(""+s,"0",2);
		return Date.fromString( DateTools.format(date, str) );
	}

	public static inline function countDeltaDays(now_:Date, next_:Date) {
		var now = setTime(now_, 5);
		var next = setTime(next_, 5);
		return Math.floor( (next.getTime() - now.getTime()) / DateTools.days(1) );
	}

	public static inline function leadingZeros(s:Dynamic, zeros:Int) {
		var str = Std.string(s);
		while (str.length<zeros)
			str="0"+str;
		return str;
	}
	
	#if neko
	public static function drawExcept<T>(a:List<T>, except:T, ?randFn:Int->Int):T {
		if (a.length==0)
			return null;
		if (randFn==null)
			randFn = Std.random;
		var a2 = new Array();
		for (elem in a)
			if (elem!=except)
				a2.push(elem);
		return
			if (a2.length==0)
				null;
			else
				a2[ randFn(a2.length) ];
			
	}
	#end
	
	#if flash9
	public static function redirectTracesToConsole(?customPrefix="") {
		haxe.Log.trace = function(m, ?pos)
		{
			try
			{
				if ( pos != null && pos.customParams == null )
					pos.customParams = ["debug"];
				
				flash.external.ExternalInterface.call("console.log", pos.fileName + "(" + pos.lineNumber + ") : " + customPrefix + Std.string(m));
			}
			catch(e:Dynamic) { }
		}
	}

	public static function atLeastVersion(version:String) { // format : xx.xx.xx.xx ou xx,xx,xx,xx
		var s = StringTools.replace(version, ",", ".");
		var req = s.split(".");
		var fv = flash.system.Capabilities.version;
		var mine = fv.substr(fv.indexOf(" ")+1).split(",");
		for (i in 0...req.length) {
			if (mine[i]==null || req[i]==null)
				break;
			var m = Std.parseInt(mine[i]);
			var r = Std.parseInt(req[i]);
			if ( m>r )	return true;
			if ( m<r )	return false;
			
		}
		return true;
	}
	
	public static function getCookie(cookieName:String, varName:String, ?defValue:Dynamic) : Dynamic {
		var cookie = flash.net.SharedObject.getLocal(cookieName);
		return
			if ( Reflect.hasField(cookie.data, varName) )
				Reflect.field(cookie.data, varName);
			else
				defValue;
	}
	
	public static function setCookie(cookieName:String, varName:String, value:Dynamic) {
		var cookie = flash.net.SharedObject.getLocal(cookieName);
		Reflect.setField(cookie.data, varName, value);
		cookie.flush();
	}
	
	public static function resetCookie(cookieName:String, ?obj:Dynamic) {
		var cookie = flash.net.SharedObject.getLocal(cookieName);
		cookie.clear();
		if (obj!=null)
			for (key in Reflect.fields(obj))
				Reflect.setField(cookie.data, key, Reflect.field(obj, key));
		cookie.flush();
	}
	
	public static inline function constraintBox(o:flash.display.DisplayObject, maxWid, maxHei) {
		var r = Math.min( Math.min(1, maxWid/o.width), Math.min(1, maxHei/o.height) );
		o.scaleX = r;
		o.scaleY = r;
		return r;
	}
	
	public static inline function isOverlap(a:flash.geom.Rectangle, b:flash.geom.Rectangle) : Bool {
		return
			b.x>=a.x-b.width && b.x<=a.right &&
			b.y>=a.y-b.height && b.y<=a.bottom;
	}
	#end
	
	
	public static function shuffle<T>(l:Iterable<T>, ?rand:Int->Int) : Array<T> {
		if(rand==null)
			rand = Std.random;
		var arr = new Array();
		for (e in l)
			arr.insert(rand(arr.length), e);
		return arr;
	}
	
	public static function randomSpread(total:Int, maxPools:Int) {
		if (total<=0 || maxPools<=0)
			return new Array();
		var pools = new Array();
		for (i in 0...maxPools)
			pools[i] = 0;
			
		var remain = total;
		while (remain>0) {
			var move = Math.ceil(total*(Std.random(4)+1)/100);
			if (move>remain)
				move = remain;
			
			var p = Std.random(maxPools);
			pools[p]+=move;
			remain-=move;
		}
		return pools;
	}
	
	
	public static inline function constraint(n:Dynamic, min:Dynamic, max:Dynamic) {
		return
			if (n<min) min;
			else if (n>max) max;
			else n;
	}
	
	public static inline function replaceTag(str:String, char:String, open:String, close:String) {
		var char = "\\"+char.split("").join("\\");
		var re = char+"([^"+char+"]+)"+char;
		return try { new EReg(re, "g").replace(str, open+"$1"+close); } catch (e:String) { str; }
	}
	
	public static inline function sign() {
		return Std.random(2)*2-1;
	}
		
	public static inline function distanceSqr(ax:Float,ay:Float,bx:Float,by:Float) : Float {
		return (ax-bx)*(ax-bx) + (ay-by)*(ay-by);
	}
		
	public static inline function distance(ax:Float,ay:Float, bx:Float,by:Float) : Float {
		return Math.sqrt( distanceSqr(ax,ay,bx,by) );
	}
		
	public static inline function randFloat(max:Float) {
		return Std.random(Std.int(max*10000))/10000;
	}
	
	public static inline function randFloatSeed(rseed:mt.Rand, max:Float) {
		return rseed.random(Std.int(max*10000))/10000;
	}
	
	public static inline function getNextPower2(n:Int) { // n est sur 32 bits
		n--;
		n |= n >> 1;
		n |= n >> 2;
		n |= n >> 4;
		n |= n >> 8;
		n |= n >> 16;
		return n++;
	}
	public static inline function getNextPower2_8bits(n:Int) { // n est sur 8 bits
		n--;
		n |= n >> 1;
		n |= n >> 2;
		n |= n >> 4;
		return n++;
	}
	
	// Comparaison optimisée pour éviter les collisions et erreurs de prédiction
	// Source : http://bits.stephan-brumme.com/minmax.html
	static inline function fastSelect(x:Int,y:Int, ifXSmaller:Int, ifYSmaller:Int) {
		var diff = x-y;
		var bit31 = diff >> 31;
		return (bit31 & (ifXSmaller ^ ifYSmaller)) ^ ifYSmaller;
	}
	
	static inline function fastMinimum(x:Int,y:Int) {
		return fastSelect(x,y, x,y);
	}
	static inline function fastMaximum(x:Int,y:Int) {
		return fastSelect(x,y, y,x);
	}
	
	
	public static inline function abs(a:Float) {
		return (a<0) ? -a : a;
	}
	
	public static inline function rnd(min:Float, max:Float, ?sign=false) {
		if( sign )
			return (min + Math.random()*(max-min)) * (Std.random(2)*2-1);
		else
			return min + Math.random()*(max-min);
	}
	
	public static inline function irnd(min:Int, max:Int, ?sign:Bool) {
		if( sign )
			return (min + Std.random(max-min+1)) * (Std.random(2)*2-1);
		else
			return min + Std.random(max-min+1);
	}
	
	public static inline function rad(a:Float) : Float {
		return a*3.1416/180;
	}
	
	public static inline function deg(a:Float) : Float {
		return a*180/3.1416;
	}
	
	public static function splitUrl(url:String) {
		if( url==null || url.length==0 )
			return null;
		var noProt = if( url.indexOf("://")<0 ) url else url.substr( url.indexOf("://")+3 );
		return {
			prot	: if( url.indexOf("://")<0 ) null else url.substr(0, url.indexOf("://")),
			dom		: if( noProt.indexOf("/")<0 ) noProt else if( noProt.indexOf("/")==0 ) null else noProt.substr(0, noProt.indexOf("/")),
			path	: if( noProt.indexOf("/")<0 ) "/" else noProt.substr(noProt.indexOf("/")),
		}
	}
	
	public static function splitMail(mail:String) {
		if (mail==null || mail.length==0)
			return null;
		if (mail.indexOf("@")<0)
			return null;
		else {
			var a = mail.split("@");
			if ( a[1].indexOf(".")<0 )
				return null;
			else
				return {
					usr	: a[0],
					dom	: a[1].substr(0,a[1].indexOf(".")),
					ext	: a[1].substr(a[1].indexOf(".")+1),
				}
		}
	}

	#if flash9
	static var flattened : Hash<flash.display.Bitmap> = new Hash();
	public static function disposeFlattened(uniqId:String) {
		if( !flattened.exists(uniqId) )
			return;
		flattened.get(uniqId).bitmapData.dispose();
		flattened.remove(uniqId);
	}
	
	public static function disposeAllFlatteneds() {
		for( bmp in flattened )
			if( bmp.bitmapData!=null )
				bmp.bitmapData.dispose();
				
		flattened = new Hash();
	}
	
	public static function flatten(o:flash.display.DisplayObject, ?uniqId:String, ?padding=0.0, ?copyTransforms=false, ?quality:flash.display.StageQuality) {
		var qold = flash.Lib.current.stage.quality;
		if( quality!=null )
			try {
				flash.Lib.current.stage.quality = quality;
			} catch( e:Dynamic ) {
				throw("flatten quality error");
			}
		var b = o.getBounds(o);
		var bmp = new flash.display.Bitmap( new flash.display.BitmapData(Math.ceil(b.width+padding*2), Math.ceil(b.height+padding*2), true, 0x0) );
		var m = new flash.geom.Matrix();
		m.translate(-b.x, -b.y);
		m.translate(padding, padding);
		bmp.bitmapData.draw(o, m, o.transform.colorTransform);

		var m = new flash.geom.Matrix();
		m.translate(b.x, b.y);
		m.translate(-padding, -padding);
		if( copyTransforms ) {
			m.scale(o.scaleX, o.scaleY);
			m.rotate( rad(o.rotation) );
			m.translate(o.x, o.y);
		}
		bmp.transform.matrix = m;
		
		if( uniqId!=null ) {
			disposeFlattened(uniqId);
			flattened.set(uniqId, bmp);
		}
		if( quality!=null )
			try {
				flash.Lib.current.stage.quality = qold;
			} catch( e:Dynamic ) {
				throw("flatten quality error");
			}
		return bmp;
	}
	#end
}
