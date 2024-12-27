package game.ui;

import godot.*;

class Title extends Node {
	@:export var effect: PostProcess2D;
	@:export var container: FullScreenPanelContainer;

	var is_transitioning = false;
	var animation = 0.0;

	override function _ready() {
		container.manual_ready();
	}

	override function _process(delta: Float) {
		if(is_transitioning) {
			animation += delta * 15.0;
			if(animation >= 1.0) animation = 1.0;

			effect.set_transition_amount(animation);

			if(animation >= 1.0) {
				get_tree().change_scene_to_file("res://CharacterCreator.tscn");
			}

			return;
		}

		if(!is_transitioning && Input.is_action_just_pressed("start")) {
			is_transitioning = true;
		}
	}
}