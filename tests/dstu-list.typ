// Переліки за ДСТУ 3008:2015, 7.7.2 і 7.7.4: кожен рівень починається з
// додаткового абзацного відступу (1,25 см), а перенесені рядки повертаються до
// лівого берега без висячого відступу (обхідне рішення для typst/typst#5751).
#import "../src/lib.typ": style

#show: style.dstu

#let pos(l) = locate(l).position()

// Позначає кожне слово міткою всередині `box`, щоб знайти початок першого
// перенесеного рядка незалежно від метрик шрифту (тег перед словом у параграфі
// може лишитися в кінці попереднього рядка, а всередині `box` переноситься з ним).
#let tracked-words(prefix, count) = {
  for i in range(count) {
    [#box[#metadata(none)#label(prefix + "-" + str(i))слово#str(i)] ]
  }
}

#let first-wrapped-x(prefix, count) = {
  let y0 = pos(label(prefix + "-0")).y
  for i in range(1, count) {
    let p = pos(label(prefix + "-" + str(i)))
    if p.y > y0 + 1pt { return p.x }
  }
  panic("рядок не перенісся: " + prefix)
}

= Переліки

#box[]<p-a>Звичайний абзац один.

#box[]<p-b>Звичайний абзац два:
- #box[]<l1>перший рядок #tracked-words("l1w", 25)кінець;
- #box[]<l2>пункт із вкладенням:
  - #box[]<l2-sub>вкладений рядок #tracked-words("l2w", 25)кінець;
  - #box[]<l2-sub2>другий вкладений;
- #box[]<l3>повернення на перший рівень.

#box[]<p-after>Абзац після маркованого списку.

== Нумерований і мішаний перелік

+ #box[]<e1>перший рівень #tracked-words("e1w", 25)кінець:
  + #box[]<e2>другий рівень #tracked-words("e2w", 25)кінець:
    - #box[]<e3>третій рівень #tracked-words("e3w", 25)кінець;
  + #box[]<e2-next>другий пункт другого рівня;
+ #box[]<e1-next>другий пункт першого рівня.

#pagebreak()
== Однорядкові відстані

#box[]<sp-p1>Перший однорядковий абзац.

#box[]<sp-p2>Другий однорядковий абзац:
- #box[]<sp-i1>однорядковий пункт 1:
  - #box[]<sp-n1>однорядковий вкладений 1;
  - #box[]<sp-n2>однорядковий вкладений 2;
- #box[]<sp-i2>однорядковий пункт 2.

#box[]<sp-p3>Абзац після списку.

== Кілька абзаців у пункті й нестандартні параметри

- #box[]<mp-1>Перший абзац пункту #tracked-words("mp1", 25)кінець.

  #box[]<mp-2>Другий абзац того ж пункту.

#[
  #set par(first-line-indent: (amount: style.indent-size, all: false))
  === Заголовок без `all: true`
  - #box[]<noall-1>перший пункт після заголовка;
  - #box[]<noall-2>другий пункт після заголовка.
]

3. починається з «в)»;
+ далі «г)»;
7. перескок на «ж)»;
+ далі «и)».

#enum(reversed: true)[третій][другий][перший]
#enum(reversed: true, enum.item(10)[десятий], [дев'ятий])

#[
  #set enum(full: true, numbering: "1.a)")
  + розділ 1
    + підпункт 1.a
    + підпункт 1.b
  + розділ 2
]

#[
  #set list(marker: ([•], [◦]))
  - глибокий 1
    - глибокий 2
      - глибокий 3
        - глибокий 4
          - глибокий 5
]

#list()
#enum()

#context {
  let left = page.margin.left.length
  let indent = style.indent-size
  let gap = 0.5cm
  let dash = measure[--].width
  let a-num = measure[а)].width
  let b-num = measure[б)].width
  let one-num = measure[1)].width
  let two-num = measure[2)].width

  // 1. Перші рядки списку на потрібному відступі рівня
  assert(calc.abs(pos(<l1>).x - (left + indent + dash + gap)) < 0.5pt, message: "l1 indent")
  assert(calc.abs(pos(<l2-sub>).x - (left + 2 * indent + dash + gap)) < 0.5pt, message: "l2-sub indent")
  assert(calc.abs(pos(<l3>).x - pos(<l1>).x) < 0.5pt, message: "l3 restores level 1 indent")

  // 2. Перенесені рядки -- від лівого берега на всіх рівнях
  assert(calc.abs(first-wrapped-x("l1w", 25) - left) < 0.5pt, message: "l1 wrap not at left margin")
  assert(calc.abs(first-wrapped-x("l2w", 25) - left) < 0.5pt, message: "l2-sub wrap not at left margin")
  assert(calc.abs(first-wrapped-x("e1w", 25) - left) < 0.5pt, message: "e1 wrap not at left margin")
  assert(calc.abs(first-wrapped-x("e2w", 25) - left) < 0.5pt, message: "e2 wrap not at left margin")
  assert(calc.abs(first-wrapped-x("e3w", 25) - left) < 0.5pt, message: "e3 wrap not at left margin")

  // 3. Нумерований і мішаний 3-рівневий перелік: а) -> 1) -> --
  assert(calc.abs(pos(<e1>).x - (left + indent + a-num + gap)) < 0.5pt, message: "e1 indent")
  assert(calc.abs(pos(<e2>).x - (left + 2 * indent + one-num + gap)) < 0.5pt, message: "e2 indent")
  assert(calc.abs(pos(<e3>).x - (left + 3 * indent + dash + gap)) < 0.5pt, message: "e3 indent")
  assert(calc.abs(pos(<e2-next>).x - (left + 2 * indent + two-num + gap)) < 0.5pt, message: "e2-next indent")
  assert(calc.abs(pos(<e1-next>).x - (left + indent + b-num + gap)) < 0.5pt, message: "e1-next indent")

  // 4. Вертикальні інтервали збігаються зі звичайними абзацами
  let base-dy = pos(<sp-p2>).y - pos(<sp-p1>).y
  for pair in (
    (<sp-p2>, <sp-i1>),
    (<sp-i1>, <sp-n1>),
    (<sp-n1>, <sp-n2>),
    (<sp-n2>, <sp-i2>),
    (<sp-i2>, <sp-p3>),
  ) {
    let dy = pos(pair.at(1)).y - pos(pair.at(0)).y
    assert(calc.abs(dy - base-dy) < 0.5pt, message: "spacing mismatch: " + str(pair.at(0)) + " -> " + str(pair.at(1)))
  }

  // 5. Другий абзац у пункті зберігає абзацний відступ
  assert(calc.abs(pos(<mp-2>).x - (left + indent)) < 0.5pt, message: "second paragraph indent")
  assert(calc.abs(first-wrapped-x("mp1", 25) - left) < 0.5pt, message: "mp-1 wrap not at left margin")

  // 6. Після заголовка без `all: true` обидва пункти вирівняні однаково
  assert(calc.abs(pos(<noall-1>).x - (left + indent + dash + gap)) < 0.5pt, message: "noall-1 indent")
  assert(calc.abs(pos(<noall-2>).x - pos(<noall-1>).x) < 0.5pt, message: "noall-2 matches noall-1")
}
