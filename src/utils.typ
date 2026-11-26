/// напівжирний текст
#let bold(content) = text(weight: "bold")[#content]

/// ненумерований заголовок першого рівня
#let nheading(title) = heading(depth: 1, numbering: none, title)

/// знімає абзацний відступ з рядка, перед яким стоїть; насамперед для
/// пояснень познак під формулою: «без абзацного відступу з нового рядка,
/// починаючи зі слова «де» без двокрапки» (ДСТУ 3008:2015, 7.10.6)
/// Використання: `#utils.noindent де $x$ -- ...`
///
/// Відступ береться з `par.first-line-indent`, тож працює з будь-яким
/// відступом (і в `em`). Без `all: true` Typst сам не відступає абзац після
/// формули, і від'ємний `h` виштовхнув би рядок за лівий берег.
#let noindent = context {
  let indent = par.first-line-indent
  if indent.all { h(-indent.amount) }
}

/// Поле з підкресленням кожного фактичного рядка при автоматичному переносі.
///
/// Typst не вміє підкреслювати порожній простір до правого краю на рядках із
/// автопереносом, тому функція вимірює висоту блока тексту й малює тонку лінію
/// під кожним рядком.
///
/// - value (content, str, array): Значення поля (масив з'єднується пробілом)
/// - prefix (content, none): Непідкреслений префікс на початку першого рядка
///   (напр. `[1. Тема роботи]`); лінія першого рядка починається після нього
/// - min-lines (int): Мінімальна кількість підкреслених рядків
/// - stroke (stroke): Стиль лінії підкреслення
/// - leading-frac (float): Міжрядковий інтервал у частках розміру шрифту
/// - offset (length): Зміщення лінії вниз від базової лінії рядка
#let ruled-field(
  value,
  prefix: none,
  min-lines: 1,
  stroke: 0.5pt,
  leading-frac: 0.5,
  offset: 0.2em,
) = layout(bounds => context {
  let val = if type(value) == array { value.join([ ]) } else { value }
  let fs = text.size
  let leading = leading-frac * fs
  let lh = measure(text(size: fs)[Ay]).height // one line box
  let dist = lh + leading // step between consecutive line bottoms
  let pw = if prefix != none { measure(prefix).width + 0.35em.to-absolute() } else { 0pt }
  let body = if prefix != none { [#prefix#h(0.35em)#val] } else { val }
  let h = measure(block(width: bounds.width)[
    #set par(justify: false, leading: leading, first-line-indent: 0pt)
    #body
  ]).height
  let n = int(calc.max(min-lines, if h > 0pt { calc.round((h - lh) / dist) + 1 } else { 1 }))
  // `offset` drops the rules below descenders (у, р, щ, ...); block grows to match
  block(width: 100%, height: lh + (n - 1) * dist + offset)[
    #for k in range(n) {
      let dx = if k == 0 { pw } else { 0pt }
      place(top + left, dx: dx, dy: lh + k * dist + offset, line(length: bounds.width - dx, stroke: stroke))
    }
    #set par(justify: false, leading: leading, first-line-indent: 0pt)
    #body
  ]
})

/// підкреслене поле на всю ширину (короткий запис `ruled-field` із вирівнюванням)
#let uline(align: center, ..args, content) = {
  let body = if type(content) == array { content.join([ ]) } else { content }
  ruled-field(if align == left { body } else { std.align(align, body) }, ..args)
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

// Внутрішнє форматування приміток (ДСТУ 3008:2015, 7.8.3, 7.8.4):
// кегль 12, одинарний інтервал, абзацний відступ; одна не нумерується
// («Примітка. …»), дві й більше -- «Примітка 1. …», «Примітка 2. …».
#let _format-notes(notes) = {
  let items = if type(notes) == array { notes } else { (notes,) }
  if items.len() == 0 { return }
  set align(left)
  set text(size: 12pt)
  set par(leading: 0.65em, spacing: 0.65em, first-line-indent: (all: true))
  if items.len() == 1 {
    par[Примітка. #items.first()]
  } else {
    for (i, item) in items.enumerate() {
      par[Примітка #(i + 1). #item]
    }
  }
}

/// рисунок з підписом і приміткою про джерело
/// Використання: dstu-figure(path("figures/image.png"), [Підпис], "джерело" (необов'язково), label: <x>)
///
/// - file (path): Файл рисунка; саме `path`, бо рядок шукався б
///   у пакунку, а не у вашому проєкті
/// - caption (content): Підпис рисунка
/// - source (str, none): Джерело рисунка; `none` -- "(рисунок виконано самостійно)"
/// - note (content, array, none): Примітка або масив приміток під рисунком перед назвою (7.5.9, 7.8.2)
/// - label (label, none): Мітка рисунка
/// - ..args: Передаються в `image` (width, height, fit, ...)
#let dstu-figure(file, caption, ..args) = {
  if type(file) == str {
    panic("dstu-figure: pass `path(\"" + file + "\")` instead of a string, which would be looked up inside the package")
  }
  let source = args.pos().at(0, default: ())
  let named = args.named()
  let lbl = named.remove("label", default: none)
  let note = named.remove("note", default: none)

  let img = image(file, ..named)
  let body = if note != none {
    stack(spacing: 0.5em, img, block(width: 100%, _format-notes(note)))
  } else {
    img
  }

  [#figure(body, kind: image, caption: img-caption(caption, source)) #lbl]
}
