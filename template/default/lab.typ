#import "@local/nure:0.3.0": *

#import style: spacing

// 1. Описуємо роботу один раз; усі блоки нижче беруть дані звідси.
//    (або тримаємо дані у файлі: `#let w = work(..toml("doc.toml"))`)
#let w = work(
  university: "ХНУРЕ",
  subject: "СМП",
  type: "ЛБ",
  number: 2,
  title: "Потiк керування та алгоритмічні структури Bash",
  mentors: (
    (name: "Шевченко Т. Г.", degree: "Доцент кафедри ПІ", gender: "m"),
    (name: "Франко І. Я.", degree: "Асистент кафедри ПІ", gender: "m"),
  ),
  authors: (
    (
      name: "Косач Л. П.",
      full-name-gen: "Косач Лариси Петрівни",
      edu-program: "КУІБ",
      group: "23-2",
      gender: "f",
      course: 2,
      semester: 4,
      variant: 8,
    ),
  ),
)

// 2. Метадані документа і стилі ДСТУ.
#set document(..w.document)
#show: style.dstu.with(skip: 1)

// 3. Збираємо документ з блоків.
//    Будь-який слот титулки можна замінити, напр. `footer: [Харків -- 2026]`,
//    або взяти інший макет: `layout: "complex"`.
#report.title-page(w)
#title-heading(w)

#v(-spacing)

== Мета роботи
#lorem(100)

== Хід роботи
#v(-spacing)
=== Підготовка
#lorem(150)

// Рисунки (`fig` = `dstu-figure`): назву файлу обгортаємо в `path()`, бо рядок шукався б у пакунку
// #fig(path("figures/scheme.png"), [Схема дослідження], label: <scheme>) // посилання @scheme
// Таблиці (`tab` = `dstu-table`)
// #tab(caption: [Результати], columns: 2, header: ([Дослід], [Час, с]), label: <results>, [1], [0.42])

=== Виконання дослідження
#lorem(300)

=== Підрахунок результатів
#lorem(250)

== Висновки
#lorem(100)

== Контрольні запитання
#lorem(100):
- #lorem(20);
- #lorem(30);
- #lorem(15);
- #lorem(25);
- #lorem(42);
- #lorem(27).

#show: style.appendices

= Quote
#link("https://youtu.be/bJQj1uKtnus")[
  The art isn't the art, the art is never the art,
  the art is the thing that happens inside you when you make it and the feeling in the heart of the beholder.
]


= Приклад звіту 1
#v(-spacing)
== Частина 1
#lorem(100)
== Частина 2
#lorem(200)

= Приклад звіту 2
#lorem(200)

= Приклад звіту 3
#lorem(200)
