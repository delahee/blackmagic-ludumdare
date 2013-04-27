package ;
import starling.display.Sprite;

/**
 * ...
 * @author de
 */
class G extends Sprite {
	
	public static var me : G = null;
	public var l = null;

	public function new() {
		super();
		me = this;
	}
	
	public function setLevel( l : L)
	{
		if (l != null) removeChild(l);
		this.l = l;
		addChild(l);
		return l;
	}
	
	public function update() {
		
	}
	
	public function kill() {
		if ( l!=null) {
			removeChild( l );
			l.dispose();
			l = null;	
		}
	}
	
}