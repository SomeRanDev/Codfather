package game;

import game.ui.LevelText;
import game.ui.dialogue.DialogueBoxManager;
import game.ui.FullScreenPanelContainer;

import godot.*;
import GDScript as GD;

class World extends Node3D {
	@:const var SIGN_SCENE: PackedScene = GD.preload("res://Objects/NPCs/Interactables/Sign.tscn");

	@:export var level_data: LevelData;
	@:export var dynamic_level_data: DynamicLevelData;
	@:export var tilemap: Tilemap;
	@:export var player: Player;
	@:export var map: MapSprite;
	@:export var turn_manager: TurnManager;
	@:export var ui_container: FullScreenPanelContainer;
	@:export var effect_manager: EffectManager;
	@:export var camera: Camera;
	@:export var dialogue_box_manager: DialogueBoxManager;
	@:export var level_text: LevelText;

	override function _ready(): Void {
		trace("Game start!!");

		ui_container.manual_ready();
		level_text.manual_ready();

		var world_changed = true;
		if(WorldManager.custom_map != null) {
			level_data.custom_map = WorldManager.custom_map;
			level_text.override_text(level_data.custom_map.text, level_data.custom_map.subtext);
		} else if(WorldManager.should_randomize) {
			level_data.randomize_noise();
			level_data.randomize_size(70, 100);
		} else {
			world_changed = false;
		}
		if(world_changed) {
			level_data.build_world();
			tilemap.build_world();
		}

		dynamic_level_data.manual_ready();
		map.manual_ready();
		player.manual_ready();
		
		setup_entities();

		map.set_top_left();

		camera.snap_to_target();
	}

	function setup_entities() {
		player.set_starting_position(level_data.player_start_position.to_vec3i(0));
		turn_manager.add_entity(player);

		final npc_scene = cast(GD.load("res://Objects/TestNPC.tscn"), PackedScene);
		for(npc_data in level_data.npcs) {
			switch(npc_data.kind) {
				case TestNPC: {
					var npc: NPC = cast npc_scene.instantiate();
					npc.setup(dynamic_level_data, turn_manager, effect_manager);
					turn_manager.add_entity(npc);
					add_child(npc);
		
					final p = npc_data.position;
					p.z = Godot.randi_range(0, 1);
					npc.set_starting_position(p);
					npc.refresh_speed_relation(player);
				}
				case Sign(text): {
					final sign: Sign = cast SIGN_SCENE.instantiate();
					sign.sign_text = text;

					sign.setup(dynamic_level_data, turn_manager, effect_manager);
					sign.setup_sign(dialogue_box_manager);
					turn_manager.add_entity(sign);
					add_child(sign);

					sign.set_starting_position(npc_data.position);
				}
				case Enemy(enemy_type): {
					final scene_path = switch(enemy_type) {
						case Crab: "res://Objects/NPCs/Crab.tscn";
					}

					final enemy: NPC = cast GD.load(scene_path).instantiate();

					enemy.setup(dynamic_level_data, turn_manager, effect_manager);
					turn_manager.add_entity(enemy);
					add_child(enemy);

					enemy.set_starting_position(npc_data.position);
				}
			}
		}
	}
}
