# Розробка

## Структура

```
src/
├── lib.typ               -- точка входу: що експортує пакунок
├── work.typ              -- work(): нормалізація даних роботи
├── recipes.typ           -- pz-lb, coursework, coursework-v2 як композиції блоків
├── style/
│   ├── main.typ          -- точка входу модуля `style`
│   ├── dstu.typ          -- style.dstu (зокрема оформлення таблиць), style.appendices, dstu-table
│   └── overrides.typ     -- style.overrides.*: атомарні перевизначення (plain-heading, inline-code, ...)
├── utils.typ             -- utils.*: dstu-figure, nheading, ruled-field, uline, ...
├── helpers.typ           -- дрібні чисті функції: gender-form, group-form, deep-merge, ...
├── shared.typ            -- вбудовані дані (universities)
├── config/universities.yaml
├── csl/                  -- стилі переліку джерел (ДСТУ 3008, ДСТУ 8302)
└── parts/
    ├── base.typ          -- розкладка титулки з чотирьох слотів
    ├── common.typ        -- title-heading, contents, doc-stats, dstu-bibliography
    ├── forms.typ         -- поля форм (forms.*)
    ├── report/           -- титулки звітів: макети nure, complex і nure-iki
    ├── cw.typ            -- блоки курсової роботи
    └── cw-v2.typ         -- блоки комплексного курсового проєкту
template/
├── default/              -- шаблон для `typst init` (приклади лабораторної й курсових)
└── mise/                 -- шаблон роботи з mise
tests/                    -- документи, які компілює CI
docs/                     -- ця документація
```

Принципи:
- блоки -- чисті функції від `w` без глобального стану; усе, що потрібно кільком блокам, додається у `work`;
- рецепти не містять власної верстки, лише викликають блоки;
- публічні функції мають `///`-коментарі українською -- їх показує Tinymist.

## Тести

`tests/` містить документи, які CI компілює на кожен push:

- `pz-lb.typ`, `pz-lb-complex.typ`, `pz-lb-nure-iki.typ`, `coursework.typ`, `coursework-v2.typ` -- рецепти;
- `constructor-*.typ` -- ті самі документи, зібрані з блоків; CI рендерить обидва варіанти в PNG і перевіряє, що вони ідентичні;
- `constructor-features.typ`, `dstu-figure.typ`, `work-data.typ` -- слоти, рисунки, власні дані й чисті функції (через `assert`);
- `dstu-equation.typ`, `dstu-footnote.typ` -- номери лише в формул, на які є посилання, і нумерація виносок у межах сторінки (через `assert`);
- `style-overrides.typ` -- оверрайди `style.overrides.plain-heading` і `style.overrides.inline-code`, зокрема сумісність із `style.appendices` і параметрами `.with(...)`;
- `tables.typ` -- оформлення таблиць: перенос довгих таблиць, напис, додатки, а також що таблиця користувача лишається незмінною (координати комірок, `hline`, `fill`-функції, `set`/`show`-правила); `dstu-table.typ` і `constructor-dstu-table.typ` -- `dstu-table` і рівнозначний `figure(table(...))`, мають рендеритися однаково.

Крім того, CI збирає шаблони `template/default/*` і `template/mise` з поточним кодом пакунка й перевіряє, що mise-шаблон посилається на версію з `typst.toml`.

Локально (з кореня репозиторію):

```sh
typst compile --root . tests/coursework.typ /tmp/coursework.pdf
```

Порівняти рендер до і після змін:

```sh
typst compile --root . --ppi 72 tests/coursework.typ "/tmp/before/p{0p}.png"
# ...зміни...
typst compile --root . --ppi 72 tests/coursework.typ "/tmp/after/p{0p}.png"
diff <(cd /tmp/before && sha256sum *.png) <(cd /tmp/after && sha256sum *.png)
```

## Оформлення коду

```sh
typstyle -l 120 -i src tests template
```

## Версії та релізи

Пакунок дотримується [SemVer](https://semver.org/) у форматі `MAJOR.MINOR.PATCH` (Typst не приймає суфікси пререлізів у `typst.toml`), а кожна випущена версія вважається незмінною:

- `PATCH` (`0.3.0` → `0.3.1`) -- виправлення помилок, оновлення вбудованих даних, правки без ламання користувацьких документів;
- `MINOR` (`0.3.x` → `0.4.0`) -- нові можливості, ламаючі зміни API (для `0.x.y`) або підвищення мінімальної версії `compiler` у `typst.toml`.

Як випустити нову версію:

1. Додайте опис змін у секцію `## [Unreleased]` файлу [CHANGELOG.md](../CHANGELOG.md).
2. Запустіть `./scripts/release.py 0.3.1` -- скрипт оновить версію в `typst.toml`, шаблонах (`template/mise`, `template/default`), `README.md` і актуальній документації (не чіпаючи історичний [migration.md](migration.md)), перенесе `[Unreleased]` у `[0.3.1]` у `CHANGELOG.md`, перевірить компіляцію тестів і шаблонів, створить коміт `chore(release): v0.3.1` та анотований тег `v0.3.1` (для перевірки без коміту -- прапорець `--no-commit`).
3. Відправте гілку й тег: `git push origin main v0.3.1`.
4. Workflow [.github/workflows/release.yml](../.github/workflows/release.yml) перевіряє строгий формат тегу `vX.Y.Z` і збіг із `typst.toml` та шаблонами, проганяє тести, збирає `nure-<версія>.tar.gz` із структурою `vendor/nure/<версія>/...`, перевіряє компіляцію `template/mise` і публікує GitHub Release з нотатками із `CHANGELOG.md`.
5. У шаблонному [template/mise/.mise/mise.lock](../template/mise/.mise/mise.lock) зафіксовані лише зовнішні бінарі (`typst`, `tinymist`, `typstyle`, `dsty`) для основних платформ -- `nure` туди навмисно не записується, щоб уникнути повторних комітів після кожного релізу (у проєкті користувача `mise install` допише `nure` і його `sha256` автоматично). Оновити локфайл бінарів: `cd template/mise && mise lock --platform linux-x64,linux-arm64,macos-arm64,macos-x64,windows-x64 typst tinymist typstyle github:linerds/dsty`.
