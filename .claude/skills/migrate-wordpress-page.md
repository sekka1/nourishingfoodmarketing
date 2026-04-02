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

**CRITICAL:** Identify ALL sections from the original page. Missing sections is the most common migration error.

```bash
# Find ALL section IDs and their order
grep -o '<section id="[^"]*"' /tmp/original-page.html | sort -u

# Extract each section individually for review
for section in about founder approach services section-cta projects testimonials contact; do
  sed -n "/<section id=\"$section\"/,/<\/section>/p" /tmp/original-page.html > /tmp/section-$section.txt
done
```

**Important:**
- List all sections found in the original page
- Include sections in the EXACT order they appear
- Do NOT rename sections (e.g., "Selected Work" not "Featured Projects")
- Do NOT omit any sections - they all need to be migrated

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

**IMPORTANT: Fix Width Constraint**
The default Jekyll layout wraps content in a `.wrapper` div with max-width constraint. Override this for full-width sections:

```css
/* Override wrapper constraint for full-width sections */
.page-content .wrapper {
  max-width: 100%;
  padding: 0;
}
```

**IMPORTANT: Fix Header Width and Logo**
The default Jekyll header also uses a `.wrapper` div that constrains width. To match the original WordPress site:

1. **Header Full Width:** Add custom CSS to override the header wrapper:
```css
.site-header .header-wrapper {
  max-width: 100%;
  padding-left: 30px;
  padding-right: 30px;
}
```

2. **Replace Text with Logo:** Edit `_includes/header.html` to replace the text site title with logo image:
```html
<!-- Before (text title) -->
<a class="site-title" rel="author" href="{{ "/" | relative_url }}">
  {{ site.title | escape }}
</a>

<!-- After (logo image) -->
<a class="site-title" rel="author" href="{{ "/" | relative_url }}">
  <img src="{{ '/assets/images/Primary-Logo.png' | relative_url }}" alt="{{ site.title | escape }}" class="site-logo" />
</a>
```

3. **Logo Styling:** Add CSS for the logo:
```css
.site-header .site-logo {
  max-height: 50px;
  width: auto;
  display: block;
}
```

**Inline Styles:**
- Copy critical CSS from the original page
- Convert WordPress image URLs to Jekyll asset paths: `{{ '/assets/images/[IMAGE]' | relative_url }}`
- Maintain original color scheme: #fab80a (accent yellow), #435159 (dark blue), #fff3e2 (cream), #eef0f2 (light gray)
- Add `.container { max-width: 1200px; margin: 0 auto; }` for section content

**HTML Content:**
- Copy section structure from original page in EXACT order
- Use the EXACT text from the original - do not rewrite or make up new content
- Keep section titles exactly as they appear in the original
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
6. **Don't** skip any sections - ALL sections must be migrated
7. **Don't** rename sections or change copy - use EXACT text from original
8. **Don't** forget to override the wrapper width constraint for full-width layouts
9. **Do** preserve responsive breakpoints (typically @media max-width: 768px)
10. **Do** maintain hover effects and transitions
11. **Do** keep the visual hierarchy and spacing
12. **Do** verify ALL sections are present before considering migration complete

## Example Migration: Home Page

See the completed home page migration in:
- `_layouts/home.html` - Fully migrated layout with ALL sections
- `_layouts/home-old-backup.html` - Original simple layout (backup)

This migration successfully:
- ✅ Identified and extracted ALL 10 sections from the original page
- ✅ Downloaded all required images (already in assets/)
- ✅ Fixed width constraint issue by overriding `.wrapper` max-width
- ✅ Preserved exact copy from original (no rewrites)
- ✅ Used exact section titles ("Selected Work" not "Featured Projects")
- ✅ Inlined critical CSS from OnePress theme
- ✅ Converted all asset paths to Jekyll format
- ✅ Removed all external dependencies
- ✅ Preserved original design and branding

**Section Order (COMPLETE LIST):**
1. Hero/Header - "Take Flight & Scale"
2. About - "About"
3. Founder - "Meet Our Founder"
4. Approach - "We Get More Done With Less!"
5. Services - "How We Can Help" (4 service cards)
6. CTA - "Download my FREE 12-page guide..."
7. Projects - "Selected Work" (with subtitle "Click on a project to learn more")
8. Testimonials - "Testimonials" (3 testimonial cards)
9. Contact - "Get in Touch"
10. Blog - "Our Thoughts" (section with 2 blog post previews and "Read Our Blog" button)
11. Newsletter - "SUBSCRIBE TO MY NEWSLETTER!" (Flodesk form integration)

### Lessons Learned: Why Sections Were Initially Missed

**Blog Section ("Our Thoughts"):**
- The section exists in the HTML with `id="blog"`
- Initially treated as a placeholder without extracting actual content
- **Lesson:** Always extract the FULL section content, not just the section ID. Use `sed -n "/<section id=\"blog\"/,/<\/section>/p"` to get ALL the HTML
- The section contains 2 blog post previews with images, titles, excerpts, and a "Read Our Blog" button
- All blog post images are external WordPress URLs - these should be kept as-is (linking to live blog)

**Newsletter Section:**
- This section does NOT have a `<section id="">` tag and won't appear in section ID searches
- Located AFTER the `</footer>` tag in the original HTML
- It's a Flodesk form integration with a specific form ID: `5fadd2dd76d8d6c0f4cf191d`
- **Lesson:** After extracting all sections, search for additional content between footer and end of body: `sed -n '/<\/footer>/,/<\/body>/p'`
- Newsletter forms and third-party integrations may be inserted outside the main section structure
- **CRITICAL:** Flodesk forms require the Flodesk universal script to be loaded in the `<head>`. Without this script, the form HTML will be present but won't render. Extract the Flodesk script from original page header:
  ```bash
  grep -o '<script>.*FlodeskObject.*</script>' /tmp/original.html
  ```
  Add this script to `_includes/head.html` before the closing `</head>` tag:
  ```html
  <script>(function(w,d,t,s,n){w.FlodeskObject=n;var fn=function(){(w[n].q=w[n].q||[]).push(arguments);};w[n]=w[n]||fn;var f=d.getElementsByTagName(t)[0];var e=d.createElement(t);var h='?v='+new Date().getTime();e.async=true;e.src=s+h;f.parentNode.insertBefore(e,f);})(window,document,'script','https://assets.flodesk.com/universal.js','fd');</script>
  ```

**Prevention Strategy:**
1. Extract ALL sections by ID using grep
2. Extract ALL content between sections to catch non-section elements
3. Extract everything after footer but before body close
4. Manually review original page to verify visual completeness
5. Count sections visually on original page and compare to extracted count

### Mobile-Friendly Design Requirements

This site must be fully responsive and mobile-friendly. All migrations must include:

**Mobile Breakpoint:**
- Primary breakpoint: `@media (max-width: 768px)`
- Mobile devices should show single-column layouts
- Touch targets should be at least 44x44px

**Layout Adjustments for Mobile:**
```css
@media (max-width: 768px) {
  /* Hero sections */
  .hero-section h1 { font-size: 32px; }
  .hero-section h3 { font-size: 18px; }

  /* Services grid - 2x2 on desktop, 1 column on mobile */
  .services-grid { grid-template-columns: 1fr; }

  /* Projects grid */
  .projects-grid { grid-template-columns: 1fr; }

  /* Founder content - stack vertically */
  .founder-content {
    flex-direction: column;
    align-items: center;
    text-align: center;
  }

  /* CTA sections */
  .section-cta .row {
    flex-direction: column;
    text-align: center;
  }

  /* Blog posts - stack vertically */
  .list-article {
    flex-direction: column;
  }

  .list-article-thumb {
    width: 100%;
  }

  /* Contact form images */
  .section-contact .contact-form img {
    float: none;
    margin: 0 auto;
    display: block;
  }
}
```

**Grid Layouts:**
- Services section: 2x2 grid on desktop (`grid-template-columns: repeat(2, 1fr)`), 1 column on mobile
- Projects section: Auto-fit grid on desktop, 1 column on mobile
- Testimonials: Auto-fit grid on desktop, 1 column on mobile

**Sticky Header:**
- Header should be sticky on scroll for better navigation
- Add to all migrated pages:
```css
.site-header {
  position: sticky;
  top: 0;
  z-index: 1000;
  width: 100%;
  background-color: #fff;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}
```

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
