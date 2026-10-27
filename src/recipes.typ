// Ready-made recipes: whole documents assembled from the parts. Each one is
// also an example of the constructor approach -- copy its body into your
// document to take control of any page.

#import "style.typ"
#import "work.typ": work
#import "parts/common.typ": dstu-bibliography, title-heading
#import "parts/report/main.typ" as report
#import "parts/cw.typ" as cw
#import "parts/cw-v2.typ" as cw-v2

/// Рецепт курсової роботи ХНУРЕ (ДСТУ 3008)
/// - university (str): Код університету, за замовчуванням "ХНУРЕ"
/// - subject (str): Код дисципліни
/// - title (str): Тема роботи
/// - authors (array): Словники авторів
/// - mentors (array): Словники викладачів
/// - task-list (dict): Дані завдання (дати, вихідні дані, зміст...)
/// - calendar-plan (dict): Таблиця календарного плану і дата затвердження
/// - abstract (dict): Ключові слова і текст реферату
/// - bib-path (path, bytes): Перелік джерел, напр. `path("bibl.yml")`
/// - appendices (content): Вміст додатків
#let coursework(
  doc,
  university: "ХНУРЕ",
  subject: none,
  title: none,
  authors: (),
  mentors: (),
  task-list: (:),
  calendar-plan: (:),
  abstract: (:),
  bib-path: none,
  appendices: (),
) = {
  let w = work(
    university: university,
    subject: subject,
    title: title,
    authors: authors,
    mentors: mentors,
    initial-date: task-list.at("initial-date", default: none),
    done-date: task-list.at("done-date", default: none),
  )

  set document(..w.document)
  show: style.dstu.with(skip: 1)

  cw.title-page(w)
  cw.task(
    w,
    source: task-list.at("source", default: []),
    content: task-list.at("content", default: []),
    graphics: task-list.at("graphics", default: []),
  )
  cw.calendar-plan(w, calendar-plan.plan-table, approval-date: calendar-plan.at("approval-date", default: auto))
  cw.abstract(w, keywords: abstract.keywords, abstract.text)
  cw.contents()

  doc

  dstu-bibliography(bib-path, style: "3008")

  style.appendices(appendices)
}

/// Рецепт комплексного курсового проєкту ХНУРЕ (ДСТУ 8302)
/// - university (str): Код університету, за замовчуванням "ХНУРЕ"
/// - title (str): Тема роботи
/// - authors (array): Словники авторів
/// - mentors (array): Словники викладачів
/// - committee-members (array): Члени комісії для титулки (необов'язково)
/// - task-list (dict): Дані завдання (дати, вихідні дані, зміст...)
/// - calendar-plan (dict): Таблиця календарного плану
/// - abstract (dict): Ключові слова і текст реферату
/// - abstract-en (dict): Англійські ключові слова і текст (необов'язково)
/// - bib-path (path, bytes): Перелік джерел, напр. `path("bibl.yml")`
/// - appendices (content): Вміст додатків
#let coursework-v2(
  doc,
  university: "ХНУРЕ",
  title: none,
  authors: (),
  mentors: (),
  committee-members: none,
  task-list: (:),
  calendar-plan: (:),
  abstract: (:),
  abstract-en: none,
  bib-path: none,
  appendices: (),
  faculty: "комп’ютерних наук",
  education-level: "перший (бакалаврський)",
  program-type: "освітньо-професійна",
  program-name: none,
) = {
  assert(mentors.len() > 0, message: "At least one mentor required")

  let w = work(
    university: university,
    title: title,
    authors: authors,
    mentors: mentors,
    committee-members: committee-members,
    faculty: faculty,
    education-level: education-level,
    program-type: program-type,
    program-name: program-name,
    initial-date: task-list.at("initial-date", default: none),
    done-date: task-list.at("done-date", default: none),
  )

  set document(..w.document)
  show: style.dstu.with(skip: 1)

  cw-v2.title-page(w)
  cw-v2.task(w, source: task-list.at("source", default: []), content: task-list.at("content", default: []))
  cw-v2.calendar-plan(w, calendar-plan.plan-table)
  cw-v2.abstract(
    w,
    keywords: abstract.keywords,
    en-keywords: if abstract-en != none { abstract-en.at("keywords", default: none) },
    abstract.text,
    ..if abstract-en != none { (abstract-en.text,) },
  )
  cw-v2.contents()

  doc

  dstu-bibliography(bib-path, style: "8302")

  style.appendices(appendices)
}

/// Рецепт практичних і лабораторних робіт
/// - layout (str): "default" (те саме, що "nure") або "complex"
/// - university (str): Код університету, див. src/config/universities.yaml
/// - edu-program (str): Код освітньої програми, за замовчуванням -- першого автора
/// - subject (str): Код дисципліни, див. src/config/universities.yaml
/// - type (str): Тип роботи (ЛБ, ПЗ, КР, РФ, ІДЗ)
/// - number (int): Номер роботи
/// - title (str): Тема роботи
/// - authors (array): Автори
/// - mentors (array): Викладачі
/// - skip-heading (bool): Не вставляти тему як заголовок першого рівня
///
/// Титулка складається з чотирьох слотів: header, info, credentials, footer.
/// Кожен за замовчуванням заповнюється вмістом макета; його можна замінити,
/// передавши `header:`, `info:`, `credentials:` чи `footer:` (або `none`,
/// щоб лишити слот порожнім). Див. `parts/report/nure.typ`.
#let pz-lb(
  doc,
  university: "ХНУРЕ",
  layout: "default",
  edu-program: none,
  subject: none,
  type: none,
  number: none,
  title: none,
  authors: (),
  mentors: (),
  skip-heading: false,
  ..title-page,
) = {
  let w = work(
    university: university,
    edu-program: edu-program,
    subject: subject,
    type: type,
    number: number,
    title: title,
    authors: authors,
    mentors: mentors,
  )

  set document(..w.document)
  show: style.dstu.with(skip: 1)

  report.title-page(w, layout: layout, ..title-page)

  if not skip-heading { title-heading(w) }

  doc
}
