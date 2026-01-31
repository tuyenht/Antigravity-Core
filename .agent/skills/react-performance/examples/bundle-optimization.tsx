// Example: Bundle size optimization with direct imports

// ❌ BAD: Barrel file import (loads entire library)
import { Check, X, Menu, Home, Settings } from 'lucide-react'
// Loads 1,583 modules
// Takes ~2.8s in dev, 200-800ms runtime
// Bundle impact: ~1MB

export function IconsBad() {
    return (
        <div>
            <Check />
            <X />
            <Menu />
            <Home />
            <Settings />
        </div>
    )
}

// ✅ GOOD: Direct imports (only what you need)
import Check from 'lucide-react/dist/esm/icons/check'
import X from 'lucide-react/dist/esm/icons/x'
import Menu from 'lucide-react/dist/esm/icons/menu'
import Home from 'lucide-react/dist/esm/icons/home'
import Settings from 'lucide-react/dist/esm/icons/settings'
// Loads only 5 modules
// ~2KB vs ~1MB
// 15-70% faster dev boot
// 28% faster builds

export function IconsGood() {
    return (
        <div>
            <Check />
            <X />
            <Menu />
            <Home />
            <Settings />
        </div>
    )
}

// ✅ BETTER: Next.js 13.5+ with optimizePackageImports
// next.config.js:
/*
module.exports = {
  experimental: {
    optimizePackageImports: ['lucide-react']
  }
}
*/

// Then you can use barrel imports (they're auto-transformed):
/*
import { Check, X, Menu, Home, Settings } from 'lucide-react'
// Automatically converted to direct imports at build time
// Best of both worlds: ergonomic + performant
*/

// Impact: 800KB → 2KB bundle for icons
// Result: 50% smaller initial bundle
