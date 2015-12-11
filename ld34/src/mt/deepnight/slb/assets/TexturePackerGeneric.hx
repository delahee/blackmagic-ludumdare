package mt.deepnight.slb.assets;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;

#else

import mt.deepnight.slb.BLib;

#end

//TODO re-add trimming suppor tif need be
private typedef Slice = {
	var name	: String;
	var frame	: Int;
	var x		: Int;
	var y		: Int;
	var wid		: Int;
	var hei		: Int;
	@:optionnal var pX:Float;
	@:optionnal var pY:Float;
}


class TexturePackerGeneric {
	public static var SLICES : Array<Slice> = new Array();

	public static macro function importXml(xmlUrl:String, ?treatFoldersAsPrefixes:Bool=false) {
		var p = Context.currentPos();

		xmlUrl = StringTools.replace(xmlUrl, "\\", "/");
		var path = xmlUrl.indexOf("/")>=0 ? xmlUrl.substr(0, xmlUrl.lastIndexOf("/")) : "";
		var id = AssetTools.cleanUpString(xmlUrl);

		// XML parsing
		var file = try Context.resolvePath(xmlUrl) catch( e : Dynamic ) { AssetTools.error("File not found : "+xmlUrl, p); null; }
		var xml = new haxe.xml.Fast( Xml.parse(sys.io.File.getContent(file)) );
		Context.addResource("_XML_"+id, sys.io.File.getBytes(file));

		// Bitmap source declaration
		var sourceName = xml.node.TextureAtlas.att.imagePath;
		var sourceUrl = path+"/"+sourceName;
		try Context.resolvePath(sourceUrl) catch( e : Dynamic ) { AssetTools.error("Image "+sourceName+" not found", p); null; }
		var sourceType = {
			pos : p,
			pack : [],
			name : "_BITMAP_"+id,
			meta : [{ name : ":bitmap", pos : p, params : [{ expr : EConst(CString(sourceUrl)), pos : p }] }],
			params : [],
			isExtern : false,
			fields : [],
			kind : TDClass({ pack : ["flash","display"], name : "BitmapData", params : [] }),
		};
		if( !AssetTools.typeExists("_BITMAP_"+id) ) {
			Context.defineType(sourceType);
		}

		var zeroExpr = { expr:EConst(CInt("0")), pos:p }
		var newSourceExpr = { expr : ENew({pack:sourceType.pack, name:sourceType.name, params:[]}, [zeroExpr,zeroExpr]), pos:p }


		// New lib declaration
		var blockContent : Array<Expr> = [];
		var folderFlagExpr = Context.makeExpr(treatFoldersAsPrefixes, p);
		var rscIdExper = Context.makeExpr("_XML_"+id, p);
		var rscGetter = macro haxe.Resource.getString($rscIdExper);
		blockContent.push( macro var _lib = mt.deepnight.slb.assets.TexturePackerGeneric.parseXml($rscGetter, $newSourceExpr, $folderFlagExpr) );
		blockContent.push( macro _lib.initBdGroups() );
		blockContent.push( macro _lib );

		return { pos:p, expr:EBlock(blockContent) }
	}


	#if !macro

	static inline function makeChecksum(slice:Slice) : String {
		return slice.name+","+slice.x+","+slice.y+","+slice.wid+","+slice.hei+","+slice.pX+","+slice.pY;
	}

	public static function parseXml(xmlString:String, source:flash.display.BitmapData, treatFoldersAsPrefixes:Bool) : BLib {
		var lib = new BLib(source);
		var xml = new haxe.xml.Fast( Xml.parse(xmlString) );
		var removeExt = ~/\.(png|gif|jpeg|jpg)/gi;
		var leadNumber = ~/([0-9]*)$/;
		try {
			// Parse frames
			var slices : Map<String, Int> = new Map();
			var anims : Map<String, Array<Int>> = new Map();
			for(atlas in xml.nodes.TextureAtlas) {
				var last : Slice = null;
				var frame = 0;
				for(sub in atlas.nodes.sprite) {
					// Read XML
					var slice : Slice = {
						name	: sub.att.n,
						frame	: 0,
						x		: Std.parseInt(sub.att.x),
						y		: Std.parseInt(sub.att.y),
						wid		: Std.parseInt(sub.att.w),
						hei		: Std.parseInt(sub.att.h),
						
						pX		: sub.has.pX ? Std.parseFloat(sub.att.pX):0.0,
						pY		: sub.has.pY ? Std.parseFloat(sub.att.pY):0.0,
					}

					// Clean-up name
					slice.name = removeExt.replace(slice.name, "");
					if( slice.name.indexOf("/")>=0 )
						if( treatFoldersAsPrefixes )
							slice.name = StringTools.replace(slice.name, "/", "_");
						else
							slice.name = slice.name.substr(slice.name.lastIndexOf("/")+1);

					// Remove leading numbers and "_"
					if( leadNumber.match(slice.name) ) {
						slice.name = slice.name.substr(0, leadNumber.matchedPos().pos);
						while( slice.name.length>0 && slice.name.charAt(slice.name.length-1)=="_" ) // trim leading "_"
							slice.name = slice.name.substr(0, slice.name.length-1);
					}

					// New serie
					if( last==null || last.name!=slice.name)
						frame = 0;

					var csum = makeChecksum(slice);
					if( !slices.exists(csum) ) {
						// Not an existing slice
						slices.set(csum, frame);
						slice.frame = frame;
						lib.sliceCustom(slice.name, slice.frame, slice.x, slice.y, slice.wid, slice.hei,slice.pX,slice.pY);
						frame++;
					}

					var realFrame = slices.get(csum);
					if( !anims.exists(slice.name) )
						anims.set(slice.name, [realFrame]);
					else
						anims.get(slice.name).push(realFrame);

					SLICES.push(slice);
					last = slice;
				}
			}

			// Define anims
			for(k in anims.keys())
				lib.__defineAnim(k, anims.get(k));

		}
		catch(e:Dynamic) {
			throw SLBError.AssetImportFailed(e);
		}
		return lib;
	}
	#end


	#if !macro
	public static function downloadXml(xmlUrl:String, imgUrl:String, treatFoldersAsPrefixes:Bool, onComplete:BLib->Void) {
		var xml : String = null;
		var bd : flash.display.BitmapData = null;
		var steps = 0;

		function onError(msg, url) {
			throw SLBError.AssetImportFailed("TexturePacker download failed:"+msg+" "+url);
		}

		function onOneDone() {
			steps++;
			if( steps>=2 ) {
				var lib = parseXml(xml, bd, treatFoldersAsPrefixes);
				onComplete(lib);
			}
		}

		// Load XML
		var r = new haxe.Http(xmlUrl);
		r.onError = function(msg) {
			onError(msg, xmlUrl);
		};
		r.onData = function(data) {
			xml = data;
			onOneDone();
		}
		r.request(true);

		// Load bitmap
		var l = new flash.display.Loader();
		#if flash
		l.contentLoaderInfo.addEventListener( flash.events.IOErrorEvent.NETWORK_ERROR, function(e) onError(e.text, imgUrl) );
		#end
		l.contentLoaderInfo.addEventListener( flash.events.IOErrorEvent.IO_ERROR, function(e) onError(e.text, imgUrl) );
		l.contentLoaderInfo.addEventListener( flash.events.Event.COMPLETE, function(_) {
			var bmp : flash.display.Bitmap = cast( l.contentLoaderInfo.content );
			bd = bmp.bitmapData;
			onOneDone();
		});
		var ctx = new flash.system.LoaderContext(true);
		var r = new flash.net.URLRequest(imgUrl);
		l.load(r, ctx);
	}
	#end
}