
enum Dir {
	Top;
	Left;
	Right;
	Bottom;
	Center;
}

enum Elem {
	None;
	Light;
	Dark;
	
	Fire;
	Earth;
	Water;
}

enum SpellForm {
	Bolt;
	Spike;
	Root;
	
	Heal;
	Armor;
	Speed;
}

enum Spell {
	Nop;
	Atk;
	Def;
	Swap;
	WhiteSpell( e:Elem, f : SpellForm );
	BlackSpell( e:Elem, f : SpellForm );
	
	DotSideFx;
}

typedef SpellDef = {
	var s : Spell;
	var weight : Int;
}

enum CharClass {
	Warrior;
	Blackmage;
	Whitemage;
	
	Dummy;
	Thug;
	Skel;
	Taxman;
	Leech;
	Tentacle;
}
