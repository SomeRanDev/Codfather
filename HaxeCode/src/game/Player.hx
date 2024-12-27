package game;

import game.ui.target_select.TargetSelectManager;
import game.Attack.NULL_SKILL_ID;
import game.ui.gameplay.SkillListMenu;
import game.ui.gameplay.SkillDescription;
import game.ui.gameplay.SkillList;
import game.Constants.JUMP_HEIGHT;
import game.CharacterAnimator.CharacterAnimation;
import game.effects.text_popup.PopupMaker;
import game.data.Action;
import game.data.Direction;

import godot.*;
import GDScript as GD;

@:using(game.Player.QueueableActionHelpers)
enum QueueableAction {
	Move(direction: Direction);
	Jump;
	BasicAttack(direction: Direction);
}

class QueueableActionHelpers {
	public static inline function is_move(self: QueueableAction, direction: Direction): Bool {
		return switch(self) {
			case Move(d): direction == d;
			case _: false;
		}
	}
}

class Player extends TurnSlave {
	@:const var SKILL_LIST_MENU: PackedScene = GD.preload("res://Objects/UI/Gameplay/SkillListMenu.tscn");
	@:const var TARGET_SELECT_MANAGER: PackedScene = GD.preload("res://Objects/UI/Gameplay/TargetSelectManager.tscn");

	@:export var level_data: DynamicLevelData;
	@:export var map: MapSprite;
	@:export var turn_manager: TurnManager;
	@:export var post_process: PostProcess;
	@:export var _2d: CanvasGroup;

	@:onready var character_animator: CharacterAnimator = untyped __gdscript__("$CharacterAnimator");
	@:onready var mesh_rotator: Node3D = untyped __gdscript__("$PlayerMeshRotator");
	@:onready var mesh_holder: Node3D = untyped __gdscript__("$PlayerMeshRotator/PlayerMeshHolder");
	@:onready var mesh: MeshInstance3D = untyped __gdscript__("$PlayerMeshRotator/PlayerMeshHolder/PlayerMesh");
	//@:onready var popup_maker: PopupMaker = untyped __gdscript__("$PlayerMeshRotator/PlayerMeshHolder/PopupMaker");
	@:onready var shadow: Sprite3D = untyped __gdscript__("$PlayerMeshRotator/PlayerMeshHolder/Shadow");

	var tilemap_position: Vector3i;

	var movement_cooldown: Float = 0.0;
	var queued_actions: Array<QueueableAction> = [];
	var last_moved_direction: Null<Direction> = null;
	var look_direction: Direction = Right;

	var queued_turn_action: Action = Nothing;
	
	var skills: Array<Int> = [0];

	var skill_list_menu: Null<SkillListMenu> = null;
	var target_select_manager: Null<TargetSelectManager> = null;

	static final INPUT_BUFFER_SIZE = 2;
	static final GAME_SPEED = 7.5;

	public function manual_ready() {
		stats.id = 2;
		stats.speed = 3;
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
		position = new Vector3(pos.x, 0.5 + (pos.z == 1 ? JUMP_HEIGHT : 0.0), pos.y);
		map.set_player_position(tilemap_position);
		character_animator.is_up = pos.z == 1;
	}

	function can_add_to_input_queue(direction: Direction): Bool {
		final len = queued_actions.length;
		if(len > 0) {
			if(queued_actions[len - 1].is_move(direction)) {
				return false;
			}
		}
		if(len > 0) {
			if(queued_actions[0].is_move(direction)) {
				return false;
			}
		}
		if(movement_cooldown <= 0) {
			return true;
		}
		if(len == 0 && last_moved_direction != direction) {
			return true;
		}
		if(len > 0) {
			if(!queued_actions[0].is_move(direction)) {
				return true;
			}
		}
		return false;
	}

	function no_cooldown_and_queued_movement(): Bool {
		return movement_cooldown <= 0 && queued_actions.length == 0;
	}

	/**
		Called when an arrow key is pressed this frame.
	**/
	function on_direction_pressed(direction: Direction) {
		if(level_data.is_attackable(tilemap_position + direction.as_vec3i())) {
			queued_actions = [BasicAttack(direction)];
		} else if(can_add_to_input_queue(direction)) {
			queued_actions.push_circular(Move(direction), INPUT_BUFFER_SIZE);
		}
	}

	override function _process(delta: Float): Void {
		popup_maker.update(delta);

		if(target_select_manager != null) {
			if(target_select_manager.update(delta, tilemap_position, level_data)) {
				final action = target_select_manager.get_queuable_action();
				if(action != null) {
					queued_actions.push(action);
				}

				target_select_manager.cleanup();
				remove_child(target_select_manager);
				target_select_manager.queue_free();
				target_select_manager = null;
			}
		} else if(skill_list_menu != null) {
			update_skill_list();
		} else {
			update_gameplay();

			if(Input.is_action_just_pressed("enter")) {
				queued_actions = [];

				skill_list_menu = cast SKILL_LIST_MENU.instantiate();
				_2d.add_child(skill_list_menu);
				skill_list_menu.setup(skills);
			}
		}

		// Refresh turn animations
		if(movement_cooldown > 0) {
			movement_cooldown -= delta * GAME_SPEED;
			if (movement_cooldown < 0) movement_cooldown = 0;
			refresh_movement_cooldown_animation();
			return;
		}

		do_next_action();
	}

	function update_gameplay() {
		var movement_pressed = new Vector2i(0, 0);
		if (Input.is_action_pressed("up"))
			movement_pressed.y -= 1;
		if (Input.is_action_pressed("down"))
			movement_pressed.y += 1;
		if (Input.is_action_pressed("left"))
			movement_pressed.x -= 1;
		if (Input.is_action_pressed("right"))
			movement_pressed.x += 1;

		var movement_just_pressed = new Vector2i(0, 0);
		if (Input.is_action_just_pressed("up"))
			movement_just_pressed.y -= 1;
		if (Input.is_action_just_pressed("down"))
			movement_just_pressed.y += 1;
		if (Input.is_action_just_pressed("left"))
			movement_just_pressed.x -= 1;
		if (Input.is_action_just_pressed("right"))
			movement_just_pressed.x += 1;

		if(movement_just_pressed.y == -1) {
			on_direction_pressed(Up);
		} else if(movement_pressed.y == -1 && no_cooldown_and_queued_movement()) {
			queued_actions.push(Move(Up));
		}

		if(movement_just_pressed.y == 1) {
			on_direction_pressed(Down);
		} else if(movement_pressed.y == 1 && no_cooldown_and_queued_movement()) {
			queued_actions.push(Move(Down));
		}

		if(movement_just_pressed.x == -1) {
			on_direction_pressed(Left);
		} else if(movement_pressed.x == -1 && no_cooldown_and_queued_movement()) {
			queued_actions.push(Move(Left));
		}

		if(movement_just_pressed.x == 1) {
			on_direction_pressed(Right);
		} else if(movement_pressed.x == 1 && no_cooldown_and_queued_movement()) {
			queued_actions.push(Move(Right));
		}

		if(Input.is_action_just_pressed("jump")) {
			queued_actions.push(Jump);
		}
	}

	function update_skill_list() {
		final selected_skill_id = skill_list_menu.update();
		if(selected_skill_id != NULL_SKILL_ID) {
			_2d.remove_child(skill_list_menu);
			skill_list_menu.queue_free();
			skill_list_menu = null;

			target_select_manager = cast TARGET_SELECT_MANAGER.instantiate();
			add_child(target_select_manager);
			target_select_manager.setup(selected_skill_id, tilemap_position, look_direction, level_data);
		}
	}

	function do_next_action() {
		// No actions to process...
		if(queued_actions.length == 0) {
			return;
		}

		final next_action = queued_actions[0];

		switch(next_action) {
			case Move(next_direction): {
				if(level_data.tile_free(tilemap_position + next_direction.as_vec3i())) {
					queued_turn_action = Move(next_direction);
					turn_manager.process_turns();

					movement_cooldown = 1;
					refresh_movement_cooldown_animation();
				}

				last_moved_direction = next_direction;
				look_direction = next_direction;
			}
			case Jump: {
				final is_up = tilemap_position.z == 0;
				final next = new Vector3i(0, 0, is_up ? 1 : -1);
				if(level_data.tile_free(tilemap_position + next)) {
					queued_turn_action = Jump(is_up);
					turn_manager.process_turns();

					movement_cooldown = 1;
					refresh_movement_cooldown_animation();
				}

				last_moved_direction = null;
			}
			case BasicAttack(direction): {
				last_moved_direction = null;
				if(level_data.is_attackable_or_empty(tilemap_position + direction.as_vec3i())) {
					queued_turn_action = BasicAttack(direction);
					turn_manager.process_turns();

					movement_cooldown = 1;
					refresh_movement_cooldown_animation();
				}
			}
		}

		queued_actions.remove_at(0);
	}

	function refresh_movement_cooldown_animation() {
		character_animator.update_animation(movement_cooldown);
		turn_manager.process_animations(1.0 - movement_cooldown);
	}

	override function process_turn() {
		character_animator.animation = Nothing;

		if(queued_turn_action == Nothing) {
			return;
		}

		switch(queued_turn_action) {
			case Move(direction): {
				final next_tile = tilemap_position + direction.as_vec3i();
				if(level_data.tile_free(next_tile) && set_tilemap_position(next_tile)) {
					last_moved_direction = direction;

					character_animator.animation = Move;
				} else {
					character_animator.animation = Blocked;

					popup_maker.popup("Blocked!");
					post_process.play_distort();
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
					post_process.play_distort();
				}
			}
			case BasicAttack(direction): {
				final attack_position = tilemap_position + direction.as_vec3i();
				final entity = level_data.get_entity(attack_position);

				character_animator.animation = DirectionalAttack;

				set_direction(direction);

				if(entity != null) {
					if(entity.take_attack(this, -1)) {
					} else {
						popup_maker.popup("Failed!");
					}
				} else {
					popup_maker.popup("Missed!");
					post_process.play_distort();
				}
			}
			case Nothing: {}
		}

		queued_turn_action = Nothing;
	}

	override function process_animation(ratio: Float): Void {
		// This function should remain empty...
	}

	function set_direction(direction: Direction) {
		look_direction = direction;
		mesh_rotator.rotation.y = direction.rotation();
	}
}
