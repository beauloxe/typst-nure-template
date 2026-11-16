/// Лінтер оформлення за ДСТУ 3008:2015.
///
/// Перевіряє те, що залежить від автора, а не від шаблону: заголовки, назви,
/// посилання, переліки. Документ при цьому не змінюється -- лінтер лише читає
/// його елементи через `query`, тож запускається окремою командою:
///
/// ```sh
/// typst eval '{ import "@vendor/nure:0.3.0": lint; lint.check() }' --in main.typ
/// ```
///
/// Команда друкує зауваження і завершується з кодом 1, якщо вони є.

/// Правила: код -> пункт ДСТУ 3008:2015 (`clause`) і суть вимоги (`desc`).
/// Перевіряється лише те, що стандарт вимагає прямо; лістингів він не описує,
/// тож їх лінтер не чіпає.
#let rules = (
  "heading-period": (clause: "7.1.20, 7.1.21", desc: "Заголовки друкують без крапки в кінці"),
  "heading-case": (clause: "7.1.21", desc: "Заголовки підрозділів, пунктів і підпунктів друкують з великої літери"),
  "heading-numbered": (
    clause: "7.1.18",
    desc: "Структурні елементи («Вступ», «Висновки», «Перелік джерел посилання» тощо) не нумерують",
  ),
  "heading-single": (
    clause: "7.4.6",
    desc: "Єдиний пункт розділу чи підрозділу (єдиний підпункт пункту) не нумерують",
  ),
  "figure-unreferenced": (clause: "7.5.2", desc: "Рисунок подають після тексту, де на нього вперше посилаються"),
  "table-unreferenced": (clause: "7.6.3", desc: "На кожну таблицю має бути посилання в тексті"),
  "figure-before-ref": (
    clause: "7.5.2, 7.6.3",
    desc: "Рисунок і таблицю подають після тексту, де їх згадано вперше, або на наступній сторінці",
  ),
  "caption-case": (clause: "7.5.9, 7.6.8", desc: "Назву рисунка й таблиці друкують з великої літери"),
  "table-no-header": (clause: "7.6.1, 7.6.9", desc: "Таблиця має головку, яку повторюють у кожній її частині"),
  "table-header-case": (clause: "7.6.10", desc: "Заголовки колонок таблиці починають з великої літери"),
  "table-header-period": (clause: "7.6.11", desc: "У кінці заголовків і підзаголовків таблиць крапки не ставлять"),
  "list-case": (clause: "7.7.4", desc: "Текст кожної позиції переліку починають з малої літери"),
  "list-punct": (clause: "7.7.2", desc: "Позиції переліку закінчують «;», останню -- «.» (за прикладом у стандарті)"),
  "footnote-count": (clause: "7.9.3", desc: "На одній сторінці -- не більше ніж чотири виноски"),
  "keywords-count": (clause: "4.3.8", desc: "Перелік ключових слів реферату містить 5--15 слів (словосполучень)"),
  "appendix-unreferenced": (clause: "6.1.2", desc: "Додатки розміщують у порядку посилання на них у тексті"),
  "appendix-order": (clause: "6.1.2", desc: "Додатки розміщують у порядку посилання на них у тексті"),
)

#let _space = [ ].func()

// Заголовки структурних елементів, які не нумерують (7.1.18)
#let _structural = (
  "список авторів",
  "реферат",
  "зміст",
  "скорочення та умовні познаки",
  "передмова",
  "вступ",
  "висновки",
  "рекомендації",
  "перелік джерел посилання",
)
// Назви видів фігур: називний і знахідний відмінки
#let _kind-names = (
  repr(image): ("рисунок", "рисунок"),
  repr(table): ("таблиця", "таблицю"),
)

/// Текст елемента без розмітки
#let _plain(c) = {
  if c == none { return "" }
  if type(c) == str { return c }
  if type(c) != content { return str(c) }
  if c.func() == _space { return " " }
  if c.func() == smartquote { return if c.double { "\"" } else { "'" } }
  if c.has("text") { return if type(c.text) == str { c.text } else { _plain(c.text) } }
  if c.has("children") { return c.children.map(_plain).join("") }
  if c.has("body") { return _plain(c.body) }
  if c.has("child") { return _plain(c.child) }
  ""
}

/// Вміст без вкладених списків: пунктуацію пункту визначає його власний текст
#let _without-lists(c) = {
  if type(c) != content { return c }
  if c.func() in (list, enum, list.item, enum.item) { return none }
  if c.has("children") { return c.children.map(_without-lists).join() }
  c
}

/// Скорочує довгий текст для повідомлення
#let _quote(s) = {
  let chars = s.trim().clusters()
  "«" + if chars.len() > 60 { chars.slice(0, 60).join("") + "…" } else { chars.join("") } + "»"
}

#let _ends-with-period(s) = s.ends-with(".") and not s.ends-with("...")

/// Перша літера рядка: "upper", "lower" або `none`, якщо рядок починається
/// не з літери чи з абревіатури (ХНУРЕ, HTTP)
#let _first-case(s) = {
  let word = s.trim().split(regex("\\s")).first()
  let first = word.clusters().at(0, default: "")
  if first.match(regex("^\\p{L}$")) == none { return none }
  if first == lower(first) { return "lower" }
  let rest = word.clusters().slice(1).join("")
  if rest != "" and rest == upper(rest) { none } else { "upper" }
}

/// Чи стоїть місце `a` в документі раніше за `b`
#let _before(a, b) = {
  let (a, b) = (a.position(), b.position())
  if a.page != b.page { return a.page < b.page }
  if a.y != b.y { a.y < b.y } else { a.x < b.x }
}

/// Перша таблиця всередині вмісту або `none`
#let _find-table(c) = {
  if type(c) != content { return none }
  if c.func() == table { return c }
  if c.has("children") {
    for child in c.children {
      let found = _find-table(child)
      if found != none { return found }
    }
  }
  if c.has("body") { return _find-table(c.body) }
  if c.has("child") { return _find-table(c.child) }
  none
}

/// Зауваження до документа: масив словників `(rule, clause, page, msg)`, упорядкований
/// за сторінками. У `typst eval --in` викликається як є, у самому документі --
/// всередині `context`.
///
/// - ignore (array): Коди правил, які не перевіряти, напр. `("list-punct",)`
#let run(ignore: ()) = {
  for rule in ignore {
    assert(rule in rules, message: "lint: unknown rule \"" + rule + "\", expected one of " + repr(rules.keys()))
  }

  let diags = ()
  let add(rule, loc, msg) = if rule in ignore { () } else {
    ((rule: rule, clause: rules.at(rule).clause, page: loc.page(), msg: msg),)
  }

  // Місця всіх посилань за міткою цілі, у порядку документа
  let refs = (:)
  for r in query(ref) {
    let key = str(r.target)
    refs.insert(key, refs.at(key, default: ()) + (r.location(),))
  }
  let refs-to(el) = if el.has("label") { refs.at(str(el.label), default: ()) } else { () }

  // Заголовки й додатки
  let appendices = ()
  // Нумеровані заголовки, під якими зараз стоїмо: (заголовок, прямі нащадки)
  let open = ()
  let close(open, level) = {
    let found = ()
    while open.len() > 0 and open.last().el.level >= level {
      let parent = open.pop()
      if parent.children.len() == 1 {
        let only = parent.children.first()
        found += add(
          "heading-single",
          only.location(),
          "єдиний підзаголовок у " + _quote(_plain(parent.el.body)) + ": " + _quote(_plain(only.body)),
        )
      }
    }
    (open, found)
  }
  for h in query(heading) {
    let title = _plain(h.body).trim()
    if _ends-with-period(title) {
      diags += add("heading-period", h.location(), "крапка в кінці заголовка " + _quote(title))
    }
    if h.level > 1 and _first-case(title) == "lower" {
      diags += add("heading-case", h.location(), "заголовок з малої літери: " + _quote(title))
    }
    if h.level == 1 and h.supplement == [Додаток] {
      appendices.push((title: title, loc: h.location(), refs: refs-to(h)))
    } else if h.level == 1 and h.numbering != none and lower(title) in _structural {
      diags += add("heading-numbered", h.location(), "структурний елемент " + _quote(title) + " має бути без номера")
    }

    let (rest, found) = close(open, h.level)
    open = rest
    diags += found
    if h.numbering != none {
      if open.len() > 0 { open.last().children.push(h) }
      open.push((el: h, children: ()))
    }
  }
  diags += close(open, 0).last()

  let last-ref = none
  for app in appendices {
    if app.refs.len() == 0 {
      diags += add("appendix-unreferenced", app.loc, "на додаток " + _quote(app.title) + " немає посилання в тексті")
      continue
    }
    if last-ref != none and _before(app.refs.first(), last-ref) {
      diags += add(
        "appendix-order",
        app.loc,
        "на додаток " + _quote(app.title) + " вперше посилаються раніше, ніж на попередній",
      )
    }
    last-ref = app.refs.first()
  }

  // Рисунки й таблиці
  for f in query(figure) {
    let kind = _kind-names.at(repr(f.kind), default: none)
    // Лістинги, власні види фігур і фігури без нумерації (логотипи тощо) не перевіряються
    if kind == none or f.numbering == none { continue }
    let loc = f.location()

    // Назва фігури для повідомлень: називний і знахідний відмінки
    let (name, name-acc) = kind
    if f.caption != none {
      let caption = _plain(f.caption.body).trim()
      name += " " + _quote(caption)
      name-acc += " " + _quote(caption)
      if _first-case(caption) == "lower" {
        diags += add("caption-case", loc, "назва з малої літери: " + name)
      }
    }

    let targets = refs-to(f)
    if targets.len() == 0 {
      diags += add(
        if f.kind == table { "table-unreferenced" } else { "figure-unreferenced" },
        loc,
        "на " + name-acc + " немає посилання в тексті",
      )
    } else if _before(loc, targets.first()) {
      diags += add(
        "figure-before-ref",
        loc,
        name + " стоїть раніше за перше посилання (с. " + str(targets.first().page()) + ")",
      )
    }

    let tbl = if f.kind == table { _find-table(f.body) }
    if tbl == none { continue }
    let header = tbl.children.find(c => c.func() == table.header)
    if header == none {
      diags += add("table-no-header", loc, name + " без головки (table.header)")
      continue
    }
    // Підзаголовки (другий рядок головки) можуть починатися з малої літери,
    // тож регістр перевіряється лише в однорядковій головці
    let columns = if type(tbl.columns) == int { tbl.columns } else if type(tbl.columns) == array {
      tbl.columns.len()
    } else { 1 }
    let single-row = header.children.len() <= columns
    for cell in header.children {
      let text = _plain(cell).trim()
      if _ends-with-period(text) {
        diags += add("table-header-period", loc, name + ": крапка в кінці заголовка колонки " + _quote(text))
      }
      if single-row and _first-case(text) == "lower" {
        diags += add("table-header-case", loc, name + ": заголовок колонки з малої літери " + _quote(text))
      }
    }
  }

  // Переліки
  for l in query(list) + query(enum) {
    for item in l.children {
      let text = _plain(_without-lists(item.body)).trim()
      if text == "" { continue }
      if _first-case(text) == "upper" {
        diags += add("list-case", l.location(), "позиція переліку з великої літери: " + _quote(text))
      }
      // «:» -- позиція, за якою йде вкладений перелік
      if not (text.ends-with(";") or text.ends-with(".") or text.ends-with(":")) {
        diags += add("list-punct", l.location(), "позиція переліку без «;» або «.» в кінці: " + _quote(text))
      }
    }
  }

  // Ключові слова реферату: кількість лишає в документі сам реферат (`keywords-count`)
  for m in query(<nure-keywords>) {
    if m.value < 5 or m.value > 15 {
      diags += add(
        "keywords-count",
        m.location(),
        "ключових слів у рефераті: " + str(m.value) + ", має бути від 5 до 15",
      )
    }
  }

  // Виноски: посилання на вже наявну виноску (`footnote(<label>)`) нової не створює
  let footnotes = (:)
  for f in query(footnote) {
    if type(f.body) == label { continue }
    let page = str(f.location().page())
    footnotes.insert(page, footnotes.at(page, default: ()) + (f.location(),))
  }
  for (page, locs) in footnotes {
    if locs.len() > 4 {
      diags += add(
        "footnote-count",
        locs.first(),
        "виносок на сторінці: " + str(locs.len()) + ", дозволено не більше ніж чотири",
      )
    }
  }

  diags.sorted(key: d => d.page)
}

/// Зауваження як текст, по одному на рядок:
/// `с. 3  [heading-period]  крапка в кінці заголовка «Вступ.» (п. 7.1.20, 7.1.21)`
#let report(diags) = {
  let pad(s, width) = s + " " * (width - s.len())
  let page-width = calc.max(0, ..diags.map(d => str(d.page).len()))
  let rule-width = calc.max(0, ..diags.map(d => d.rule.len())) + 2
  diags
    .map(d => (
      "с. "
        + pad(str(d.page), page-width)
        + "  "
        + pad("[" + d.rule + "]", rule-width)
        + "  "
        + d.msg
        + " (п. "
        + d.clause
        + ")"
    ))
    .join("\n", default: "")
}

/// Перевіряє документ: якщо є зауваження, зупиняється з помилкою, у тексті якої
/// їх перелік (`typst eval` тоді завершується з кодом 1); інакше повертає
/// рядок про успіх.
///
/// - ignore (array): Коди правил, які не перевіряти
#let check(ignore: ()) = {
  let diags = run(ignore: ignore)
  assert(
    diags.len() == 0,
    message: "ДСТУ 3008:2015, зауважень: " + str(diags.len()) + "\n" + report(diags),
  )
  "ДСТУ 3008:2015: зауважень немає"
}
