#import "@vendor/nure:0.3.0": *
#import "utils.typ": *

#import style: spacing

// Дані роботи з doc.toml; власні дисципліни/університети додаються через
// `data: yaml("data.yaml")`
#let w = work(..toml("doc.toml"), title: "Дослідження роботи мікроконтролера 8051") // title: none, якщо теми немає

#set document(..w.document)
#show: style.dstu.with(skip: 1)

// Правило з utils.typ
// #show: correctly-indent-list-and-enum-items

#report.title-page(w) // layout: "complex", footer: [...] тощо
#title-heading(w)

/// Корисні фрагменти

/// Рисунок (`fig` = `dstu-figure`): назву файлу обгортаємо в `path()`
// #fig(path("figures/clojure-logo.png"), [Логотип Clojure], "clojure.org", label: <clojure-logo>)

/// Таблиця з .csv (`tab` = `dstu-table`)
// #tab(
//   caption: [],
//   columns: 4,
//   header: ([], [], [], []),
//   label: <table>,
//   ..csv("assets/table.csv").flatten(),
// )

/// Перелік джерел (`bib` = `dstu-bibliography`)
// #bib(path("assets/bibl.yml"))

/// Додатки
// #style.appendices(include "chapters/appendices.typ")
// або
// #show: style.appendices
// = ...
