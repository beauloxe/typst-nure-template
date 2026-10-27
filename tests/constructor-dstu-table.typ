// The same document as dstu-table.typ, written with plain figure(table(...)).
#import "../src/lib.typ": *
#show: style.dstu

= Розділ
#figure(
  table(
    columns: (1fr, 2fr, 2fr),
    align: center,
    table.header([№], [Напруга, В], [Струм, мА]),
    ..range(150).map(i => [#i]),
  ),
  caption: [Результати вимірювань],
) <measurements>
#figure(
  table(
    columns: 2,
    table.header([A], [B]),
    [1], [2],
  ),
  caption: [Коротка],
) <short>

Див. @measurements і @short[таблицю].
