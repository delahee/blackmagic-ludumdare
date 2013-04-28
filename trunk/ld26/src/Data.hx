import flash.Lib;
import flash.display.BitmapData;
import flash.utils.Namespace;
import starling.core.Starling;
import starling.display.MovieClip;

import haxe.xml.Fast;

import pix.Element;
import pix.Store;

import starling.textures.Texture;

using  Lambda;
using  volute.LbdEx;
using  volute.ArrEx;

import starling.textures.Texture;
import volute.t.Vec2;

enum Side{
	SPlayer;
	SOther;
}

typedef CineLine = {
	line:String,
	side:Side,
}
typedef Cine = 
{
	sprite:String,
	script:List<CineLine>,
	proc:Void->Void,
	ofs:Vec2,
}


typedef XMLSlice =
{
	xml:haxe.xml.Fast,
	coord: { 	x : Int, y: Int,
				h: Int,  w : Int},
	nb: { x:Int, y:Int },
	hitbox :
	{
		x:Int,y:Int,w:Int,h:Int
	}
}

typedef XMLState =
{
	xml:haxe.xml.Fast,
	id:String,
	slices:Array<XMLSlice>,
}

typedef XMLSprite =
{
	xml:haxe.xml.Fast,
	sheet:String,
	id:String,
	states:Array<XMLState>,
}

typedef EngineSheet = { 
	name:String, 
	sheet:TestSheet, 
	store:pix.Store, 
	texSheet:Texture,
}

@:bitmap("../gfx/png/test.png")
class TestSheet extends flash.display.BitmapData
{
	
}


@:bitmap("../gfx/planche/perso.png")
class PersoSheet extends flash.display.BitmapData
{
	
}

@:bitmap("../gfx/planche/propsspritesheet.png")
class PropsSheet extends flash.display.BitmapData
{
	
}


@:file("../gfx/data.xml")
class SheetXml extends flash.utils.ByteArray
{
	
}

@:bitmap("../gfx/lvl/1.png")
class BmpLevel extends flash.display.BitmapData
{
	
}

class BmpBg extends flash.display.BitmapData {
	
}


@:file("../gfx/ld.xml")
class LDXml extends flash.utils.ByteArray
{
	
}


class Data implements haxe.Public
{
	var xml : haxe.xml.Fast;

	var sprites : Hash<XMLSprite>;
	var sheets : Hash<{name:String, sheet:BitmapData, texSheet: starling.textures.Texture,store:Store}>;
	var texRegion  : flash.geom.Rectangle;
	
	var level : BmpLevel;
	var ld : haxe.xml.Fast;
	var fxQueue : List<MovieClip>;
	
	public var texts :Hash<String>;
	public var rdText : Array < String >;
	
	public var cines : Hash<Cine>;
	
	public static var me : Data = null;
	public function new(){
		me = this;
		var str = new SheetXml().toString();
		xml = new haxe.xml.Fast( haxe.xml.Parser.parse( str ));
		ld =  new haxe.xml.Fast( haxe.xml.Parser.parse(  new LDXml().toString() )).node.ld;

		sprites = new Hash();
		sheets = new Hash();
		fxQueue = new List();
		level = new BmpLevel(0, 0, false);
		
		var ls : BitmapData = null;
		
		function loadSheet(name, obj:BitmapData) {
			var ls = null;
			return { name:name, sheet:ls=obj, store:new pix.Store( ls ), texSheet:Texture.fromBitmapData( ls, true, false, 1) };
		}
			
		var lsheets = 
		[
			loadSheet("perso", new PersoSheet(0, 0, false)),
			loadSheet("propsspritesheet", new PropsSheet(0, 0, false))
		];
		
		for ( s in lsheets ) {
			sheets.set( s.name, s );
		}
		
		for( ts in xml.nodes.tileDef){
			for ( spr in ts.nodes.sprite ){
				var sprId;
				var file = ts.att.file;
				var sheet = sheets.get(file);
				if ( sheet == null ) continue;
				var store = sheet.store;

				store.addIndex(sprId = spr.att.id);
				var frameCount = 0;
				var xmlStates = [];
				for(s in spr.nodes.state)
				{
					var stId = s.att.id;
					var slices = [];
					var fr = 0;
					var ofr = frameCount;

					for(sl in s.nodes.slice )
					{
						var coo = sl.att.coord.split(',')
						.map( Std.parseInt)
						.array();
						var nb : Array<Null<Int>> = (!sl.has.nb) ? [] : sl.att.nb.split(',')
						.map( Std.parseInt)
						.array();

						var s : XMLSlice =
						{
							xml:sl,
							coord: { x:coo[0], y:coo[1], w:coo[2], h:coo[3] },
							nb: { x:nb[0] == null?1 : nb[0],
								y:nb[1] == null?1 : nb[1],
							},
							hitbox:
							{
								var hcoo = sl.att.coord.split(',')
								.map( Std.parseInt)
								.array();

								if ( sl.hasNode.hitbox )	{ x:hcoo[0], y:hcoo[1], w:hcoo[2], h:hcoo[3] };
								else						{ x:0, y:0, w:coo[2], h:coo[3]};
							}
						};

						fr += s.nb.x * s.nb.y;
						store.slice( s.coord.x, s.coord.y, s.coord.w, s.coord.h, s.nb.x, s.nb.y);
						slices.push(s);
						frameCount += s.nb.x * s .nb.y;
					}

					var xmlState : XMLState =
					{
						id:stId,
						xml:s,
						slices:slices,
					}

					var anm = sprId + "." + stId;
					store.addAnim( anm,
					volute.Lib.rangeMinMax(ofr, frameCount) , //get precised range
					s.has.rythm ? volute.Lib.splat( Std.parseInt(s.att.rythm), fr ) : null ); //splat rythm
					
					xmlStates.push(xmlState);
				}

				var xmlSprite : XMLSprite =
				{
					xml:spr,
					id:sprId,
					states:xmlStates,
					sheet:ts.att.file,
				}
				sprites.set( sprId, xmlSprite);
				Lib.trace("read id: "+sprId /*+ " = " + xmlSprite*/);
			}
		}
	
		 
		texts = {
			var h = new Hash();
			function s(lbl, txt) h.set( lbl, txt);
			
			var i = 0;
			s('persoAlone_#0', 'Hi');
			s('persoAlone_#1', 'Anybody outta ?');
			s('persoAlone_#2', 'Darn, think I lost my party...');
			
			s('perso_jump_#0', 'woow that sensation, flying alone is good sometime');
			s('perso_jump_#1', 'whooooooooooooooooo that one as awesome');
			//s('persoAlone_jump_#2', 'urgh, there is a crasy thug eyeing me  ');
			//s('persoAlone_#3', 'At least my grass mawing skills will pay off.');
			
			h;
		};
		rdText = [];
		for( k in texts.keys()) {
			var t = texts.get( k );
			if( k.indexOf( "persoAlone_") >= 0)
				rdText.push( k  );
		}
		writeCine();
	}
	
	public function writeCine()
	{
		var cine = new Hash();
		cine.set('ben',{
			sprite: "ben",
			script: {
				var l = new List();
					l.add( { line:"Hi, what r u duin here", side:SPlayer } );
					l.add( { line:"coding a game, havin a bowl...", side:SOther } );
					l.add( { line:"kinda fell of my spaceship, can u hint a  way to nearest spaceport ?", side:SPlayer } );
					l.add( { line:"oh and what were you doing there ?", side:SOther } );
					l.add( { line:"...was ahem... on a sexual crusade aiming at mars there were grea...", side:SPlayer } );
					l.add( { line:"Anyway i have a gameplay for that, sexual cruise that is, it's simple, you can take two token, pretend they are fighting each other", side:SOther } );
					l.add( { line:"bla bla", side:SOther } );
					l.add( { line:"*the guy talks lightning fast about rules of  games involving strange fruits and animals*", side:SOther } );
					l.add( { line:"...anyway when the fruit reaches, the cat you have on the head...", side:SOther } );
					l.add( { line:"and you obviously feel entertained...", side:SOther } );
					l.add( { line:"*this guy is crazy* ok ahem, got to go, i have needs...", side:SPlayer } );
					l.add( { line:"ok bye ! ", side:SOther } );
					l.add( { line:"*that was a colorful character...*", side:SPlayer } );
				l;
			},
			proc:function() {},
			ofs:new Vec2(-40, 35),
		});
		
		cine.set('petit_prince',{
			sprite: "petit_prince",
			script: {
				var l = new List();
					l.add( { line:"Hi...its cold out there", side:SPlayer } );
					l.add( { line:"coldness...i myself find coldness peaceful", side:SOther } );
					l.add( { line:"kinda refreshing yes...", side:SPlayer } );
					l.add( { line:"we are expecting company, would you join us ?", side:SOther } );
					l.add( { line:"dunno if ihave time, a ship might leave soon", side:SPlayer } );
					l.add( { line:"what do you miss so deeply from those congested cans ?", side:SOther } );
					l.add( { line:"one or three things maybe...", side:SPlayer } );
					l.add( { line:"that is ?", side:SOther } );
					l.add( { line:"my HK p.m.v. first, useful when i am afraid...", side:SPlayer } );
					l.add( { line:"my 3chanophone, i am always looking for new stuff", side:SPlayer } );
					l.add( { line:"and did you find yourself", side:SOther } );
					l.add( { line:"*^_^' w.h.o.s. t.h.a.t. b.o.y....*", side:SPlayer } );
					l.add( { line:"*and my cat...the cat is for girl traps...", side:SPlayer } );
					l.add( { line:"you look desperately in need of others...", side:SOther } );
					l.add( { line:"as long as they are not too freaky...", side:SPlayer } );
					l.add( { line:"and who are you freak to ?", side:SOther } );
					l.add( { line:"no no no ahem...dropt it, you are too young to understand", side:SPlayer } );
				l;
			},
			proc:function() {},
			ofs:new Vec2(-40, 35),
		});
		
		cine.set('yoda',{
			sprite: "yoda",
			script: {
				var l = new List();
					l.add( { line:"***", side:SPlayer } );
					l.add( { line:"***", side:SOther } );
					l.add( { line:"*:-)*", side:SPlayer } );
					l.add( { line:"*:-P*", side:SOther } );
					l.add( { line:"*:-/*", side:SPlayer } );
					l.add( { line:"unrestful you are", side:SOther } );
					l.add( { line:"me good man, you what tongue ?", side:SOther } );
					l.add( { line:"thong ? swift you have to be if leave be, your mind is shrouded", side:SOther } );
					l.add( { line:"me from earth, me was on big iron boat", side:SOther } );
					l.add( { line:"strenght in you i feel, unrest clouds minds, unfocus birth haste, haste breed crasyness", side:SOther } );
					l.add( { line:"big man want leave LEAVE LEAVE, need my home, need my chicks, need...", side:SPlayer } );
					l.add( { line:"happiness no need has ? so many things but less should seek, less is MORE", side:SOther } );
					l.add( { line:"for moron you mean... no need for less, when can have plenty, ciao stupido !", side:SPlayer} );
				l;
			},
			proc:function() {},
			ofs:new Vec2(-40, 35),
		});
		
		cine.set('deepnight',{
			sprite: "deepnight",
			script: {
				var l = new List();
					l.add( { line:"hi there, you look a normal guy... at last", side:SPlayer } );
					l.add( { line:"*busy*", side:SOther } );
					l.add( { line:"do you know by chance...", side:SPlayer } );
					l.add( { line:"don't have time, plenty things to do.", side:SOther } );
					l.add( { line:"but, ahem, if you happend to", side:SPlayer } );
					l.add( { line:"talk to my leg, if need be,got a world to run", side:SOther } ); 
					l.add( { line:"...ok this one is weird...", side:SPlayer } );
					l.add( { line:"ciao, mind the door please, and please make less noise when leaving.", side:SOther } );
					l.add( { line:"...but i", side:SPlayer } );
					l.add( { line:"hey i recognize you, you are the video game superstar", side:SPlayer } );
					l.add( { line:"as you can see i have lotta things to do, those are not mere games but universes.",  side:SOther} );
					l.add( { line:"...",  side:SOther } );
				l;
			},
			proc:function() {},
			ofs:new Vec2(-40, 35),
		});
		
		cine.set('elvis',{
			sprite: "elvis",
			script: {
				var l = new List();
					l.add( { line:"hi", side:SPlayer } );
					l.add( { line:"hey come over here boy what are you doin here alone ", side:SOther } );
					l.add( { line:"i am desperately looking for a ride home", side:SPlayer } );
					l.add( { line:"we're on the go for a party on Uranus. I've heard Uranian girls have 3 boobs ! Do you come with us ?", side:SOther } );
					l.add( { line:"omagad civilization at least ! i am ok but there are crasy people outta", side:SPlayer } );
					l.add( { line:"we don t need those suckers yo moron come on !", side:SOther } );
					l.add( { line:"but they are in need, their minds are ill ", side:SPlayer } );
					l.add( { line:"do they need you ? we need you to party", side:SOther } );
					l.add( { line:"but they are here alone, lost in this asteroid field", side:SPlayer } );
					l.add( { line:"what help do they need exactly, they are in their own world", side:SOther } );
					l.add( { line:"yours is ours, come on... hey ladys , found the perfect fit  !", side:SOther } );
					l.add( { line:"maybe...", side:SOther } );
					l.add( { line:"after all had so much of those parties, so much vomit, so much pain, so much headache...", side:SPlayer } );
					l.add( { line:"...", side:SPlayer } );
					l.add( { line:"...", side:SPlayer } );
					l.add( { line:"ok i am in, anyway.", side:SPlayer } );
					l;
				},
			proc:function() {},
			ofs:new Vec2(-40, 35),
		});
		cines = cine;
	}
	
	public function getFrame(sprite,state) : pix.Frame{
		var spr = sprites.get( sprite );
		var sheet = sheets.get( spr.sheet );
		return sheet.store.get( sprite + "." + state );
	}
	
	public function getFrames(sprite,state) : flash.Vector<pix.Frame>{
		var spr = sprites.get( sprite );
		var sheet = sheets.get( spr.sheet );
		var store = sheet.store;
		var tml = store.timelines.get( sprite + "." + state);
		var v = new flash.Vector(tml.length);
		for ( a in tml )
			v.push( store.get( a ));
		return v;
	}
	
	
	public function getFramesRect(sprite,state) : flash.Vector<flash.geom.Rectangle>{
		var spr = sprites.get( sprite );
		var sheet = sheets.get( spr.sheet );
		var store = sheet.store;
		var tml = store.timelines.get( sprite + "." + state);
		var v = new flash.Vector(tml.length);
		for ( a in tml )
			v.push( store.get( a ).rectangle );
		return v;
	}
	
	
	public function getFramesRectTex(sprite,state) : flash.Vector<starling.textures.Texture>{
		var spr = sprites.get( sprite );
		var sheet = sheets.get( spr.sheet );
		var texSheet = sheet.texSheet;
		
		var tml = sheet.store.timelines.get( sprite + "." + state);
		var v = new flash.Vector(tml.length);
		
		for ( a in 0...tml.length )
			v[a] = starling.textures.Texture.fromTexture( texSheet, sheet.store.get( tml[a] ).rectangle ) ;
			
		return v;
	}
	
	public function fillMc(mc : MovieClip, tml : flash.Vector<starling.textures.Texture>) {
		for ( i in 0...tml.length){
			var f = tml[i];
			mc.addFrameAt( mc.numFrames, f);
		}
		
		while (mc.numFrames > cast tml.length ) mc.removeFrameAt( 0 );
		
		mc.currentFrame = 0;
		mc.readjustSize();
	}
	
	
	public function getFramesRandRectTex(sprite) : flash.Vector<starling.textures.Texture> {
		var spr = sprites.get( sprite);
		var sheet = sheets.get( spr.sheet );
		var store = sheet.store;
		var state = spr.states.random();
		var tml = store.timelines.get( sprite + "." + state.id);
		var v = new flash.Vector(tml.length);
		for ( a in 0...tml.length )
			v[a] = starling.textures.Texture.fromTexture( sheet.texSheet, store.get( tml[a] ).rectangle ) ;
		return v;
	}
	
	
	public function getRandFrame(sprite) : pix.Frame
	{
		var spr = sprites.get( sprite);
		var store = sheets.get( spr.sheet ).store;
		if ( spr == null) throw "No such sprite " + sprite;
		var state = spr.states.random();
		return store.get( sprite + "." + state );
	}
	
	public function mkSprite( el : Element, sprite:String, state:String )
	{
		var s = sprite + "." + state;
		var sp = sprites.get( sprite);
		if ( sp == null) throw "No such sprite "+sprite;
		if ( !sp.states.exists( function(s) return s.id == state )) throw "No such state "+sprite+"."+state;
		el.play( s );
		return el;
	}
	
	public function mkSpriteRandState( el : Element, sprite:String )
	{
		var sp = sprites.get( sprite);
		if ( sp == null) throw "No such sprite " + sprite;
		var st = sp.states.random();
		return mkSprite(el, sprite, st.id );
	}

	public function getMovie(spr,state)
	{
		var vfr = Data.me.getFramesRectTex( spr,state );
		var el : starling.display.MovieClip = new starling.display.MovieClip( vfr,30 );
		el.readjustSize(); 
		el.loop = true;
		el.play();
		Starling.juggler.add( cast el );
		return el;
	}
	
	public function update() {
		if( fxQueue.length > 0 )
			fxQueue = fxQueue.filter( function(m) 
			{
				if ( m.isComplete  ) {
					if ( m.parent != null)
						m.parent.removeChild( m );
					return false;
				}
				else 
					return true;
			});
	}
	
	
	public function playFx(fx)
	{
		var m = getMovie( "fx",fx );
		m.loop = false;
		fxQueue.push( m );
		return m;
	}
}