// Tables under style.dstu: plain figure(table(...)) breaks across pages with
// «Продовження таблиці N», while the user's table is left untouched (row
// indices, explicit arguments, set and show rules keep working).
#import "../src/lib.typ": *

#let rows(n) = range(n).map(i => [#i])

// the n-th table figure of the document spans pages start..end
#let spans(n) = {
  let page-of(key) = query(metadata.where(value: key + str(n))).first().location().page()
  (page-of("dstu-table-start-"), page-of("dstu-table-end-"))
}

#show: style.dstu
#show table.cell.where(y: 0): strong
#set grid(stroke: 2pt + red, inset: 10pt) // must not leak into the table wrapper

= Довгі таблиці
#figure(
  table(
    columns: (1fr, 2fr),
    table.header([A], [B]),
    ..rows(150),
  ),
  caption: [З шапкою],
) <long>
#figure(table(columns: 2, ..rows(150)), caption: [Вузька без шапки])
#figure(
  {
    set text(size: 10pt)
    table(columns: 3, ..rows(200))
  },
  caption: [Стилізоване тіло],
)
#figure(table(columns: 2, ..rows(150)), caption: [Без номера], numbering: none)

Посилання: @long, @long[таблиці].

#context {
  for n in range(1, 5) {
    let (start, end) = spans(n)
    assert(end > start, message: "table " + str(n) + " must span several pages")
  }
}

= Таблиці користувача
#figure(
  table(
    columns: 2,
    table.cell(x: 1, y: 0)[верх-право], [b], [c],
  ),
  caption: [Комірка з координатами],
)
#figure(
  table(
    columns: 2,
    stroke: none,
    table.hline(y: 1), [a], [b], [c], [d],
  ),
  caption: [hline],
)
#figure(table(columns: 2, fill: (_, y) => if calc.odd(y) { luma(220) }, ..rows(6)), caption: [Смуги])
#figure(
  table(
    columns: 2,
    row-gutter: 8pt,
    [a], [b],
    [c], [d],
  ),
  caption: [row-gutter],
)
#figure(
  table(
    columns: 2,
    [a], [b],
    table.footer([Σ], [1]),
  ),
  caption: [Футер],
)
#figure(
  table(
    columns: 2,
    [a], [b],
  ),
  caption: [Інший supplement],
  supplement: [Табл.],
)
#figure(table(
  columns: 2,
  [a], [b],
))
#[
  #set table(align: right, fill: luma(240))
  #figure(
    table(
      columns: (5cm, 5cm),
      [право], [право],
    ),
    caption: [set table],
  )
]
#lorem(10)
#figure(
  table(
    columns: 2,
    [a], [b],
  ),
  caption: [Плаваюча],
  placement: top,
)

#context {
  // floating figures are left as they are, without markers
  assert.eq(query(figure.where(kind: table)).len(), 14)
  assert.eq(query(metadata).filter(m => type(m.value) == str and m.value.starts-with("dstu-table-start-")).len(), 13)
}
#context [Підсумки: #doc-stats()]

#show: style.appendices
= Додаток
#figure(table(columns: 2, ..rows(150)), caption: [У додатку]) <app>
Див. @app.
#context {
  let (start, end) = spans(13) // the floating table gets no markers
  assert(end > start)
  assert.eq(style.appendix-index.get(), 1)
}
