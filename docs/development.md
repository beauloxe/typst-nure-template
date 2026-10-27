# Розробка

Як влаштований репозиторій і як перевірити зміни перед тим, як запропонувати їх.

## Структура

```
src/
├── lib.typ               -- точка входу: що експортує пакунок
├── work.typ              -- work(): нормалізація даних роботи
├── recipes.typ           -- pz-lb, coursework, coursework-v2 як композиції блоків
├── style.typ             -- style.dstu, style.appendices, dstu-table
├── utils.typ             -- utils.*: img, nheading, uline, ...
├── helpers.typ           -- дрібні чисті функції: gender-form, group-form, deep-merge, ...
├── shared.typ            -- вбудовані дані (universities)
├── config/universities.yaml
├── csl/                  -- стилі переліку джерел (ДСТУ 3008, ДСТУ 8302)
└── parts/
    ├── base.typ          -- розкладка титулки з чотирьох слотів
    ├── common.typ        -- title-heading, contents, doc-stats, dstu-bibliography
    ├── forms.typ         -- поля форм (forms.*)
    ├── report/           -- титулки звітів: макети nure і complex
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

- `pz-lb.typ`, `pz-lb-complex.typ`, `coursework.typ`, `coursework-v2.typ` -- рецепти;
- `constructor-*.typ` -- ті самі документи, зібрані з блоків; CI рендерить обидва варіанти в PNG і перевіряє, що вони ідентичні;
- `constructor-features.typ`, `utils-img.typ`, `work-data.typ` -- слоти, рисунки, власні дані й чисті функції (через `assert`).

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

## Версії

- Кожна версія -- окрема гілка (`0.3.0`), `main` вказує на останню.
- Версія задається в `typst.toml`; ті самі цифри мають бути в імпортах шаблонів і в `nure_package_ref` mise-шаблону (це перевіряє CI).
- Після змін у гілці версії оновіть `nure_package_rev` у [template/mise/.mise/config.toml](../template/mise/.mise/config.toml) на новий коміт (`mise run update-package-rev` у копії шаблону або вручну).
