package util;

class ArrayExtender {
	public static inline function pushx<T>(a:Array<T>,n:T,times:Int) {
		for (i in 0...times)
			a.push(n);

		return a;
	}
}