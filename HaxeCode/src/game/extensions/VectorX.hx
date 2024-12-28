package game.extensions;

import haxe.macro.Expr;

import godot.*;

/**
	Due to Haxe bug, I need to make all of these macro functions.
	Do NOT ask me why, I just needed it to work.

	TODO: Report this bug?? Idk, kinda lazy...
**/
class Vector2iExtensions {
	public static macro function to_vec3i(self: ExprOf<Vector2i>, z: ExprOf<Int>): ExprOf<Vector3i> {
		return macro untyped __gdscript__("Vector3({0}.x, {0}.y, {1})", $self, $z);
	}

	public static macro function to_vec3i_b(self: ExprOf<Vector2i>, z: ExprOf<Bool>): ExprOf<Vector3i> {
		return macro untyped __gdscript__("Vector3({0}.x, {0}.y, {1})", $self, $z ? 1 : 0);
	}
}

class Vector3iExtensions {
	public static macro function to_vec2i(self: ExprOf<Vector3i>): ExprOf<Vector2i> {
		return macro untyped __gdscript__("Vector2({0}.x, {0}.y)", $self);
	}

	public static macro function to_vec4i(self: ExprOf<Vector3i>, w: ExprOf<Int>): ExprOf<Vector4i> {
		return macro untyped __gdscript__("Vector4({0}.x, {0}.y, {0}.z, {1})", $self, $w);
	}
}

