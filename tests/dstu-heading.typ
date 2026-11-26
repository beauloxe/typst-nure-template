// Заголовки нижчих рівнів під ненумерованим заголовком 1-го рівня не мають
// початкового «0.»: `==` нумерується як «1», `===` -- як «1.1».
// Також перевіряються `supplement` рівнів (7.11.2) і `contents()` (4.4.2, Додаток Б).
#import "../src/lib.typ": *

#show: style.dstu.with(section-numbering: false)

#contents()

#utils.nheading[Мета роботи]
Текст мети роботи.

#utils.nheading[Хід виконання] <sec>
== Перший пункт <s1>
Текст першого пункту.

=== Підпункт <s1-1>
Посилання на @s1, @s1-1, @s1-1-1, @sec-num та @app1.

==== Четвертий рівень <s1-1-1>
Текст четвертого рівня.

== Другий пункт <s2>
Текст другого пункту.

#heading(level: 2, numbering: none)[Ненумерований підзаголовок]
Текст без номера.

= Нумерований розділ <sec-num>
Текст розділу.

#utils.nheading[Висновки]
Текст висновків.

#show: style.appendices
= Перший додаток <app1>
== Підрозділ додатка <app1-1>
Текст додатка.

#context {
  let display-at(lbl) = {
    let el = query(lbl).first()
    numbering(el.numbering, ..counter(heading).at(el.location()))
  }
  assert.eq(display-at(<s1>), "1")
  assert.eq(display-at(<s1-1>), "1.1")
  assert.eq(display-at(<s2>), "2")

  // 7.11.2: кожен рівень має свій supplement, у додатках -- «Додаток»
  assert.eq(query(<sec>).first().supplement, [Розділ])
  assert.eq(query(<s1>).first().supplement, [Підрозділ])
  assert.eq(query(<s1-1>).first().supplement, [Пункт])
  assert.eq(query(<s1-1-1>).first().supplement, [Підпункт])
  assert.eq(query(<app1>).first().supplement, [Додаток])
}
