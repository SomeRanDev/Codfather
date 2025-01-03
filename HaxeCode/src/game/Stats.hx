package game;

import godot.Godot;

class Stats {
	static var max_id = 10;
	public static function reset() { max_id = 10; }

	public var id = 0;

	public var max_health = 10;
	public var health = 10;

	public var power: Int = 5;
	public var tough: Int = 5;
	public var speed: Int = 5;
	public var luck: Int = 5;

	public function new() {
	}

	public function generate_id() {
		id = max_id++;
	}

	public function randomize() {
		speed = Godot.randi_range(2, 8);
	}
}
