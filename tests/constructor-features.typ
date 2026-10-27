// Features only reachable through the constructor: slot overrides, reuse of
// layout defaults, citation totals, plain-list English keywords. Pure
// functions are checked with assertions.
#import "../src/lib.typ": *

#let data = toml("fixtures/data.toml")
#let w = work(..data, done-date: datetime(year: 2024, month: 12, day: 27))

// work() resolves lookups and defaults
#assert.eq(w.edu-program, "КУІБ")
#assert.eq(w.subject-name, "Скриптові мови програмування")
#assert.eq(w.year, 2024)
#assert.eq(w.document, (title: data.title, author: ("Косач Л. П.", "Шевченко Т. Г.")))
#assert.eq(work(..data, edu-program: "ПЗПІ").edu.code, 121)
#assert.eq(work(..data, title: ("Дві ", "частини")).document.title, "Дві  частини")
#assert.eq(work(..data, year: "2030").year, "2030")
#assert.eq(work(..data, subject: "Нова дисципліна").subject-name, "Нова дисципліна")
#assert.eq(work(..data, program-name: "Своя").program-name, "Своя")
#assert.eq(sort-keywords(("b", "a", "я", "а")), ("а", "я", "a", "b"))

#set document(..w.document)
#show: style.dstu.with(skip: 3)

// slots: override one, reuse another layout's default, drop one
#report.title-page(
  w,
  footer: report.complex.default-footer(w),
  info: [#report.nure.default-info(w) \ (перевизначений слот)],
  header: none,
)

#pagebreak()
#cw.abstract(w, keywords: ("тест", "zebra", "абетка"))[Реферат з посиланнями.]

#pagebreak()
#cw-v2.abstract(w, keywords: ("тест", "абетка"), en-keywords: ("test", "alphabet"))[Укр.][Eng.]

#title-heading(w)

== Citations
Text @go, #cite(<htmx>) and @go again.

#dstu-bibliography(bytes(read("fixtures/bibl.yml")), style: "8302", full: false)
