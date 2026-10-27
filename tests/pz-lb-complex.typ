#import "../src/lib.typ": pz-lb

#let data = toml("fixtures/data.toml")

#show: pz-lb.with(
  ..data,
  layout: "complex",
)

== Complex layout
#lorem(40)
