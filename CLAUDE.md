# CLAUDE.md

Personal single-page website of Haoyang Liu, built on the [al-folio](https://github.com/alshedivat/al-folio) v1.2 starter (Jekyll).
Address https://haoyangliu59.github.io, source at https://github.com/haoyangliu59/haoyangliu59.github.io.

Taking the site offline: Pages cannot be disabled on a user-site repo (API 422); making the repo private takes
it down on the free plan, and GitHub then deletes the Pages config. To bring it back, make the repo public and
re-create Pages: `gh api -X POST repos/haoyangliu59/haoyangliu59.github.io/pages -f "source[branch]=gh-pages"
-f "source[path]=/" -f build_type=legacy` (done 2026-11-19 after a month offline).

## Workflow

Edit locally → verify (build or preview) → commit → push to `main`. Standing instruction from the user
(2026-11-19): push each requested change right away without asking, then verify it on the live site.
A push runs `.github/workflows/deploy.yml`, which builds the site and publishes it to the `gh-pages`
branch (≈1–2 min); GitHub Pages serves that branch.

```bash
bin/serve                              # preview with live reload at http://localhost:4000
bundle exec jekyll build               # one-off build to _site/ (inside the conda env, see below)
bundle exec al-folio upgrade overrides audit   # after `bundle update`: flags stale local overrides
```

`bin/serve` activates the conda env `torchenv` (which holds Ruby 3.3, the gems, ImageMagick) and
forces a UTF-8 locale — without it Ruby defaults to US-ASCII and the bibliography fails to parse.
Run everything else the same way: `source /opt/anaconda3/etc/profile.d/conda.sh && conda activate torchenv`
with `LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8`.

## Site structure

One page (`_pages/about.md`, layout `home`) with sections, in this order:

| Section      | Where the content lives                                            |
| ------------ | ------------------------------------------------------------------ |
| about        | `_pages/about.md` (front matter: subtitle, profile photo; body: bio) |
| news         | `_news/*.md`, one file per item, `inline: true`, ordered by `date` |
| education    | `_data/education.yml`                                              |
| publications and preprints | `_bibliography/papers.bib` (jekyll-scholar; see the field list at its top) |
| projects     | `_data/projects.yml`                                               |
| personal     | `_data/personal.yml` (Markdown paragraphs, no bullets: hobbies)      |
| social icons | `_data/socials.yml` (Google Scholar, email, LinkedIn), shown under the profile photo |

- `_layouts/home.liquid` renders the sections; `_includes/header.liquid` is the navbar with anchor links
  to them. A menu label links to `#<label | slugify>` (e.g. fun facts → `#fun-facts`), so the heading ids in
  `home.liquid` must match.
- `_includes/header.liquid` and `_layouts/bib.liquid` shadow al_folio_core files and are tracked in
  `.al-folio-overrides.yml` (`bundle exec al-folio upgrade overrides accept <path>` after intentional edits).
  `bib.liquid` adds `abbr2`/`abbr3` + `_url` (extra badges) and `venue_link`/`venue_link_name` (custom button);
  those fields are in `filtered_bibtex_keywords`. Co-first authors: `{Liu*, Haoyang}` + `note`.
- Site-wide settings (name, url, feature flags, scholar name highlighting) are in `_config.yml`.
  `url` must stay `https://haoyangliu59.github.io` and `baseurl` empty (user site).
- Profile photo: `assets/img/avatar-placeholder.svg` (grey silhouette, 4:5) until the user sends a real photo;
  the user wants a placeholder rather than no photo. Swap `profile.image` in `_pages/about.md`.
- `imagemagick.enabled: false` and CI does not install ImageMagick or Python (keeps builds ~1 min and off
  slow Ubuntu mirrors). When adding a photo, resize it before committing (e.g. ~800px wide) instead.
  CI runs on `ubuntu-24.04` (pinned; `ubuntu-latest` = 26.04 lacks prebuilt Ruby 3.3.5).
- Email: `_data/socials.yml` stores it as `email_user` + `email_domain` (the repo is public);
  `_plugins/socials_email.rb` joins them at build time, and `protect_email: true` (al_email_protect) keeps
  the address and any `mailto:` out of the HTML — clicking the icon copies it. After changes, build and check
  that `grep -r "@wustl.edu" _site` finds nothing.
- `robots.txt` allows all search engines but disallows AI-training crawlers (GPTBot, ClaudeBot, CCBot, ...).
- Logos for list entries (e.g. the education `logo:` field) live in `assets/logos/`, outside `assets/img/`, so
  jekyll-imagemagick does not generate unused responsive copies. `washu-seal.webp` is the official WashU
  seal (from marcomm.washu.edu); WashU allows the seal only with MarComm's prior permission.
- `assets/css/custom.css` (linked from `header.liquid`) holds all site CSS: the navy accent colour
  (`--global-theme-color` #1d3c78 light / #7ea6e0 dark, replacing the theme's purple), the icon size under the photo,
  section heading style, and the navbar collapse breakpoint moved from 576px to 768px (`navbar-expand-md`).
  Typeface is EB Garamond site-wide (user's choice, 2026-11-20), loaded from Google Fonts via
  `third_party_libraries.google_fonts` in `_config.yml`; base size is 19px (Garamond's small x-height) on the
  theme's 930px column. Large-screen scaling was tried and removed at the user's request.
  Rules that must beat the theme's `!important` declarations go inside `@layer components`.

## Conventions

- Theme runtime (layouts, includes, CSS, JS) comes from the `al_folio_core` and `al_*` gems pinned in
  `Gemfile`; `_config.yml` `plugins:` must list the same gems. Prefer config/content changes over new
  local overrides; when an override is unavoidable, add it under the same path and acknowledge it.
- `docs/` is al-folio's reference documentation (CUSTOMIZE.md, FAQ.md); it is excluded from the build.
- Commit messages: short imperative subject, body explains why.
