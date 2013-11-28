import volute.Types;

using volute.com.Ex;

class ScrollableBitmap extends Bitmap
{
	public var ox:Float;
	
	public function new(b)
	{
		super(b);
	}
}

enum SPRITE_LAYER
{
	SL_CHAR_FRONT;
	SL_CHAR_BACK;
}

class Level 
{
	public var root : flash.display.Sprite;
	var store : IntHash<List<Entity>>;
	var stc : 
	{
		ld : flash.display.BitmapData,
		w:Int,
		h:Int,
	};
	
	var spawnX : Int; 
	var spawnY : Int;
	public var idx : Int;
	
	var front : flash.display.Sprite;
	var bloodTest : fx.BloodLine;
	
	var light : Bitmap;
	var sky : Bitmap;
	var scrolls0 : Array<ScrollableBitmap>;
	var scrolls1 : Array<ScrollableBitmap>;
	var scrolls2 : Array<ElementEx>;
	
	var props : List<ElementEx>;
	var rd : volute.Rand;
	var grid : flash.display.Shape;
	
	public var structure:Bitmap;
	
	public function new(i) 
	{
		root = new flash.display.Sprite();
		front = new flash.display.Sprite();
		store = new IntHash<List<Entity>>();
		scrolls0 = [];
		scrolls1 = [];
		scrolls2 = [];
		props = new List<ElementEx>();
		//init vars there
		rd = new volute.Rand( (i * 32143574) ^ 0xdeadbeef );
		for ( i in 0...100)
			rd.rand();
			
		//init gd here
		spec(idx = i);
		
		#if debug
		//mkGrid();
		#end
	}
	
	public function kill()
	{
		structure.bitmapData.dispose();
		structure = null;
		
		root.removeChildren();
		root = null;
		
		light.bitmapData.dispose();
		sky.bitmapData.dispose();
		
		for ( p in props)
			p.kill();

		for (s in scrolls0)
			s.bitmapData.dispose();
		
		for (s in scrolls1)
			s.bitmapData.dispose();
			
		for (s in scrolls2)
			s.kill();
		
			
		for ( s in store)
			if (s != null)
				for ( e in s )
					e.kill();
	}
	
	public function mkGrid()
	{
		grid = new flash.display.Shape();
		
		
		for( y in 0...Tools.ch() )
		{
			for( x in 0...Tools.cw()*4 )
			{
				var gfx = grid.graphics;
				
				var isColl = staticTest( x, y);
				if (isColl)
					gfx.beginFill( 0xFF0000, 0.4);
				gfx.lineStyle( 1,0x00FF00 );
				gfx.moveTo(x * 16, y * 16);
				gfx.lineTo((x + 1) * 16, y * 16);
				gfx.lineTo((x + 1 )* 16, (y+1) * 16);
				gfx.lineTo(x * 16, (y + 1) * 16);
				gfx.lineStyle();
				gfx.endFill();
			}
		}
		
		root.addChild(grid);
		grid.toFront();
		
		root.addEventListener(flash.events.MouseEvent.MOUSE_DOWN,
		function(e:flash.events.MouseEvent)
		{
			trace("level:"+idx+" "+Std.int(e.localX / 16) + " " + Std.int(e.localY / 16));
		});
	}
	
	public function iterEntities(f:Entity->Void)
	{
		for ( l in store)
			if ( l != null)
				for ( e in l ) 
					f(e);
	}
	
	public inline function mkKey(cx, cy)
	{
		return (cx << 16) | cy;
	}
	
	public function dynTest(cx, cy)
	{
		var k = mkKey(cx, cy);
		if ( !store.exists( k )) return false;
		return store.get(k).length > 0;
	}
	
	public inline function staticTest(cx, cy)
	{
		return 0 != stc.ld.getPixel(cx, cy);
	}
	
	function lo(s)
		return s.toLowerCase()
		
	public function staticBump(cx, cy)
	{
		var c = stc.ld.getPixel(cx, cy);
		var x = M.data.wallIndex.get( c );
		if ( x == null ) return;
		if ( !x.xml.has.data ) return;
		for ( s in x.xml.att.data.split(',') )
		{
			switch(lo(s))
			{
				case lo("nextLevel"):
					M.op.push(
					function()
					{
						if (M.nextLevel == null)
						{
							M.char.pause = true;
							M.nextLevel = M.level.idx + 1;
						}
					}
					); 
			}
		}
	}
	
	public inline function get(cx, cy)
		return store.get( mkKey(cx, cy))
	
	public function add(e:Entity)
	{
		var nk = mkKey(e.cx, e.cy);
		if ( !store.exists(nk) ) store.set( nk, new List() );
			store.get(nk).push( e );
		root.addChild( e.el );
	}
	
	public function onEnterGd(i:Int)
	{
		var lev = getXMLLevel(i);
		Tools.assert( lev != null );
		for ( cmd in lev.elements )
		{
			switch( cmd.name )
			{
				default:
				case "enter":  for( x in cmd.elements ) executeXMLCmd(x);
			}
		}
	}
	
	public function enterLevel()
	{
		onEnterGd(idx);
		
		root.parent.parent.addChild( light );
		light.toBack();
		sky.putBehind( light );
		
		for ( s in scrolls0) 
		{
			root.parent.parent.addChild( s );
			s.putInFront( sky );
		}
		
		for ( s in scrolls1) 
		{
			root.parent.parent.addChild( s );
			s.putInFront( sky );
		}
		
		for ( s in scrolls2) 
		{
			root.parent.parent.addChild( s );
			s.putBehind( structure );
		}
		
		M.char.enterLevel(this);
		
		for ( l in store)
			if ( l != null)
				for ( e in l ) 
					if( e != M.char )
						e.enterLevel(this);
					
		
		for ( p in props )
		{
			root.addChild( p );
			if ( p.data.layer == null)
				p.putBehind(structure);
			else 
			switch(p.data.layer)
			{
				case SL_CHAR_FRONT:
				p.putInFront(M.char.el);
				case SL_CHAR_BACK:
				p.putBehind(M.char.el);
			}
		}
		
	}
	
	public function leaveLevel()
	{
		light.detach();
		sky.detach();
		for ( s in scrolls0) s.detach();
		for ( s in scrolls1) s.detach();
		for ( s in scrolls2) s.detach();
	}
	
	public function remove(e:Entity, cx, cy)
	{
		var ok = mkKey(cx, cy);
		store.get(ok).remove(e);
		e.l = null;
	}
	
	public function remove2(e:Entity)
	{
		for ( l in store)
			if ( l != null)
				l.remove(e);
	}
	
	public function warp(e:Entity,cx, cy)
	{
		var ocx = e.cx;
		var ocy = e.cy;
		var ok = mkKey(ocx, ocy);
		if(e.l != null)
			store.get(ok).remove(e);
		e.cx = cx; 
		e.cy = cy;
		var nk = mkKey(e.cx, e.cy);
		if ( !store.exists(nk) ) store.set( nk, new List() );
		store.get(nk).push( e );
		e.l = this;
	}
	
	public function buildBg()
	{
		sky = new Bitmap( new Data.BmpSky(0, 0, false));
		light = new Bitmap( new Data.BmpLight(0, 0, false));
		light.blendMode =  flash.display.BlendMode.ADD;
		light.alpha = 0.2;
		
		function expand(a:Array<ScrollableBitmap>,bmd:BitmapData) {
			var t = Tools.lw();
			var n = 0;
			while ( t > 0)
			{
				var b;
				a.pushBack( b=new ScrollableBitmap( bmd ) );
				b.x += b.width * n;
				b.y = Tools.lh() - b.height;
				b.ox = b.x;
				n++;
				t -= Std.int(b.width);
			}
		}
		
		expand( scrolls0, new Data.BmpBg01(0, 0, false ));
		expand( scrolls1, new Data.BmpBg02(0, 0, false ));
		
		var t = Tools.lw();
		var n = 0;
		while ( t > 0)
		{
			var b;
			scrolls2.pushBack( b =
			{
				var e =new ElementEx();
				e.goto( "sidewalk" );
				e;
			});
			b.x += b.width * n -8;
			b.y = 13 * 16;
			//b.y = 20;
			n++;
			t -= Std.int(b.width);
		}
		
		for (s in scrolls1)
			s.y -= 35;
	}
	
	public function updateBg()
	{
		var c = M.char;
		
		var scrollPow = 1.25;
		for (s in scrolls0 ) s.x = Std.int(s.ox + M.bbLevelRoot.x * 0.01 * scrollPow);
		for (s in scrolls1 ) s.x = Std.int(s.ox + M.bbLevelRoot.x * 0.02 * scrollPow);
	}
	
	public function update(force=false)
	{
		if(!root.visible ) return;
	
		var ocx;
		var ocy;
		for (l in store)
		{
			for ( e in l)
			{
				ocx = e.cx;
				ocy = e.cy;
				var ok = mkKey(ocx, ocy);
				e.update();
				var nk = mkKey(e.cx, e.cy);
				if( nk != ok )
				{
					if( e.l!=null)
						store.get(ok).remove(e);
						
					if ( !store.exists(nk) )
						store.set( nk, new List() );
					store.get(nk).push( e );
				}
				
				if ( e.type == ET_PEON )
					e.el.visible = Math.abs(e.el.x - M.char.el.x) <= 350;
			}
		}
		
		//updateBg();
	}
	
	//mk specific setup
	public function spec( i : Int)
	{
		switch(i)
		{
			default:
			{
				var bmd = new flash.display.BitmapData( Tools.cw() * 4, Tools.ch(), false);
				var lw = Tools.cw()*4;
				var lh = Tools.ch();
				
				var tl = M.data.ld;
				bmd.fillRect( bmd.rect, 0);
				
				var stg = i -1;
				bmd.copyPixels( tl, new flash.geom.Rectangle(0, stg * Tools.ch(),lw, Tools.ch()), new flash.geom.Point(0, 0) );
				
				stc = 
				{
					ld:bmd,
					w:lw,
					h:lh,
				};
			}
			case 0:
			{
				var lw = Tools.cw();
				var lh = Tools.ch();
				var bmd = new flash.display.BitmapData(lw, lh, false);//4 screens
				bmd.fillRect( bmd.rect, 0);
				for ( i in 0...lw )
					bmd.setPixel(i, 12, 1);
					
				for ( i in 0...lh )
					bmd.setPixel(0, i, 1);
					
				for ( i in 0...lh )
					bmd.setPixel(lw - 1, i, 1);
					
				for ( i in 0-4...lw-4 )
					bmd.setPixel(i, lh - 8, 1);
								
				stc = 
				{
					ld:bmd,
					w:lw,
					h:lh,
				}
				
			}
		}
		
		buildBg();
		buildStatic();
		buildGd();
		
		root.addChild( front );
		
		#if false
		front.addChild( new Bitmap(stc.ld) );
		#end
		
		front.toFront();
		
	}
	
	public function getXMLLevel(i:Int)
	{
		return M.data.gd.nodes.level
		.filter(function(t) return Std.parseInt(t.att.id) == i )
		.first();
	}
	
	public function executeXMLCmd(cmd:haxe.xml.Fast) 
	{
		var lo = function(s) return s.toLowerCase();
		
		switch( lo(cmd.name) )
		{
			case lo("addPeon"):
				var p;
				add( p = new Peon() );
				var s = cmd.innerData.split(',').map(Std.parseInt).array();
				
				
			case lo("spawn"):
				var s = cmd.innerData.split(',').map(Std.parseInt).array();
				M.level.warp( M.char, s[0], s[1] );
				M.char.syncPos();
				
			case lo('msg'):
				var msg  = M.ui.mkMsg( cmd.innerHTML );
				if ( cmd.has.life )
					msg.life = Std.parseInt(cmd.att.life);
					
			case lo('addSprite'):
				var pos = cmd.att.pos.split(',').map(Std.parseInt).array();
				
				var l = new ElementEx();
				l.setAlign( 0.0, 1.0);
				l.goto( cmd.att.id );
				l.x = pos[0] * 16;
				l.y = pos[1] * 16 + 16;
				
				
				var lay = !cmd.has.layer?null:
				switch(cmd.att.layer.toLowerCase())
				{
					case "charfront":SL_CHAR_FRONT;
					case "charback":SL_CHAR_BACK;
				};
				l.data.layer = lay;
				
				props.push( l );
				
			case lo('peonGen'):
				var pos = cmd.att.pos.split(',').map(Std.parseInt).array();
				
				
				var s = { x:pos[0], y:pos[1] };
				var a = [ Reflect.copy(s) ];
				var cont = true;
				
				var iter = 6;
				while( cont )
				{
					s.x--;
					if ( staticTest( s.x, s.y ))
					{
						cont = false;
						break;
					}
					else
						a.pushBack(Reflect.copy(s));
						
					iter--;
					if (iter <= 0) break;
				}
				
				var cont = true;
				var iter = 6;
				while( cont )
				{
					s.x++;
					if ( staticTest( s.x, s.y ))
					{
						cont = false;
						break;
					}
					else
						a.pushBack(Reflect.copy(s));
					iter--;
					if (iter <= 0) break;
				}
				
				var nb = 3;
				if ( cmd.has.nb )
					nb = Std.parseInt( cmd.att.nb );
				
				var oa = a.copy();
				
				for ( p in 0...nb)
				{
					var p = new Peon();
					
					if ( a.length == 0)
						a = oa.copy();
						
					var idx = rd.random(a.length);
					var ar =  a[idx];
					a.removeByIndex(idx);
					
					var set = M.data.pnjPhrases.filter( function(s) return s.cat < 10);
					var some = set.nth( rd.random(set.length) );
					Tools.assert(some != null, "no more sentences for peon "+p );
					M.data.pnjPhrases.remove( some );
					switch(some.cat)
					{
						case 0 : 	M.data.mkChar( p.spr, "peon_female", "stand" );
						case 1 : 	M.data.mkChar( p.spr, "peon_male", "stand" );
						case 2: 	M.data.mkChar( p.spr, "peon_elder", "stand" );
						case 3: 	M.data.mkChar( p.spr, "peon_granny", "stand" );
						case 4: 	M.data.mkChar( p.spr, "peon_kid_male", "stand" );
						case 5: 	M.data.mkChar( p.spr, "goat", "stand" );
					}
					p.pnjData =  some;
							
					p.cx = ar.x;
					p.cy = ar.y;
					p.rx = 0.05 + Math.random() * 0.85;
					p.ry = 1.0;
					
					add(p);
				}
		}
	}
	
	public function buildGd()
	{
		var lev = getXMLLevel(idx);
		Tools.assert( lev != null );
		
		for ( cmd in lev.elements )
		{
			switch( cmd.name )
			{
				default:
				case "init": 
					{
						for ( x in cmd.elements ) executeXMLCmd(x);
						
						var nbPoints = 0;
						var nbPeons = 0;
						iterEntities(function(e)
							if (e.type == ET_PEON )
							{
								var p : Peon = cast e;
								if(p.pnjData!=null)
								{
									nbPoints += p.pnjData.score;
									nbPeons++;
								}
								
							});
						#if debug	
						trace('level ' + idx + " contains " + nbPoints + " and " + nbPeons + " peons");
						#end
					}
				
			}
		}
	}
	
	
	
	
	public function buildStatic()
	{
		var bg = new Bitmap(new BitmapData( Tools.lw(), Tools.lh(), true));
		bg.bitmapData.fillRect(bg.bitmapData.rect, 0);
		var m = new flash.geom.Matrix();
		var tl  = M.data.tileLib;
		
		for(y in 0...stc.h)
		{
			for (x in 0...stc.w)
			{
				var p = stc.ld.getPixel(x, y); 
				if (p == 0) continue;
				
				var gc = M.data.wallIndex.get( p );
				if ( gc == null)
				{
					//its a char
					var data = M.data.charIndex.get(p);
					if (data == null)
					{
						var data = M.data.propIndex.get(p);
						if ( data == null ) 
							continue;
						var l = new ElementEx();
						l.goto(data.sprite);
						l.x += l.width * 0.5 + x  *16;
						l.y += y*16 + 16;
						props.add( l );
					}
					else
					{
						var p = new Peon();
						
						if ( data.named != null )
						{
							M.data.mkChar( p.spr, data.named, "stand" );
							for(u in M.data.pnjPhrases )
							{
								if ( u.cat == data.cat )
								{
									p.pnjData = u;
									M.data.pnjPhrases.remove(u);
									break;
								}
							}
						}
						else
						{
							var set = M.data.pnjPhrases.filter( function(s) return s.cat == data.cat);
							var some = set.nth( rd.random(set.length) );
							
							Tools.assert(some != null, data.cat+" has no sentences" );
							M.data.pnjPhrases.remove( some );
							switch(some.cat)
							{
								case 0 : 	M.data.mkChar( p.spr, "peon_female", "stand" );
								case 1 : 	M.data.mkChar( p.spr, "peon_male", "stand" );
								case 2: 	M.data.mkChar( p.spr, "peon_elder", "stand" );
								case 3: 	M.data.mkChar( p.spr, "peon_granny", "stand" );
								case 4: 	M.data.mkChar( p.spr, "peon_kid_male", "stand" );
								case 5: 	M.data.mkChar( p.spr, "goat", "stand" );
							}
							p.pnjData =  some;
						}
						
						p.cx = x;
						p.cy = y;
						p.rx = 0;
						p.ry = 1.0;
						add( p );
					}
				
					stc.ld.setPixel(x, y, 0);
				}
				else
				{
					p = gc.idx;
				
					if ( p <= cast tl.getGroup("wall").length )
						tl.drawIntoBitmap(bg.bitmapData, x * 16, y * 16, "wall", p, 0, 0);
						
					if (gc.xml.has.data && gc.xml.att.data.split(',').has('noBlock'))
						stc.ld.setPixel(x, y, 0);
				}
			}
		}
		
		root.addChild( structure = bg );
	}
}