# CLAUDE.md

Personal single-page website of Haoyang Liu, built on the [al-folio](https://github.com/alshedivat/al-folio) v1.2 starter (Jekyll).
Live at https://haoyangliu59.github.io, source at https://github.com/haoyangliu59/haoyangliu59.github.io.

## Workflow

Edit locally → preview → commit → push to `main`. The user confirms before anything is pushed.
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
| publications | `_bibliography/papers.bib` (jekyll-scholar; `abbr`, `html`, `pdf`, `preview`, `bibtex_show` fields) |
| projects     | `_data/projects.yml`                                               |
| internships  | `_data/internships.yml`                                            |
| fun facts    | `_data/fun_facts.yml` (list of Markdown strings: personal anecdotes) |
| social icons | `_data/socials.yml` (Google Scholar, email, LinkedIn), shown under the profile photo |

- `_layouts/home.liquid` renders the sections; `_includes/header.liquid` is the navbar with anchor links
  to them. A menu label links to `#<label | slugify>` (fun facts → `#fun-facts`), so the heading ids in
  `home.liquid` must match.
- `header.liquid` shadows the al_folio_core gem's include and is tracked in `.al-folio-overrides.yml`
  (`bundle exec al-folio upgrade overrides accept _includes/header.liquid` after intentional edits).
- Site-wide settings (name, url, feature flags, scholar name highlighting) are in `_config.yml`.
  `url` must stay `https://haoyangliu59.github.io` and `baseurl` empty (user site).
- Profile photo: `assets/img/prof_pic.jpg`.
- Logos for list entries (e.g. the education `logo:` field) live in `assets/logos/`, outside `assets/img/`, so
  jekyll-imagemagick does not generate unused responsive copies. `washu-seal.webp` is the official WashU
  seal (from marcomm.washu.edu); WashU allows the seal only with MarComm's prior permission.
- `assets/css/custom.css` (linked from `header.liquid`) holds all site CSS: large-screen scaling, the icon
  size under the photo, and the navbar collapse breakpoint moved from 576px to 768px (`navbar-expand-md`).
  Rules that must beat the theme's `!important` declarations go inside `@layer components`.

## Conventions

- Theme runtime (layouts, includes, CSS, JS) comes from the `al_folio_core` and `al_*` gems pinned in
  `Gemfile`; `_config.yml` `plugins:` must list the same gems. Prefer config/content changes over new
  local overrides; when an override is unavoidable, add it under the same path and acknowledge it.
- `docs/` is al-folio's reference documentation (CUSTOMIZE.md, FAQ.md); it is excluded from the build.
- Commit messages: short imperative subject, body explains why.
