// Нумерація й оформлення формул за ДСТУ 3008:2015:
// - 7.10.1: відступ зверху й знизу не менше ніж один рядок (`double-spacing`);
// - 7.10.2: номер мають лише формули, на які є посилання, без пропусків;
// - 7.10.4: у багаторядкових формулах номер на рівні останнього рядка (`end + bottom`).
#import "../src/lib.typ": style

#show: style.dstu

= Перший розділ
#box[]<p1>Перший абзац тексту.

#box[]<p2>Другий абзац тексту.

$ a = 1.5 $

#box[]<p3>Третій абзац тексту.

$ b = 2 $ <b>
$ c = 3 \ c_2 = 4 $ <c-unused>
$ d = 4 \ + 5 \ + 6 $ <d>
$ e = 5 $
#[
  #set math.equation(numbering: none)
  $ f = 6 $
]

За формулою @b і формулою @d. Явне `numbering: none` (формула $f$) лишається як є.

= Другий розділ
$ g = 1 $ <g>
Див. @g, а також з першого розділу @d.

#show: style.appendices

= Додаток
$ h = 1 $
$ i = 2 $ <i>
Див. @i.

// Номер формули -- значення лічильника в її місці
#let num(l) = counter(math.equation).at(locate(l)).first()
#context {
  assert.eq(num(<b>), 1)
  assert.eq(num(<d>), 2)
  assert.eq(num(<g>), 1)
  assert.eq(num(<i>), 1)

  // 7.10.4: вирівнювання номера по останньому рядку
  assert.eq(math.equation.number-align, end + bottom)

  // 7.10.1: відстань над і під формулою більша за звичайний міжрядковий інтервал
  let y(l) = locate(l).position().y
  let par-dy = y(<p2>) - y(<p1>)
  let eq-span = y(<p3>) - y(<p2>)
  assert(
    eq-span > 2 * par-dy + style.spacing.to-absolute(),
    message: "block equation must have extra vertical spacing above and below",
  )
}
