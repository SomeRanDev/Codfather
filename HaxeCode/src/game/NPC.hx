package game;

import game.effects.Exclamation;
import game.npc.NPCBehaviorBase;
import game.Constants.JUMP_HEIGHT;
import game.data.Direction;

import godot.*;
import GDScript as GD;

class NPC extends TurnSlave {
	@:const var FAST_PARTICLES: PackedScene = GD.preload("res://Objects/Particles/FastParticles.tscn");

	@:export var behavior: NPCBehaviorBase;

	@:onready var character_animator: CharacterAnimator = untyped __gdscript__("$CharacterAnimator");
	@:onready var mesh_rotator: Node3D = untyped __gdscript__("$MeshRotator");
	@:onready var mesh_holder: Node3D = untyped __gdscript__("$MeshRotator/MeshHolder");
	@:onready var mesh_manipulator: Node3D = untyped __gdscript__("$MeshRotator/MeshHolder/MeshManipulator");
	@:onready var mesh: MeshInstance3D = untyped __gdscript__("$MeshRotator/MeshHolder/MeshManipulator/Mesh");
	@:onready var shadow: Sprite3D = untyped __gdscript__("$MeshRotator/MeshHolder/Shadow");
	@:onready var exclamation: Exclamation = untyped __gdscript__("$MeshRotator/MeshHolder/Exclamation");
	@:onready var tile_indicator: TileIndicator = untyped __gdscript__("$MeshRotator/TileIndicator");

	var move_particles: Null<GPUParticles3D> = null;

	var level_data: DynamicLevelData;
	var turn_manager: TurnManager;
	var effect_manager: EffectManager;

	var offset_y: Float = 0.5;

	public function setup(level_data: DynamicLevelData, turn_manager: TurnManager, effect_manager: EffectManager) {
		this.level_data = level_data;
		this.turn_manager = turn_manager;
		this.effect_manager = effect_manager;

		stats.generate_id();
		stats.randomize();

		stats.power = 1;
		stats.max_health = 5;
		stats.health = 5;
	}

	public function set_starting_position(pos: Vector3i): Bool {
		if(level_data.place_entity(stats.id, pos)) {
			apply_position(pos);
			character_animator.setup_shadow(pos.z == 1);
			return true;
		}
		return false;
	}

	public override function set_tilemap_position(pos: Vector3i): Bool {
		final previous = tilemap_position;
		if(level_data.move_entity(stats.id, previous, pos)) {
			apply_position(pos);
			return true;
		}
		return false;
	}

	override function set_direction(direction: Direction) {
		look_direction = direction;
		mesh_rotator.rotation.y = direction.rotation();

		mesh_manipulator.rotation_degrees.x = switch(direction) {
			case Left: -30.0;
			case Right: 30.0;
			case _: 0.0;
		}
	}

	function apply_position(pos: Vector3i) {
		tilemap_position = pos;
		position = new Vector3(pos.x, offset_y + (pos.z == 1 ? JUMP_HEIGHT : 0), pos.y);
		character_animator.is_up = pos.z == 1;
	}

	public function refresh_speed_relation(player: Player) {
		final is_fast = stats.speed > player.stats.speed;
		show_speed_particles(is_fast);
		tile_indicator.set_fast(is_fast);

		for(i in 0...mesh.mesh.get_surface_count()) {
			final m = if(mesh.get_surface_override_material(i) == null) {
				final m = mesh.mesh.surface_get_material(i).duplicate();
				mesh.set_surface_override_material(i, cast(m, Material));
				m;
			} else {
				mesh.get_surface_override_material(i);
			}
			final m = cast(m, ShaderMaterial);
			if(m != null) {
				m.set_shader_parameter("is_fast", is_fast);
			}
		}
	}

	function show_speed_particles(show: Bool) {
		if(show && move_particles == null) {
			move_particles = cast FAST_PARTICLES.instantiate();
			mesh.add_child(move_particles);
		} else if(!show && move_particles != null) {
			mesh.remove_child(move_particles);
			move_particles.queue_free();
			move_particles = null;
		}
	}

	override function preprocess_turn() {
		if(behavior != null) {
			queued_turn_action = behavior.decide(this, level_data);
		}
	}

	override function process_turn() {
		default_turn_processing(character_animator, effect_manager, level_data, null, null);
	}

	override function process_animation(ratio: Float) {
		character_animator.update_animation(1.0 - ratio);

		if(move_particles != null && character_animator.animation.is_move_like()) {
			if(ratio == 1.0) {
				move_particles.emitting = false;
			} else {
				move_particles.emitting = true;
			}
		}
	}

	override function _process(delta: Float) {
		popup_maker.update(delta);
	}

	public override function kill() {
		popup_maker.detatch_and_delete_when_possible();

		level_data.remove_id(stats.id, tilemap_position);
		turn_manager.remove_entity(this);
		queue_free();
	}

	public function start_exclamation() {
		exclamation.start_effect();
	}
}