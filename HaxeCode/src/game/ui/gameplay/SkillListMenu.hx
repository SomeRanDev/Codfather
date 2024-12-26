package game.ui.gameplay;

import game.Attack.BASIC_SKILL;
import game.Attack.ALL_SKILLS;
import godot.*;
import GDScript as GD;

class SkillListMenu extends VBoxContainer {
	@:onready var skill_list: SkillList = untyped __gdscript__("$SkillListContainer/SkillList");
	@:onready var skill_description: SkillDescription = untyped __gdscript__("$SkillDescriptionContainer/SkillDescription");

	var DESCRIPTION_LABEL_SETTINGS: LabelSettings = GD.preload("res://VisualAssets/Fonts/SkillList/DescriptionLabelSettings.tres");
	var NAME_LABEL_SETTINGS: LabelSettings = GD.preload("res://VisualAssets/Fonts/SkillList/NameLabelSettings.tres");
	var STATS_LABEL_SETTINGS: LabelSettings = GD.preload("res://VisualAssets/Fonts/SkillList/StatsLabelSettings.tres");

	public function setup(skills: Array<Int>) {
		skill_list.setup(skills);
		
		skill_description.set_skill(BASIC_SKILL);

		get_viewport().connect("size_changed", new Callable(this, "on_resize"));
		on_resize();
	}

	public function update() {
		final skill_id = skill_list.update();
		if(skill_id != -2) {
			if(skill_id == -1) {
				skill_description.set_skill(BASIC_SKILL);
			} else {
				skill_description.set_skill(ALL_SKILLS[skill_id]);
			}
		}
	}

	function on_resize() {
		final ratio_2d = get_viewport_rect().size / new Vector2(1152, 648);
		final r = Math.max(ratio_2d.x, ratio_2d.y);
		DESCRIPTION_LABEL_SETTINGS.font_size = Math.round(18 * r);
		NAME_LABEL_SETTINGS.font_size = Math.round(32 * r);
		STATS_LABEL_SETTINGS.font_size = Math.round(26 * r);

		center();
	}

	public function center() {
		final viewport_rect = get_viewport_rect();

		position = Vector2.ZERO;
		set_deferred("size", viewport_rect.size);

		skill_description.set_custom_minimum_size(new Vector2(viewport_rect.size.x * (500.0 / 1152.0), 0));

		// final ratio_2d = get_viewport_rect().size / new Vector2(1152, 648);
		// final r = Math.max(ratio_2d.x, ratio_2d.y);

		// position = (get_viewport_rect().size - size) / 2.;

		// skill_description.size = new Vector2(500, 171.0) * r;
		// skill_description.position = position + new Vector2((size.x - skill_description.size.x) / 2.0, -skill_description.size.y - 32);
	}
}
