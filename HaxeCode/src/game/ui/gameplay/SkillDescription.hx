package game.ui.gameplay;

import game.Attack.Skill;
import godot.*;

class SkillDescription extends PanelContainer {
	@:onready var name_label: Label = untyped __gdscript__("$MarginContainer/VBoxContainer/HBoxContainer/NameLabel");
	@:onready var description_label: Label = untyped __gdscript__("$MarginContainer/VBoxContainer/HBoxContainer/Description");
	@:onready var power_label: Label = untyped __gdscript__("$MarginContainer/VBoxContainer/Stats/Power/PowerValue");
	@:onready var target_label: Label = untyped __gdscript__("$MarginContainer/VBoxContainer/Stats/Target/TargetValue");
	@:onready var range_label: Label = untyped __gdscript__("$MarginContainer/VBoxContainer/Stats/Range/RangeValue");

	public function set_skill(skill: Skill) {
		name_label.text = skill.name;
		description_label.text = "blablabla\nblabla";
		power_label.text = skill.min_power + "~" + skill.max_power;
		target_label.text = switch(skill.attack_type) {
			case BasicAttack: {
				"1";
			}
			case SurrondAttack: {
				"8";
			}
		}
		range_label.text = switch(skill.attack_type) {
			case BasicAttack: {
				"Next to You";
			}
			case SurrondAttack: {
				"Next to You";
			}
		}
	}
}
