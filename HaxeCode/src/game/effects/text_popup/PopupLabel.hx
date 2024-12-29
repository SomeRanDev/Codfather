package game.effects.text_popup;

import godot.*;

using tweenxcore.Tools;

class PopupLabel extends Label3D {
	var time = 0.0;
	var start_position: Vector3;
	var target_position: Vector3;

	var y_offset: Float = 0.0;
	var target_y_offset: Float = 0.0;

	public function setup(start: Vector3, end: Vector3) {
		start_position = start;
		target_position = end;
		global_position = start_position;
	}

	public function update(delta: Float) {
		time += delta * 2.0;
		if(time > 1.0) time = 1.0;

		if(y_offset != target_y_offset) {
			y_offset = y_offset.lerp(target_y_offset, delta * 20.0);
		}

		global_position = start_position.lerp(target_position, time.cubicOut()) + new Vector3(0, y_offset, 0);

		if(time < 0.2) {
			final r = time / 0.2;
			scale = Vector3.ONE * r;
		} else if(time > 0.75) {
			final r = (time - 0.75) / 0.25;
			scale = Vector3.ONE * (1.0 - r);
		} else {
			scale = Vector3.ONE;
		}

		if(time >= 1.0) {
			queue_free();
			return true;
		}

		return false;
	}

	public function shift_up() {
		target_y_offset += 0.7;
	}

	public function make_green() {
		modulate.r = 0.5;
		modulate.b = 0.5;
	}
}