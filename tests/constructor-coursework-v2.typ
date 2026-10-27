// Same document as coursework-v2.typ, assembled from parts; must render identically.
#import "../src/lib.typ": *

#let data = toml("fixtures/data.toml")
#let w = work(
  university: data.university,
  title: (data.title,),
  authors: data.authors,
  mentors: data.mentors,
  committee-members: (
    (name: "Сосюра В. М.", degree: "Доц."),
    (name: "Симоненко В. А.", degree: "Ст. викл."),
  ),
  initial-date: datetime(year: 2024, month: 9, day: 15),
  done-date: datetime(year: 2024, month: 12, day: 27),
)

#set document(..w.document)
#show: style.dstu.with(skip: 1)

#cw-v2.title-page(w)
#cw-v2.task(w, source: ([Test source.], [Additional source.]), content: ([Test content.], [Additional content.]))
#cw-v2.calendar-plan(w, table(
  columns: 4,
  [№], [Етап], [Строк], [Примітка],
  [1], [Аналіз], [], [виконано],
  [2], [Реалізація], [], [виконано],
))
#cw-v2.abstract(w, keywords: (("тест", "TEST"), ("типст", "TYPST")))[
  Тестовий реферат нового варіанта курсового шаблону.
][
  English abstract.
]
#cw-v2.contents()

= Test chapter
#lorem(80)

#dstu-bibliography(bytes(read("fixtures/bibl.yml")), style: "8302")

#show: style.appendices
= Додатки\ Тестовий додаток.
