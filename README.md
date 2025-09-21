# CompactSchema

Swift macro for generating token-optimized, AI-friendly documentation from your data structures.

## Overview

CompactSchema automatically transforms your Swift structs and enums into minimal, token-efficient schemas perfect for AI/LLM consumption. Reduce documentation overhead by 90% while keeping your API docs perfectly synchronized with your code.

```swift
@CompactSchema
struct UserProfile: Codable {
    let username: String
    let email: String?
    let isVerified: Bool
    let preferences: [String: Any]
}

// Automatically generates:
// UserProfile { username: String, email: String?, isVerified: Bool, preferences: [String: Any] }
```

## Features

- **Zero Runtime Cost** - Generated at compile time
- **Always Synchronized** - Can't get out of sync with your code
- **Token Optimized** - 90% reduction in documentation tokens
- **AI-Friendly** - Perfect format for LLM context windows
- **Simple API** - Just add `@CompactSchema` to any struct or enum
- **Protocol-Aware** - Automatically excludes `description` and other protocol properties

## Installation

### Swift Package Manager

Add CompactSchema to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/YourUsername/CompactSchema.git", from: "1.0.0")
]
```

Then add it to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: ["CompactSchema"]
)
```

### Xcode

1. File → Add Package Dependencies
2. Enter: `https://github.com/YourUsername/CompactSchema.git`
3. Add to your target

## Usage

### Basic Struct

```swift
import CompactSchema

@CompactSchema
struct Product: Codable {
    let id: String
    let name: String
    let price: Double?
    let categories: [String]
}

// Generated schema:
// Product { id: String, name: String, price: Double?, categories: [String] }
```

### Enum Support

```swift
@CompactSchema
enum Status: String, CaseIterable {
    case active = "active"
    case inactive = "inactive"
    case pending = "pending"
}

// Generated schema:
// enum Status: [active = "active" | inactive = "inactive" | pending = "pending"]
```

### Custom String Convertible (Handled Automatically)

```swift
@CompactSchema
struct User: Codable, CustomStringConvertible {
    let name: String
    let age: Int

    var description: String {
        return "\(name), age \(age)"
    }
}

// Generated schema (description property excluded):
// User { name: String, age: Int }
```

### Accessing Generated Schemas

```swift
// Individual schema
print(User.aiSchema)

// All schemas in your module (if using registry)
let allSchemas = getAllCompactSchemas()
```

## Token Efficiency

CompactSchema dramatically reduces token usage for AI documentation:

| Format | Tokens | Example |
|--------|--------|---------|
| Full Swift Struct | ~500 | `public struct UserProfile: Codable, Sendable { public let username: String; public let email: String?; ... }` |
| CompactSchema | ~50 | `UserProfile { username: String, email: String? }` |
| **Savings** | **90%** | Perfect for LLM context windows |

## Advanced Features

### JSON Field Mapping

CompactSchema respects your `CodingKeys` for accurate API documentation:

```swift
@CompactSchema
struct APIResponse: Codable {
    let userId: String
    let isActive: Bool

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case isActive = "is_active"
    }
}

// Generated schema:
// APIResponse { user_id: String, is_active: Bool }
```

### Integration with Documentation Systems

Generate complete API documentation by collecting all schemas:

```swift
// Individual schema access
let userSchema = User.aiSchema

// For batch processing, create a registry in your own project
// that collects all your @CompactSchema types
```

## Requirements

- Swift 5.9+
- Xcode 15.0+
- macOS 13.0+ / iOS 16.0+

## How It Works

CompactSchema uses Swift's macro system to analyze your types at compile time:

1. **Compile Time**: Macro analyzes struct/enum declarations
2. **Code Generation**: Creates minimal schema representations
3. **Protocol Filtering**: Automatically excludes computed properties and protocol requirements
4. **Zero Runtime Cost**: All work done during compilation

## Comparison

| Approach | Sync | Performance | Maintenance | Token Efficiency |
|----------|------|-------------|-------------|------------------|
| Manual Documentation | ❌ | ✅ | ❌ | ⚠️ |
| Runtime Reflection | ✅ | ❌ | ✅ | ⚠️ |
| **CompactSchema** | ✅ | ✅ | ✅ | ✅ |

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Related Projects

- [swift-syntax](https://github.com/apple/swift-syntax) - Swift's syntax analysis library
- Your other API packages that can benefit from CompactSchema

---

**Perfect for:** API documentation, AI/LLM integration, microservices, SDK documentation, code generation pipelines