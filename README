# Baggage Conveyor
------------

A conveyor system for spawning and animating bags with client-server synchronization.



I decided to use charm at the forefront of this system for it's immutable state replication. I think any state library can work here but charm is what i'm most familiar with. The reason i went with a state library instead of remotes was to showcase my ability to work in a larger codebase which would (or should) have proper state management.

## Key Dependencies

| Package | Purpose |
|---------|---------|
| **Charm** | Reactive state container for conveyor data |
| **CharmSync** | Automatic client-server state synchronization |
| **Flipper** | Smooth animation of bag position, scale, and rotation |
| **Zap** | Optimized network protocol for remote calls |
| **Promise** | Async/await-style promise library |
| **GreenTea** | Testing framework |
| **Tooling** | Selene (linter), StyLua(formatter), Lune (scripting)






## Workflow

Install the necessary tools with rokit

```luau
rokit install
```

Build the place file (You will need to launch it manually from your file system)

```luau
lune run build
```

Start a local development session
```luau
lune run serve
```

Save any asset changes from studio (remember to save the file first!)

```luau
lune run syncback
```
## Acknowledgements

 - I slightly modified these [lune scripts](https://github.com/Josephh310/Rojo-Tools/tree/main#installation). It's been a while since i worked on a fully managed project and this saved me from rewritting my own outdated lune workflow.
