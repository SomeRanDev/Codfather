package game.npc;

import game.data.Action;

import godot.*;

class NPCBehaviorBase extends Node {
	public function decide(npc: NPC, level_data: DynamicLevelData): Action {
		return Nothing;
	}
}