package game;

import godot.*;

class TileIndicator extends Node3D {
	@:onready var top_left: Sprite3D = untyped __gdscript__("$TopLeft");
	@:onready var top_right: Sprite3D = untyped __gdscript__("$TopRight");
	@:onready var bottom_left: Sprite3D = untyped __gdscript__("$BottomLeft");
	@:onready var bottom_right: Sprite3D = untyped __gdscript__("$BottomRight");

	public function set_animation(r: Float) {
		if(r < 0.5) {
			final r = r / 0.5;
			bottom_right.position = new Vector3(0.5 + 1.0, 0.0, 0.5);
			bottom_left.position = new Vector3(-0.5 + 1.0 - r, 0.0, 0.5);
			top_left.position = new Vector3(-0.5 + 1.0 - r, 0.0, -0.5);
			top_right.position = new Vector3(0.5 + 1.0, 0.0, -0.5);
		} else {
			final r = (r - 0.5) / 0.5;
			bottom_right.position = new Vector3(0.5 + 1.0 - r, 0.0, 0.5);
			bottom_left.position = new Vector3(-0.5, 0.0, 0.5);
			top_left.position = new Vector3(-0.5, 0.0, -0.5);
			top_right.position = new Vector3(0.5 + 1.0 - r, 0.0, -0.5);
		}
	}
}
