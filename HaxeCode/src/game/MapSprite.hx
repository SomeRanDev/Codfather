package game;

import godot.*;

@:tool
class MapSprite extends Sprite2D {
	@:exportToolButton("Build Map", "ColorRect")
	var build_map_action = untyped __gdscript__("build_map");

	@:exportToolButton("Delete Map", "ColorRect")
	var delete_map_action = untyped __gdscript__("setup_image");

	@:exportToolButton("Move Top Left", "ColorRect")
	var set_top_left_action = untyped __gdscript__("set_top_left");

	@:exportToolButton("Move Center", "ColorRect")
	var set_center_action = untyped __gdscript__("set_center");

	@:export var level_data: LevelData;
	@:export var wall_pixel_length: Int = 5;
	@:export var player_reveal_size = 12;

	var image: Image = null;
	var image_texture: ImageTexture = null;

	var handled_tiles: Array<Int>;

	var player_sprite: ColorRect = null;

	public function manual_ready() {
		setup_image();
	}

	public function set_player_position(player_position: Vector2i) {
		if(player_sprite == null) {
			player_sprite = new ColorRect();
			player_sprite.color = Color.RED;
			player_sprite.set_size(Vector2.ONE * wall_pixel_length);
			add_child(player_sprite);
		}

		if(image == null) return;

		var map_size = new Vector2i(level_data.width, level_data.height);
		player_sprite.position = new Vector2(((map_size / -2) + player_position) * wall_pixel_length);

		var player_index = (player_position.y * level_data.width) + player_position.x;
		if(handled_tiles[player_index] == 2) return;

		var drew_wall = false;
		var player_reveal_size_2 = player_reveal_size / 2;
		var start_x = Math.floor(player_position.x - player_reveal_size_2);
		var start_y = Math.floor(player_position.y - player_reveal_size_2);
		for(x in start_x...(start_x + player_reveal_size)) {
			for(y in start_y...(start_y + player_reveal_size)) {
				if(x >= 0 && x < level_data.width && y >= 0 && y < level_data.height) {
					var index = (y * level_data.width) + x;
					if(handled_tiles[index] == 0) {
						handled_tiles[index] = 1;
						if(draw_map_pos(x, y)) {
							drew_wall = true;
						}
					}
				}
			}
		}
		
		if(drew_wall) image_texture.update(image);

		handled_tiles[player_index] = 2;
	}

	public function set_top_left() {
		position = (new Vector2(
			level_data.width * wall_pixel_length,
			level_data.height * wall_pixel_length
		) * scale) / 2.0;
	}

	function set_center() {
		position = new Vector2(cast(get_viewport(), Window).size / 2.0);
	}

	function setup_image() {
		image = Image.create_empty(
			level_data.width * wall_pixel_length,
			level_data.height * wall_pixel_length,
			false,
			FORMAT_RGBA8
		);
		image.fill(new Color(0, 0, 0, 0));
		image_texture = ImageTexture.create_from_image(image);
		texture = image_texture;

		handled_tiles = [];
		handled_tiles.resize(level_data.width * level_data.height);
		untyped __gdscript__("{0}.fill(0);", handled_tiles);
	}

	function build_map() {
		if(image == null) {
			setup_image();
		}

		for(x in 0...level_data.width) {
			for(y in 0...level_data.height) {
				draw_map_pos(x, y);
			}
		}

		image_texture.update(image);
	}

	function draw_map_pos(x: Int, y: Int): Bool {
		if(!level_data.has_tile(x, y)) {
			draw_wall(x, y);
			return true;
		}
		return false;
	}

	function draw_wall(x: Int, y: Int) {
		var base_x = x * wall_pixel_length;
		var base_y = y * wall_pixel_length;
		if(level_data.has_tile(x, y - 1))
			for(i in 0...wall_pixel_length)
				draw_pixel(base_x + i, base_y);
		if(level_data.has_tile(x, y + 1))
			for(i in 0...wall_pixel_length)
				draw_pixel(base_x + i, base_y + wall_pixel_length - 1);
		if(level_data.has_tile(x - 1, y))
			for(i in 0...wall_pixel_length)
				draw_pixel(base_x, base_y + i);
		if(level_data.has_tile(x + 1, y))
			for(i in 0...wall_pixel_length)
				draw_pixel(base_x + wall_pixel_length - 1, base_y + i);
	}

	function draw_pixel(x: Int, y: Int) {
		if(x < 0 || x >= image.get_width() || y < 0 || y >= image.get_height()) return;
		
		image.set_pixel(x, y, Color.WHITE);
		set_pixel_black_if_empty(x - 1, y);
		set_pixel_black_if_empty(x + 1, y);
		set_pixel_black_if_empty(x, y - 1);
		set_pixel_black_if_empty(x, y + 1);
	}

	function set_pixel_black_if_empty(x: Int, y: Int) {
		if(image.get_pixel(x, y).a < 0.1) {
			image.set_pixel(x, y, Color.BLACK);
		}
	}
}
