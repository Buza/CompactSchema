import Testing
@testable import CompactSchema

@CompactSchema
struct TestUser: Codable {
    let id: String
    let name: String
    let email: String?
    let isActive: Bool
    let tags: [String]
    let metadata: [String: String]
}

@CompactSchema
struct TestUserWithProtocols: Codable, CustomStringConvertible {
    let id: String
    let name: String

    var description: String {
        return "\(name) (\(id))"
    }
}

@CompactSchema
enum TestStatus: String, CaseIterable {
    case active = "active"
    case inactive = "inactive"
    case pending = "pending"
}

@CompactSchema
enum TestPriority: Int {
    case low = 1
    case medium = 2
    case high = 3
}

@CompactSchema
enum TestSimpleEnum {
    case option1
    case option2
    case option3
}

@Test("CompactSchema generates correct struct schema")
func testStructSchema() async throws {
    let expectedSchema = """
    TestUser {
      id: String
      name: String
      email: String?
      isActive: Bool
      tags: [String]
      metadata: [String: String]
    }
    """

    #expect(TestUser.compactSchema == expectedSchema)
}

@Test("CompactSchema excludes protocol properties")
func testProtocolPropertyExclusion() async throws {
    let expectedSchema = """
    TestUserWithProtocols {
      id: String
      name: String
    }
    """

    #expect(TestUserWithProtocols.compactSchema == expectedSchema)
}

@Test("CompactSchema generates correct enum schema with raw values")
func testEnumSchemaWithRawValues() async throws {
    let expectedSchema = """
    enum TestStatus: [active = "active" | inactive = "inactive" | pending = "pending"]
    """

    #expect(TestStatus.compactSchema == expectedSchema)
}

@Test("CompactSchema generates correct enum schema with int raw values")
func testEnumSchemaWithIntRawValues() async throws {
    let expectedSchema = """
    enum TestPriority: [low = 1 | medium = 2 | high = 3]
    """

    #expect(TestPriority.compactSchema == expectedSchema)
}

@Test("CompactSchema generates correct enum schema without raw values")
func testSimpleEnumSchema() async throws {
    let expectedSchema = """
    enum TestSimpleEnum: [option1 | option2 | option3]
    """

    #expect(TestSimpleEnum.compactSchema == expectedSchema)
}

@Test("CompactSchema property is accessible")
func testSchemaAccessibility() async throws {
    // Test that the generated property is accessible and returns a non-empty string
    #expect(!TestUser.compactSchema.isEmpty)
    #expect(!TestStatus.compactSchema.isEmpty)
    #expect(!TestSimpleEnum.compactSchema.isEmpty)
}
