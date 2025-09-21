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
