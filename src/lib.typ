#import "./shared.typ": universities
#import "./helpers.typ": *

#import "./style.typ"
#import "./utils.typ"

#let dstu-table = style.dstu-table
#let hfill = utils.hfill

// Constructor: work data + parts, assembled by the author.
#import "./work.typ": work
#import "./parts/common.typ": contents, doc-stats, dstu-bibliography, sort-keywords, title-heading
#import "./parts/forms.typ"
#import "./parts/report/main.typ" as report
#import "./parts/cw.typ" as cw
#import "./parts/cw-v2.typ" as cw-v2

// Recipes: whole documents assembled from the parts.
#import "./recipes.typ": coursework, coursework-v2, pz-lb
