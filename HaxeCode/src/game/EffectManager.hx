package game;

import godot.*;
import GDScript as GD;

class EffectManager extends Node3D {
	@:const var BLOOD_PARTICLES: PackedScene = GD.preload("res://Objects/Particles/BloodParticles.tscn");

	var blood_particles: Array<GPUParticles3D> = [];
	var blood_particle_pool: Array<GPUParticles3D> = [];

	public function add_blood_particles(position: Vector3) {
		final blood = if(blood_particle_pool.length > 0) {
			blood_particle_pool.pop();
		} else {
			final b: GPUParticles3D = cast BLOOD_PARTICLES.instantiate();
			final ga = new GodotArray();
			ga.push_back(b);
			b.connect("finished", (new Callable(this, "on_blood_complete")).bindv(ga));
			b;
		}

		blood.position = position;

		add_child(blood);
		blood_particles.push(blood);

		blood.restart();
	}

	function on_blood_complete(b: GPUParticles3D) {
		remove_child(b);
		blood_particles.remove(b);
		blood_particle_pool.push(b);
	}

	override function _exit_tree() {
		for(b in blood_particle_pool) {
			b.queue_free();
		}
		blood_particle_pool = [];
	}
}
