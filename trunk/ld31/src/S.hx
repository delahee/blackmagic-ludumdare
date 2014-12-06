import T;
class S{
	var scene : h2d.Scene;
	var mask:h2d.Mask;
	public function new(s) {
		scene = s;
		var g = App.me.g;
		var mask = new h2d.Mask( g.masterScene.targetRatioW *  scene.width,  g.masterScene.targetRatioH * scene.height,scene);
	}
	
	public function update(tmod) {
	}
	
}