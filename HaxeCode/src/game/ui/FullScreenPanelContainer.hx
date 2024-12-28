package game.ui;

import godot.*;

class FullScreenPanelContainer extends PanelContainer {
	@:export var resize_label_settings: Array<LabelSettings> = [];
	@:export var resize_rich_texts: Array<RichTextLabel> = [];
	
	var resize_label_settings_sizes: Array<Int> = [];
	var resize_rich_text_sizes: Array<Int> = [];

	public function manual_ready() {
		if(resize_label_settings_sizes.length == 0) {
			for(ls in resize_label_settings) {
				resize_label_settings_sizes.push(ls.font_size);
			}
		}
		if(resize_rich_text_sizes.length == 0) {
			for(rt in resize_rich_texts) {
				resize_rich_text_sizes.push(rt.get("theme_override_font_sizes/normal_font_size"));
			}
		}

		get_viewport().connect("size_changed", new Callable(this, "on_game_resize"));
		on_game_resize();
	}

	function on_game_resize() {
		final new_size = get_viewport_rect().size;
		set_deferred("size", new_size);
		set_deferred("position", Vector2.ZERO);

		final size_ratio = (new_size / new Vector2(1152, 648));
		final font_ratio = Math.max(size_ratio.x, size_ratio.y);
		for(i in 0...resize_label_settings.length) {
			resize_label_settings[i].font_size = Math.round(resize_label_settings_sizes[i] * font_ratio);
		}
		for(i in 0...resize_rich_texts.length) {
			resize_rich_texts[i].set("theme_override_font_sizes/normal_font_size", Math.round(resize_rich_text_sizes[i] * font_ratio));
		}
	}
}