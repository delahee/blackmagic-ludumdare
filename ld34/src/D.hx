
import mt.deepnight.slb.BLib;
import mt.deepnight.slb.HSprite;

import com.newgonzo.midi.MIDIDecoder;
import com.newgonzo.midi.file.*;
import com.newgonzo.midi.events.MessageEvent;

typedef TE = com.newgonzo.midi.file.MIDITrackEvent;
class D {
	public static var me : D = null;
	
	public var char : mt.deepnight.slb.BLib;
	public var decor : mt.deepnight.slb.BLib;
	public var wendyBig : h2d.Font;
	public var wendySmall : h2d.Font;
	public var wendyUber : h2d.Font;
	public var arial : h2d.Font;
	
	public var midiFile : MIDIFile;
	public var midiFile2 : MIDIFile;
	
	public static var sfx = mt.flash.Sfx.importDirectory("assets/snd/SFX");
	public static var music = mt.flash.Sfx.importDirectory("assets/snd/music");
	
	
	public function new() {
		char = mt.deepnight.slb.assets.TexturePacker.importXml("assets/assets.xml",true);
		char.texture.filter = Nearest;
		
		var fnt = openfl.Assets.getFont( "assets/wendy_0.ttf" );
		wendyBig = hxd.res.FontBuilder.getFont(fnt.fontName, 40);
		wendyBig.tile.getTexture().filter = Nearest;
		
		wendyUber = hxd.res.FontBuilder.getFont(fnt.fontName, 80);
		wendyUber.tile.getTexture().filter = Nearest;
		
		wendySmall = hxd.res.FontBuilder.getFont(fnt.fontName, 20);
		wendySmall.tile.getTexture().filter = Nearest;
		
		arial = hxd.res.FontBuilder.getFont("arial", 14);
		
		initMidi();
	}
	
	public function initMidi() {
		var decoder:MIDIDecoder = new MIDIDecoder();
		midiFile = decoder.decodeFile(openfl.Assets.getBytes("assets/snd/midi/midi.mid"));
		midiFile2 = decoder.decodeFile(openfl.Assets.getBytes("assets/snd/midi/midi2.mid"));
	}
	
	//in midi frames
	//start and end are inclusive
	public function getMessageRange( file : MIDIFile, start:UInt, end:UInt, f: Int->Int->TE->Void) {
		var ti = 0;
		for ( t in file.tracks) {
			var i = 0;
			for ( e in t.events ) {
				if ( e.time < start )
					continue;
					
				if ( e.time > end )
					break;
					
				f( ti,i, e );
				i++;
			}
			ti++;
		}
	}
	
	public function update() {
		char.updateChildren();
		mt.flash.Sfx.update();
	}
	
	
}