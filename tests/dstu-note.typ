// Примітки за ДСТУ 3008:2015 (7.8, 7.1.24): одна не нумерується («Примітка. …»),
// кілька нумеруються («Примітка 1. …»); кегль 12, одинарний інтервал, абзацний
// відступ; у тексті -- відступ `double-spacing`, під рисунком -- перед назвою,
// у таблиці -- під основною частиною (не повторюється при переносі).
#import "../src/lib.typ": *

#show: style.dstu

#let pos(l) = locate(l).position()

= Примітки

#box[]<p-before>Звичайний абзац перед приміткою.

#[
  #show "Примітка": it => [#box[]<n1-start>#it]
  #show "raw-check": it => context {
    assert(calc.abs(text.size - 12pt) < 0.01pt, message: "inline raw in note must stay 12pt, got " + repr(text.size))
    it
  }
  #dstu-note[Одна примітка до тексту з `raw-check`, досить довга, щоб перенестися на другий рядок і показати відсутність висячого відступу: #lorem(18).]
]

#box[]<p-after>Звичайний абзац після примітки.

#[
  #show "Примітка 1": it => [#box[]<n2a>#it]
  #show "Примітка 2": it => [#box[]<n2b>#it]
  #note[
    Перша з двох приміток.
  ][
    Друга з двох приміток.
  ]
]

#dstu-note(([Масив перша.], [Масив друга.]))

// Примітка під рисунком перед його назвою (7.5.9, 7.8.2)
#[
  #show "Примітка": it => [#box[]<fig-note>#it]
  #fig(
    path("fixtures/figures/scheme.svg"),
    [#box[]<fig-cap>Схема з приміткою],
    width: 4cm,
    note: [Пояснення до схеми.],
    label: <f-noted>,
  )
]

#fig(
  path("fixtures/figures/scheme.svg"),
  [Схема з двома примітками],
  none,
  width: 4cm,
  note: ([Перше пояснення.], [Друге пояснення.]),
)

// Примітка в межах короткої й багатосторінкової таблиці (7.8.2)
#[
  #show "Примітка": it => [#box[]<tab-short-note>#it]
  #tab(
    caption: [Коротка таблиця з приміткою],
    columns: 2,
    header: ([Параметр], [Значення]),
    note: [Пояснення до таблиці.],
    [Напруга],
    [3,3 В],
  )
]

#tab(
  caption: [Довга таблиця з примітками],
  columns: (1fr, 2fr),
  header: ([№], [Дані]),
  note: ([#box[]<tab-long-note>Перша примітка довгої таблиці.], [Друга примітка довгої таблиці.]),
  ..range(120).map(i => [#i]),
)

Див. @f-noted.

#context {
  let left = page.margin.left.length
  let indent = par.first-line-indent.amount

  // 1. Одиночна й кілька приміток мають абзацний відступ
  assert(
    calc.abs(pos(<n1-start>).x - (left + indent)) < 0.5pt,
    message: "single note indent",
  )
  assert(
    calc.abs(pos(<n2a>).x - (left + indent)) < 0.5pt,
    message: "numbered note 1 indent",
  )
  assert(
    calc.abs(pos(<n2b>).x - (left + indent)) < 0.5pt,
    message: "numbered note 2 indent",
  )

  // 2. Рисунок із приміткою лишається figure(kind: image), примітка -- перед назвою
  assert.eq(query(figure.where(kind: image)).len(), 2)
  assert(pos(<fig-note>).y < pos(<fig-cap>).y, message: "figure note must precede caption")
  assert(
    calc.abs(pos(<fig-note>).x - (left + indent)) < 0.5pt,
    message: "figure note indent",
  )

  // 3. Примітка таблиці -- в межах таблиці з абзацним відступом і не повторюється
  assert(
    pos(<tab-short-note>).x > left + indent,
    message: "table note must be indented inside cell",
  )
  let long-end-page = query(metadata.where(value: "dstu-figure-end-2")).first().location().page()
  let long-start-page = query(metadata.where(value: "dstu-figure-start-2")).first().location().page()
  assert(long-end-page > long-start-page, message: "long table must span pages")
  assert.eq(
    query(<tab-long-note>).len(),
    1,
    message: "table note must not repeat on intermediate pages",
  )
  assert.eq(
    pos(<tab-long-note>).page,
    long-end-page,
    message: "table note must appear on the last page of the table",
  )
}
