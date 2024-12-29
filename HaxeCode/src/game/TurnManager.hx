package game;

import godot.*;
import GDScript as GD;

class TurnManager extends Node {
	var entities: Array<TurnSlave> = [];
	var entity_map: Dictionary = new Dictionary();
	var to_be_added_entities: Array<TurnSlave> = [];
	var to_be_deleted_entities: Array<TurnSlave> = [];

	public function preprocess_turns(): Bool {
		for (e in entities)
			e.preprocess_turn();

		return true;
	}

	public function process_turns(): Bool {
		cast(entities, GodotArray).sort_custom(new Callable(this, "sort_entities"));

		for(e in entities) {
			e.process_turn();
		}

		if(to_be_added_entities.length > 0) {
			for(tba in to_be_added_entities) {
				add_entity(tba);
			}
			to_be_added_entities = [];
		}

		if(to_be_deleted_entities.length > 0) {
			for(tbd in to_be_deleted_entities) {
				entities.remove(tbd);
				entity_map.erase(tbd.stats.id);
				tbd.queue_free();
			}
			to_be_deleted_entities = [];
		}

		return true;
	}

	public function process_animations(ratio: Float): Void {
		for (e in entities)
			e.process_animation(ratio);
	}

	function sort_entities(a: TurnSlave, b: TurnSlave): Bool {
		return a.get_speed() > b.get_speed();
	}

	public function add_entity(entity: TurnSlave): Void {
		entities.push(entity);

		GD.assert(entity.stats.id > 0, "Added entity without setting up ID.");
		entity_map.set(entity.stats.id, entity);
	}

	public function queue_add_entity(entity: TurnSlave) {
		to_be_added_entities.push(entity);
	}

	public function remove_entity(entity: TurnSlave) {
		to_be_deleted_entities.push(entity);
	}

	public function get_entity(id: Int): Null<TurnSlave> {
		if(entity_map.has(id)) {
			return entity_map.get(id);
		}
		return null;
	}
}
