import T;

using Math;
class S {
	var app(get, null) : App; 			function get_app() return App.me;
	var d(get, null) : D; 				function get_d() return App.me.d;
	var g(get, null) : G; 				function get_g() return App.me.g;
	var c(get, null) : CenterScreen;	function get_c() return CenterScreen.me;
	
	public var scene : h2d.Scene;
	var mask:h2d.Mask;
	
	public var root : h2d.Sprite;

	public function new(s) {
		scene = s;
		var g = App.me.g;
		mask = new h2d.Mask( width,  height , scene);
		root = new h2d.Sprite( mask );
	}
	
	public var width(get, null):Int; function get_width() return scene.width.round();
	public var height(get, null):Int; function get_height() return scene.height.round();
	
	public function update(tmod:Float) {
	}
	
}