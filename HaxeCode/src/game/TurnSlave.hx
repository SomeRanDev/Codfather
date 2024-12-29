package game;

import game.AudioPlayer.MyAudioPlayer;
//import game.Constants.PROJECTILE_SCENE;
import game.npc.NPCBehaviorProjectile;
import game.Attack.BASIC_SKILL_ID;
import game.data.Direction;
import game.Attack.Skill;
import game.data.Action;
import game.Attack.ALL_SKILLS;
import game.effects.text_popup.PopupMaker;

import godot.*;
import GDScript as GD;

enum TakeAttackResult {
	Interaction;
	Nothing;
	Damaged;
	Killed;
}

class TurnSlave extends Node3D {
	@:export var popup_maker: PopupMaker;

	var world: World;

	var tilemap_position: Vector3i;
	var queued_turn_action: Action = Nothing;
	var look_direction: Direction = Right;

	public var stats(default, null) = new Stats();

	public function set_world(world: World) {
		this.world = world;
	}

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
		character_animator: CharacterAnimator, effect_manager: EffectManager, level_data: DynamicLevelData, turn_manager: TurnManager,
		post_process: Null<PostProcess>, camera: Null<Camera>,
	): Float {
		character_animator.animation = Nothing;

		if(queued_turn_action == Nothing) {
			return 1.0;
		}

		var turn_speed_ratio = 1.0;

		switch(queued_turn_action) {
			case Suicide: {
				kill();
			}
			case Move(direction): {
				final next_tile = tilemap_position + direction.as_vec3i();
				if(level_data.tile_free(next_tile) && set_tilemap_position(next_tile)) {
					on_successful_move(direction);

					character_animator.animation = Move;
					if(post_process != null) {
						MyAudioPlayer.play_footstep();
					}
				} else {
					character_animator.animation = Blocked;

					popup_maker.popup("Blocked!");
					if(post_process != null) {
						post_process.play_distort();
						MyAudioPlayer.blocked.play();
					}
				}

				set_direction(direction);
			}
			case Jump(is_up): {
				final next = new Vector3i(0, 0, is_up ? 1 : -1);
				final next_tile = tilemap_position + next;
				if(level_data.tile_free(next_tile) && set_tilemap_position(next_tile)) {
					character_animator.animation = is_up ? GoUp : GoDown;
					if(post_process != null) {
						if(is_up) MyAudioPlayer.go_up.play();
						else MyAudioPlayer.go_down.play();
					}
				} else {
					character_animator.animation = is_up ? BlockedUp : BlockedDown;

					popup_maker.popup("Blocked!");
					if(post_process != null) {
						post_process.play_distort();
						MyAudioPlayer.blocked.play();
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
					switch(hit_entity_with_skill(entity, BASIC_SKILL_ID, effect_manager, camera)) {
						case Killed if(post_process != null): {
							heal_self_by(4);
						}
						case _:
					}
				} else {
					popup_maker.popup("Missed!");
					if(post_process != null) {
						post_process.play_distort();
						MyAudioPlayer.attack1.play();
					}
				}
			}
			case ProjectileAttack(direction, skill_id): {
				final attack_position = tilemap_position + direction.as_vec3i();
				final entity = level_data.get_entity(attack_position);

				character_animator.animation = Move;
				set_direction(direction);

				if(entity != null) {
					switch(entity.take_attack(this, skill_id)) {
						case Interaction: {}
						case Nothing: {}
						case Damaged: {
							effect_manager.add_blood_particles(entity.position);
							MyAudioPlayer.special_attack.play();
						}
						case Killed: {
							MyAudioPlayer.special_attack.play();
							effect_manager.add_bone_particles(entity.position, 5.0);
							effect_manager.add_blood_particles(entity.position, 10.0);
							if(camera != null) camera.shake();
						}
					}

					kill();
				}
			}
			case DoSkill(skill_id, targeted_positions): {
				final skill = Skill.get_skill(skill_id);
				if(skill.get_real_cost() > get_skill_money()) {
					popup_maker.popup("Not enough teeth!");
				} else {
					take_skill_money(skill.get_real_cost());

					if(skill.healing > 0) {
						heal_self(skill_id);
					}

					for(position in targeted_positions) {
						if(position == tilemap_position) {
							continue;
						}

						final p = position;
						if(skill.is_projectile()) {
							if(level_data.is_attackable_or_empty(p)) {
								if(level_data.is_attackable(p)) {
									final entity = level_data.get_entity(p);
									if(entity != null) hit_entity_with_skill(entity, skill_id, effect_manager, camera);
								} else {
									final d = get_direction_from_offset(p - tilemap_position);
									if(d != null) {
										spawn_projectile(p, skill_id, d, level_data, turn_manager, effect_manager, world);
									}
								}
							}
						} else {
							final entity = level_data.get_entity(p);
							if(entity != null) hit_entity_with_skill(entity, skill_id, effect_manager, camera);
						}
					}

					if(post_process != null) {
						MyAudioPlayer.special_attack.play();
					}
					character_animator.animation = switch(skill.attack_type) {
						case SurrondAttack: SpinAttack;
						case Self: Nothing;
						case _: DirectionalAttack;
					};
					if(skill.attack_type == SurrondAttack) {
						set_direction(look_direction.reverse());
					}
					turn_speed_ratio = 0.75;
				}
			}
			case Nothing: {}
		}

		queued_turn_action = Nothing;

		return turn_speed_ratio;
	}

	function get_direction_from_offset(offset: Vector3i): Null<Direction> {
		return if(offset.x == 0) {
			if(offset.y == -1) Up;
			else if(offset.y == 1) Down;
			else null;
		} else if(offset.y == 0) {
			if(offset.x == -1) Left;
			else if(offset.x == 1) Right;
			else null;
		} else null;
	}

	function hit_entity_with_skill(entity: TurnSlave, skill_id: Int, effect_manager: EffectManager, camera: Null<Camera>) {
		final result = entity.take_attack(this, skill_id);
		switch(result) {
			case Interaction: {}
			case Nothing: popup_maker.popup("Failed!");
			case Damaged: {
				effect_manager.add_blood_particles(entity.position);
			}
			case Killed: {
				effect_manager.add_bone_particles(entity.position, 5.0);
				effect_manager.add_blood_particles(entity.position, 10.0);
				if(camera != null) camera.shake();
			}
		}
		return result;
	}

	function spawn_projectile(
		position: Vector3i, skill_id: Int, direction: Direction,
		dynamic_level_data: DynamicLevelData, turn_manager: TurnManager, effect_manager: EffectManager, world: World
	) {
		final projectile: NPC = cast GD.load("res://Objects/NPCs/Projectile.tscn").instantiate();
		projectile.stats.speed = 999 + projectile.stats.id;

		final projectile_behavior = cast(@:privateAccess projectile.behavior, NPCBehaviorProjectile);
		if(projectile_behavior != null) {
			projectile_behavior.direction = direction;
		}

		projectile.setup(dynamic_level_data, turn_manager, effect_manager);
		turn_manager.queue_add_entity(projectile);
		world.add_child(projectile);
		projectile.is_projectile = true;

		projectile.set_starting_position(position);
		projectile.set_is_faster_than_player(true);
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
			if(stats.health <= 0) {
				kill();
				killed = true;
			} else {
				on_damaged();
			}
		}

		return killed ? Killed : (damage > 0 ? Damaged : Nothing);
	}

	public function heal_self(skill_id: Int) {
		final skill = Skill.get_skill(skill_id);
		final heal = skill.healing;
		heal_self_by(heal);
	}

	function heal_self_by(amount: Int) {
		if(amount > 0) {
			final previous_health = stats.health;
			stats.health += amount;
			if(stats.health >= stats.max_health) {
				stats.health = stats.max_health;
			}

			popup_maker.popup_green(Std.string(stats.health - previous_health));
		}
	}

	public function on_damaged() {
	}

	public function kill() {
	}
}