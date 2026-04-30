/**
 * Adds Vim-style j/k navigation and explicit `/` search mode to pi's
 * double-Escape session tree and `/resume` session picker.
 */
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { SessionSelectorComponent, TreeSelectorComponent } from "@mariozechner/pi-coding-agent";
import { getKeybindings } from "@mariozechner/pi-tui";

const TREE_PATCHED = Symbol.for("jonco.pi.tree-vim-navigation.tree-patched");
const SESSION_PATCHED = Symbol.for("jonco.pi.tree-vim-navigation.session-patched");
const SEARCH_ACTIVE = Symbol.for("jonco.pi.tree-vim-navigation.search-active");

type TreeListInternals = {
	selectedIndex?: number;
	filteredNodes?: unknown[];
	getSearchQuery?: () => string;
	[SEARCH_ACTIVE]?: boolean;
};

type TreeSelectorInternals = {
	labelInput?: unknown;
	treeList?: TreeListInternals;
	handleInput: (data: string) => void;
};

type SearchInputInternals = {
	getValue: () => string;
	setValue: (value: string) => void;
	handleInput: (data: string) => void;
};

type SessionListInternals = {
	selectedIndex?: number;
	filteredSessions?: unknown[];
	searchInput?: SearchInputInternals;
	confirmingDeletePath?: string | null;
	filterSessions?: (query: string) => void;
	[SEARCH_ACTIVE]?: boolean;
};

type SessionSelectorInternals = {
	mode?: string;
	sessionList?: SessionListInternals;
	handleInput: (data: string) => void;
};

type PatchableTreeSelectorPrototype = TreeSelectorInternals & {
	[TREE_PATCHED]?: boolean;
};

type PatchableSessionSelectorPrototype = SessionSelectorInternals & {
	[SESSION_PATCHED]?: boolean;
};

function isPlainPrintable(data: string): boolean {
	if (data.length === 0) return false;
	return ![...data].some((ch) => {
		const code = ch.charCodeAt(0);
		return code < 32 || code === 0x7f || (code >= 0x80 && code <= 0x9f);
	});
}

function moveTreeSelection(list: TreeListInternals, delta: -1 | 1) {
	const nodes = list.filteredNodes;
	if (!nodes || nodes.length === 0) return;

	const current = typeof list.selectedIndex === "number" ? list.selectedIndex : 0;
	if (delta < 0) {
		list.selectedIndex = current <= 0 ? nodes.length - 1 : current - 1;
	} else {
		list.selectedIndex = current >= nodes.length - 1 ? 0 : current + 1;
	}
}

function moveSessionSelection(list: SessionListInternals, delta: -1 | 1) {
	const sessions = list.filteredSessions;
	if (!sessions || sessions.length === 0) return;

	const current = typeof list.selectedIndex === "number" ? list.selectedIndex : 0;
	if (delta < 0) {
		list.selectedIndex = Math.max(0, current - 1);
	} else {
		list.selectedIndex = Math.min(sessions.length - 1, current + 1);
	}
}

function patchTreeSelector() {
	const prototype = TreeSelectorComponent.prototype as PatchableTreeSelectorPrototype;
	if (!prototype || prototype[TREE_PATCHED]) return;

	const originalHandleInput = prototype.handleInput;
	prototype[TREE_PATCHED] = true;
	prototype.handleInput = function (this: TreeSelectorInternals, data: string) {
		// Label editing uses the same component; do not intercept those keystrokes.
		if (this.labelInput || !this.treeList) {
			return originalHandleInput.call(this, data);
		}

		const list = this.treeList;
		const keybindings = getKeybindings();
		const query = list.getSearchQuery?.() ?? "";
		const searchActive = Boolean(list[SEARCH_ACTIVE]);
		const printable = isPlainPrintable(data);

		if (!searchActive && !query && printable) {
			if (data === "j") {
				moveTreeSelection(list, 1);
				return;
			}
			if (data === "k") {
				moveTreeSelection(list, -1);
				return;
			}
			if (data === "/") {
				list[SEARCH_ACTIVE] = true;
				return;
			}

			// Preserve printable built-in tree commands such as Shift+L and Shift+T.
			if (
				keybindings.matches(data, "app.tree.editLabel") ||
				keybindings.matches(data, "app.tree.toggleLabelTimestamp")
			) {
				return originalHandleInput.call(this, data);
			}

			// Default pi behavior starts searching on any printable character. Suppress
			// that until the user explicitly enters search mode with `/`.
			return;
		}

		if (searchActive && keybindings.matches(data, "tui.select.cancel")) {
			list[SEARCH_ACTIVE] = false;
			if (!query) return;
			return originalHandleInput.call(this, data);
		}

		if (searchActive && keybindings.matches(data, "tui.editor.deleteCharBackward") && !query) {
			list[SEARCH_ACTIVE] = false;
			return;
		}

		return originalHandleInput.call(this, data);
	};
}

function patchSessionSelector() {
	const prototype = SessionSelectorComponent.prototype as PatchableSessionSelectorPrototype;
	if (!prototype || prototype[SESSION_PATCHED]) return;

	const originalHandleInput = prototype.handleInput;
	prototype[SESSION_PATCHED] = true;
	prototype.handleInput = function (this: SessionSelectorInternals, data: string) {
		if (this.mode === "rename" || !this.sessionList) {
			return originalHandleInput.call(this, data);
		}

		const list = this.sessionList;
		if (list.confirmingDeletePath !== null && list.confirmingDeletePath !== undefined) {
			return originalHandleInput.call(this, data);
		}

		const keybindings = getKeybindings();
		const searchInput = list.searchInput;
		const query = searchInput?.getValue() ?? "";
		const searchActive = Boolean(list[SEARCH_ACTIVE]);
		const printable = isPlainPrintable(data);

		if (!searchActive && !query && printable) {
			if (data === "j") {
				moveSessionSelection(list, 1);
				return;
			}
			if (data === "k") {
				moveSessionSelection(list, -1);
				return;
			}
			if (data === "/") {
				list[SEARCH_ACTIVE] = true;
				return;
			}

			// Default pi behavior starts searching on any printable character. Suppress
			// that until the user explicitly enters search mode with `/`.
			return;
		}

		if (searchActive && keybindings.matches(data, "tui.select.cancel")) {
			list[SEARCH_ACTIVE] = false;
			if (query && searchInput && list.filterSessions) {
				searchInput.setValue("");
				list.filterSessions("");
			}
			return;
		}

		if (searchActive && keybindings.matches(data, "tui.editor.deleteCharBackward") && !query) {
			list[SEARCH_ACTIVE] = false;
			return;
		}

		return originalHandleInput.call(this, data);
	};
}

export default function (_pi: ExtensionAPI) {
	patchTreeSelector();
	patchSessionSelector();
}
