# Code Context

## Files Retrieved
1. `/home/jonco/.local/share/mise/installs/node/24.11.1/lib/node_modules/@earendil-works/pi-coding-agent/README.md` (lines 29, 148, 287-290, 559-567, 626-630) - documented modes, startup header, resource flags, env flags.
2. `/home/jonco/.local/share/mise/installs/node/24.11.1/lib/node_modules/@earendil-works/pi-coding-agent/docs/usage.md` (lines 93-101, 194-202, 258-275) - context/resource flags and explicit “no built-in MCP” statement.
3. `/home/jonco/.local/share/mise/installs/node/24.11.1/lib/node_modules/@earendil-works/pi-coding-agent/docs/settings.md` (lines 7-8, 42-55, 148-170, 192-231) - settings locations, quiet/offline/telemetry, npmCommand, packages/resources settings.
4. `/home/jonco/.local/share/mise/installs/node/24.11.1/lib/node_modules/@earendil-works/pi-coding-agent/package.json` (lines 1-10) - `pi` bin points to `dist/cli.js`.
5. `/home/jonco/.local/share/mise/installs/node/24.11.1/lib/node_modules/@earendil-works/pi-coding-agent/dist/cli.js` (lines 8-19) - CLI process setup then `main()`.
6. `/home/jonco/.local/share/mise/installs/node/24.11.1/lib/node_modules/@earendil-works/pi-coding-agent/dist/main.js` (lines 321-565) - startup sequence, timing labels, benchmark path, interactive dispatch.
7. `/home/jonco/.local/share/mise/installs/node/24.11.1/lib/node_modules/@earendil-works/pi-coding-agent/dist/core/agent-session-services.js` (lines 57-81, 100) - creates settings/model/resource services and registers extension providers.
8. `/home/jonco/.local/share/mise/installs/node/24.11.1/lib/node_modules/@earendil-works/pi-coding-agent/dist/core/resource-loader.js` (lines 210-330, 344-416, 661-678) - reloads settings/packages/extensions/skills/prompts/themes/context/system prompt.
9. `/home/jonco/.local/share/mise/installs/node/24.11.1/lib/node_modules/@earendil-works/pi-coding-agent/dist/core/package-manager.js` (lines 655-688, 938-989, 1600-1629, 1730-1799, 1851-1866) - package/resource resolution and auto-discovery.
10. `/home/jonco/.local/share/mise/installs/node/24.11.1/lib/node_modules/@earendil-works/pi-coding-agent/dist/core/extensions/loader.js` (lines 119-158, 169-279, 285-326, 346-358) - jiti extension loading and registration API.
11. `/home/jonco/.local/share/mise/installs/node/24.11.1/lib/node_modules/@earendil-works/pi-coding-agent/dist/core/skills.js` (lines 129-237, 261-284, 309-389) - skill discovery/parsing and prompt formatting.
12. `/home/jonco/.local/share/mise/installs/node/24.11.1/lib/node_modules/@earendil-works/pi-coding-agent/dist/core/sdk.js` (lines 83-100, 115-146, 190-261) - `createAgentSession()` builds model/agent/session.
13. `/home/jonco/.local/share/mise/installs/node/24.11.1/lib/node_modules/@earendil-works/pi-coding-agent/dist/core/agent-session.js` (lines 115-136, 568-676, 1608-1639, 1784-1893) - runtime/tools/system prompt/extension runner construction and extension session events.
14. `/home/jonco/.local/share/mise/installs/node/24.11.1/lib/node_modules/@earendil-works/pi-coding-agent/dist/modes/interactive/interactive-mode.js` (lines 204-247, 381-454, 487-543, 1094-1199) - TUI object creation, first `ui.start()`, extension binding, prompt loop.
15. `/home/jonco/.local/share/mise/installs/node/24.11.1/lib/node_modules/@earendil-works/pi-coding-agent/dist/core/timings.js` (lines 1-24) - `PI_TIMING=1` startup timing instrumentation.
16. `/home/jonco/.local/share/mise/installs/node/24.11.1/lib/node_modules/@earendil-works/pi-coding-agent/dist/utils/tools-manager.js` (lines 1-18, 80-96, 221-250) - fd/rg lookup/download and `PI_OFFLINE` guard.

## Key Code

Startup entry:

```js
// dist/cli.js:11-19
process.title = APP_NAME;
process.env.PI_CODING_AGENT = "true";
process.emitWarning = (() => { });
setGlobalDispatcher(new EnvHttpProxyAgent({ bodyTimeout: 0, headersTimeout: 0 }));
main(process.argv.slice(2));
```

Main startup path before interactive mode:

```js
// dist/main.js:321-507, abridged
resetTimings();
const offlineMode = args.includes("--offline") || isTruthyEnvFlag(process.env.PI_OFFLINE);
if (offlineMode) { process.env.PI_OFFLINE = "1"; process.env.PI_SKIP_VERSION_CHECK = "1"; }
await handlePackageCommand(args); await handleConfigCommand(args);
const parsed = parseArgs(args); time("parseArgs");
runMigrations(process.cwd()); time("runMigrations");
const startupSettingsManager = SettingsManager.create(cwd, agentDir);
let sessionManager = await createSessionManager(...); time("createSessionManager");
const runtime = await createAgentSessionRuntime(createRuntime, ...);
stdinContent = await readPipedStdin(); time("readPipedStdin");
await prepareInitialMessage(...); time("prepareInitialMessage");
initTheme(settingsManager.getTheme(), appMode === "interactive"); time("initTheme");
```

Resource/config loading:

```js
// dist/core/agent-session-services.js:57-65
const settingsManager = SettingsManager.create(cwd, agentDir);
const modelRegistry = ModelRegistry.create(authStorage, join(agentDir, "models.json"));
const resourceLoader = new DefaultResourceLoader({ cwd, agentDir, settingsManager, ... });
await resourceLoader.reload();
```

```js
// dist/core/resource-loader.js:210-330, abridged
await this.settingsManager.reload();
const resolvedPaths = await this.packageManager.resolve();
const cliExtensionPaths = await this.packageManager.resolveExtensionSources(...);
const extensionsResult = await loadExtensions(extensionPaths, this.cwd, this.eventBus);
this.updateSkillsFromPaths(skillPaths, metadataByPath);
this.updatePromptsFromPaths(promptPaths, metadataByPath);
this.updateThemesFromPaths(themePaths, metadataByPath);
this.agentsFiles = this.noContextFiles ? [] : loadProjectContextFiles({ cwd, agentDir });
this.systemPrompt = resolvePromptInput(this.systemPromptSource ?? this.discoverSystemPromptFile(), ...);
this.appendSystemPrompt = ...discoverAppendSystemPromptFile()...
```

Extension load runs factories during startup:

```js
// dist/core/extensions/loader.js:317-326
const factory = await loadExtensionModule(resolvedPath);
const extension = createExtension(extensionPath, resolvedPath);
const api = createExtensionAPI(extension, runtime, cwd, eventBus);
await factory(api);
```

First TUI render vs first prompt:

```js
// dist/modes/interactive/interactive-mode.js:381-454
this.changelogMarkdown = this.getChangelogForDisplay();
const [fdPath] = await Promise.all([ensureTool("fd"), ensureTool("rg")]);
// build header/layout...
this.ui.start();              // first TUI render starts here
this.isInitialized = true;
await this.rebindCurrentSession(); // extension session_start/resources_discover after UI start
this.renderInitialMessages();
```

```js
// dist/modes/interactive/interactive-mode.js:487-543
await this.init();
checkForNewPiVersion(...);          // async after init
this.checkForPackageUpdates(...);   // async after init
while (true) {
  const userInput = await this.getUserInput(); // first interactive prompt wait
  await this.session.prompt(userInput);
}
```

Built-in tracing:

```js
// dist/core/timings.js:1-24
const ENABLED = process.env.PI_TIMING === "1";
export function time(label) { ... }
export function printTimings() { console.error("--- Startup Timings ---"); ... }
```

```js
// dist/main.js:523-553
const startupBenchmark = isTruthyEnvFlag(process.env.PI_STARTUP_BENCHMARK);
if (startupBenchmark && appMode !== "interactive") error;
if (startupBenchmark) {
  await interactiveMode.init();
  time("interactiveMode.init");
  printTimings();
  interactiveMode.stop();
  return;
}
```

## Architecture

`package.json` maps the global `pi` command to `dist/cli.js`. `cli.js` sets process title/env, disables Node warnings, configures undici proxy/timeouts, then calls `main()`.

`main()` handles global startup work before any TUI: package/config subcommands, arg parse, mode resolution, migrations, startup settings/session lookup, then `createAgentSessionRuntime()`. Runtime creation calls `createAgentSessionServices()`, which creates `AuthStorage` (`~/.pi/agent/auth.json`), `SettingsManager` (`~/.pi/agent/settings.json` plus `.pi/settings.json`), `ModelRegistry` (`~/.pi/agent/models.json` plus built-ins), and `DefaultResourceLoader`.

`DefaultResourceLoader.reload()` is the central config/resource loader. It reloads settings, resolves installed/configured packages and local resources through `DefaultPackageManager`, loads extensions via jiti, registers providers queued by extension load, applies extension CLI flags, loads skills/prompts/themes, discovers `AGENTS.md`/`CLAUDE.md`, and resolves `SYSTEM.md`/`APPEND_SYSTEM.md`.

`DefaultPackageManager.resolve()` merges project settings before global settings, installs missing npm/git package resources unless offline, resolves explicit `packages`, `extensions`, `skills`, `prompts`, `themes`, then auto-discovers project `.pi/{extensions,skills,prompts,themes}`, user `~/.pi/agent/{extensions,skills,prompts,themes}`, project ancestor `.agents/skills`, and user `~/.agents/skills`.

`createAgentSession()` builds the core `Agent`; `AgentSession` constructor creates built-in tool definitions, wraps extension/custom tools, creates `ExtensionRunner`, sets active tools, and builds the system prompt from selected tools, loaded context files, and loaded skills. Extension `session_start` and `resources_discover` are not emitted in the constructor; in interactive mode they happen inside `InteractiveMode.rebindCurrentSession()` after `ui.start()` but before the first `getUserInput()` prompt wait.

MCP: grep found no built-in MCP loader in `dist/` (only unrelated syntax-highlighter text). Docs explicitly say Pi “intentionally does not include built-in MCP” (`docs/usage.md:275`). MCP can only be added as an extension/package, so startup cost would be under extension loading/factory code and any `session_start` handlers.

Network/startup notes: `--offline` or `PI_OFFLINE=1` sets both `PI_OFFLINE` and `PI_SKIP_VERSION_CHECK` in `main.js:322-325`. Before first TUI render, package resolution may install missing npm/git packages unless offline, and `InteractiveMode.init()` may download `fd`/`rg` unless already present or offline. Version/package update checks are launched asynchronously after `init()` in `InteractiveMode.run()`.

## Start Here

Open `/home/jonco/.local/share/mise/installs/node/24.11.1/lib/node_modules/@earendil-works/pi-coding-agent/dist/main.js` first. It is the top-level ordered startup path and points to the service/resource/session/TUI branches.

## Commands to profile startup

Use a pseudo-TTY because `PI_STARTUP_BENCHMARK` only works in interactive mode; non-TTY stdin forces print mode.

```bash
# Built-in timing; initializes interactive UI, prints timings, exits before first prompt.
script -qfec 'PI_TIMING=1 PI_STARTUP_BENCHMARK=1 PI_OFFLINE=1 pi --no-session' /dev/null

# Same, but disable resource/context discovery to isolate baseline harness startup.
script -qfec 'PI_TIMING=1 PI_STARTUP_BENCHMARK=1 PI_OFFLINE=1 pi --no-session --no-extensions --no-skills --no-prompt-templates --no-themes --no-context-files' /dev/null

# Add wall-clock/RSS around the built-in benchmark.
/usr/bin/time -f "elapsed=%E maxrss=%MKB" script -qfec 'PI_TIMING=1 PI_STARTUP_BENCHMARK=1 PI_OFFLINE=1 pi --no-session' /dev/null

# Node CPU profile for the installed package.
mkdir -p /tmp/pi-prof
script -qfec 'PI_TIMING=1 PI_STARTUP_BENCHMARK=1 PI_OFFLINE=1 node --cpu-prof --cpu-prof-dir=/tmp/pi-prof /home/jonco/.local/share/mise/installs/node/24.11.1/lib/node_modules/@earendil-works/pi-coding-agent/dist/cli.js --no-session' /dev/null
ls -lh /tmp/pi-prof
```

## Supervisor coordination

No blocker. The only ambiguity is whether “before first TUI render” or “before first interactive prompt” is the boundary; this report separates them. Extension `session_start`/`resources_discover` run after first `ui.start()` but before the prompt loop.
