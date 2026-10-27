// utils.img with project-relative `path` values passed into the package.
#import "../src/lib.typ": *

#assert.eq(utils.path-str(path("fixtures/figures/scheme.svg")), "/tests/fixtures/figures/scheme.svg")
#assert.eq(utils.path-str("a/b.png"), "a/b.png")
#assert.eq(utils.img-label(path("fixtures/figures/scheme.svg")), <figures_scheme>)
#assert.eq(utils.img-label("scheme.png"), <scheme>)

#show: style.dstu

= Images
#utils.img(path("fixtures/figures/scheme.svg"), [Own scheme], none, width: 4cm)
#utils.img(path("fixtures/figures/scheme.svg"), [Borrowed scheme], "go.dev", width: 4cm, label: <borrowed>)
#utils.img(path("fixtures/figures/scheme.svg"), [Unlabelled], width: 4cm, label: none)

See @figures_scheme and @borrowed.

#context assert.eq(query(figure).len(), 3)
#context assert.eq(query(<figures_scheme>).len(), 1)
