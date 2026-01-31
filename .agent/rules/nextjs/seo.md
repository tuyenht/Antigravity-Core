# Next.js SEO & Metadata Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31  
> **Next.js:** 14.x / 15.x  
> **Priority:** P0 - Load for all SEO tasks

---

You are an expert in Next.js SEO and metadata optimization.

## Core SEO Principles

- Use Metadata API for SEO
- Implement dynamic metadata
- Use proper Open Graph tags
- Create XML sitemaps
- Implement structured data

---

## 1) Metadata API

### Static Metadata
```typescript
// ==========================================
// app/layout.tsx - Root Metadata
// ==========================================

import type { Metadata, Viewport } from 'next';

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  maximumScale: 5,
  themeColor: [
    { media: '(prefers-color-scheme: light)', color: '#ffffff' },
    { media: '(prefers-color-scheme: dark)', color: '#0a0a0a' },
  ],
};

export const metadata: Metadata = {
  // Base metadata
  metadataBase: new URL(process.env.NEXT_PUBLIC_APP_URL || 'https://myapp.com'),
  
  // Title configuration
  title: {
    default: 'MyApp - Build Amazing Products',
    template: '%s | MyApp',
  },
  
  // Description
  description: 'MyApp is the platform for developers to create, deploy, and scale applications with ease.',
  
  // Keywords
  keywords: ['nextjs', 'react', 'web development', 'saas', 'platform'],
  
  // Authors
  authors: [{ name: 'MyApp Team', url: 'https://myapp.com' }],
  creator: 'MyApp',
  publisher: 'MyApp Inc.',
  
  // Robots
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
  
  // Icons
  icons: {
    icon: [
      { url: '/favicon.ico', sizes: 'any' },
      { url: '/icon.svg', type: 'image/svg+xml' },
    ],
    apple: [
      { url: '/apple-touch-icon.png', sizes: '180x180' },
    ],
    other: [
      { rel: 'mask-icon', url: '/safari-pinned-tab.svg', color: '#5bbad5' },
    ],
  },
  
  // Manifest
  manifest: '/manifest.webmanifest',
  
  // Open Graph
  openGraph: {
    type: 'website',
    locale: 'en_US',
    url: 'https://myapp.com',
    siteName: 'MyApp',
    title: 'MyApp - Build Amazing Products',
    description: 'The platform for developers to create, deploy, and scale applications.',
    images: [
      {
        url: '/og-image.png',
        width: 1200,
        height: 630,
        alt: 'MyApp - Build Amazing Products',
      },
    ],
  },
  
  // Twitter
  twitter: {
    card: 'summary_large_image',
    site: '@myapp',
    creator: '@myapp',
    title: 'MyApp - Build Amazing Products',
    description: 'The platform for developers to create and scale applications.',
    images: ['/twitter-image.png'],
  },
  
  // Verification
  verification: {
    google: 'google-site-verification-code',
    yandex: 'yandex-verification-code',
    other: {
      'facebook-domain-verification': 'facebook-verification-code',
    },
  },
  
  // App links
  appLinks: {
    ios: {
      app_store_id: '123456789',
      url: 'myapp://home',
    },
    android: {
      package: 'com.myapp.android',
      url: 'myapp://home',
    },
  },
  
  // Category
  category: 'technology',
  
  // Alternates for i18n
  alternates: {
    canonical: 'https://myapp.com',
    languages: {
      'en-US': 'https://myapp.com/en',
      'es-ES': 'https://myapp.com/es',
      'fr-FR': 'https://myapp.com/fr',
    },
  },
};
```

### Page-Level Metadata
```typescript
// ==========================================
// app/about/page.tsx
// ==========================================

import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'About Us',  // Becomes "About Us | MyApp"
  description: 'Learn about MyApp, our mission, and the team behind the platform.',
  
  openGraph: {
    title: 'About MyApp',
    description: 'Learn about our mission and team.',
    images: ['/og-about.png'],
  },
};

export default function AboutPage() {
  return <main>...</main>;
}
```

---

## 2) Dynamic Metadata

### generateMetadata Function
```typescript
// ==========================================
// app/posts/[slug]/page.tsx
// ==========================================

import type { Metadata, ResolvingMetadata } from 'next';
import { notFound } from 'next/navigation';

interface Props {
  params: { slug: string };
  searchParams: { [key: string]: string | string[] | undefined };
}

// Generate metadata dynamically
export async function generateMetadata(
  { params, searchParams }: Props,
  parent: ResolvingMetadata
): Promise<Metadata> {
  const post = await getPost(params.slug);
  
  if (!post) {
    return {
      title: 'Post Not Found',
    };
  }
  
  // Optionally access parent metadata
  const previousImages = (await parent).openGraph?.images || [];
  
  return {
    title: post.title,
    description: post.excerpt || `Read ${post.title} on MyApp Blog`,
    
    authors: [{ name: post.author.name }],
    
    openGraph: {
      type: 'article',
      title: post.title,
      description: post.excerpt,
      url: `https://myapp.com/posts/${post.slug}`,
      siteName: 'MyApp Blog',
      publishedTime: post.publishedAt,
      modifiedTime: post.updatedAt,
      authors: [post.author.name],
      section: post.category.name,
      tags: post.tags.map(t => t.name),
      images: [
        {
          url: post.featuredImage || '/og-blog-default.png',
          width: 1200,
          height: 630,
          alt: post.title,
        },
        ...previousImages,
      ],
    },
    
    twitter: {
      card: 'summary_large_image',
      title: post.title,
      description: post.excerpt,
      images: [post.featuredImage || '/twitter-blog-default.png'],
      creator: post.author.twitter || '@myapp',
    },
    
    alternates: {
      canonical: `https://myapp.com/posts/${post.slug}`,
    },
  };
}

// Page component
export default async function PostPage({ params }: Props) {
  const post = await getPost(params.slug);
  
  if (!post) {
    notFound();
  }
  
  return (
    <article>
      <h1>{post.title}</h1>
      {/* content */}
    </article>
  );
}


// ==========================================
// app/products/[id]/page.tsx - E-commerce
// ==========================================

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const product = await getProduct(params.id);
  
  if (!product) {
    return { title: 'Product Not Found' };
  }
  
  return {
    title: `${product.name} - ${product.category}`,
    description: product.description.slice(0, 160),
    
    openGraph: {
      type: 'website',  // Use product schema via JSON-LD instead
      title: product.name,
      description: product.description,
      images: product.images.map(img => ({
        url: img.url,
        width: 800,
        height: 800,
        alt: img.alt || product.name,
      })),
    },
    
    other: {
      'product:price:amount': product.price.toString(),
      'product:price:currency': 'USD',
      'product:availability': product.inStock ? 'in stock' : 'out of stock',
    },
  };
}
```

---

## 3) Structured Data (JSON-LD)

### JSON-LD Component
```typescript
// ==========================================
// components/JsonLd.tsx
// ==========================================

interface JsonLdProps {
  data: Record<string, any>;
}

export function JsonLd({ data }: JsonLdProps) {
  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(data) }}
    />
  );
}


// ==========================================
// lib/schema.ts - Schema Generators
// ==========================================

export function generateOrganizationSchema() {
  return {
    '@context': 'https://schema.org',
    '@type': 'Organization',
    name: 'MyApp',
    url: 'https://myapp.com',
    logo: 'https://myapp.com/logo.png',
    sameAs: [
      'https://twitter.com/myapp',
      'https://linkedin.com/company/myapp',
      'https://github.com/myapp',
    ],
    contactPoint: {
      '@type': 'ContactPoint',
      telephone: '+1-555-123-4567',
      contactType: 'customer service',
      email: 'support@myapp.com',
      availableLanguage: ['English', 'Spanish'],
    },
  };
}

export function generateWebsiteSchema() {
  return {
    '@context': 'https://schema.org',
    '@type': 'WebSite',
    name: 'MyApp',
    url: 'https://myapp.com',
    potentialAction: {
      '@type': 'SearchAction',
      target: {
        '@type': 'EntryPoint',
        urlTemplate: 'https://myapp.com/search?q={search_term_string}',
      },
      'query-input': 'required name=search_term_string',
    },
  };
}

export function generateArticleSchema(post: Post) {
  return {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: post.title,
    description: post.excerpt,
    image: post.featuredImage,
    datePublished: post.publishedAt,
    dateModified: post.updatedAt,
    author: {
      '@type': 'Person',
      name: post.author.name,
      url: `https://myapp.com/authors/${post.author.slug}`,
    },
    publisher: {
      '@type': 'Organization',
      name: 'MyApp',
      logo: {
        '@type': 'ImageObject',
        url: 'https://myapp.com/logo.png',
      },
    },
    mainEntityOfPage: {
      '@type': 'WebPage',
      '@id': `https://myapp.com/posts/${post.slug}`,
    },
  };
}

export function generateProductSchema(product: Product) {
  return {
    '@context': 'https://schema.org',
    '@type': 'Product',
    name: product.name,
    description: product.description,
    image: product.images.map(img => img.url),
    sku: product.sku,
    brand: {
      '@type': 'Brand',
      name: product.brand,
    },
    offers: {
      '@type': 'Offer',
      url: `https://myapp.com/products/${product.id}`,
      priceCurrency: 'USD',
      price: product.price,
      availability: product.inStock
        ? 'https://schema.org/InStock'
        : 'https://schema.org/OutOfStock',
      seller: {
        '@type': 'Organization',
        name: 'MyApp Store',
      },
    },
    aggregateRating: product.reviewCount > 0 ? {
      '@type': 'AggregateRating',
      ratingValue: product.averageRating,
      reviewCount: product.reviewCount,
    } : undefined,
  };
}

export function generateBreadcrumbSchema(items: { name: string; url: string }[]) {
  return {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: items.map((item, index) => ({
      '@type': 'ListItem',
      position: index + 1,
      name: item.name,
      item: item.url,
    })),
  };
}

export function generateFAQSchema(faqs: { question: string; answer: string }[]) {
  return {
    '@context': 'https://schema.org',
    '@type': 'FAQPage',
    mainEntity: faqs.map(faq => ({
      '@type': 'Question',
      name: faq.question,
      acceptedAnswer: {
        '@type': 'Answer',
        text: faq.answer,
      },
    })),
  };
}


// ==========================================
// USAGE IN PAGES
// ==========================================

// app/layout.tsx
import { JsonLd } from '@/components/JsonLd';
import { generateOrganizationSchema, generateWebsiteSchema } from '@/lib/schema';

export default function RootLayout({ children }) {
  return (
    <html>
      <head>
        <JsonLd data={generateOrganizationSchema()} />
        <JsonLd data={generateWebsiteSchema()} />
      </head>
      <body>{children}</body>
    </html>
  );
}

// app/posts/[slug]/page.tsx
import { JsonLd } from '@/components/JsonLd';
import { generateArticleSchema, generateBreadcrumbSchema } from '@/lib/schema';

export default async function PostPage({ params }) {
  const post = await getPost(params.slug);
  
  const breadcrumbs = [
    { name: 'Home', url: 'https://myapp.com' },
    { name: 'Blog', url: 'https://myapp.com/blog' },
    { name: post.title, url: `https://myapp.com/posts/${post.slug}` },
  ];
  
  return (
    <>
      <JsonLd data={generateArticleSchema(post)} />
      <JsonLd data={generateBreadcrumbSchema(breadcrumbs)} />
      
      <nav aria-label="Breadcrumb">
        <ol>
          {breadcrumbs.map((item, i) => (
            <li key={i}>
              <a href={item.url}>{item.name}</a>
            </li>
          ))}
        </ol>
      </nav>
      
      <article>
        <h1>{post.title}</h1>
        {/* content */}
      </article>
    </>
  );
}
```

---

## 4) Sitemap Generation

### Dynamic Sitemap
```typescript
// ==========================================
// app/sitemap.ts
// ==========================================

import { MetadataRoute } from 'next';
import { prisma } from '@/lib/prisma';

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const baseUrl = process.env.NEXT_PUBLIC_APP_URL || 'https://myapp.com';
  
  // Static pages
  const staticPages: MetadataRoute.Sitemap = [
    {
      url: baseUrl,
      lastModified: new Date(),
      changeFrequency: 'daily',
      priority: 1,
    },
    {
      url: `${baseUrl}/about`,
      lastModified: new Date(),
      changeFrequency: 'monthly',
      priority: 0.8,
    },
    {
      url: `${baseUrl}/pricing`,
      lastModified: new Date(),
      changeFrequency: 'weekly',
      priority: 0.9,
    },
    {
      url: `${baseUrl}/blog`,
      lastModified: new Date(),
      changeFrequency: 'daily',
      priority: 0.9,
    },
    {
      url: `${baseUrl}/contact`,
      lastModified: new Date(),
      changeFrequency: 'monthly',
      priority: 0.5,
    },
  ];
  
  // Dynamic posts
  const posts = await prisma.post.findMany({
    where: { status: 'PUBLISHED' },
    select: { slug: true, updatedAt: true },
    orderBy: { publishedAt: 'desc' },
  });
  
  const postPages: MetadataRoute.Sitemap = posts.map((post) => ({
    url: `${baseUrl}/posts/${post.slug}`,
    lastModified: post.updatedAt,
    changeFrequency: 'weekly',
    priority: 0.7,
  }));
  
  // Dynamic products
  const products = await prisma.product.findMany({
    where: { isActive: true },
    select: { id: true, updatedAt: true },
  });
  
  const productPages: MetadataRoute.Sitemap = products.map((product) => ({
    url: `${baseUrl}/products/${product.id}`,
    lastModified: product.updatedAt,
    changeFrequency: 'daily',
    priority: 0.8,
  }));
  
  // Categories
  const categories = await prisma.category.findMany({
    select: { slug: true, updatedAt: true },
  });
  
  const categoryPages: MetadataRoute.Sitemap = categories.map((category) => ({
    url: `${baseUrl}/categories/${category.slug}`,
    lastModified: category.updatedAt,
    changeFrequency: 'weekly',
    priority: 0.6,
  }));
  
  return [...staticPages, ...postPages, ...productPages, ...categoryPages];
}


// ==========================================
// LARGE SITEMAP (Multiple Sitemaps)
// ==========================================

// app/sitemap.ts - Index sitemap
import { MetadataRoute } from 'next';

export default function sitemap(): MetadataRoute.Sitemap {
  return [
    {
      url: 'https://myapp.com/sitemap-static.xml',
      lastModified: new Date(),
    },
    {
      url: 'https://myapp.com/sitemap-posts.xml',
      lastModified: new Date(),
    },
    {
      url: 'https://myapp.com/sitemap-products.xml',
      lastModified: new Date(),
    },
  ];
}

// app/sitemap-posts/route.ts - Posts sitemap
import { NextResponse } from 'next/server';

export async function GET() {
  const posts = await prisma.post.findMany({
    where: { status: 'PUBLISHED' },
    select: { slug: true, updatedAt: true },
  });
  
  const xml = `<?xml version="1.0" encoding="UTF-8"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
      ${posts.map(post => `
        <url>
          <loc>https://myapp.com/posts/${post.slug}</loc>
          <lastmod>${post.updatedAt.toISOString()}</lastmod>
          <changefreq>weekly</changefreq>
          <priority>0.7</priority>
        </url>
      `).join('')}
    </urlset>
  `;
  
  return new NextResponse(xml, {
    headers: {
      'Content-Type': 'application/xml',
      'Cache-Control': 'public, max-age=3600, s-maxage=3600',
    },
  });
}
```

---

## 5) Robots.txt

### Robots Configuration
```typescript
// ==========================================
// app/robots.ts
// ==========================================

import { MetadataRoute } from 'next';

export default function robots(): MetadataRoute.Robots {
  const baseUrl = process.env.NEXT_PUBLIC_APP_URL || 'https://myapp.com';
  
  // Different rules for production vs preview
  if (process.env.VERCEL_ENV === 'preview') {
    return {
      rules: {
        userAgent: '*',
        disallow: '/',
      },
    };
  }
  
  return {
    rules: [
      {
        userAgent: '*',
        allow: '/',
        disallow: [
          '/api/',
          '/admin/',
          '/dashboard/',
          '/private/',
          '/_next/',
          '/auth/',
        ],
      },
      {
        userAgent: 'Googlebot',
        allow: '/',
        disallow: ['/api/', '/admin/'],
      },
    ],
    sitemap: `${baseUrl}/sitemap.xml`,
    host: baseUrl,
  };
}
```

---

## 6) Open Graph Images

### Dynamic OG Images
```typescript
// ==========================================
// app/api/og/route.tsx
// ==========================================

import { ImageResponse } from 'next/og';
import { NextRequest } from 'next/server';

export const runtime = 'edge';

export async function GET(request: NextRequest) {
  const { searchParams } = request.nextUrl;
  const title = searchParams.get('title') || 'MyApp';
  const description = searchParams.get('description') || '';
  const type = searchParams.get('type') || 'default';

  // Load font
  const interBold = await fetch(
    new URL('../../assets/fonts/Inter-Bold.ttf', import.meta.url)
  ).then((res) => res.arrayBuffer());

  return new ImageResponse(
    (
      <div
        style={{
          height: '100%',
          width: '100%',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'flex-start',
          justifyContent: 'flex-end',
          backgroundColor: '#0a0a0a',
          padding: '60px',
        }}
      >
        {/* Logo */}
        <div
          style={{
            position: 'absolute',
            top: 60,
            left: 60,
            display: 'flex',
            alignItems: 'center',
            gap: '12px',
          }}
        >
          <div
            style={{
              width: 48,
              height: 48,
              backgroundColor: '#3b82f6',
              borderRadius: 12,
            }}
          />
          <span style={{ color: '#fff', fontSize: 32, fontWeight: 700 }}>
            MyApp
          </span>
        </div>

        {/* Title */}
        <div
          style={{
            display: 'flex',
            flexDirection: 'column',
            gap: '16px',
          }}
        >
          <h1
            style={{
              fontSize: 64,
              fontWeight: 700,
              color: '#fff',
              lineHeight: 1.2,
              maxWidth: '900px',
            }}
          >
            {title}
          </h1>
          
          {description && (
            <p
              style={{
                fontSize: 28,
                color: '#a1a1aa',
                maxWidth: '800px',
              }}
            >
              {description}
            </p>
          )}
        </div>

        {/* Type badge */}
        {type !== 'default' && (
          <div
            style={{
              position: 'absolute',
              top: 60,
              right: 60,
              backgroundColor: '#3b82f6',
              color: '#fff',
              padding: '8px 16px',
              borderRadius: 8,
              fontSize: 20,
              textTransform: 'uppercase',
            }}
          >
            {type}
          </div>
        )}
      </div>
    ),
    {
      width: 1200,
      height: 630,
      fonts: [
        {
          name: 'Inter',
          data: interBold,
          style: 'normal',
          weight: 700,
        },
      ],
    }
  );
}


// ==========================================
// USAGE IN METADATA
// ==========================================

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const post = await getPost(params.slug);
  
  const ogUrl = new URL('/api/og', process.env.NEXT_PUBLIC_APP_URL);
  ogUrl.searchParams.set('title', post.title);
  ogUrl.searchParams.set('description', post.excerpt);
  ogUrl.searchParams.set('type', 'blog');
  
  return {
    openGraph: {
      images: [
        {
          url: ogUrl.toString(),
          width: 1200,
          height: 630,
          alt: post.title,
        },
      ],
    },
  };
}
```

---

## 7) International SEO

### Localized Metadata
```typescript
// ==========================================
// app/[locale]/layout.tsx
// ==========================================

import { Metadata } from 'next';
import { locales, Locale } from '@/i18n/config';

export async function generateMetadata({
  params: { locale },
}: {
  params: { locale: Locale };
}): Promise<Metadata> {
  const messages = await import(`@/messages/${locale}.json`);
  const t = messages.default.metadata;
  
  const baseUrl = process.env.NEXT_PUBLIC_APP_URL;
  
  return {
    title: {
      default: t.title,
      template: `%s | ${t.siteName}`,
    },
    description: t.description,
    
    alternates: {
      canonical: `${baseUrl}/${locale}`,
      languages: Object.fromEntries(
        locales.map(loc => [loc, `${baseUrl}/${loc}`])
      ),
    },
    
    openGraph: {
      locale: locale,
      alternateLocale: locales.filter(l => l !== locale),
    },
  };
}


// ==========================================
// i18n SITEMAP
// ==========================================

// app/sitemap.ts
import { MetadataRoute } from 'next';
import { locales } from '@/i18n/config';

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const baseUrl = process.env.NEXT_PUBLIC_APP_URL;
  
  const pages = ['', '/about', '/pricing', '/blog'];
  
  const entries: MetadataRoute.Sitemap = [];
  
  for (const page of pages) {
    for (const locale of locales) {
      entries.push({
        url: `${baseUrl}/${locale}${page}`,
        lastModified: new Date(),
        changeFrequency: 'weekly',
        priority: page === '' ? 1 : 0.8,
        alternates: {
          languages: Object.fromEntries(
            locales.map(loc => [loc, `${baseUrl}/${loc}${page}`])
          ),
        },
      });
    }
  }
  
  return entries;
}
```

---

## 8) Performance for SEO

### Core Web Vitals Optimization
```typescript
// ==========================================
// next.config.js - Image Optimization
// ==========================================

/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    formats: ['image/avif', 'image/webp'],
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048],
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384],
    remotePatterns: [
      {
        protocol: 'https',
        hostname: '**.cloudinary.com',
      },
    ],
  },
  
  // Optimize fonts
  experimental: {
    optimizeCss: true,
  },
};


// ==========================================
// SEO-OPTIMIZED IMAGE COMPONENT
// ==========================================

import Image from 'next/image';

interface SEOImageProps {
  src: string;
  alt: string;
  width: number;
  height: number;
  priority?: boolean;
  className?: string;
}

export function SEOImage({
  src,
  alt,
  width,
  height,
  priority = false,
  className,
}: SEOImageProps) {
  // Ensure alt text is descriptive
  if (!alt || alt.length < 5) {
    console.warn(`SEOImage: Alt text should be descriptive. Got: "${alt}"`);
  }
  
  return (
    <Image
      src={src}
      alt={alt}
      width={width}
      height={height}
      priority={priority}
      loading={priority ? 'eager' : 'lazy'}
      className={className}
      sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
    />
  );
}
```

---

## 9) SEO Utilities

### SEO Helper Functions
```typescript
// ==========================================
// lib/seo.ts
// ==========================================

import { Metadata } from 'next';

interface SEOConfig {
  title: string;
  description: string;
  path: string;
  image?: string;
  type?: 'website' | 'article';
  publishedTime?: string;
  modifiedTime?: string;
  authors?: string[];
  noIndex?: boolean;
}

export function generateSEO({
  title,
  description,
  path,
  image,
  type = 'website',
  publishedTime,
  modifiedTime,
  authors,
  noIndex = false,
}: SEOConfig): Metadata {
  const baseUrl = process.env.NEXT_PUBLIC_APP_URL || 'https://myapp.com';
  const url = `${baseUrl}${path}`;
  const ogImage = image || `${baseUrl}/og-default.png`;
  
  return {
    title,
    description: description.slice(0, 160),
    
    robots: noIndex ? {
      index: false,
      follow: false,
    } : {
      index: true,
      follow: true,
    },
    
    alternates: {
      canonical: url,
    },
    
    openGraph: {
      type,
      title,
      description,
      url,
      images: [
        {
          url: ogImage,
          width: 1200,
          height: 630,
          alt: title,
        },
      ],
      ...(type === 'article' && {
        publishedTime,
        modifiedTime,
        authors,
      }),
    },
    
    twitter: {
      card: 'summary_large_image',
      title,
      description,
      images: [ogImage],
    },
  };
}

// Usage
export const metadata = generateSEO({
  title: 'How to Build a Next.js App',
  description: 'Learn how to build a production-ready Next.js application.',
  path: '/posts/how-to-build-nextjs-app',
  type: 'article',
  publishedTime: '2024-01-15',
  authors: ['John Doe'],
});
```

---

## Best Practices Checklist

### Metadata
- [ ] Title under 60 characters
- [ ] Description under 160 characters
- [ ] Unique per page
- [ ] Keywords included naturally

### Structured Data
- [ ] Organization schema
- [ ] Article/Product schemas
- [ ] Breadcrumb schema
- [ ] FAQ schema (if applicable)

### Technical
- [ ] XML sitemap generated
- [ ] robots.txt configured
- [ ] Canonical URLs set
- [ ] hreflang for i18n

### Performance
- [ ] Core Web Vitals passing
- [ ] Images optimized
- [ ] Fonts optimized
- [ ] Lazy loading implemented

---

**References:**
- [Next.js Metadata API](https://nextjs.org/docs/app/building-your-application/optimizing/metadata)
- [Schema.org](https://schema.org/)
- [Google Search Central](https://developers.google.com/search)
- [Open Graph Protocol](https://ogp.me/)
