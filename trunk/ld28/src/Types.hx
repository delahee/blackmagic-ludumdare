import flash.media.Sound;
import flash.text.Font;
enum NmyType {
	Normal;
	Heavy;
	Boss;
}

enum BS {
	Waitplayer;
	Talk;
	Choice;
	ShootAtWill;
}

@:font('asset/nokiafc22.ttf')
class Nokia extends Font{
	
}

@:sound('Chased_16PCM.mp3')
class Chased extends Sound {
	
}

@:sound('Healing_16PCM.mp3')
class Healing extends Sound {
	
}

@:sound('pok.wav')
class Pok extends Sound {
	
}

@:sound('impact.wav')
class Impact extends Sound {
	
}

@:sound('death.wav')
class Death extends Sound {
	
}

@:sound('sand.wav')
class Sand extends Sound {
	
}