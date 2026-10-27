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
4. Впишіть свої дані в `src/doc.toml` (див. [Дані роботи](data.md)) і пишіть текст у `src/main.typ` (див. [Лабораторна чи практична](lab.md)).

### Тека роботи
```
lb1/
├── .mise/
│   ├── config.toml   -- інструменти, версія пакунка, задачі
│   └── mise.lock     -- точні версії інструментів
├── vendor/           -- пакунок nure (завантажується сам, у git не потрапляє)
├── main.pdf          -- результат
└── src/
    ├── doc.toml      -- дані роботи
    ├── main.typ      -- текст роботи
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

### Організація семестру
Підхід [unexplrd](https://gitea.linerds.us/unexplrd): одна тека на семестр, шаблон роботи і nushell-задача, яка створює нову роботу й заповнює `doc.toml`.

```
/home/user/Documents/nure/
└── .config/
    ├── defaults.yaml
    ├── subjects.yaml
    ├── mise/
    │   ├── config.toml
    │   └── mise.lock
    └── template/        -- ця тека (template/mise) без doc.toml
        ├── .mise/
        └── src/
```

<details><summary>Вміст <code>.config/defaults.yaml</code></summary><p>

```yaml
university: ХНУРЕ
default_author:
  name: Косач Л. П.
  edu-program: ПЗПІ
  group: 23-2
  gender: f
  variant: 8
  full-name-gen: Косач Лариси Петрівни
  course: 2
  semester: 4
work_types:
  lb: ЛБ
  pz: ПЗ
  kr: КР
```

</p></details>

<details><summary>Вміст <code>.config/subjects.yaml</code></summary><p>

```yaml
smp:
  name: СМП
  full_name: Скриптові мови програмування
  mentors:
    - name: Шевченко Т. Г.
      degree: Доцент кафедри ПІ
      gender: m
    - name: Франко І. Я.
      degree: Асистент кафедри ПІ
      gender: m
iks:
  name: ІКС
  full_name: Інформаційно-комунікаційні системи
  mentors:
    - name: Бажан М. П.
      degree: Доцент кафедри ІКІ
      gender: m
# тощо...
```

</p></details>

<details><summary>Вміст <code>.config/mise/config.toml</code></summary><p>

```toml
[settings]
quiet = true
env_shell_expand = true
lockfile = true

[tools]
"aqua:nushell/nushell" = "latest"

[tasks.work]
usage = '''
arg "<subject>" help="Target environment"
arg "<type>" help="Target environment"
arg "<number>" help="Target environment"
'''

run = '''
#!/usr/bin/env nu

let template_dir = ".config/template"
let config_dir = ".config"
# let out_dir = $"(pwd)"
let out_dir = $"(pwd)/works"

def not_main [subject: string, shortcode: string, number?: int] {
    let subject_lower = ($subject | str downcase)
    let shortcode_lower = ($shortcode | str downcase)

    validate-input $subject $shortcode $number

    let temp_dir = $"/tmp/nure-work-(random chars -l 8)"
    let final_dir = $"($out_dir)/($subject_lower)/($shortcode_lower)($number)"
    let subject_dir = $"($out_dir)/($subject_lower)"

    # TODO?: replace with git clone
    cp -r ($config_dir)/template $temp_dir
    generate-doc-toml $shortcode_lower $subject_lower $temp_dir $number
    check-mkdir $out_dir
    if ($final_dir | path exists) {
        error make -u {msg: $"Directory ($final_dir) already exists"}
    }

    check-mkdir $subject_dir; cp -r $temp_dir $final_dir; rm -rf $temp_dir
    print $"=> Created new work: ($final_dir)"
}

def check-mkdir [path: string] { if not ($path | path exists) { mkdir $path } }

def validate-input [subject: string, shortcode: string, number?: int] {
    if not ($config_dir | path exists) {
        error make -u {msg: $"($config_dir) not found"}
    }

    let defaults_yaml = $"($config_dir)/defaults.yaml"
    let subjects_yaml = $"($config_dir)/subjects.yaml"

    if not ($defaults_yaml | path exists) {
        error make -u {msg: $"defaults.yaml not found in ($config_dir)"}
    }
    if not ($subjects_yaml | path exists) {
        error make -u {msg: $"subjects.yaml not found in ($config_dir)"}
    }

    if ($number != nothing and $number < 1 ) {
        error make -u {msg: "Work number should be greater than 0"}
    }

    let subject_lower = ($subject | str downcase)
    let subjects = (open $subjects_yaml | columns)
    if $subject_lower not-in $subjects {
        error make -u {
            msg: $"Subject '($subject)' not found in configuration"
            help: $"Available subjects: ($subjects | str join ', ')"
        }
    }
}

def generate-doc-toml [shortcode: string, subject: string, target_dir: string, number?: int] {
    let defaults = (open $"($config_dir)/defaults.yaml")
    let subjects = (open $"($config_dir)/subjects.yaml")

    let subject_data = ($subjects | get $subject)
    let work_type = ($defaults | get work_types | try { get $shortcode } catch { $shortcode })

    {
        university: ($defaults | get university)
        subject: ($subject_data | get name), type: $work_type, number: $number
        mentors: ($subject_data | get mentors), authors: [($defaults | get default_author)]
    } | compact --empty | to toml | save $"($target_dir)/src/doc.toml" --force
}

not_main {{usage.subject}} {{usage.type}} {{usage.number}}
'''
```

</p></details>

`mise run work smp lb 1` робить дві речі:
- копіює шаблон у `works/smp/lb1`;
- заповнює `doc.toml` даними з `defaults.yaml` і викладачами з `subjects.yaml`.

Дисципліни, яких немає в пакунку, кладіть у `.config/template/src/data.yaml` -- тоді кожна нова робота отримає копію.

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
