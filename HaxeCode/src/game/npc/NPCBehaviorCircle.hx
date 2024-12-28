package game.npc;

import game.data.Action;
import game.data.Direction;

import godot.*;

@:access(game.NPC)
class NPCBehaviorCircle extends NPCBehaviorBase {
	var phase = 0;

	public override function decide(npc: NPC, level_data: DynamicLevelData): Action {
		if(Math.random() < 0.2) {
			final is_up = npc.tilemap_position.z == 0;
			final next_position = npc.tilemap_position + new Vector3i(0, 0, is_up ? 1 : -1);
			if(level_data.tile_free(next_position)) {
				return Jump(is_up);
			}
		}

		final direction: Direction = {
			switch(Math.round(phase / 2)) {
				case 0: Right;
				case 1: Down;
				case 2: Left;
				case 3: Up;
				case _: Up;
			}
		}

		final next_position = npc.tilemap_position + direction.as_vec3i();
		if(level_data.tile_free(next_position)) {
			phase++;
			if(phase >= 8) { phase = 0; }

			return Move(direction);
		}

		return Nothing;
	}
}
