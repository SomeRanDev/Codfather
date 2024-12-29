package game;

import game.CustomMap.EnemyCustomEntity;
import game.CustomMap.SignCustomEntity;
import game.CustomMap.CustomEntity;
import game.CustomMap.TypedDictionary;
import godot.*;
import GDScript as GD;

class WorldManager {
	public static var floor = 1;
	public static var floors_remaining = 4;
	public static var should_randomize = false;

	public static var no_more_floors = false;

	public static var custom_map: CustomMap = null;

	public static function next_floor() {
		go_to_new_floor();
		if(floors_remaining > 0) {
			floor += 1;
			floors_remaining -= 1;
			should_randomize = true;
		} else {
			no_more_floors = true;
		}
	}

	public static function reset() {
		floor = 1;
		floors_remaining = 4;
		should_randomize = false;
		no_more_floors = false;

		Stats.reset();
		StaticPlayerData.reset();
	}

	public static function go_to_tutorial() {
		custom_map = new CustomMap();
		custom_map.custom_map = GD.load("res://VisualAssets/CustomMaps/Tutorial.aseprite");
		custom_map.text = "Tutorial";
		custom_map.subtext = "(Thank god you're actually playing the tutorial.)";
		custom_map.custom_entities.set(100, SignCustomEntity.make("Welcome! Use the map on the left to navigate. Can you completely fill it out?"));
		custom_map.custom_entities.set(101, SignCustomEntity.make("An enemy appears! Get next to them then press the direction they are to attack them."));
		custom_map.custom_entities.set(102, SignCustomEntity.make("You can use a skill by pressing X. Skills consume shark teeth. Shark teeth are replenished over time."));
		custom_map.custom_entities.set(103, SignCustomEntity.make("Press Z to change your swimming layer. Use this to dodge the bubbles!"));
		custom_map.custom_entities.set(104, SignCustomEntity.make("Enemies with yellow indicators are FASTER! They will attack or move before you do. This can cause you to miss or die early."));
		custom_map.custom_entities.set(105, SignCustomEntity.make("Use the stairs to enter the next floor! Good luck!"));
		custom_map.custom_entities.set(106, EnemyCustomEntity.make(StarFish));
		custom_map.custom_entities.set(107, EnemyCustomEntity.make(CrabShooter));
		custom_map.custom_entities.set(108, EnemyCustomEntity.make(AlwaysFastTutorialFish));
	}

	public static function go_to_new_floor() {
		custom_map = null;
	}
}
