#import "utils.typ": bold
/// Константи оформлення
#let spacing = 0.95em
#let indent-size = 1.25cm
#let double-spacing = spacing * 2
#let double-half-spacing = spacing * 2.5

/// Українська абетка для нумерації за ДСТУ 3008:2015
#let ukr-enum = "абвгдежиклмнпрстуфхцшщюя".clusters()

/// Номер поточного додатка (`none` поза додатками), для нумерації в посиланнях
#let appendix-index = state("appendix-index", none)

/// Відступ між підписом таблиці (лістингу) й нею та під написом «Продовження таблиці»
#let table-caption-gap = 0.65em

// Наскрізний номер таблиці чи лістингу в документі -- для унікальних ключів
// маркерів початку й кінця фігури (позиція фігури як ключ працює, але в рази повільніше).
#let figure-seq = counter("dstu-figure-seq")

// Напис над продовженням фігури на новій сторінці; на першій її сторінці -- нічого.
#let continuation-label(noun, num, start-key, end-key) = context {
  let start = query(metadata.where(value: start-key)).first().location().page()
  if here().page() == start { return }
  let end = query(metadata.where(value: end-key)).first().location().page()
  set par(first-line-indent: 0pt)
  block(inset: (bottom: table-caption-gap))[
    #if here().page() == end [Кінець] else [Продовження] #noun#if num != none [ #num]
  ]
}

// Оформлення таблиці- чи лістингу-`figure` за ДСТУ: підпис ліворуч над
// фігурою, перенос між сторінками з написом «Продовження таблиці N»
// («Продовження лістингу N»). Вміст користувача не перебудовується, а
// обгортається в сітку з однією колонкою: шапка сітки повторюється на кожній
// сторінці й несе напис, а єдина комірка -- сама таблиця чи код, як є. Тому
// номери рядків, явні аргументи, set- і show-правила користувача не зачіпаються.
#let breakable-figure(fig) = {
  // плаваючу фігуру однаково не можна розірвати -- лишаємо як є
  if fig.placement != none { return fig }

  let noun = if fig.kind == raw [лістингу] else [таблиці]
  // номер цієї фігури («1.2», «А.1»); обчислюється там, де стоїть напис
  let num = if fig.numbering != none { fig.counter.display(fig.numbering) }

  figure-seq.step()
  context {
    let id = str(figure-seq.get().first())
    let (start-key, end-key) = ("dstu-figure-start-" + id, "dstu-figure-end-" + id)

    // інтервали, які для інших фігур додає show-правило фігури в `dstu`
    // (до цього виводу воно вже не застосовується)
    v(double-spacing, weak: true)

    if fig.caption != none {
      block(sticky: true, below: fig.gap, width: 100%, {
        set align(left)
        set par(first-line-indent: 0pt)
        fig.caption
      })
    }

    metadata(start-key)
    // Колонка на всю ширину тексту, щоб напис не переносився; вміст у ній --
    // від лівого краю. Решта значень явні, щоб `set grid(...)` користувача не
    // зачепив обгортку.
    grid(
      columns: (100%,),
      align: left,
      stroke: none,
      inset: 0pt,
      fill: none,
      gutter: 0pt,
      grid.header(
        repeat: true,
        continuation-label(noun, num, start-key, end-key),
      ),
      {
        // У звичайному figure вміст комірок таблиці центрується, бо фігура
        // вирівнює своє тіло по центру; відтворюємо це, якщо користувач не
        // задав власного вирівнювання таблиці.
        set table(align: center) if table.align == auto
        fig.body
      },
    )
    metadata(end-key)
    v(double-spacing, weak: true)
  }
}

/// Блок заголовків 2-го і 3-го рівнів
#let heading-block(it, num: auto) = {
  v(double-spacing, weak: true)
  block(width: 100%, spacing: 0em)[
    #h(indent-size)
    #counter(heading).display(num)
    #it.body
  ]
  v(double-spacing, weak: true)
}

#let _required(name, value) = {
  if value == none {
    panic("dstu-table: " + name + " is required")
  }
  value
}

/// Таблиця з підписом -- скорочення для `figure(table(table.header(..header), ..), caption: ..)`.
/// Перенос між сторінками з написом «Продовження таблиці N» `style.dstu`
/// оформлює для будь-якої таблиці-`figure`, тож ця функція -- лише зручність.
///
/// - caption (content): Назва таблиці
/// - columns (int, array): Кількість або ширини колонок
/// - header (array): Комірки шапки, напр. `([A], [B])`
/// - label (label): Мітка для посилань, напр. `<my-table>`
/// - tag (str): Те саме рядком (для сумісності зі старими версіями)
/// - ..args: Передаються в `table` (комірки, `align`, `stroke`, ...)
#let dstu-table(caption: none, columns: none, header: none, label: none, tag: none, ..args) = {
  let caption = _required("caption", caption)
  let columns = _required("columns", columns)
  let header = _required("header", header)
  if type(header) != array {
    panic("dstu-table: header must be an array, e.g. ([A], [B])")
  }
  let label = if label != none { label } else if tag != none { std.label(tag) }

  [#figure(
      table(columns: columns, ..args.named(), table.header(..header), ..args.pos()),
      caption: caption,
    ) #label]
}
}

/// Оформлення за ДСТУ 3008:2015: `#show: style.dstu`
#let dstu(
  it,
  skip: 0,
  offset: 0,
) = {
  // Page setup
  set page(
    paper: "a4",
    number-align: top + right,
    margin: (top: 20mm, right: 10mm, bottom: 20mm, left: 25mm),
    numbering: (i, ..) => if i > skip { numbering("1", i + offset) },
    // Виноски нумерують у межах кожної сторінки (7.9.2): фон кладеться на
    // кожну сторінку раніше за її вміст, тож лічильник скидається до першої виноски
    background: counter(footnote).update(0),
  )

  // Text and paragraph
  set text(lang: "uk", size: 14pt, hyphenate: false, font: ("Times New Roman", "Liberation Serif"))
  set par(justify: true, spacing: spacing, leading: spacing, first-line-indent: (
    amount: indent-size,
    all: true,
  ))
  set block(spacing: spacing)
  set underline(evade: false)

  // Lists
  set enum(indent: indent-size, body-indent: 0.5cm, numbering: i => ukr-enum.at(i - 1) + ")")
  show enum: it => {
    set enum(indent: 0em, numbering: "1)")
    it
  }
  set list(indent: indent-size + 0.1cm, body-indent: 0.5cm, marker: [--])

  // Footnotes (7.9.2, 7.9.5, 7.9.6): «1)» над рядком; текст з абзацного
  // відступу, кеглем 12 через один інтервал; лінія 35 мм від лівого берега
  set footnote(numbering: "1)")
  set footnote.entry(separator: line(length: 35mm, stroke: 0.5pt), indent: 0pt)
  show footnote.entry: set text(size: 12pt)
  show footnote.entry: set par(leading: 0.65em, spacing: 0.65em, first-line-indent: (
    amount: indent-size,
    all: true,
  ))
  // запис виноски -- не абзац, тож без обгортки відступ першого рядка не діє
  show footnote.entry: it => par(it)

  // Figures
  show ref: it => {
    let target = it.element

    if target == none {
      return it
    }

    if target.func() != figure and target.func() != math.equation {
      return it
    }

    // A figure or equation number must be read at the element itself, not at the citation site.
    // The default ref display re-runs the numbering function here, where its inner `counter(heading)`
    // context resolves to the citing chapter and prints the wrong section or appendix letter.
    // We sample every counter at the target location instead.
    let loc = target.location()

    let appendix = appendix-index.at(loc)

    let section = if appendix == none {
      str(counter(heading).at(loc).first())
    } else {
      upper(ukr-enum.at(appendix - 1))
    }

    let number = if target.func() == figure {
      let idx = counter(figure.where(kind: target.kind)).at(loc).first()
      section + "." + str(idx)
    } else {
      let idx = counter(math.equation).at(loc).first()
      "(" + section + "." + str(idx) + ")"
    }

    let supplement = if it.supplement == auto {
      target.supplement
    } else {
      it.supplement
    }

    let body = if supplement != auto and supplement != none {
      [#supplement #number]
    } else {
      [#number]
    }

    link(loc, body)
  }

  show figure: it => {
    v(double-spacing, weak: true)
    it
    v(double-spacing, weak: true)
  }
  set figure.caption(separator: [ -- ])
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.caption.where(kind: table): set align(left)
  show figure.where(kind: raw): set figure.caption(position: top)
  show figure.where(kind: raw): set align(left)

  // Tables and listings: break across pages with «Продовження таблиці N»
  // («Продовження лістингу N»); the figure wraps the show rule output in a
  // block, which must be breakable for that
  show figure.where(kind: table): set block(breakable: true)
  show figure.where(kind: table): breakable-figure
  show figure.where(kind: raw): set block(breakable: true)
  show figure.where(kind: raw): breakable-figure

  // Numbering reset on level 1 headings
  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    counter(figure.where(kind: raw)).update(0)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    it
  }
  set figure(numbering: i => context numbering("1.1", counter(heading).get().at(0), i))
  set math.equation(numbering: i => context numbering("(1.1)", counter(heading).get().at(0), i))

  // Нумерують лише ті формули, на які є посилання (7.10.2). Формула без
  // посилання виводиться без номера, а лічильник повертається назад, тож
  // номери решти йдуть без пропусків. Явне `numbering: none` не чіпається.
  show math.equation.where(block: true): it => {
    if it.numbering == none { return it }
    context {
      if it.has("label") and query(ref.where(target: it.label)).len() > 0 { return it }
      counter(math.equation).update(n => n - 1)
      math.equation(it.body, block: true, numbering: none)
    }
  }

  // Decimal comma in formulas: $9.8$ -> 9,8. In math every number is a separate
  // text atom, so the anchored regex rewrites only whole numbers and leaves the
  // equation number «(1.1)» (one text with parentheses) untouched.
  show math.equation: it => {
    show regex("^\d+\.\d+$"): m => m.text.replace(".", ",")
    it
  }

  // Headings
  set heading(numbering: "1.1")
  show heading: it => {
    set text(size: 14pt)
    if it.level == 1 {
      set align(center)
      set text(weight: "semibold")
      pagebreak(weak: true)
      upper(it)
      v(double-spacing, weak: true)
    } else {
      set text(weight: "regular")
      heading-block(it, num: if it.level == 3 { it.numbering } else { auto })
    }
  }

  // Code listings
  show raw.where(block: true): it => {
    let code-spacing = 0.5em
    set block(spacing: code-spacing)
    set par(spacing: code-spacing, leading: code-spacing)
    set text(size: 11pt, weight: "semibold", font: ("Courier New", "Liberation Mono"))
    v(double-half-spacing, weak: true)
    pad(it, left: indent-size)
    v(double-half-spacing, weak: true)
  }

  // blocks `like this` aren't welcome, so ` is replaced with "
  show raw.where(block: false): it => text(
    lang: "uk",
    size: 14pt,
    hyphenate: false,
    weight: "regular",
    font: ("Times New Roman", "Liberation Serif"),
  )["#it.text"]

  it
}

/// Оформлення додатків за ДСТУ 3008:2015: `#show: style.appendices`
#let appendices(it) = {
  counter(heading).update(0)

  set heading(numbering: (i, ..n) => upper(ukr-enum.at(i - 1)) + numbering(".1.1", ..n))
  set heading(supplement: [Додаток])

  let app-letter = context upper(ukr-enum.at(counter(heading).get().at(0) - 1))
  set figure(numbering: i => app-letter + "." + str(i))
  set math.equation(numbering: i => [(#app-letter.#str(i))])

  show heading: h => {
    set text(size: 14pt)
    if h.level == 1 {
      counter(math.equation).update(0)
      counter(figure.where(kind: raw)).update(0)
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      appendix-index.update(counter(heading).get().at(0))

      set align(center)
      set text(weight: "regular")
      pagebreak(weak: true)
      bold([ДОДАТОК #counter(heading).display(auto)])
      linebreak()
      h.body
      v(double-spacing, weak: true)
    } else {
      set text(weight: "regular")
      heading-block(h)
    }
  }

  it
}
