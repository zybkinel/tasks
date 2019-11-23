<?php

/*
 * Эта реализация подразумевает посимвольное чтение файла.
 * А так же не делает никаких подготовительных проходов по файлу.
 *
 * Если нужно построчное чтение, то тут два варианта:
 * 1) При создании объекта пройти по всему файлу fgets и записать
 * во вспомогательный массив оффсеты строк относительно их порядкого номера
 * 2) Проходить fgets с начала файла только до нужной строки,
 * составляем при этом все тот же вспомогательный массив.
 */

class FileReader implements SeekableIterator
{
    private $position;

    private $fileReadStream;

    public function __construct($path)
    {
        if (!file_exists($path)) {
            throw new \Exception('File not found');
        }

        $this->fileReadStream = fopen($path, "r");
    }

    public function seek($position)
    {
        // Сдвигаем
        $this->position = $position;

        // Валидируем
        if (!$this->valid()) {
            throw new \OutOfBoundsException("invalid seek position ($position)");
        }
    }

    public function rewind()
    {
        $this->position = 0;
    }

    public function current()
    {
        return stream_get_contents($this->fileReadStream, 1, $this->position);
    }

    public function key()
    {
        return $this->position;
    }

    public function next()
    {
        ++$this->position;
    }

    public function valid()
    {
        // Сдвигаем
        fseek($this->fileReadStream, $this->position);
        fread($this->fileReadStream, 1);
        // Проверяем на конец файла
        return !feof($this->fileReadStream);
    }
}

try {
    $file = new FileReader('test.txt');
    $file->seek(2);
    echo $file->current();
} catch (Throwable $e) {
    echo $e->getMessage();
}

