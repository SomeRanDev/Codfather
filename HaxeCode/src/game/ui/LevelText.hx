package game.ui;

import godot.*;

class LevelText extends Node {
	@:export var floor_text: Label;
	@:export var floor_subtext: Label;

	var floor_text_animation: Float = 3.0;

	override function _ready() {
		floor_text.visible = floor_subtext.visible = true;
		floor_text.modulate.a = floor_subtext.modulate.a = 1.0;
		floor_text.text = "Floor " + Std.string(WorldManager.floor);
		floor_subtext.text = "(" + WorldManager.floors_remaining + " floors remaining)";
		set_process_mode(PROCESS_MODE_INHERIT);

		floor_text_animation = 3.0;
	}

	override function _process(delta: Float) {
		floor_text_animation -= delta;
		if(floor_text_animation < 0.0) floor_text_animation = 0.0;

		if(floor_text_animation < 1.0) {
			floor_text.modulate.a = floor_text_animation;
			floor_subtext.modulate.a = floor_text_animation;
		}

		if(floor_text_animation <= 0.0) {
			set_process_mode(PROCESS_MODE_DISABLED);
		}
	}
}
