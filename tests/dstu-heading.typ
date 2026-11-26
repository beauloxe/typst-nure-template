// Заголовки нижчих рівнів під ненумерованим заголовком 1-го рівня не мають
// початкового «0.»: `==` нумерується як «1», `===` -- як «1.1».
#import "../src/lib.typ": *

#show: style.dstu.with(section-numbering: false)

#contents()

#utils.nheading[Мета роботи]
Текст мети роботи.

#utils.nheading[Хід виконання]
== Перший пункт <s1>
Текст першого пункту.

=== Підпункт <s1-1>
Посилання на @s1 та @s1-1.

== Другий пункт <s2>
Текст другого пункту.

#heading(level: 2, numbering: none)[Ненумерований підзаголовок]
Текст без номера.

#utils.nheading[Висновки]
Текст висновків.

#context {
  let display-at(lbl) = {
    let el = query(lbl).first()
    numbering(el.numbering, ..counter(heading).at(el.location()))
  }
  assert.eq(display-at(<s1>), "1")
  assert.eq(display-at(<s1-1>), "1.1")
  assert.eq(display-at(<s2>), "2")
}
