import Testing
@testable import CompactSchema

@CompactSchema
public struct TestUser: Codable {
    let id: String
    let name: String
    let email: String?
    let isActive: Bool
    let tags: [String]
    let metadata: [String: String]

    public init(id: String, name: String, email: String?, isActive: Bool, tags: [String], metadata: [String: String]) {
        self.id = id
        self.name = name
        self.email = email
        self.isActive = isActive
        self.tags = tags
        self.metadata = metadata
    }
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

// MARK: - CompactMethod Tests

struct TestAPI {
    @CompactMethod
    public func getUserInfo() async throws -> TestUser {
        return TestUser(id: "1", name: "Test", email: nil, isActive: true, tags: [], metadata: [:])
    }

    @CompactMethod
    public func updateProfile(_ request: UpdateProfileRequest) async throws -> TestUser {
        return TestUser(id: "1", name: "Updated", email: nil, isActive: true, tags: [], metadata: [:])
    }

    @CompactMethod
    public func deleteUser(_ id: String) -> Void {
        // Implementation
    }

    @CompactMethod
    public func syncOperation() -> Bool {
        return true
    }
}

public struct UpdateProfileRequest {
    let name: String
    let email: String?

    public init(name: String, email: String?) {
        self.name = name
        self.email = email
    }
}

@Test("CompactMethod generates correct method signature for async throws function")
func testAsyncThrowsMethodSignature() async throws {
    let expectedSignature = "getUserInfo() async throws -> TestUser"
    #expect(TestAPI.getUserInfoMethod == expectedSignature)
}

@Test("CompactMethod generates correct method signature with parameters")
func testMethodSignatureWithParameters() async throws {
    let expectedSignature = "updateProfile(_: UpdateProfileRequest) async throws -> TestUser"
    #expect(TestAPI.updateProfileMethod == expectedSignature)
}

@Test("CompactMethod generates correct method signature for Void return")
func testVoidReturnMethodSignature() async throws {
    let expectedSignature = "deleteUser(_: String)"
    #expect(TestAPI.deleteUserMethod == expectedSignature)
}

@Test("CompactMethod generates correct method signature for sync function")
func testSyncMethodSignature() async throws {
    let expectedSignature = "syncOperation() -> Bool"
    #expect(TestAPI.syncOperationMethod == expectedSignature)
}

// MARK: - CompactAPIMethods Tests

@CompactAPIMethods
public class TestBourbonAPI {
    public func getUserInfo() async throws -> TestUser {
        return TestUser(id: "1", name: "Test", email: nil, isActive: true, tags: [], metadata: [:])
    }

    public func updateProfile(_ request: UpdateProfileRequest) async throws -> TestUser {
        return TestUser(id: "1", name: "Updated", email: nil, isActive: true, tags: [], metadata: [:])
    }

    public func createCollection(_ request: CreateCollectionRequest) async throws -> Collection {
        return Collection(id: 1, name: "Test", itemCount: 0)
    }

    // Test method with many parameters of the same type (simulates discoverTastings scenario)
    public func discoverTastings(
        type: String?,
        age: Int?,
        proof: Double?,
        barrelNumber: String?,
        bottlingYear: Int?,
        limit: Int?,
        offset: Int?,
        sortBy: String?
    ) async throws -> TastingDiscoverResponse {
        return TastingDiscoverResponse(results: [], total: 0)
    }

    // This should not be included (private)
    private func internalMethod() {
        // Private implementation
    }

    // This should not be included (internal)
    func internalMethod2() {
        // Internal implementation
    }
}

public struct TastingDiscoverResponse {
    let results: [String]
    let total: Int

    public init(results: [String], total: Int) {
        self.results = results
        self.total = total
    }
}

public struct CreateCollectionRequest {
    let name: String
    let description: String?

    public init(name: String, description: String?) {
        self.name = name
        self.description = description
    }
}

public struct Collection {
    let id: Int64
    let name: String
    let itemCount: Int

    public init(id: Int64, name: String, itemCount: Int) {
        self.id = id
        self.name = name
        self.itemCount = itemCount
    }
}

@Test("CompactAPIMethods generates array of all public methods")
func testCompactAPIMethodsGeneration() async throws {
    let expectedMethods = [
        "getUserInfo() async throws -> TestUser",
        "updateProfile(_: UpdateProfileRequest) async throws -> TestUser",
        "createCollection(_: CreateCollectionRequest) async throws -> Collection",
        "discoverTastings(type: String?, age: Int?, proof: Double?, barrelNumber: String?, bottlingYear: Int?, limit: Int?, offset: Int?, sortBy: String?) async throws -> TastingDiscoverResponse"
    ]

    #expect(TestBourbonAPI.compactMethods == expectedMethods)
}

@Test("CompactAPIMethods excludes private and internal methods")
func testCompactAPIMethodsExcludesPrivate() async throws {
    // Verify that private and internal methods are not included
    let methodsString = TestBourbonAPI.compactMethods.joined(separator: " ")
    #expect(!methodsString.contains("internalMethod"))
}

@Test("CompactAPIMethods preserves parameter labels for multi-parameter methods")
func testParameterLabelsPreserved() async throws {
    // This test addresses the critical issue: methods with many parameters of the same type
    // need parameter labels to distinguish which parameter is which
    let discoverTastingsSignature = TestBourbonAPI.compactMethods.first { $0.contains("discoverTastings") }

    // Verify the signature exists
    #expect(discoverTastingsSignature != nil)

    if let signature = discoverTastingsSignature {
        // Verify all parameter labels are present
        #expect(signature.contains("type:"))
        #expect(signature.contains("age:"))
        #expect(signature.contains("proof:"))
        #expect(signature.contains("barrelNumber:"))
        #expect(signature.contains("bottlingYear:"))
        #expect(signature.contains("limit:"))
        #expect(signature.contains("offset:"))
        #expect(signature.contains("sortBy:"))

        // Verify the complete signature format
        let expected = "discoverTastings(type: String?, age: Int?, proof: Double?, barrelNumber: String?, bottlingYear: Int?, limit: Int?, offset: Int?, sortBy: String?) async throws -> TastingDiscoverResponse"
        #expect(signature == expected)
    }
}

// MARK: - CompactMethodRegistry Tests

@Test("CompactMethodRegistry provides empty arrays initially")
func testCompactMethodRegistryEmpty() async throws {
    // Since we haven't implemented runtime registration yet, these should be empty
    #expect(CompactMethodRegistry.getAllMethods().isEmpty)
    #expect(CompactMethodRegistry.getMethodsByCategory().isEmpty)
}

// MARK: - CompactDocumentation Tests

@Test("CompactDocumentation generates basic structure")
func testCompactDocumentationStructure() async throws {
    let documentation = CompactDocumentation.getCompleteDocumentation()
    #expect(documentation.contains("# API Documentation"))
    #expect(documentation.contains("## Data Models"))
}

// MARK: - Integration Tests

@Test("CompactMethod and CompactSchema work together")
func testIntegrationWithCompactSchema() async throws {
    // Test that method signatures reference types that have @CompactSchema
    let methodSignature = TestAPI.getUserInfoMethod
    let schemaString = TestUser.compactSchema

    // Verify that the method returns a type that has compact schema
    #expect(methodSignature.contains("TestUser"))
    #expect(!schemaString.isEmpty)
}

@Test("All macro generated properties are accessible")
func testMacroGeneratedAccessibility() async throws {
    // Test that all generated properties can be accessed without compilation errors
    _ = TestAPI.getUserInfoMethod
    _ = TestAPI.updateProfileMethod
    _ = TestAPI.deleteUserMethod
    _ = TestAPI.syncOperationMethod
    _ = TestBourbonAPI.compactMethods
    _ = TestUser.compactSchema
    _ = TestStatus.compactSchema
}
