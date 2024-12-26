package game;

import game.Attack.ALL_SKILLS;
import game.effects.text_popup.PopupMaker;

import godot.*;

class TurnSlave extends Node3D {
	@:export var popup_maker: PopupMaker;

	public var stats(default, null) = new Stats();

	public function get_speed(): Float {
		return stats.speed;
	}

	public function process_turn() {
	}

	public function process_animation(ratio: Float): Void {
	}

	public function take_attack(attacker: TurnSlave, skill_id: Int): Bool {
		var damage: Int = 0;

		if(skill_id == -1) {
			damage = Math.floor(attacker.stats.power / 2);
		} else {
			final skill = ALL_SKILLS[skill_id];
			final ratio = stats.tough == 0 ? 1 : (attacker.stats.power / stats.tough);
			final power = Godot.randf_range(skill.min_power, skill.max_power);
			damage = Math.floor(Math.max(ratio * power, 1));
		}

		if(damage > 0) {
			popup_maker.popup(Std.string(damage));

			stats.health -= damage;
			if(stats.health < 0) {
				// kill
			}
		}

		return true;
	}
}