#import "../src/lib.typ": pz-lb

#let data = toml("fixtures/data.toml")

#show: pz-lb.with(
  ..data,
  layout: "nure-iki",
)

== NURE IKI layout
#lorem(40)
