#import "../style/dstu.typ": spacing
#import "../helpers.typ": is-cyr, is-empty

// Спільні перевірки обов'язкових полів для блоків (внутрішні, не експортуються з lib.typ).
#let require-work(w, key, part) = {
  let value = w.at(key, default: none)
  assert(not is-empty(value), message: part + ": work(" + key + ": ...) is required")
  value
}

#let require-field(dict, key, label, part) = {
  let value = dict.at(key, default: none)
  assert(not is-empty(value), message: part + ": " + label + "." + key + " is required")
  value
}

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

/// Зміст (ДСТУ 3008:2015, 4.4, Додаток Б).
///
/// - compact-appendices (bool): Приховувати підзаголовки додатків
/// - depth (int, none): Глибина заголовків у змісті (типово 3 -- розділи, підрозділи й пункти)
#let contents(compact-appendices: false, depth: 3) = {
  show outline.entry: it => {
    let el = it.element

    if el.func() == heading and el.supplement == [Додаток] {
      if el.level > 1 {
        if compact-appendices { none } else { it }
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

  heading(level: 1, numbering: none, outlined: false)[ЗМІСТ]
  block(width: 100%, above: 0pt, below: spacing, align(right)[с.])
  outline(
    title: none,
    depth: depth,
    indent: 1.5em,
  )
}

/// Підсумки документа для реферату: "N с., N табл., N рис., N джерел".
/// Нульові значення пропускаються. Рахує різні процитовані джерела, тож не
/// потребує show-правил і працює будь-де в документі.
#let doc-stats() = context {
  let pages = counter(page).final().at(0)
  let images = query(figure.where(kind: image)).len()
  let tables = query(figure.where(kind: table)).len()
  let bibs = query(cite).map(it => it.key).dedup().len()

  let counters = ()
  if pages != 0 { counters.push[#pages с.] }
  if tables != 0 { counters.push[#tables табл.] }
  if images != 0 { counters.push[#images рис.] }
  if bibs != 0 { counters.push[#bibs джерел] }

  counters.join(", ")
}

#let _uk-alphabet = "абвгґдеєжзиіїйклмнопрстуфхцчшщьюя".clusters()
#let _uk-base = str.to-unicode("а")

// Перекладає українські літери в послідовні коди Unicode від «а», щоб звичайне
// рядкове сортування давало правильний порядок (ДСТУ 3008:2015, 4.3.8).
#let _uk-sort-key(s) = {
  let s = lower(s)
  (
    (if is-cyr(s) { "0" } else { "1" })
      + s
        .clusters()
        .map(c => {
          let i = _uk-alphabet.position(ch => ch == c)
          if i != none { str.from-unicode(_uk-base + i) } else { c }
        })
        .join()
  )
}

/// Сортує ключові слова реферату: спершу кирилиця за українською абеткою, далі латиниця.
/// - key (function): Повертає рядок, за яким сортується елемент
#let sort-keywords(keywords, key: it => it) = keywords.sorted(key: it => _uk-sort-key(key(it)))

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
