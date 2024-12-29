package game;

import godot.*;
import GDScript as GD;

@:native("MyAudioPlayer")
extern var MyAudioPlayer: AudioPlayer;

class AudioPlayer extends Node {
	public var cursor_move: AudioStreamPlayer = null;
	public var selection_change: AudioStreamPlayer = null;
	public var start: AudioStreamPlayer = null;
	public var blocked: AudioStreamPlayer = null;
	public var special_attack: AudioStreamPlayer = null;
	public var attack1: AudioStreamPlayer = null;
	public var stairs2: AudioStreamPlayer = null;
	public var enemy_kill: AudioStreamPlayer = null;
	public var player_kill: AudioStreamPlayer = null;
	public var add_stat: AudioStreamPlayer = null;
	public var subtract_stat: AudioStreamPlayer = null;
	public var player_enter: AudioStreamPlayer = null;
	public var go_up: AudioStreamPlayer = null;
	public var go_down: AudioStreamPlayer = null;
	public var footstep: AudioStreamPlayer = null;
	public var enemy_notice: AudioStreamPlayer = null;
	public var read_sign: AudioStreamPlayer = null;
	public var finish_dialogue: AudioStreamPlayer = null;

	public var music_player: AudioStreamPlayer = null;
	var current_music = -1;

	override function _ready() {
		music_player = new AudioStreamPlayer();
		add_child(music_player);

		cursor_move = make_player("CursorMove", -5.0);
		selection_change = make_player("SelectionChange", 0.0);
		start = make_player("Start", -5.0);
		blocked = make_player("Blocked", -7.0);
		special_attack = make_player("SpecialAttack", 0.0);
		attack1 = make_player("Attack1", 0.0);
		stairs2 = make_player("Stairs2", 0.0);
		enemy_kill = make_player("EnemyKill", 0.0);
		player_kill = make_player("PlayerKill", 0.0);
		add_stat = make_player("AddStat", -5.0);
		subtract_stat = make_player("SubtractStat", -3.0);
		player_enter = make_player("PlayerEnter", -10.0);
		go_up = make_player("GoUp", 0.0);
		go_down = make_player("GoDown", 0.0);
		footstep = make_player("Footstep", -15.0);
		enemy_notice = make_player("EnemyNotice", 0.0);
		read_sign = make_player("ReadSign", 0.0);
		finish_dialogue = make_player("FinishDialogue", 0.0);
	}

	public function play_footstep() {
		footstep.pitch_scale = Godot.randf_range(0.5, 1.5);
		footstep.volume_db = Godot.randf_range(-17.0, -12.0);
		footstep.play();
	}

	function make_player(path: String, volume: Float) {
		final p = new AudioStreamPlayer();
		p.stream = GD.load("res://AudioAssets/" + path + ".wav");
		p.max_polyphony = 3;
		p.volume_db = volume;
		add_child(p);
		return p;
	}

	public function play_title_music() {
		if(current_music != 0) {
			current_music = 0;
			music_player.stream = GD.load("res://AudioAssets/Music/Sketchbook 2024-08-21.ogg");
			music_player.play();
		}
	}

	public function play_level_music() {
		if(current_music != 1) {
			current_music = 1;
			music_player.stream = GD.load("res://AudioAssets/Music/Sketchbook 2024-11-07.ogg");
			music_player.play();
		}
	}

	public function play_boss_music() {
		if(current_music != 2) {
			current_music = 2;
			music_player.stream = GD.load("res://AudioAssets/Music/Sketchbook 2024-10-23.ogg");
			music_player.play();
		}
	}

	public function play_tutorial_music() {
		if(current_music != 3) {
			current_music = 3;
			music_player.stream = GD.load("res://AudioAssets/Music/Sketchbook 2024-10-30.ogg");
			music_player.play();
		}
	}

	public function stop_music() {
		if(current_music != -1) {
			current_music = -1;
			music_player.stop();
		}
	}
}
