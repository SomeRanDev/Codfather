package game.ui.gameplay;

import game.AudioPlayer.MyAudioPlayer;
import game.Attack.CANCEL_SKILL_ID;
import game.Attack.Skill;
import game.Attack.BASIC_SKILL_ID;
import game.Attack.NULL_SKILL_ID;
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

	public function setup(skills: Array<Int>, current_player_teeth: Int) {
		skill_list.setup(skills);
		
		skill_description.set_skill(BASIC_SKILL, current_player_teeth);

		get_viewport().connect("size_changed", new Callable(this, "on_resize"));
		on_resize();
	}

	public function update(current_player_teeth: Int): Int {
		final skill_id = skill_list.update();
		if(skill_id != NULL_SKILL_ID) {
			skill_description.set_skill(Skill.get_skill(skill_id), current_player_teeth);
		}

		if(Input.is_action_just_pressed("ok")) {
			if(!skill_list.has_enough_teeth(current_player_teeth)) {
				// Play bad sound effect...
				return NULL_SKILL_ID;
			}
			MyAudioPlayer.start.play();
			return skill_list.get_current_skill_id();
		} else if(Input.is_action_just_pressed("back")) {
			MyAudioPlayer.subtract_stat.play();
			return CANCEL_SKILL_ID;
		}
		return NULL_SKILL_ID;
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
