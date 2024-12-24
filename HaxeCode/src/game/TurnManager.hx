package game;

import godot.*;

class TurnManager extends Node {
	var entities: Array<TurnSlave> = [];

	public function process_turns(): Bool {
		cast(entities, GodotArray).sort_custom(new Callable(this, "sort_entities"));

		for (e in entities)
			e.process_turn();

		return true;
	}

	public function process_animations(ratio: Float): Void {
		for (e in entities)
			e.process_animation(ratio);
	}

	function sort_entities(a: TurnSlave, b: TurnSlave): Bool {
		return a.get_speed() < b.get_speed();
	}

	public function add_entity(entity: TurnSlave): Void {
		entities.push(entity);
	}
}