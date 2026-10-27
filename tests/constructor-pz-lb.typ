// Same document as pz-lb.typ, assembled from parts; must render identically.
#import "../src/lib.typ": *

#let w = work(..toml("fixtures/data.toml"))

#set document(..w.document)
#show: style.dstu.with(skip: 1)

#report.title-page(w)
#title-heading(w)

== Default layout
This document verifies the default laboratory/practice title page.

== Content
#lorem(80)
