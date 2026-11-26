/// блок коду з рядка, напр. #code(read("foo.c"))
#let code(content) = raw(block: true, theme: none, content)

/// прочитати файл як байти
#let b(path) = bytes(read(path, encoding: none))

/// підключити розділи за назвами файлів з /chapters
#let chapters(ch) = (
  array(ch).map(chapter => include str(chapter) + ".typ").join()
)
