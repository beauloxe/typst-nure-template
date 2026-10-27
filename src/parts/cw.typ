#import "../helpers.typ": *
#import "../utils.typ": bold, hfill, uline
#import "common.typ": contents as base-contents, doc-stats, sort-keywords

// Parts of a coursework explanatory note (NURE). Every part takes the
// dictionary returned by `work` and is a whole page (or several).

#let required-date(w, key, part) = {
  let date = w.at(key)
  assert(date != none, message: "cw." + part + ": work(" + key + ": ...) is required")
  date
}

/// Титульна сторінка.
#let title-page(w) = {
  let author = w.authors.first()
  let head-mentor = w.mentors.first()

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

      #gender-form("author", gender: author.gender) ст. гр. #group-form(author)

      \
      Керівник:\ #head-mentor.degree

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

    Харків -- #w.year

    #pagebreak()
  ]
}

/// Сторінка завдання. Бере `initial-date` і `done-date` з `work`.
/// - source (content): Вихідні дані до роботи
/// - content (content): Зміст розрахунково-пояснювальної записки
/// - graphics (content): Перелік графічного матеріалу
#let task(w, source: [], content: [], graphics: []) = {
  let author = w.authors.first()
  let done-date = required-date(w, "done-date", "task")
  let initial-date = required-date(w, "initial-date", "task")

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
    [#bold[Курс] #uline(author.course)],
    [#bold[Група] #uline([#author.edu-program\-#author.group])],
    [#bold[Семестр] #uline(author.semester)],
  )

  linebreak()
  linebreak()
  linebreak()

  align(center, bold[ЗАВДАННЯ \ на курсову роботу студента])

  linebreak()

  uline(align: left)[_#author.full-name-gen _]

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
  let head-mentor = w.mentors.first()
  let approval-date = if approval-date == auto { required-date(w, "done-date", "calendar-plan") } else {
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
      #head-mentor.degree
      #head-mentor.name.
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
#let contents() = base-contents()
