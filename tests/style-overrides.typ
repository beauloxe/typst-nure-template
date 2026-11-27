// Оверрайди `style.overrides.*`: `plain-heading` та `inline-code`.
#import "../src/lib.typ": *

#show: style.dstu.with(section-numbering: false)

// Перевіряємо, що обидва способи доступу працюють: `style.overrides.*` та імпорт
#import style.overrides: inline-code, plain-heading

// 1. Типовий `plain-heading` + типовий `inline-code`
#{
  show: style.overrides.plain-heading
  show: style.overrides.inline-code

  [
    = Мета роботи <goal>
    Метою роботи є отримання практичних навичок роботи з `NTFS` та командою `icacls --help "file"` і підсвіткою #raw("int x = 1;", lang: "c"). Порожній: #raw("").

    #note[Примітка з `inline-code` у кеглі 12 pt.]

    = Хід виконання <steps>
    == Перший пункт <s1>
    Текст першого пункту.

    === Підпункт <s1-1>
    Текст підпункту.

    == Другий пункт <s2>
    ```c
    int main(void) { return 0; }
    ```

    = Довгий заголовок першого рівня який має перенестися на другий рядок для перевірки вирівнювання
    Текст після довгого заголовка.

    #show: style.appendices
    = Код програми <app1>
    == Підрозділ додатка <app1-1>
    Текст додатка з `raw` у тексті.
  ]
}

// 2. `plain-heading` із параметрами (`numbering: auto`, `pagebreak: true`, `uppercase: false`)
//    та `inline-code` із `fill`, `stroke` і явним `size`
#{
  counter(heading).update(0)
  show: style.dstu.with(section-numbering: true)
  show: plain-heading.with(numbering: auto, pagebreak: true, uppercase: false, weight: "semibold")
  show: inline-code.with(size: 0.9em, fill: luma(240), stroke: 0.4pt + luma(200))

  [
    = Нумерований розділ <num1>
    Інлайн-код із плашкою: `git status`.
    #fig(path("fixtures/figures/scheme.svg"), [Перший рисунок], width: 3cm, label: <f-num1>)

    = Другий розділ <num2>
    #fig(path("fixtures/figures/scheme.svg"), [Рисунок у другому розділі], width: 3cm, label: <f-num2>)
  ]
}

// 3. `inline-code` із точним розміром у `pt` та `1em`
#{
  show: inline-code.with(size: 1em)
  [Розмір 1em: `same-size`. ]
}
#{
  show: inline-code.with(size: 11pt)
  [Розмір 11pt: `fixed-size`.]
}

#context {
  let loc(lbl) = query(lbl).first().location()
  let display-at(lbl) = {
    let el = query(lbl).first()
    numbering(el.numbering, ..counter(heading).at(el.location()))
  }

  // `plain-heading`: без номера і без розриву сторінки між «Мета роботи» та «Хід виконання»
  assert.eq(query(<goal>).first().numbering, none)
  assert.eq(query(<steps>).first().numbering, none)
  assert.eq(loc(<goal>).page(), loc(<steps>).page())

  // Підзаголовки під ненумерованим рівнем 1 без початкового «0.»
  assert.eq(display-at(<s1>), "1")
  assert.eq(display-at(<s1-1>), "1.1")
  assert.eq(display-at(<s2>), "2")

  // `style.appendices` після `plain-heading` зберігає літерну нумерацію
  let app1 = query(<app1>).first()
  assert.ne(app1.numbering, none)
  assert.eq(app1.supplement, [Додаток])
  assert.eq(display-at(<app1>), "А")
  assert.eq(display-at(<app1-1>), "А.1")

  // `plain-heading.with(numbering: auto, pagebreak: true)` зберігає нумерацію розділів
  // і скидає лічильники рисунків на новому розділі
  assert.eq(display-at(<num1>), "1")
  assert.eq(display-at(<num2>), "2")
  assert(loc(<num2>).page() > loc(<num1>).page())
  assert.eq(counter(figure.where(kind: image)).at(loc(<f-num1>)).first(), 1)
  assert.eq(counter(figure.where(kind: image)).at(loc(<f-num2>)).first(), 1)
}
