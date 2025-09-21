//
//  CompactSchema.swift
//  CompactSchema
//

import Foundation

/// A macro that generates compact, AI-optimized schema representations of Swift data structures.
///
/// CompactSchema automatically transforms your Swift structs and enums into minimal, token-efficient
/// schemas perfect for AI/LLM consumption. The generated schemas reduce documentation overhead by ~90%
/// while keeping your API docs perfectly synchronized with your code.
///
/// ## Usage
///
/// Apply the `@CompactSchema` macro to any struct or enum:
///
/// ```swift
/// @CompactSchema
/// struct UserProfile: Codable {
///     let username: String
///     let email: String?
///     let isVerified: Bool
///     let preferences: [String: Any]
/// }
///
/// // Automatically generates:
/// // UserProfile {
/// //   username: String
/// //   email: String?
/// //   isVerified: Bool
/// //   preferences: [String: Any]
/// // }
/// ```
///
/// ## Features
///
/// - **Zero Runtime Cost**: Generated at compile time
/// - **Always Synchronized**: Can't get out of sync with your code
/// - **Token Optimized**: 90% reduction in documentation tokens
/// - **AI-Friendly**: Perfect format for LLM context windows
/// - **Protocol-Aware**: Automatically excludes `description` and other protocol properties
///
/// ## Accessing Generated Schemas
///
/// The macro adds a static `compactSchema` property to your types:
///
/// ```swift
/// print(UserProfile.compactSchema)
/// ```
@attached(member, names: named(compactSchema))
public macro CompactSchema() = #externalMacro(module: "CompactSchemaMacros", type: "CompactSchemaMacro")
