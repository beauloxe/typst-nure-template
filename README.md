# Шаблон Typst для робіт ХНУРЕ
<img src="assets/pz-lb_title_page.png" alt="Титульна сторінка лабораторної роботи" width=350>

## Загальне

Пакунок містить будівельні блоки й утиліти для оформлення робіт ХНУРЕ за ДСТУ 3008:2015. Усі функції мають документаційні коментарі, що відображаються через LSP (tinymist).

Документ збирається як конструктор:

1. **`work(...)`** один раз описує роботу (університет, дисципліна, автори, викладачі, тема, дати) і повертає звичайний словник. Це чиста функція: без глобального стану й `context`, тож результат можна використовувати будь-де.
2. **Блоки** -- чисті функції, що приймають цей словник і повертають сторінку чи її частину: титульні сторінки, завдання, календарний план, реферат, зміст, перелік джерел. Беріть потрібні, у будь-якому порядку, або замінюйте своїми.
3. **Стилі** (`style.dstu`, `style.appendices`) ви застосовуєте самі через show-правила.

Старі шаблони одним викликом (`pz-lb`, `coursework`, `coursework-v2`) лишилися як **рецепти**: кожен -- це просто композиція блоків (див. `src/recipes.typ`), тож наявні документи працюють як раніше.

Потрібен Typst 0.15 або новіший.

## Встановлення

### mise (рекомендовано)
[mise](https://mise.jdx.dev/) для кожної роботи сам встановлює Typst і супутні інструменти потрібних версій та завантажує пакунок зафіксованої ревізії. Глобально нічого ставити не треба, а оновлення Typst чи пакунка не зламає вже зроблені роботи.

```sh
git clone --depth 1 -b 0.3.0 https://github.com/beauloxe/typst-nure-template.git nure-template
cp -r nure-template/template/mise lb1   # Windows (PowerShell): Copy-Item -Recurse nure-template\template\mise lb1
cd lb1
mise trust
mise install
mise run watch
```

Задачі, оновлення пакунка й приклад організації цілого семестру -- у [template/mise/README.md](template/mise/README.md). У mise-проєкті пакунок імпортується як `@vendor/nure:0.3.0`.

### Локальний пакунок Typst

#### Linux / macOS
1. Склонуйте репозиторій у теку локальних пакунків Typst:
```bash
git clone -b 0.3.0 https://github.com/beauloxe/typst-nure-template.git ~/.local/share/typst/packages/local/nure/0.3.0
```
2. Створіть проєкт:
```bash
typst init @local/nure:0.3.0 назва-проєкту
```

#### Windows (символьне посилання)
Репозиторій клонується в зручне місце, а в теку пакунків Typst у `%APPDATA%` ставиться символьне посилання на нього. Перевага: щоб оновити шаблон, достатньо `git pull` у склонованій теці.

Крок 1 -- склонуйте шаблон (наприклад, у «Документи»):
```powershell
cd $HOME\Documents
git clone -b 0.3.0 https://github.com/beauloxe/typst-nure-template.git
```

Крок 2 -- створіть посилання (PowerShell від імені адміністратора):
1. Відкрийте «Пуск», знайдіть PowerShell, клацніть правою кнопкою і виберіть «Запуск від імені адміністратора».
2. Виконайте одним блоком:
```powershell
# Тека локальних пакунків (якщо її ще немає)
New-Item -ItemType Directory -Force -Path "$env:APPDATA\typst\packages\local\nure"

# Тека, куди склоновано репозиторій
$gitFolder = "$HOME\Documents\typst-nure-template"

# Посилання для версії пакунка (має збігатися з version у typst.toml)
New-Item -ItemType SymbolicLink -Path "$env:APPDATA\typst\packages\local\nure\0.3.0" -Target $gitFolder
```

Крок 3 -- відкрийте теку з роботою у VS Code з розширенням Tinymist, створіть `main.typ` та імпортуйте пакунок через `@local`, як у [швидкому старті](#швидкий-старт).

Версія в назві теки має збігатися з `version` у `typst.toml`, інакше Typst не завантажить пакунок.

### Окремими файлами
Скопіюйте `src/` у корінь проєкту (за бажання перейменувавши на `lib/`) та імпортуйте `src/lib.typ` або `lib/lib.typ`.

## Швидкий старт

```typst
#import "@local/nure:0.3.0": *
#import style: spacing

// 1. Описуємо роботу один раз
#let w = work(
  subject: "СМП",
  type: "ЛБ",
  number: 2,
  title: "Потiк керування та алгоритмічні структури Bash",
  authors: ((name: "Косач Л. П.", edu-program: "КУІБ", group: "23-2", gender: "f", variant: 8),),
  mentors: ((name: "Шевченко Т. Г.", degree: "Доцент кафедри ПІ", gender: "m"),),
)
// ...або тримаємо дані у файлі
// #let w = work(..toml("doc.toml"))

// 2. Метадані документа і стилі ДСТУ
#set document(..w.document)
#show: style.dstu.with(skip: 1) // skip: кількість ненумерованих титульних сторінок

// 3. Збираємо документ з блоків
#report.title-page(w)
#title-heading(w) // "= <тема>", нумерується номером роботи

#v(-spacing)
== Мета роботи
...

#show: style.appendices
= Код програми
```

`typst init @local/nure:0.3.0 назва-проєкту` створює проєкт з `template/default/lab.typ`; `coursework.typ` і `coursework-v2.typ` у тій самій теці -- повні приклади курсових.

## Довідник

### `work(...)`
| Аргумент | Опис |
| --- | --- |
| `university` | Код університету з `src/config/universities.yaml`, за замовчуванням `"ХНУРЕ"` |
| `edu-program` | Код освітньої програми, за замовчуванням -- першого автора |
| `subject` | Код дисципліни з `universities.yaml` (або довільний текст) |
| `type`, `number` | Тип роботи (`ЛБ`, `ПЗ`, `КР`, `РФ`, `ІДЗ` або довільний текст) і номер |
| `title` | Тема: рядок (у `title-heading` обробляється як розмітка), вміст або масив рядків |
| `authors`, `mentors` | Масиви словників, див. приклад TOML нижче; перший викладач -- керівник |
| `committee-members` | Члени комісії для `cw-v2.title-page`, за замовчуванням -- усі викладачі, крім першого |
| `initial-date`, `done-date` | Дати видачі й здачі завдання (`datetime`), потрібні блокам курсових |
| `year` | Рік на титулці, за замовчуванням -- з `done-date` або поточний |
| `faculty`, `education-level`, `program-type`, `program-name` | Поля сторінок `cw-v2` |
| `data` | Власні університети, освітні програми й дисципліни поверх вбудованих (див. [Власні дані](#власні-дані)) |

Крім аргументів, результат містить знайдені дані: `w.uni`, `w.edu`, `w.subject-name`, `w.program-name` і `w.document` (аргументи для `set document`). Це звичайний словник, тож для власних блоків у нього можна додати свої поля: `work(...) + (consultant: "Драч І. Ф.")`.

Вбудовані дані експортуються як є: `universities.at("ХНУРЕ").subjects.at("БД")`.

### Власні дані
`src/config/universities.yaml` містить вбудовані університети, освітні програми й дисципліни. Щоб додати чи змінити їх без правок пакунка, тримайте у проєкті файл такого самого формату і передайте його у `work`:

```yaml
# my-data.yaml
ХНУРЕ:
  edu-programs:
    ПЗПІ:
      code: F2          # змінити одне поле, решта лишається вбудованою
    ШІ:                 # додати програму
      name-long: Штучний інтелект
      department-gen: Штучного інтелекту
      code: 122
    КНТ: null           # прибрати програму
  subjects:
    НовДис: Нова дисципліна

КПІ:                    # додати університет
  name: Національний технічний університет України «Київський політехнічний інститут імені Ігоря Сікорського»
  edu-programs:
    ІПЗ:
      name-long: Інженерія програмного забезпечення
      department-gen: Інформатики та програмної інженерії
      code: 121
  subjects:
    ОП: Основи програмування
```

```typst
#let w = work(..toml("doc.toml"), data: yaml("my-data.yaml"))
```

Словники зливаються поключово (`deep-merge`), `null` видаляє ключ, будь-яке інше значення замінює вбудоване. Університету потрібне `name`, освітній програмі -- `name-long`, `department-gen` і `code` (`description` і `program-name` необов'язкові). Те, що не береться з даних, як-от місто у футері титулки, змінюється [слотами](#слоти-титульної-сторінки): `#report.title-page(w, footer: [Київ -- #w.year])`.

### Блоки
| Блок | Опис |
| --- | --- |
| `report.title-page(w, layout: "default")` | Титулка звіту з практичної/лабораторної; макети `"default"` (`"nure"`), `"complex"` |
| `title-heading(w)` | Заголовок першого рівня з темою, нумерується номером роботи |
| `cw.title-page(w)` | Титулка курсової роботи |
| `cw.task(w, source:, content:, graphics:)` | Завдання на курсову |
| `cw.calendar-plan(w, table, approval-date: auto)` | Календарний план |
| `cw.abstract(w, keywords: (...))[текст]` | Реферат з підсумками документа; ключові слова сортуються |
| `cw.contents()` | Зміст |
| `cw-v2.title-page(w)` | Титулка комплексного курсового проєкту |
| `cw-v2.task(w, source:, content:)` | Завдання; масив розбивається на підкреслені рядки |
| `cw-v2.calendar-plan(w, table)` | Календарний план з підписами |
| `cw-v2.abstract(w, keywords: (...))[укр][англ]` | Реферат, за потреби двомовний; ключові слова -- пари `(укр, англ)` або рядки з `en-keywords:` |
| `cw-v2.contents()` | Зміст, де додатки подано як «Додаток А ...» |
| `dstu-bibliography(path("bibl.yml"), style: "3008")` | Перелік джерел за ДСТУ 3008:2015 (`"3008"`) або ДСТУ 8302:2015 (`"8302"`) |
| `contents(compact-appendices: false)` | Зміст |
| `doc-stats()` | Підсумки документа: «N с., N табл., N рис., N джерел» |
| `forms.*` | Поля форм з офіційних сторінок (`label-line`, `note`, `commission-lines`, ...) для власних сторінок |

#### Слоти титульної сторінки
Титулка звіту складається з чотирьох слотів: `header`, `info`, `credentials`, `footer`. Кожен за замовчуванням заповнюється вмістом макета, його можна замінити своїм або прибрати через `none`. Вміст макетів доступний як функції, тож його можна взяти й доповнити:

```typst
#report.title-page(
  w,
  layout: "complex",
  footer: [Харків\ 2026],
  info: [#report.complex.default-info(w) \ Підгрупа 2],
)
```

### Рецепти
Шаблони одним викликом доступні й дають той самий результат, що й раніше:

```typst
#show: pz-lb.with(..toml("doc.toml"))                   // практичні й лабораторні роботи
#show: coursework.with(title: ..., task-list: ..., ...) // курсові роботи (ДСТУ 3008)
#show: coursework-v2.with(title: ..., ...)              // комплексний курсовий проєкт (ДСТУ 8302)
```

Це короткі композиції блоків. Щоб змінити одну сторінку рецепта, скопіюйте його тіло з `src/recipes.typ` у свій документ і відредагуйте.

### Утиліти
- `nheading` -- ненумерований заголовок, як-от «Вступ» чи «Висновки».
- `hfill` -- заповнює горизонтальний простір невидимим текстом, а не порожнечею; зручно для підкреслень.
- `uline` -- підкреслене поле для заповнення, як ПІБ на сторінці завдання.
- `bold` -- напівжирний текст усередині функцій.
- `dstu-table` -- таблиця з написами «Продовження таблиці» при переносі на нову сторінку.
- `img` -- рисунок з підписом і міткою, що виводиться з назви файлу:
  ```typst
  #utils.img(path("figures/chapter1/scheme.png"), [Схема])             // <chapter1_scheme>, «(рисунок виконано самостійно)»
  #utils.img(path("figures/net.png"), [Мережа], "cisco.com", width: 80%) // «(за даними cisco.com)»
  #utils.img(path("figures/net.png"), [Мережа], (), label: <net>)        // без примітки про джерело, своя мітка
  ```

### Шляхи до файлів
Рядковий шлях, переданий у функцію пакунка, шукається відносно **пакунка**, а не вашого проєкту: `image("figures/a.png")` усередині пакунка шукатиме `~/.local/share/typst/packages/local/nure/0.3.0/figures/a.png`. У Typst 0.15 з'явився тип `path`, який пам'ятає файл, де його записано, тож назви файлів, що передаються в пакунок, обгортайте в `path()`:

```typst
#utils.img(path("figures/a.png"), [Рисунок])
#dstu-bibliography(path("bibl.yml"))
#show: coursework.with(bib-path: path("bibl.yml"), ...)
```

`utils.img` відхиляє звичайні рядки з підказкою. Саме тому пакунок потребує Typst 0.15 або новішого.

## Приклад проєкту
```typst
// Імпорт пакунка: локального (у mise-проєкті -- @vendor/nure:0.3.0)...
#import "@local/nure:0.3.0": *
// ...або напряму з lib.typ
// #import "/lib/lib.typ": *
#import style: spacing

// ПРИМІТКА: усі аргументи пишуться в kebab-case.

#let w = work(..toml("/doc.toml"))
#set document(..w.document)
#show: style.dstu.with(skip: 1)

#report.title-page(w)
#title-heading(w)

// Текст роботи
#v(-spacing) // прибрати інтервал між заголовками
== Мета роботи
Текст

// ...або окремі файли
#include "chapters/intro.typ"
#include "chapters/chapter1.typ"
#include "chapters/chapter2.typ"
// ПРИМІТКА: щоб використовувати змінні чи утиліти пакунка всередині такого файлу,
// імпортуйте пакунок і в ньому (напр. #import "@local/nure:0.3.0": utils).

// Перелік джерел -- перед додатками
#dstu-bibliography(path("bibl.yml"), style: "3008")

#show: style.appendices

= Цитата
#link("https://youtu.be/bJQj1uKtnus")[
  The art isn't the art, the art is never the art,
  the art is the thing that happens inside you when you make it and the feeling in the heart of the beholder.
]
```

Файл TOML виглядає так:
```toml
# university = "ХНУРЕ" # "ХНУРЕ" за замовчуванням
# edu-program = "ПЗПІ" # за замовчуванням береться з authors.first()

subject = "СМП"
type = "ЛБ"
number = 2
title = "Потiк керування та алгоритмічні структури Bash"

[[mentors]]
name = "Шевченко Т. Г."
degree = "Доцент кафедри ПІ"
gender = "m"

[[mentors]]
name = "Франко І. Я."
degree = "Асистент кафедри ПІ"
gender = "m"

[[authors]]
name = "Косач Л. П."
edu-program = "ПЗПІ"
group = "23-2"
gender = "f"
variant = 8
# Для курсових
full-name-gen = "Косач Лариси Петрівни"
course = 2
semester = 4
```

### Примітки
1. `#v(-spacing)` прибирає вертикальний інтервал між заголовками (шаблон не може зробити це сам). Змінна `spacing` імпортується з пакунка.
2. Назви файлів, що передаються в пакунок, обгортайте в `path()`, див. [Шляхи до файлів](#шляхи-до-файлів).

### Перелік джерел
Записи оформлюються власними CSL-стилями: `src/csl/dstu-3008-2015.csl` і `src/csl/dstu-8302-2015.csl`.

Підтримувані типи записів у `bibl.yml`:
- **Book**: книги з автором, назвою, видавництвом, роком і кількістю сторінок
- **Web**: вебресурси з назвою, автором/організацією, URL і датою звернення

**Увага:** інші типи не перевірено на відповідність стандарту, не раджу їх використовувати.

Приклад `bibl.yml`:
```yaml
mysql:
  type: Book
  title: MySQL Language Reference
  author: Ab M.
  publisher: MySQL Press
  date: 2004
  page-total: 600

go:
  type: Web
  title: The Go Programming Language
  author: The Go Programming Language
  url:
    value: https://go.dev/
    date: 2024-12-10
```

### Структура проєкту
```
project/
├── doc.toml -- дані, що не змінюються між роботами: автори, викладачі
├── main.typ -- головний файл
├── utils.typ -- допоміжні функції
├── chapters/
│   ├── intro.typ
│   ├── chapter1.typ
│   ├── chapter2.typ
│   └── ...
├── figures/
│   ├── chapter1/
│   │   ├── figure1.png
│   │   ├── figure2.png
│   │   └── ...
│   └── ...
└── ...
```

У mise-проєкті все це лежить у `src/`, див. [template/mise/README.md](template/mise/README.md).

## Подяки
Проєкт продовжує [typst_nure_template](https://github.com/linerds/typst_nure_template). Дякуємо його авторам: unexplrd, Anton Bilous, Sytnyk Yehor, pencelheimer, ilyaoc, dxrknesss, bosiiandgolii, sekomi.

## Тести
`tests/` містить документи, які компілює CI (`.github/workflows/typst.yml`). Кожен `constructor-*.typ` збирає з блоків той самий документ, що й однойменний тест рецепта, тож вони мають рендеритися однаково; `constructor-features.typ`, `utils-img.typ` і `work-data.typ` перевіряють слоти, рисунки, власні дані й чисті функції через `assert`. Шаблон `template/mise` збирається з поточним кодом пакунка.
