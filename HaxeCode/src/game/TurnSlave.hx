package game;

import godot.*;

class TurnSlave extends Node3D {
	var stats = new Stats();

	public function get_speed(): Float {
		return stats.speed;
	}

	public function process_turn() {
	}

	public function process_animation(ratio: Float): Void {
	}
}