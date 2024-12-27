package game.data;

import godot.Vector2i;
import godot.Vector3i;

@:using(game.data.Direction.DirectionHelpers)
enum Direction {
	Up;
	Down;
	Left;
	Right;
}

class DirectionHelpers {
	public static function random(): Direction {
		return switch(godot.Godot.randi_range(0, 4)) {
			case 0: Up;
			case 1: Down;
			case 2: Left;
			case 3: Right;
			case _: Up;
		}
	}

	public static function reverse(self: Direction): Direction {
		return switch(self) {
			case Up: Down;
			case Down: Up;
			case Left: Right;
			case Right: Left;
		}
	}

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

	public static function as_vec3i(self: Direction): Vector3i {
		return switch(self) {
			case Up: new Vector3i(0, -1, 0);
			case Down: new Vector3i(0, 1, 0);
			case Left: new Vector3i(-1, 0, 0);
			case Right: new Vector3i(1, 0, 0);
		}
	}
}
