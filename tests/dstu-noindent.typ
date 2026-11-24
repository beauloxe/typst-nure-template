// Пояснення познак під формулою -- з нового рядка без абзацного відступу,
// починаючи зі слова «де» (ДСТУ 3008:2015, 7.10.6): `utils.noindent`.
#import "../src/lib.typ": style, utils

#show: style.dstu

// Горизонтальна позиція мітки (порожній `box` -- метадані дають позицію
// абзацу, а не рядка)
#let x(l) = locate(l).position().x

= Розділ
Звичайний абзац із відступом.

#box[]<plain>Звичайний абзац.

$ beta = gamma / (2^gamma - 1) $
#utils.noindent #box[]<where>де $gamma$ -- частотна ефективність, $beta$ -- енергетична ефективність.

// Відступ в `em`
#[
  #set par(first-line-indent: (amount: 2em, all: true))
  $ a = b $
  #utils.noindent #box[]<where-em>де $a$ -- ...
]

// Без `all: true` Typst не відступає абзац після формули; noindent нічого не робить
#[
  #set par(first-line-indent: (amount: 1.25cm, all: false))
  $ c = d $
  #utils.noindent #box[]<where-noall>де $c$ -- ...
]

#context {
  let left = page.margin.left.length
  let indent = par.first-line-indent.amount
  assert(x(<plain>) - left > indent - 0.5pt, message: "звичайний абзац має відступ")
  for l in (<where>, <where-em>, <where-noall>) {
    assert(calc.abs(x(l) - left) < 0.5pt, message: str(l) + ": «де» не від лівого берега")
  }
}
