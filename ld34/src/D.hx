
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
	
	public var music1Midi : MIDIFile;
	public var music2Midi : MIDIFile;
	
	public static var sfx = mt.flash.Sfx.importDirectory("assets/snd/SFX");
	public static var music = mt.flash.Sfx.importDirectory("assets/snd/music");
	
	public var eightSmall : h2d.Font;
	public var eightMedium : h2d.Font;
	public var eightBig : h2d.Font;
	public var eightVeryBig : h2d.Font;
	
	public function new() {
		char = mt.deepnight.slb.assets.TexturePacker.importXml("assets/assets.xml",true);
		char.texture.filter = Nearest;
		
		var fnt = openfl.Assets.getFont( "assets/wendy_0.ttf" );
		wendyBig = hxd.res.FontBuilder.getFont(fnt.fontName, 40);
		wendyUber = hxd.res.FontBuilder.getFont(fnt.fontName, 80);
		wendySmall = hxd.res.FontBuilder.getFont(fnt.fontName, 20);
		
		var fnt = openfl.Assets.getFont( "assets/8-BIT WONDER.TTF" );
		var opt : hxd.res.FontBuilder.FontBuildOptions= { antiAliasing:false};
		eightSmall = hxd.res.FontBuilder.getFont(fnt.fontName, 12,opt);
		eightMedium = hxd.res.FontBuilder.getFont(fnt.fontName, 24,opt);
		eightBig = hxd.res.FontBuilder.getFont(fnt.fontName, 40,opt);
		eightVeryBig = hxd.res.FontBuilder.getFont(fnt.fontName, 60,opt);
		
		arial = hxd.res.FontBuilder.getFont("arial", 14);
		
		initMidi();
	}
	
	public function initMidi() {
		var decoder:MIDIDecoder = new MIDIDecoder();
		
		inline function l(str) return decoder.decodeFile(openfl.Assets.getBytes(str));
		
		midiFile = l("assets/snd/midi/midi.mid");
		midiFile2 = l("assets/snd/midi/midi2.mid");
		
		music1Midi= l("assets/snd/midi/music1.mid");
		music2Midi = l("assets/snd/midi/music2.mid");
		
		var file = music1Midi;
		var ti = 0;
		for ( t in file.tracks) {
			var i = 0;
			for ( e in t.events ) {
				trace( e );
				i++;
			}
			ti++;
		}
		
		sfxKick00 = sfx.KICK00();
		sfxKick11 = sfx.KICK11();
		sfxKick12 = sfx.KICK12();
		sfxKick13 = sfx.KICK13();
	}
	
	public var music1:mt.flash.Sfx;
	public var music2:mt.flash.Sfx;
	public var music1Bip:mt.flash.Sfx;
	
	public var sfxKick00:mt.flash.Sfx;
	public var sfxKick11:mt.flash.Sfx;
	public var sfxKick12:mt.flash.Sfx;
	public var sfxKick13:mt.flash.Sfx;
	
	public function sndPrepareMusic1() {
		if ( music1 == null ) music1 = music.MUSIC1();
	}
	
	public function sndPrepareMusic1Bip() {
		if ( music1Bip == null ) music1Bip = music.MUSIC1_BIP();
	}
	
	public function sndPrepareMusic2() {
		if ( music2 == null ) music2 = music.MUSIC1();
	}
	
	public function sndPlayMusic1() {
		music1.play().tweenVolume(1.0, 100);
	}
	
	public function sndPlayMusic1Bip() {
		music1Bip.play().tweenVolume(1.0, 100);
	}
	
	public function sndPlayMusic2(){
		music2.play().tweenVolume(1.0, 100);
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