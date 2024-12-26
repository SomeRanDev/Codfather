package game.ui.gameplay;

import game.Attack.ALL_SKILLS;

import godot.*;
import GDScript as GD;

class SkillList extends PanelContainer {
	@:const var ITEM_SCENE: PackedScene = GD.preload("res://Objects/UI/Gameplay/SkillListItem.tscn");

	@:onready var items_container: VBoxContainer = untyped __gdscript__("$MarginContainer/ItemContainer");

	var items: Array<SkillListItem> = [];

	var separators: Array<ColorRect> = [];
	var pooled_separators: Array<ColorRect> = [];

	var current_index = 0;

	public function setup(skills: Array<Int>) {
		while(items.length > 0) {
			items_container.remove_child(items[0]);
			items[0].queue_free();
			items.remove_first();
		}
		while(separators.length > 0) {
			items_container.remove_child(separators[separators.length - 1]);
			pooled_separators.push(separators.pop());
		}

		final attack_item: SkillListItem = cast ITEM_SCENE.instantiate();
		items_container.add_child(attack_item);
		items.push(attack_item);
		attack_item.setup("Chomp", -1);

		for(skill in skills) {
			final separator = if(pooled_separators.length > 0) {
				pooled_separators.pop();
			} else {
				final c = new ColorRect();
				c.color = Color.DARK_GRAY;
				c.set_custom_minimum_size(new Vector2(0, 2));
				c;
			}
			items_container.add_child(separator);
			separators.push(separator);

			final item: SkillListItem = cast ITEM_SCENE.instantiate();
			items_container.add_child(item);
			items.push(item);

			final skill_data = ALL_SKILLS[skill];
			item.setup(skill_data.name, skill);
			item.set_selected(false);
		}

		current_index = 0;
		attack_item.set_selected(true);
	}

	public function update(): Int {
		var move_input = 0;
		if (Input.is_action_just_pressed("up"))
			move_input -= 1;
		if (Input.is_action_just_pressed("down"))
			move_input += 1;
	
		if(move_input == -1) {
			items[current_index].set_selected(false);

			current_index--;
			if(current_index < 0) current_index = items.length - 1;
			items[current_index].set_selected(true);

			return items[current_index].skill_id;
		} else if(move_input == 1) {
			items[current_index].set_selected(false);

			current_index++;
			if(current_index >= items.length) current_index = 0;
			items[current_index].set_selected(true);

			return items[current_index].skill_id;
		}

		return -2;
	}
}