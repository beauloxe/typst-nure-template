/// напівжирний текст
#let bold(content) = text(weight: "bold")[#content]

/// ненумерований заголовок першого рівня
#let nheading(title) = heading(depth: 1, numbering: none, title)

/// заповнює горизонтальний простір невидимим текстом (для підкреслень)
#let hfill(width) = box(width: width, repeat(" "))  // HAIR SPACE (U+200A)

/// масив рядків -> рядки, заповнені до кінця, для підкреслених полів завдання
#let filled-lines(content) = if type(content) == array {
  content.map(line => [#line #hfill(1fr)]).join(linebreak())
} else {
  content
}

/// підкреслене поле, вміст за замовчуванням по центру
#let uline(align: center, content) = underline[
  #if align != left { hfill(1fr) }
  #content
  #if align != right { hfill(1fr) }
]

// HACK: Typst cannot underline "empty space". The `underline` element follows
// the text extents, and a box/cell bottom stroke only draws under the last
// line, so a field whose value wraps gets a rule on at most one line. This
// measures the value's height, derives the number of lines from it, and
// places a rule under each line box, so every wrapped line gets a full-width
// rule no matter where its words end.
//
// Note the geometry: rules sit at `line-height + k * line-distance`, NOT at
// `k * (height / lines)` -- Typst puts the leading between lines only, so the
// first line box is shorter than the step between the following ones, and a
// uniform split of the measured height puts the first rule inside the
// second line's ascenders.
//
// Constraints:
// - the value must have a uniform line height (a single font and size),
//   otherwise the rules drift away from the text lines;
// - it must be laid out inside a proper region (a grid cell or similar):
//   `layout`'s bounds are unreliable in a plain inline run and the line count
//   comes out wrong.
// If a native per-line rule ever lands in Typst, replace this wholesale.
#let ruled-field(value, stroke: 0.5pt, leading-frac: 0.45, offset: 0.1em) = layout(bounds => context {
  let fs = text.size
  let leading = leading-frac * fs
  let lh = measure(text(size: fs)[Ay]).height // one line box
  let dist = lh + leading // step between consecutive line bottoms
  let h = measure(block(width: bounds.width)[
    #set par(justify: false, leading: leading)
    #value
  ]).height
  let n = int(calc.max(1, calc.round((h - lh) / dist) + 1)) // number of lines
  // `offset` drops the rules a little below the line boxes so they don't
  // clip through descenders (у, р, щ, ...); the block grows to match
  block(width: 100%, height: h + offset)[
    #for k in range(n) {
      place(top + left, dy: lh + k * dist + offset, line(length: 100%, stroke: stroke))
    }
    #set par(justify: false, leading: leading)
    #value
  ]
})

// HACK: the `path` type (Typst 0.15) is opaque -- no methods, and `str()`
// rejects it -- so the only way to get its text is `repr`, which prints
// `path("/dir/file.png")` (project-rooted, normalized, `"` escaped). The
// format is checked, so a change in a future Typst fails loudly instead of
// producing wrong labels. Replace with a native accessor once one lands.
/// Текст значення `path` ("/dir/file.png"); рядки повертаються як є
#let path-str(file) = if type(file) == str { file } else {
  let r = repr(file)
  assert(
    r.starts-with("path(\"") and r.ends-with("\")"),
    message: "path-str: unexpected path repr " + r + "; pass `label:` explicitly",
  )
  r.slice(6, -2).replace("\\\"", "\"")
}

/// Назва файлу без розширення
#let stem(file) = path-str(file).split("/").last().split(".").first()

/// Назва батьківської теки
#let parent-dir(file) = path-str(file).split("/").at(-2, default: "")

/// Мітка з шляху до рисунка (рядок або `path`):
/// - "image.png" → "image"
/// - "img/foo/bar.png" → "foo_bar"
#let img-label(file) = {
  let name = stem(file)
  let parent = parent-dir(file)

  // If parent exists and name doesn't start with parent name, combine them
  let base = if parent != "" and not name.starts-with(parent) {
    parent + "_" + name
  } else {
    name
  }

  label(base.replace(" ", "_"))
}

/// Підпис рисунка з приміткою про джерело
#let img-caption(base-caption, source) = {
  if source == none {
    base-caption + " (рисунок виконано самостійно)"
  } else if source == () or source == "" {
    base-caption
  } else {
    base-caption + " (за даними " + source + ")"
  }
}

/// рисунок з підписом і міткою, виведеною з назви файлу
/// Використання: img(path("figures/image.png"), [Підпис], "джерело" (необов'язково))
///
/// - file (path): Файл рисунка; саме `path`, бо рядок шукався б
///   у пакунку, а не у вашому проєкті
/// - caption (content): Підпис рисунка
/// - source (str, none): Джерело рисунка; `none` -- "(рисунок виконано самостійно)"
/// - label (label, auto, none): Мітка рисунка, за замовчуванням з назви файлу
/// - ..args: Передаються в `image` (width, height, fit, ...)
#let img(file, caption, ..args) = {
  if type(file) == str {
    panic("img: pass `path(\"" + file + "\")` instead of a string, which would be looked up inside the package")
  }
  let source = args.pos().at(0, default: ())
  let named = args.named()
  let lbl = named.remove("label", default: auto)
  let lbl = if lbl == auto { img-label(file) } else { lbl }

  [#figure(image(file, ..named), caption: img-caption(caption, source)) #lbl]
}
