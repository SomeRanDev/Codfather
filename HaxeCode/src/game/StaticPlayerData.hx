package game;

import game.Stats;

class StaticPlayerData {
	public static var stats = new Stats();

	public static var species: Int = 0;
	public static var class_kind: Int = 0;
	public static var teeth: Int = 14;
	public static var max_teeth: Int = 14;

	public static function reset() {
		stats = new Stats();
	}

	public static function set_base_stats(stat_array: Array<Int>) {
		stats.max_health = stat_array[0];
		stats.health = stat_array[0];
		stats.power = stat_array[1];
		stats.tough = stat_array[2];
		stats.speed = stat_array[3];
		stats.luck = stat_array[4];
	}
}