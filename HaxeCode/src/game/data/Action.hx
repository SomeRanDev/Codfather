package game.data;

import game.data.Direction;

import godot.Vector3i;

@:using(game.data.Action.ActionHelpers)
enum Action {
	Nothing;
	Suicide;
	Move(direction: Direction);
	Jump(is_up: Bool);
	BasicAttack(direction: Direction);
	ProjectileAttack(direction: Direction, skill_id: Int);
	DoSkill(skill_id: Int, targeted_positions: Array<Vector3i>);
}

class ActionHelpers {
	public static function action_from_offset(offset: Vector3i): Action {
		return if(offset.x == 0 && offset.z == 0) {
			switch(offset.y) {
				case -1: Move(Up);
				case 1: Move(Down);
				case _: Nothing;
			}
		} else if(offset.y == 0 && offset.z == 0) {
			switch(offset.x) {
				case -1: Move(Left);
				case 1: Move(Right);
				case _: Nothing;
			}
		} else if(offset.x == 0 && offset.y == 0) {
			switch(offset.z) {
				case -1: Jump(false);
				case 1: Jump(true);
				case _: Nothing;
			}
		} else {
			Nothing;
		}
	}
}
