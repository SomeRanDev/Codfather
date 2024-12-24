package game;

class Stats {
	static var max_id = 10;

	public var id = 0;

	public var health = 10;

	public var power: Int = 5;
	public var tough: Int = 5;
	public var speed: Int = 5;
	public var special: Int = 5;

	public function new() {
	}

	public function generate_id() {
		id = max_id++;
	}
}
