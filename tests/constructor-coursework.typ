// Same document as coursework.typ, assembled from parts; must render identically.
#import "../src/lib.typ": *

#let data = toml("fixtures/data.toml")
#let w = work(
  university: data.university,
  subject: data.subject,
  title: data.title,
  authors: data.authors,
  mentors: data.mentors,
  initial-date: datetime(year: 2024, month: 9, day: 15),
  done-date: datetime(year: 2024, month: 12, day: 27),
)

#set document(..w.document)
#show: style.dstu.with(skip: 1)

#cw.title-page(w)
#cw.task(w, source: [Test source data.], content: [Test report contents.], graphics: [Test graphics.])
#cw.calendar-plan(w, table(
  columns: 4,
  [№], [Етап], [Строк], [Примітка],
  [1], [Аналіз], [01.09--15.09], [виконано],
  [2], [Реалізація], [16.09--15.10], [виконано],
))
#cw.abstract(w, keywords: ("типст", "шаблон", "тестування"))[
  Тестовий реферат для перевірки курсового шаблону.
]
#cw.contents()

= Test chapter
#lorem(80)

#dstu-bibliography(bytes(read("fixtures/bibl.yml")), style: "3008")

#show: style.appendices
= Додатки\ Тестовий додаток.
