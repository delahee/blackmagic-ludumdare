
import mt.deepnight.slb.BLib;
import mt.deepnight.slb.HSprite;

class D {
	public static var me : D = null;
	
	public var char : mt.deepnight.slb.BLib;
	public var decor : mt.deepnight.slb.BLib;
	public var wendyBig : h2d.Font;
	public var wendySmall : h2d.Font;
	public var wendyUber : h2d.Font;
	public var arial : h2d.Font;
	
	public static var sfx = mt.flash.Sfx.importDirectory("assets/snd/SFX");
	public static var music = mt.flash.Sfx.importDirectory("assets/snd/music");
	
	public function getSphereAdd(p:h2d.Sprite) : mt.deepnight.slb.HSprite {
		var d = char.h_get("sphere_add",p);
		d.setCenterRatio(0.5, 0.5);
		return d;
	}
	
	public function new() {
		char = mt.deepnight.slb.assets.TexturePacker.importXml("assets/assets.xml",true);
		char.texture.filter = Nearest;
		
		decor = mt.deepnight.slb.assets.TexturePacker.importXml("assets/decor.xml");
		decor.texture.filter = Linear;
		
		var fnt = openfl.Assets.getFont( "assets/wendy_0.ttf" );
		wendyBig = hxd.res.FontBuilder.getFont(fnt.fontName, 40);
		wendyBig.tile.getTexture().filter = Nearest;
		
		wendyUber = hxd.res.FontBuilder.getFont(fnt.fontName, 80);
		wendyUber.tile.getTexture().filter = Nearest;
		
		wendySmall = hxd.res.FontBuilder.getFont(fnt.fontName, 20);
		wendySmall.tile.getTexture().filter = Nearest;
		
		arial = hxd.res.FontBuilder.getFont("arial", 14);
	}
	
	public function update() {
		char.updateChildren();
		decor.updateChildren();
		mt.flash.Sfx.update();
	}
	
	public var battle:mt.flash.Sfx;
	public var gameover:mt.flash.Sfx;
	public var boss:mt.flash.Sfx;
	public var intro:mt.flash.Sfx;
	
	public function sndPlayBattle() {
		if ( battle == null )battle = music.battle_OK();
		battle.playLoop(500).tweenVolume(1.0, 100);
	}
	
	public function sndPlayGameover(){
		if ( gameover == null )gameover = music.gameover_OK();
		gameover.playLoop(500).tweenVolume(1.0, 100);
	}
	
	public function sndPlayIntro() {
		if ( intro == null )intro = music.intro_OK();
		intro.playLoop(500).tweenVolume(1.0, 100);
	}
	
	public function sndPlayBoss() {
		if ( boss == null )boss = music.boss_OK();
		boss.playLoop(500).tweenVolume(1.0, 100);
	}
	
	public function sndStopBattle() 
	if(battle!=null) battle.tweenVolume(0.0, 200).onEnd = function() 	
	{ if (battle != null) battle.stop(); battle = null; };
	
	public function sndStopGameover() 
	if (gameover != null) gameover.tweenVolume(0.0, 200).onEnd = function() 
	{ if (gameover != null) gameover.stop(); gameover = null; };
	
	public function sndStopIntro() 
	if (intro != null) intro.tweenVolume(0.0, 200).onEnd = function() 		
	{ if (intro != null) intro.stop(); intro = null; };
	
	public function sndStopBoss()
	if (boss != null) boss.tweenVolume(0.0, 200).onEnd = function() 	
	{ if(boss!=null)boss.stop(); boss = null; };
	
	
	
}