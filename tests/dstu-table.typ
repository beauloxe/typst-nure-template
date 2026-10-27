// dstu-table is a shorthand for figure(table(...)); must render exactly like
// constructor-dstu-table.typ. `tag:` is the pre-0.3 way to set the label.
#import "../src/lib.typ": *
#show: style.dstu

= Розділ
#dstu-table(
  caption: [Результати вимірювань],
  columns: (1fr, 2fr, 2fr),
  header: ([№], [Напруга, В], [Струм, мА]),
  tag: "measurements",
  align: center,
  ..range(150).map(i => [#i]),
)
#dstu-table(caption: [Коротка], columns: 2, header: ([A], [B]), label: <short>, [1], [2])

Див. @measurements і @short[таблицю].
