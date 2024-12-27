package game;

import game.Constants.JUMP_HEIGHT;
import game.data.Direction;

import godot.*;
import GDScript as GD;

class NPC extends TurnSlave {
	@:const var FAST_PARTICLES: PackedScene = GD.preload("res://Objects/Particles/FastParticles.tscn");

	@:onready var character_animator: CharacterAnimator = untyped __gdscript__("$CharacterAnimator");
	@:onready var mesh_rotator: Node3D = untyped __gdscript__("$MeshRotator");
	@:onready var mesh_holder: Node3D = untyped __gdscript__("$MeshRotator/MeshHolder");
	@:onready var mesh_manipulator: Node3D = untyped __gdscript__("$MeshRotator/MeshHolder/MeshManipulator");
	@:onready var mesh: MeshInstance3D = untyped __gdscript__("$MeshRotator/MeshHolder/MeshManipulator/Mesh");
	@:onready var shadow: Sprite3D = untyped __gdscript__("$MeshRotator/MeshHolder/Shadow");
	@:onready var tile_indicator: TileIndicator = untyped __gdscript__("$MeshRotator/TileIndicator");

	var move_particles: Null<GPUParticles3D> = null;

	var level_data: DynamicLevelData;
	var tilemap_position: Vector3i;

	var phase = 0;

	public function setup(level_data: DynamicLevelData) {
		this.level_data = level_data;

		stats.generate_id();
		stats.randomize();
	}

	public function set_starting_position(pos: Vector3i): Bool {
		if(level_data.place_entity(stats.id, pos)) {
			apply_position(pos);
			return true;
		}
		return false;
	}

	public function set_tilemap_position(pos: Vector3i): Bool {
		final previous = tilemap_position;
		if(level_data.move_entity(stats.id, previous, pos)) {
			apply_position(pos);
			return true;
		}
		return false;
	}

	function apply_position(pos: Vector3i) {
		tilemap_position = pos;
		position = new Vector3(pos.x, 0.5 + (pos.z == 1 ? JUMP_HEIGHT : 0), pos.y);
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

	override function process_turn() {
		if(Math.random() < 0.2) {
			final is_up = tilemap_position.z == 0;
			final next_position = tilemap_position + new Vector3i(0, 0, is_up ? 1 : -1);
			if(level_data.tile_free(next_position)) {
				if(set_tilemap_position(next_position)) {
					character_animator.animation = is_up ? GoUp : GoDown;
					return;
				}
			}
		}

		final direction: Direction = {
			switch(Math.round(phase / 2)) {
				case 0: Right;
				case 1: Down;
				case 2: Left;
				case 3: Up;
				case _: Up;
			}
		}

		character_animator.animation = Nothing;

		final next_position = tilemap_position + direction.as_vec3i();
		if(level_data.tile_free(next_position)) {
			if(set_tilemap_position(next_position)) {
				character_animator.animation = Move;
				mesh_rotator.rotation.y = direction.rotation();

				phase++;
				if(phase >= 8) { phase = 0; }
			}
		}
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
}