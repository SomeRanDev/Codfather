package game;

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

	public function take_attack(attacker: TurnSlave, attack: Attack): Bool {
		var damage: Int = 0;

		switch(attack) {
			case BasicAttack: {
				damage = Math.floor(attacker.stats.power / 2);
			}
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