package game.ui.gameplay;

import godot.*;

class SkillListItem extends HBoxContainer {
	@:onready var cursor: TextureRect = untyped __gdscript__("$Cursor");
	@:onready var label: Label = untyped __gdscript__("$Label");

	public var skill_id(default, null): Int;

	public function setup(name: String, id: Int) {
		if(label == null) {
			label = untyped __gdscript__("$Label");
		}
		label.text = name;
		skill_id = id;
	}

	public function set_selected(selected: Bool) {
		cursor.visible = selected;
	}
}
