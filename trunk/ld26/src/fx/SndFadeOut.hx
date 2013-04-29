package fx;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import volute.fx.FX;

/**
 * ...
 * @author de
 */
class SndFadeOut extends FX
{
	var sc: SoundChannel;
	public function new(sc:SoundChannel,d) 
	{
		super( d );
		this.sc = sc;
	}
	
	public override function update() {
		var b = super.update();
		
		sc.soundTransform = new SoundTransform( 1.0-t() );
		return b;
		
	}
	
}