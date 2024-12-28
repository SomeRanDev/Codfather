package game;

import godot.*;
import GDScript as GD;

@:tool
class Tilemap extends Node3D {
	@:exportToolButton("Generate Tile Nodes", "ColorRect")
	var build_world_action = untyped __gdscript__("build_world");

	@:export var level_data: LevelData;

	@:export var floor_mesh: Mesh;
	@:export var wall_mesh: Mesh = GD.preload("res://VisualAssets/Blender/World/Wall1.res");
	@:export var top_mesh: Mesh = GD.preload("res://VisualAssets/Blender/World/WallTop1.res");
	@:export var stairs: Mesh = GD.preload("res://VisualAssets/Blender/World/Stairs.res");

	@:export var stairs_scene: PackedScene = GD.preload("res://Objects/Stairs.tscn");

	@:export var normal_floor_material = GD.preload("res://VisualAssets/Materials/World/NormalTile.tres");
	@:export var alternative_floor_material = GD.preload("res://VisualAssets/Materials/World/AlternativeTile.tres");
	@:export var stairs_material = GD.preload("res://VisualAssets/Materials/World/Stairs.tres");

	public function build_world() {
		if(level_data == null)
			return;

		while(get_child_count(true) > 0)
			remove_child(get_child(0, true));

		for(x in 0...level_data.width)
			for(y in 0...level_data.height)
				create_tile(x, y);
	}

	function create_tile(x: Int, y: Int) {
		if(level_data.has_tile(x, y))
			if(level_data.stairs_position.x == x && level_data.stairs_position.y == y)
				create_stairs(x, y);
			else
				create_walkable_tile(x, y);
		else
			create_unwalkable_tile(x, y);
	}

	function find_owner(): Node {
		if(Engine.is_editor_hint())
			return EditorInterface.get_edited_scene_root();
		return get_tree().get_root();
	}

	function create_stairs(x: Int, y: Int) {
		var m = if(stairs_scene != null) {
			cast stairs_scene.instantiate();
		} else {
			final m = new MeshInstance3D();
			m.mesh = stairs;
			m.set_surface_override_material(0, stairs_material);
			m;
		}
		m.position = new Vector3(x, 0.0, y);
		add_child(m);
		m.owner = find_owner();
	}

	function create_walkable_tile(x: Int, y: Int) {
		var m = new MeshInstance3D();
		m.mesh = floor_mesh;
		m.position = new Vector3(x, 0.0, y);
		if(x % 2 == y % 2)
			m.set_surface_override_material(0, alternative_floor_material);
		else
			m.set_surface_override_material(0, normal_floor_material);
		add_child(m);
		m.owner = find_owner();
	}

	function create_unwalkable_tile(x: Int, y: Int) {
		final cap = new MeshInstance3D();
		cap.mesh = top_mesh;
		cap.position = new Vector3(x, 1.5, y);
		cap.rotation = new Vector3(0.0, Godot.randi_range(0, 4) * Math.PI * 0.5, 0.0);
		add_child(cap);
		cap.owner = find_owner();

		if(level_data.has_tile(x - 1, y)) {
			final m = new MeshInstance3D();
			m.mesh = wall_mesh;
			m.position = new Vector3(x, 0.0, y);
			m.rotation = new Vector3(0.0, Math.PI, 0.0);
			add_child(m);
			m.owner = find_owner();
		}
		if(level_data.has_tile(x + 1, y)) {
			final m = new MeshInstance3D();
			m.mesh = wall_mesh;
			m.position = new Vector3(x, 0.0, y);
			m.rotation = new Vector3(0.0, 0.0, 0.0);
			add_child(m);
			m.owner = find_owner();
		}
		if(level_data.has_tile(x, y + 1)) {
			final m = new MeshInstance3D();
			m.mesh = wall_mesh;
			m.position = new Vector3(x, 0.0, y);
			m.rotation = new Vector3(0.0, Math.PI * 1.5, 0.0);
			add_child(m);
			m.owner = find_owner();
		}
		if(level_data.has_tile(x, y - 1)) {
			final m = new MeshInstance3D();
			m.mesh = wall_mesh;
			m.position = new Vector3(x, 0.0, y);
			m.rotation = new Vector3(0.0, Math.PI * 0.5, 0.0);
			add_child(m);
			m.owner = find_owner();
		}
	}
}
