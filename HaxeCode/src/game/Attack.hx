package game;

enum Attack {
	BasicAttack;
	SurrondAttack;
}

class Skill {
	public var name(default, null): String;
	public var attack_type(default, null): Null<Attack>;
	public var min_power(default, null): Float;
	public var max_power(default, null): Float;
	public var knockback(default, null): Int;

	public function new(name: String, attack_type: Null<Attack>, min_power: Int, max_power: Int, knockback: Int) {
		this.name = name;
		this.attack_type = attack_type;
		this.min_power = min_power;
		this.max_power = max_power;
		this.knockback = knockback;
	}

	public static function get_skill(id: Int) {
		return if(id == BASIC_SKILL_ID) {
			BASIC_SKILL;
		} else {
			ALL_SKILLS[id];
		}
	}
}

final NULL_SKILL_ID = -2;
final CANCEL_SKILL_ID = -3;
final BASIC_SKILL_ID = -1;

final BASIC_SKILL = new Skill("Chomp", BasicAttack, 2, 3, 0);

final ALL_SKILLS = [
	new Skill("Spin Attack", SurrondAttack, 2, 3, 0),
];
