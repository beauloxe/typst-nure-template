#import "nure.typ"
#import "complex.typ"

#let layouts = (
  "default": nure,
  "nure": nure,
  "complex": complex,
)

/// Титулка звіту з практичної/лабораторної (ЛБ, ПЗ, КР, РФ, ІДЗ).
///
/// - layout (str): "default" (те саме, що "nure") або "complex"
///
/// Сторінка складається з чотирьох слотів: header, info, credentials, footer.
/// Кожен за замовчуванням заповнюється вмістом макета; його можна замінити,
/// передавши `header:`, `info:`, `credentials:` чи `footer:` (або `none`,
/// щоб лишити слот порожнім). Вміст макетів доступний як функції,
/// напр. `report.nure.default-footer(w)`.
#let title-page(w, layout: "default", ..slots) = {
  assert(
    layout in layouts,
    message: "report: unknown layout " + repr(layout) + ", expected one of " + repr(layouts.keys()),
  )
  layouts.at(layout).title-page(w, ..slots)
}
