# Встановлення

Потрібен Typst 0.15 або новіший. Є три способи працювати з пакунком; для більшості студентів найзручніший перший.

- [mise](#mise-рекомендовано) -- кожна робота в окремій теці зі своїми версіями Typst і пакунка;
- [локальний пакунок Typst](#локальний-пакунок-typst) -- пакунок встановлюється один раз для всіх робіт;
- [окремими файлами](#окремими-файлами) -- код пакунка копіюється в проєкт.

## mise (рекомендовано)

[mise](https://mise.jdx.dev/) -- менеджер інструментів. Для кожної роботи він сам встановлює Typst, форматер typstyle, мовний сервер tinymist і завантажує пакунок `nure` зафіксованої ревізії. Глобально нічого ставити не треба, а оновлення Typst чи пакунка не зламає вже зроблені роботи: кожна пам'ятає свої версії.

### Нова робота

1. Встановіть [mise](https://mise.jdx.dev/getting-started.html) і `git`.
2. Скопіюйте шаблон роботи:
   ```sh
   git clone --depth 1 -b main https://github.com/beauloxe/typst-nure-template.git nure-template
   cp -r nure-template/template/mise lb1
   ```
   На Windows (PowerShell) замість `cp`: `Copy-Item -Recurse nure-template\template\mise lb1`.

   Склонований `nure-template` потрібен лише як джерело шаблону; його можна тримати для наступних робіт.
3. Запустіть:
   ```sh
   cd lb1
   mise trust      # дозволити mise виконувати задачі з цієї теки
   mise install    # встановити Typst та інші інструменти
   mise run watch  # завантажити пакунок і перезбирати main.pdf при кожному збереженні
   ```
4. Впишіть свої дані в `src/doc.toml` (див. [Дані роботи](data.md)), тип, номер і тему -- на початку `src/main.typ`, і пишіть текст (див. [Лабораторна чи практична](lab.md)).

### Тека роботи
```
lb1/
├── .mise/
│   ├── config.toml   -- інструменти, версія пакунка, задачі
│   └── mise.lock     -- точні версії інструментів
├── vendor/           -- пакунок nure (завантажується сам, у git не потрапляє)
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
| `mise run clean` | Видалити зібрані PDF |
| `mise run update-package-rev` | Оновити пакунок до останньої ревізії тієї ж версії |
| `mise run fetch-nure-package` | Завантажити пакунок (запускається сам перед `compile` і `watch`) |

`mise tasks` показує цей самий список. `clean`, `rename` і `update-package-rev` потребують POSIX-shell -- на Windows це Git Bash; решта працює всюди.

### Редактор

Рекомендований редактор -- VS Code (чи VSCodium) з розширенням [Tinymist](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist): підсвітка, автодоповнення з описом функцій пакунка, попередній перегляд.

Tinymist шукає пакунок `@vendor/nure` через змінну `TYPST_PACKAGE_PATH`, яку mise виставляє в теці роботи. Тому відкривайте редактор так, щоб він її бачив:
- запустіть його з теки роботи через mise: `mise exec -- code .`;
- або увімкніть [інтеграцію mise з оболонкою](https://mise.jdx.dev/getting-started.html#activate-mise) -- тоді `code .` з теки роботи теж підійде.

Інакше редактор підкреслюватиме імпорт як помилку, хоча `mise run watch` збиратиме PDF без проблем.

### Оновлення пакунка

Версія задається у `[vars]` файлу `.mise/config.toml`:

```toml
nure_package_ref = "main"        # гілка репозиторію
nure_package_rev = "828a058..."  # конкретний коміт у ній
nure_package_ver = "0.3.0"       # версія пакунка (`version` у його typst.toml)
```

- **Оновлення:** `mise run update-package-rev` -- `nure_package_rev` оновиться до останнього коміту `main`, наступний `compile` завантажить його.
- **Нова версія:** якщо після оновлення в `main` змінилася `version` у `typst.toml` (напр. на `0.4.0`), змініть `nure_package_ver = "0.4.0"` і версію в імпорті: `#import "@vendor/nure:0.4.0": *`. Перед цим прочитайте [Перехід зі старих версій](migration.md).

Здані роботи краще не оновлювати: вони й так збиратимуться на своїй ревізії.

## Локальний пакунок Typst

Пакунок встановлюється один раз у теку локальних пакунків Typst і доступний у всіх роботах як `@local/nure:0.3.0`. Typst при цьому ставите самі ([інструкція](https://github.com/typst/typst#installation)).

### Linux і macOS
```sh
git clone -b main https://github.com/beauloxe/typst-nure-template.git ~/.local/share/typst/packages/local/nure/0.3.0
```
На macOS тека пакунків -- `~/Library/Application Support/typst/packages/local/nure/0.3.0`.

### Windows
Найзручніше склонувати репозиторій у звичне місце і поставити на нього символьне посилання з теки пакунків -- тоді для оновлення достатньо `git pull`.

1. Склонуйте репозиторій (наприклад, у «Документи»):
   ```powershell
   cd $HOME\Documents
   git clone -b main https://github.com/beauloxe/typst-nure-template.git
   ```
2. Відкрийте PowerShell від імені адміністратора («Пуск» → PowerShell → правою кнопкою → «Запуск від імені адміністратора») і виконайте:
   ```powershell
   New-Item -ItemType Directory -Force -Path "$env:APPDATA\typst\packages\local\nure"
   New-Item -ItemType SymbolicLink -Path "$env:APPDATA\typst\packages\local\nure\0.3.0" -Target "$HOME\Documents\typst-nure-template"
   ```

Версія в назві теки (`0.3.0`) має збігатися з `version` у `typst.toml` пакунка, інакше Typst його не завантажить.

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
