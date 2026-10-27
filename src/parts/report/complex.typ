#import "../../helpers.typ": gender-form, gender-get, group-form, is-empty, key-get, pz-lb-title
#import "../base.typ": title-page as base-title-page

// Default content for each `title-page` slot, specific to the complex layout.
// Builders are standalone so they can be reused or overridden individually;
// all of them take the dictionary returned by `work`.

#let default-header(w) = [
  Міністерство освіти і науки України\
  #w.uni.name

  \
  #set par(first-line-indent: 0pt)
  #align(left)[
    Кафедра #underline(w.edu.department-gen) \
    Спеціальність #underline([#w.edu.code #w.edu.at("description", default: "")]) \
    Освітня програма #underline(w.edu.name-long) \ \
  ]
]

#let default-info(w) = {
  let variant = w.authors.first().at("variant", default: none)

  [
    #pz-lb-title(w.type, number: w.number)

    з навчальної дисципліни "#w.subject-name"\
    #if w.title != none [з теми "#w.title"\ ]
    #if not is-empty(variant) [\ Варіант №#variant]
  ]
}

#let default-credentials(w) = align(right)[
  #set par(first-line-indent: 0pt)

  #gender-form("author", gender: gender-get(w.authors)):\
  #for a in w.authors [студент групи #group-form(a)\ #a.name\ ]
  #text(size: 8pt)[(прізвище та ініціали)\ ]

  \

  #gender-form("mentor", gender: gender-get(w.mentors)):\
  #for m in w.mentors {
    let degree = key-get(m, "degree")
    if degree != none [#degree\ ]
    [#m.name\ ]
  }
  #text(size: 8pt)[(прізвище та ініціали)\ ]
]

#let default-footer(w) = [Харків\
  #w.year]

/// Макет "complex" титулки звіту з практичної/лабораторної (зі спеціальністю
/// та освітньою програмою на титулці).
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
