package game.data;

import game.data.Direction;

enum Action {
	Nothing;
	Move(direction: Direction);
	Jump(is_up: Bool);
}
