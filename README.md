# Design Patterns in Vim9script

A comprehensive collection of 22 Gang of Four design patterns implemented in modern **Vim9script**. This project demonstrates how classic software design patterns can be applied using Vim9's object-oriented features including classes, interfaces, abstract classes, enums, and type aliases.

## Overview

This project provides educational examples of design patterns across three main categories:

- **Creational Patterns** (5): Deal with object creation mechanisms
- **Behavioral Patterns** (10): Focus on communication between objects
- **Structural Patterns** (7): Address object composition and relationships

Each pattern is implemented with:
- Clear, well-commented Vim9script code
- Practical examples demonstrating real-world usage
- Comprehensive README with pattern explanation and references
- Modern language features (classes, interfaces, type safety)

## Project Structure

```
design-patterns/
├── README.md                          # This file
├── run_all_tests.vim                  # Script to run all pattern demos
├── creational-patterns/               # Object creation patterns
│   ├── abstract-factory/              # Create families of related objects
│   ├── builder/                       # Construct complex objects step-by-step
│   ├── factory-method/                # Create objects without specifying classes
│   ├── prototype/                     # Clone existing objects
│   └── singleton/                     # Ensure single instance
├── behavioral-patterns/               # Object communication patterns
│   ├── chain-of-responsibility/       # Pass requests along a chain
│   ├── command/                       # Encapsulate requests as objects
│   ├── iterator/                      # Traverse collections uniformly
│   ├── mediator/                      # Centralize object communication
│   ├── memento/                       # Capture and restore state
│   ├── observer/                      # Notify observers of state changes
│   ├── state/                         # Change behavior with state
│   ├── strategy/                      # Swap algorithms at runtime
│   ├── template-method/               # Define algorithm skeleton
│   └── visitor/                       # Add operations without modifying objects
└── structural-patterns/               # Object composition patterns
    ├── adapter/                       # Convert incompatible interfaces
    ├── bridge/                        # Separate abstraction from implementation
    ├── composite/                     # Treat individual and composite objects uniformly
    ├── decorator/                     # Add behavior dynamically
    ├── facade/                        # Provide simplified interface
    ├── flyweight/                     # Share objects to reduce memory
    └── proxy/                         # Control access to another object
```

## Pattern Categories

### Creational Patterns (5)

These patterns provide object creation mechanisms that increase flexibility and reuse.

| Pattern | Purpose |
|---------|---------|
| [Abstract Factory](creational-patterns/abstract-factory/) | Create families of related objects without specifying concrete classes |
| [Builder](creational-patterns/builder/) | Construct complex objects step by step |
| [Factory Method](creational-patterns/factory-method/) | Create objects without specifying their exact classes |
| [Prototype](creational-patterns/prototype/) | Create new objects by cloning existing ones |
| [Singleton](creational-patterns/singleton/) | Ensure a class has only one instance |

### Behavioral Patterns (10)

These patterns focus on object collaboration and responsibility distribution.

| Pattern | Purpose |
|---------|---------|
| [Chain of Responsibility](behavioral-patterns/chain-of-responsibility/) | Pass requests along a chain of handlers |
| [Command](behavioral-patterns/command/) | Encapsulate requests as objects |
| [Iterator](behavioral-patterns/iterator/) | Traverse collections without exposing structure |
| [Mediator](behavioral-patterns/mediator/) | Centralize communication between objects |
| [Memento](behavioral-patterns/memento/) | Capture and externalize object state |
| [Observer](behavioral-patterns/observer/) | Notify multiple observers of state changes |
| [State](behavioral-patterns/state/) | Change behavior based on internal state |
| [Strategy](behavioral-patterns/strategy/) | Encapsulate interchangeable algorithms |
| [Template Method](behavioral-patterns/template-method/) | Define algorithm skeleton in base class |
| [Visitor](behavioral-patterns/visitor/) | Add operations without modifying objects |

### Structural Patterns (7)

These patterns address how objects and classes can be combined to form larger structures.

| Pattern | Purpose |
|---------|---------|
| [Adapter](structural-patterns/adapter/) | Convert interface to one clients expect |
| [Bridge](structural-patterns/bridge/) | Separate abstraction from implementation |
| [Composite](structural-patterns/composite/) | Treat individual and composite objects uniformly |
| [Decorator](structural-patterns/decorator/) | Add behavior to objects dynamically |
| [Facade](structural-patterns/facade/) | Provide simplified interface to subsystem |
| [Flyweight](structural-patterns/flyweight/) | Share objects to reduce memory usage |
| [Proxy](structural-patterns/proxy/) | Control access to another object |

## Getting Started

### Requirements

- **Vim 9.0 or later** (for Vim9script class support)
- No external dependencies

### Running Examples

Each pattern directory contains:
- `pattern_name.vim` - Implementation with example code
- `README.md` - Pattern explanation and usage guide

To run a specific pattern example:

```vim
:source creational-patterns/singleton/singleton_pattern.vim
:call g:RunSingletonPatternDemo()
```

To run all pattern demos:

```vim
:source run_all_tests.vim
```

### Exploring a Pattern

1. Navigate to the pattern directory
2. Read the `README.md` for pattern explanation
3. Review the `.vim` file for implementation details
4. Run the demo to see the pattern in action

Example for Observer pattern:

```vim
:source behavioral-patterns/observer/observer_pattern.vim
:call g:RunObserverPatternDemo()
```

## Features

### Modern Vim9 Language Features

Each example demonstrates:
- **Classes and Inheritance** - Object-oriented programming
- **Interfaces** - Contract definitions for implementations
- **Abstract Classes** - Base classes with abstract methods
- **Enums** - Type-safe enumeration values
- **Type Aliases** - Semantic type naming
- **Type Annotations** - Compile-time type checking

### Educational Value

- Clear naming conventions
- Practical, relatable examples
- Real-world use cases
- Side-by-side pattern comparisons
- References to Gang of Four book with page numbers

## References

For deeper understanding of design patterns:

- **Refactoring.Guru** - [Design Patterns](https://refactoring.guru/design-patterns) - Interactive patterns with code examples
- **Gang of Four Book** - "Design Patterns: Elements of Reusable Object-Oriented Software" by Gamma, Helm, Johnson, Vlissides
- **SourceMaking** - [Design Patterns](https://sourcemaking.com/design_patterns)
- **Wikipedia** - [Software Design Patterns](https://en.wikipedia.org/wiki/Software_design_pattern)

## Credits

These design pattern examples were generated by **GitHub Copilot** to demonstrate modern Vim9script capabilities and software design principles. The project serves as both an educational resource and a showcase of idiomatic Vim9 code.

## License

MIT License - Feel free to use this for learning and teaching design patterns!

See [LICENSE](LICENSE) file for details.

## Contributing

This is an educational project. If you find issues or have suggestions, feel free to open an issue or pull request.

## Acknowledgments

- Gang of Four (Gamma, Helm, Johnson, Vlissides) for the original design patterns
- The Vim community for creating Vim9script with powerful OOP features
- GitHub Copilot for generating these comprehensive examples

## Quick Links

- [Vim9script Documentation](https://github.com/vim/vim/blob/master/runtime/doc/vim9.txt)
- [Vim Official Website](https://www.vim.org/)
- [Design Patterns Overview](https://en.wikipedia.org/wiki/Software_design_pattern)

---

**Happy Learning!** Explore, understand, and apply these timeless design patterns in your own Vim9script projects.
