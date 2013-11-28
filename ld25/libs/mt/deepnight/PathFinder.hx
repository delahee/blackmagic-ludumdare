package mt.deepnight;

typedef AStarPoint = {x:Int, y:Int, parent:AStarPoint, goalScore:Float, homeScore:Float};

private class AStarList {
	public var list	: List<AStarPoint>;
	var hash		: IntHash<Bool>;
	
	public function new() {
		list = new List();
		hash = new IntHash();
	}
	
	private inline function id(pt:AStarPoint) {
		return pt.x + pt.y*100000;
	}
	
	public inline function add(pt:AStarPoint) {
		if( !has(pt) ) {
			list.add(pt);
			hash.set(id(pt), true);
		}
	}
	
	public function search(spt:AStarPoint) {
		for( pt in list )
			if( pt.x==spt.x && pt.y==spt.y )
				return pt;
		return null;
	}
	
	public inline function remove(pt:AStarPoint) {
		if( has(pt) ) {
			list.remove(pt);
			hash.set(id(pt), false);
		}
	}
	
	public inline function has(pt:AStarPoint) {
		return hash.get(id(pt));
	}
	
	public inline function iterator() {
		return list.iterator();
	}
}


// Credits : http://www.policyalmanac.org/games/aStarTutorial.htm

class PathFinder {
	var colMap		: Array<Array<Bool>>;
	var wid			: Int;
	var hei			: Int;
	
	public var moveCost		: Int->Int -> Int->Int -> Float; //    fn(fromX,fromY, toX,toY) -> cost
	public var turnCost		: Float; // Set to 1.1+ to reduce turnings
	public var useCache		: Bool;

	var openList	: AStarList;
	var closedList	: AStarList;
	
	var cache		: IntHash<Array<{x:Int, y:Int}>>;
	var diagonals	: Bool;
	
	public var tries(default,null) 		: Int;
	
	public function new(w,h, ?allowDiagonals=false) {
		wid = w;
		hei = h;
		useCache = true;
		diagonals = allowDiagonals;
		turnCost = 1.0;
		moveCost = function(x1,y1, x2,y2) return 1;
		
		resetCollisions();
	}
	
	public inline function resetCache() {
		cache = new IntHash();
	}
	
	public function resetCollisions() {
		resetCache();
		colMap = new Array();
		for(x in 0...wid) {
			colMap[x] = new Array();
			for(y in 0...hei)
				setCollision(x,y, false);
		}
	}
	
	inline function abs(n) {
		return n>0 ? n : -n;
	}
	
	inline function getHeuristicDist(a:AStarPoint, b:AStarPoint) {
		return abs(a.x-b.x) + abs(a.y-b.y);
	}
	
	public function astar(from:{x:Int, y:Int}, to:{x:Int, y:Int}) {
		if( useCache && cache.exists( getCacheID(from,to) ) )
			return cache.get( getCacheID(from,to) );
			
		openList = new AStarList();
		closedList = new AStarList();
		if( getCollision(from.x,from.y) || getCollision(to.x,to.y) )
			return new Array();
		if( from.x<0 || from.y<0 || from.x>=wid || from.y>=hei )
			return new Array();
		if( to.x<0 || to.y<0 || to.x>=wid || to.y>=hei )
			return new Array();
		return astarLoop(
			{x:from.x, y:from.y, homeScore:0, goalScore:-1, parent:null},
			{x:to.x, y:to.y, homeScore:0, goalScore:-1, parent:null}
		);
	}
	
	inline function getCacheID(start:{x:Int,y:Int}, end:{x:Int,y:Int}) {
		return start.x+start.y*wid + 100000*(end.x+end.y*wid);
	}
	
	function astarLoop(start:AStarPoint, end:AStarPoint) {
		var tmp = end; end = start; start = tmp; // Avoid the path to be returned reversed
		openList = new AStarList();
		closedList = new AStarList();
		openList.add(start);
		
		tries = 0;
		while( openList.list.length>0 ) {
			tries++;
			var cur : AStarPoint = null;
			for(pt in openList.list)
				if( cur==null || cur.goalScore+cur.homeScore>pt.goalScore+pt.homeScore )
					cur = pt;
			openList.remove(cur);
			closedList.add(cur);
			if( cur.x==end.x && cur.y==end.y ) {
				end = cur;
				break;
			}
			
			var neig = new Array();
			neig.push( { dx:-1,	dy:0,	cost:1.0} );
			neig.push( { dx:1,	dy:0,	cost:1.0} );
			neig.push( { dx:0,	dy:-1,	cost:1.0} );
			neig.push( { dx:0,	dy:1,	cost:1.0} );
			if( diagonals ) {
				neig.push( { dx:-1,	dy:-1,	cost:1.4} );
				neig.push( { dx:1,	dy:-1,	cost:1.4} );
				neig.push( { dx:1,	dy:1,	cost:1.4} );
				neig.push( { dx:-1,	dy:1,	cost:1.4} );
			}
			
			for( n in neig ) {
				var pt = { x:cur.x+n.dx, y:cur.y+n.dy, homeScore:-1., goalScore:-1., parent:cur }
				if( getCollision(pt.x, pt.y) || closedList.has(pt) )
					continue;
				var cost = moveCost(cur.x, cur.y, pt.x, pt.y) * n.cost;
				if( cost<0 )
					continue;
				var lastDir = if( cur.parent!=null ) {dx:cur.x-cur.parent.x, dy:cur.y-cur.parent.y} else {dx:0, dy:0};
				pt.homeScore = (cur.homeScore + cost ) * (lastDir.dx!=n.dx || lastDir.dy!=n.dy ? turnCost : 1);
				pt.goalScore = getHeuristicDist(pt, end);
				if( !openList.has(pt) )
					openList.add(pt);
				else {
					var old = openList.search(pt);
					if( pt.homeScore<old.homeScore ) {
						old.homeScore = pt.homeScore;
						old.parent = pt.parent;
					}
				}
			}
		}
		
		if( end.parent==null )
			return new Array();
		else {
			var path = new Array();
			var pt = end;
			while( pt.parent!=null ) {
				path.push({x:pt.x, y:pt.y});
				pt = pt.parent;
			}
			path.push({x:start.x, y:start.y});
			cache.set( getCacheID( {x:end.x, y:end.y}, {x:start.x, y:start.y} ), path);
			return path;
		}
	}
	
	
	public function setSquareCollision(x,y,w,h, ?b=true) {
		for(ix in x...x+w)
			for(iy in y...y+h)
				colMap[ix][iy] = b;
		resetCache();
	}
	
	
	public inline function setCollision(x:Int,y:Int, ?b=true) {
		colMap[x][y] = b;
		resetCache();
	}
	
	public inline function getCollision(x:Int, y:Int) {
		if( x<0 || x>=wid || y<0 || y>=hei )
			return true;
		else
			return colMap[x][y];
	}
	
}

