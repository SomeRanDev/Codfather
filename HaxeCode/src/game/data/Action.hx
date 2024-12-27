package game.data;

import game.data.Direction;

import godot.Vector3i;

enum Action {
	Nothing;
	Move(direction: Direction);
	Jump(is_up: Bool);
	BasicAttack(direction: Direction);
	DoSkill(skill_id: Int, targeted_positions: Array<Vector3i>);
}
