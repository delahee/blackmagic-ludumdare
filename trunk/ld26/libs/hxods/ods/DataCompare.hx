package ods;
import ods.Ods;

class DataCompare {

	public static function compare( fr : String, int : String, configFile : String ) {
		var ofr = new OdsChecker();
		ofr.loadODS(neko.io.File.read(fr));
		var oint = new OdsChecker();
		oint.loadODS(neko.io.File.read(int));

		var config = new Hash();
		for( l in neko.io.File.getContent(configFile).split("\n") ) {
			var l = StringTools.trim(l);
			if( l == "" || l.charAt(0) == "#" ) continue;
			config.set(l, true);
		}

		var line = 0;
		var sheet = "";

		function error(msg) {
			neko.Lib.println(int + ":"+line+": in '"+sheet+"' "+ msg+"\n");
		}

		for( s in oint.getSheets() ) {
			if( config.exists("sheet."+s) ) continue;
			line = 1;
			sheet = s;
			if( !ofr.hasSheet(s) ) {
				error("sheet not found in original file");
				continue;
			}
			var lfr = ofr.getLines(s);
			var lint = oint.getLines(s);
			var col = -1;

			var cols = [];
			var colFR = lfr.next();


			for( v in lint.next() ) {
				col++;
				var v = StringTools.trim(v);
				if( v == "" ) continue;
				var c = Lambda.indexOf(colFR, v);
				if( c < 0 ) error("column '" + v + "' not found in original file");
				cols.push( {
					name : v,
					skip : config.exists(s + "." + v),
					int : col,
					fr : c,
				});
			}

			// don't compare sheets that have no columns
			if( cols.length == 0 )
				continue;

			var fline = 1;

			while( true ) {
				var i;
				var skip = 0;
				do {
					line++;
					skip++;
					i = lint.next();
				} while( StringTools.trim(i.join("")) == "" && skip < 20 );
				if( skip >= 20 ) {
					line -= skip - 1;
					error("Missing $EOF");
					break;
				}
				var f;
				do {
					fline++;
					f = lfr.next();
				} while( StringTools.trim(f.join("")) == "" );
				if( i[0] == "$EOF" && f[0] == "$EOF" )
					break;
				if( i[0] == "$EOF" ) {
					error("missing data");
					break;
				}
				if( f[0] == "$EOF" ) {
					error("extra data");
					break;
				}
				var count = 0;
				for( c in cols ) {
					var iv = i[c.int];
					var fv = f[c.fr];
					if( iv == fv ) continue;
					if( c.skip && (iv == "") == (fv == "") ) continue;
					error("column "+c.name+" '"+iv+"'");
					neko.Lib.println(fr + ":" + fline + ": | should be              '" + fv+"'");
					count++;
					if( count >= 10 ) break;
				}
			}


		}
	}

}