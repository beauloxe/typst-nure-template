#import "../../helpers.typ": gender-form, gender-get, group-form, is-empty, key-get, pz-lb-title
#import "../base.typ": title-page as base-title-page

// Default content for each `title-page` slot, specific to the NURE layout.
// Builders are standalone so they can be reused or overridden individually;
// all of them take the dictionary returned by `work`.

#let default-header(w) = [
  #upper([Міністерство освіти і науки України\ #w.uni.name]) \ \
  Кафедра #w.edu.department-gen \ \ \
]

#let default-info(w) = [
  #pz-lb-title(w.type, number: w.number)\
  з дисципліни: "#w.subject-name"\
  #if w.title != none [з теми: "#w.title"]
]

#let default-credentials(w) = {
  let (authors, mentors) = (w.authors, w.mentors)
  let variant = authors.first().at("variant", default: none)

  columns(2, {
    set align(left)
    set par(first-line-indent: 0pt)

    [#gender-form("author", gender: gender-get(authors)):\ ]
    for a in authors { [ст. гр. #group-form(a)\ #a.name\ ] }
    if not is-empty(variant) [Варіант: №#variant]

    colbreak()
    set align(right)

    [#gender-form("mentor", gender: gender-get(mentors)):\ ]
    for m in mentors {
      let degree = key-get(m, "degree")
      if degree != none [#degree\ ]
      [#m.name\ ]
    }
  })
}

#let default-footer(w) = [Харків -- #w.year]

/// Макет ХНУРЕ титулки звіту з практичної/лабораторної.
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
