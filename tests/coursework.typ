#import "../src/lib.typ": coursework

#let data = toml("fixtures/data.toml")
#let author = data.authors.first()

#let task = (
  done-date: datetime(year: 2024, month: 12, day: 27),
  initial-date: datetime(year: 2024, month: 9, day: 15),
  source: [Test source data.],
  content: [Test report contents.],
  graphics: [Test graphics.],
)

#let calendar = (
  plan-table: table(
    columns: 4,
    [№], [Етап], [Строк], [Примітка],
    [1], [Аналіз], [01.09--15.09], [виконано],
    [2], [Реалізація], [16.09--15.10], [виконано],
  ),
  approval-date: datetime(year: 2024, month: 12, day: 27),
)

#let abstract = (
  keywords: ("типст", "шаблон", "тестування"),
  text: [Тестовий реферат для перевірки курсового шаблону.],
)

#show: coursework.with(
  university: data.university,
  subject: data.subject,
  title: data.title,
  authors: data.authors,
  mentors: data.mentors,
  task-list: task,
  calendar-plan: calendar,
  abstract: abstract,
  bib-path: bytes(read("fixtures/bibl.yml")),
  appendices: [= Додатки\ Тестовий додаток.],
)

= Test chapter
#lorem(80)
