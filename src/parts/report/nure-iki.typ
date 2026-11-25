#import "../../helpers.typ": gender-form, gender-get, group-form, is-empty, key-get
#import "../../utils.typ": bold, hfill, ruled-field
#import "../base.typ": title-page as base-title-page
#import "../forms.typ": inline-label-line

#let caption(body) = {
  v(2pt)
  align(center, text(size: 10pt, body))
}

#let header-field(label, value, hint) = {
  set par(first-line-indent: 0pt, justify: false)
  block(width: 100%, spacing: 0pt)[
    #place(top + center, value)
    #grid(
      columns: (auto, 1fr),
      column-gutter: 0.3em,
      align: bottom,
      pad(bottom: 0.15em, label), line(length: 100%, stroke: 0.5pt),
    )
  ]
  caption(hint)
}

#let report-title(type, number: none) = {
  let type-title = (
    "ЛБ": [ЗВІТ\ з лабораторної роботи],
    "ПЗ": [ЗВІТ\ з практичного заняття],
    "КР": [КОНТРОЛЬНА РОБОТА],
    "ІДЗ": [ІНДИВІДУАЛЬНЕ ДОМАШНЄ ЗАВДАННЯ],
  ).at(type, default: type)
  if not is-empty(number) { [#type-title №#number] } else { [#type-title] }
}

#let default-header(w) = [
  #set par(first-line-indent: 0pt, justify: false, leading: 0.45em)
  Міністерство освіти і науки України\
  #w.uni.name

  #v(1.6em)

  #align(left)[
    #header-field([Факультет], w.faculty, [(повна назва)])
    #v(0.7em)
    #header-field([Кафедра], w.edu.department-gen, [(повна назва)])
  ]

  #v(2.4em)
]

#let default-info(w) = {
  let variant = w.authors.first().at("variant", default: none)
  let title = if type(w.title) == array { w.title.join() } else { w.title }

  [
    #set par(first-line-indent: 0pt, justify: false, leading: 0.45em)
    #text(size: 20pt, weight: "bold")[#report-title(w.type, number: w.number)]

    #if w.subject-name != none [
      #v(1.2em)
      з дисципліни\
      #bold(w.subject-name)
    ]

    #if title != none [
      #v(1.0em)
      Тема заняття: #title
    ]

    #if not is-empty(variant) [
      #v(0.8em)
      Варіант №#variant
    ]
  ]
}

#let default-credentials(w) = grid(
  columns: (0.35fr, 0.65fr),
  [],
  align(left)[
    #set par(first-line-indent: 0pt, justify: false, leading: 0.45em)
    #set block(above: 0pt, below: 0pt)

    #block(below: 0.45em)[#gender-form("author", gender: gender-get(w.authors)):]
    #for (i, a) in w.authors.enumerate() {
      if i > 0 { v(0.6em) }
      let course = key-get(a, "course")
      let student-prefix = if course != none [
        студент #underline(stroke: 0.5pt, offset: 0.25em)[#hfill(0.4em)#course#hfill(0.4em)] курсу, групи
      ] else [
        студент групи
      ]
      inline-label-line(student-prefix, align(center, group-form(a)))
      v(0.5em)
      ruled-field(align(center, a.name))
    }
    #caption[(прізвище, ініціали)]

    #v(2.0em)

    #let mentor-label = [#gender-form("mentor", gender: gender-get(w.mentors)):]
    #if w.mentors.len() == 0 {
      inline-label-line(mentor-label, [])
      v(0.5em)
      ruled-field([])
    } else {
      for (i, m) in w.mentors.enumerate() {
        let degree = key-get(m, "degree")
        if i == 0 {
          if degree != none {
            inline-label-line(mentor-label, align(center, degree))
            v(0.5em)
            ruled-field(align(center, m.name))
          } else {
            inline-label-line(mentor-label, align(center, m.name))
          }
        } else {
          v(0.6em)
          if degree != none {
            ruled-field(align(center, degree))
            v(0.5em)
          }
          ruled-field(align(center, m.name))
        }
      }
    }
    #caption[(посада, прізвище, ініціали)]
  ],
)

#let default-footer(w) = [
  #set par(first-line-indent: 0pt, justify: false)
  #w.year р.
]

/// Макет "nure-iki" титулки звіту з практичної/лабораторної за методичними
/// рекомендаціями кафедри інфокомунікаційної інженерії ім. В. В. Поповського (2024).
///
/// Усі слоти за замовчуванням `auto`, тобто вміст відповідної функції
/// `default-*`; передайте свій вміст, щоб замінити слот, або `none`, щоб
/// лишити його порожнім.
#let title-page(w, header: auto, info: auto, credentials: auto, footer: auto) = base-title-page(
  if header == auto { default-header(w) } else { header },
  if info == auto { default-info(w) } else { info },
  if credentials == auto { default-credentials(w) } else { credentials },
  if footer == auto { default-footer(w) } else { footer },
)
