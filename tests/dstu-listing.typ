// Лістинг-figure переходить на наступні сторінки з написом «Продовження
// лістингу N» / «Кінець лістингу N», як таблиця.
#import "../src/lib.typ": *
#show: style.dstu

= Розділ
Текст перед лістингом.

#figure(
  raw(range(1, 121).map(i => "printf(\"line " + str(i) + "\\n\");").join("\n"), lang: "c", block: true),
  caption: [Довга програма],
) <long>

#figure(
  ```bash
  for f in *.txt; do wc -l "$f"; done
  ```,
  caption: [Коротка програма],
) <short>

Текст після лістингу. Див. @long і @short.

#figure(
  ```c
  int main(void) { return 0; }
  ```,
  caption: [Плаваючий лістинг],
  placement: bottom,
)

#context {
  let page-of(key) = query(metadata.where(value: key)).first().location().page()
  // довгий лістинг займає кілька сторінок, короткий -- одну
  assert(page-of("dstu-figure-start-1") < page-of("dstu-figure-end-1"))
  assert.eq(page-of("dstu-figure-start-2"), page-of("dstu-figure-end-2"))
  // плаваючий лістинг не обгортається
  assert.eq(query(metadata).filter(m => type(m.value) == str and m.value.starts-with("dstu-figure-start-")).len(), 2)
}
