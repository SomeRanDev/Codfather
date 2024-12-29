package game;

import game.npc.NPCBehaviorBasicAttacker;
import game.npc.NPCBehaviorShooter;
import game.npc.NPCBehaviorStillAttacker;
import game.LevelData.EnemyType;

import godot.*;

class EnemyMaker {
	public static function random_enemy_type(): EnemyType {
		return switch(Godot.randi_range(0, 6)) {
			case 0: Crab;
			case 1: CrabShooter;
			case 2: Fish1;
			case 3: Fish2;
			case 4: FlatFish;
			case 5: SwordFish;
			case _: StarFish;
		}
	}

	public static function make_enemy(npc: NPC, enemy_type: EnemyType) {
		switch(enemy_type) {
			case TestFish: {
				npc.set_mesh("res://VisualAssets/Blender/Characters/Fish1.res");
				npc.set_behavior(new NPCBehaviorBasicAttacker());
				npc.set_all_stats(1, 1, 1, 1, 0);
			}
			case Crab: {
				npc.set_mesh("res://VisualAssets/Blender/Characters/Crab.res");
				final attacker = new NPCBehaviorBasicAttacker();
				attacker.wander = false;
				npc.set_behavior(attacker);
				npc.set_all_stats(Godot.randi_range(10, 15), Godot.randi_range(1, 1), Godot.randi_range(4, 6), Godot.randi_range(1, 2), 0);
			}
			case CrabShooter: {
				npc.set_mesh("res://VisualAssets/Blender/Characters/Crab.res");
				npc.set_behavior(new NPCBehaviorShooter());
				npc.set_all_stats(Godot.randi_range(10, 15), Godot.randi_range(1, 1), Godot.randi_range(4, 6), Godot.randi_range(1, 2), 0);
			}
			case Fish1: {
				npc.set_mesh("res://VisualAssets/Blender/Characters/Fish1.res");
				npc.set_behavior(new NPCBehaviorBasicAttacker());
				npc.set_all_stats(Godot.randi_range(2, 6), Godot.randi_range(2, 3), Godot.randi_range(2, 3), Godot.randi_range(3, 8), 0);
			}
			case Fish2: {
				npc.set_mesh("res://VisualAssets/Blender/Characters/Fish2.res");
				npc.set_behavior(new NPCBehaviorBasicAttacker());
				npc.set_all_stats(Godot.randi_range(4, 8), Godot.randi_range(3, 4), Godot.randi_range(3, 4), Godot.randi_range(4, 10), 0);
			}
			case FlatFish: {
				npc.set_mesh("res://VisualAssets/Blender/Characters/FlatFish.res");
				npc.set_behavior(new NPCBehaviorBasicAttacker());
				npc.set_all_stats(Godot.randi_range(10, 15), Godot.randi_range(1, 3), Godot.randi_range(10, 15), Godot.randi_range(2, 5), 0);
			}
			case StarFish: {
				npc.set_mesh("res://VisualAssets/Blender/Characters/StarFish.res");
				npc.set_behavior(new NPCBehaviorStillAttacker());
				npc.set_all_stats(Godot.randi_range(1, 4), Godot.randi_range(1, 2), Godot.randi_range(5, 7), 0, 0);
			}
			case SwordFish: {
				npc.set_mesh("res://VisualAssets/Blender/Characters/SwordFish.res");
				npc.set_behavior(new NPCBehaviorBasicAttacker());
				npc.set_all_stats(Godot.randi_range(8, 12), Godot.randi_range(5, 7), Godot.randi_range(4, 6), Godot.randi_range(10, 15), 0);
			}
			case AlwaysFastTutorialFish: {
				npc.set_mesh("res://VisualAssets/Blender/Characters/Fish1.res");
				final attacker = new NPCBehaviorBasicAttacker();
				attacker.wander = false;
				npc.set_behavior(attacker);
				npc.set_all_stats(5, 1, 5, 9999, 0);
			}
		}
	}
}