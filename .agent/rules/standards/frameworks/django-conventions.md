---
technology: Django
version: 5.0+
last_updated: 2026-01-16
official_docs: https://docs.djangoproject.com/
---

# Django - Best Practices & Conventions

**Version:** Django 5.0+  
**Updated:** 2026-01-16  
**Source:** Official Django docs + industry best practices

---

## Overview

Django is a high-level Python web framework that encourages rapid development and clean, pragmatic design. It follows the MVT (Model-View-Template) architecture pattern.

---

## Project Structure

```
myproject/
├── manage.py
├── myproject/
│   ├── settings.py
│   ├── urls.py
│   ├── asgi.py
│   └── wsgi.py
├── apps/
│   ├── users/
│   │   ├── models.py
│   │   ├── views.py
│   │   ├── serializers.py  # DRF
│   │   ├── urls.py
│   │   └── tests.py
│   └── products/
└── templates/
```

---

## Models & ORM Best Practices

### Model Definition

```python
from django.db import models
from django.core.validators import MinValueValidator

class Product(models.Model):
    name = models.CharField(max_length=200)
    price = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        validators=[MinValueValidator(0)]
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['name']),
        ]
    
    def __str__(self):
        return self.name
```

### N+1 Query Prevention

```python
# ❌ Bad - N+1 problem
products = Product.objects.all()
for product in products:
    print(product.category.name)  # Query per product!

# ✅ Good - Use select_related for ForeignKey
products = Product.objects.select_related('category').all()

# ✅ Good - Use prefetch_related for ManyToMany
products = Product.objects.prefetch_related('tags').all()
```

### QuerySet Optimization

```python
# ✅ Select only needed fields
Product.objects.only('id', 'name').all()

# ✅ Use exists() instead of count
if Product.objects.filter(active=True).exists():
    # ...

# ✅ Bulk create
Product.objects.bulk_create([
    Product(name='Item 1'),
    Product(name='Item 2'),
])

# ✅ Bulk update
Product.objects.filter(active=False).update(status='archived')
```

---

## Django REST Framework (DRF)

### Serializers

```python
from rest_framework import serializers

class ProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = Product
        fields = ['id', 'name', 'price', 'created_at']
        read_only_fields = ['id', 'created_at']
    
    def validate_price(self, value):
        if value <= 0:
            raise serializers.ValidationError("Price must be positive")
        return value
```

### ViewSets

```python
from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticatedOrReadOnly

class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.select_related('category').all()
    serializer_class = ProductSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]
    
    def get_queryset(self):
        queryset = super().get_queryset()
        # Filter by query params
        category = self.request.query_params.get('category')
        if category:
            queryset = queryset.filter(category__slug=category)
        return queryset
```

---

## Views & URLs

### Class-Based Views

```python
from django.views.generic import ListView, DetailView

class ProductListView(ListView):
    model = Product
    template_name = 'products/list.html'
    context_object_name = 'products'
    paginate_by = 20
    
    def get_queryset(self):
        return Product.objects.filter(active=True).select_related('category')

class ProductDetailView(DetailView):
    model = Product
    template_name = 'products/detail.html'
```

### URL Patterns

```python
from django.urls import path, include
from rest_framework.routers import DefaultRouter

router = DefaultRouter()
router.register(r'products', ProductViewSet)

urlpatterns = [
    path('api/', include(router.urls)),
    path('products/', ProductListView.as_view(), name='product-list'),
]
```

---

## Authentication & Permissions

### Custom User Model (Recommended)

```python
from django.contrib.auth.models import AbstractUser

class User(AbstractUser):
    email = models.EmailField(unique=True)
    phone = models.CharField(max_length=20, blank=True)
    
    USERNAME_FIELD = 'email'  # Use email for login
    REQUIRED_FIELDS = ['username']
```

### DRF Authentication

```python
# settings.py
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
}
```

---

## Database Migrations

### Best Practices

```python
# Create migration
python manage.py makemigrations

# Review migration before applying
python manage.py sqlmigrate users 0001

# Apply migrations
python manage.py migrate

# ✅ Always add indexes for foreign keys
class Migration(migrations.Migration):
    operations = [
        migrations.AddIndex(
            model_name='product',
            index=models.Index(fields=['category'], name='product_category_idx'),
        ),
    ]
```

### Zero-Downtime Migrations

```python
# Step 1: Add nullable field
class Migration(migrations.Migration):
    operations = [
        migrations.AddField('Product', 'new_field', 
            models.CharField(max_length=100, null=True)),
    ]

# Step 2: Populate data

# Step 3: Make NOT NULL (separate migration)
```

---

## Security Best Practices

### CSRF Protection

```html
<!-- Always use {% csrf_token %} in forms -->
<form method="post">
    {% csrf_token %}
    {{ form.as_p }}
    <button type="submit">Submit</button>
</form>
```

### SQL Injection Prevention

```python
# ✅ Good - Use ORM
Product.objects.filter(name=user_input)

# ✅ Good - Use parameterized queries
Product.objects.raw('SELECT * FROM product WHERE name = %s', [user_input])

# ❌ Bad - String interpolation
Product.objects.raw(f'SELECT * FROM product WHERE name = {user_input}')  # VULNERABLE!
```

### XSS Prevention

```html
<!-- Auto-escapes by default -->
{{ user_input }}

<!-- Raw HTML (careful!) -->
{{ trusted_html|safe }}
```

---

## Caching

```python
from django.core.cache import cache
from django.views.decorators.cache import cache_page

# Cache view for 15 minutes
@cache_page(60 * 15)
def product_list(request):
    products = Product.objects.all()
    return render(request, 'products/list.html', {'products': products})

# Manual caching
def get_products():
    products = cache.get('products')
    if products is None:
        products = list(Product.objects.all())
        cache.set('products', products, 3600)  # 1 hour
    return products
```

---

## Testing

```python
from django.test import TestCase
from rest_framework.test import APITestCase

class ProductModelTest(TestCase):
    def setUp(self):
        self.product = Product.objects.create(
            name='Test Product',
            price=19.99
        )
    
    def test_product_creation(self):
        self.assertEqual(self.product.name, 'Test Product')
        self.assertGreater(self.product.price, 0)

class ProductAPITest(APITestCase):
    def test_list_products(self):
        response = self.client.get('/api/products/')
        self.assertEqual(response.status_code, 200)
```

---

## Settings Organization

```python
# settings/
# ├── __init__.py
# ├── base.py      # Common settings
# ├── dev.py       # Development
# ├── prod.py      # Production
# └── test.py      # Testing

# base.py
SECRET_KEY = os.environ.get('SECRET_KEY')
DEBUG = os.environ.get('DEBUG', 'False') == 'True'

# dev.py
from .base import *
DEBUG = True
ALLOWED_HOSTS = ['localhost', '127.0.0.1']

# prod.py
from .base import *
DEBUG = False
ALLOWED_HOSTS = os.environ.get('ALLOWED_HOSTS', '').split(',')
```

---

## Anti-Patterns to Avoid

❌ **Logic in templates** → Move to views/services  
❌ **Fat views** → Use services/managers  
❌ **No indexes** → Index foreign keys and frequent queries  
❌ **N+1 queries** → Use select_related/prefetch_related  
❌ **Raw SQL everywhere** → Use ORM  
❌ **No migrations** → Always create migrations  
❌ **Hardcoded settings** → Use environment variables

---

## Best Practices

✅ **Custom User model** from the start  
✅ **Use ORM** for database queries  
✅ **select_related/prefetch_related** for relationships  
✅ **Django REST Framework** for APIs  
✅ **Environment variables** for config  
✅ **Migrations** for schema changes  
✅ **pytest-django** for testing  
✅ **Celery** for async tasks

---

**References:**
- [Django Official Docs](https://docs.djangoproject.com/)
- [Django REST Framework](https://www.django-rest-framework.org/)
- [Two Scoops of Django](https://www.feldroy.com/books/two-scoops-of-django-3-x)
