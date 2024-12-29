package game;

import game.LevelData.EnemyType;
import godot.*;

@:nativeTypeCode("Dictionary[{type0}, {type1}]")
typedef TypedDictionary<T, U> = Dictionary;

@:tool
class CustomMap extends Resource {
	@:export public var custom_map: CompressedTexture2D;
	@:export public var text: String;
	@:export public var subtext: String;
	@:export public var custom_entities: TypedDictionary<Int, CustomEntity>;
}

@:tool
class CustomEntity extends Resource {
}

@:tool
class SignCustomEntity extends CustomEntity {
	@:export public var sign_text: String;

	public static function make(text: String) {
		final result = new SignCustomEntity();
		result.sign_text = text;
		return result;
	}
}

@:tool
class EnemyCustomEntity extends CustomEntity {
	@:export public var enemy: EnemyType;

	public static function make(enemy: EnemyType) {
		final result = new EnemyCustomEntity();
		result.enemy = enemy;
		return result;
	}
}
