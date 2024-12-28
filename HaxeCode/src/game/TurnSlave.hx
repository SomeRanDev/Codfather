package game;

import game.Attack.BASIC_SKILL_ID;
import game.data.Direction;
import game.Attack.Skill;
import game.data.Action;
import game.Attack.ALL_SKILLS;
import game.effects.text_popup.PopupMaker;

import godot.*;

enum TakeAttackResult {
	Nothing;
	Damaged;
	Killed;
}

class TurnSlave extends Node3D {
	@:export var popup_maker: PopupMaker;

	var tilemap_position: Vector3i;
	var queued_turn_action: Action = Nothing;
	var look_direction: Direction = Right;

	public var stats(default, null) = new Stats();

	public function get_speed(): Float {
		return stats.speed;
	}

	public function preprocess_turn() {
	}

	public function process_turn() {
	}

	public function process_animation(ratio: Float): Void {
	}

	public function set_tilemap_position(pos: Vector3i): Bool {
		return false;
	}

	function get_skill_money() {
		return 9999;
	}

	function take_skill_money(amount: Int) {
	}

	function set_direction(direction: Direction) {
	}

	function on_successful_move(direction: Direction) {
	}

	public function default_turn_processing(
		character_animator: CharacterAnimator, effect_manager: EffectManager, level_data: DynamicLevelData,
		post_process: Null<PostProcess>, camera: Null<Camera>,
	): Float {
		character_animator.animation = Nothing;

		if(queued_turn_action == Nothing) {
			return 1.0;
		}

		var turn_speed_ratio = 1.0;

		switch(queued_turn_action) {
			case Move(direction): {
				final next_tile = tilemap_position + direction.as_vec3i();
				if(level_data.tile_free(next_tile) && set_tilemap_position(next_tile)) {
					on_successful_move(direction);

					character_animator.animation = Move;
				} else {
					character_animator.animation = Blocked;

					popup_maker.popup("Blocked!");
					if(post_process != null) {
						post_process.play_distort();
					}
				}

				set_direction(direction);
			}
			case Jump(is_up): {
				final next = new Vector3i(0, 0, is_up ? 1 : -1);
				final next_tile = tilemap_position + next;
				if(level_data.tile_free(next_tile) && set_tilemap_position(next_tile)) {
					character_animator.animation = is_up ? GoUp : GoDown;
				} else {
					character_animator.animation = is_up ? BlockedUp : BlockedDown;

					popup_maker.popup("Blocked!");
					if(post_process != null) {
						post_process.play_distort();
					}
				}
			}
			case BasicAttack(direction): {
				final attack_position = tilemap_position + direction.as_vec3i();
				final entity = level_data.get_entity(attack_position);

				character_animator.animation = DirectionalAttack;
				turn_speed_ratio = 0.75;

				set_direction(direction);

				if(entity != null) {
					switch(entity.take_attack(this, BASIC_SKILL_ID)) {
						case Nothing: popup_maker.popup("Failed!");
						case Damaged: effect_manager.add_blood_particles(entity.position);
						case Killed: {
							effect_manager.add_bone_particles(entity.position, 5.0);
							effect_manager.add_blood_particles(entity.position, 10.0);
							if(camera != null) camera.shake();
						}
					}
				} else {
					popup_maker.popup("Missed!");
					if(post_process != null) {
						post_process.play_distort();
					}
				}
			}
			case DoSkill(skill_id, targeted_positions): {
				final skill = Skill.get_skill(skill_id);
				if(skill.get_real_cost() > get_skill_money()) {
					popup_maker.popup("Not enough teeth!");
				} else {
					take_skill_money(skill.get_real_cost());

					for(position in targeted_positions) {
						final entity = level_data.get_entity(position);
						if(entity != null) {
							switch(entity.take_attack(this, skill_id)) {
								case Nothing: popup_maker.popup("Failed!");
								case Damaged: effect_manager.add_blood_particles(entity.position);
								case Killed: {
									effect_manager.add_bone_particles(entity.position, 5.0);
									effect_manager.add_blood_particles(entity.position, 10.0);
									if(camera != null) camera.shake();
								}
							}
						}
					}

					set_direction(look_direction.reverse());
					character_animator.animation = SpinAttack;
					turn_speed_ratio = 0.75;
				}
			}
			case Nothing: {}
		}

		queued_turn_action = Nothing;

		return turn_speed_ratio;
	}

	public function take_attack(attacker: TurnSlave, skill_id: Int): TakeAttackResult {
		var damage: Int = 0;

		final skill = Skill.get_skill(skill_id);
		final ratio = stats.tough == 0 ? 1 : (attacker.stats.power / stats.tough);
		final power = Godot.randf_range(skill.min_power, skill.max_power);
		damage = Math.floor(Math.max(ratio * power, 1));

		var killed = false;
		if(damage > 0) {
			popup_maker.popup(Std.string(damage));

			stats.health -= damage;
			if(stats.health < 0) {
				kill();
				killed = true;
			} else {
				on_damaged();
			}
		}

		return killed ? Killed : (damage > 0 ? Damaged : Nothing);
	}

	public function on_damaged() {
	}

	public function kill() {
	}
}