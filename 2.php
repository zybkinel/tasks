<?php
// Убираем лимит на время исполнения
ini_set('max_execution_time', '0');

$dbh = new PDO('mysql:host=127.0.0.1;port=3306;dbname=local', 'user', 'pass');

// Чем больше рамер чанка, тем меньше запросов будет к базе,
// но памяти потребуется больше и наоборт
$limit = 1000;
$currentId = 0;
$result = [];

$start = microtime(true);

while(true) {

    $query = $dbh->prepare("SELECT `id`, `email` FROM `users` WHERE id > :current ORDER BY id ASC LIMIT :limit");
    $query->bindValue(':current', $currentId, PDO::PARAM_INT);
    $query->bindValue(':limit', $limit, PDO::PARAM_INT);
    $query->execute();

    if ($query->rowCount() === 0) {
        break;
    }

    while ($row = $query->fetch()) {
        $emails = explode(',', $row['email']);

        foreach ($emails as $email) {
            // Если быть уверенным что email'ы разделены запятой одинаково,
            // то есть всегда есть пробел или всегда его нет, от этой операции можно отказаться
            // На моем конфиге это 5 секунд с миллиона записей
            $email = trim($email);

            if (empty($email)) {
                continue;
            }

            $domain = explode("@", $email,2)[1];

            if (!isset($result[$domain])) {
                $result[$domain] = 0;
            }

            $result[$domain]++;
        }

        $currentId = $row['id'];
    }
}

$time = microtime(true) - $start;

echo("<pre>");print_r($time);echo("</pre>");//todo Remove it
echo("<pre>");print_r($result);echo("</pre>");die();//todo Remove it
