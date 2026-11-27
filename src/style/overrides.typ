#import "dstu.typ": _reset-section-counters, code-font, double-spacing

/// Спрощене оформлення заголовків першого рівня: без номера, по центру,
/// звичайним накресленням, великими літерами й без розриву сторінки.
/// Застосовується після `style.dstu`: `#show: style.overrides.plain-heading`.
///
/// Якщо всі заголовки першого рівня без номера, для наскрізної нумерації
/// рисунків, таблиць, лістингів і формул передайте
/// `style.dstu.with(section-numbering: false)`.
///
/// - numbering (none, str, function, auto): Нумерація заголовків 1-го рівня;
///   типово `none` (без номера), `auto` -- лишити нумерацію з `style.dstu`
/// - alignment (alignment): Вирівнювання заголовка (типово `center`)
/// - weight (str, int): Накреслення тексту (типово `"regular"`)
/// - size (length): Кегль тексту (типово `14pt`)
/// - uppercase (bool): Переводити текст у верхній регістр (типово `true`)
/// - pagebreak (bool): Починати заголовок з нової сторінки (типово `false`)
/// - above (length): Відступ над заголовком (типово `double-spacing`)
/// - below (length): Відступ під заголовком (типово `double-spacing`)
#let plain-heading(
  body,
  numbering: none,
  alignment: center,
  weight: "regular",
  size: 14pt,
  uppercase: true,
  pagebreak: false,
  above: double-spacing,
  below: double-spacing,
) = {
  show heading.where(level: 1): set heading(numbering: numbering) if numbering != auto

  show heading.where(level: 1): it => {
    if it.numbering != none {
      _reset-section-counters()
    }
    if pagebreak {
      std.pagebreak(weak: true)
    }
    set align(alignment)
    set text(size: size, weight: weight)
    set par(first-line-indent: 0pt, justify: false)
    let content = if it.numbering != none {
      [#counter(heading).display(it.numbering) #it.body]
    } else {
      it.body
    }
    block(
      width: 100%,
      above: above,
      below: below,
      sticky: true,
      if uppercase { upper(content) } else { content },
    )
  }

  body
}

/// Моноширинний інлайн-код (`` `код` ``) замість лапок у `Times New Roman`,
/// які за замовчуванням ставить `style.dstu`.
/// Застосовується після `style.dstu`: `#show: style.overrides.inline-code`.
///
/// Без `fill` і `stroke` виводиться як звичайний текст (переноситься між
/// рядками); із `fill` або `stroke` загортається в `box`.
///
/// - font (str, array): Шрифт коду (типово `("Courier New", "Liberation Mono")`)
/// - size (auto, length): Кегль коду; `auto` -- типовий для Typst (`0.8em` від
///   навколишнього тексту: ~11.2 pt в основному тексті, ~9.6 pt у примітках);
///   відносні одиниці (`em`) рахуються від навколишнього тексту
/// - weight (str, int): Накреслення тексту (типово `"regular"`)
/// - fill (none, color, gradient, tiling): Тло плашки (типово `none`)
/// - stroke (none, stroke, color, length, dictionary): Рамка плашки (типово `none`)
/// - inset (length, dictionary): Внутрішні відступи плашки (типово `(x: 0.25em)`)
/// - outset (length, dictionary): Зовнішні відступи плашки (типово `(y: 0.2em)`)
/// - radius (length, dictionary): Заокруглення кутів плашки (типово `2pt`)
#let inline-code(
  body,
  font: code-font,
  size: auto,
  weight: "regular",
  fill: none,
  stroke: none,
  inset: (x: 0.25em),
  outset: (y: 0.2em),
  radius: 2pt,
) = {
  show raw.where(block: false): it => {
    // Виводимо рядки напряму (`it.lines`), а не `it`, щоб перекрити зовнішнє
    // show-правило `raw.where(block: false)` зі `style.dstu` і зберегти підсвітку.
    let content = it.lines.map(l => l.body).join(linebreak())
    // Typst зменшує `raw` до 0.8em; якщо задано явний `size`, спершу повертаємо
    // масштаб навколишнього тексту (`1.25em`), щоб `0.9em` рахувалося від нього.
    let styled = if size != auto {
      text(size: 1.25em, text(font: font, size: size, weight: weight, hyphenate: false, content))
    } else {
      text(font: font, weight: weight, hyphenate: false, content)
    }

    if fill != none or stroke != none {
      box(fill: fill, stroke: stroke, inset: inset, outset: outset, radius: radius, styled)
    } else {
      styled
    }
  }

  body
}
