/*
* Таблица категорий
*/
CREATE TABLE `categories` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`name` VARCHAR(128) NOT NULL COLLATE 'utf8_unicode_ci',
	`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`deleted_at` TIMESTAMP NULL DEFAULT NULL,
	PRIMARY KEY (`id`)
)
ENGINE=InnoDB;

/*
* Таблица юзеров
*/
CREATE TABLE `users` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`name` VARCHAR(32) NOT NULL COLLATE 'utf8_unicode_ci',
	`gender` TINYINT(2) NOT NULL,
	`email` VARCHAR(255) NOT NULL COLLATE 'utf8_unicode_ci',
	`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`deleted_at` TIMESTAMP NULL DEFAULT NULL,
	PRIMARY KEY (`id`)
)
ENGINE=InnoDB;

/*
* Таблица постов
*/
CREATE TABLE `posts` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`title` VARCHAR(128) NOT NULL COLLATE 'utf8_unicode_ci',
	`content` VARCHAR(243) NOT NULL COLLATE 'utf8_unicode_ci',
	`category_id` INT(11) NOT NULL,
	`likes_count` INT(11) NOT NULL DEFAULT '0',
	`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`deleted_at` TIMESTAMP NULL DEFAULT NULL,
	PRIMARY KEY (`id`),
	INDEX `category_id_foreign` (`category_id`),
	CONSTRAINT `category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`)
)
ENGINE=InnoDB;

/*
*Таблица лайков
*/
CREATE TABLE `likes` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`user_id` INT(11) NOT NULL,
	`post_id` INT(11) NOT NULL,
	`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`deleted_at` TIMESTAMP NULL DEFAULT NULL,
	PRIMARY KEY (`id`),
	UNIQUE INDEX `user_id_post_id_uniq` (`user_id`, `post_id`),
	INDEX `user_id_foreign` (`user_id`),
	INDEX `post_id_foreign` (`post_id`),
	INDEX `created_at` (`created_at`),
	CONSTRAINT `post_id_foreign` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`),
	CONSTRAINT `user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
)
ENGINE=InnoDB;

/*
* 1. запросы на постановку лайка от юзера к новости;
*/
INSERT INTO `likes` (`user_id`, `post_id`) VALUES ('1', '1') ON DUPLICATE KEY UPDATE `deleted_at` = NULL;
UPDATE `posts` SET `likes_count` = `likes_count` + 1 WHERE `id` = 1;

/*
* 2. запросы на отмену лайка;
*/
UPDATE `posts` SET `likes_count` = `likes_count` - 1 WHERE `id` = 1;
UPDATE `likes` SET `deleted_at` = CURRENT_TIMESTAMP WHERE `user_id` = 1 AND `post_id` = 1;

/*
*3. выборка пользователей, оценивших новость, желательно учесть что их могут быть тысячи и сделать возможность постраничного вывода;
* Пагинация с использованием "LIMIT" и условия по primary ключу;
*/
SELECT 
 likes.id AS like_id,
 likes.user_id, 
 likes.post_id,
 likes.updated_at AS date_liked,
 users.name,
 users.gender,
 users.email
FROM `likes` 
LEFT JOIN users ON likes.user_id = users.id 
WHERE 
	likes.deleted_at IS NULL 
	AND likes.post_id = 1
	AND likes.id > 'ID последней записи предыдущей страницы'
ORDER BY likes.id ASC
LIMIT 20;


/*
* 4. запросы для вывода ленты новостей;
* Пагинация с использованием "LIMIT" и условия по primary ключу;
*/
SELECT 
id,
title,
content,
category_id,
likes_count,
created_at,
updated_at 
FROM `posts`
WHERE 
	deleted_at IS NULL 
	AND category_id IN (1)
	AND id < 'ID последней записи предыдущей страницы'
ORDER BY id DESC 
LIMIT 20;

/*
* 5. запросы на добавление поста в ленту.
*/
INSERT INTO `posts` (`title`, `content`, `category_id`) VALUES ('Первый пост', 'Контент первого поста', '1');
INSERT INTO `posts` (`title`, `content`, `category_id`) VALUES ('Второй пост', 'Контент второго поста', '1');

