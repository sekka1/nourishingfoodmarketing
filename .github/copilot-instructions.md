# GitHub Copilot Instructions for Nourishing Food Marketing

This repository contains the Nourishing Food Marketing website, a static site built with Jekyll and deployed on GitHub Pages.

## Repository Overview

**Framework:** Jekyll 4.x static site generator
**Theme:** Minima (customized)
**Deployment:** GitHub Pages
**Language:** Ruby (Jekyll), HTML, CSS (SCSS), Liquid templating
**Base URL:** `/nourishingfoodmarketing` (GitHub Pages subdirectory)

## Site Structure

```
/
├── _config.yml           # Jekyll configuration
├── Gemfile              # Ruby dependencies
├── _layouts/            # Page templates
│   ├── default.html    # Base wrapper layout
│   ├── home.html       # Home page (fully migrated from WordPress)
│   ├── page.html       # Standard page layout
│   └── post.html       # Blog post layout
├── _includes/           # Reusable HTML components
│   ├── head.html       # <head> section
│   ├── header.html     # Navigation header
│   └── footer.html     # Footer
├── _posts/             # Blog posts (Markdown)
├── _sass/              # SCSS stylesheets
│   ├── minima.scss     # Main theme configuration
│   └── minima/
│       ├── _base.scss  # Base styling
│       └── _layout.scss # Layout styling
├── assets/             # Static assets
│   ├── main.scss       # CSS entry point
│   └── images/         # Image files
│       ├── icons/      # Service/feature icons
│       └── projects/   # Project showcase images
├── index.md            # Home page entry (uses home layout)
├── about.md            # About page
├── services.md         # Services page
├── contact.md          # Contact page
└── .claude/            # AI agent skills and documentation
    └── skills/
        └── migrate-wordpress-page.md  # Migration guide
```

## Key Technologies

- **Jekyll:** Static site generator that converts Markdown and Liquid templates to HTML
- **Minima Theme:** Default Jekyll theme, customized for brand
- **Liquid:** Templating language used in Jekyll layouts
- **SCSS/SASS:** CSS preprocessor for stylesheets
- **GitHub Pages:** Free hosting with automatic Jekyll builds
- **Plugins:**
  - `jekyll-feed` - RSS feed generation
  - `jekyll-seo-tag` - SEO meta tags
  - `jekyll-paginate-v2` - Pagination for blog
  - `jekyll-sitemap` - XML sitemap generation

## Brand Colors

Primary color palette (defined in migrated layouts):
- **Accent Yellow:** `#fab80a` - Primary brand color, buttons, highlights
- **Dark Blue:** `#435159` - Headers, primary text, dark backgrounds
- **Cream:** `#fff3e2` - Light backgrounds, text on dark sections
- **Light Gray:** `#eef0f2` - Alternating section backgrounds
- **Coral Pink:** `#e95262` - Hover states

## Content Management

### Pages
- Pages are written in Markdown (`.md` files) with YAML front matter
- Front matter specifies layout, title, and other metadata
- Use Liquid filters for asset paths: `{{ '/assets/images/logo.png' | relative_url }}`

### Blog Posts
- Located in `_posts/` directory
- Named with format: `YYYY-MM-DD-title.md`
- Use `post` layout by default
- Support pagination (5 posts per page)

### Layouts
- All layouts inherit from `default.html`
- `home.html` contains full WordPress-migrated content with inline CSS
- Width constraint override: `.page-content .wrapper { max-width: 100%; padding: 0; }`

## WordPress to Jekyll Migration

### Migration Skill

The repository includes a comprehensive migration skill at `.claude/skills/migrate-wordpress-page.md` for migrating pages from the original WordPress site (https://www.nourishingfoodmarketing.com/) to Jekyll.

**Key Migration Principles:**

1. **Complete Section Extraction** - Identify ALL sections from original page before migrating
2. **Exact Content Preservation** - Use EXACT text from WordPress, no rewrites
3. **Full-Width Layout** - Override `.wrapper` max-width constraint for proper display
4. **Local Assets** - All images, CSS, JS must be local (no external CDNs)
5. **Section Order** - Maintain exact section order from original

**Migration Process Summary:**

```bash
# 1. Download original HTML
curl -L https://www.nourishingfoodmarketing.com/[page] -o /tmp/original.html

# 2. Find all sections
grep -o '<section id="[^"]*"' /tmp/original.html | sort -u

# 3. Extract each section
for section in about founder services projects testimonials contact; do
  sed -n "/<section id=\"$section\"/,/<\/section>/p" /tmp/original.html > /tmp/section-$section.txt
done

# 4. Create new layout with all sections in correct order
# See .claude/skills/migrate-wordpress-page.md for details
```

### Home Page Migration

The home page (`_layouts/home.html`) is a complete migration from WordPress with:
- 10 sections in exact order from original
- Full-width layout (wrapper override)
- Inline CSS from WordPress OnePress theme
- All local assets (images from `assets/images/`)
- Exact text from original (no modifications)

**Section Order:**
1. Hero - "Take Flight & Scale"
2. About - Introduction with client logos
3. Founder - "Meet Our Founder" (Christie Lee)
4. Approach - "We Get More Done With Less!"
5. Services - "How We Can Help" (4 service cards)
6. CTA - "Download my FREE 12-page guide..."
7. Projects - "Selected Work" (3 project showcases)
8. Testimonials - 3 testimonial cards
9. Contact - "Get in Touch"
10. Blog - Section placeholder

## Common Tasks

### Adding a New Blog Post

```markdown
---
layout: post
title: "Your Post Title"
date: 2026-04-02 10:00:00 -0800
categories: marketing
---

Your content here...
```

### Creating a New Page

```markdown
---
layout: page
title: Your Page Title
---

Your content here...
```

### Using Local Images

```liquid
<img src="{{ '/assets/images/your-image.png' | relative_url }}" alt="Description" />
```

### Linking to Other Pages

```liquid
<a href="{{ '/about' | relative_url }}">About Us</a>
```

## Development

### Local Development

```bash
# Install dependencies
bundle install

# Serve locally (with live reload)
bundle exec jekyll serve

# Build for production
bundle exec jekyll build
```

**Note:** The site is automatically built by GitHub Pages on push, so local builds are only needed for development.

### Testing

Before committing changes:
1. Verify page renders correctly locally
2. Check all images load
3. Verify no external dependencies
4. Test responsive design (mobile breakpoint: 768px)
5. Validate all section content is present

## Migration Workflow for New Pages

When migrating additional pages from WordPress:

1. **Review Migration Skill** - Read `.claude/skills/migrate-wordpress-page.md` completely
2. **Download Original** - Get full HTML from WordPress site
3. **Extract ALL Sections** - Use grep to find every `<section id=` and extract them all
4. **Preserve Exact Text** - Copy content verbatim, no changes
5. **Fix Width** - Add wrapper override for full-width display
6. **Verify Completeness** - Check every section from original is present
7. **Update Skill** - Add any new learnings to migration guide

## Important Notes

- **Never rewrite content** - Use exact text from WordPress original
- **Never skip sections** - All sections must be migrated
- **Never change titles** - Use exact section titles from original
- **Always override wrapper** - Add `.page-content .wrapper { max-width: 100%; padding: 0; }` for full-width
- **Always use relative_url** - For all asset and page links
- **All external assets must be local** - No CDN links, no external images

## Deployment

The site is automatically deployed via GitHub Pages when changes are pushed to the main branch. The deployment URL is: https://www.nourishingfoodmarketing.com/

Configuration:
- Base URL: `/nourishingfoodmarketing`
- Source: Main branch
- Build: Automatic Jekyll build by GitHub Pages

## Troubleshooting

### Width Issues
If sections appear constrained, ensure the wrapper override is present in layout CSS:
```css
.page-content .wrapper {
  max-width: 100%;
  padding: 0;
}
```

### Missing Sections
Always verify section count against original WordPress page:
```bash
grep -o '<section id="[^"]*"' /tmp/original.html | wc -l
```

### Asset Path Issues
Use Jekyll's `relative_url` filter for all paths:
- Images: `{{ '/assets/images/file.png' | relative_url }}`
- Pages: `{{ '/about' | relative_url }}`
- CSS: `{{ '/assets/main.css' | relative_url }}`

## Support Files

- **Migration Guide:** `.claude/skills/migrate-wordpress-page.md` - Complete WordPress to Jekyll migration documentation
- **Backup Layout:** `_layouts/home-old-backup.html` - Original simple home layout before migration
- **Migration Docs:** `MIGRATION.md` - Home page migration documentation

## Contact

For questions about this repository or the migration process, refer to the comprehensive migration guide at `.claude/skills/migrate-wordpress-page.md`.
