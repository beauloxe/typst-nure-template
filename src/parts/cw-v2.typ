#import "../helpers.typ": *
#import "../utils.typ": bold, filled-lines, hfill, uline
#import "forms.typ": *
#import "common.typ": contents as base-contents, doc-stats, sort-keywords

// Parts of a complex coursework project explanatory note (NURE, new form).
// Every part takes the dictionary returned by `work` and is a whole page.

#let required(w, key, part) = {
  let value = w.at(key)
  assert(value != none and value != (), message: "cw-v2." + part + ": work(" + key + ": ...) is required")
  value
}

/// Титульна сторінка. Члени комісії за замовчуванням -- усі викладачі, крім першого.
#let title-page(w) = {
  let author = w.authors.first()
  let head-mentor = required(w, "mentors", "title-page").first()
  let commission-members = if w.committee-members == none {
    w.mentors.slice(1)
  } else {
    w.committee-members
  }

  let group-name = group-form(author)
  let author-display-name = author.at("display-name", default: author.name)
  let mentor-display-name = head-mentor.at("display-name", default: head-mentor.name)
  let mentor-degree = head-mentor.at("degree", default: "")

  [
    #set par(first-line-indent: 0pt, justify: false, leading: 0.45em)

    #set text(size: 14pt)
    #set align(center)
    МІНІСТЕРСТВО ОСВІТИ І НАУКИ УКРАЇНИ\
    #w.uni.name

    #v(0.7em)

    #set align(left)
    #inline-label-line(
      [Факультет],
      w.faculty,
    )
    #note([(повна назва)])

    #v(0.8em)
    #inline-label-line(
      [Кафедра],
      lower(w.edu.department-gen),
    )
    #note([(повна назва)])

    #v(1.8em)

    #set align(center)
    #text(size: 20pt, weight: "bold")[КОМПЛЕКСНИЙ КУРСОВИЙ ПРОЄКТ]\
    #text(size: 20pt, weight: "bold")[Пояснювальна записка]

    #v(0.9em)

    #set align(left)
    #label-line([рівень вищої освіти], w.education-level, label-width: 120pt)

    #v(1.0em)
    #title-field(w.title)

    #v(3em)

    #grid(
      columns: (0.36fr, 0.64fr),
      [],
      [
        #gender-form("author", gender: author.gender):\
        здобувач #underline([#author.course]) курсу, групи #underline(group-name)\
        #uline(align: center, author-display-name)
        #note[(Власне ім'я, ПРІЗВИЩЕ)]

        #v(0.2em)
        #inline-label-line([Спеціальність], [#w.edu.code -- #w.edu.name-long])
        #note[(код і повна назва спеціальності)]
        #inline-label-line([Тип програми], w.program-type)
        #inline-label-line([Освітня програма], w.program-name)
        #note[(повна назва освітньої програми)]

        #v(0.3em)
        #inline-label-line([Керівник], [#mentor-degree #mentor-display-name])
        #note[(посада, Власне ім'я, ПРІЗВИЩЕ)]

        #v(0.3em)
        #pad(left: 75pt)[
          #set par(first-line-indent: 0pt)
          Члени комісії (#text(size: 10pt)[Власне ім'я, ПРІЗВИЩЕ, підпис])
          #v(0.15em)
          #commission-lines(commission-members)
        ]
      ],
    )

    #v(1fr)

    #set align(center)
    #w.year р.

    #pagebreak()
  ]
}

/// Сторінка завдання. Бере `done-date` з `work`.
/// - source (content, array): Вихідні дані; масив розбивається на підкреслені рядки
/// - content (content, array): Питання для опрацювання; масив розбивається на підкреслені рядки
#let task(w, source: [], content: []) = {
  let author = w.authors.first()
  let done-date = required(w, "done-date", "task")
  let group-name = group-form(author)
  let author-full-name-dat = author.at("full-name-dat", default: author.full-name-gen)

  [
    #set par(first-line-indent: 0pt, justify: false)
    #align(center)[#w.uni.name]

    #v(1.1em)
    #task-head-fields((
      (
        [Факультет],
        (
          w.faculty,
        ),
      ),
      ([Кафедра], lower(w.edu.department-gen)),
      ([Рівень вищої освіти], w.education-level),
      ([Спеціальність], [#w.edu.code -- #w.edu.name-long]),
      ([Тип програми], w.program-type),
      ([Освітня програма], w.program-name),
    ))
    #note[(шифр і назва)]

    #v(1.7em)
    #grid(
      columns: (1.1fr, 1.1fr, 1.1fr, 1.7fr, 1.3fr, 1.1fr),
      gutter: 0pt,
      align: center + horizon,
      [Курс], uline(author.course), [Група], uline(group-name), [Семестр], uline(author.semester),
    )

    #v(2.6em)

    #align(center)[
      #bold[ЗАВДАННЯ]\
      #text(style: "italic", weight: "bold")[на курсовий проєкт (роботу) студента]
    ]

    #v(1.0em)

    #label-line([здобувачеві], author-full-name-dat, caption: [(прізвище, ім'я, по батькові)], label-width: 95pt)

    #v(1.0em)

    #task-num(1) Тема роботи #uline(align: left, filled-lines(w.title))

    #v(0.4em)
    #task-num(2) Термін здачі студентом закінченої роботи
    “#underline(done-date.display("[day]"))” #underline(month-gen(done-date.month())) #done-date.display("[year]")р.

    #v(0.4em)
    #task-num(3) Вихідні дані до проєкту #uline(align: left, filled-lines(source))
    #v(0.4em)
    #uline(align: left, [])

    #v(0.4em)
    #task-num(4) Перелік питань, що потрібно опрацювати в роботі\
    #uline(align: left, filled-lines(content))
    #v(0.4em)
    #uline(align: left, [])

    #pagebreak()
  ]
}

/// Календарний план з підписами. Бере `initial-date` з `work`.
/// - plan-table (content): Таблиця плану
#let calendar-plan(w, plan-table) = {
  let head-mentor = required(w, "mentors", "calendar-plan").first()
  let initial-date = required(w, "initial-date", "calendar-plan")
  let mentor-display-name = head-mentor.at("display-name", default: head-mentor.name)
  let mentor-degree = head-mentor.at("degree", default: "")

  [
    #align(center, bold[КАЛЕНДАРНИЙ ПЛАН])
    #set par(first-line-indent: 0pt)

    #v(1.4em)

    #plan-table

    #v(5.0em)

    Дата видачі завдання “#underline(initial-date.display("[day]"))” #underline(month-gen(initial-date.month())) #initial-date.display("[year]") р.

    #v(1.4em)

    Здобувач #underline([#hfill(6cm)])
    #note[(підпис) #h(8cm)]

    #v(1.4em)

    Керівник роботи #uline(align: center, []) #h(1cm) #underline[#mentor-degree #mentor-display-name]
    #note[(підпис) #h(4.5cm) (посада, Власне ім'я, ПРІЗВИЩЕ)]

    #pagebreak()
  ]
}

/// Реферат: підсумки документа, ключові слова і текст, за потреби з
/// англійською версією: `#abstract(w, keywords: ...)[Текст][Text]`.
///
/// - keywords (array): Ключові слова, сортуються автоматично; рядки або
///   пари (укр, англ)
/// - en-keywords (array): Англійські ключові слова в тому ж порядку, що й `keywords`,
///   якщо ті -- звичайні рядки
/// - ..body (content): Текст реферату, за потреби й англійський після нього
#let abstract(w, keywords: (), en-keywords: none, ..body) = {
  let (body, en-body) = (body.pos().at(0), body.pos().at(1, default: none))

  let keyword-pairs = if keywords.len() > 0 and type(keywords.first()) == array {
    keywords.map(pair => (uk: pair.at(0), en: pair.at(1)))
  } else if en-keywords != none {
    keywords.enumerate().map(((i, uk)) => (uk: uk, en: en-keywords.at(i)))
  } else {
    keywords.map(uk => (uk: uk))
  }
  let sorted-keyword-pairs = sort-keywords(keyword-pairs, key: pair => pair.uk)

  [
    #let header = if en-body != none {
      bold[РЕФЕРАТ / ABSTRACT]
    } else {
      bold[РЕФЕРАТ]
    }
    #align(center, header) \

    Пояснювальна записка містить: #doc-stats().

    \

    #(sorted-keyword-pairs.map(pair => upper(pair.uk)).join(", "))

    \

    #body

    #if en-body != none [
      \

      #(sorted-keyword-pairs.map(pair => upper(pair.at("en", default: ""))).join(", "))

      \

      #en-body
    ]
  ]
}

/// Зміст, де додатки подано як "Додаток А Назва".
#let contents() = base-contents(compact-appendices: true)
