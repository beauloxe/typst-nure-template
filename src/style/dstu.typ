#import "../utils.typ": _format-notes, bold
/// Константи оформлення
#let spacing = 0.95em
#let indent-size = 1.25cm
#let double-spacing = spacing * 2
#let double-half-spacing = spacing * 2.5
#let code-font = ("Courier New", "Liberation Mono")

/// Українська абетка для нумерації за ДСТУ 3008:2015
#let ukr-enum = "абвгдежиклмнпрстуфхцшщюя".clusters()

// Обхідне рішення для переліків без висячого відступу (ДСТУ 3008:2015, 7.7.4):
// вбудовані `list` і `enum` у Typst завжди вирівнюють перенесені рядки під
// початком тексту пункту (https://github.com/typst/typst/issues/5751).
// Розкладаємо кожен пункт у звичайний абзац потоку (аналогічно до `show block`
// у `dstu-bibliography`): перший рядок зміщується на накопичений відступ рівня
// плюс маркер і `body-indent`, а перенесені рядки йдуть від лівого берега.
// `body` не загортається в `context`, тож довільна глибина вкладення збігається
// за два проходи верстки. Коли Typst підтримає hanging-indent для списків --
// приберіть ці правила.
#let _list-indents = state("dstu-list-indents", ())
#let _list-depth = state("dstu-list-depth", 0)
#let _enum-parents = state("dstu-enum-parents", ())

#let _ukr-numbering(i) = ukr-enum.at(i - 1) + ")"

#let _flat-item(body-indent, make-prefix, body) = {
  parbreak()
  context {
    let ind = _list-indents.get().sum(default: 0pt)
    h(ind - par.first-line-indent.amount)
    let prefix = make-prefix()
    if prefix != none {
      box(prefix)
      h(body-indent)
    }
  }
  body
  parbreak()
}

#let _flat-list(it) = {
  if it.children.len() == 0 { return }
  _list-indents.update(s => s + (it.indent,))
  _list-depth.update(d => d + 1)
  {
    set par(first-line-indent: (all: true))
    set par(spacing: it.spacing) if it.spacing != auto
    for child in it.children {
      let make-prefix() = {
        let d = _list-depth.get() - 1
        if type(it.marker) == array {
          it.marker.at(calc.rem(d, it.marker.len()))
        } else if type(it.marker) == function {
          it.marker(d)
        } else {
          it.marker
        }
      }
      _flat-item(it.body-indent, make-prefix, child.body)
    }
  }
  _list-depth.update(d => d - 1)
  _list-indents.update(s => s.slice(0, -1))
}

#let _flat-enum(it) = {
  if it.children.len() == 0 { return }
  let num = if it.start != auto {
    it.start
  } else if it.reversed {
    it.children.len()
  } else {
    1
  }
  let step = if it.reversed { -1 } else { 1 }
  _list-indents.update(s => s + (it.indent,))
  {
    set par(first-line-indent: (all: true))
    set par(spacing: it.spacing) if it.spacing != auto
    set enum(numbering: "1)") if it.numbering == _ukr-numbering
    for child in it.children {
      let explicit = child.at("number", default: auto)
      let cur = if explicit != auto { explicit } else { num }
      if cur != none {
        num = cur + step
        _enum-parents.update(p => p + (cur,))
      }
      let make-prefix() = if cur == none {
        none
      } else if it.full {
        numbering(it.numbering, .._enum-parents.get())
      } else {
        numbering(it.numbering, cur)
      }
      _flat-item(it.body-indent, make-prefix, child.body)
      if cur != none { _enum-parents.update(p => p.slice(0, -1)) }
    }
  }
  _list-indents.update(s => s.slice(0, -1))
}

/// Номер поточного додатка (`none` поза додатками), для нумерації в посиланнях
#let appendix-index = state("appendix-index", none)

#let _heading-numbering(..n) = {
  let nums = n.pos()
  while nums.len() > 0 and nums.first() == 0 {
    nums = nums.slice(1)
  }
  if nums.len() > 0 {
    numbering("1.1", ..nums)
  }
}

#let _section-figure-numbering(i) = context numbering("1.1", counter(heading).get().at(0), i)
#let _section-equation-numbering(i) = context numbering("(1.1)", counter(heading).get().at(0), i)
// Функція замість рядка `"(1)"`, щоб у посиланнях (`@eq`) Typst не знімав дужки (ДСТУ 3008:2015, 7.10.2)
#let _continuous-equation-numbering(i) = numbering("(1)", i)
#let _appendix-figure-numbering(i) = context {
  upper(ukr-enum.at(counter(heading).get().at(0) - 1)) + "." + str(i)
}
#let _appendix-equation-numbering(i) = context {
  [(#upper(ukr-enum.at(counter(heading).get().at(0) - 1)).#str(i))]
}

#let _reset-section-counters() = context {
  if math.equation.numbering == _section-equation-numbering {
    counter(math.equation).update(0)
  }
  if figure.numbering == _section-figure-numbering {
    counter(figure.where(kind: raw)).update(0)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
  }
}

/// Відступ між підписом таблиці (лістингу) й нею та під написом «Продовження таблиці»
#let table-caption-gap = 0.65em

// Наскрізний номер таблиці чи лістингу в документі -- для унікальних ключів
// маркерів початку й кінця фігури (позиція фігури як ключ працює, але в рази повільніше).
#let figure-seq = counter("dstu-figure-seq")

// Напис над продовженням фігури на новій сторінці з абзацного відступу (7.6.9);
// на першій її сторінці -- нічого.
#let continuation-label(noun, num, start-key, end-key) = context {
  let start = query(metadata.where(value: start-key)).first().location().page()
  if here().page() == start { return }
  let end = query(metadata.where(value: end-key)).first().location().page()
  set par(first-line-indent: (all: true))
  block(
    width: 100%,
    inset: (bottom: table-caption-gap),
    par[#if here().page() == end [Кінець] else [Продовження] #noun#if num != none [ #num]],
  )
}

// Підпис таблиці або лістингу з абзацного відступу (ДСТУ 3008:2015, 7.6.8):
// стандартний `figure.caption` не застосовує `par.first-line-indent`, тому
// загортаємо вміст підпису в `par`.
#let _indented-caption(it) = {
  set align(left)
  set par(first-line-indent: (all: true))
  block(
    width: 100%,
    par[#if it.supplement != none and it.numbering != none [#it.supplement~#context it.counter.display(
          it.numbering,
        )#it.separator]#it.body],
  )
}

// Оформлення таблиці- чи лістингу-`figure` за ДСТУ: підпис з абзацного відступу
// над фігурою, перенос між сторінками з написом «Продовження таблиці N»
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
    #if it.numbering != none {
      counter(heading).display(if num == auto { it.numbering } else { num })
      [ ]
    }#it.body
  ]
  v(double-spacing, weak: true)
}

#let _required(name, value) = {
  if value == none {
    panic("dstu-table: " + name + " is required")
  }
  value
}

/// Примітка або кілька приміток за ДСТУ 3008:2015 (7.8, 7.1.24):
/// одна не нумерується («Примітка. …»), дві й більше нумеруються
/// («Примітка 1. …», «Примітка 2. …»); кегль 12, одинарний інтервал,
/// абзацний відступ, відступ `double-spacing` від тексту.
///
/// - ..notes (content): Текст примітки (один або кілька аргументів, або масив)
#let dstu-note(..notes) = {
  let items = notes.pos()
  if items.len() == 1 and type(items.first()) == array {
    items = items.first()
  }
  if items.len() == 0 { return }
  v(double-spacing, weak: true)
  _format-notes(items)
  v(double-spacing, weak: true)
}

/// Таблиця з підписом -- скорочення для `figure(table(table.header(..header), ..), caption: ..)`.
/// Перенос між сторінками з написом «Продовження таблиці N» `style.dstu`
/// оформлює для будь-якої таблиці-`figure`, тож ця функція -- лише зручність.
///
/// - caption (content): Назва таблиці
/// - columns (int, array): Кількість або ширини колонок
/// - header (array): Комірки шапки, напр. `([A], [B])`
/// - note (content, array, none): Примітка або масив приміток у межах таблиці під основною частиною (7.8.2)
/// - label (label): Мітка для посилань, напр. `<my-table>`
/// - tag (str): Те саме рядком (для сумісності зі старими версіями)
/// - ..args: Передаються в `table` (комірки, `align`, `stroke`, ...)
#let dstu-table(caption: none, columns: none, header: none, note: none, label: none, tag: none, ..args) = {
  let caption = _required("caption", caption)
  let columns = _required("columns", columns)
  let header = _required("header", header)
  if type(header) != array {
    panic("dstu-table: header must be an array, e.g. ([A], [B])")
  }
  let label = if label != none { label } else if tag != none { std.label(tag) }
  let col-count = if type(columns) == int {
    columns
  } else if type(columns) == array {
    columns.len()
  } else {
    1
  }

  [#figure(
      table(
        columns: columns,
        ..args.named(),
        table.header(..header),
        ..args.pos(),
        ..if note != none {
          (table.footer(repeat: false, table.cell(colspan: col-count, align: left, _format-notes(note))),)
        },
      ),
      caption: caption,
    ) #label]
}

/// Оформлення за ДСТУ 3008:2015: `#show: style.dstu`
#let dstu(
  it,
  skip: 0,
  offset: 0,
  section-numbering: true,
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
  set underline(evade: false, offset: 0.22em, stroke: 0.5pt)

  // Lists (7.7.2, 7.7.4): а) -> 1) -> --; кожен рівень зсувається на абзацний
  // відступ, перенесені рядки повертаються до лівого берега без висячого відступу
  set enum(indent: indent-size, body-indent: 0.5cm, numbering: _ukr-numbering)
  set list(indent: indent-size, body-indent: 0.5cm, marker: [--])
  show list: _flat-list
  show enum: _flat-enum

  // Footnotes (7.9.2, 7.9.5, 7.9.6): «1)» над рядком; текст з абзацного
  // відступу, кеглем 12 через один інтервал; лінія 35 мм від лівого берега
  set footnote(numbering: "1)")
  set footnote.entry(separator: line(length: 35mm, stroke: 0.5pt), indent: 0pt)
  show footnote.entry: set text(size: 12pt)
  show footnote.entry: set par(leading: 0.65em, spacing: 0.65em, first-line-indent: (
    amount: indent-size,
    all: true,
  ))
  // запис виноски -- не абзац, тож без обгортки відступ першого рядка не діє;
  // також додаємо пробіл між знаком виноски «1)» і текстом
  show footnote.entry: it => {
    let loc = it.note.location()
    let num = numbering(it.note.numbering, ..counter(footnote).at(loc))
    par[#link(loc, super(num))#h(0.25em)#it.note.body]
  }

  // Figures and equations with section/appendix numbering
  show ref: it => {
    let target = it.element

    if target == none {
      return it
    }

    let is-dstu-fig = (
      target.func() == figure and target.numbering in (_section-figure-numbering, _appendix-figure-numbering)
    )
    let is-dstu-eq = (
      target.func() == math.equation and target.numbering in (_section-equation-numbering, _appendix-equation-numbering)
    )

    if not is-dstu-fig and not is-dstu-eq {
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
  show figure.caption.where(kind: table): _indented-caption
  show figure.where(kind: raw): set figure.caption(position: top)
  show figure.where(kind: raw): set align(left)
  show figure.caption.where(kind: raw): _indented-caption

  // Tables and listings: break across pages with «Продовження таблиці N»
  // («Продовження лістингу N»); the figure wraps the show rule output in a
  // block, which must be breakable for that
  show figure.where(kind: table): set block(breakable: true)
  show figure.where(kind: table): breakable-figure
  show figure.where(kind: raw): set block(breakable: true)
  show figure.where(kind: raw): breakable-figure

  // Numbering reset on level 1 headings
  show heading.where(level: 1): it => {
    if section-numbering {
      _reset-section-counters()
    }
    it
  }
  set figure(numbering: if section-numbering { _section-figure-numbering } else { "1" })
  set math.equation(
    numbering: if section-numbering {
      _section-equation-numbering
    } else {
      _continuous-equation-numbering
    },
    // У багаторядкових формулах номер проставляють на рівні останнього рядка (7.10.4)
    number-align: end + bottom,
  )

  // Відстань від попереднього й наступного тексту не менше ніж один рядок (7.10.1)
  show math.equation.where(block: true): set block(above: double-spacing, below: double-spacing)

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
  set heading(
    numbering: _heading-numbering,
    supplement: it => {
      let lvl = if it.has("level") and it.level != auto {
        it.level
      } else if it.has("depth") {
        it.depth
      } else {
        1
      }
      ([Розділ], [Підрозділ], [Пункт], [Підпункт]).at(calc.min(lvl, 4) - 1)
    },
  )
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
      heading-block(it)
    }
  }

  // Code listings
  show raw.where(block: true): it => {
    let code-spacing = 0.5em
    set block(spacing: code-spacing)
    set par(spacing: code-spacing, leading: code-spacing)
    set text(size: 11pt, weight: "semibold", font: code-font)
    v(double-half-spacing, weak: true)
    pad(it, left: indent-size)
    v(double-half-spacing, weak: true)
  }

  // blocks `like this` aren't welcome, so ` is replaced with "
  // Typst scales `raw` to 0.8em by default; 1.25em restores the surrounding text size
  // so inline code matches 14pt body, 12pt notes/footnotes, and 10pt form captions.
  show raw.where(block: false): it => text(
    lang: "uk",
    size: 1.25em,
    hyphenate: false,
    weight: "regular",
    font: ("Times New Roman", "Liberation Serif"),
  )["#it.text"]

  it
}

/// Оформлення додатків за ДСТУ 3008:2015: `#show: style.appendices`
#let appendices(it) = {
  counter(heading).update(0)

  let appendix-numbering = (i, ..n) => upper(ukr-enum.at(i - 1)) + numbering(".1.1", ..n)
  set heading(numbering: appendix-numbering)
  // Перекриває зовнішнє `show heading.where(level: 1): set heading(numbering: none)`
  // (напр. зі `style.overrides.plain-heading`), щоб додатки все одно нумерувалися
  show heading.where(level: 1): set heading(numbering: appendix-numbering)
  set heading(supplement: [Додаток])

  set figure(numbering: _appendix-figure-numbering)
  set math.equation(numbering: _appendix-equation-numbering)

  show heading: h => {
    set text(size: 14pt)
    if h.level == 1 {
      context {
        if math.equation.numbering == _appendix-equation-numbering {
          counter(math.equation).update(0)
        }
        if figure.numbering == _appendix-figure-numbering {
          counter(figure.where(kind: raw)).update(0)
          counter(figure.where(kind: image)).update(0)
          counter(figure.where(kind: table)).update(0)
        }
      }
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
