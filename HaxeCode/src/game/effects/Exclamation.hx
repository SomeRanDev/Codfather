package game.effects;

import godot.*;

class Exclamation extends MeshInstance3D {
	var start: Vector3;
	var end: Vector3;

	var animation: Float = 0.0;

	public function start_effect() {
		set_process_mode(PROCESS_MODE_INHERIT);
		visible = true;
	}

	override function _ready() {
		start = position;
		end = start + new Vector3(0.0, 1.0, 0.0);

		set_process_mode(PROCESS_MODE_DISABLED);
		visible = false;
	}

	override function _process(delta: Float) {
		animation += delta * 3.0;
		if(animation > 1.0) animation = 1.0;

		position = start.lerp(end, animation.cubicOut());

		if(animation >= 1.0) {
			set_process_mode(PROCESS_MODE_DISABLED);
			visible = false;
		}
	}
}
