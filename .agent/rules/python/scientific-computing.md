# Python Scientific Computing Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31
> **Python:** 3.11+ | **NumPy:** 2.x | **Tools:** JAX, Numba, CuPy
> **Priority:** P1 - Load for scientific computing projects

---

You are an expert in Python scientific computing with NumPy, SciPy, JAX, and Numba.

## Key Principles

- Use vectorization for performance
- Leverage JAX for GPU/TPU acceleration
- Use Numba for JIT compilation
- Write reproducible research code
- Validate numerical results
- Document algorithms and assumptions

---

## Project Structure

```
scientific-project/
├── src/
│   ├── __init__.py
│   ├── core/
│   │   ├── linalg.py
│   │   ├── optimization.py
│   │   └── integration.py
│   ├── models/
│   │   ├── physics.py
│   │   └── statistics.py
│   ├── utils/
│   │   ├── validation.py
│   │   └── visualization.py
│   └── accelerated/
│       ├── jax_ops.py
│       └── numba_ops.py
├── notebooks/
├── tests/
├── data/
├── figures/
└── pyproject.toml
```

---

## NumPy Fundamentals

### Array Operations
```python
import numpy as np
from numpy.typing import NDArray


def array_operations_demo():
    """NumPy array operations."""
    
    # Create arrays
    a = np.array([1, 2, 3, 4, 5], dtype=np.float64)
    b = np.linspace(0, 1, 100)
    c = np.arange(0, 10, 0.5)
    
    # Multidimensional
    matrix = np.random.randn(3, 4)
    tensor = np.random.randn(2, 3, 4)
    
    # Broadcasting
    x = np.arange(4)          # shape (4,)
    y = np.arange(3)[:, None] # shape (3, 1)
    result = x + y            # shape (3, 4) - broadcasted
    
    # Vectorized operations
    squared = a ** 2
    exp_vals = np.exp(a)
    sin_vals = np.sin(b * 2 * np.pi)
    
    # Boolean indexing
    mask = a > 2
    filtered = a[mask]
    
    # Conditional operations
    clipped = np.where(a > 3, 3, a)
    
    return result


def efficient_operations(arr: NDArray[np.float64]) -> NDArray[np.float64]:
    """Efficient NumPy patterns."""
    
    # Use einsum for complex operations
    # Matrix multiplication: C = A @ B
    A = np.random.randn(100, 50)
    B = np.random.randn(50, 30)
    C = np.einsum("ij,jk->ik", A, B)
    
    # Batch matrix multiplication
    batch_A = np.random.randn(10, 100, 50)
    batch_B = np.random.randn(10, 50, 30)
    batch_C = np.einsum("bij,bjk->bik", batch_A, batch_B)
    
    # Outer product
    outer = np.einsum("i,j->ij", arr, arr)
    
    # Trace of matrix
    trace = np.einsum("ii->", np.eye(5))
    
    # Diagonal extraction
    diag = np.einsum("ii->i", np.random.randn(5, 5))
    
    return batch_C


def memory_efficient(large_arr: NDArray) -> NDArray:
    """Memory-efficient operations."""
    
    # Use out parameter to avoid allocation
    result = np.empty_like(large_arr)
    np.multiply(large_arr, 2, out=result)
    
    # Use views instead of copies
    view = large_arr[::2]  # Every other element (view)
    copy = large_arr[::2].copy()  # Explicit copy
    
    # Check if it's a view
    is_view = view.base is large_arr
    
    # Use contiguous arrays for performance
    if not large_arr.flags["C_CONTIGUOUS"]:
        large_arr = np.ascontiguousarray(large_arr)
    
    # Memory-mapped arrays for large files
    mmap_arr = np.memmap(
        "large_array.dat",
        dtype=np.float64,
        mode="r+",
        shape=(1000000,),
    )
    
    return result
```

---

## Linear Algebra

### Matrix Operations
```python
import numpy as np
from numpy import linalg as LA
from scipy import linalg as SLA
from numpy.typing import NDArray


class LinearAlgebra:
    """Linear algebra operations."""
    
    @staticmethod
    def solve_system(A: NDArray, b: NDArray) -> NDArray:
        """Solve Ax = b."""
        # Direct solve
        x = LA.solve(A, b)
        
        # Verify solution
        residual = LA.norm(A @ x - b)
        
        return x
    
    @staticmethod
    def solve_least_squares(A: NDArray, b: NDArray) -> NDArray:
        """Solve overdetermined system (least squares)."""
        x, residuals, rank, s = LA.lstsq(A, b, rcond=None)
        return x
    
    @staticmethod
    def eigendecomposition(A: NDArray) -> tuple[NDArray, NDArray]:
        """Compute eigenvalues and eigenvectors."""
        # Standard eigendecomposition
        eigenvalues, eigenvectors = LA.eig(A)
        
        # For symmetric matrices (more stable)
        if np.allclose(A, A.T):
            eigenvalues, eigenvectors = LA.eigh(A)
        
        return eigenvalues, eigenvectors
    
    @staticmethod
    def svd_decomposition(A: NDArray, k: int | None = None) -> tuple:
        """Singular Value Decomposition."""
        U, s, Vh = LA.svd(A, full_matrices=False)
        
        # Truncated SVD for dimensionality reduction
        if k is not None:
            U = U[:, :k]
            s = s[:k]
            Vh = Vh[:k, :]
        
        # Reconstruct
        A_reconstructed = U @ np.diag(s) @ Vh
        
        return U, s, Vh
    
    @staticmethod
    def matrix_factorizations(A: NDArray) -> dict:
        """Various matrix factorizations."""
        
        # LU decomposition
        P, L, U = SLA.lu(A)
        
        # Cholesky (for positive definite)
        try:
            L_chol = LA.cholesky(A)
        except LA.LinAlgError:
            L_chol = None
        
        # QR decomposition
        Q, R = LA.qr(A)
        
        return {
            "lu": (P, L, U),
            "cholesky": L_chol,
            "qr": (Q, R),
        }
    
    @staticmethod
    def condition_number(A: NDArray) -> float:
        """Compute condition number."""
        cond = LA.cond(A)
        
        # If condition number is large, matrix is ill-conditioned
        if cond > 1e10:
            print("Warning: Matrix is ill-conditioned")
        
        return cond


# Usage
linalg = LinearAlgebra()

# Solve system
A = np.array([[3, 1], [1, 2]], dtype=np.float64)
b = np.array([9, 8], dtype=np.float64)
x = linalg.solve_system(A, b)

# SVD for low-rank approximation
data = np.random.randn(100, 50)
U, s, Vh = linalg.svd_decomposition(data, k=10)
```

---

## SciPy Scientific Computing

### Optimization
```python
from scipy import optimize
from scipy.optimize import minimize, curve_fit, root
import numpy as np
from typing import Callable


class Optimization:
    """Optimization algorithms."""
    
    @staticmethod
    def minimize_function(
        func: Callable,
        x0: np.ndarray,
        method: str = "L-BFGS-B",
        bounds: list[tuple] | None = None,
        constraints: list[dict] | None = None,
    ) -> optimize.OptimizeResult:
        """General optimization."""
        
        result = minimize(
            func,
            x0,
            method=method,
            bounds=bounds,
            constraints=constraints,
            options={"maxiter": 1000, "disp": True},
        )
        
        return result
    
    @staticmethod
    def gradient_descent(
        func: Callable,
        grad: Callable,
        x0: np.ndarray,
        learning_rate: float = 0.01,
        max_iter: int = 1000,
        tol: float = 1e-6,
    ) -> tuple[np.ndarray, list[float]]:
        """Manual gradient descent."""
        
        x = x0.copy()
        history = []
        
        for i in range(max_iter):
            g = grad(x)
            x = x - learning_rate * g
            
            loss = func(x)
            history.append(loss)
            
            if np.linalg.norm(g) < tol:
                break
        
        return x, history
    
    @staticmethod
    def curve_fitting(
        func: Callable,
        xdata: np.ndarray,
        ydata: np.ndarray,
        p0: np.ndarray | None = None,
    ) -> tuple[np.ndarray, np.ndarray]:
        """Fit function to data."""
        
        popt, pcov = curve_fit(func, xdata, ydata, p0=p0)
        
        # Standard errors
        perr = np.sqrt(np.diag(pcov))
        
        return popt, perr
    
    @staticmethod
    def constrained_optimization(
        func: Callable,
        x0: np.ndarray,
    ) -> optimize.OptimizeResult:
        """Optimization with constraints."""
        
        # Inequality constraint: g(x) >= 0
        def constraint_ineq(x):
            return x[0] + x[1] - 1
        
        # Equality constraint: h(x) = 0
        def constraint_eq(x):
            return x[0] ** 2 + x[1] ** 2 - 1
        
        constraints = [
            {"type": "ineq", "fun": constraint_ineq},
            {"type": "eq", "fun": constraint_eq},
        ]
        
        bounds = [(0, None), (0, None)]  # x >= 0
        
        result = minimize(
            func,
            x0,
            method="SLSQP",
            bounds=bounds,
            constraints=constraints,
        )
        
        return result


# Example: Rosenbrock function
def rosenbrock(x):
    return (1 - x[0]) ** 2 + 100 * (x[1] - x[0] ** 2) ** 2


def rosenbrock_grad(x):
    return np.array([
        -2 * (1 - x[0]) - 400 * x[0] * (x[1] - x[0] ** 2),
        200 * (x[1] - x[0] ** 2),
    ])


opt = Optimization()
result = opt.minimize_function(rosenbrock, np.array([0.0, 0.0]))
print(f"Minimum at: {result.x}")
```

### Numerical Integration
```python
from scipy import integrate
import numpy as np


class NumericalIntegration:
    """Numerical integration methods."""
    
    @staticmethod
    def integrate_1d(
        func: callable,
        a: float,
        b: float,
    ) -> tuple[float, float]:
        """1D numerical integration."""
        result, error = integrate.quad(func, a, b)
        return result, error
    
    @staticmethod
    def integrate_2d(
        func: callable,
        x_limits: tuple[float, float],
        y_limits: tuple[float, float] | callable,
    ) -> tuple[float, float]:
        """2D numerical integration."""
        result, error = integrate.dblquad(
            func,
            x_limits[0], x_limits[1],
            y_limits[0] if callable(y_limits) else y_limits[0],
            y_limits[1] if callable(y_limits) else y_limits[1],
        )
        return result, error
    
    @staticmethod
    def solve_ode(
        func: callable,
        y0: np.ndarray,
        t_span: tuple[float, float],
        t_eval: np.ndarray | None = None,
    ) -> integrate.OdeResult:
        """Solve ODE: dy/dt = f(t, y)."""
        
        result = integrate.solve_ivp(
            func,
            t_span,
            y0,
            method="RK45",
            t_eval=t_eval,
            dense_output=True,
        )
        
        return result
    
    @staticmethod
    def solve_bvp(
        func: callable,
        bc: callable,
        x: np.ndarray,
        y: np.ndarray,
    ) -> integrate.BVPResult:
        """Solve boundary value problem."""
        
        result = integrate.solve_bvp(func, bc, x, y)
        return result


# Example: Harmonic oscillator
def harmonic_oscillator(t, y, omega=1.0):
    """d²x/dt² = -ω²x"""
    x, v = y
    return [v, -omega ** 2 * x]


integrator = NumericalIntegration()

# Solve ODE
t_span = (0, 10)
y0 = [1.0, 0.0]  # Initial position and velocity
t_eval = np.linspace(0, 10, 100)

solution = integrator.solve_ode(
    harmonic_oscillator,
    y0,
    t_span,
    t_eval,
)

# Access solution
t = solution.t
x = solution.y[0]
v = solution.y[1]
```

---

## JAX (Accelerated Computing)

### JAX Fundamentals
```python
import jax
import jax.numpy as jnp
from jax import grad, jit, vmap, pmap
from jax import random
from functools import partial


# Enable 64-bit precision
jax.config.update("jax_enable_x64", True)


class JAXComputing:
    """JAX accelerated computing."""
    
    @staticmethod
    @jit
    def matrix_operations(A: jnp.ndarray, B: jnp.ndarray) -> jnp.ndarray:
        """JIT-compiled matrix operations."""
        C = A @ B
        D = jnp.linalg.inv(C)
        return D @ A
    
    @staticmethod
    def auto_differentiation():
        """Automatic differentiation with JAX."""
        
        # Function to differentiate
        def f(x):
            return jnp.sum(x ** 2)
        
        # Gradient
        grad_f = grad(f)
        
        x = jnp.array([1.0, 2.0, 3.0])
        gradient = grad_f(x)  # [2, 4, 6]
        
        # Hessian
        hessian_f = jax.hessian(f)
        hessian = hessian_f(x)
        
        # Jacobian
        def g(x):
            return jnp.array([x[0] ** 2, x[0] * x[1], x[1] ** 2])
        
        jacobian_g = jax.jacobian(g)
        jacobian = jacobian_g(x[:2])
        
        return gradient, hessian, jacobian
    
    @staticmethod
    @partial(jit, static_argnums=(2,))
    def gradient_descent(
        f: callable,
        x0: jnp.ndarray,
        num_steps: int = 100,
        learning_rate: float = 0.01,
    ) -> jnp.ndarray:
        """JIT-compiled gradient descent."""
        
        grad_f = grad(f)
        
        def step(x, _):
            g = grad_f(x)
            return x - learning_rate * g, None
        
        x_final, _ = jax.lax.scan(step, x0, None, length=num_steps)
        return x_final
    
    @staticmethod
    def vectorized_operations():
        """Vectorization with vmap."""
        
        # Single input function
        def single_predict(params, x):
            w, b = params
            return jnp.dot(w, x) + b
        
        # Vectorize over batch dimension
        batch_predict = vmap(single_predict, in_axes=(None, 0))
        
        # Usage
        key = random.PRNGKey(0)
        w = random.normal(key, (10,))
        b = 0.0
        params = (w, b)
        
        X = random.normal(key, (32, 10))  # Batch of 32
        predictions = batch_predict(params, X)  # Shape (32,)
        
        return predictions
    
    @staticmethod
    def neural_network_forward():
        """Simple neural network with JAX."""
        
        def init_params(key, layer_sizes):
            """Initialize network parameters."""
            keys = random.split(key, len(layer_sizes) - 1)
            params = []
            
            for k, (m, n) in zip(keys, zip(layer_sizes[:-1], layer_sizes[1:])):
                w = random.normal(k, (m, n)) * jnp.sqrt(2.0 / m)
                b = jnp.zeros(n)
                params.append((w, b))
            
            return params
        
        def forward(params, x):
            """Forward pass."""
            for w, b in params[:-1]:
                x = jax.nn.relu(x @ w + b)
            
            w, b = params[-1]
            return x @ w + b
        
        def loss_fn(params, x, y):
            """MSE loss."""
            pred = forward(params, x)
            return jnp.mean((pred - y) ** 2)
        
        @jit
        def train_step(params, x, y, lr=0.01):
            """Single training step."""
            grads = grad(loss_fn)(params, x, y)
            
            new_params = [
                (w - lr * gw, b - lr * gb)
                for (w, b), (gw, gb) in zip(params, grads)
            ]
            
            return new_params
        
        # Initialize
        key = random.PRNGKey(42)
        params = init_params(key, [784, 128, 64, 10])
        
        # Train
        x = random.normal(key, (32, 784))
        y = random.normal(key, (32, 10))
        
        for _ in range(100):
            params = train_step(params, x, y)
        
        return params


# Usage
jax_comp = JAXComputing()

# JIT compilation
A = jnp.array(random.normal(random.PRNGKey(0), (100, 100)))
B = jnp.array(random.normal(random.PRNGKey(1), (100, 100)))
result = jax_comp.matrix_operations(A, B)

# Automatic differentiation
gradient, hessian, jacobian = jax_comp.auto_differentiation()
```

---

## Numba JIT Compilation

### Numba Acceleration
```python
import numpy as np
from numba import jit, njit, prange, vectorize, guvectorize
from numba import float64, int64
import numba


@njit
def numba_dot_product(a: np.ndarray, b: np.ndarray) -> float:
    """Numba-accelerated dot product."""
    result = 0.0
    for i in range(len(a)):
        result += a[i] * b[i]
    return result


@njit(parallel=True)
def parallel_matrix_multiply(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Parallel matrix multiplication with Numba."""
    m, k = A.shape
    k2, n = B.shape
    
    C = np.zeros((m, n), dtype=A.dtype)
    
    for i in prange(m):
        for j in range(n):
            total = 0.0
            for l in range(k):
                total += A[i, l] * B[l, j]
            C[i, j] = total
    
    return C


@njit
def mandelbrot_numba(
    xmin: float,
    xmax: float,
    ymin: float,
    ymax: float,
    width: int,
    height: int,
    max_iter: int,
) -> np.ndarray:
    """Mandelbrot set computation with Numba."""
    
    result = np.zeros((height, width), dtype=np.int32)
    
    for i in range(height):
        for j in range(width):
            x = xmin + (xmax - xmin) * j / width
            y = ymin + (ymax - ymin) * i / height
            
            c = complex(x, y)
            z = 0j
            
            for n in range(max_iter):
                if abs(z) > 2:
                    result[i, j] = n
                    break
                z = z * z + c
            else:
                result[i, j] = max_iter
    
    return result


@njit(parallel=True)
def parallel_mandelbrot(
    xmin: float,
    xmax: float,
    ymin: float,
    ymax: float,
    width: int,
    height: int,
    max_iter: int,
) -> np.ndarray:
    """Parallel Mandelbrot computation."""
    
    result = np.zeros((height, width), dtype=np.int32)
    
    for i in prange(height):
        for j in range(width):
            x = xmin + (xmax - xmin) * j / width
            y = ymin + (ymax - ymin) * i / height
            
            c = complex(x, y)
            z = 0j
            
            for n in range(max_iter):
                if abs(z) > 2:
                    result[i, j] = n
                    break
                z = z * z + c
            else:
                result[i, j] = max_iter
    
    return result


@vectorize([float64(float64, float64)])
def fast_hypotenuse(x, y):
    """Vectorized hypotenuse with Numba."""
    return np.sqrt(x ** 2 + y ** 2)


@guvectorize(
    [(float64[:], float64[:], float64[:])],
    "(n),(n)->(n)",
)
def generalized_add(a, b, result):
    """Generalized ufunc with Numba."""
    for i in range(a.shape[0]):
        result[i] = a[i] + b[i]


@njit
def solve_ode_numba(
    f,
    y0: np.ndarray,
    t: np.ndarray,
) -> np.ndarray:
    """Simple RK4 solver with Numba."""
    
    n = len(t)
    m = len(y0)
    y = np.zeros((n, m))
    y[0] = y0
    
    for i in range(n - 1):
        dt = t[i + 1] - t[i]
        ti = t[i]
        yi = y[i]
        
        k1 = f(ti, yi)
        k2 = f(ti + dt / 2, yi + dt * k1 / 2)
        k3 = f(ti + dt / 2, yi + dt * k2 / 2)
        k4 = f(ti + dt, yi + dt * k3)
        
        y[i + 1] = yi + dt * (k1 + 2 * k2 + 2 * k3 + k4) / 6
    
    return y


# Usage
# First call compiles, subsequent calls are fast
a = np.random.randn(1000000)
b = np.random.randn(1000000)

result = numba_dot_product(a, b)  # Compiled and cached

# Mandelbrot
mandelbrot = parallel_mandelbrot(-2, 1, -1.5, 1.5, 1000, 1000, 100)
```

---

## CuPy (GPU Acceleration)

### GPU Computing
```python
try:
    import cupy as cp
    HAS_CUPY = True
except ImportError:
    HAS_CUPY = False
    import numpy as cp  # Fallback


class GPUComputing:
    """GPU-accelerated computing with CuPy."""
    
    def __init__(self):
        if HAS_CUPY:
            self.device = cp.cuda.Device()
            print(f"Using GPU: {self.device}")
        else:
            print("CuPy not available, using NumPy")
    
    def matrix_operations(self, n: int = 1000) -> cp.ndarray:
        """GPU matrix operations."""
        # Create arrays on GPU
        A = cp.random.randn(n, n, dtype=cp.float32)
        B = cp.random.randn(n, n, dtype=cp.float32)
        
        # Operations on GPU
        C = cp.matmul(A, B)
        D = cp.linalg.inv(C)
        
        # Synchronize (wait for GPU)
        cp.cuda.Stream.null.synchronize()
        
        return D
    
    def transfer_to_gpu(self, arr: np.ndarray) -> cp.ndarray:
        """Transfer NumPy array to GPU."""
        if HAS_CUPY:
            return cp.asarray(arr)
        return arr
    
    def transfer_to_cpu(self, arr: cp.ndarray) -> np.ndarray:
        """Transfer CuPy array to CPU."""
        if HAS_CUPY:
            return cp.asnumpy(arr)
        return arr
    
    def fft_gpu(self, arr: cp.ndarray) -> cp.ndarray:
        """FFT on GPU."""
        return cp.fft.fft2(arr)
    
    def custom_kernel(self):
        """Custom CUDA kernel with CuPy."""
        if not HAS_CUPY:
            return None
        
        kernel = cp.RawKernel(r'''
        extern "C" __global__
        void add_kernel(const float* x, const float* y, float* z, int n) {
            int tid = blockIdx.x * blockDim.x + threadIdx.x;
            if (tid < n) {
                z[tid] = x[tid] + y[tid];
            }
        }
        ''', 'add_kernel')
        
        n = 1000
        x = cp.random.randn(n, dtype=cp.float32)
        y = cp.random.randn(n, dtype=cp.float32)
        z = cp.zeros(n, dtype=cp.float32)
        
        block_size = 256
        grid_size = (n + block_size - 1) // block_size
        
        kernel((grid_size,), (block_size,), (x, y, z, n))
        
        return z


# Usage (if CuPy available)
if HAS_CUPY:
    gpu = GPUComputing()
    
    # Matrix operations on GPU
    result_gpu = gpu.matrix_operations(2000)
    
    # Transfer back to CPU
    result_cpu = gpu.transfer_to_cpu(result_gpu)
```

---

## Signal Processing

### Signal Processing with SciPy
```python
import numpy as np
from scipy import signal
from scipy import fft


class SignalProcessing:
    """Signal processing utilities."""
    
    @staticmethod
    def design_filter(
        filter_type: str,
        cutoff: float | tuple[float, float],
        fs: float,
        order: int = 5,
    ) -> tuple[np.ndarray, np.ndarray]:
        """Design Butterworth filter."""
        nyquist = fs / 2
        
        if isinstance(cutoff, tuple):
            normalized_cutoff = (cutoff[0] / nyquist, cutoff[1] / nyquist)
        else:
            normalized_cutoff = cutoff / nyquist
        
        b, a = signal.butter(order, normalized_cutoff, btype=filter_type)
        
        return b, a
    
    @staticmethod
    def apply_filter(
        data: np.ndarray,
        b: np.ndarray,
        a: np.ndarray,
    ) -> np.ndarray:
        """Apply filter with zero-phase distortion."""
        return signal.filtfilt(b, a, data)
    
    @staticmethod
    def compute_fft(
        data: np.ndarray,
        fs: float,
    ) -> tuple[np.ndarray, np.ndarray]:
        """Compute FFT and frequencies."""
        n = len(data)
        
        # Compute FFT
        fft_vals = fft.fft(data)
        freqs = fft.fftfreq(n, 1 / fs)
        
        # Take positive frequencies only
        positive_mask = freqs >= 0
        freqs = freqs[positive_mask]
        magnitude = np.abs(fft_vals[positive_mask]) * 2 / n
        
        return freqs, magnitude
    
    @staticmethod
    def spectrogram(
        data: np.ndarray,
        fs: float,
        window_size: int = 256,
        overlap: int = 128,
    ) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
        """Compute spectrogram."""
        f, t, Sxx = signal.spectrogram(
            data,
            fs=fs,
            nperseg=window_size,
            noverlap=overlap,
        )
        return f, t, Sxx
    
    @staticmethod
    def find_peaks(
        data: np.ndarray,
        height: float | None = None,
        distance: int | None = None,
    ) -> tuple[np.ndarray, dict]:
        """Find peaks in signal."""
        peaks, properties = signal.find_peaks(
            data,
            height=height,
            distance=distance,
        )
        return peaks, properties
    
    @staticmethod
    def convolve(
        signal1: np.ndarray,
        signal2: np.ndarray,
        mode: str = "same",
    ) -> np.ndarray:
        """Convolve two signals."""
        return signal.convolve(signal1, signal2, mode=mode)


# Usage
sp = SignalProcessing()

# Generate noisy signal
fs = 1000  # Sampling frequency
t = np.linspace(0, 1, fs)
signal_clean = np.sin(2 * np.pi * 50 * t) + 0.5 * np.sin(2 * np.pi * 120 * t)
noise = np.random.randn(len(t)) * 0.5
signal_noisy = signal_clean + noise

# Design low-pass filter
b, a = sp.design_filter("low", cutoff=80, fs=fs, order=4)

# Apply filter
signal_filtered = sp.apply_filter(signal_noisy, b, a)

# FFT analysis
freqs, magnitude = sp.compute_fft(signal_filtered, fs)
```

---

## Statistics

### Statistical Analysis
```python
import numpy as np
from scipy import stats
from typing import NamedTuple


class StatisticalResult(NamedTuple):
    statistic: float
    pvalue: float
    reject_null: bool


class Statistics:
    """Statistical analysis utilities."""
    
    @staticmethod
    def t_test(
        sample1: np.ndarray,
        sample2: np.ndarray | None = None,
        mu: float = 0,
        paired: bool = False,
        alpha: float = 0.05,
    ) -> StatisticalResult:
        """Perform t-test."""
        if sample2 is None:
            # One-sample t-test
            statistic, pvalue = stats.ttest_1samp(sample1, mu)
        elif paired:
            # Paired t-test
            statistic, pvalue = stats.ttest_rel(sample1, sample2)
        else:
            # Independent t-test
            statistic, pvalue = stats.ttest_ind(sample1, sample2)
        
        return StatisticalResult(
            statistic=statistic,
            pvalue=pvalue,
            reject_null=pvalue < alpha,
        )
    
    @staticmethod
    def anova(*groups, alpha: float = 0.05) -> StatisticalResult:
        """One-way ANOVA."""
        statistic, pvalue = stats.f_oneway(*groups)
        
        return StatisticalResult(
            statistic=statistic,
            pvalue=pvalue,
            reject_null=pvalue < alpha,
        )
    
    @staticmethod
    def chi_square_test(
        observed: np.ndarray,
        expected: np.ndarray | None = None,
        alpha: float = 0.05,
    ) -> StatisticalResult:
        """Chi-square test."""
        if expected is None:
            # Chi-square test of independence (for contingency table)
            statistic, pvalue, dof, expected = stats.chi2_contingency(observed)
        else:
            # Goodness of fit
            statistic, pvalue = stats.chisquare(observed, expected)
        
        return StatisticalResult(
            statistic=statistic,
            pvalue=pvalue,
            reject_null=pvalue < alpha,
        )
    
    @staticmethod
    def confidence_interval(
        data: np.ndarray,
        confidence: float = 0.95,
    ) -> tuple[float, float]:
        """Calculate confidence interval for mean."""
        n = len(data)
        mean = np.mean(data)
        se = stats.sem(data)
        
        h = se * stats.t.ppf((1 + confidence) / 2, n - 1)
        
        return mean - h, mean + h
    
    @staticmethod
    def bootstrap(
        data: np.ndarray,
        statistic: callable,
        n_bootstrap: int = 10000,
        confidence: float = 0.95,
    ) -> tuple[float, tuple[float, float]]:
        """Bootstrap estimation."""
        n = len(data)
        bootstrap_stats = np.zeros(n_bootstrap)
        
        for i in range(n_bootstrap):
            sample = np.random.choice(data, size=n, replace=True)
            bootstrap_stats[i] = statistic(sample)
        
        # Percentile method for CI
        alpha = 1 - confidence
        lower = np.percentile(bootstrap_stats, 100 * alpha / 2)
        upper = np.percentile(bootstrap_stats, 100 * (1 - alpha / 2))
        
        return np.mean(bootstrap_stats), (lower, upper)
    
    @staticmethod
    def correlation(
        x: np.ndarray,
        y: np.ndarray,
        method: str = "pearson",
    ) -> tuple[float, float]:
        """Calculate correlation coefficient."""
        if method == "pearson":
            r, p = stats.pearsonr(x, y)
        elif method == "spearman":
            r, p = stats.spearmanr(x, y)
        elif method == "kendall":
            r, p = stats.kendalltau(x, y)
        else:
            raise ValueError(f"Unknown method: {method}")
        
        return r, p


# Usage
stat = Statistics()

# T-test
sample1 = np.random.normal(100, 15, 50)
sample2 = np.random.normal(105, 15, 50)

result = stat.t_test(sample1, sample2)
print(f"t-statistic: {result.statistic:.3f}, p-value: {result.pvalue:.3f}")

# Bootstrap
mean_est, ci = stat.bootstrap(sample1, np.mean)
print(f"Mean: {mean_est:.2f}, 95% CI: ({ci[0]:.2f}, {ci[1]:.2f})")
```

---

## Best Practices Checklist

- [ ] Use vectorization instead of loops
- [ ] Use JAX for GPU acceleration
- [ ] Use Numba for JIT compilation
- [ ] Set random seeds for reproducibility
- [ ] Validate numerical results
- [ ] Use appropriate data types (float32 vs float64)
- [ ] Profile code with cProfile
- [ ] Document algorithms and assumptions
- [ ] Use einsum for complex tensor operations
- [ ] Test with edge cases and boundary conditions

---

**References:**
- [NumPy Documentation](https://numpy.org/doc/)
- [SciPy Documentation](https://docs.scipy.org/doc/scipy/)
- [JAX Documentation](https://jax.readthedocs.io/)
- [Numba Documentation](https://numba.pydata.org/)
- [CuPy Documentation](https://docs.cupy.dev/)
