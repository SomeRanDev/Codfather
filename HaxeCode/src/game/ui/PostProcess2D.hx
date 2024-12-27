package game.ui;

import godot.*;

class PostProcess2D extends CanvasGroup {
	public function set_transition_amount(r: Float) {
		final m = cast(get_material(), ShaderMaterial);
		if(m != null) {
			m.set_shader_parameter("resolution", (new Vector2(640, 480)).lerp(new Vector2(100, 100), r));
			m.set_shader_parameter("aberation_amount", Godot.lerp(0.5, 3.0, r));
		}
	}
}
