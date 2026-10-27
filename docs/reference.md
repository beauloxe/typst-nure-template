# Довідник

Усе, що експортує `#import "@vendor/nure:0.3.0": *` (або `@local/...`). Підказки з тими самими описами показує Tinymist у редакторі.

## Короткі назви

| Коротко | Повна назва | Опис |
| --- | --- | --- |
| `fig(file, caption, source, label: none, ..args)` | [`dstu-figure`](#dstu-figurefile-caption-source-label-none-args) | Рисунок |
| `tab(caption:, columns:, header:, label: none, ..args)` | [`dstu-table`](#dstu-tablecaption-columns-header-label-none-tag-none-args) | Таблиця |
| `bib(source, style: "3008", ..)` | [`dstu-bibliography`](#dstu-bibliographysource-style-3008-title-перелік-джерел-посилання-full-true) | Перелік джерел |

Короткі й повні назви -- одні й ті самі функції: аргументи й результат однакові. Див. [Короткі назви](writing.md#короткі-назви).

## Дані

### `work(...) -> dictionary`
Описує роботу; усі поля -- у [Дані роботи](data.md). Повертає словник з тими самими полями плюс:

| Поле | Значення |
| --- | --- |
| `w.uni` | Дані університету (`name`, `edu-programs`, `subjects`) |
| `w.edu` | Дані освітньої програми (`name-long`, `department-gen`, `code`, …) |
| `w.subject-name` | Повна назва дисципліни |
| `w.program-name` | Назва освітньої програми |
| `w.year` | Рік для титулки |
| `w.document` | Аргументи для `#set document(..w.document)`: тема й автори |

### `universities`
Вбудовані дані з `src/config/universities.yaml`.

## Стилі

### `style.dstu(skip: 0, offset: 0)`
Оформлення за ДСТУ 3008:2015: `#show: style.dstu.with(skip: 1)`.
- `skip` -- скільки перших сторінок лишити без номера (вони все одно рахуються);
- `offset` -- на скільки зсунути номери сторінок.

### `style.appendices`
Оформлення додатків: `#show: style.appendices`. Див. [Додатки](writing.md#додатки).

### Константи
`style.spacing` (міжрядковий інтервал, для `#v(-spacing)`), `style.indent-size` (абзацний відступ 1,25 см), `style.double-spacing`, `style.ukr-enum` (абетка для нумерації).

## Титулки звітів: `report`

### `report.title-page(w, layout: "default", header: auto, info: auto, credentials: auto, footer: auto)`
Титулка звіту з лабораторної, практичної тощо. `layout`: `"default"` (те саме, що `"nure"`) або `"complex"`. Слоти: `auto` -- вміст макета, свій вміст -- заміна, `none` -- порожньо. Див. [Лабораторна](lab.md#титульна-сторінка-reporttitle-page).

### `report.nure.*`, `report.complex.*`
Вміст слотів кожного макета: `default-header(w)`, `default-info(w)`, `default-credentials(w)`, `default-footer(w)`; та `title-page(w, ...)` конкретного макета.

### `title-heading(w)`
Заголовок першого рівня з темою, пронумерований номером роботи.

## Курсові: `cw`, `cw-v2`

| Функція | Опис |
| --- | --- |
| `cw.title-page(w)` | Титулка курсової роботи |
| `cw.task(w, source: [], content: [], graphics: [])` | Завдання; потребує `initial-date` і `done-date` |
| `cw.calendar-plan(w, plan-table, approval-date: auto)` | Календарний план; `auto` -- дата з `done-date` |
| `cw.abstract(w, keywords: (), body)` | Реферат |
| `cw.contents()` | Зміст |
| `cw-v2.title-page(w)` | Титулка комплексного курсового проєкту |
| `cw-v2.task(w, source: [], content: [])` | Завдання; потребує `done-date`; масив -- окремі підкреслені рядки |
| `cw-v2.calendar-plan(w, plan-table)` | Календарний план з підписами; потребує `initial-date` |
| `cw-v2.abstract(w, keywords: (), en-keywords: none, ..body)` | Реферат; `body` -- текст, за ним необов'язково англійський |
| `cw-v2.contents()` | Зміст з додатками у вигляді «Додаток А Назва» |

Див. [Курсова](coursework.md).

## Спільні блоки

### `contents(compact-appendices: false)`
Зміст до другого рівня заголовків. `compact-appendices: true` -- додатки як «Додаток А Назва» без підрозділів.

### `dstu-bibliography(source, style: "3008", title: [Перелік джерел посилання], full: true)`
Перелік джерел (коротко -- `bib`). `source` -- `path("bibl.yml")` або байти; `style` -- `"3008"`, `"8302"` або власний CSL як байти; `full: false` -- лише процитовані. Див. [Перелік джерел](writing.md#перелік-джерел).

### `doc-stats()`
Підсумки документа: «N с., N табл., N рис., N джерел» (нульові пропускаються).

### `sort-keywords(keywords, key: it => it)`
Сортує ключові слова: спершу кирилиця, далі за абеткою.

## Таблиці й рисунки

### `dstu-table(caption:, columns:, header:, label: none, tag: none, ..args)`
Скорочення для `figure(table(table.header(..header), ..args), caption: caption)` (ще коротше -- `tab`). `header` -- масив комірок шапки, `label` -- мітка (`<x>`), `tag` -- те саме рядком (для сумісності); решта передається в `table`. Перенос з «Продовження таблиці» `style.dstu` оформлює для будь-якої таблиці-`figure`. Див. [Таблиці](writing.md#таблиці).

### `dstu-figure(file, caption, source, label: none, ..args)`
Рисунок з підписом і приміткою про джерело (коротко -- `fig`). `file` -- `path(...)`; `source` (необов'язковий третій аргумент): не вказано або `()` -- без примітки, `none` -- «(рисунок виконано самостійно)», рядок -- «(за даними …)»; `label` -- мітка (`<x>`), без неї рисунок без мітки; решта передається в `image`. Є й як `utils.dstu-figure`. Див. [Рисунки](writing.md#рисунки).

## Утиліти: `utils`

| Функція | Опис |
| --- | --- |
| `utils.nheading(title)` | Ненумерований заголовок першого рівня («Вступ», «Висновки») |
| `utils.bold(content)` | Напівжирний текст |
| `utils.uline(align: center, content)` | Підкреслене поле на всю ширину |
| `utils.hfill(width)` / `hfill(width)` | Невидимий текст заданої ширини, щоб підкреслення тяглося |
| `utils.filled-lines(lines)` | Масив рядків → рядки, заповнені до кінця (для підкреслених полів) |
| `utils.ruled-field(value)` | Поле, де підкреслено кожен рядок при переносі |
| `utils.img-caption(caption, source)` | Підпис з приміткою про джерело |

## Поля форм: `forms`
Будівельні блоки офіційних сторінок для власних: `forms.note`, `forms.form-field`, `forms.label-line`, `forms.inline-label-line`, `forms.task-head-fields`, `forms.task-num`, `forms.title-field`, `forms.commission-lines`. Див. [Розширення](extending.md).

## Допоміжні функції

| Функція | Опис |
| --- | --- |
| `month-gen(n)` | Назва місяця в родовому відмінку: `month-gen(9)` → «вересня» |
| `gender-form(verb, gender: "p")` | `gender-form("author", gender: "f")` → «Виконала»; `"mentor"` → «Перевірив…» |
| `gender-get(people)` | Рід для списку людей: рід єдиної людини або `"p"` |
| `group-form(author)` | Шифр групи: «КУІБ-24-1» |
| `pz-lb-title(type, number: none)` | «Звіт з лабораторної роботи №2» за типом роботи |
| `key-get(dict, key)` | Значення або `none`, якщо ключа немає чи воно порожнє |
| `is-empty(value)` | Чи порожнє значення (`none`, `""`, `()`) |
| `is-cyr(text)` | Чи починається рядок з кириличної літери |
| `deep-merge(base, override)` | Рекурсивне злиття словників; `none` видаляє ключ |

## Рецепти

| Функція | Опис |
| --- | --- |
| `pz-lb` | Звіт з лабораторної чи практичної одним викликом: `#show: pz-lb.with(..toml("doc.toml"))` |
| `coursework` | Курсова робота одним викликом |
| `coursework-v2` | Комплексний курсовий проєкт одним викликом |

Див. [Лабораторна](lab.md#коротший-варіант-рецепт-pz-lb) і [Курсова](coursework.md#коротший-варіант-рецепти).
