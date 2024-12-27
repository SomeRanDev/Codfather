package game.ui.character_creator;

import godot.*;

class CCEntry extends PanelContainer {
	var select: ColorRect;
	var is_selected: Bool = false;

	public function manual_ready() {
		select = untyped __gdscript__("$Select");
	}

	public function set_selected(selected: Bool) {
		if(is_selected != selected) {
			is_selected = selected;
			select.visible = selected;
			on_selected();
		}
	}

	function on_selected() {
	}

	public function update(): Bool {
		return false;
	}
}
