package game;

enum Attack {
	BasicAttack;
	SingleAttack;
	SurrondAttack;
	Self;
	Projectile;
}

class Skill {
	public var name(default, null): String;
	public var description(default, null): String;
	public var attack_type(default, null): Null<Attack>;
	public var min_power(default, null): Float;
	public var max_power(default, null): Float;
	public var knockback(default, null): Int;
	public var cost(default, null): Int;
	public var healing(default, null): Int;

	public function new(
		name: String, description: String, attack_type: Null<Attack>, min_power: Int, max_power: Int, cost: Int,
		knockback: Int, healing: Int
	) {
		this.name = name;
		this.description = description;
		this.attack_type = attack_type;
		this.min_power = min_power;
		this.max_power = max_power;
		this.cost = cost;
		this.knockback = knockback;
		this.healing = healing;
	}

	public static function get_skill(id: Int) {
		return if(id == BASIC_SKILL_ID) {
			BASIC_SKILL;
		} else {
			ALL_SKILLS[id];
		}
	}

	public function get_real_cost(): Int {
		return cost < 0 ? 0 : cost;
	}

	public function is_projectile(): Bool {
		return switch(attack_type) {
			case Projectile: true;
			case _: false;
		}
	}
}

final NULL_SKILL_ID = -2;
final CANCEL_SKILL_ID = -3;
final BASIC_SKILL_ID = -1;

final BASIC_SKILL = new Skill("Chomp", "Your default attack.\nRestores health on kill.", BasicAttack, 2, 3, 0, 0, 0);

final ALL_SKILLS = [
	new Skill("Spin Attack", "Hits all enemies around you.", SurrondAttack, 2, 4, 2, 0, 0),
	new Skill("Bubble", "Shoots a bubble.", Projectile, 2, 5, 2, 0, 0),
	new Skill("Crushing Crunch", "Hits a single enemy for BIG damage.", SingleAttack, 7, 15, 5, 0, 0),
	new Skill("Plankton Snack", "Restores HP to full.", Self, 0, 0, 10, 0, 999),
];
