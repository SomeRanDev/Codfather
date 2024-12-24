package game;

import godot.*;

class PostProcess extends MeshInstance3D {
	var shader_material: ShaderMaterial;

	var animation_timer: Float = 0.0;
	var playing_animation: Bool = false;

	override function _ready() {
		shader_material = cast get_surface_override_material(0);
	}

	override function _process(delta: Float) {
		if(playing_animation) {
			animation_timer += delta * 5.0;
			if(animation_timer > 1.0) animation_timer = 1.0;

			if(animation_timer < 0.5) {
				final r = animation_timer / 0.5;
				set_distort_amount(r);
			} else {
				final r = 1.0 - ((animation_timer -  0.5) / 0.5);
				set_distort_amount(r);
			}

			if(animation_timer >= 1.0) {
				playing_animation = false;
				set_process_mode(PROCESS_MODE_DISABLED);
			}
		}
	}

	function set_distort_amount(ratio: Float) {
		shader_material.set_shader_parameter("resolution", (new Vector2(640, 480)).lerp(new Vector2(320, 240), ratio));
		shader_material.set_shader_parameter("aberation_amount", Godot.lerp(1.0, 2.0, ratio));
	}

	public function play_distort() {
		playing_animation = true;
		animation_timer = 0.0;
		set_process_mode(PROCESS_MODE_INHERIT);
	}
}
