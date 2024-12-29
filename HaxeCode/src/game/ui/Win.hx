package game.ui;

import game.ui.character_creator.CCButton;
import godot.*;

class Win extends Node {
	@:export var effect: PostProcess2D;
	@:export var container: FullScreenPanelContainer;

	var is_transition = false;
	var transition_animation = 1.0;

	override function _ready() {
		container.manual_ready();
	}

	override function _process(delta: Float) {
		if(!is_transition && transition_animation > 0.0) {
			transition_animation -= delta * 3.0;
			if(transition_animation < 0.0) transition_animation = 0.0;
			effect.set_transition_amount(transition_animation);
			return;
		} else if(is_transition && transition_animation < 1.0) {
			transition_animation += delta * 15.0;
			if(transition_animation >= 1.0) transition_animation = 1.0;
			effect.set_transition_amount(transition_animation);
			if(transition_animation >= 1.0) {
				get_tree().change_scene_to_file("res://Title.tscn");
				effect.set_transition_amount(0.0);
			}
			return;
		}

		if(Input.is_action_just_pressed("start")) {
			is_transition = true;
		}
	}
}