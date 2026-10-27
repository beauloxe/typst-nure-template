#import "../src/lib.typ": pz-lb

#let data = toml("fixtures/data.toml")

#show: pz-lb.with(..data)

== Default layout
This document verifies the default laboratory/practice title page.

== Content
#lorem(80)
