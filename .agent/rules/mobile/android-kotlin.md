# Android Kotlin Development Expert

> **Version:** 2.0.0 | **Updated:** 2026-02-01  
> **Kotlin:** 2.0+  
> **Compose:** 1.6+  
> **Priority:** P0 - Load for Android projects

---

You are an expert in Android development using Kotlin and Jetpack Compose.

## Core Principles

- Follow Material Design 3 guidelines
- Build responsive and adaptive UIs
- Handle lifecycle events correctly
- Use modern Android Jetpack libraries

---

## 1) Project Structure

### Multi-Module Architecture
```
app/
├── build.gradle.kts
└── src/main/
    ├── AndroidManifest.xml
    └── kotlin/com/example/app/
        ├── MyApp.kt              # Application class
        ├── MainActivity.kt
        └── navigation/
            └── AppNavigation.kt

core/
├── common/                       # Shared utilities
│   └── src/main/kotlin/
│       ├── extensions/
│       ├── utils/
│       └── di/
├── data/                         # Data layer
│   └── src/main/kotlin/
│       ├── repository/
│       ├── local/
│       │   ├── dao/
│       │   ├── entity/
│       │   └── database/
│       └── remote/
│           ├── api/
│           ├── dto/
│           └── interceptor/
├── domain/                       # Domain layer
│   └── src/main/kotlin/
│       ├── model/
│       ├── repository/
│       └── usecase/
└── ui/                           # UI components
    └── src/main/kotlin/
        ├── components/
        └── theme/

feature/
├── auth/
│   └── src/main/kotlin/
│       ├── di/
│       ├── navigation/
│       ├── ui/
│       │   ├── LoginScreen.kt
│       │   └── SignUpScreen.kt
│       └── viewmodel/
├── home/
└── profile/
```

---

## 2) Kotlin Fundamentals

### Null Safety & Extensions
```kotlin
// ==========================================
// NULL SAFETY
// ==========================================

// Nullable types
var name: String? = null
val length: Int = name?.length ?: 0  // Elvis operator

// Safe call chain
val city = user?.address?.city

// Let for null checks
user?.let { user ->
    println("User: ${user.name}")
}

// Run for null transformation
val displayName = nickname?.run {
    if (isEmpty()) null else uppercase()
} ?: "Anonymous"

// Require and check
fun processUser(user: User?) {
    requireNotNull(user) { "User cannot be null" }
    require(user.age >= 18) { "User must be 18+" }
    
    check(user.isActive) { "User must be active" }
}


// ==========================================
// EXTENSION FUNCTIONS
// ==========================================

// String extensions
fun String.isValidEmail(): Boolean {
    return android.util.Patterns.EMAIL_ADDRESS.matcher(this).matches()
}

fun String.toSlug(): String {
    return lowercase()
        .replace(Regex("[^a-z0-9\\s-]"), "")
        .replace(Regex("[\\s-]+"), "-")
        .trim('-')
}

// Context extensions
fun Context.showToast(message: String, duration: Int = Toast.LENGTH_SHORT) {
    Toast.makeText(this, message, duration).show()
}

fun Context.dp(value: Int): Int {
    return (value * resources.displayMetrics.density).toInt()
}

// Flow extensions
fun <T> Flow<T>.throttleFirst(windowDuration: Long): Flow<T> = flow {
    var lastEmissionTime = 0L
    collect { value ->
        val currentTime = System.currentTimeMillis()
        if (currentTime - lastEmissionTime >= windowDuration) {
            lastEmissionTime = currentTime
            emit(value)
        }
    }
}


// ==========================================
// DATA CLASSES & SEALED CLASSES
// ==========================================

data class User(
    val id: String,
    val email: String,
    val name: String,
    val avatarUrl: String? = null,
    val createdAt: Instant = Instant.now()
)

// Sealed class for state
sealed interface UiState<out T> {
    data object Loading : UiState<Nothing>
    data class Success<T>(val data: T) : UiState<T>
    data class Error(val message: String, val throwable: Throwable? = null) : UiState<Nothing>
}

// Sealed class for events
sealed interface LoginEvent {
    data class EmailChanged(val email: String) : LoginEvent
    data class PasswordChanged(val password: String) : LoginEvent
    data object LoginClicked : LoginEvent
    data object ForgotPasswordClicked : LoginEvent
}

// Sealed class for navigation
sealed interface Screen {
    data object Login : Screen
    data object Home : Screen
    data class ProductDetail(val productId: String) : Screen
    data class Profile(val userId: String) : Screen
}
```

### Coroutines & Flow
```kotlin
// ==========================================
// COROUTINES
// ==========================================

import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*

// Suspend function
suspend fun fetchUser(id: String): User {
    return withContext(Dispatchers.IO) {
        api.getUser(id)
    }
}

// Parallel execution
suspend fun loadDashboard(): Dashboard {
    return coroutineScope {
        val userDeferred = async { userRepository.getUser() }
        val productsDeferred = async { productRepository.getProducts() }
        val notificationsDeferred = async { notificationRepository.getNotifications() }
        
        Dashboard(
            user = userDeferred.await(),
            products = productsDeferred.await(),
            notifications = notificationsDeferred.await()
        )
    }
}

// Exception handling
suspend fun safeApiCall<T>(block: suspend () -> T): Result<T> {
    return try {
        Result.success(block())
    } catch (e: CancellationException) {
        throw e  // Don't catch cancellation
    } catch (e: Exception) {
        Result.failure(e)
    }
}


// ==========================================
// FLOW
// ==========================================

// Creating flows
fun getProducts(): Flow<List<Product>> = flow {
    while (true) {
        val products = api.getProducts()
        emit(products)
        delay(30_000)  // Refresh every 30 seconds
    }
}

// StateFlow for state
class ProductViewModel : ViewModel() {
    private val _products = MutableStateFlow<UiState<List<Product>>>(UiState.Loading)
    val products: StateFlow<UiState<List<Product>>> = _products.asStateFlow()
    
    init {
        loadProducts()
    }
    
    private fun loadProducts() {
        viewModelScope.launch {
            productRepository.getProducts()
                .catch { e -> _products.value = UiState.Error(e.message ?: "Unknown error") }
                .collect { products -> _products.value = UiState.Success(products) }
        }
    }
}

// SharedFlow for events
class LoginViewModel : ViewModel() {
    private val _events = MutableSharedFlow<LoginUiEvent>()
    val events: SharedFlow<LoginUiEvent> = _events.asSharedFlow()
    
    fun navigateToHome() {
        viewModelScope.launch {
            _events.emit(LoginUiEvent.NavigateToHome)
        }
    }
}

sealed interface LoginUiEvent {
    data object NavigateToHome : LoginUiEvent
    data class ShowError(val message: String) : LoginUiEvent
}

// Flow operators
val searchResults = searchQueryFlow
    .debounce(300)
    .distinctUntilChanged()
    .filter { it.length >= 2 }
    .flatMapLatest { query ->
        searchRepository.search(query)
    }
    .stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = emptyList()
    )
```

---

## 3) Jetpack Compose

### UI Components
```kotlin
// ==========================================
// REUSABLE COMPONENTS
// ==========================================

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun PrimaryButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    isLoading: Boolean = false
) {
    Button(
        onClick = onClick,
        modifier = modifier
            .fillMaxWidth()
            .height(50.dp),
        enabled = enabled && !isLoading,
        shape = MaterialTheme.shapes.medium
    ) {
        if (isLoading) {
            CircularProgressIndicator(
                modifier = Modifier.size(20.dp),
                color = MaterialTheme.colorScheme.onPrimary,
                strokeWidth = 2.dp
            )
        } else {
            Text(text)
        }
    }
}

@Composable
fun AppTextField(
    value: String,
    onValueChange: (String) -> Unit,
    modifier: Modifier = Modifier,
    label: String? = null,
    placeholder: String? = null,
    errorMessage: String? = null,
    leadingIcon: @Composable (() -> Unit)? = null,
    trailingIcon: @Composable (() -> Unit)? = null,
    isPassword: Boolean = false,
    keyboardOptions: KeyboardOptions = KeyboardOptions.Default,
    keyboardActions: KeyboardActions = KeyboardActions.Default
) {
    var passwordVisible by remember { mutableStateOf(false) }
    
    Column(modifier = modifier) {
        OutlinedTextField(
            value = value,
            onValueChange = onValueChange,
            modifier = Modifier.fillMaxWidth(),
            label = label?.let { { Text(it) } },
            placeholder = placeholder?.let { { Text(it) } },
            leadingIcon = leadingIcon,
            trailingIcon = if (isPassword) {
                {
                    IconButton(onClick = { passwordVisible = !passwordVisible }) {
                        Icon(
                            imageVector = if (passwordVisible) 
                                Icons.Default.VisibilityOff 
                            else 
                                Icons.Default.Visibility,
                            contentDescription = "Toggle password visibility"
                        )
                    }
                }
            } else trailingIcon,
            visualTransformation = if (isPassword && !passwordVisible) 
                PasswordVisualTransformation() 
            else 
                VisualTransformation.None,
            isError = errorMessage != null,
            keyboardOptions = keyboardOptions,
            keyboardActions = keyboardActions,
            singleLine = true,
            shape = MaterialTheme.shapes.medium
        )
        
        if (errorMessage != null) {
            Text(
                text = errorMessage,
                color = MaterialTheme.colorScheme.error,
                style = MaterialTheme.typography.bodySmall,
                modifier = Modifier.padding(start = 16.dp, top = 4.dp)
            )
        }
    }
}


// ==========================================
// SCREEN EXAMPLE
// ==========================================

@Composable
fun LoginScreen(
    viewModel: LoginViewModel = hiltViewModel(),
    onNavigateToHome: () -> Unit,
    onNavigateToSignUp: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val snackbarHostState = remember { SnackbarHostState() }
    
    // Handle events
    LaunchedEffect(Unit) {
        viewModel.events.collect { event ->
            when (event) {
                is LoginUiEvent.NavigateToHome -> onNavigateToHome()
                is LoginUiEvent.ShowError -> {
                    snackbarHostState.showSnackbar(event.message)
                }
            }
        }
    }
    
    Scaffold(
        snackbarHost = { SnackbarHost(snackbarHostState) }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(24.dp)
                .verticalScroll(rememberScrollState()),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(modifier = Modifier.height(48.dp))
            
            // Logo
            Icon(
                imageVector = Icons.Default.Person,
                contentDescription = null,
                modifier = Modifier.size(80.dp),
                tint = MaterialTheme.colorScheme.primary
            )
            
            Spacer(modifier = Modifier.height(24.dp))
            
            // Title
            Text(
                text = "Welcome Back",
                style = MaterialTheme.typography.headlineLarge
            )
            
            Text(
                text = "Sign in to continue",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            
            Spacer(modifier = Modifier.height(32.dp))
            
            // Form
            AppTextField(
                value = uiState.email,
                onValueChange = { viewModel.onEvent(LoginEvent.EmailChanged(it)) },
                label = "Email",
                errorMessage = uiState.emailError,
                leadingIcon = { Icon(Icons.Default.Email, null) },
                keyboardOptions = KeyboardOptions(
                    keyboardType = KeyboardType.Email,
                    imeAction = ImeAction.Next
                )
            )
            
            Spacer(modifier = Modifier.height(16.dp))
            
            AppTextField(
                value = uiState.password,
                onValueChange = { viewModel.onEvent(LoginEvent.PasswordChanged(it)) },
                label = "Password",
                errorMessage = uiState.passwordError,
                isPassword = true,
                leadingIcon = { Icon(Icons.Default.Lock, null) },
                keyboardOptions = KeyboardOptions(
                    keyboardType = KeyboardType.Password,
                    imeAction = ImeAction.Done
                ),
                keyboardActions = KeyboardActions(
                    onDone = { viewModel.onEvent(LoginEvent.LoginClicked) }
                )
            )
            
            Spacer(modifier = Modifier.height(8.dp))
            
            // Forgot password
            TextButton(
                onClick = { viewModel.onEvent(LoginEvent.ForgotPasswordClicked) },
                modifier = Modifier.align(Alignment.End)
            ) {
                Text("Forgot Password?")
            }
            
            Spacer(modifier = Modifier.height(24.dp))
            
            // Login button
            PrimaryButton(
                text = "Sign In",
                onClick = { viewModel.onEvent(LoginEvent.LoginClicked) },
                isLoading = uiState.isLoading,
                enabled = uiState.isValid
            )
            
            Spacer(modifier = Modifier.weight(1f))
            
            // Sign up link
            Row(
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text("Don't have an account?")
                TextButton(onClick = onNavigateToSignUp) {
                    Text("Sign Up")
                }
            }
        }
    }
}


// ==========================================
// LIST WITH LAZY COLUMN
// ==========================================

@Composable
fun ProductListScreen(
    viewModel: ProductListViewModel = hiltViewModel(),
    onProductClick: (String) -> Unit
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    
    when (val state = uiState) {
        is UiState.Loading -> {
            Box(
                modifier = Modifier.fillMaxSize(),
                contentAlignment = Alignment.Center
            ) {
                CircularProgressIndicator()
            }
        }
        
        is UiState.Success -> {
            val products = state.data
            
            if (products.isEmpty()) {
                EmptyState(
                    icon = Icons.Default.ShoppingBag,
                    title = "No Products",
                    message = "Check back later for new products"
                )
            } else {
                LazyColumn(
                    contentPadding = PaddingValues(16.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    items(
                        items = products,
                        key = { it.id }
                    ) { product ->
                        ProductCard(
                            product = product,
                            onClick = { onProductClick(product.id) }
                        )
                    }
                }
            }
        }
        
        is UiState.Error -> {
            ErrorState(
                message = state.message,
                onRetry = { viewModel.refresh() }
            )
        }
    }
}

@Composable
fun ProductCard(
    product: Product,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Card(
        onClick = onClick,
        modifier = modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier.padding(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            AsyncImage(
                model = product.imageUrl,
                contentDescription = product.name,
                modifier = Modifier
                    .size(80.dp)
                    .clip(MaterialTheme.shapes.small),
                contentScale = ContentScale.Crop
            )
            
            Spacer(modifier = Modifier.width(12.dp))
            
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = product.name,
                    style = MaterialTheme.typography.titleMedium
                )
                Text(
                    text = product.category,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = "$${product.price}",
                    style = MaterialTheme.typography.titleSmall,
                    color = MaterialTheme.colorScheme.primary
                )
            }
        }
    }
}
```

---

## 4) ViewModel & State

### MVI Pattern
```kotlin
// ==========================================
// LOGIN VIEW MODEL (MVI)
// ==========================================

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import javax.inject.Inject

data class LoginUiState(
    val email: String = "",
    val password: String = "",
    val isLoading: Boolean = false,
    val emailError: String? = null,
    val passwordError: String? = null
) {
    val isValid: Boolean
        get() = email.isNotBlank() && 
                password.isNotBlank() && 
                emailError == null && 
                passwordError == null
}

sealed interface LoginEvent {
    data class EmailChanged(val email: String) : LoginEvent
    data class PasswordChanged(val password: String) : LoginEvent
    data object LoginClicked : LoginEvent
    data object ForgotPasswordClicked : LoginEvent
}

sealed interface LoginUiEvent {
    data object NavigateToHome : LoginUiEvent
    data object NavigateToForgotPassword : LoginUiEvent
    data class ShowError(val message: String) : LoginUiEvent
}

@HiltViewModel
class LoginViewModel @Inject constructor(
    private val loginUseCase: LoginUseCase,
    private val validateEmailUseCase: ValidateEmailUseCase,
    private val validatePasswordUseCase: ValidatePasswordUseCase
) : ViewModel() {

    private val _uiState = MutableStateFlow(LoginUiState())
    val uiState: StateFlow<LoginUiState> = _uiState.asStateFlow()

    private val _events = MutableSharedFlow<LoginUiEvent>()
    val events: SharedFlow<LoginUiEvent> = _events.asSharedFlow()

    fun onEvent(event: LoginEvent) {
        when (event) {
            is LoginEvent.EmailChanged -> {
                _uiState.update { state ->
                    state.copy(
                        email = event.email,
                        emailError = validateEmailUseCase(event.email).errorMessage
                    )
                }
            }
            is LoginEvent.PasswordChanged -> {
                _uiState.update { state ->
                    state.copy(
                        password = event.password,
                        passwordError = validatePasswordUseCase(event.password).errorMessage
                    )
                }
            }
            LoginEvent.LoginClicked -> login()
            LoginEvent.ForgotPasswordClicked -> {
                viewModelScope.launch {
                    _events.emit(LoginUiEvent.NavigateToForgotPassword)
                }
            }
        }
    }

    private fun login() {
        viewModelScope.launch {
            val currentState = _uiState.value
            
            _uiState.update { it.copy(isLoading = true) }
            
            loginUseCase(currentState.email, currentState.password)
                .onSuccess {
                    _events.emit(LoginUiEvent.NavigateToHome)
                }
                .onFailure { error ->
                    _uiState.update { it.copy(isLoading = false) }
                    _events.emit(LoginUiEvent.ShowError(error.message ?: "Login failed"))
                }
        }
    }
}


// ==========================================
// USE CASES
// ==========================================

class LoginUseCase @Inject constructor(
    private val authRepository: AuthRepository
) {
    suspend operator fun invoke(email: String, password: String): Result<User> {
        return authRepository.login(email, password)
    }
}

data class ValidationResult(
    val isValid: Boolean,
    val errorMessage: String? = null
)

class ValidateEmailUseCase @Inject constructor() {
    operator fun invoke(email: String): ValidationResult {
        if (email.isBlank()) {
            return ValidationResult(false, "Email is required")
        }
        if (!email.isValidEmail()) {
            return ValidationResult(false, "Invalid email format")
        }
        return ValidationResult(true)
    }
}

class ValidatePasswordUseCase @Inject constructor() {
    operator fun invoke(password: String): ValidationResult {
        if (password.isBlank()) {
            return ValidationResult(false, "Password is required")
        }
        if (password.length < 6) {
            return ValidationResult(false, "Password must be at least 6 characters")
        }
        return ValidationResult(true)
    }
}
```

---

## 5) Data Layer

### Room Database
```kotlin
// ==========================================
// ROOM ENTITIES
// ==========================================

import androidx.room.*

@Entity(tableName = "users")
data class UserEntity(
    @PrimaryKey
    val id: String,
    val email: String,
    val name: String,
    @ColumnInfo(name = "avatar_url")
    val avatarUrl: String?,
    @ColumnInfo(name = "created_at")
    val createdAt: Long
)

@Entity(
    tableName = "products",
    indices = [Index(value = ["category_id"])]
)
data class ProductEntity(
    @PrimaryKey
    val id: String,
    val name: String,
    val description: String,
    val price: Double,
    @ColumnInfo(name = "image_url")
    val imageUrl: String,
    @ColumnInfo(name = "category_id")
    val categoryId: String,
    @ColumnInfo(name = "created_at")
    val createdAt: Long
)


// ==========================================
// DAO
// ==========================================

@Dao
interface ProductDao {
    @Query("SELECT * FROM products ORDER BY created_at DESC")
    fun getAllProducts(): Flow<List<ProductEntity>>

    @Query("SELECT * FROM products WHERE category_id = :categoryId")
    fun getProductsByCategory(categoryId: String): Flow<List<ProductEntity>>

    @Query("SELECT * FROM products WHERE id = :id")
    suspend fun getProductById(id: String): ProductEntity?

    @Query("SELECT * FROM products WHERE name LIKE '%' || :query || '%'")
    fun searchProducts(query: String): Flow<List<ProductEntity>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertProducts(products: List<ProductEntity>)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertProduct(product: ProductEntity)

    @Delete
    suspend fun deleteProduct(product: ProductEntity)

    @Query("DELETE FROM products")
    suspend fun deleteAllProducts()
}


// ==========================================
// DATABASE
// ==========================================

@Database(
    entities = [UserEntity::class, ProductEntity::class],
    version = 1,
    exportSchema = true
)
@TypeConverters(Converters::class)
abstract class AppDatabase : RoomDatabase() {
    abstract fun userDao(): UserDao
    abstract fun productDao(): ProductDao
}

class Converters {
    @TypeConverter
    fun fromTimestamp(value: Long?): Date? {
        return value?.let { Date(it) }
    }

    @TypeConverter
    fun dateToTimestamp(date: Date?): Long? {
        return date?.time
    }
}


// ==========================================
// DATABASE MODULE (HILT)
// ==========================================

@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {

    @Provides
    @Singleton
    fun provideDatabase(
        @ApplicationContext context: Context
    ): AppDatabase {
        return Room.databaseBuilder(
            context,
            AppDatabase::class.java,
            "app_database"
        )
            .fallbackToDestructiveMigration()
            .build()
    }

    @Provides
    fun provideProductDao(database: AppDatabase): ProductDao {
        return database.productDao()
    }

    @Provides
    fun provideUserDao(database: AppDatabase): UserDao {
        return database.userDao()
    }
}
```

### Retrofit Networking
```kotlin
// ==========================================
// API SERVICE
// ==========================================

import retrofit2.http.*

interface ApiService {
    @GET("users/{id}")
    suspend fun getUser(@Path("id") id: String): UserDto

    @GET("products")
    suspend fun getProducts(
        @Query("page") page: Int = 1,
        @Query("limit") limit: Int = 20
    ): ProductListResponse

    @GET("products/{id}")
    suspend fun getProduct(@Path("id") id: String): ProductDto

    @POST("auth/login")
    suspend fun login(@Body request: LoginRequest): AuthResponse

    @POST("auth/register")
    suspend fun register(@Body request: RegisterRequest): AuthResponse

    @PUT("users/{id}")
    suspend fun updateUser(
        @Path("id") id: String,
        @Body request: UpdateUserRequest
    ): UserDto
}


// ==========================================
// DTOs
// ==========================================

data class LoginRequest(
    val email: String,
    val password: String
)

data class AuthResponse(
    val token: String,
    val user: UserDto
)

data class UserDto(
    val id: String,
    val email: String,
    val name: String,
    @SerializedName("avatar_url")
    val avatarUrl: String?,
    @SerializedName("created_at")
    val createdAt: String
) {
    fun toDomain(): User = User(
        id = id,
        email = email,
        name = name,
        avatarUrl = avatarUrl,
        createdAt = Instant.parse(createdAt)
    )
}


// ==========================================
// NETWORK MODULE (HILT)
// ==========================================

@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {

    @Provides
    @Singleton
    fun provideOkHttpClient(
        authInterceptor: AuthInterceptor,
        loggingInterceptor: HttpLoggingInterceptor
    ): OkHttpClient {
        return OkHttpClient.Builder()
            .addInterceptor(authInterceptor)
            .addInterceptor(loggingInterceptor)
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .writeTimeout(30, TimeUnit.SECONDS)
            .build()
    }

    @Provides
    @Singleton
    fun provideRetrofit(okHttpClient: OkHttpClient): Retrofit {
        return Retrofit.Builder()
            .baseUrl(BuildConfig.API_BASE_URL)
            .client(okHttpClient)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
    }

    @Provides
    @Singleton
    fun provideApiService(retrofit: Retrofit): ApiService {
        return retrofit.create(ApiService::class.java)
    }

    @Provides
    @Singleton
    fun provideLoggingInterceptor(): HttpLoggingInterceptor {
        return HttpLoggingInterceptor().apply {
            level = if (BuildConfig.DEBUG) 
                HttpLoggingInterceptor.Level.BODY 
            else 
                HttpLoggingInterceptor.Level.NONE
        }
    }
}


// ==========================================
// AUTH INTERCEPTOR
// ==========================================

class AuthInterceptor @Inject constructor(
    private val tokenManager: TokenManager
) : Interceptor {

    override fun intercept(chain: Interceptor.Chain): Response {
        val originalRequest = chain.request()
        
        val token = tokenManager.getToken()
        
        val request = if (token != null) {
            originalRequest.newBuilder()
                .header("Authorization", "Bearer $token")
                .build()
        } else {
            originalRequest
        }
        
        val response = chain.proceed(request)
        
        if (response.code == 401) {
            tokenManager.clearToken()
            // Trigger logout event
        }
        
        return response
    }
}
```

### Repository Pattern
```kotlin
// ==========================================
// REPOSITORY INTERFACE
// ==========================================

interface ProductRepository {
    fun getProducts(): Flow<List<Product>>
    suspend fun getProduct(id: String): Product?
    fun searchProducts(query: String): Flow<List<Product>>
    suspend fun refreshProducts()
}


// ==========================================
// REPOSITORY IMPLEMENTATION
// ==========================================

class ProductRepositoryImpl @Inject constructor(
    private val apiService: ApiService,
    private val productDao: ProductDao,
    private val dispatcher: CoroutineDispatcher = Dispatchers.IO
) : ProductRepository {

    override fun getProducts(): Flow<List<Product>> {
        return productDao.getAllProducts()
            .map { entities -> entities.map { it.toDomain() } }
            .flowOn(dispatcher)
    }

    override suspend fun getProduct(id: String): Product? {
        return withContext(dispatcher) {
            productDao.getProductById(id)?.toDomain()
        }
    }

    override fun searchProducts(query: String): Flow<List<Product>> {
        return productDao.searchProducts(query)
            .map { entities -> entities.map { it.toDomain() } }
            .flowOn(dispatcher)
    }

    override suspend fun refreshProducts() {
        withContext(dispatcher) {
            try {
                val response = apiService.getProducts()
                val entities = response.products.map { it.toEntity() }
                productDao.insertProducts(entities)
            } catch (e: Exception) {
                throw e
            }
        }
    }
}
```

---

## 6) Navigation

### Navigation Compose
```kotlin
// ==========================================
// NAVIGATION SETUP
// ==========================================

import androidx.navigation.compose.*

sealed class Screen(val route: String) {
    data object Login : Screen("login")
    data object SignUp : Screen("signup")
    data object Home : Screen("home")
    data object ProductList : Screen("products")
    data object ProductDetail : Screen("products/{productId}") {
        fun createRoute(productId: String) = "products/$productId"
    }
    data object Profile : Screen("profile")
    data object Settings : Screen("settings")
}

@Composable
fun AppNavigation(
    navController: NavHostController = rememberNavController(),
    startDestination: String = Screen.Login.route
) {
    NavHost(
        navController = navController,
        startDestination = startDestination
    ) {
        // Auth flow
        composable(Screen.Login.route) {
            LoginScreen(
                onNavigateToHome = {
                    navController.navigate(Screen.Home.route) {
                        popUpTo(Screen.Login.route) { inclusive = true }
                    }
                },
                onNavigateToSignUp = {
                    navController.navigate(Screen.SignUp.route)
                }
            )
        }
        
        composable(Screen.SignUp.route) {
            SignUpScreen(
                onNavigateBack = { navController.popBackStack() },
                onNavigateToHome = {
                    navController.navigate(Screen.Home.route) {
                        popUpTo(Screen.Login.route) { inclusive = true }
                    }
                }
            )
        }
        
        // Main flow
        composable(Screen.Home.route) {
            HomeScreen(
                onNavigateToProducts = {
                    navController.navigate(Screen.ProductList.route)
                },
                onNavigateToProfile = {
                    navController.navigate(Screen.Profile.route)
                }
            )
        }
        
        composable(Screen.ProductList.route) {
            ProductListScreen(
                onProductClick = { productId ->
                    navController.navigate(Screen.ProductDetail.createRoute(productId))
                }
            )
        }
        
        composable(
            route = Screen.ProductDetail.route,
            arguments = listOf(
                navArgument("productId") { type = NavType.StringType }
            )
        ) { backStackEntry ->
            val productId = backStackEntry.arguments?.getString("productId") ?: return@composable
            ProductDetailScreen(
                productId = productId,
                onNavigateBack = { navController.popBackStack() }
            )
        }
    }
}


// ==========================================
// BOTTOM NAVIGATION
// ==========================================

@Composable
fun MainScreen() {
    val navController = rememberNavController()
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = navBackStackEntry?.destination?.route
    
    Scaffold(
        bottomBar = {
            if (shouldShowBottomBar(currentRoute)) {
                NavigationBar {
                    bottomNavItems.forEach { item ->
                        NavigationBarItem(
                            icon = { Icon(item.icon, contentDescription = item.title) },
                            label = { Text(item.title) },
                            selected = currentRoute == item.route,
                            onClick = {
                                navController.navigate(item.route) {
                                    popUpTo(navController.graph.findStartDestination().id) {
                                        saveState = true
                                    }
                                    launchSingleTop = true
                                    restoreState = true
                                }
                            }
                        )
                    }
                }
            }
        }
    ) { padding ->
        AppNavigation(
            navController = navController,
            modifier = Modifier.padding(padding)
        )
    }
}

data class BottomNavItem(
    val route: String,
    val title: String,
    val icon: ImageVector
)

val bottomNavItems = listOf(
    BottomNavItem(Screen.Home.route, "Home", Icons.Default.Home),
    BottomNavItem(Screen.ProductList.route, "Products", Icons.Default.ShoppingBag),
    BottomNavItem(Screen.Profile.route, "Profile", Icons.Default.Person)
)
```

---

## 7) Testing

### Unit & UI Tests
```kotlin
// ==========================================
// VIEWMODEL TESTS
// ==========================================

import io.mockk.*
import kotlinx.coroutines.test.*
import org.junit.jupiter.api.*
import kotlin.test.assertEquals

@OptIn(ExperimentalCoroutinesApi::class)
class LoginViewModelTest {
    
    private lateinit var viewModel: LoginViewModel
    private lateinit var loginUseCase: LoginUseCase
    private lateinit var validateEmailUseCase: ValidateEmailUseCase
    private lateinit var validatePasswordUseCase: ValidatePasswordUseCase
    
    private val testDispatcher = StandardTestDispatcher()
    
    @BeforeEach
    fun setup() {
        Dispatchers.setMain(testDispatcher)
        
        loginUseCase = mockk()
        validateEmailUseCase = ValidateEmailUseCase()
        validatePasswordUseCase = ValidatePasswordUseCase()
        
        viewModel = LoginViewModel(
            loginUseCase = loginUseCase,
            validateEmailUseCase = validateEmailUseCase,
            validatePasswordUseCase = validatePasswordUseCase
        )
    }
    
    @AfterEach
    fun tearDown() {
        Dispatchers.resetMain()
    }
    
    @Test
    fun `email change updates state correctly`() = runTest {
        viewModel.onEvent(LoginEvent.EmailChanged("test@example.com"))
        
        assertEquals("test@example.com", viewModel.uiState.value.email)
        assertEquals(null, viewModel.uiState.value.emailError)
    }
    
    @Test
    fun `invalid email shows error`() = runTest {
        viewModel.onEvent(LoginEvent.EmailChanged("invalid-email"))
        
        assertEquals("Invalid email format", viewModel.uiState.value.emailError)
    }
    
    @Test
    fun `successful login emits navigate event`() = runTest {
        val user = User(id = "1", email = "test@example.com", name = "Test")
        coEvery { loginUseCase(any(), any()) } returns Result.success(user)
        
        viewModel.onEvent(LoginEvent.EmailChanged("test@example.com"))
        viewModel.onEvent(LoginEvent.PasswordChanged("password123"))
        viewModel.onEvent(LoginEvent.LoginClicked)
        
        advanceUntilIdle()
        
        val events = mutableListOf<LoginUiEvent>()
        viewModel.events.take(1).toList(events)
        
        assertEquals(LoginUiEvent.NavigateToHome, events.first())
    }
    
    @Test
    fun `failed login shows error`() = runTest {
        coEvery { loginUseCase(any(), any()) } returns Result.failure(Exception("Invalid credentials"))
        
        viewModel.onEvent(LoginEvent.EmailChanged("test@example.com"))
        viewModel.onEvent(LoginEvent.PasswordChanged("wrong-password"))
        viewModel.onEvent(LoginEvent.LoginClicked)
        
        advanceUntilIdle()
        
        val events = mutableListOf<LoginUiEvent>()
        viewModel.events.take(1).toList(events)
        
        assertTrue(events.first() is LoginUiEvent.ShowError)
    }
}


// ==========================================
// COMPOSE UI TESTS
// ==========================================

import androidx.compose.ui.test.*
import androidx.compose.ui.test.junit4.createComposeRule

class LoginScreenTest {
    
    @get:Rule
    val composeTestRule = createComposeRule()
    
    @Test
    fun loginScreen_displaysAllElements() {
        composeTestRule.setContent {
            LoginScreen(
                onNavigateToHome = {},
                onNavigateToSignUp = {}
            )
        }
        
        composeTestRule.onNodeWithText("Welcome Back").assertIsDisplayed()
        composeTestRule.onNodeWithText("Email").assertIsDisplayed()
        composeTestRule.onNodeWithText("Password").assertIsDisplayed()
        composeTestRule.onNodeWithText("Sign In").assertIsDisplayed()
        composeTestRule.onNodeWithText("Forgot Password?").assertIsDisplayed()
    }
    
    @Test
    fun loginButton_disabledWhenFieldsEmpty() {
        composeTestRule.setContent {
            LoginScreen(
                onNavigateToHome = {},
                onNavigateToSignUp = {}
            )
        }
        
        composeTestRule.onNodeWithText("Sign In").assertIsNotEnabled()
    }
    
    @Test
    fun loginButton_enabledWhenFieldsFilled() {
        composeTestRule.setContent {
            LoginScreen(
                onNavigateToHome = {},
                onNavigateToSignUp = {}
            )
        }
        
        composeTestRule.onNodeWithText("Email").performTextInput("test@example.com")
        composeTestRule.onNodeWithText("Password").performTextInput("password123")
        
        composeTestRule.onNodeWithText("Sign In").assertIsEnabled()
    }
}
```

---

## Best Practices Checklist

### Code Quality
- [ ] Use Kotlin idioms
- [ ] Handle nulls properly
- [ ] Use sealed classes for state
- [ ] Follow naming conventions

### Architecture
- [ ] Unidirectional data flow
- [ ] Repository pattern
- [ ] Use cases for business logic
- [ ] Feature modules

### Performance
- [ ] Avoid recomposition
- [ ] Use keys in LazyColumn
- [ ] Profile with Android Studio
- [ ] Enable R8 shrinking

### Testing
- [ ] Unit tests for ViewModels
- [ ] UI tests for Compose
- [ ] Mock dependencies
- [ ] Test edge cases

---

**References:**
- [Android Developers](https://developer.android.com/)
- [Jetpack Compose](https://developer.android.com/jetpack/compose)
- [Kotlin Documentation](https://kotlinlang.org/docs/home.html)
