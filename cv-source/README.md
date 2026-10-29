# CV Source

`Curriculum_Vitae.tex` is generated from the website data in `_pages/*.yml` by:

```bash
ruby scripts/build_cv.rb
```

The PDF is written to `files/Curriculum_Vitae.pdf`, the CV linked from the website. Only the Skills section lives here, in `static/skills.tex`; everything else comes from the website data, so editing a `.yml` file updates both the website and the CV.
