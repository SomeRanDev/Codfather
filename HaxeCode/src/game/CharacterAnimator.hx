package game;

import game.Constants.JUMP_HEIGHT;
import godot.*;

@:using(game.CharacterAnimator.CharacterAnimationHelper)
enum CharacterAnimation {
	Nothing;
	Move;
	GoUp;
	GoDown;
	Blocked;
	BlockedUp;
	BlockedDown;

	DirectionalAttack;
	SpinAttack;
}

class CharacterAnimationHelper {
	public static function is_move_like(self: CharacterAnimation): Bool {
		return switch(self) {
			case Move | GoUp | GoDown: true;
			case _: false;
		}
	}
}

class CharacterAnimator extends Node {
	@:export var mesh: MeshInstance3D;
	@:export var mesh_manipulator: Node3D;
	@:export var mesh_holder: Node3D;
	@:export var shadow: Sprite3D;
	@:export var tile_indicator: TileIndicator;

	@:export var default_mesh: Mesh;
	@:export var attack_mesh: Mesh;

	@:export var base_scale: Float = 1.0;

	public var is_up: Bool;

	public var animation: CharacterAnimation = Nothing;

	public function start_animation() {
		switch(animation) {
			case DirectionalAttack if(attack_mesh != null): mesh.mesh = attack_mesh;
			case _:
		}
	}

	public function update_animation(r: Float) {
		switch(animation) {
			case Nothing: {}
			case Move: refresh_move_animation(r);
			case GoUp: refresh_move_up_animation(r);
			case GoDown: refresh_move_down_animation(r);
			case Blocked: refresh_block_animation(r);
			case BlockedUp: refresh_block_up_animation(r);
			case BlockedDown: refresh_block_down_animation(r);
			case DirectionalAttack: refresh_attack_animation(r);
			case SpinAttack: refresh_spin_attack_animation(r);
		}
	}

	public function end_animation() {
		switch(animation) {
			case DirectionalAttack: mesh.mesh = default_mesh;
			case _:
		}
	}

	function back_and_forth(r: Float): Float {
		return if(r < 0.5) {
			r / 0.5;
		} else {
			1 - ((r - 0.5) / 0.5);
		}
	}

	function refresh_move_animation(r: Float) {
		final r2 = back_and_forth(r);
		mesh.scale = new Vector3(1 + r2, 1 - 0.5 * r2, 1) * base_scale;
		mesh_holder.position = new Vector3(1, 0, 0) * r;
		if(tile_indicator != null) {
			tile_indicator.set_animation(1.0 - r);
		}
	}

	function refresh_move_up_animation(r: Float) {
		final r2 = back_and_forth(r);
		//mesh.scale = new Vector3(1 - 0.5 * r2, 1 + r2, 1 - 0.5 * r2) * base_scale;
		mesh_manipulator.scale = new Vector3(1 + r2 * 0.3, 1, 1);
		mesh_holder.position = new Vector3(0, -JUMP_HEIGHT, 0) * r;
		mesh.rotation.z = Math.PI * -0.333 * r2;
		refresh_shadow_size(r);
	}

	function refresh_move_down_animation(r: Float) {
		final r2 = back_and_forth(r);
		//mesh.scale = new Vector3(1 - 0.5 * r2, 1 + r2, 1 - 0.5 * r2) * base_scale;
		mesh_manipulator.scale = new Vector3(1 + r2, 1 - 0.5 * r2, 1);
		mesh_holder.position = new Vector3(0, JUMP_HEIGHT, 0) * r;
		mesh.rotation.z = Math.PI * 0.333 * r2;
		refresh_shadow_size(r);
	}

	function refresh_block_animation(r: Float) { refresh_block_animation_with_offset(r, new Vector3(-0.5, 0, 0)); }
	function refresh_block_up_animation(r: Float) { refresh_block_animation_with_offset(r, new Vector3(0, 0.5, 0)); }
	function refresh_block_down_animation(r: Float) { refresh_block_animation_with_offset(r, new Vector3(0, -0.5, 0)); }

	function refresh_block_animation_with_offset(r: Float, offset: Vector3) {
		final r2 = if(r < 0.8) {
			r / 0.8;
		} else {
			1 - ((r - 0.8) / 0.2);
		}
		mesh_manipulator.position = offset * r;

		refresh_shadow_size(r);
	}

	function refresh_shadow_size(r: Float) {
		final r = if(is_up) {
			mesh_holder.position.y / -JUMP_HEIGHT;
		} else {
			1.0 - (mesh_holder.position.y / JUMP_HEIGHT);
		}
		final r2 = 1.0 - r;
		shadow.pixel_size = (0.01 + (0.01 * r2)) * 1.75;
		shadow.position.y = -(JUMP_HEIGHT + 0.48) + (r * JUMP_HEIGHT);
		shadow.modulate.a = ((1.0 - r) * 0.5);
		shadow.visible = r < 1.0 || is_up;
	}

	function refresh_attack_animation(r: Float) {
		final r = if(r < 0.8) {
			(r / 0.8) * 0.5;
		} else {
			((r - 0.8) / 0.2) * 0.5 + 0.5;
		}
		refresh_block_animation_with_offset(back_and_forth(r), new Vector3(-0.5, 0, 0));
	}

	function refresh_spin_attack_animation(r: Float) {
		final r = 1.0 - r;
		if(r < 0.1) {
			final r = r / 0.1;
			mesh.scale = new Vector3(1 + r, 1, 1) * base_scale;
			mesh_holder.rotation.y = Math.PI * 1.0;
		} else {
			final r2 = 1.0 - ((r - 0.1) / 0.9);
			mesh.scale = new Vector3(2, 1, 1) * base_scale;
			mesh_holder.rotation.y = Math.PI * 1.0 * r2.cubicOut();

			if(r > 0.6) {
				final r = (r - 0.6) / 0.4;
				mesh.scale = new Vector3(1 + (1.0 - r), 1, 1) * base_scale;
			}
		}
	}
}