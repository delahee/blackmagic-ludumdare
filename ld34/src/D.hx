
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
	}
	
	public function update() {
		char.updateChildren();
		mt.flash.Sfx.update();
	}
	
	
}