# Ernest F. Aboagye — academic website

Live at https://aboagyernest.github.io. Built with Jekyll, which GitHub Pages runs automatically.
Layout and design adapted from Qiuqi Wang's site (https://qwangan.github.io).

## Updating content

Edit the files in `_pages/` (on GitHub: open the file, click the pencil, edit, **Commit changes**):

| File | Section |
|---|---|
| `site.yml` | name, title, email, Google Scholar and GitHub links |
| `appointment.yml`, `industry.yml` | Positions |
| `education.yml` | Education & credentials |
| `interests.yml` | Research interests |
| `awards.yml` | Honors & awards |
| `publications.yml` | Publications, working papers, work in progress |
| `teaching.yml` | Courses |
| `activities.yml` | Presentations & conferences |
| `service.yml`, `other_service.yml`, `memberships.yml` | Service |

The photo is `images/photo.jpg`.

## The CV updates itself

`files/Curriculum_Vitae.pdf` (the CV linked on the site) is generated from the same `_pages/*.yml` files by `scripts/build_cv.rb`. On every change to `_pages/`, the **Build CV PDF** GitHub Action rebuilds the PDF and commits it, so the website and CV never disagree. The only CV-only content is `cv-source/static/skills.tex`.

To build locally (needs Ruby and LaTeX): `ruby scripts/build_cv.rb`.

## New papers are added automatically

Every day the **Update publications** GitHub Action looks for new papers and adds them to Working Papers (and so to the CV):

- **arXiv:** papers whose author list includes "Ernest F. Aboagye" or "Ernest Aboagye".
- **SSRN:** papers whose SSRN record carries the ORCID iD 0009-0000-6582-8536 (add the ORCID to your SSRN profile). Name-only SSRN matches are ignored because other researchers share the name.

If a new arXiv or SSRN posting has the same title as a paper already listed, the link is added to that entry instead of a duplicate. Identity settings are in `publication-sources.yml`. To run it immediately, open **Actions > Update publications > Run workflow**.
