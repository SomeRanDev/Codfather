package game;

import godot.*;

class Camera extends Camera3D {
	@:export var camera_target_position: Node3D;
	@:export var offset: Vector3;

	var cached_position: Vector3;

	var shake_ratio: Float;

	override function _physics_process(delta: Float): Void {
		final shake_offset = if(shake_ratio > 0.0) {
			shake_ratio -= delta * 10.0;
			new Vector3(
				Math.sin(Time.get_ticks_msec() * 0.05) * 0.333,
				Math.cos(Time.get_ticks_msec() * 0.09) * 0.645,
				0.0
			) * 0.2;
		} else {
			Vector3.ZERO;
		}

		final target = camera_target_position.global_position;
		cached_position = cached_position.lerp(target, 0.1);
		global_position = cached_position + offset + shake_offset;
	}

	public function shake() {
		shake_ratio = 1.0;
	}
}
