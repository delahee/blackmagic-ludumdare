import T;
using Math;

import mt.deepnight.slb.HSprite;
import mt.deepnight.slb.SpriteInterface;
import mt.deepnight.Tweenie;

class CenterScreen extends S {
	
	public var char : Array<Char> = [];
	public var nmy : Array<Char> = [];
	public var nextNmy : Array<Char> = [];
	
	public var columnInteract : Array<h2d.Interactive>=[];
	public var columnsGraphics : Array<ColumnGraphics>=[];
	
	public var lockInteraction : Int;
	public var partLayers : Array<h2d.SpriteBatch>;
	
	public var bg : HSprite;
	public var bgNight : HSprite;
	public var boss : HSprite;
	public var pause : h2d.Text;
	
	public var wave : Int = #if debug 0#else 0#end;
	
	public static var me : CenterScreen;
	public function new(s) 	{
		me = this;
		super(s);
		
		bgNight = d.char.h_get("bgNight", root);
		bg = d.char.h_get("bg", root);
		boss = d.char.h_getAndPlay("mobBoss");
		root.addChild(boss);
		
		bgNight.alpha = 0.99;
		bg.alpha = 0.99;
		boss.visible = false;
		
		//char[0] = mkChar(0);
		//char[1] = mkChar(1);
		//char[2] = mkChar(2);
		//nextNmy = [ mkNmy(0, 1), mkNmy(1, 1), mkNmy(2, 1)];
		//nmy = [ mkNmy(0, 0), mkNmy(1, 0), mkNmy(2, 0)];
		
		//nextWave();
		
		makeColumn(0);
		makeColumn(1);
		makeColumn(2);
		
		partLayers = [];
		
		var s = null;
		partLayers.push(s=new h2d.SpriteBatch(  d.char.tile ,root));
		s.blendMode = Add;
		
		haxe.Timer.delay(function(){
			init();
		},1);
		
		pause = new h2d.Text(d.wendyBig, root);
		pause.text = "PAUSE";
		
		pause.x = C.CW * 0.5;
		pause.x -= pause.textWidth * 0.5;
		
		pause.y = C.CH * 0.33;
		pause.y -= pause.textHeight * 0.5;
		pause.visible = false;
	}
	
	public function night() {
		app.tweenie.create( bg, "alpha", 0.0, TType.TLinear, 4000 );
	}
	
	public function day() {
		app.tweenie.create( bg, "alpha", 1.0, TType.TLinear, 4000 );
	}
	
	public function init() {
		
	}
	
	public function dispose() {
		
	}
	
	public function canInteract() return lockInteraction == 0;
	
	public function makeColumn(idx:Int) {
		var r = calcLineRect( idx );
		var i = new h2d.Interactive(r.z, r.w, scene);
		var c = null;
		i.x = r.x; i.y = r.y;
		columnInteract.push( i );
		columnsGraphics.push(c=new ColumnGraphics(scene,r,idx));
		
		i.onClick = function(e) {
			if ( g.stopped ) {
				c.setDehovered();
				c.setDeselected();
				return;
			}
			for ( cg in columnsGraphics ) 
				if ( cg == c && cg.selected){
					c.setDeselected();
					return;
				}
				
			for ( cg in columnsGraphics ) 
				if ( cg != c && cg.selected ) {
					var cin = char[idx];
					var cout = char[cg.idx];
					if( cin!=null && cin.isLocked()) continue;
					if( cout!=null && cout.isLocked()) continue;
					
					if( cin !=null || cout != null)
						swap(cg.idx, c.idx);
					
					for ( cg in columnsGraphics )
						cg.setDeselected();
						
					return;
				}
				
			if ( char[idx] == null )
				return;
			c.setSelected();
			trace("onclick");
		};
		
		i.onOut = function(e) {
			if ( g.stopped ) {
				c.setDehovered();
				c.setDeselected();
				return;
			}
			c.setDehovered();
		};
		
		i.onOver = function(e) {
			if ( g.stopped ) {
				c.setDehovered();
				c.setDeselected();
				return;
			}
			c.setHovered();
		};
	}
	
	public function xOf(i) {
		return
		switch( i ) {
			case 0: (C.CW >> 1) - C.CHAR_W;
			case 1: (C.CW >> 1);
			case 2: (C.CW >> 1) + C.CHAR_W;
			default: 0;
		};
	}
	
	public function mkNmy(col,line,cl:CharClass) {
		var b = new Char(cl, scene);
		b.setTile( "mob" +getLetter(cl) );
		b.finish(col,line);
		
		if ( line > 0 ) {
			mt.heaps.fx.Lib.traverseDrawables( b,
			function(b) {
				var m = new h3d.Matrix();
				m.colorSaturation( 0.5);
				m.colorContrast(-0.3);
				b.colorMatrix = m;
			});
		}
		
		#if debug
		var g = new h2d.Graphics(b);
		g.beginFill(0xFF00FF);
		g.drawRect( 0, 0, 64, 64);
		g.endFill();
		g.visible = false;
		#end
		
		b.x = xOf( col );
		b.y = C.NMY_Y;
		switch(line) {
			default: 
			case 1: b.x += 16;  b.y -= 64; b.scaleX = b.scaleY = 0.5;
		}
		return b;
	}
	
	public function getLetter(cl:CharClass) {
		return
		switch(cl) {
			case Whitemage:"A";
			case Warrior:"B";
			case Blackmage:"C";
			
			
			case Dummy,Skel:"A";
			case Thug:"B";
			case Taxman:"C";
			case Leech:"D";
			case Tentacle:"F";
		}
	}
	
	public function mkChar(i,cl) {
		var b = new Char(cl, scene);
		b.isGood = true;
		b.setTile( "char" + getLetter(cl));
		b.finish(i,0);
		b.x = xOf( i );
		b.y = C.CHAR_Y;
		return b;
	}
	
	public function onDeath(){
		
		var areAllDead = true;
		for ( cs in c.char ) 
			if ( cs != null && !cs.isDead ) 
				areAllDead = false;
				
		if( areAllDead)
			g.launchLostScreen();
		
		var isWaveFinished = true;
		for ( i in 0...c.nmy.length ) {
			var cs = c.nmy[i];
			if( cs != null){
				if ( !cs.isDead )
					isWaveFinished = false;
				if ( cs.isDead ) 
					if ( c.nextNmy[i] != null ){
						c.nmy[i] = c.nextNmy[i];
						c.nextNmy[i] = null;
						c.nmy[i].setToFront();
						isWaveFinished = false;
					}
			}
		}
		
		if ( isWaveFinished ){
			var b = new h2d.Sprite(root);
			var t = new h2d.Text( d.wendyUber, b);
			t.text = "WAVE " + (wave+1) +" COMPLETE";
			t.textColor = 0xFFE8400A;
			t.x = -t.textWidth * 0.5;
			t.y = -t.textHeight * 0.5;
			
			b.x = C.CW * 0.5;
			b.y = C.CH * 0.33;
			
			t.dropShadow = { dx:2, dy:2, color:0x000000, alpha:0.9 };
			new mt.heaps.fx.Spawn( b, 0.1, false, true);
			
			if(d.battle!=null) d.battle.tweenVolume( 0.0, 100 );
			D.music.jingle_win_OK().playLoop(1);
			haxe.Timer.delay( function() if( d.battle != null ) d.battle.tweenVolume(1.0,100), 4500 );
			
			haxe.Timer.delay( function() {
				nextWave();
				new mt.heaps.fx.Vanish( b );
			}, 200 );
		}
	}
	
	
		
	public override function update(tmod) {
		super.update(tmod);
		
		#if debug
		if ( mt.flash.Key.isToggled(mt.flash.Key.SPACE)) {
			for ( c in char ) 
			
				if( c != null)
				//var c = char[0];
				//c.execute( BlackSpell(Fire, Bolt ) );
				//c.execute( WhiteSpell(Water, Heal ) );
				//c.execute( WhiteSpell(Fire, Speed) );
				//c.execute( WhiteSpell(Earth, Armor) );
				//c.execute( BlackSpell(Water, Spike) );
				c.execute( BlackSpell(Earth, Root) );
				//c.execute( Def );
		}
		#end
		
		for ( c in char )
			if( c != null && canInteract() ) 
				c.update( tmod );
			
		for ( c in nmy )
			if( c != null && canInteract() ) 
				c.update( tmod );
			
		updateLine();
	}
	
	public function oppSwap(i, j) {
		var d = 300;
		var from = nmy[i];
		var to = nmy[j];
		var tt = mt.deepnight.Tweenie.TType.TElasticEnd;
		
		var t = null;
		if ( from != null) {
			from.lock();
			t = app.tweenie.create( nmy[i], "x", xOf(j), tt, d);
		}
		if ( to != null) {
			to.lock();
			t = app.tweenie.create( nmy[j], "x", xOf(i), tt, d);
		}
		t.onEnd = function() {
			var o = nmy[j];
			nmy[j] = nmy[i];
			nmy[i] = o;
		}
		
		D.sfx.slide().play();
	}
	
	public function swap(i, j) {
		lockInteraction++;
		
		var d = 300;
		var from = char[i];
		var to = char[j];
		var tt = mt.deepnight.Tweenie.TType.TElasticEnd;
		
		if ( from != null ) from.lock();
		if ( to != null ) 	to.lock();
		if ( from == null && to == null) return;
		
		var t = null;
		if( char[i]!=null)	t = app.tweenie.create( char[i], "x", xOf(j), tt, d);
		if( char[j]!=null) 	t = app.tweenie.create( char[j], "x", xOf(i), tt, d);
		t.onEnd = function() {
			lockInteraction--;
			
			var o = char[j];
			char[j] = char[i];
			char[i] = o;
			trace("unlocked");
		}
		
		D.sfx.slide().play();
	}
	
	public function cleanupNmy() {
		for ( n in nmy )
			if ( n != null) 
				n.dispose();
		nmy = [null, null, null];
			
		for ( n in nextNmy )
			if( n != null) 
				n.dispose();
		nextNmy = [null, null, null];
		boss.visible = false;
	}
	
	public function cleanup() {
		for ( n in nmy )
			if ( n != null) 
				n.dispose();
		nmy = [null, null, null];
			
		for ( n in nextNmy )
			if( n != null) 
				n.dispose();
		nextNmy = [null, null, null];
		
		for ( n in char )
			if( n != null) {
				var o = new mt.heaps.fx.Vanish( n );
				o.onFinish = function() {
					n.dispose();
				}
			}
		char = [null, null, null];
		boss.visible = false;
	}
	
	public function updateLine() {
		for (cg in columnsGraphics ) 
			cg.update( hxd.Timer.tmod );
			
		for (cg in columnInteract ) 
			cg.visible = lockInteraction == 0;
	}
	
	public function calcLineRect(i) : h3d.Vector {
		var margin = 2.0;
		return new h3d.Vector(xOf(i) - (C.CHAR_W >> 1) - margin, margin, C.CHAR_W, C.CH);
	}
	
	public function nextWave() {
		var nmy = [null,null,null];
		var nextNmy = [null,null,null];
			
		if ( wave == 14 ) {
			g.launchVictoryScreen();
		}
		else {
			for ( n in this.nmy )
				if( n != null)
					n.dispose();
					
			for ( n in this.nextNmy )
				if( n != null)
					n.dispose();
			
			switch(wave) {
				
				case -1:
					char = [mkChar(0, Whitemage), mkChar(1, Blackmage), mkChar(2, Warrior)];
					nmy = [Dummy, Dummy, Dummy]; 
					nextNmy = [Dummy, Dummy, Dummy]; 
					d.sndPlayBattle();
					
				case 0:
					char = [null, null, mkChar(2, Warrior)];
					nmy = [Skel, null, null]; 
					d.sndPlayBattle();
					
				case 1:
					nmy = [null, Thug, null]; 
					
				case 2:
					nmy = [Taxman, null, Skel]; 
					for ( i in 0...char.length ) {
						if ( char[i] == null ) {
							char[i] = mkChar(i, Whitemage);
							new mt.heaps.fx.Spawn( char[i], 0.1, true );
							break;
						}
					}
				
				case 3:
					nmy = [Skel, Thug,Skel]; 
					
				case 4:
					nmy = [Thug,null,Thug]; 
					nextNmy = [Skel,null,Taxman];
					
				case 5:
					nmy = [Thug,Thug,Thug]; 
					
					for ( i in 0...char.length ) {
						if ( char[i] == null ) {
							char[i] = mkChar(i, Blackmage);
							new mt.heaps.fx.Spawn( char[i], 0.1, true );
							break;
						}
					}
					
				case 6:
					nmy 	= [Thug,null, 	Thug]; 
					nextNmy = [Skel,null, 	Taxman];
					
				case 7:
					nmy 	= [Leech, 	Taxman,	Thug]; 
					nextNmy = [Skel, 	null, 	Taxman];
					
				case 8:
					nmy 	= [Skel, 	Thug,	Taxman]; 
					nextNmy = [Taxman,	 Leech,	Taxman];
					
				case 9:
					nmy 	= [Leech, 	Thug,	Skel]; 
					nextNmy = [Taxman,	Leech,	Taxman];
					
				case 10:
					d.sndStopBattle();
					d.sndPlayBoss();
					boss.visible = true;
					nmy 	= [null, 	Tentacle,	null]; 
					
				case 11:
					nmy 	= [Tentacle, null,		Tentacle]; 
					
				case 12:
					nmy 	= [Tentacle, Tentacle,	Tentacle]; 
					
				case 13:
					nmy 	= [Tentacle, Tentacle,	Tentacle]; 
					nextNmy = [null, 	Tentacle,		null]; 
			}
			
			for ( i in 0...nextNmy.length )
				if ( nextNmy[i] == null )
					this.nextNmy[i] =null;
				else 
					this.nextNmy[i] = mkNmy( i, 1, nextNmy[i]);
					
			for ( i in 0...nmy.length )
				if ( nmy[i] == null )
					this.nmy[i] =null;
				else 
					this.nmy[i] = mkNmy( i, 0, nmy[i]);
			
			wave++;
		}
	}
	
}