package game.extensions;

class ArrayExtensions {
	public static inline function remove_first<T>(self: Array<T>) {
		self.splice(0, 1);
	}

	public static inline function remove_at<T>(self: Array<T>, index: Int) {
		self.splice(index, 1);
	}

	public static inline function push_circular<T>(self: Array<T>, item: T, max_size: Int) {
		self.push(item);
		while(self.length > max_size) {
			remove_first(self);
		}
	}
}
