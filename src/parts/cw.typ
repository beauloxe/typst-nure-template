#import "../helpers.typ": *
#import "../utils.typ": bold, hfill, uline
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

  uline[#w.uni.name]

  linebreak()
  linebreak()

  grid(
    columns: (100pt, 1fr),
    bold[
      Кафедра
      Дисципліна
      Спеціальність
    ],
    {
      uline(align: left, w.edu.department-gen)
      linebreak()
      uline(align: left, w.subject-name)
      linebreak()
      uline(align: left, [#w.edu.code #w.edu.name-long])
    },
  )
  grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 0.3fr,
    [#bold[Курс] #uline(course)], [#bold[Група] #uline(group-form(author))], [#bold[Семестр] #uline(semester)],
  )

  linebreak()
  linebreak()
  linebreak()

  align(center, bold[ЗАВДАННЯ \ на курсову роботу студента])

  linebreak()

  uline(align: left)[_#full-name-gen _]

  linebreak()
  linebreak()

  bold[\1. Тема роботи:]
  uline[#w.title.]

  linebreak()

  {
    bold[\2. Строк здачі закінченої роботи:]
    uline(done-date.display("[day].[month].[year]"))
    hfill(10fr)
  }

  linebreak()

  bold[\3. Вихідні дані для роботи:]
  uline(source)

  linebreak()

  bold[\4. Зміст розрахунково-пояснювальної записки:]
  uline(content)

  linebreak()

  bold[\5. Перелік графічного матеріалу:]
  uline(graphics)

  linebreak()

  {
    bold[\6. Дата видачі завдання:]
    uline(initial-date.display("[day].[month].[year]"))
    hfill(10fr)
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
    grid(
      columns: (1fr, 2fr, 1fr),
      gutter: 0.2fr,
      [
        Студент \
        Керівник \
        #align(center)["#underline[#approval-date.day()]"]
      ],
      [
        #uline(align: center, []) \
        #uline(align: center, []) \
        #uline(align: center, month-gen(approval-date.month()))
      ],
      [
        \ \
        #underline[#approval-date.year()] р.
      ],
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
