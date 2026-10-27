#import "@local/nure:0.3.0": *
#import style: spacing

// 1. Описуємо роботу один раз; усі блоки нижче беруть дані звідси.
#let w = work(
  title: (
    "Демонстраційна інформаційна система для комплексного ",
    "курсового проєкту",
  ),
  authors: (
    (
      name: "Стус В. С.",
      display-name: "Василь СТУС",
      full-name-gen: "Стуса Василя Семеновича",
      full-name-dat: "Стусу Василю Семеновичу",
      edu-program: "ПЗПІ",
      group: "23-3",
      gender: "m",
      course: 3,
      semester: 6,
      variant: 13,
    ),
  ),
  mentors: (
    (name: "Тичина П. Г.", display-name: "Павло ТИЧИНА", degree: "ст.викл. кафедри ПІ"),
  ),
  committee-members: (
    (name: "Сосюра В. М.", degree: "Доц."),
    (name: "Симоненко В. А.", degree: "Ст. викл."),
    (name: "Маланюк Є. Ф.", degree: "Ст. викл."),
  ),
  initial-date: datetime(year: 2026, month: 9, day: 15),
  done-date: datetime(year: 2026, month: 12, day: 27),
)

// 2. Метадані документа і стилі ДСТУ.
#set document(..w.document)
#show: style.dstu.with(skip: 1)

// 3. Збираємо документ з блоків; будь-який можна прибрати чи замінити своїм.
#cw-v2.title-page(w)

#cw-v2.task(
  w,
  // масив розбивається на підкреслені рядки
  source: (
    [Узагальнити модель предметної області,],
    [визначити основні сутності та зв'язки між ними.],
    [Підготувати демонстраційний набір технологій для шаблону.],
  ),
  content: (
    [Опис предметної галузі, формування вимог,],
    [архітектурне проєктування, тестування та],
    [перевірка верстки пояснювальної записки.],
  ),
)

#cw-v2.calendar-plan(
  w,
  table(
    columns: (0.7fr, 5.8fr, 2.5fr, 1.6fr),
    align: (center, left, center, center),
    [№], [Назва етапів роботи], [Термін виконання етапів роботи], [Примітка],
    [1], [Аналіз предметної галузі], [], [виконано],
    [2], [Розробка постановки задачі], [], [виконано],
    [3], [Проєктування ПЗ], [], [виконано],
    [4], [Програмна реалізація], [], [виконано],
    [5], [Аналіз результатів], [], [виконано],
    [6], [Підготовка пояснювальної записки.], [], [виконано],
    [7], [Перевірка на наявність ознак академічного плагіату], [], [виконано],
    [8], [Захист роботи], [], [виконано],
  ),
)

#cw-v2.abstract(
  w,
  // пари (укр, англ) або рядки разом з `en-keywords:`
  keywords: (
    ("веб-застосунок", "WEB APPLICATION"),
    ("інформаційна система", "INFORMATION SYSTEM"),
    ("курсова робота", "COURSEWORK"),
    ("програмна інженерія", "SOFTWARE ENGINEERING"),
    ("тестовий приклад", "DEMO SAMPLE"),
  ),
)[
  Мета даної роботи -- продемонструвати оформлення пояснювальної записки
  для комплексного курсового проєкту з використанням нового варіанта шаблону.
  Приклад містить узагальнену тему, типові сторінки завдання, календарного плану,
  реферату, змісту, переліку джерел посилання та додатків.

  У роботі наведено умовну структуру програмної системи, що може бути
  адаптована під конкретну предметну область. Основний акцент зроблено на
  перевірці полів титульної сторінки, сторінки завдання, службових підписів,
  нумерації розділів і коректної роботи додатків.

  Результатом є демонстраційний документ, який показує очікуване використання
  шаблону без прив'язки до реального студента, викладача або завершеної роботи.
][
  The purpose of this work is to demonstrate the formatting of a coursework
  explanatory note using the new template variant.

  The sample contains a generalized topic, typical pages for the assignment,
  calendar plan, abstract, contents, bibliography, and appendices.

  The work presents an illustrative structure of a software system that can be
  adapted to a specific subject area. The main focus is on checking title-page
  fields, assignment-page fields, signature blocks, section numbering, and
  appendix handling.

  The result is a demonstration document that shows the expected template usage
  without being tied to a real student, supervisor, or completed project.
]

#cw-v2.contents()

= Моделювання
#lorem(250)

= Імплементація
#v(-spacing)
== Підготовка
#lorem(200)
== Процес
#lorem(500)

= Тестування
#lorem(300)

// ПРИМІТКА: назви файлів обгортаємо в `path()`, бо рядок шукався б у теці пакунка (`bib` = `dstu-bibliography`)
#bib(path("bibl.yml"), style: "8302")

#show: style.appendices

= Приклад звіту 1
#v(-spacing)
== Частина 1
#lorem(100)
== Частина 2
#lorem(200)

= Приклад звіту 2
#lorem(200)

= Приклад звіту 3
#lorem(200)
