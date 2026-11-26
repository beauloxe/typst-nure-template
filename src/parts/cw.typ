#import "../helpers.typ": *
#import "../utils.typ": bold, ruled-field
#import "forms.typ": form-field
#import "common.typ": contents as base-contents, doc-stats, require-field, require-work, sort-keywords

// Parts of a coursework explanatory note (NURE). Every part takes the
// dictionary returned by `work` and is a whole page (or several).

/// Титульна сторінка.
#let title-page(w) = {
  let author = w.authors.first()
  let head-mentor = require-work(w, "mentors", "cw.title-page").first()
  let head-degree = key-get(head-mentor, "degree")

  [
    #set align(center)
    МІНІСТЕРСТВО ОСВІТИ І НАУКИ УКРАЇНИ\
    #upper(w.uni.name)

    \

    Кафедра #w.edu.department-gen

    \

    ПОЯСНЮВАЛЬНА ЗАПИСКА\
    ДО КУРСОВОЇ РОБОТИ\
    з дисципліни: "#w.subject-name"\
    Тема роботи: "#w.title"

    \ \ \

    #columns(2, gutter: 4cm)[
      #set align(left)
      #set par(first-line-indent: 0pt)

      #gender-form("author", gender: author.at("gender", default: none)) ст. гр. #group-form(author)

      \
      Керівник:#if head-degree != none [\ #head-degree]

      \
      Робота захищена на оцінку

      \
      Комісія:\ #for m in w.mentors {
        let degree = key-get(m, "degree")
        if degree != none [#degree\ ]
      }

      #colbreak()
      #set align(left)


      #author.name

      \ \
      #head-mentor.name

      \
      #underline(" " * 35)

      \ \
      #for m in w.mentors [#m.name\ ]
    ]

    #v(1fr)

    #if w.city != none [#w.city -- ]#w.year

    #pagebreak()
  ]
}

/// Сторінка завдання. Бере `initial-date` і `done-date` з `work`.
/// - source (content): Вихідні дані до роботи
/// - content (content): Зміст розрахунково-пояснювальної записки
/// - graphics (content): Перелік графічного матеріалу
#let task(w, source: [], content: [], graphics: []) = {
  let author = w.authors.first()
  let done-date = require-work(w, "done-date", "cw.task")
  let initial-date = require-work(w, "initial-date", "cw.task")
  let course = require-field(author, "course", "author", "cw.task")
  let semester = require-field(author, "semester", "author", "cw.task")
  let full-name-gen = require-field(author, "full-name-gen", "author", "cw.task")

  {
    set par(first-line-indent: 0pt, justify: false)

    ruled-field(align(center, w.uni.name))

    v(1.2em)

    grid(
      columns: (100pt, 1fr),
      row-gutter: 0.55em,
      align: top,
      bold[Кафедра], ruled-field(w.edu.department-gen),
      bold[Дисципліна], ruled-field(w.subject-name),
      bold[Спеціальність], ruled-field([#w.edu.code #w.edu.name-long]),
    )

    v(0.8em)

    grid(
      columns: (auto, 1fr, auto, 1.6fr, auto, 1fr),
      column-gutter: 0.5em,
      align: bottom,
      bold[Курс], form-field(course), bold[Група], form-field(group-form(author)), bold[Семестр], form-field(semester),
    )

    v(2.0em)

    align(center, bold[ЗАВДАННЯ \ на курсову роботу студента])

    v(0.8em)

    ruled-field[_#full-name-gen _]

    v(1.2em)

    ruled-field(prefix: bold[\1. Тема роботи:], [#w.title.])
    v(0.6em)

    grid(
      columns: (auto, 4cm),
      column-gutter: 0.4em,
      align: bottom,
      bold[\2. Строк здачі закінченої роботи:], form-field(done-date.display("[day].[month].[year]")),
    )
    v(0.6em)

    ruled-field(prefix: bold[\3. Вихідні дані для роботи:], source)
    v(0.6em)

    ruled-field(prefix: bold[\4. Зміст розрахунково-пояснювальної записки:], content)
    v(0.6em)

    ruled-field(prefix: bold[\5. Перелік графічного матеріалу:], graphics)
    v(0.6em)

    grid(
      columns: (auto, 4cm),
      column-gutter: 0.4em,
      align: bottom,
      bold[\6. Дата видачі завдання:], form-field(initial-date.display("[day].[month].[year]")),
    )
  }

  pagebreak()
}

/// Календарний план.
/// - plan-table (content): Таблиця плану
/// - approval-date (datetime): Дата затвердження, за замовчуванням `done-date`
#let calendar-plan(w, plan-table, approval-date: auto) = {
  let author = w.authors.first()
  let head-mentor = require-work(w, "mentors", "cw.calendar-plan").first()
  let head-degree = key-get(head-mentor, "degree")
  let approval-date = if approval-date == auto { require-work(w, "done-date", "cw.calendar-plan") } else {
    approval-date
  }

  align(center, bold[КАЛЕНДАРНИЙ ПЛАН])
  set par(first-line-indent: 0pt)

  linebreak()

  plan-table

  linebreak()

  grid(
    columns: (5fr, 5fr),
    column-gutter: 0.8em,
    grid(
      columns: (auto, 1fr, auto),
      column-gutter: 0.4em,
      row-gutter: 0.6em,
      align: bottom,
      [Студент], form-field([]), [],
      [Керівник], form-field([]), [],
      align(center)["#underline[#approval-date.day()]"],
      form-field(month-gen(approval-date.month())),
      [#underline[#approval-date.year()] р.],
    ),
    [
      #author.name, \
      #if head-degree != none [#head-degree ]#head-mentor.name.
    ],
  )

  pagebreak()
}

/// Реферат: підсумки документа, ключові слова і текст.
/// - keywords (array): Ключові слова, сортуються автоматично
/// - body (content): Текст реферату
#let abstract(w, keywords: (), body) = [
  #align(center, bold[РЕФЕРАТ]) \

  Пояснювальна записка до курсової роботи: #doc-stats().

  \

  #sort-keywords(keywords.map(upper)).join(", ")

  \
  #body
]

/// Зміст.
#let contents(..args) = base-contents(..args)
