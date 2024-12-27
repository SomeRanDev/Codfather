package game.ui.character_creator;

import game.Constants;

import godot.*;
import GDScript as GD;

class CharacterCreator extends Node {
	@:const var GREAT_WHITE_SHARK: Mesh = GD.preload("res://VisualAssets/Blender/Characters/Player/GreatWhiteShark.res");
	@:const var HAMMERHEAD_SHARK: Mesh = GD.preload("res://VisualAssets/Blender/Characters/Player/HammerheadShark.res");
	@:const var WHALE_SHARK: Mesh = GD.preload("res://VisualAssets/Blender/Characters/Player/WhaleShark.res");

	@:const var BRUTE: Mesh = GD.preload("res://VisualAssets/Blender/Characters/PlayerHats/Brute.res");
	@:const var DISPOSER: Mesh = GD.preload("res://VisualAssets/Blender/Characters/PlayerHats/Disposer.res");
	@:const var CAPO: Mesh = GD.preload("res://VisualAssets/Blender/Characters/PlayerHats/Capo.res");

	@:export var effect: PostProcess2D;
	@:export var container: FullScreenPanelContainer;
	@:export var entries: Array<CCEntry> = [];
	@:export var start_button: CCButton;

	@:export var species_selection: CCOption;
	@:export var class_selection: CCOption;
	@:export var display_model: MeshInstance3D;
	@:export var hat: MeshInstance3D;

	var is_transition: Bool = false;
	var transition_animation = 1.0;

	var current_index = 0;

	override function _ready() {
		for(e in entries) {
			e.manual_ready();
		}

		entries[0].set_selected(true);

		species_selection.connect("on_choice_changed", new Callable(this, "update_model"));
		class_selection.connect("on_choice_changed", new Callable(this, "update_hat"));

		container.manual_ready();
	}

	override function _process(delta: Float) {
		if(!is_transition && transition_animation > 0.0) {
			transition_animation -= delta * 15.0;
			if(transition_animation < 0.0) transition_animation = 0.0;
			effect.set_transition_amount(transition_animation);
			return;
		} else if(is_transition && transition_animation < 1.0) {
			transition_animation += delta * 15.0;
			if(transition_animation >= 1.0) transition_animation = 1.0;
			effect.set_transition_amount(transition_animation);
			if(transition_animation >= 1.0) {
				// GO TO NEXT SCENE....
			}
			return;
		}

		var offset = 0;
		if(Input.is_action_just_pressed("up")) {
			offset--;
		}
		if(Input.is_action_just_pressed("down")) {
			offset++;
		}
		if(offset < 0) {
			set_index(current_index == 0 ? entries.length - 1 : current_index - 1);
		} else if(offset > 0) {
			set_index(current_index == entries.length - 1 ? 0 : current_index + 1);
		}

		if(entries[current_index].update()) {
			is_transition = true;
		}
	}

	function set_index(index: Int) {
		if(current_index != index) {
			entries[current_index].set_selected(false);
			entries[index].set_selected(true);
			current_index = index;
		}
	}

	function update_model(index: Int) {
		display_model.mesh = switch(index) {
			case 0: GREAT_WHITE_SHARK;
			case 1: HAMMERHEAD_SHARK;
			case _: WHALE_SHARK;
		}

		hat.position = switch(index) {
			case 0: GWSharkHatPosition;
			case 1: HHSharkHatPosition;
			case _: WSharkHatPosition;
		}

		hat.rotation_degrees = switch(index) {
			case 0: GWSharkHatRotation;
			case 1: HHSharkHatRotation;
			case _: WSharkHatRotation;
		}
	}

	function update_hat(index: Int) {
		hat.mesh = switch(index) {
			case 0: BRUTE;
			case 1: DISPOSER;
			case _: CAPO;
		}

		hat.set_surface_override_material(0, switch(index) {
			case 0: GD.load("res://VisualAssets/Materials/Fish/Red.tres");
			case 1: GD.load("res://VisualAssets/Materials/Fish/Orange.tres");
			case _: GD.load("res://VisualAssets/Materials/Fish/Brown.tres");
		});
	}
}
