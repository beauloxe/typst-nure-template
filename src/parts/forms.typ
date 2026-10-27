#import "../utils.typ": ruled-field, uline

// Form-like building blocks: underlined fields with captions below them,
// as used on official NURE pages (title page, task). Reusable in custom parts.

/// дрібний підпис під полем по центру, напр. "(повна назва)"
#let note(content) = block(width: 100%, above: 5pt, below: 0pt)[
  #set text(size: 10pt)
  #set par(first-line-indent: 0pt, spacing: 0pt)
  #align(center)[#content]
]

/// однорядкове поле з лінією знизу
#let form-field(alignment: center, content) = box(
  width: 100%,
  stroke: (bottom: 0.5pt),
  inset: (bottom: 1.5pt),
)[
  #align(alignment)[#content]
]

/// назва і поле після неї, за потреби з підписом; `label-width` вирівнює кілька рядків
#let label-line(label, value, caption: none, label-width: auto) = {
  set par(first-line-indent: 0pt)
  if label-width == auto {
    [#label #form-field(alignment: center, value)]
  } else {
    grid(
      columns: (label-width, 1fr),
      gutter: 0pt,
      align: horizon,
      label, form-field(alignment: center, value),
    )
  }
  if caption != none {
    note(caption)
  }
}

/// однорядкове поле з текстом по центру
#let inline-field(value) = form-field(alignment: center, value)

/// назва і поле, де підкреслено кожен рядок при переносі (див. `utils.ruled-field`)
#let inline-label-line(label, value) = block(width: 100%, below: 0pt)[
  #set par(first-line-indent: 0pt)
  #grid(
    columns: (auto, 1fr),
    column-gutter: 0.5em,
    align: (left + top, left + top),
    label, ruled-field(value),
  )
]

/// сітка рядків (назва, значення); значення-масив займає кілька рядків
#let task-head-fields(fields) = {
  set par(first-line-indent: 0pt)
  let cells = ()
  for (label, value) in fields {
    if type(value) == array {
      for (i, line) in value.enumerate() {
        cells.push(if i == 0 { label } else { [] })
        cells.push(inline-field(line))
      }
    } else {
      cells.push(label)
      cells.push(inline-field(value))
    }
  }
  grid(
    columns: (auto, 1fr),
    gutter: 0pt,
    row-gutter: 0.65em,
    align: top,
    ..cells,
  )
}

/// номер пункту завдання "N."
#let task-num(n) = box(str(n) + ".")

/// поле теми роботи; тема-масив з'єднується
#let title-field(value) = {
  uline(align: center, if type(value) == array { value.join() } else { value })
  uline(align: center, [])
  note[(тема)]
}

/// по лінії на кожного члена комісії або три порожні лінії
#let commission-lines(members) = {
  if members.len() > 0 {
    for (i, member) in members.enumerate() {
      if i > 0 {
        linebreak()
      }
      let member-display-name = member.at("display-name", default: member.name)
      let member-degree = member.at("degree", default: "")
      uline(align: left, [#member-degree #member-display-name])
    }
  } else {
    v(0.55em)
    line(length: 100%, stroke: 0.5pt)
    v(0.55em)
    line(length: 100%, stroke: 0.5pt)
    v(0.55em)
    line(length: 100%, stroke: 0.5pt)
  }
}

