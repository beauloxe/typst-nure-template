// Перевірка лінтера (`src/lint.typ`): кожне порушення позначене поруч
// `#expect("правило")`, і CI звіряє набір пар «правило, сторінка» з тим, що
// знайшов `lint.run()`. Рядки без `expect` -- випадки, на яких лінтер
// мовчати повинен.

#import "../src/lib.typ": cw, style, tab, utils

#let expect(rule) = [#metadata(rule) <lint-expect>]

#show: style.dstu

// --- Сторінка 1: реферат, заголовки
#cw.abstract((:), keywords: ("один", "два"))[Реферат з двома ключовими словами.]
#expect("keywords-count")

= Вступ
#expect("heading-numbered")
Вступ із номером.

#utils.nheading[Висновки]
Ненумерований структурний елемент -- без зауважень.

= Розділ з крапкою.
#expect("heading-period")

== мала літера
#expect("heading-case")
Текст.

== HTTP запити
Абревіатура на початку -- без зауважень.

= Розділ з одним підрозділом

== Єдиний підрозділ
#expect("heading-single")
Текст.

#pagebreak()
// --- Сторінка 2: рисунки
Посилання на @f-ok і @f-lower стоять раніше за рисунки.

#figure(rect(), caption: [Добрий рисунок]) <f-ok>

#figure(rect(), caption: [мала літера в назві]) <f-lower>
#expect("caption-case")

#figure(rect(), caption: [Без посилання])
#expect("figure-unreferenced")

#figure(rect(), caption: [Раніше за посилання]) <f-early>
#expect("figure-before-ref")
Посилання на @f-early.

Рисунок без назви (@f-no-caption) -- без зауважень, назва необов'язкова.

#figure(rect()) <f-no-caption>

#pagebreak()
// --- Сторінка 3: таблиці на одній сторінці
Таблиці @t-ok, @t-case, @t-period і @t-side.

#tab(caption: [Добра], columns: 2, header: ([Назва], [Час, с]), label: <t-ok>, [a], [1])

#tab(caption: [Регістр], columns: 2, header: ([Назва], [час]), label: <t-case>, [a], [1])
#expect("table-header-case")

#tab(caption: [Крапка], columns: 2, header: ([Назва], [Час, с.]), label: <t-period>, [a], [1])
#expect("table-header-period")

#figure(
  table(
    columns: 3,
    [$L$, мкГн], [10], [30],
    [$C$, пФ], [15], [5],
  ),
  caption: [Лише боковик на одній сторінці -- без зауважень],
) <t-side>

#tab(caption: [Без посилання], columns: 2, header: ([А], [Б]), [a], [1])
#expect("table-unreferenced")

#pagebreak()
// --- Сторінки 4--5: таблиці з переносом
Таблиці @t-long і @t-long-header.

#expect("table-no-header")
#figure(
  table(columns: 2, ..range(80).map(i => [#i])),
  caption: [Довга без головки],
) <t-long>

#tab(
  caption: [Довга з головкою],
  columns: 2,
  header: ([А], [Б]),
  label: <t-long-header>,
  ..range(80).map(i => [#i]),
)

#pagebreak()
// --- Сторінка 6: переліки й виноски
Перелік:
#expect("list-case")
#expect("list-punct")
- Велика літера;
- мала літера;
- HTTP -- абревіатура;
- без крапки

Вкладений перелік -- без зауважень:
- перший рівень:
  + другий рівень;
  + ще один.
- кінець.

Виноски#footnote[Перша.] <fn>
#footnote[Друга.]
#footnote[Третя.]
#footnote[Четверта.]
#footnote(<fn>) -- повторне посилання нової виноски не створює.

#expect("footnote-count")
І ще#footnote[П'ята.] #footnote[Шоста.]

#pagebreak()
Додатки: спершу @app-b, потім @app-a.

#show: style.appendices

= Перший <app-a>
Текст.

= Другий <app-b>
#expect("appendix-order")
Текст.

= Без посилання
#expect("appendix-unreferenced")
Текст.
