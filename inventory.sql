CREATE TABLE IF NOT EXISTS `inventory_stash` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `stash` varchar(50) NOT NULL,
  `items` longtext DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

ALTER TABLE `users`
	ADD COLUMN `inventory` longtext NOT NULL DEFAULT '[]';

ALTER TABLE `owned_vehicles`
    ADD COLUMN `gloveboxitems` longtext NOT NULL DEFAULT '[]',
	ADD COLUMN `trunkitems` longtext NOT NULL DEFAULT '[]';