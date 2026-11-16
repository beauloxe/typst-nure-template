// Нумерація формул за ДСТУ 3008:2015, 7.10.2: номер мають лише формули, на
// які є посилання, і номери йдуть без пропусків -- у розділах і в додатках.
#import "../src/lib.typ": style

#show: style.dstu

= Перший розділ
$ a = 1.5 $
$ b = 2 $ <b>
$ c = 3 \ c_2 = 4 $ <c-unused>
$ d = 4 $ <d>
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
}
