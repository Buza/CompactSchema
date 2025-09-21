//
//  CompactSchemaMacro.swift
//  CompactSchema
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct CompactSchemaPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        CompactSchemaMacro.self,
        CompactMethodMacro.self,
        CompactAPIMethodsMacro.self,
    ]
}

public struct CompactSchemaMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        // Handle structs
        if let structDecl = declaration.as(StructDeclSyntax.self) {
            let structName = structDecl.name.text
            let fields = extractFields(from: structDecl)
            let schemaString = generateCompactSchema(structName: structName, fields: fields)

            let member: DeclSyntax = """
            /// Compact Schema - Minimal token representation for AI tools
            public static let compactSchema = \"\"\"
            \(raw: schemaString)
            \"\"\"
            """

            return [member]
        }

        // Handle enums
        if let enumDecl = declaration.as(EnumDeclSyntax.self) {
            let enumName = enumDecl.name.text
            let cases = extractCases(from: enumDecl)
            let schemaString = generateEnumSchema(enumName: enumName, cases: cases)

            let member: DeclSyntax = """
            /// Compact Schema - Minimal token representation for AI tools
            public static let compactSchema = \"\"\"
            \(raw: schemaString)
            \"\"\"
            """

            return [member]
        }

        return []
    }

    private static func extractFields(from structDecl: StructDeclSyntax) -> [(name: String, type: String, optional: Bool)] {
        var fields: [(name: String, type: String, optional: Bool)] = []

        // Protocol properties to exclude from schema
        let protocolProperties: Set<String> = [
            "description",      // CustomStringConvertible
            "debugDescription", // CustomDebugStringConvertible
            "hashValue"        // Hashable (deprecated but might appear)
        ]

        for member in structDecl.memberBlock.members {
            if let variableDecl = member.decl.as(VariableDeclSyntax.self) {
                // Skip computed properties (ones with get/set blocks)
                let hasAccessorBlock = variableDecl.bindings.contains { binding in
                    binding.accessorBlock != nil
                }

                if hasAccessorBlock {
                    continue
                }

                for binding in variableDecl.bindings {
                    if let pattern = binding.pattern.as(IdentifierPatternSyntax.self),
                       let typeAnnotation = binding.typeAnnotation?.type {

                        let fieldName = pattern.identifier.text

                        // Skip known protocol properties
                        if protocolProperties.contains(fieldName) {
                            continue
                        }

                        let (cleanType, isOptional) = parseType(typeAnnotation)

                        fields.append((name: fieldName, type: cleanType, optional: isOptional))
                    }
                }
            }
        }

        return fields
    }

    private static func parseType(_ type: TypeSyntax) -> (type: String, optional: Bool) {
        let typeText = type.description.trimmingCharacters(in: .whitespacesAndNewlines)

        if typeText.hasSuffix("?") {
            return (String(typeText.dropLast()), true)
        } else if typeText.hasPrefix("Optional<") && typeText.hasSuffix(">") {
            let innerType = String(typeText.dropFirst(9).dropLast())
            return (innerType, true)
        }

        // Clean up common array and dictionary types
        let cleanedType = typeText
            .replacingOccurrences(of: "Array<", with: "[")
            .replacingOccurrences(of: ">", with: "]")
            .replacingOccurrences(of: "Dictionary<", with: "[")
            .replacingOccurrences(of: ", ", with: ": ")

        return (cleanedType, false)
    }

    private static func generateCompactSchema(structName: String, fields: [(name: String, type: String, optional: Bool)]) -> String {
        let fieldLines = fields.map { field in
            let optionalIndicator = field.optional ? "?" : ""
            return "\(field.name): \(field.type)\(optionalIndicator)"
        }

        return """
        \(structName) {
        \(fieldLines.map { "  " + $0 }.joined(separator: "\n"))
        }
        """
    }

    private static func extractCases(from enumDecl: EnumDeclSyntax) -> [(name: String, value: String?)] {
        var cases: [(name: String, value: String?)] = []

        for member in enumDecl.memberBlock.members {
            if let caseDecl = member.decl.as(EnumCaseDeclSyntax.self) {
                for element in caseDecl.elements {
                    let caseName = element.name.text
                    var caseValue: String? = nil

                    if let rawValue = element.rawValue {
                        // Extract the raw value (e.g., = "asc")
                        let valueText = rawValue.value.description.trimmingCharacters(in: .whitespacesAndNewlines)
                        caseValue = valueText
                    }

                    cases.append((name: caseName, value: caseValue))
                }
            }
        }

        return cases
    }

    private static func generateEnumSchema(enumName: String, cases: [(name: String, value: String?)]) -> String {
        let caseLines = cases.map { enumCase in
            if let value = enumCase.value {
                return "\(enumCase.name) = \(value)"
            } else {
                return enumCase.name
            }
        }

        return """
        enum \(enumName): [\(caseLines.joined(separator: " | "))]
        """
    }
}

public struct CompactMethodMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        // The declaration should be a function declaration
        guard let functionDecl = declaration.as(FunctionDeclSyntax.self) else {
            throw MacroError.invalidDeclaration("@CompactMethod can only be applied to functions")
        }

        // Generate the compact method signature
        let compactSignature = generateCompactMethodSignature(from: functionDecl)

        // Create a static property name based on the function name
        let propertyName = "\(functionDecl.name.text)Method"

        let peer: DeclSyntax = """
        /// Compact Method - Generated by @CompactMethod macro
        public static let \(raw: propertyName) = \"\(raw: compactSignature)\"
        """

        return [peer]
    }

    private static func generateCompactMethodSignature(from functionDecl: FunctionDeclSyntax) -> String {
        return MethodSignatureGenerator.generateCompactMethodSignature(from: functionDecl)
    }
}

public struct CompactAPIMethodsMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        // Extract all public functions from the declaration
        let publicMethods = extractPublicMethods(from: declaration)

        // Generate compact signatures for all methods
        let compactSignatures = publicMethods.map { generateCompactMethodSignature(from: $0) }

        // Create the static compactMethods array
        let methodsArray = compactSignatures.map { "\"\($0)\"" }.joined(separator: ",\n        ")

        let member: DeclSyntax = """
        /// Compact Methods - Generated by @CompactAPIMethods macro
        public static let compactMethods: [String] = [
            \(raw: methodsArray)
        ]
        """

        return [member]
    }

    private static func extractPublicMethods(from declaration: some DeclGroupSyntax) -> [FunctionDeclSyntax] {
        var publicMethods: [FunctionDeclSyntax] = []

        for member in declaration.memberBlock.members {
            if let functionDecl = member.decl.as(FunctionDeclSyntax.self) {
                // Check if the function is public or open
                let isPublic = functionDecl.modifiers.contains { modifier in
                    modifier.name.text == "public" || modifier.name.text == "open"
                }

                if isPublic {
                    publicMethods.append(functionDecl)
                }
            }
        }

        return publicMethods
    }

    private static func generateCompactMethodSignature(from functionDecl: FunctionDeclSyntax) -> String {
        // Reuse the shared method signature generation logic
        return MethodSignatureGenerator.generateCompactMethodSignature(from: functionDecl)
    }
}

struct MethodSignatureGenerator {
    static func generateCompactMethodSignature(from functionDecl: FunctionDeclSyntax) -> String {
        let functionName = functionDecl.name.text

        // Extract parameters
        let parameters = extractParameters(from: functionDecl.signature.parameterClause)

        // Extract return type
        let returnType = extractReturnType(from: functionDecl.signature.returnClause)

        // Extract async/throws modifiers
        let asyncModifier = functionDecl.signature.effectSpecifiers?.asyncSpecifier != nil ? " async" : ""
        let throwsModifier = functionDecl.signature.effectSpecifiers?.throwsSpecifier != nil ? " throws" : ""

        // Build the compact signature
        let parameterString = parameters.isEmpty ? "()" : "(\(parameters.joined(separator: ", ")))"
        let returnString = returnType == "Void" ? "" : " -> \(returnType)"

        return "\(functionName)\(parameterString)\(asyncModifier)\(throwsModifier)\(returnString)"
    }

    private static func extractParameters(from parameterClause: FunctionParameterClauseSyntax) -> [String] {
        var parameters: [String] = []

        for parameter in parameterClause.parameters {
            // For compact representation, we'll include the type but simplify parameter labels
            let parameterType = parameter.type.description.trimmingCharacters(in: .whitespacesAndNewlines)

            // Use simplified parameter representation: just the type for most cases
            // This achieves maximum token compression while maintaining clarity
            parameters.append(parameterType)
        }

        return parameters
    }

    private static func extractReturnType(from returnClause: ReturnClauseSyntax?) -> String {
        guard let returnClause = returnClause else {
            return "Void"
        }

        return returnClause.type.description.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum MacroError: Error, CustomStringConvertible {
    case invalidDeclaration(String)

    var description: String {
        switch self {
        case .invalidDeclaration(let message):
            return "Invalid declaration: \(message)"
        }
    }
}
