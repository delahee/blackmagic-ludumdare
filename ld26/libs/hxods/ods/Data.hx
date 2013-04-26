package ods;

#if macro
#if haxe_211
import haxe.macro.Type;
import haxe.macro.Expr;
#else
import haxe.macro.Expr;
import haxe.macro.Type;
#end
import haxe.macro.Context;
import ods.Ods;
#end

typedef OdsID = String;
typedef OdsEncoded = Int;
typedef OdsCheck = Bool;
typedef OdsSkip<T> = T;
typedef OdsConstraint<Const,Const,Const> = String;

class Data {

	static var ENCODER = #if mt MTEncoder #else Encoder #end;

	#if macro

	static var __ = OdsChecker;
	static var regid = ~/^[A-Za-z_][_A-Za-z0-9]*$/;
	static var enums : Array<{ path : String, rule : Rule }>;
	static var current : OdsChecker;
	static var subField : Null<String>;

	static function getType( e : Expr ) {
		return switch( e.expr ) {
		case EConst(c):
			switch( c ) {
			case CIdent(t) #if !haxe3 , CType(t) #end: t;
			default: Context.error("Invalid type", e.pos);
			}
		case EField(e, f) #if !haxe3 , EType(e, f) #end:
			getType(e) + "." + f;
		default:
			Context.error("Invalid type", e.pos);
		};
	}

	static function getString( e : Expr ) {
		return switch( e.expr ) {
		case EConst(c):
			switch( c ) {
			case CString(s): s;
			default: Context.error("Constant string required", e.pos);
			}
		default:
			Context.error("Constant string required", e.pos);
		};
	}

	#if (spadm || mt)
	static function parseEncoded( s : String ) {
		return try spadm.Id.encode(s) catch( e : Dynamic ) null;
	}
	#end

	static function extractArgs( str : String  ) : Array<String> {
		var start = 0;
		var pos = start;
		var args = [];
		while( true ) {
			var c = StringTools.fastCodeAt(str,pos);
			if( StringTools.isEOF(c) ) break;
			pos++;
			if( c == '('.code ) {
				// skip content until matching closing parenthesis
				var count = 1;
				while( true ) {
					c = StringTools.fastCodeAt(str,pos);
					if( StringTools.isEOF(c) ) break;
					pos++;
					if( c == ')'.code ) {
						count--;
						if( count == 0 ) break;
					} else if( c == '('.code )
						count++;
				}
			} else if( c == '['.code ) {
				// skip content until matching closing array
				var count = 1;
				while( true ) {
					c = StringTools.fastCodeAt(str,pos);
					if( StringTools.isEOF(c) ) break;
					pos++;
					if( c == ']'.code ) {
						count--;
						if( count == 0 ) break;
					} else if( c == '['.code )
						count++;
				}
			} else if( c == ','.code ) {
				args.push(str.substr(start,pos - start - 1));
				start = pos;
			}
		}
		args.push(str.substr(start,pos - start));
		return args;
	}

	static function parseEnum( names : Array<String>, values : Array<Dynamic>, rules : Array<Array<Column>>, v : String ) : Dynamic {
		var cst = v.split("(")[0];
		for( i in 0...names.length )
			if( cst == names[i] ) {
				var r = rules[i];
				if( r == null )
					return values[i];
				if( v.charCodeAt(v.length - 1) != ")".code )
					throw CustomMessage("unclosed parenthesis");
				var args = extractArgs(v.substr(cst.length + 1, v.length - (cst.length + 2)));
				if( args.length < r.length ) {
					var minArgs = 0;
					var opt = false;
					for( v in r )
						switch( v ) {
						case Opt(_): opt = true;
						default:
							if( opt ) throw CustomMessage("in " + cst + " you can't have required enum parameters after optional ones");
							minArgs++;
						}
					if( args.length < minArgs )
						throw CustomMessage("constructor '" + cst + "' requires " + minArgs+"-"+r.length + " parameters, " + args.length + " encountered");
				} else if( args.length > r.length )
					throw CustomMessage("constructor '" + cst + "' requires " + r.length + " parameters, " + args.length + " encountered");

				var e = Reflect.copy(values[i]);
				e.args = neko.NativeArray.alloc(r.length);
				for( i in 0...args.length ) {
					var a = StringTools.trim(args[i]);
					var r = switch( r[i] ) {
					case Opt(r): r;
					default: r[i];
					}
					var r = switch( r ) {
					case A(_, r): r;
					default: throw "assert";
					}
					switch( r ) {
					case RArray(sep, rsub):
						if( a.charCodeAt(0) == '['.code && a.charCodeAt(a.length - 1) == ']'.code ) {
							a = a.substr(1, a.length - 2);
							r = RArray(',', rsub);
						}
					default:
					}
					var v = current.checkRule(r, a);
					if( v == null )
						throw CustomMessage("'"+a+"' argument should be " + current.ruleString(r));
					e.args[i] = v;
				}
				return e;
			}
		throw CustomMessage("unknown constructor " + cst);
		return null;
	}

	static function parseEnumClosure(names, values, rules) {
		// for typing only
		if( false )
			return callback(parseEnum, names, values, rules);
		// this will ensure that the parameters are part of the signature
		return untyped __dollar__closure(parseEnum, null, names, values, rules);
	}

	static function getMetaString( meta : MetaAccess, key : String, ?def : String ) {
		if( !meta.has(key) )
			return def;
		for( m in meta.get() )
			if( m.name == key ) {
				if( m.params.length != 1 ) throw "Invalid parameters for @" + key;
				switch( m.params[0].expr ) {
				case EConst(c):
					switch( c ) {
					case CString(s):
						return s;
					default:
					}
				default:
				}
				throw "Invalid parameters for @" + key;
			}
		return def;
	}

	static function getKind( f : { name : String, meta : MetaAccess, pos : Position }, t : Type ) {
		function opt(r) {
			return switch(r) {
			case Opt(_): r;
			default: Opt(r);
			}
		}
		switch( t ) {
		case TInst(t, params):
			return A(f.name,switch( t.toString() ) {
			case "Int": RInt;
			case "Float": RFloat;
			case "String": RText;
			case "Array":
				var r = getKind(f, params[0]);
				switch(r) {
				case A(_, r): RArray(getMetaString(f.meta,":sep",","), r);
				default: throw "Unsupported " + Std.string(t);
				}
			default: throw "Unsupported " + Std.string(t);
			});
		case TAbstract(t, params):
			return A(f.name,switch( t.toString() ) {
			case "Int": RInt;
			case "Float": RFloat;
			case "Bool":
				return A(f.name, RMap(["true","1","T","false","0","F"],[true,true,true,false,false,false]));
			default: throw "Unsupported " + Std.string(t);
			});
		case TType(tt, params):
			return switch( tt.toString() ) {
			case "Null": opt(getKind(f, params[0]));
			case "ods.OdsID": A(f.name, RReg(regid));
			#if (spadm || mt)
			case "ods.OdsEncoded": A(f.name, RCustom("encoded id",parseEncoded));
			#end
			case "ods.OdsCheck": opt(A(f.name, RMap(["x", "X", "o", "O"], [true, true, true, true])));
			case "ods.OdsConstraint":
				var sparams = [];
				for( p in params )
					switch( p ) {
					case TInst(c, _):
						sparams.push(c.toString().substr(1));
					default: throw "assert";
					}
				var ids = getModsColumn(f.pos,sparams[0], sparams[1], sparams[2]);
				A(f.name, RValues(ids));
			case "ods.OdsSkip": null;
			default: getKind({ name : f.name, meta : f.meta, pos : tt.get().pos }, Context.follow(t,true));
			}
		case TEnum(t, params):
			var path = t.toString();
			if( path == "Bool" )
				return A(f.name, RMap(["true","1","T","false","0","F"],[true,true,true,false,false,false]));
			var t = t.get();
			for( e in enums )
				if( e.path == path )
					return A(f.name, RCustom(path,function(v) return current.checkRule(e.rule, v)));
			var pos = enums.length;
			var inf = { path : path, rule : null };
			enums.push(inf);
			var names = [], values = [], rules = null;
			var fakeEnum = { __enum__ : { __ename__ : ["$" + pos] }, index : 0 };
			var prefix = t.names[0];
			for( n in t.names ) {
				var e = Reflect.copy(fakeEnum);
				var c = t.constructs.get(n);
				if( c.meta.has(":skip") ) {
					names.push(n+"___skipped");
					e.index = c.index;
					values.push(e);
					continue;
				}
				switch( c.type ) {
				case TFun(fargs,_):
					if( rules == null ) rules = [];
					var args = [];
					for( t in fargs ) {
						var k = getKind({ pos : c.pos, name : f.name + "." + t.name, meta : f.meta }, t.t);
						if( k == null ) continue;
						if( t.opt ) k = opt(k);
						args.push(k);
					}
					rules[names.length] = args;
				default:
				}
				e.index = c.index;
				names.push(n);
				values.push(e);
				if( c.meta.has(":alias") ) {
					for( m in c.meta.get() )
						if( m.name == ":alias" )
							for( p in m.params )
								switch( p.expr ) {
								case EConst(c):
									switch( c ) {
									case CString(s):
										if( rules != null )
											rules.push(rules[names.length-1]);
										names.push(s);
										values.push(e);
									default:
									}
								default:
								}
				}
				while( prefix.length > 0 && !StringTools.startsWith(n, prefix) )
					prefix = prefix.substr(0, prefix.length - 1);
			}
			if( prefix != null && prefix.length > 0 && names.length > 1 )
				for( i in 0...names.length )
					if( values[i] != values[i-1] ) // only remove prefix for not-aliased named
						names[i] = names[i].substr(prefix.length);
			if( rules == null )
				inf.rule = RMap(names, values);
			else
				inf.rule = RCustom(path,parseEnumClosure(names, values, rules));
			return A(f.name, inf.rule);
		case TAnonymous(a):
			throw "Unsupported {"+Lambda.map(a.get().fields,function(f) return f.name).join(",")+"}";
		default:
			throw "Unsupported " + Std.string(t);
		}
	}

	static function getFields( t : Type, sub : Bool ) {
		switch( t ) {
		case TType(_):
			return getFields(Context.follow(t), sub);
		case TAnonymous(a):
			var fields = a.get().fields;
			var a = new Array();
			for( f in fields ) {
				var k;
				try {
					k = getKind({ name : f.name, meta : f.meta, pos : f.pos }, f.type);
				} catch( e : Dynamic ) {
					if( !sub ) {
						switch( Context.follow(f.type) ) {
						case TInst(c, p):
							if( c.toString() == "Array" && switch(Context.follow(p[0])) { case TAnonymous(_): true; default: false; } ) {
								a = a.concat(getFields(p[0], true));
								subField = f.name;
								continue;
							}
						default:
						}
					}
					throw Std.string(e) + " for field '" + f.name + "'";
				}
				if( k == null ) continue;
				a.push({ name : f.name, sub : sub, kind : k });
			}
			return a;
		default:
			throw "Unsupported " + Std.string(t);
		}
	}

	static function getModsColumn( pos : Position, file : String, sheet : String, column : String ) {
		var esheet = { expr : EConst(CString(sheet)), pos : pos };
		var ecolumn = { expr : EConst(CString(column)), pos : pos };
		var efilter = null;
		var bytes = getODSCache(file, pos, "_enum." + sheet + "_" + column, sheet + Context.signature(efilter), callback(extractColumns, esheet, ecolumn, efilter, regid) );
		return bytes.toString().split("@");
	}

	static function parseRules( rules : Array<{ name : String, kind : Column, sub : Bool }>, rsubField : String, file : String, esheet : Expr, o : OdsChecker ) {
		var sheet = getString(esheet);
		if( !o.hasSheet(sheet) )
			Context.error("Sheet not found", esheet.pos);
		var head = o.getLines(sheet).next();
		var cols = [], scols = [];
		while( true ) {
			var k = head.pop();
			if( k != "" ) {
				head.push(k);
				break;
			}
		}
		var trules = rules.copy();
		var skip = R(RSkip);
		for( id in head ) {
			var found = false;
			var sfound = false;
			var parts = id.split("/");
			var id = parts[0];
			var sid = parts.pop();
			for( r in rules )
				if( r.name == (r.sub ? sid : id) ) {
					if( r.sub ) {
						sfound = true;
						scols.push(r.kind);
					}
					else {
						found = true;
						cols.push(r.kind);
					}
					if( !trules.remove(r) ) {
						var k = switch( r.kind ) {
						case Opt(r): r;
						default: r.kind;
						};
						switch( k ) {
						case A(_,r):
							switch( r ) {
							case RArray(_):
							default:
								Context.error("Duplicate column '" + id + "'", esheet.pos);
							}
						default:
						}
					}
				}
			if( !found ) cols.push(sfound ? R(RBlank) : skip);
			if( !sfound ) scols.push(skip);
		}
		if( trules.length > 0 )
			Context.error("Column '" + trules[0].name + "' not found", esheet.pos);
		cols.push(All(R(RSkip)));
		var line = if( rsubField == null )
			DLine( { name : "object", cols : cols } )
		else
			DGroup( { name : "object", cols : cols } , DMany(DLine( { name : rsubField, cols : scols } )) );
		var eof = DLine( { name : null, cols : [R(RValues(["$EOF"])), All(R(RSkip))] } );
		var doc = DList([
			DLine( { name : null, cols : [All(R(RSkip))] } ),
			DWhileNot(
				eof,
				DChoice([
					line,
					DLine( { name : null, cols : [All(R(RBlank))] }),
				])
			),
		]);
		current = o;
		var ol : Array<Dynamic> = try o.check(sheet, doc).o.object catch( e : Dynamic ) Context.error(Std.string(e), esheet.pos);
		current = null;
		var fields = new Array<Dynamic>();
		for( o in ol ) {
			for( r in rules )
				if( !r.sub )
					fields.push(Reflect.field(o, r.name));
			if( rsubField != null )
				fields.push(Reflect.field(o, rsubField));
		}
		var s = new haxe.Serializer();
		s.useEnumIndex = true;
		s.serialize(fields);
		return ENCODER.encode(file,neko.Lib.bytesReference(s.toString()));
	}

	static var cachedODS = new Hash();
	static function loadODS( file : String ) {
		var o = cachedODS.get(file);
		if( o == null ) {
			var f = sys.io.File.read(file, true);
			o = new OdsChecker();
			o.loadODS(f);
			f.close();
			cachedODS.set(file, o);
		}
		return o;
	}

	static var cachedDB = new Hash<{ file : String, h : Hash<{ sign : String, bytes : haxe.io.Bytes }> }>();
	static function getODSCache( fileName : String, pos : Position, type : String, sign : String, buildData ) {
		var db = cachedDB.get(fileName);
		var file = try Context.resolvePath(fileName) catch( e : Dynamic ) Context.error("File not found", pos);

		var m = switch( Context.getLocalType() ) {
		case TInst(c, _): c.get().module;
		case TEnum(e, _): e.get().module;
		case TType(t, _): t.get().module;
		default: null;
		}
		Context.registerModuleDependency(m, file);

		if( db == null ) {
			var path = file.split(".");
			if( path.length > 1 )
				path.pop();
			var cache = path.join(".") + ".cache";
			if( sys.FileSystem.exists(cache) && sys.FileSystem.stat(cache).mtime.getTime() > sys.FileSystem.stat(file).mtime.getTime() )
				db = { file : cache, h : haxe.Unserializer.run(sys.io.File.getContent(cache)) };
			else
				db = { file : cache, h : new Hash() };
			cachedDB.set(fileName, db);
		}
		var data = db.h.get(type);
		if( data != null && data.sign == sign && data.bytes != null )
			return data.bytes;
		var t = haxe.Timer.stamp();
		var bytes = buildData(loadODS(file));
		db.h.set(type, { sign : sign, bytes : bytes } );
		var f = sys.io.File.write(db.file, true);
		f.writeString(haxe.Serializer.run(db.h));
		f.close();
		#if !mods_silent
		trace("Rebuilt " + type + " from '" + fileName + "' in " + Std.int((haxe.Timer.stamp() - t) * 100) / 100 + "s");
		#end
		return bytes;
	}

	static function extractColumns( esheet : Expr, ecolumn : Expr, efilter : Expr, reg : EReg, o : OdsChecker ) {
		var sheet = getString(esheet);
		var column = getString(ecolumn);
		if( !o.hasSheet(sheet) )
			Context.error("Sheet not found",  esheet.pos);
		var filtColumn = null;
		var filtValue = null;
		var prefix = "";
		if( efilter != null ) {
			switch( efilter.expr ) {
			case EObjectDecl(fields):
				for( f in fields )
					switch( f.field ) {
					case "prefix":
						prefix = getString(f.expr);
					default:
						if( filtColumn != null )
							Context.error("Not supported", efilter.pos);
						filtColumn = f.field;
						filtValue = getString(f.expr);
					}
			default:
				Context.error("Not supported", efilter.pos);
			}
		}
		var lines = o.getLines(sheet);
		var head = lines.next();
		var icol = 0;
		for( i in head ) {
			if( i == column )
				break;
			icol++;
		}
		if( icol == head.length )
			Context.error("Column '"+column+"' not found", ecolumn.pos);
		var ifilter = 0;
		if( filtColumn != null ) {
			for( i in head ) {
				if( i == filtColumn )
					break;
				ifilter++;
			}
			if( ifilter == head.length )
				Context.error("Column '"+filtColumn+"' not found", efilter.pos);
		}
		var line = 2;
		var ids = [];
		var skip = 0;
		while( lines.hasNext() ) {
			var l = lines.next();
			if( l[0] == "$EOF" ) {
				skip = -1;
				break;
			}
			if( filtColumn != null && l[ifilter] != filtValue )
				continue;
			var id = l[icol];
			if( !reg.match(id) ) {
				if( StringTools.trim(l.join("")) == "" ) {
					line++;
					skip++;
					if( skip >= 20 ) break;
					continue;
				}
				Context.error("Invalid ID ("+id+") at " + o.columnName(icol) + line, Context.currentPos());
			}
			ids.push(prefix + id.split('@').join('$$'));
			line++;
			skip = 0;
		}
		if( skip >= 0 )
			Context.error("Missing $EOF", Context.currentPos());
		return haxe.io.Bytes.ofString(ids.join("@"));
	}

	#end

	@:macro public static function parse( efile : Expr, sheet : Expr, t : Expr ) {
		var pos = Context.currentPos();
		var mk = function(e) return { expr : e, pos : pos };
		var file = getString(efile);
		var type = getType(t);
		enums = [];
		subField = null;
		var tinf = try Context.getType(type) catch( e : Dynamic ) Context.error("Type not found", t.pos);
		var rules = try getFields(tinf,false) catch( e : Dynamic ) Context.error(Std.string(e), t.pos);
		var signature = Context.signature(rules) + getString(sheet) + subField;
		var bytes = getODSCache(file, efile.pos, type, signature, callback(parseRules,rules,subField,file,sheet) );
		var isNeko = Context.defined("neko");
		var res = isNeko ? type : #if haxe3 haxe.crypto.Md5.encode #else haxe.Md5.encode #end(file + "@" + type);
		if( !isNeko )
			Context.addResource(res,bytes);
		var e = mk(EConst(CString(res)));
		var names = [];
		for( r in rules )
			if( !r.sub )
				names.push(mk(ECall(mk(EConst(CIdent("__unprotect__"))), [mk(EConst(CString(r.name)))])));
		if( subField != null )
			names.push(mk(ECall(mk(EConst(CIdent("__unprotect__"))), [mk(EConst(CString(subField)))])));
		var enums = [];
		for( e in Data.enums )
			enums.push(Context.parse(e.path, pos));
		var args =  [e, mk(EArrayDecl(names)), mk(EArrayDecl(enums))];
		if( isNeko ) {
			var get = mk(EConst(CIdent("getCacheFile")));
			args.push(mk(ECall(mk(EConst(CIdent("callback"))),[get,mk(EConst(CString(file.split(".ods").join(".cache"))))])));
		}
		e = mk(ECall(mk(EField(mk(#if haxe3 EField #else EType #end(mk(EConst(CIdent("ods"))),"Data")),"extract")), args));
		var pack = type.split(".");
		var ct = TPath( { pack : pack, name : pack.pop(), params : [], sub : null } );
		ct = TPath( { pack : [], name : "Array", params : [TPType(ct)], sub : null } );
		return mk(EBlock([
			mk(EVars([{ name : "tmp", type : ct, expr : e }])),
			mk(EConst(CIdent("tmp"))),
		]));
	}

	@:macro public static function build( params : Array<Expr> ) : Array<Field> {
		var pos = Context.currentPos();
		if( params.length < 3 )
			Context.error("Required parameters (file,sheet,column,?filter)", pos);
		var efile = params[0];
		var esheet = params[1];
		var ecolumn = params[2];
		var efilter = params[3];
		var file = getString(efile);
		var column = getString(ecolumn);
		var sheet = getString(esheet);
		var bytes = getODSCache(file, efile.pos, "_enum." + sheet+"_"+column, sheet + Context.signature(efilter), callback(extractColumns, esheet, ecolumn, efilter, regid) );
		var constructs = [];
		for( id in bytes.toString().split("@") ) {
			if( id == "_" ) continue;
			constructs.push( { name : id, pos : pos, access : [], doc : null, meta : [], kind : FVar(null,null) } );
		}
		return constructs.concat(Context.getBuildFields());
	}

	@:macro public static function buildComplex( params : Array<Expr> ) : Array<Field> {
		var pos = Context.currentPos();
		if( params.length < 3 )
			Context.error("Required parameters (file,sheet,column,?filter)", pos);
		var efile = params[0];
		var esheet = params[1];
		var ecolumn = params[2];
		var efilter = params[3];
		var file = getString(efile);
		var column = getString(ecolumn);
		var sheet = getString(esheet);
		var bytes = getODSCache(file, efile.pos, "_enum." + sheet+"_"+column, sheet + Context.signature(efilter), callback(extractColumns, esheet, ecolumn, efilter, ~/^[A-Za-z_]/) );
		var constructs = [];
		for( id in bytes.toString().split("@") ) {
			if( id == "_" ) continue;
			if( regid.match(id) ) {
				constructs.push( { name : id, pos : pos, access : [], doc : null, meta : [], kind : FVar(null,null) } );
				continue;
			}
			var metas = [];
			var rmeta = ~/ \$\$(:?[A-Za-z_][A-Za-z_0-9]*)$/;
			while( rmeta.match(id) ) {
				metas.push( { name : rmeta.matched(1), pos : pos, params : [] } );
				id = rmeta.matchedLeft();
			}
			var e;
			try {
				e = Context.parse("function "+id+"{}",pos);
			} catch( e : Dynamic ) {
				Context.error("Invalid ID '"+id+"'",pos);
			}
			switch( e.expr ) {
			case EFunction(name,f):
				f.expr = null;
				constructs.push({ name : name, pos : pos, access :[], doc : null, meta : metas, kind : FFun(f) });
			default:
				Context.error("Invalid ID '"+id+"'",pos);
			}
		}
		return constructs.concat(Context.getBuildFields());
	}

	#if neko
	static var CACHED = null;
	#end

	public static function extract<T>( data : String, names : Array<String>, enums : Array<Dynamic> #if neko, getCacheFile : Void -> String #end ) : Array<T> {
		#if neko
		var file = getCacheFile();
		if( CACHED == null ) CACHED = new Hash();
		var cache : Hash<{ bytes : haxe.io.Bytes }> = CACHED.get(file);
		if( cache == null ) {
			cache = haxe.Unserializer.run(sys.io.File.getContent(file));
			CACHED.set(file, cache);
		}
		var cinf = cache.get(data);
		if( cinf == null )
			throw file + " is missing " + data;
		var data = cinf.bytes;
		#else
		var data = haxe.Resource.getBytes(data);
		#end
		var data = ENCODER.decode(data);
		var uns = new haxe.Unserializer(data);
		uns.setResolver({
			resolveClass : function(_) return null,
			resolveEnum : function(n:String) {
				return enums[Std.parseInt(n.substr(1))];
			},
		});
		var fields : Array<Dynamic> = uns.unserialize();
		var objs = new Array<T>();
		var count = names.length;
		var pos = 0;
		while( pos < fields.length ) {
			var o : T = cast { };
			for( i in 0...count )
				Reflect.setField(o, names[i], fields[pos++]);
			objs.push(o);
		}
		return objs;
	}

}