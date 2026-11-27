# Встановлення

Потрібен Typst 0.15 або новіший. Є три способи працювати з пакунком; для більшості студентів найзручніший перший.

- [mise](#mise-рекомендовано) -- кожна робота в окремій теці зі своїми версіями Typst і пакунка;
- [локальний пакунок Typst](#локальний-пакунок-typst) -- пакунок встановлюється один раз для всіх робіт;
- [окремими файлами](#окремими-файлами) -- код пакунка копіюється в проєкт.

## mise (рекомендовано)

[mise](https://mise.jdx.dev/) -- менеджер інструментів. Для кожної роботи він сам встановлює Typst, форматер typstyle, мовний сервер tinymist, лінтер dsty й пакунок `nure` зафіксованої версії. Глобально нічого ставити не треба, а оновлення Typst чи пакунка не зламає вже зроблені роботи: кожна пам'ятає свої версії.

### Нова робота

1. Встановіть [mise](https://mise.jdx.dev/getting-started.html) (і `git`, щоб скопіювати шаблон).
2. Скопіюйте шаблон роботи:
   ```sh
   git clone --depth 1 -b v0.3.0 https://github.com/beauloxe/typst-nure-template.git nure-template
   cp -r nure-template/template/mise lb1
   ```
   На Windows (PowerShell) замість `cp`: `Copy-Item -Recurse nure-template\template\mise lb1`.

   Склонований `nure-template` потрібен лише як джерело шаблону; його можна тримати для наступних робіт.
3. Запустіть:
   ```sh
   cd lb1
   mise trust      # дозволити mise виконувати задачі з цієї теки
   mise install    # встановити Typst, інші інструменти й пакунок nure
   mise run watch  # перезбирати main.pdf при кожному збереженні
   ```
4. Впишіть свої дані в `src/doc.toml` (див. [Дані роботи](data.md)), тип, номер і тему -- на початку `src/main.typ`, і пишіть текст (див. [Лабораторна чи практична](lab.md)).

### Тека роботи

```
lb1/
├── .mise/
│   ├── config.toml   -- інструменти, версія пакунка, задачі
│   └── mise.lock     -- точні версії й контрольні суми інструментів і пакунка
├── main.pdf          -- результат
└── src/
    ├── doc.toml      -- спільні дані: дисципліна, автори, викладачі
    ├── main.typ      -- тип, номер, тема й текст роботи
    ├── utils.typ     -- ваші допоміжні функції
    ├── data.yaml     -- (необов'язково) власні дисципліни й університети
    ├── chapters/     -- розділи, якщо робота велика
    ├── figures/      -- рисунки
    └── assets/       -- інші файли: .csv, код, bibl.yml
```

Typst бачить лише теку `src/`: файли поза нею (`../щось`) прочитати не вийде, тож рисунки, джерела й дані кладіть у `src/`.

### Задачі

| Команда | Що робить |
| --- | --- |
| `mise run watch` | Перезбирати `main.pdf` при кожному збереженні |
| `mise run compile` | Зібрати `main.pdf` один раз |
| `mise run rename` | Зібрати й скопіювати PDF з назвою для здачі, напр. `ЛБ1_Косач_КУІБ-24-1_СМП.pdf` |
| `mise run format` | Відформатувати код у `src/` |
| `mise run lint` | Перевірити документ за допомогою `dsty` |
| `mise run clean` | Видалити зібрані PDF |

`mise tasks` показує цей самий список. `clean` і `rename` потребують POSIX-shell -- на Windows це Git Bash; решта працює всюди.

### Редактор

Рекомендований редактор -- VS Code (чи VSCodium) з розширенням [Tinymist](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist): підсвітка, автодоповнення з описом функцій пакунка, попередній перегляд.

Tinymist шукає пакунок `@vendor/nure` через змінну `TYPST_PACKAGE_PATH`, яку mise виставляє в теці роботи. Тому відкривайте редактор так, щоб він її бачив:
- запустіть його з теки роботи через mise: `mise exec -- code .`;
- або увімкніть [інтеграцію mise з оболонкою](https://mise.jdx.dev/getting-started.html#activate-mise) -- тоді `code .` з теки роботи теж підійде.

Інакше редактор підкреслюватиме імпорт як помилку, хоча `mise run watch` збиратиме PDF без проблем.

### Оновлення пакунка

Пакунок `nure` встановлюється з GitHub Releases як звичайний інструмент mise у спільне сховище (`~/.local/share/mise/installs/nure/<ver>`). Версія задається у `[tools]` файлу `.mise/config.toml`:

```toml
nure = { version = "0.3.0", asset_pattern = "nure-*.tar.gz", strip_components = 0 }
```

Щоб перейти на новий реліз (наприклад, `0.3.1` або `0.4.0`):
1. Перевірте доступні релізи: `mise ls-remote nure` (перед переходом на нову мінорну версію прочитайте [Перехід зі старих версій](migration.md)).
2. Змініть версію `nure` у `.mise/config.toml` і в імпорті `src/main.typ`: `#import "@vendor/nure:0.3.1": *`.
3. Виконайте `mise install`.

Старі версії пакунка, які більше не використовує жодна робота, прибирає `mise prune`. Здані роботи краще не оновлювати: вони й так збиратимуться на своїй версії.

### Підключення в наявний mise-проєкт

Якщо у вас уже є власний `mise.toml` і ви не копіюєте `template/mise`, підключіть пакунок через CLI:

```sh
mise config set tool_alias.nure "github:beauloxe/typst-nure-template"
mise config set --type string env.TYPST_PACKAGE_PATH.value '{% if tools.nure is defined %}{{ tools.nure.path }}{% endif %}'
mise config set --type bool env.TYPST_PACKAGE_PATH.tools true
mise use "nure[asset_pattern=nure-*.tar.gz,strip_components=0]@0.3.0"
```

Після цього в документі працюватиме `#import "@vendor/nure:0.3.0": *`, а `mise` зафіксує версію й `sha256` у вашому `mise.lock`.

## Локальний пакунок Typst

Пакунок встановлюється один раз у теку локальних пакунків Typst і доступний у всіх роботах як `@local/nure:0.3.0`. Typst при цьому ставите самі ([інструкція](https://github.com/typst/typst#installation)).

### Linux і macOS

```sh
git clone --depth 1 -b v0.3.0 https://github.com/beauloxe/typst-nure-template.git ~/.local/share/typst/packages/local/nure/0.3.0
```

На macOS тека пакунків -- `~/Library/Application Support/typst/packages/local/nure/0.3.0`.

### Windows

```powershell
git clone --depth 1 -b v0.3.0 https://github.com/beauloxe/typst-nure-template.git "$env:APPDATA\typst\packages\local\nure\0.3.0"
```

Версія в назві теки (`0.3.0`) має збігатися з `version` у `typst.toml` пакунка, інакше Typst його не завантажить. Для нової версії (наприклад, `0.3.1`) просто склонуйте відповідний тег у сусідню теку `0.3.1` -- старі роботи продовжать збиратися на `0.3.0`.

### Нова робота

```sh
typst init @local/nure:0.3.0 lb1
```

Створиться тека `lb1` з прикладами: `lab.typ` (лабораторна), `coursework.typ` і `coursework-v2.typ` (курсові) та `bibl.yml` (джерела). Зайве видаліть. В імпорті використовуйте `@local/nure:0.3.0` -- у документації приклади написано для mise, де це `@vendor/nure:0.3.0`.

Зібрати PDF: `typst watch lab.typ`. У VS Code з Tinymist нічого додатково налаштовувати не треба.

## Окремими файлами

Скопіюйте теку `src/` репозиторію в проєкт (можна перейменувати, наприклад, на `lib/`) та імпортуйте її напряму:

```typst
#import "/lib/lib.typ": *
```

Так зручно, якщо роботу збирає хтось інший, у кого пакунка немає. Оновлювати доведеться вручну.
