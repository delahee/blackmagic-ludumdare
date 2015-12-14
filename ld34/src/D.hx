
import mt.deepnight.slb.BLib;
import mt.deepnight.slb.HSprite;

import com.newgonzo.midi.MIDIDecoder;
import com.newgonzo.midi.file.*;
import com.newgonzo.midi.events.MessageEvent;

typedef MidiStruct = {
	midi:MIDIFile,
	durBeat:Int,
	durTick:Int,
	bpm:Int,
	sig:Int,
}

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
	
	public var music1Desc : MidiStruct;
	public var music2Desc : MidiStruct;
	public var music3Desc : MidiStruct;
	public var music4Desc : MidiStruct;
	public var musics : Array<MidiStruct>;
	
	public static var sfx = mt.flash.Sfx.importDirectory("assets/snd/SFX");
	public static var music = mt.flash.Sfx.importDirectory("assets/snd/music");
	
	public var eightVerySmall : h2d.Font;
	public var eightSmall : h2d.Font;
	public var eightMedium : h2d.Font;
	public var eightMediumPlus : h2d.Font;
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
		eightVerySmall = hxd.res.FontBuilder.getFont(fnt.fontName, 8,opt);
		eightSmall = hxd.res.FontBuilder.getFont(fnt.fontName, 12,opt);
		eightMedium = hxd.res.FontBuilder.getFont(fnt.fontName, 22,opt);
		eightMediumPlus = hxd.res.FontBuilder.getFont(fnt.fontName, 28,opt);
		eightBig = hxd.res.FontBuilder.getFont(fnt.fontName, 40,opt);
		eightVeryBig = hxd.res.FontBuilder.getFont(fnt.fontName, 60,opt);
		
		arial = hxd.res.FontBuilder.getFont("arial", 14);
		
		initMidi();
	}
	
	public function stopAllMusic() {
		for ( a in [music1, music2, music3, music4])
			a.stop();
	}
	
	public function initMidi() {
		var decoder:MIDIDecoder = new MIDIDecoder();
		
		inline function l(str) return decoder.decodeFile(openfl.Assets.getBytes(str));
		sfxKick00 = sfx.KICK00();
		sfxKick11 = sfx.KICK11();
		sfxKick12 = sfx.KICK12();
		sfxKick13 = sfx.KICK13();
		
		function parseMidi(str,bpm,sig) :MidiStruct {
			var midi = l(str);
			var durTick = seekEnd(midi);
			var durBeat = Std.int(durTick / midi.division);
			return { midi:midi, durBeat:durBeat, durTick:durTick,sig:sig,bpm:bpm };
		}
		music1Desc	= parseMidi("assets/snd/midi/music1.mid",125,4);
		music2Desc 	= parseMidi("assets/snd/midi/music2.mid",140,3);
		music3Desc 	= parseMidi("assets/snd/midi/music3.mid",135,4);
		music4Desc 	= parseMidi("assets/snd/midi/music4.mid",115,4);
		musics = [music1Desc, music2Desc, music3Desc, music4Desc];
		
		//trace( musics );
	}
	
	function seekEndBeat(file:MIDIFile) {
		var d = seekEnd(file);
		return midiTickToBeats( file, d);
	}
	
	function seekEnd(file:MIDIFile) {
		for ( t in file.tracks) {
			for ( e in t.events ) {
				if ( e.time != 0 && Std.is( e.message , com.newgonzo.midi.file.messages.EndTrackMessage) ) {
					return e.time;
				}
			}
		}
		return -1;
	}
	
	function midiTickToBeats(file,nb) {
		return Std.int(nb / file.division);
	}
	
	public var music1:mt.flash.Sfx;
	public var music2:mt.flash.Sfx;
	public var music3:mt.flash.Sfx;
	public var music4:mt.flash.Sfx;
	
	public var sfxKick00:mt.flash.Sfx;
	public var sfxKick11:mt.flash.Sfx;
	public var sfxKick12:mt.flash.Sfx;
	public var sfxKick13:mt.flash.Sfx;
	
	public function sndPrepareMusic1() 	if ( music1 == null ) music1 = music.MUSIC1();
	public function sndPrepareMusic2() 	if ( music2 == null ) music2 = music.MUSIC2();
	public function sndPrepareMusic3() 	if ( music3 == null ) music3 = music.MUSIC3();
	public function sndPrepareMusic4() 	if ( music4 == null ) music4 = music.MUSIC4();
	
	public function sndPlayMusic1()  	music1.play().tweenVolume(1.0, 100);
	public function sndPlayMusic2()		music2.play().tweenVolume(1.0, 100);
	public function sndPlayMusic3()		music3.play().tweenVolume(1.0, 100);
	public function sndPlayMusic4()		music4.play().tweenVolume(1.0, 100);
	
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