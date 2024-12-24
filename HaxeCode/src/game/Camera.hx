package game;

import godot.*;

class Camera extends Camera3D {
	@:export var camera_target_position: Node3D;
	@:export var offset: Vector3;

	var cached_position: Vector3;

	override function _physics_process(_delta: Float): Void {
		final target = camera_target_position.global_position;
		cached_position = cached_position.lerp(target, 0.1);
		global_position = cached_position + offset;
	}
}
