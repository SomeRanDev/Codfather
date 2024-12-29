package game.ui;

import game.ui.character_creator.CCButton;
import godot.*;

class Story extends Node {
	@:export var effect: PostProcess2D;
	@:export var container: FullScreenPanelContainer;

	@:export var play_tutorial: CCButton;
	@:export var skip_tutorial: CCButton;

	var is_transition = false;
	var transition_animation = 1.0;

	var selected_button_index = 0;

	override function _ready() {
		container.manual_ready();

		play_tutorial.manual_ready();
		skip_tutorial.manual_ready();

		play_tutorial.set_selected(true);
		skip_tutorial.set_selected(false);
		selected_button_index = 0;
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
				get_tree().change_scene_to_file("res://Main.tscn");
				effect.set_transition_amount(0.0);
			}
			return;
		}

		if(Input.is_action_just_pressed("start")) {
			is_transition = true;
			if(selected_button_index == 0) {
				WorldManager.should_randomize = false;

				WorldManager.floor = 0;
				WorldManager.floors_remaining = 5;
				WorldManager.go_to_tutorial();
			} else {
				WorldManager.should_randomize = true;
				WorldManager.go_to_new_floor();
			}
		} else if(selected_button_index == 1 && Input.is_action_just_pressed("left")) {
			play_tutorial.set_selected(true);
			skip_tutorial.set_selected(false);
			selected_button_index = 0;
		} else if(selected_button_index == 0 && Input.is_action_just_pressed("right")) {
			skip_tutorial.set_selected(true);
			play_tutorial.set_selected(false);
			selected_button_index = 1;
		}
	}
}