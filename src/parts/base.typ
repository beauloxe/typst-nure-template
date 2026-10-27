/// Розкладає титульну сторінку з чотирьох слотів.
///
/// Лише розміщує слоти по вертикалі й не має власного вмісту -- вміст кожного
/// слота будує конкретний макет (див. `report/nure.typ`, `report/complex.typ`),
/// він же вирішує, що робити з `auto` ("взяти вміст макета").
#let title-page(header, info, credentials, footer) = {
  align(center)[
    #header \ 
    #info
    #v(1fr)
    #credentials
    #v(1fr)
    #footer
  ]
}
