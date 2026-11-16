// Виноски за ДСТУ 3008:2015, 7.9.2: «1)» над рядком, нумерація в межах кожної
// сторінки. Вигляд (7.9.5, 7.9.6) -- кегль 12, абзацний відступ, лінія 35 мм.
#import "../src/lib.typ": style

#show: style.dstu

= Виноски
Текст#footnote[Перша виноска, досить довга, щоб перенестися на другий рядок і показати, що відступ має лише перший рядок.] <fn-a>
і ще#footnote[Друга.] <fn-b>
#lorem(40)

#pagebreak()
Нова сторінка#footnote[Знову перша.] <fn-c>

#context {
  let num(l) = counter(footnote).at(locate(l)).first()
  assert.eq(num(<fn-a>), 1)
  assert.eq(num(<fn-b>), 2)
  assert.eq(num(<fn-c>), 1)
}
