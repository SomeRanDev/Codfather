package game;

import godot.*;
import GDScript as GD;

class World extends Node3D {
	@:export var level_data: LevelData;
	@:export var dynamic_level_data: DynamicLevelData;
	@:export var tilemap: Tilemap;
	@:export var player: Player;
	@:export var map: MapSprite;
	@:export var turn_manager: TurnManager;

	override function _ready(): Void {
		var rebuild_level = false;

		if(rebuild_level) {
			level_data.build_world();
			tilemap.build_world();
		}

		dynamic_level_data.manual_ready();
		map.manual_ready();
		player.manual_ready();
		
		setup_entities();

		map.set_top_left();
	}

	function setup_entities() {
		player.set_starting_position(level_data.player_start_position.to_vec3i(0));
		turn_manager.add_entity(player);

		final npc_scene = cast(GD.load("res://Objects/TestNPC.tscn"), PackedScene);
		for(npc_position in level_data.test_npcs) {
			var npc: NPC = cast npc_scene.instantiate();
			npc.setup(dynamic_level_data);
			npc.set_starting_position(npc_position.to_vec3i(Godot.randi_range(0, 1)));
			turn_manager.add_entity(npc);
			add_child(npc);
		}
	}
}
