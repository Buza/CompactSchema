# CompactSchema

Swift macros for generating token-optimized, AI-friendly documentation from your data structures and API methods.

## Overview

CompactSchema automatically transforms your Swift structs, enums, and API methods into minimal, token-efficient documentation perfect for AI/LLM consumption. Reduce documentation overhead by 90% while keeping your API docs perfectly synchronized with your code.

```swift
// Document data structures
@CompactSchema
struct UserProfile: Codable {
    let username: String
    let email: String?
    let isVerified: Bool
    let preferences: [String: Any]
}
// Generates: UserProfile { username: String, email: String?, isVerified: Bool, preferences: [String: Any] }

// Document individual API methods
@CompactMethod
public func getUserInfo() async throws -> UserProfile {
    // implementation
}
// Generates: getUserInfoMethod = "getUserInfo() async throws -> UserProfile"

// Document entire API classes
@CompactAPIMethods
public class UserAPI {
    public func getUserInfo() async throws -> UserProfile { ... }
    public func updateProfile(_ request: UpdateRequest) async throws -> UserProfile { ... }
}
// Generates: compactMethods = ["getUserInfo() async throws -> UserProfile", "updateProfile(UpdateRequest) async throws -> UserProfile"]
```

## Features

### Data Structure Documentation (@CompactSchema)
- **Zero Runtime Cost** - Generated at compile time
- **Always Synchronized** - Can't get out of sync with your code
- **Token Optimized** - 90% reduction in documentation tokens
- **AI-Friendly** - Perfect format for LLM context windows
- **Protocol-Aware** - Automatically excludes `description` and other protocol properties

### API Method Documentation (@CompactMethod & @CompactAPIMethods)
- **Individual Method Tracking** - Document specific methods with `@CompactMethod`
- **Bulk Class Documentation** - Document all public methods with `@CompactAPIMethods`
- **Type Integration** - Seamlessly references `@CompactSchema` types
- **Compressed Signatures** - 70-90% token reduction vs full method signatures
- **Access Control Aware** - Only documents public/open methods

### Registry & Integration
- **Centralized Collection** - `CompactMethodRegistry` for gathering all documented methods
- **Complete Documentation** - `CompactDocumentation` combines data schemas and method signatures
- **LLM-Optimized Output** - Perfect format for AI tool consumption

## Installation

### Swift Package Manager

Add CompactSchema to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/buza/CompactSchema.git", from: "1.0.0")
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
2. Enter: `https://github.com/buza/CompactSchema.git`
3. Add to your target

## Usage

### Data Structure Documentation

#### Basic Struct

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

#### Enum Support

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

### API Method Documentation

#### Individual Methods

```swift
@CompactMethod
public func getUserInfo() async throws -> UserProfile {
    // implementation
}

@CompactMethod
public func updateProfile(_ request: UpdateProfileRequest) async throws -> UserProfile {
    // implementation
}

@CompactMethod
public func deleteUser(_ id: String) -> Void {
    // implementation
}

// Accessing generated signatures:
print(getUserInfoMethod)      // "getUserInfo() async throws -> UserProfile"
print(updateProfileMethod)    // "updateProfile(UpdateProfileRequest) async throws -> UserProfile"
print(deleteUserMethod)       // "deleteUser(String)"
```

#### Entire API Classes

```swift
@CompactAPIMethods
public class UserAPI {
    public func getUserInfo() async throws -> UserProfile {
        // implementation
    }

    public func updateProfile(_ request: UpdateProfileRequest) async throws -> UserProfile {
        // implementation
    }

    public func createAccount(_ request: CreateAccountRequest) async throws -> UserProfile {
        // implementation
    }

    // Private methods are automatically excluded
    private func validateRequest() { ... }
}

// Accessing all method signatures:
print(UserAPI.compactMethods)
// Output: [
//   "getUserInfo() async throws -> UserProfile",
//   "updateProfile(UpdateProfileRequest) async throws -> UserProfile",
//   "createAccount(CreateAccountRequest) async throws -> UserProfile"
// ]
```

### Complete API Documentation

```swift
// Generate comprehensive documentation combining data schemas and method signatures
let documentation = CompactDocumentation.getCompleteDocumentation()

// Output:
// # API Documentation
//
// ## Methods
// getUserInfo() async throws -> UserProfile
// updateProfile(UpdateProfileRequest) async throws -> UserProfile
// createAccount(CreateAccountRequest) async throws -> UserProfile
//
// ## Data Models
// UserProfile { id: String, username: String, email: String? }
// UpdateProfileRequest { username: String?, email: String? }
// CreateAccountRequest { username: String, email: String, password: String }
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

### Accessing Generated Documentation

```swift
// Individual data schema
print(User.compactSchema)

// Individual method signatures (from @CompactMethod)
print(getUserInfoMethod)
print(updateProfileMethod)

// All methods from a class (from @CompactAPIMethods)
print(UserAPI.compactMethods)

// Complete documentation combining everything
let completeDoc = CompactDocumentation.getCompleteDocumentation()

// Registry access (for future extensions)
let allMethods = CompactMethodRegistry.getAllMethods()
let methodsByCategory = CompactMethodRegistry.getMethodsByCategory()
```

## Token Efficiency

CompactSchema dramatically reduces token usage for AI documentation:

### Data Structure Documentation
| Format | Tokens | Example |
|--------|--------|---------|
| Full Swift Struct | ~500 | `public struct UserProfile: Codable, Sendable { public let username: String; public let email: String?; ... }` |
| @CompactSchema | ~50 | `UserProfile { username: String, email: String? }` |
| **Savings** | **90%** | Perfect for LLM context windows |

### API Method Documentation
| Format | Tokens | Example |
|--------|--------|---------|
| Full Method Signature | ~200 | `public func updateUserProfile(_ request: UpdateUserProfileRequest) async throws -> UserProfileResponse` |
| @CompactMethod | ~30 | `updateUserProfile(UpdateUserProfileRequest) async throws -> UserProfileResponse` |
| **Savings** | **85%** | Compressed for AI consumption |

### Complete API Documentation
When documenting an entire API with 20 methods and 15 data types:
- **Traditional Documentation**: ~15,000 tokens
- **CompactSchema + CompactMethod**: ~1,500 tokens
- **Total Savings**: **90%** token reduction

## Advanced Features

### Method Documentation Patterns

#### Async/Throws Optimization
```swift
@CompactMethod
public func fetchData() async throws -> Data {
    // Full signature preserved for clarity
}
// Output: "fetchData() async throws -> Data"

@CompactMethod
public func syncOperation() -> String {
    // Sync methods remain concise
}
// Output: "syncOperation() -> String"
```

#### Parameter Compression
```swift
@CompactMethod
public func updateUser(_ id: String, with request: UpdateRequest) async throws -> User {
    // Parameter labels removed for token efficiency
}
// Output: "updateUser(String, UpdateRequest) async throws -> User"
```

#### Integration with @CompactSchema Types
```swift
@CompactSchema
struct UserRequest {
    let name: String
    let email: String
}

@CompactMethod
public func createUser(_ request: UserRequest) async throws -> User {
    // References CompactSchema types automatically
}
// Output: "createUser(UserRequest) async throws -> User"
// UserRequest schema also available via UserRequest.compactSchema
```

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

### Complete Documentation Pipeline

```swift
// 1. Document your data models
@CompactSchema
struct User { let id: String, name: String }

@CompactSchema
struct CreateUserRequest { let name: String, email: String }

// 2. Document your API methods
@CompactAPIMethods
public class UserAPI {
    public func getUser(_ id: String) async throws -> User { ... }
    public func createUser(_ request: CreateUserRequest) async throws -> User { ... }
}

// 3. Generate complete documentation
let documentation = CompactDocumentation.getCompleteDocumentation()

// 4. Perfect for AI tool consumption
// Feed `documentation` to your LLM for API understanding
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

| Approach | Sync | Performance | Maintenance | Token Efficiency | Method Support |
|----------|------|-------------|-------------|------------------|----------------|
| Manual Documentation | ❌ | ✅ | ❌ | ⚠️ | ❌ |
| Runtime Reflection | ✅ | ❌ | ✅ | ⚠️ | ⚠️ |
| OpenAPI/Swagger | ⚠️ | ✅ | ⚠️ | ❌ | ✅ |
| **CompactSchema Suite** | ✅ | ✅ | ✅ | ✅ | ✅ |

### What's Included

- **@CompactSchema**: Data structure documentation (structs, enums)
- **@CompactMethod**: Individual method signature documentation
- **@CompactAPIMethods**: Bulk class method documentation
- **CompactMethodRegistry**: Centralized method collection
- **CompactDocumentation**: Integrated data + method documentation

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Related Projects

- [swift-syntax](https://github.com/apple/swift-syntax) - Swift's syntax analysis library
- Your other API packages that can benefit from CompactSchema

---

**Perfect for:**
- **API Documentation**: Complete data structure + method signature documentation
- **AI/LLM Integration**: Token-optimized format for AI tool consumption
- **Microservices**: Document service interfaces efficiently
- **SDK Documentation**: Auto-generated, always-current API docs
- **Code Generation**: Feed compressed schemas to code generators
- **Developer Tools**: Build AI-powered development assistants with complete API understanding
