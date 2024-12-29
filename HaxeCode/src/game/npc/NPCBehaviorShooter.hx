package game.npc;

import game.Attack.BASIC_SKILL_ID;
import game.data.Action;
import game.data.Direction;
import game.data.Direction.DirectionHelpers;

import godot.*;

@:access(game.NPC)
class NPCBehaviorShooter extends NPCBehaviorBase {
	public var direction: Direction = Left;
	
	var cooldown_time = 4;
	var cooldown = 0;

	public override function decide(npc: NPC, level_data: DynamicLevelData): Action {
		final npc_position = npc.tilemap_position;

		if(cooldown > 0) {
			cooldown--;
			return cooldown == 1 ? Jump(npc_position.z == 0) : Nothing;
		} else {
			cooldown = cooldown_time;
		}

		return DoSkill(1, [npc_position + Left.as_vec3i()]);
	}
}
