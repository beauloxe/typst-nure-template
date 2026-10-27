/// назва місяця в родовому відмінку за його номером (1-12)
#let month-gen(month) = (
  "січня",
  "лютого",
  "березня",
  "квітня",
  "травня",
  "червня",
  "липня",
  "серпня",
  "вересня",
  "жовтня",
  "листопада",
  "грудня",
).at(month - 1)

#let is-cyr(c) = regex("^\p{Cyrillic}") in c

/// перевірка на порожнечу для `none`, `""` і `()`
#let is-empty(val) = {
  if val == none { return true }
  if type(val) == str { val.len() == 0 } else if type(val) == array { val == [] } else { false }
}

/// значення `key` у словнику або none, якщо ключа немає чи він порожній -- лише
/// доступ до даних; `none` у розмітці нічого не виводить
#let key-get(dict, key) = if key in dict and not is-empty(dict.at(key)) { dict.at(key) }

/// форма дієслова за родом ("m", "f" або "p" -- множина):
/// gender-form("author", gender: "f") -> "Виконала"; інші значення -- як "p"
#let gender-form(verb, gender: "p") = {
  (
    "author": ("m": "Виконав", "f": "Виконала", "p": "Виконали"),
    "mentor": ("m": "Перевірив", "f": "Перевірила", "p": "Перевірили"),
  )
    .at(verb)
    .at(if gender == "m" or gender == "f" { gender } else { "p" })
}


#let gender-get(dict) = if dict.len() == 1 {
  dict.first().gender
} else if dict.len() > 1 {
  "p"
} else {
  none
}

/// шифр групи зі словника автора: "ПЗПІ" + "23-2" -> "ПЗПІ-23-2";
/// префікс не додається, якщо група вже починається з освітньої програми
#let group-form(author) = if str(author.group).starts-with(author.edu-program) {
  str(author.group)
} else {
  str(author.edu-program) + "-" + str(author.group)
}

#let pz-lb-title(type, number: none) = {
  let type-title = (
    "ЛБ": [Звіт\ з лабораторної роботи],
    "ПЗ": [Звіт\ з практичної роботи],
    "КР": [Контрольна робота],
    "РФ": [Реферат],
    "ІДЗ": [Індивідуальне домашнє завдання],
  ).at(type, default: type)
  if not is-empty(number) { [#type-title №#number] } else { [#type-title] }
}

/// рекурсивно накладає `override` на `base`: вкладені словники зливаються
/// поключово, `none` (`null` у YAML) видаляє ключ, будь-яке інше значення
/// з `override` замінює значення з `base`
#let deep-merge(base, override) = {
  let result = base
  for (key, value) in override {
    if value == none {
      let _ = result.remove(key, default: none)
      continue
    }
    let current = result.at(key, default: none)
    result.insert(key, if type(current) == dictionary and type(value) == dictionary {
      deep-merge(current, value)
    } else { value })
  }
  result
}
