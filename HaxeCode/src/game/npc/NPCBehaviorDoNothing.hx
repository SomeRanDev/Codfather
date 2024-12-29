package game.npc;

import game.data.Action;
import game.data.Direction;

import godot.*;

@:access(game.NPC)
class NPCBehaviorDoNothing extends NPCBehaviorBase {
	public override function decide(npc: NPC, level_data: DynamicLevelData): Action {
		return Nothing;
	}
}
