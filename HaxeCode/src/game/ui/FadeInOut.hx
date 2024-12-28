package game.ui;

import godot.*;

class FadeInOut extends ColorRect {
	var fade_amount = 1.0;

	public function update_fade_in(delta: Float) {
		if(fade_amount == 0.0) {
			return false;
		}

		fade_amount -= delta * 2.0;
		if(fade_amount < 0.0) fade_amount = 0.0;

		trace(fade_amount);
		color.a = fade_amount;

		return fade_amount > 0.0;
	}

	public function update_fade_out(delta: Float) {
		if(fade_amount == 1.0) {
			return false;
		}

		fade_amount += delta * 5.0;
		if(fade_amount > 1.0) fade_amount = 1.0;

		color.a = fade_amount;

		return fade_amount < 1.0;
	}
}