package game;

import godot.*;
import GDScript as GD;

class HoverDots extends Node3D {
	var animation_time: Float;
	var dots: Null<Array<Sprite3D>> = null;

	@:const var DOT_SCENE: PackedScene = cast GD.preload("res://Objects/Dot.tscn");

	public function set_show(show: Bool) {
		if(visible != show) {
			visible = show;
			set_process_mode(show ? PROCESS_MODE_INHERIT : PROCESS_MODE_DISABLED);
			if(show && dots == null) {
				create_dots();
			}
		}
	}

	function create_dots() {
		dots = [];

		for(i in 0...3) {
			final dot: Sprite3D = cast DOT_SCENE.instantiate();
			add_child(dot);
			dots.push(dot);
		}
	}

	function refresh() {
		var index = 0;
		for(i in 0...3) {
			dots[i].position = new Vector3(0, ((i * 0.33333) + (animation_time * 0.333333)) - 0.5, 0);
		}
	}

	override function _process(delta: Float) {
		animation_time += delta;
		if(animation_time > 1.0) animation_time = 0.0;
		refresh();
	}
}
