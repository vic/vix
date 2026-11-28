// one scroll listener for the page; each caller re-reads the DOM it needs, so it survives client-side navigation
const callbacks = new Set<() => void>();
let listening = false;

export function onScroll(fn: () => void) {
	callbacks.add(fn);
	if (!listening) {
		listening = true;
		addEventListener('scroll', () => callbacks.forEach((f) => f()), { passive: true });
	}
	fn();
}
