# WordPress to Jekyll Static Page Migration Skill

This skill helps migrate WordPress pages from the live site (https://www.nourishingfoodmarketing.com/) to this Jekyll-based static site repository.

## Purpose

Systematically migrate pages from the WordPress site to Jekyll layouts while:
- Preserving all content and structure
- Downloading and localizing all assets (images, CSS)
- Removing external dependencies
- Maintaining the visual design and brand identity

## Migration Process

### 1. Download Original HTML

```bash
curl -L https://www.nourishingfoodmarketing.com/[PAGE_PATH] -o /tmp/original-page.html
```

### 2. Analyze External Dependencies

Extract all external resources that need to be localized:

```bash
# Find CSS files
grep -oP "href=['\"]https?://[^'\"]+\.css[^'\"]*['\"]" /tmp/original-page.html

# Find JavaScript files
grep -oP "src=['\"]https?://[^'\"]+\.js[^'\"]*['\"]" /tmp/original-page.html

# Find images from wp-content
grep -oP "https?://[^'\"]+\.(png|jpg|jpeg|gif|svg|webp)" /tmp/original-page.html | grep "wp-content"

# Find Google Fonts
grep -oP "https?://fonts\.googleapis\.com[^'\"]*" /tmp/original-page.html
```

### 3. Download Required Assets

Only download assets that don't already exist in the repository:

```bash
# Check existing assets
ls -la assets/images/
ls -la assets/images/icons/
ls -la assets/images/projects/

# Download missing images (if needed)
cd assets/images
curl -O [IMAGE_URL]
```

### 4. Extract Page Content Sections

Identify and extract the main content sections from the WordPress HTML:

```bash
# Find section IDs
grep -n "section id=" /tmp/original-page.html

# Extract specific sections
sed -n '/<section id="SECTION_NAME"/,/<\/section>/p' /tmp/original-page.html > /tmp/section-SECTION_NAME.txt
```

### 5. Extract Inline CSS

Extract theme-specific CSS that needs to be preserved:

```bash
sed -n "/style id='onepress-style-inline-css'/,/\/style/p" /tmp/original-page.html > /tmp/inline-css.txt
```

### 6. Create New Jekyll Layout

Create a new layout file in `_layouts/[PAGE_NAME].html` with:

**Front Matter:**
```yaml
---
layout: default
title: [Page Title]
---
```

**Inline Styles:**
- Copy critical CSS from the original page
- Convert WordPress image URLs to Jekyll asset paths: `{{ '/assets/images/[IMAGE]' | relative_url }}`
- Maintain original color scheme: #fab80a (accent yellow), #435159 (dark blue), #fff3e2 (cream), #eef0f2 (light gray)

**HTML Content:**
- Copy section structure from original page
- Remove WordPress-specific classes/IDs not needed for styling
- Simplify HTML while preserving visual structure
- Convert all external asset references to local paths

### 7. Update Asset References

Replace all external URLs with local Jekyll paths:

**Before:**
```html
<img src="https://i0.wp.com/www.nourishingfoodmarketing.com/wp-content/uploads/2020/06/Circle-Variation-grey.png" alt="Logo">
```

**After:**
```html
<img src="{{ '/assets/images/Circle-Variation-grey.png' | relative_url }}" alt="Logo">
```

### 8. Test Migration

```bash
# Build the site
bundle exec jekyll build

# Serve locally
bundle exec jekyll serve
```

### 9. Visual Comparison Checklist

- [ ] Hero section displays correctly with background image
- [ ] All images load and display at correct sizes
- [ ] Colors match original site (accent yellow #fab80a, dark blue #435159)
- [ ] Typography is readable and matches original
- [ ] Sections have correct background colors
- [ ] Buttons and links have hover effects
- [ ] Responsive design works on mobile (< 768px)
- [ ] No external dependencies (all assets local)
- [ ] No broken images or missing CSS

## Key Design Elements to Preserve

### Color Palette
- **Primary Accent:** #fab80a (golden yellow)
- **Primary Dark:** #435159 (dark blue-gray)
- **Background Cream:** #fff3e2
- **Background Gray:** #eef0f2
- **Hover Accent:** #e95262 (coral pink)

### Typography
- **Headings:** Libre Baskerville (serif)
- **Body:** Roboto (sans-serif)
- **Base font size:** 18-22px for body text

### Section Patterns
- **Hero sections:** Dark overlay on background image, centered text
- **Alternating backgrounds:** Light gray (#eef0f2) and cream (#fff3e2)
- **Cards:** White or light gray background with subtle shadow, hover lift effect
- **CTA sections:** Dark blue background (#435159) with cream text

## Repository Asset Structure

```
assets/
├── images/
│   ├── [main-images].png/jpg
│   ├── icons/
│   │   ├── DNA-icon.png
│   │   ├── Product-Positioning.png
│   │   ├── Consumer-Research.png
│   │   └── marketing-strategy.png
│   └── projects/
│       ├── Olly-Project.png
│       ├── PetitPot-Project.png
│       └── TinyHero-Project.png
└── main.scss (CSS entry point)
```

## Common Pitfalls to Avoid

1. **Don't** include WordPress-specific JavaScript (lazy loading, etc.)
2. **Don't** use absolute URLs for assets
3. **Don't** forget to convert WordPress `wp-content` URLs to local paths
4. **Don't** include analytics scripts or third-party tracking
5. **Don't** copy WordPress plugin CSS/JS that isn't needed
6. **Do** preserve responsive breakpoints (typically @media max-width: 768px)
7. **Do** maintain hover effects and transitions
8. **Do** keep the visual hierarchy and spacing

## Example Migration: Home Page

See the completed home page migration in:
- `_layouts/home.html` - New migrated layout
- `_layouts/home-old-backup.html` - Original simple layout (backup)

This migration successfully:
- ✅ Downloaded all required images (already in assets/)
- ✅ Extracted content from 5 main sections
- ✅ Inlined critical CSS from OnePress theme
- ✅ Converted all asset paths to Jekyll format
- ✅ Removed all external dependencies
- ✅ Preserved original design and branding

## Usage

To migrate a new page:

1. Identify the page URL on the WordPress site
2. Follow steps 1-6 above to extract and analyze
3. Create new layout file in `_layouts/`
4. Create/update corresponding Markdown file (e.g., `about.md`)
5. Update front matter to use new layout
6. Test visually against original
7. Commit and push to GitHub Pages

## Notes

- GitHub Pages automatically builds Jekyll sites on push
- No need to commit `_site/` directory (it's in .gitignore)
- Use `{{ relative_url }}` filter for all internal links and assets
- The site uses the Minima theme as a base but heavily customizes it
