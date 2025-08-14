# development guidelines

## philosophy

### key precepts

- **focus on incremental progress** - make small changes which make incremental progress to an objective
- **learning from existing code** - review the current state of the code base and assemble a plan before implementing
- **pragmatic over dogmatic** - adapt to project reality
- **clarity over cleverness** - be clear and obvious, avoid creating code we won't understand in a month

### simplicity

- single responsibility per function/class
- avoid premature abstractions
- no clever tricks - choose the boring solution
- if you need to explain it to me, it's too complex

## process

### 1. planning & staging

break complex work into 3-5 stages. document the plan in `IMPLEMENTATION-PLAN.md`:

```markdown
# <descriptive plan name>

start time: [start time for the task]
end time: [completion time for the task]

## overview

< provide an overview of the deliverable/objective >

## stage n: [name]
**goal**: [specific deliverable]
**success criteria**: [testable outcomes]
**tests**: [specific test cases]
**status**: [not started|in progress|complete]
```

- update status as you progress
- include a log of the commits at the bottom of the file.
- append the `IMPLEMENTATION-PLAN.md` file to the `WORKLOG.md` file at the root of the project.  

### 2. implementation flow

1. **understand** - study existing patterns in codebase
2. **test** - write test first (red)
3. **implement** - minimal code to pass (green)
4. **refactor** - clean up with tests passing
5. **commit** - with clear message linking to plan

### 3. when stuck (after 3 attempts)

**CRITICAL**: maximum 3 attempts per issue, then stop.

1. **document what failed**:
   - what you tried
   - specific error messages
   - why you think it failed

2. **research alternatives**:
   - find 2-3 similar implementations
   - note different approaches used

3. **question fundamentals**:
   - is this the right abstraction level?
   - can this be split into smaller problems?
   - is there a simpler approach entirely?

4. **try different angle**:
   - different library/framework feature?
   - different architectural pattern?
   - remove abstraction instead of adding?

## technical standards

### architecture principles

- **explicit over implicit** - clear data flow and dependencies
- **test-driven when possible** - never disable tests, fix them

### code quality

- **every commit must**:
  - compile successfully
  - pass all existing tests
  - include tests for new functionality
  - follow project formatting/linting

- **before committing**:
  - run formatters/linters, align with any tools already in the code base
  - self-review changes
  - ensure commit message explains "why"

### error handling

- fail fast with descriptive messages
- include context for debugging
- handle errors at appropriate level
- never silently swallow exceptions

## decision framework

when multiple valid approaches exist, choose based on:

1. **testability** - can i easily test this?
2. **readability** - will someone understand this in 6 months?
3. **consistency** - does this match project patterns?
4. **simplicity** - is this the simplest solution that works?
5. **reversibility** - how hard to change later?

## project integration

### learning the codebase

- find 3 similar features/components
- identify common patterns and conventions
- use same libraries/utilities when possible
- follow existing test patterns

### tooling

- use existing project build system
- use the project test framework
- use the project formatter/linter settings
- don't introduce new tools without strong justification

## quality validation

### done definition

- [ ] tests written and passing
- [ ] code follows project conventions
- [ ] no linter/formatter warnings
- [ ] commit messages are clear
- [ ] implementation matches plan
- [ ] no TODOs without issue numbers

### test guidelines

- test behavior, not implementation
- one assertion per test when possible
- clear test names describing scenario
- use existing test utilities/helpers
- tests should be deterministic

## important reminders

**NEVER**:
- use `--no-verify` to bypass commit hooks
- disable tests instead of fixing them
- commit code that doesn't compile
- make assumptions - verify with existing code

**ALWAYS**:
- commit working code incrementally
- update plan documentation as you go
- learn from existing implementations
- stop after 3 failed attempts and reassess the approach
