import 	flash.Lib;
import 	flash.display.BitmapData;
import flash.utils.Namespace;

import 	haxe.xml.Fast;

import 	mt.pix.Element;
import 	mt.pix.Store;

import  starling.textures.Texture;

using Lambda;
using volute.com.LbdEx;
using volute.com.ArrEx;

import starling.textures.Texture;


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
	store:mt.pix.Store, 
	texSheet:Texture,
}

@:bitmap("../gfx/png/test.png")
class TestSheet extends flash.display.BitmapData
{
	
}


@:file("../gfx/data.xml")
class SheetXml extends flash.utils.ByteArray
{
	
}

/*
@:font('../../com/gfx/nokiafc22.ttf')
class Nokia extends flash.text.Font
{
	
}
*/

class Data implements haxe.Public
{
	var xml : haxe.xml.Fast;

	var sprites : Hash<XMLSprite>;
	var sheets : Hash<{name:String, sheet:BitmapData, texSheet: starling.textures.Texture,store:Store}>;
	var texRegion  : flash.geom.Rectangle;
	
	public static var me = null;
	public function new(){
		me = this;
		var str = new SheetXml().toString();
		xml =  new haxe.xml.Fast( haxe.xml.Parser.parse( str ));

		sprites = new Hash();
		sheets = new Hash();
		
		var ls : BitmapData = null;
		var lsheets = [{ 
			name:"test", 
			sheet:ls=new TestSheet(0, 0, false), 
			store:new mt.pix.Store( ls ), 
			texSheet:Texture.fromBitmapData( ls, true, false, 1) 
		}];
		
		for ( s in lsheets ) {
			sheets.set( s.name, s );
			trace('gen sheet ' + s.name + "<>" + s);
		}
		
		for( ts in xml.nodes.tileDef){
			for ( spr in ts.nodes.sprite ){
				var sprId;
				var file = ts.att.file;
				var sheet = sheets.get(file);
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
	}
	
	public function getFrame(sprite,state) : mt.pix.Frame{
		var spr = sprites.get( sprite );
		var sheet = sheets.get( spr.sheet );
		return sheet.store.get( sprite + "." + state );
	}
	
	public function getFrames(sprite,state) : flash.Vector<mt.pix.Frame>{
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
	
	
	public function getRandFrame(sprite) : mt.pix.Frame
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

}