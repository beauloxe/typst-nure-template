// Same document as pz-lb-complex.typ, assembled from parts; must render identically.
#import "../src/lib.typ": *

#let w = work(..toml("fixtures/data.toml"))

#set document(..w.document)
#show: style.dstu.with(skip: 1)

#report.title-page(w, layout: "complex")
#title-heading(w)

== Complex layout
#lorem(40)
