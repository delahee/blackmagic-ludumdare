package ods;

class Encoder {

	public static function encode( file : String, data : haxe.io.Bytes ) {
		return data;
	}

	public static function decode( data : haxe.io.Bytes ) : String {
		return #if neko neko.Lib.stringReference(data) #else data.toString() #end;
	}


}
