# iOS Swift Development Expert

> **Version:** 2.0.0 | **Updated:** 2026-02-01  
> **Swift:** 5.9+  
> **iOS:** 17+  
> **Priority:** P0 - Load for iOS/Swift projects

---

You are an expert in iOS development using Swift and SwiftUI.

## Core Principles

- Follow Apple's Human Interface Guidelines
- Write safe, fast, and expressive Swift
- Prioritize user privacy and security
- Embrace modern declarative UI (SwiftUI)

---

## 1) Project Structure

### Feature-Based Architecture
```
MyApp/
├── App/
│   ├── MyApp.swift              # @main entry
│   ├── AppDelegate.swift        # UIKit lifecycle (if needed)
│   └── ContentView.swift
├── Core/
│   ├── Extensions/
│   │   ├── View+Extensions.swift
│   │   └── String+Extensions.swift
│   ├── Services/
│   │   ├── NetworkService.swift
│   │   └── StorageService.swift
│   ├── Utilities/
│   │   └── Constants.swift
│   └── Theme/
│       ├── Colors.swift
│       └── Typography.swift
├── Features/
│   ├── Auth/
│   │   ├── Models/
│   │   │   └── User.swift
│   │   ├── ViewModels/
│   │   │   └── AuthViewModel.swift
│   │   └── Views/
│   │       ├── LoginView.swift
│   │       └── SignUpView.swift
│   ├── Home/
│   │   ├── Models/
│   │   ├── ViewModels/
│   │   └── Views/
│   └── Profile/
├── Resources/
│   ├── Assets.xcassets
│   └── Localizable.strings
└── Tests/
    ├── UnitTests/
    └── UITests/
```

---

## 2) Swift Fundamentals

### Optionals & Error Handling
```swift
// ==========================================
// OPTIONALS
// ==========================================

// Declaration
var name: String? = nil
var age: Int? = 25

// Safe unwrapping with if let
if let name = name {
    print("Hello, \(name)")
}

// Guard let (early exit)
func greet(user: User?) {
    guard let user = user else {
        print("No user")
        return
    }
    print("Hello, \(user.name)")
}

// Optional chaining
let firstCharacter = user?.profile?.bio?.first

// Nil coalescing
let displayName = user?.name ?? "Anonymous"

// Map and flatMap
let uppercased = name.map { $0.uppercased() }
let trimmed = name.flatMap { $0.isEmpty ? nil : $0.trimmingCharacters(in: .whitespaces) }


// ==========================================
// ERROR HANDLING
// ==========================================

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingFailed(Error)
    case serverError(statusCode: Int, message: String)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingFailed(let error):
            return "Decoding failed: \(error.localizedDescription)"
        case .serverError(let code, let message):
            return "Server error \(code): \(message)"
        }
    }
}

// Throwing function
func fetchUser(id: String) async throws -> User {
    guard let url = URL(string: "https://api.example.com/users/\(id)") else {
        throw NetworkError.invalidURL
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse else {
        throw NetworkError.noData
    }
    
    guard (200...299).contains(httpResponse.statusCode) else {
        throw NetworkError.serverError(
            statusCode: httpResponse.statusCode,
            message: "Request failed"
        )
    }
    
    do {
        return try JSONDecoder().decode(User.self, from: data)
    } catch {
        throw NetworkError.decodingFailed(error)
    }
}

// Usage with do-try-catch
do {
    let user = try await fetchUser(id: "123")
    print("User: \(user.name)")
} catch let error as NetworkError {
    print("Network error: \(error.localizedDescription)")
} catch {
    print("Unknown error: \(error)")
}

// Result type
func fetchUserResult(id: String) async -> Result<User, NetworkError> {
    do {
        let user = try await fetchUser(id: id)
        return .success(user)
    } catch let error as NetworkError {
        return .failure(error)
    } catch {
        return .failure(.decodingFailed(error))
    }
}
```

### Protocols & Generics
```swift
// ==========================================
// PROTOCOL-ORIENTED PROGRAMMING
// ==========================================

protocol Identifiable {
    var id: String { get }
}

protocol Displayable {
    var displayName: String { get }
}

protocol Repository {
    associatedtype Entity: Identifiable
    
    func getAll() async throws -> [Entity]
    func get(by id: String) async throws -> Entity?
    func save(_ entity: Entity) async throws
    func delete(_ entity: Entity) async throws
}

// Protocol with default implementation
extension Displayable where Self: Identifiable {
    var displayName: String {
        return "Item \(id)"
    }
}


// ==========================================
// GENERICS
// ==========================================

// Generic function
func firstElement<T>(of array: [T]) -> T? {
    return array.first
}

// Generic type with constraints
struct Cache<Key: Hashable, Value> {
    private var storage: [Key: Value] = [:]
    private let queue = DispatchQueue(label: "cache.queue", attributes: .concurrent)
    
    mutating func set(_ value: Value, for key: Key) {
        queue.async(flags: .barrier) { [self] in
            storage[key] = value
        }
    }
    
    func get(for key: Key) -> Value? {
        queue.sync {
            storage[key]
        }
    }
    
    mutating func remove(for key: Key) {
        queue.async(flags: .barrier) { [self] in
            storage.removeValue(forKey: key)
        }
    }
}

// Usage
var userCache = Cache<String, User>()
userCache.set(user, for: user.id)


// ==========================================
// ASYNC/AWAIT & ACTORS
// ==========================================

// Async function
func loadData() async throws -> [Product] {
    async let products = fetchProducts()
    async let categories = fetchCategories()
    
    // Parallel execution
    let (productList, categoryList) = try await (products, categories)
    
    return productList.map { product in
        var p = product
        p.category = categoryList.first { $0.id == product.categoryId }
        return p
    }
}

// Actor for thread-safe mutable state
actor UserManager {
    private var users: [String: User] = [:]
    
    func getUser(_ id: String) -> User? {
        users[id]
    }
    
    func setUser(_ user: User) {
        users[user.id] = user
    }
    
    func removeUser(_ id: String) {
        users.removeValue(forKey: id)
    }
}

// Using actor
let userManager = UserManager()

Task {
    await userManager.setUser(user)
    let cachedUser = await userManager.getUser("123")
}
```

---

## 3) SwiftUI Views

### Basic Views
```swift
// ==========================================
// REUSABLE COMPONENTS
// ==========================================

import SwiftUI

// Primary Button
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(isDisabled ? Color.gray : Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(isDisabled || isLoading)
    }
}

// Styled Text Field
struct AppTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var errorMessage: String? = nil
    var icon: String? = nil
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(isFocused ? .accentColor : .gray)
                }
                
                Group {
                    if isSecure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .focused($isFocused)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 1)
            )
            
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    private var borderColor: Color {
        if errorMessage != nil {
            return .red
        }
        return isFocused ? .accentColor : .gray.opacity(0.3)
    }
}

// Card Component
struct CardView<Content: View>: View {
    let content: Content
    var padding: CGFloat = 16
    
    init(padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}


// ==========================================
// SCREEN EXAMPLE
// ==========================================

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case email, password
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Logo
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.accentColor)
                    
                    // Title
                    Text("Welcome Back")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Sign in to continue")
                        .foregroundColor(.secondary)
                    
                    // Form
                    VStack(spacing: 16) {
                        AppTextField(
                            placeholder: "Email",
                            text: $viewModel.email,
                            errorMessage: viewModel.emailError,
                            icon: "envelope"
                        )
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .password }
                        
                        AppTextField(
                            placeholder: "Password",
                            text: $viewModel.password,
                            isSecure: true,
                            errorMessage: viewModel.passwordError,
                            icon: "lock"
                        )
                        .textContentType(.password)
                        .focused($focusedField, equals: .password)
                        .submitLabel(.go)
                        .onSubmit { Task { await viewModel.login() } }
                    }
                    
                    // Login Button
                    PrimaryButton(
                        title: "Sign In",
                        action: { Task { await viewModel.login() } },
                        isLoading: viewModel.isLoading,
                        isDisabled: !viewModel.isValid
                    )
                    
                    // Forgot Password
                    Button("Forgot Password?") {
                        viewModel.showForgotPassword = true
                    }
                    .font(.subheadline)
                    
                    Spacer()
                    
                    // Sign Up Link
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.secondary)
                        NavigationLink("Sign Up") {
                            SignUpView()
                        }
                    }
                    .font(.subheadline)
                }
                .padding()
            }
            .navigationBarHidden(true)
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .sheet(isPresented: $viewModel.showForgotPassword) {
                ForgotPasswordView()
            }
        }
    }
}


// ==========================================
// LIST WITH REFRESH
// ==========================================

struct ProductListView: View {
    @StateObject private var viewModel = ProductListViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .loading:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                case .loaded(let products):
                    List {
                        ForEach(products) { product in
                            NavigationLink(value: product) {
                                ProductRow(product: product)
                            }
                        }
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                    
                case .error(let message):
                    ContentUnavailableView(
                        "Error",
                        systemImage: "exclamationmark.triangle",
                        description: Text(message)
                    )
                    
                case .empty:
                    ContentUnavailableView(
                        "No Products",
                        systemImage: "cube.box",
                        description: Text("Check back later for new products")
                    )
                }
            }
            .navigationTitle("Products")
            .navigationDestination(for: Product.self) { product in
                ProductDetailView(product: product)
            }
            .task {
                await viewModel.load()
            }
        }
    }
}
```

### State Management
```swift
// ==========================================
// STATE PROPERTY WRAPPERS
// ==========================================

struct CounterView: View {
    // Local state
    @State private var count = 0
    
    var body: some View {
        VStack {
            Text("Count: \(count)")
            Button("Increment") {
                count += 1
            }
        }
    }
}

// Binding (two-way)
struct ParentView: View {
    @State private var isOn = false
    
    var body: some View {
        ChildView(isOn: $isOn)
    }
}

struct ChildView: View {
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle("Toggle", isOn: $isOn)
    }
}

// ObservableObject
@Observable
class SettingsViewModel {
    var isDarkMode = false
    var fontSize: CGFloat = 16
    var notificationsEnabled = true
}

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    
    var body: some View {
        Form {
            Toggle("Dark Mode", isOn: $viewModel.isDarkMode)
            Slider(value: $viewModel.fontSize, in: 12...24)
            Toggle("Notifications", isOn: $viewModel.notificationsEnabled)
        }
    }
}

// Environment for app-wide state
@Observable
class AppState {
    var isLoggedIn = false
    var user: User?
    var theme: Theme = .system
}

@main
struct MyApp: App {
    @State private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
    }
}

struct ContentView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        if appState.isLoggedIn {
            MainTabView()
        } else {
            LoginView()
        }
    }
}
```

---

## 4) MVVM Architecture

### ViewModel Pattern
```swift
// ==========================================
// LOGIN VIEW MODEL
// ==========================================

import Foundation

@Observable
class LoginViewModel {
    // Input
    var email = ""
    var password = ""
    
    // Output
    var isLoading = false
    var showError = false
    var errorMessage = ""
    var showForgotPassword = false
    
    // Validation
    var emailError: String? {
        if email.isEmpty { return nil }
        return email.isValidEmail ? nil : "Invalid email format"
    }
    
    var passwordError: String? {
        if password.isEmpty { return nil }
        return password.count >= 6 ? nil : "Password must be at least 6 characters"
    }
    
    var isValid: Bool {
        !email.isEmpty && !password.isEmpty && emailError == nil && passwordError == nil
    }
    
    // Dependencies
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }
    
    // Actions
    @MainActor
    func login() async {
        guard isValid else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let user = try await authService.login(email: email, password: password)
            // Handle successful login
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}


// ==========================================
// LIST VIEW MODEL
// ==========================================

enum ViewState<T> {
    case loading
    case loaded(T)
    case error(String)
    case empty
}

@Observable
class ProductListViewModel {
    var state: ViewState<[Product]> = .loading
    var searchText = ""
    
    private let productService: ProductServiceProtocol
    
    init(productService: ProductServiceProtocol = ProductService.shared) {
        self.productService = productService
    }
    
    var filteredProducts: [Product] {
        guard case .loaded(let products) = state else { return [] }
        
        if searchText.isEmpty {
            return products
        }
        
        return products.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    @MainActor
    func load() async {
        state = .loading
        
        do {
            let products = try await productService.getProducts()
            state = products.isEmpty ? .empty : .loaded(products)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    @MainActor
    func refresh() async {
        do {
            let products = try await productService.getProducts()
            state = products.isEmpty ? .empty : .loaded(products)
        } catch {
            // Keep existing data on refresh error
        }
    }
}
```

---

## 5) Networking

### Network Layer
```swift
// ==========================================
// API CLIENT
// ==========================================

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

protocol APIEndpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var parameters: [String: Any]? { get }
    var body: Encodable? { get }
}

extension APIEndpoint {
    var baseURL: String { "https://api.example.com" }
    var headers: [String: String] { ["Content-Type": "application/json"] }
    var parameters: [String: Any]? { nil }
    var body: Encodable? { nil }
}

enum UserEndpoint: APIEndpoint {
    case getUser(id: String)
    case updateUser(id: String, data: UpdateUserRequest)
    case deleteUser(id: String)
    case getUsers(page: Int, limit: Int)
    
    var path: String {
        switch self {
        case .getUser(let id), .updateUser(let id, _), .deleteUser(let id):
            return "/users/\(id)"
        case .getUsers:
            return "/users"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getUser, .getUsers: return .get
        case .updateUser: return .put
        case .deleteUser: return .delete
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .getUsers(let page, let limit):
            return ["page": page, "limit": limit]
        default:
            return nil
        }
    }
    
    var body: Encodable? {
        switch self {
        case .updateUser(_, let data):
            return data
        default:
            return nil
        }
    }
}


// ==========================================
// NETWORK SERVICE
// ==========================================

actor NetworkService {
    static let shared = NetworkService()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private var token: String?
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        
        self.session = URLSession(configuration: config)
        
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .iso8601
        
        self.encoder = JSONEncoder()
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
    }
    
    func setToken(_ token: String?) {
        self.token = token
    }
    
    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        responseType: T.Type
    ) async throws -> T {
        let request = try buildRequest(for: endpoint)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return try decoder.decode(T.self, from: data)
        case 401:
            throw NetworkError.unauthorized
        case 404:
            throw NetworkError.notFound
        case 500...599:
            throw NetworkError.serverError(httpResponse.statusCode)
        default:
            throw NetworkError.unknown(httpResponse.statusCode)
        }
    }
    
    private func buildRequest(for endpoint: APIEndpoint) throws -> URLRequest {
        var urlComponents = URLComponents(string: endpoint.baseURL + endpoint.path)!
        
        if let parameters = endpoint.parameters {
            urlComponents.queryItems = parameters.map {
                URLQueryItem(name: $0.key, value: "\($0.value)")
            }
        }
        
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        for (key, value) in endpoint.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = endpoint.body {
            request.httpBody = try encoder.encode(body)
        }
        
        return request
    }
}


// ==========================================
// SERVICE USAGE
// ==========================================

protocol UserServiceProtocol {
    func getUser(id: String) async throws -> User
    func getUsers(page: Int, limit: Int) async throws -> [User]
    func updateUser(id: String, data: UpdateUserRequest) async throws -> User
}

class UserService: UserServiceProtocol {
    static let shared = UserService()
    
    private let network = NetworkService.shared
    
    func getUser(id: String) async throws -> User {
        try await network.request(
            UserEndpoint.getUser(id: id),
            responseType: User.self
        )
    }
    
    func getUsers(page: Int = 1, limit: Int = 20) async throws -> [User] {
        try await network.request(
            UserEndpoint.getUsers(page: page, limit: limit),
            responseType: [User].self
        )
    }
    
    func updateUser(id: String, data: UpdateUserRequest) async throws -> User {
        try await network.request(
            UserEndpoint.updateUser(id: id, data: data),
            responseType: User.self
        )
    }
}
```

---

## 6) Data Persistence

### SwiftData
```swift
// ==========================================
// SWIFTDATA MODELS
// ==========================================

import SwiftData

@Model
class Task {
    var id: UUID
    var title: String
    var notes: String?
    var isCompleted: Bool
    var dueDate: Date?
    var createdAt: Date
    var priority: Priority
    
    @Relationship(deleteRule: .nullify, inverse: \Category.tasks)
    var category: Category?
    
    init(
        title: String,
        notes: String? = nil,
        isCompleted: Bool = false,
        dueDate: Date? = nil,
        priority: Priority = .medium,
        category: Category? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.notes = notes
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.createdAt = Date()
        self.priority = priority
        self.category = category
    }
}

@Model
class Category {
    var id: UUID
    var name: String
    var color: String
    
    @Relationship
    var tasks: [Task]?
    
    init(name: String, color: String) {
        self.id = UUID()
        self.name = name
        self.color = color
    }
}

enum Priority: String, Codable, CaseIterable {
    case low, medium, high
}


// ==========================================
// SWIFTDATA IN APP
// ==========================================

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Task.self, Category.self])
    }
}


// ==========================================
// USING SWIFTDATA IN VIEWS
// ==========================================

struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Task.createdAt, order: .reverse) private var tasks: [Task]
    
    // With filter
    @Query(
        filter: #Predicate<Task> { !$0.isCompleted },
        sort: \Task.dueDate
    ) private var pendingTasks: [Task]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(tasks) { task in
                    TaskRow(task: task)
                }
                .onDelete(perform: deleteTasks)
            }
            .navigationTitle("Tasks")
            .toolbar {
                Button(action: addTask) {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    private func addTask() {
        let task = Task(title: "New Task")
        modelContext.insert(task)
    }
    
    private func deleteTasks(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(tasks[index])
        }
    }
}


// ==========================================
// KEYCHAIN FOR SECURE STORAGE
// ==========================================

import Security

class KeychainService {
    static let shared = KeychainService()
    
    func save(_ data: Data, for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }
    
    func load(for key: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                return nil
            }
            throw KeychainError.loadFailed(status)
        }
        
        return result as? Data
    }
    
    func delete(for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }
}

enum KeychainError: Error {
    case saveFailed(OSStatus)
    case loadFailed(OSStatus)
    case deleteFailed(OSStatus)
}
```

---

## 7) Testing

### Unit & UI Tests
```swift
// ==========================================
// UNIT TESTS
// ==========================================

import XCTest
@testable import MyApp

final class LoginViewModelTests: XCTestCase {
    var sut: LoginViewModel!
    var mockAuthService: MockAuthService!
    
    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
        sut = LoginViewModel(authService: mockAuthService)
    }
    
    override func tearDown() {
        sut = nil
        mockAuthService = nil
        super.tearDown()
    }
    
    func testEmailValidation_withValidEmail_returnsNil() {
        sut.email = "test@example.com"
        XCTAssertNil(sut.emailError)
    }
    
    func testEmailValidation_withInvalidEmail_returnsError() {
        sut.email = "invalid-email"
        XCTAssertNotNil(sut.emailError)
    }
    
    func testIsValid_withEmptyFields_returnsFalse() {
        sut.email = ""
        sut.password = ""
        XCTAssertFalse(sut.isValid)
    }
    
    func testIsValid_withValidData_returnsTrue() {
        sut.email = "test@example.com"
        sut.password = "password123"
        XCTAssertTrue(sut.isValid)
    }
    
    func testLogin_withValidCredentials_succeeds() async {
        let expectedUser = User(id: "1", email: "test@example.com", name: "Test")
        mockAuthService.loginResult = .success(expectedUser)
        
        sut.email = "test@example.com"
        sut.password = "password123"
        
        await sut.login()
        
        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(sut.showError)
    }
    
    func testLogin_withInvalidCredentials_showsError() async {
        mockAuthService.loginResult = .failure(NetworkError.unauthorized)
        
        sut.email = "test@example.com"
        sut.password = "wrong-password"
        
        await sut.login()
        
        XCTAssertFalse(sut.isLoading)
        XCTAssertTrue(sut.showError)
    }
}


// ==========================================
// MOCK SERVICE
// ==========================================

class MockAuthService: AuthServiceProtocol {
    var loginResult: Result<User, Error>!
    
    func login(email: String, password: String) async throws -> User {
        switch loginResult {
        case .success(let user):
            return user
        case .failure(let error):
            throw error
        case .none:
            fatalError("loginResult not set")
        }
    }
}


// ==========================================
// UI TESTS
// ==========================================

import XCTest

final class LoginUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }
    
    func testLoginWithValidCredentials() {
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Sign In"]
        
        emailField.tap()
        emailField.typeText("test@example.com")
        
        passwordField.tap()
        passwordField.typeText("password123")
        
        loginButton.tap()
        
        // Wait for navigation
        let homeTitle = app.navigationBars["Home"]
        XCTAssertTrue(homeTitle.waitForExistence(timeout: 5))
    }
    
    func testLoginShowsValidationErrors() {
        let loginButton = app.buttons["Sign In"]
        loginButton.tap()
        
        XCTAssertTrue(app.staticTexts["Email is required"].exists)
        XCTAssertTrue(app.staticTexts["Password is required"].exists)
    }
}
```

---

## Best Practices Checklist

### Code Quality
- [ ] Use Swift's type system
- [ ] Handle optionals safely
- [ ] Follow naming conventions
- [ ] Use extensions for organization

### Performance
- [ ] Avoid force unwrapping
- [ ] Use lazy loading
- [ ] Profile with Instruments
- [ ] Optimize images

### Architecture
- [ ] MVVM separation
- [ ] Protocol-oriented design
- [ ] Dependency injection
- [ ] Clean error handling

### Testing
- [ ] Unit tests for ViewModels
- [ ] UI tests for flows
- [ ] Mock dependencies
- [ ] Test edge cases

---

**References:**
- [Swift Documentation](https://docs.swift.org/swift-book/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
