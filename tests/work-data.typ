// Own universities, edu-programs and subjects merged over the built-in data.
#import "../src/lib.typ": *

#let extra = yaml("fixtures/extra-data.yaml")
#let author = (name: "Косач Л. П.", edu-program: "ПЗПІ", group: "23-2", gender: "f")
#let mentor = (name: "Франко І. Я.", degree: "Доцент", gender: "m")

#assert.eq(deep-merge((a: 1, b: (c: 2, d: 3)), (b: (d: 4, e: 5), f: 6)), (a: 1, b: (c: 2, d: 4, e: 5), f: 6))
#assert.eq(deep-merge((a: 1, b: (c: 2)), (a: none, b: (c: none), x: none)), (b: (:)))

// built-in university: one field overridden, new program and subject added
#let w = work(subject: "НовДис", authors: (author,), data: extra)
#assert.eq(w.edu.code, "F2")
#assert.eq(w.edu.name-long, "Інженерія програмного забезпечення")
#assert.eq(w.subject-name, "Нова дисципліна")
#assert.eq(work(subject: "БД", authors: (author,), data: extra).subject-name, "Бази даних")
#assert.eq(work(edu-program: "ШІ", authors: (author,), data: extra).edu.department-gen, "Штучного інтелекту")
// built-in data untouched
#assert.eq(work(authors: (author,)).edu.code, 121)
#assert.eq(universities.at("ХНУРЕ").edu-programs.ПЗПІ.code, 121)

// a university of your own
#let kpi = work(
  university: "КПІ",
  subject: "ОП",
  type: "ЛБ",
  number: 1,
  title: "Перша лабораторна",
  authors: ((..author, edu-program: "ІПЗ"),),
  mentors: (mentor,),
  data: extra,
)
#assert.eq(kpi.uni.name.starts-with("Національний"), true)

#set document(..kpi.document)
#show: style.dstu.with(skip: 1)

// the default footer says "Харків", replace it for another city
#report.title-page(kpi, footer: [Київ -- #kpi.year])
#title-heading(kpi)

== Content
#lorem(20)
