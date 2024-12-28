package game;

class WorldManager {
	public static var floor = 1;
	public static var floors_remaining = 4;
	public static var should_randomize = false;

	public static var no_more_floors = false;

	public static function next_floor() {
		if(floors_remaining > 0) {
			floor += 1;
			floors_remaining -= 1;
			should_randomize = true;
		} else {
			no_more_floors = true;
		}
	}
}
