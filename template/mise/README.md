# Робота з шаблоном ХНУРЕ

Тека роботи для [typst-nure-template](https://github.com/beauloxe/typst-nure-template). Typst, інструменти й пакунок встановлює [mise](https://mise.jdx.dev/).

## Початок

```sh
mise trust
mise install
mise run watch
```

Далі впишіть свої дані в `src/doc.toml` і пишіть текст у `src/main.typ`; `main.pdf` перезбирається при кожному збереженні.

## Що де

| | |
| --- | --- |
| `src/doc.toml` | Дані роботи: дисципліна, тип і номер, автори, викладачі |
| `src/main.typ` | Текст роботи |
| `src/utils.typ` | Ваші допоміжні функції |
| `src/figures/`, `src/assets/` | Рисунки й інші файли (тримайте їх у `src/` -- файли поза нею Typst не бачить) |
| `.mise/config.toml` | Версія пакунка й задачі |

## Команди

| | |
| --- | --- |
| `mise run watch` | Перезбирати `main.pdf` при кожному збереженні |
| `mise run compile` | Зібрати `main.pdf` один раз |
| `mise run rename` | Скопіювати PDF з назвою для здачі, напр. `ЛБ1_Косач_КУІБ-24-1_СМП.pdf` |
| `mise run format` | Відформатувати `src/` |
| `mise run clean` | Видалити PDF |
| `mise run update-package-rev` | Оновити пакунок до останнього коміту `main` |

## Документація

- [Лабораторна чи практична](https://github.com/beauloxe/typst-nure-template/blob/main/docs/lab.md)
- [Курсова](https://github.com/beauloxe/typst-nure-template/blob/main/docs/coursework.md)
- [Оформлення тексту](https://github.com/beauloxe/typst-nure-template/blob/main/docs/writing.md): рисунки, таблиці, код, джерела, додатки
- [Дані роботи](https://github.com/beauloxe/typst-nure-template/blob/main/docs/data.md): усі поля `doc.toml`, власні дисципліни
- [Встановлення й налаштування редактора](https://github.com/beauloxe/typst-nure-template/blob/main/docs/install.md)
