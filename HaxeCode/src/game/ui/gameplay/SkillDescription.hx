package game.ui.gameplay;

import game.Attack.Skill;
import godot.*;

class SkillDescription extends PanelContainer {
	@:onready var name_label: Label = untyped __gdscript__("$MarginContainer/VBoxContainer/HBoxContainer/NameLabel");
	@:onready var description_label: Label = untyped __gdscript__("$MarginContainer/VBoxContainer/HBoxContainer/Description");
	@:onready var power_label: Label = untyped __gdscript__("$MarginContainer/VBoxContainer/Stats/Power/PowerValue");
	@:onready var cost_label: Label = untyped __gdscript__("$MarginContainer/VBoxContainer/Stats/Cost/CostValue");
	@:onready var target_label: Label = untyped __gdscript__("$MarginContainer/VBoxContainer/Stats/Target/TargetValue");
	@:onready var range_label: Label = untyped __gdscript__("$MarginContainer/VBoxContainer/Stats/Range/RangeValue");

	public function set_skill(skill: Skill, current_teeth_count: Int) {
		name_label.text = skill.name;
		description_label.text = skill.description;
		power_label.text = Math.round(skill.min_power) + "~" + Math.round(skill.max_power);

		final cost = skill.get_real_cost();
		cost_label.text = cost <= 0 ? "Free" : (Std.string(cost) + " Teeth");
		cost_label.modulate = current_teeth_count < cost ? Color.RED : Color.WHITE;

		target_label.text = switch(skill.attack_type) {
			case BasicAttack: {
				"1";
			}
			case SurrondAttack: {
				"8";
			}
			case Projectile: {
				"1";
			}
		}
		range_label.text = switch(skill.attack_type) {
			case BasicAttack: {
				"Next to You";
			}
			case SurrondAttack: {
				"Next to You";
			}
			case Projectile: {
				"Projectile";
			}
		}
	}
}
