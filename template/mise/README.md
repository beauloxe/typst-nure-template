# Робота з mise

Рекомендований спосіб писати роботи з цим пакунком. Кожна робота -- окрема тека, у якій [mise](https://mise.jdx.dev/) сам встановлює Typst і супутні інструменти потрібних версій та завантажує пакунок `nure` зафіксованої ревізії. Нічого не треба ставити глобально, а оновлення Typst чи пакунка не зламає вже здані роботи.

## Що потрібно
- [`mise`](https://mise.jdx.dev/getting-started.html)
- `git`

## Нова робота

```sh
git clone --depth 1 -b 0.3.0 https://github.com/beauloxe/typst-nure-template.git nure-template
cp -r nure-template/template/mise моя-робота   # Windows (PowerShell): Copy-Item -Recurse nure-template\template\mise моя-робота
cd моя-робота
mise trust      # дозволити mise виконувати задачі з .mise/config.toml
mise install    # встановити Typst, typstyle, tinymist, yq з .mise/mise.lock
mise run watch  # завантажити пакунок і перезбирати main.pdf при кожній зміні
```

Далі заповніть `src/doc.toml` (дисципліна, тип і номер роботи, автори, викладачі) і пишіть текст у `src/main.typ`. Як влаштований документ -- у [README пакунка](../../README.md).

Для редактора: tinymist встановлюється разом з усім іншим (`mise which tinymist`), а пакунок шукається через змінну `TYPST_PACKAGE_PATH`, яку mise виставляє в цій теці. Запускайте редактор з неї (`mise exec -- code .`) або увімкніть [інтеграцію mise з оболонкою](https://mise.jdx.dev/getting-started.html#activate-mise).

## Структура
```
.
├── .mise/
│   ├── config.toml   -- інструменти, версія пакунка, задачі
│   └── mise.lock     -- точні версії інструментів
├── vendor/           -- пакунок nure (завантажується автоматично, в .gitignore)
└── src/
    ├── doc.toml      -- дані роботи для work(..toml("doc.toml"))
    ├── main.typ      -- головний файл
    ├── utils.typ     -- допоміжні функції проєкту
    ├── data.yaml     -- (необов'язково) власні дисципліни й університети
    ├── chapters/     -- розділи, якщо робота велика
    ├── figures/      -- рисунки
    └── assets/       -- інші файли: .csv, код, bibl.yml
```

Корінь проєкту для Typst -- `src/`: файли поза нею (`../щось`) прочитати не вийде.

## Задачі

| Задача | Що робить |
| --- | --- |
| `mise run compile` | Зібрати `src/main.typ` у `main.pdf` |
| `mise run watch` | Перезбирати `main.pdf` при кожній зміні |
| `mise run format` | Відформатувати `src/` за допомогою typstyle |
| `mise run rename` | Скопіювати `main.pdf` з назвою з `doc.toml`, напр. `ЛБ1_Прізвище_КУІБ-24-1_АКС.pdf` |
| `mise run clean` | Видалити зібрані PDF |
| `mise run fetch-nure-package` | Завантажити пакунок у `vendor/` (запускається сам перед `compile`/`watch`, лише коли змінився `config.toml`) |
| `mise run update-package-rev` | Оновити `nure_package_rev` до останнього коміту гілки `nure_package_ref` |

`compile`, `watch`, `format` і `fetch-nure-package` працюють на будь-якій ОС. `clean`, `rename` і `update-package-rev` потребують POSIX-shell (на Windows -- Git Bash).

## Версія пакунка
Пакунок задається у `[vars]` файлу `.mise/config.toml`:

```toml
nure_package_ref = "0.3.0"   # гілка; має збігатися з версією в імпорті @vendor/nure:0.3.0
nure_package_rev = "778c3aa..."  # коміт у цій гілці
```

- Щоб отримати виправлення в межах тієї ж версії: `mise run update-package-rev`.
- Щоб перейти на нову версію: змініть `nure_package_ref`, виконайте `mise run update-package-rev` і оновіть версію в `#import "@vendor/nure:..."`.

## Власні дисципліни й університети
Дисципліни, освітні програми чи цілі університети, яких немає в пакунку, не потребують його правок: покладіть їх у `src/data.yaml` у форматі `src/config/universities.yaml` пакунка і передайте у `work`:

```yaml
# src/data.yaml
ХНУРЕ:
  subjects:
    Прог: Програмування
    ТІК: Теорія інформації та кодування
```

```typst
#let w = work(..toml("doc.toml"), data: yaml("data.yaml"))
```

Записи накладаються на вбудовані, `null` видаляє запис.

## Приклад: шаблон на семестр
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
