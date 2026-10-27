#import "shared.typ": universities
#import "helpers.typ": deep-merge

/// Нормалізований опис роботи, спільний для всіх блоків.
///
/// Чиста функція: лише знаходить дані (університет, освітня програма, дисципліна),
/// підставляє значення за замовчуванням і повертає звичайний словник. Без стану
/// й `context`, тож результат можна використати будь-де: `#set document(..w.document)`.
///
/// Тут дані, потрібні кільком блокам (автори, тема, дати); дані одного
/// блоку (ключові слова, таблиця плану) передаються прямо в нього.
///
/// Назви параметрів збігаються з рецептами й `doc.toml`, тож
/// `work(..toml("doc.toml"))` працює.
///
/// - university (str): Код університету, див. `config/universities.yaml`
/// - edu-program (str): Код освітньої програми, за замовчуванням -- першого автора
/// - subject (str): Код дисципліни, див. `config/universities.yaml`
/// - type (str): Тип роботи (ЛБ, ПЗ, КР, РФ, ІДЗ або довільний текст)
/// - number (int): Номер роботи
/// - title (str, content, array): Тема роботи; масив -- тема, розбита на рядки
/// - authors (array): Словники авторів
/// - mentors (array): Словники викладачів, перший -- керівник
/// - committee-members (array): Члени комісії, якщо вони відрізняються від викладачів
/// - faculty, education-level, program-type (str): Поля титулки курсового проєкту
/// - program-name (str): Назва освітньої програми, за замовчуванням -- з даних програми
/// - initial-date (datetime): Дата видачі завдання
/// - done-date (datetime): Термін здачі роботи
/// - year (int, str): Рік на титулці, за замовчуванням -- з `done-date` або поточний
/// - data (dictionary): Власні університети, освітні програми й дисципліни у
///   форматі `config/universities.yaml`, накладаються на вбудовані,
///   напр. `data: yaml("my-data.yaml")`
#let work(
  university: "ХНУРЕ",
  edu-program: none,
  subject: none,
  type: none,
  number: none,
  title: none,
  authors: (),
  mentors: (),
  committee-members: none,
  faculty: "комп’ютерних наук",
  education-level: "перший (бакалаврський)",
  program-type: "освітньо-професійна",
  program-name: none,
  initial-date: none,
  done-date: none,
  year: auto,
  data: (:),
) = {
  let universities = if data == none { universities } else { deep-merge(universities, data) }

  assert(
    university in universities,
    message: "work: unknown university " + repr(university) + ", expected one of " + repr(universities.keys()),
  )
  assert(authors.len() > 0, message: "work: at least one author is required")

  let uni = universities.at(university)
  assert("name" in uni, message: "work: university " + repr(university) + " has no `name`")
  let edu-programs = uni.at("edu-programs", default: (:))
  let edu-program = if edu-program != none { edu-program } else { authors.first().at("edu-program", default: none) }
  assert(
    edu-program in edu-programs,
    message: "work: edu-program must be one of " + repr(edu-programs.keys()) + ", got: " + repr(edu-program),
  )
  let edu = edu-programs.at(edu-program)
  for key in ("name-long", "department-gen", "code") {
    assert(key in edu, message: "work: edu-program " + repr(edu-program) + " has no `" + key + "`")
  }

  (
    university: university,
    uni: uni,
    edu-program: edu-program,
    edu: edu,
    subject: subject,
    subject-name: if subject != none { uni.at("subjects", default: (:)).at(subject, default: subject) },
    type: type,
    number: number,
    title: title,
    authors: authors,
    mentors: mentors,
    committee-members: committee-members,
    faculty: faculty,
    education-level: education-level,
    program-type: program-type,
    program-name: if program-name != none { program-name } else { edu.at("program-name", default: edu.name-long) },
    initial-date: initial-date,
    done-date: done-date,
    year: if year != auto { year } else if done-date != none { done-date.year() } else { datetime.today().year() },
    // arguments for `set document`
    document: (
      title: if std.type(title) == array { title.join(" ") } else { title },
      author: authors.map(a => a.name),
    ),
  )
}
