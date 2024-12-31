package game;

import godot.*;

class TileIndicator extends Node3D {
	@:export var normal_texture: Texture2D;
	@:export var fast_texture_1: Texture2D;
	@:export var fast_texture_2: Texture2D;

	@:onready(node = "TopLeft") var top_left: Sprite3D;
	@:onready(node = "TopRight") var top_right: Sprite3D;
	@:onready(node = "BottomLeft") var bottom_left: Sprite3D;
	@:onready(node = "BottomRight") var bottom_right: Sprite3D;

	var is_fast: Bool = false;
	var timer: Float;

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

	public function set_fast(is_fast: Bool) {
		this.is_fast = is_fast;
		set_process_mode(is_fast ? PROCESS_MODE_INHERIT : PROCESS_MODE_DISABLED);
		if(is_fast) {
			set_all_textures(fast_texture_1);
		} else {
			set_all_textures(normal_texture);
		}
	}

	override function _ready() {
		set_fast(false);
	}

	override function _process(delta: Float) {
		timer += delta * 10.0;
		if(timer > 1.0) {
			timer = 0.0;

			if(top_left.texture == fast_texture_1) {
				set_all_textures(fast_texture_2);
			} else {
				set_all_textures(fast_texture_1);
			}
		}
	}

	function set_all_textures(t: Texture2D) {
		top_left.texture = t;
		top_right.texture = t;
		bottom_left.texture = t;
		bottom_right.texture = t;
	}
}
