package game;

import game.ui.dialogue.DialogueBoxManager;
import game.ui.LevelText;
import game.ui.FadeInOut;
import game.Attack.Skill;
import game.Attack.CANCEL_SKILL_ID;
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
	DoSkill(skill_id: Int, targeted_positions: Array<Vector3i>);
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
	@:const var EMPTY_TOOTH_TEXTURE: CompressedTexture2D = GD.preload("res://VisualAssets/2D/EmptyTooth.png");
	@:const var TOOTH_TEXTURE: CompressedTexture2D = GD.preload("res://VisualAssets/2D/Tooth.png");
	@:const var TOOTH_SCENE: PackedScene = GD.preload("res://Objects/UI/Gameplay/Tooth.tscn");

	@:export var camera: Camera;
	@:export var level_data: DynamicLevelData;
	@:export var map: MapSprite;
	@:export var turn_manager: TurnManager;
	@:export var post_process: PostProcess;
	@:export var _2d: CanvasGroup;
	@:export var effect_manager: EffectManager;
	@:export var fade_in_out: FadeInOut;
	@:export var level_text: LevelText;
	@:export var dialogue_box_manager: DialogueBoxManager;
	@:export var gameplay_controls: Label;
	@:export var gameplay_controls_stairs: VBoxContainer;
	@:export var menu_controls: Label;

	@:export var health_bar: ColorRect;
	@:export var health_bar_padding: Control;
	@:export var health_bar_amount: Label;

	@:export var tooth_container: GridContainer;

	@:onready var character_animator: CharacterAnimator = untyped __gdscript__("$CharacterAnimator");
	@:onready var mesh_rotator: Node3D = untyped __gdscript__("$PlayerMeshRotator");
	@:onready var mesh_holder: Node3D = untyped __gdscript__("$PlayerMeshRotator/PlayerMeshHolder");
	@:onready var mesh_manipulator: Node3D = untyped __gdscript__("$PlayerMeshRotator/PlayerMeshHolder/PlayerMeshManipulator");
	@:onready var mesh: MeshInstance3D = untyped __gdscript__("$PlayerMeshRotator/PlayerMeshHolder/PlayerMeshManipulator/PlayerMesh");
	//@:onready var popup_maker: PopupMaker = untyped __gdscript__("$PlayerMeshRotator/PlayerMeshHolder/PopupMaker");
	@:onready var shadow: Sprite3D = untyped __gdscript__("$PlayerMeshRotator/PlayerMeshHolder/Shadow");

	var turn_speed_ratio = 1.0;
	var movement_cooldown: Float = 0.0;
	var queued_actions: Array<QueueableAction> = [];
	var last_moved_direction: Null<Direction> = null;
	
	var skills: Array<Int> = [0];
	var teeth: Int = 10;
	var max_teeth: Int = 10;
	var turns_until_next_tooth: Int = -1;

	var skill_list_menu: Null<SkillListMenu> = null;
	var target_select_manager: Null<TargetSelectManager> = null;

	var intro_outro_animation: Float = 1.0;
	var is_stairs_animation = false;
	var is_death_animation = false;

	var in_menu = false;
	var on_stairs = false;

	static final INPUT_BUFFER_SIZE = 2;
	static final GAME_SPEED = 7.5;

	public function manual_ready() {
		stats.id = 2;
		stats.speed = 3;

		set_direction(Right);

		refresh_health_bar();
		refresh_teeth();

		get_viewport().connect("size_changed", new Callable(this, "refresh_tooth_container_size"));
		refresh_tooth_container_size();
		//connect("tree_exiting", new Callable(this, "test"));
	}

	// function test() {
	// 	untyped __gdscript__("print_orphan_nodes()");
	// }

	// =====================================

	public override function set_tilemap_position(pos: Vector3i): Bool {
		final previous = tilemap_position;
		if(level_data.move_entity(stats.id, previous, pos)) {
			apply_position(pos);
			return true;
		}
		return false;
	}

	public override function get_speed(): Float {
		return stats.speed + 0.0001;
	}

	public override function process_turn() {
		turn_speed_ratio = default_turn_processing(character_animator, effect_manager, level_data, turn_manager, post_process, camera);
	}

	override function process_animation(ratio: Float): Void {
		// This function should remain empty...
	}

	override function on_successful_move(direction: Direction) {
		last_moved_direction = direction;
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

	override function get_skill_money() {
		return teeth;
	}

	override function take_skill_money(amount: Int) {
		teeth -= amount;
		refresh_teeth();
	}

	public override function on_damaged() {
		refresh_health_bar();
	}

	public override function kill() {
		stats.health = 0;
		refresh_health_bar();

		camera.shake();
		post_process.play_distort();

		is_death_animation = true;
		intro_outro_animation = 1.0;
	}

	// =====================================

	public function set_starting_position(pos: Vector3i): Bool {
		if(level_data.place_entity(stats.id, pos)) {
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

		final now_on_stairs = if(tilemap_position.z == 0) {
			final stairs = level_data.static_data().stairs_position;
			tilemap_position.x == stairs.x && tilemap_position.y == stairs.y;
		} else {
			false;
		}
		if(on_stairs != now_on_stairs) {
			on_stairs = now_on_stairs;
			refresh_gameplay_controls();
		}
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

	function check_reset_input() {
		if(Input.is_action_just_pressed("start") || Input.is_action_just_pressed("ok")) {
			WorldManager.reset();
			get_tree().change_scene_to_file("res://Title.tscn");
		}
	}

	override function _process(delta: Float): Void {
		if(intro_outro_animation > 0.0) {
			var update_animation = true;
			if(!is_stairs_animation) {
				if(fade_in_out.update_fade_in(delta)) {
					update_animation = false;
				}
			}

			final previous = intro_outro_animation;

			if(update_animation) {
				intro_outro_animation -= delta * (is_stairs_animation ? 2.0 : (is_death_animation ? 0.2 : 1.0));
				if(intro_outro_animation < 0.0) intro_outro_animation = 0.0;
			}

			if(is_death_animation) {
				final r = 1.0 - intro_outro_animation;
				if(r < 0.3) {
					final r = r / 0.3;
					mesh.rotation.x = r.cubicInOut() * Math.PI;
				} else {
					mesh.rotation.x = Math.PI;
				}

				if(r > 0.2) {
					final r = (r - 0.2) / 0.8;
					mesh.position = new Vector3(0, 3.0 * r.cubicOut(), 0);
				}

				if(previous > 0.7 && intro_outro_animation <= 0.7) {
					level_text.set_death_text();
				}

				if(intro_outro_animation >= 0.3) {
					check_reset_input();
				}

				popup_maker.update(delta);
			} else if(is_stairs_animation) {
				final r = 1.0 - intro_outro_animation;
				if(r < 0.3) {
					final r = r / 0.3;
					mesh.position = new Vector3(0, r.cubicOut() * 2.0, 0);
					mesh.rotation.z = r.quartOut() * Math.PI * -0.25;
				} else {
					final r = (r - 0.3) / 0.7;
					mesh.position = new Vector3(0, 2.0 + (r.cubicIn() * -2.2), 0);
					mesh.rotation.z = Math.PI * (-0.25 + r.cubicInOut() * 2.0);
				}

				if(r > 0.8) {
					final r = (r - 0.8) / 0.2;
					mesh_holder.scale = Vector3.ONE * (1.0 - r);
				}

				if(intro_outro_animation == 0.0) {
					// This will now go to `fade_in_out.update_fade_out`...
				}
			} else {
				final r = (1.0 - intro_outro_animation).cubicOut();
				mesh.position = new Vector3(0, 5.0 - (r * 5.0), 0);
				mesh.rotation.y = (1.0 - r) * 14.0;
			}

			return;
		} else if(is_stairs_animation) {
			if(!fade_in_out.update_fade_out(delta)) {
				WorldManager.next_floor();
				get_tree().change_scene_to_file("res://Main.tscn");
			}
			return;
		} else if(is_death_animation) {
			check_reset_input();
			popup_maker.update(delta);
			return;
		}

		popup_maker.update(delta);

		final can_input = !dialogue_box_manager.update(delta);

		if(target_select_manager != null) {
			final target_result = target_select_manager.update(delta, tilemap_position, level_data);
			if(target_result == 1) {
				final action = target_select_manager.get_queuable_action();
				if(action != null) {
					queued_actions.push(action);
				}

				remove_target_select_manager();
			} else if(target_result == 2) {
				remove_target_select_manager();
			}
		} else if(skill_list_menu != null) {
			update_skill_list();
		} else {
			if(can_input) {
				update_gameplay();
			}

			if(can_input && Input.is_action_just_pressed("skills")) {
				queued_actions = [];

				skill_list_menu = cast SKILL_LIST_MENU.instantiate();
				_2d.add_child(skill_list_menu);
				skill_list_menu.setup(skills, teeth);

				in_menu = true;
				refresh_gameplay_controls();
			}
		}

		// Refresh turn animations
		if(movement_cooldown > 0) {
			movement_cooldown -= delta * GAME_SPEED * turn_speed_ratio;
			if(movement_cooldown < 0) {
				movement_cooldown = 0;
			}
			refresh_movement_cooldown_animation();
			if(movement_cooldown == 0) {
				character_animator.end_animation();
			}
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
		final selected_skill_id = skill_list_menu.update(teeth);

		if(selected_skill_id == CANCEL_SKILL_ID) {
			remove_skill_list();

			in_menu = false;
			refresh_gameplay_controls();
		} else if(selected_skill_id != NULL_SKILL_ID) {
			remove_skill_list();

			target_select_manager = cast TARGET_SELECT_MANAGER.instantiate();
			add_child(target_select_manager);
			target_select_manager.setup(selected_skill_id, tilemap_position, look_direction, level_data);
		}
	}

	function remove_skill_list() {
		_2d.remove_child(skill_list_menu);
		skill_list_menu.queue_free();
		skill_list_menu = null;
	}

	function remove_target_select_manager() {
		in_menu = false;
		refresh_gameplay_controls();

		target_select_manager.cleanup();
		remove_child(target_select_manager);
		target_select_manager.queue_free();
		target_select_manager = null;
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
					process_turns(Move(next_direction));
				}

				last_moved_direction = next_direction;
				look_direction = next_direction;
			}
			case Jump: {
				if(on_stairs) {
					is_stairs_animation = true;
					intro_outro_animation = 1.0;

					gameplay_controls_stairs.visible = false;
					return;
				}

				final is_up = tilemap_position.z == 0;
				final next = new Vector3i(0, 0, is_up ? 1 : -1);
				if(level_data.tile_free(tilemap_position + next)) {
					process_turns(Jump(is_up));
				}

				last_moved_direction = null;
			}
			case BasicAttack(direction): {
				last_moved_direction = null;
				if(level_data.is_attackable_or_empty(tilemap_position + direction.as_vec3i())) {
					process_turns(BasicAttack(direction));
				}
			}
			case DoSkill(skill_id, targeted_positions): {
				last_moved_direction = null;

				process_turns(DoSkill(skill_id, targeted_positions));
				camera.shake();
			}
		}

		queued_actions.remove_at(0);
	}

	function process_turns(action: Action) {
		turn_manager.preprocess_turns();

		queued_turn_action = action;
		turn_manager.process_turns();
		character_animator.start_animation();

		movement_cooldown = 1;
		refresh_movement_cooldown_animation();
	}

	function refresh_movement_cooldown_animation() {
		character_animator.update_animation(movement_cooldown);
		turn_manager.process_animations(1.0 - movement_cooldown);
	}

	function refresh_gameplay_controls() {
		gameplay_controls.visible = !in_menu && !on_stairs;
		gameplay_controls_stairs.visible = !in_menu && on_stairs;
		menu_controls.visible = in_menu;
	}

	function refresh_health_bar() {
		health_bar_amount.text = Std.string(stats.health);

		final ratio = cast(stats.health, Float) / stats.max_health;
		if(ratio < 0.5) {
			health_bar_padding.size_flags_stretch_ratio = 1.0;
			health_bar.size_flags_stretch_ratio = ratio * 2.0;
		} else {
			health_bar_padding.size_flags_stretch_ratio = 1.0 - ((ratio - 0.5) * 2.0);
			health_bar.size_flags_stretch_ratio = 1.0;
		}
	}

	function refresh_teeth() {
		var count = tooth_container.get_child_count();
		while(count < max_teeth) {
			final tr = cast(TOOTH_SCENE.instantiate(), TextureRect);
			tr.texture = EMPTY_TOOTH_TEXTURE;
			tooth_container.add_child(tr);
			count = tooth_container.get_child_count();
		}
		while(count > max_teeth) {
			tooth_container.remove_child(tooth_container.get_child(tooth_container.get_child_count() - 1));
			count = tooth_container.get_child_count();
		}
		
		

		for(i in 0...count) {
			final tooth = cast(tooth_container.get_child(i), TextureRect);
			if(tooth != null) {
				tooth.texture = i < teeth ? TOOTH_TEXTURE : EMPTY_TOOTH_TEXTURE;
			}
		}
	}

	function refresh_tooth_container_size() {
		final new_size = DisplayServer.window_get_size();
		final size_ratio = (new Vector2(new_size.x, new_size.y) / new Vector2(1152, 648));
		final ratio = Math.max(size_ratio.x, size_ratio.y);
		tooth_container.set_custom_minimum_size(new Vector2(0, (Math.floor(max_teeth / 15) + 1) * 28 * ratio));
	}
}
