#import "../style.typ": spacing
#import "../helpers.typ": is-cyr

/// Заголовок першого рівня з темою роботи, з якого починається основна частина.
///
/// Виставляє лічильник заголовків так, щоб тема мала номер роботи: з темою
/// сам заголовок отримує номер `number`; без теми заголовок не вставляється,
/// а наступні заголовки нумеруються від `number`.
/// Тема-рядок обробляється як розмітка.
#let title-heading(w) = {
  pagebreak(weak: true)

  if w.title == none {
    if w.number == none { context counter(heading).update(1) } else {
      context counter(heading).update(w.number)
    }
  } else {
    if w.number != none {
      context counter(heading).update(w.number - 1)
    }

    let title = if type(w.title) == array { w.title.join() } else { w.title }
    heading(if type(title) == str { eval(title, mode: "markup") } else { title })
  }
}

/// Зміст.
///
/// - compact-appendices (bool): Подавати додатки як "Додаток А Назва" і
///   приховувати їхні підзаголовки
#let contents(compact-appendices: false) = {
  show outline.entry: it => {
    let el = it.element

    if compact-appendices and el.func() == heading and el.supplement == [Додаток] {
      if el.level > 1 {
        none
      } else {
        block(width: 100%)[
          #link(el.location())[
            Додаток #it.prefix()#h(0.5em)#it.inner()
          ]
        ]
      }
    } else {
      it
    }
  }

  outline(
    title: [
      ЗМІСТ
      #v(spacing * 2, weak: true)
    ],
    depth: 2,
    indent: auto,
  )
}

/// Підсумки документа для реферату: "N с., N табл., N рис., N джерел".
/// Нульові значення пропускаються. Рахує різні процитовані джерела, тож не
/// потребує show-правил і працює будь-де в документі.
#let doc-stats() = context {
  let pages = counter(page).final().at(0)
  let images = query(figure.where(kind: image)).len()
  let dstu-tables = (
    query(metadata)
      .filter(it => type(it.value) == dictionary and it.value.at("kind", default: none) == "dstu-table")
      .len()
  )
  let tables = query(figure.where(kind: table)).len() + dstu-tables
  let bibs = query(cite).map(it => it.key).dedup().len()

  let counters = ()
  if pages != 0 { counters.push[#pages с.] }
  if tables != 0 { counters.push[#tables табл.] }
  if images != 0 { counters.push[#images рис.] }
  if bibs != 0 { counters.push[#bibs джерел] }

  counters.join(", ")
}

/// Сортує ключові слова реферату: спершу кирилиця, далі за абеткою.
/// - key (function): Повертає рядок, за яким сортується елемент
#let sort-keywords(keywords, key: it => it) = keywords.sorted(by: (a, b) => {
  let (a, b) = (key(a), key(b))
  if is-cyr(a) != is-cyr(b) { is-cyr(a) } else { a < b }
})

#let csl-styles = (
  "3008": "../csl/dstu-3008-2015.csl",
  "8302": "../csl/dstu-8302-2015.csl",
)

/// Перелік джерел за ДСТУ. Виводить `source` (`path("bibl.yml")` або байти
/// hayagriva YAML / BibLaTeX) так, як вимагає стандарт: після номера
/// запису 0,5 см, перший рядок з абзацним відступом, наступні -- від
/// лівого краю, без зайвих інтервалів.
///
/// - style (str, bytes): "3008" (ДСТУ 3008:2015), "8302" (ДСТУ 8302:2015)
///   або власний CSL-стиль як байти
/// - title (content): Заголовок переліку
/// - full (bool): Включати й непроцитовані джерела
///
/// `show block` -- обхідне рішення саме для цих CSL: записи виводяться
/// блоками, чия власна структура абзаців ламає оформлення за ДСТУ
/// (відступи в наступних рядках, зайві проміжки). Зняття блоку з parbreak
/// після нього вбудовує кожен запис у звичайний потік абзаців. Перевірено:
/// локальний `set block(spacing: 0pt)` прибирає проміжки, але не відступ
/// наступних рядків. Якщо новіший Typst зробить це зайвим -- приберіть
/// повністю.
#let dstu-bibliography(source, style: "3008", title: [Перелік джерел посилання], full: true) = {
  let style = if type(style) == str {
    assert(
      style in csl-styles,
      message: "dstu-bibliography: style must be one of " + repr(csl-styles.keys()) + " or CSL bytes",
    )
    csl-styles.at(style)
  } else { style }

  show regex("^\\d+\\."): it => [#it#h(0.5cm)]
  show block: it => [#it.body#parbreak()]
  bibliography(source, title: title, style: style, full: full)
}
