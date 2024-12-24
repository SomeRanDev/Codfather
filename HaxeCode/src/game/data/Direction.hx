package game.data;

import godot.Vector2i;

@:using(game.data.Direction.DirectionHelpers)
enum Direction {
	Up;
	Down;
	Left;
	Right;
}

class DirectionHelpers {
	public static function rotation(self: Direction): Float {
		return rotation_ratio(self) * Math.PI;
	}

	public static function rotation_ratio(self: Direction): Float {
		return switch(self) {
			case Up: 1.5;
			case Down: 0.5;
			case Left: 0;
			case Right: 1.0;
		}
	}

	public static function as_vec2i(self: Direction): Vector2i {
		return switch(self) {
			case Up: new Vector2i(0, -1);
			case Down: new Vector2i(0, 1);
			case Left: new Vector2i(-1, 0);
			case Right: new Vector2i(1, 0);
		}
	}
}
