#import "../src/lib.typ": coursework-v2

#let data = toml("fixtures/data.toml")
#let task = (
  done-date: datetime(year: 2024, month: 12, day: 27),
  initial-date: datetime(year: 2024, month: 9, day: 15),
  source: ([Test source.], [Additional source.]),
  content: ([Test content.], [Additional content.]),
)
#let calendar = (
  plan-table: table(
    columns: 4,
    [№], [Етап], [Строк], [Примітка],
    [1], [Аналіз], [], [виконано],
    [2], [Реалізація], [], [виконано],
  ),
)
#let abstract = (
  keywords: (("тест", "TEST"), ("типст", "TYPST")),
  text: [Тестовий реферат нового варіанта курсового шаблону.],
)
#let committee = (
  (name: "Сосюра В. М.", degree: "Доц."),
  (name: "Симоненко В. А.", degree: "Ст. викл."),
)

#show: coursework-v2.with(
  university: data.university,
  title: (data.title,),
  authors: data.authors,
  mentors: data.mentors,
  committee-members: committee,
  task-list: task,
  calendar-plan: calendar,
  abstract: abstract,
  abstract-en: (keywords: ("test",), text: [English abstract.]),
  bib-path: bytes(read("fixtures/bibl.yml")),
  appendices: [= Додатки\ Тестовий додаток.],
)

= Test chapter
#lorem(80)
