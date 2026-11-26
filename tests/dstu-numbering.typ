// Наскрізна нумерація рисунків, таблиць, лістингів і формул:
// `style.dstu.with(section-numbering: false)` без скидання на розділах,
// але з літерною нумерацією в додатках (`А.1`).
#import "../src/lib.typ": *

#show: style.dstu.with(section-numbering: false)

// Рисунок до першого заголовка 1-го рівня (раніше посилався як «рис. 0.1»)
#fig(path("fixtures/figures/scheme.svg"), [До розділу], width: 3cm, label: <f1>)

Див. (@f1[рис.]) та @f2, а також @app-fig[рисунок] у додатку.

= Перший розділ

#fig(path("fixtures/figures/scheme.svg"), [У першому розділі], width: 3cm, label: <f2>)

#tab(
  caption: [Перша таблиця],
  columns: 2,
  header: ([A], [B]),
  label: <t1>,
  [1], [2],
)

#figure(```c
int a = 1;
```, caption: [Перший лістинг]) <l1>

$ a = 1 $
$ b = 2 $ <eq1>

Посилання: @f2[рис.], @t1[табл.], @l1[лістинг], @eq1[формула].

= Другий розділ

#fig(path("fixtures/figures/scheme.svg"), [У другому розділі], width: 3cm, label: <f3>)

#tab(
  caption: [Друга таблиця],
  columns: 2,
  header: ([C], [D]),
  label: <t2>,
  [3], [4],
)

#figure(```c
int b = 2;
```, caption: [Другий лістинг]) <l2>

$ c = 3 $ <eq2>

Посилання: @f3[рис.], @t2[табл.], @l2[лістинг], @eq2[формула].

#show: style.appendices

= Додаток
#fig(path("fixtures/figures/scheme.svg"), [Рисунок у додатку], width: 3cm, label: <app-fig>)
$ d = 4 $ <eq-app>

Посилання в додатку: @app-fig[рис.], @eq-app[формула].

#context {
  let fig-num(kind, lbl) = counter(figure.where(kind: kind)).at(locate(lbl)).first()
  let eq-num(lbl) = counter(math.equation).at(locate(lbl)).first()

  // Наскрізні лічильники в основній частині не скидаються між розділами
  assert.eq(fig-num(image, <f1>), 1)
  assert.eq(fig-num(image, <f2>), 2)
  assert.eq(fig-num(image, <f3>), 3)
  assert.eq(fig-num(table, <t1>), 1)
  assert.eq(fig-num(table, <t2>), 2)
  assert.eq(fig-num(raw, <l1>), 1)
  assert.eq(fig-num(raw, <l2>), 2)
  assert.eq(eq-num(<eq1>), 1)
  assert.eq(eq-num(<eq2>), 2)

  // У додатку лічильники скидаються й мають літерну нумерацію
  assert.eq(fig-num(image, <app-fig>), 1)
  assert.eq(eq-num(<eq-app>), 1)

  // Нумерація елементів відповідає налаштуванню
  assert.eq(query(<f1>).first().numbering, "1")
  assert.eq(numbering(query(<eq1>).first().numbering, 1), "(1)")
}
