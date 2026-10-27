// dstu-figure with project-relative `path` values passed into the package.
#import "../src/lib.typ": *

#show: style.dstu

= Images
#dstu-figure(path("fixtures/figures/scheme.svg"), [Own scheme], none, width: 4cm, label: <own>)
#dstu-figure(path("fixtures/figures/scheme.svg"), [Borrowed scheme], "go.dev", width: 4cm, label: <borrowed>)
#dstu-figure(path("fixtures/figures/scheme.svg"), [Unlabelled], width: 4cm)

See @own and @borrowed.

#context assert.eq(query(figure).len(), 4)
#context assert.eq(query(<own>).len(), 1)

// Short aliases.
#assert.eq(tab, dstu-table)
#assert.eq(fig, dstu-figure)
#assert.eq(bib, dstu-bibliography)
#fig(path("fixtures/figures/scheme.svg"), [Alias], width: 4cm, label: <alias>)
#context assert.eq(query(<alias>).len(), 1)
