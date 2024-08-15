-- MariaDB dump 10.19  Distrib 10.5.19-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: nextcloud
-- ------------------------------------------------------
-- Server version	10.5.19-MariaDB-0+deb11u2

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `oc_accounts`
--

DROP TABLE IF EXISTS `oc_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_accounts` (
  `uid` varchar(64) NOT NULL DEFAULT '',
  `data` longtext NOT NULL,
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_accounts`
--

LOCK TABLES `oc_accounts` WRITE;
/*!40000 ALTER TABLE `oc_accounts` DISABLE KEYS */;
INSERT INTO `oc_accounts` VALUES ('nextcloud','{\"displayname\":{\"value\":\"nextcloud\",\"scope\":\"v2-federated\",\"verified\":\"0\"},\"address\":{\"value\":\"\",\"scope\":\"v2-local\",\"verified\":\"0\"},\"website\":{\"value\":\"\",\"scope\":\"v2-local\",\"verified\":\"0\"},\"email\":{\"value\":null,\"scope\":\"v2-federated\",\"verified\":\"0\"},\"avatar\":{\"scope\":\"v2-federated\"},\"phone\":{\"value\":\"\",\"scope\":\"v2-local\",\"verified\":\"0\"},\"twitter\":{\"value\":\"\",\"scope\":\"v2-local\",\"verified\":\"0\"},\"organisation\":{\"value\":\"\",\"scope\":\"v2-local\"},\"role\":{\"value\":\"\",\"scope\":\"v2-local\"},\"headline\":{\"value\":\"\",\"scope\":\"v2-local\"},\"biography\":{\"value\":\"\",\"scope\":\"v2-local\"},\"profile_enabled\":{\"value\":\"1\"}}'),('user1','{\"displayname\":{\"value\":\"user1\",\"scope\":\"v2-federated\",\"verified\":\"0\"},\"address\":{\"value\":\"\",\"scope\":\"v2-local\",\"verified\":\"0\"},\"website\":{\"value\":\"\",\"scope\":\"v2-local\",\"verified\":\"0\"},\"email\":{\"value\":null,\"scope\":\"v2-federated\",\"verified\":\"0\"},\"avatar\":{\"scope\":\"v2-federated\"},\"phone\":{\"value\":\"\",\"scope\":\"v2-local\",\"verified\":\"0\"},\"twitter\":{\"value\":\"\",\"scope\":\"v2-local\",\"verified\":\"0\"},\"organisation\":{\"value\":\"\",\"scope\":\"v2-local\"},\"role\":{\"value\":\"\",\"scope\":\"v2-local\"},\"headline\":{\"value\":\"\",\"scope\":\"v2-local\"},\"biography\":{\"value\":\"\",\"scope\":\"v2-local\"},\"profile_enabled\":{\"value\":\"1\"}}');
/*!40000 ALTER TABLE `oc_accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_accounts_data`
--

DROP TABLE IF EXISTS `oc_accounts_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_accounts_data` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uid` varchar(64) NOT NULL,
  `name` varchar(64) NOT NULL,
  `value` varchar(255) DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `accounts_data_uid` (`uid`),
  KEY `accounts_data_name` (`name`),
  KEY `accounts_data_value` (`value`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_accounts_data`
--

LOCK TABLES `oc_accounts_data` WRITE;
/*!40000 ALTER TABLE `oc_accounts_data` DISABLE KEYS */;
INSERT INTO `oc_accounts_data` VALUES (1,'nextcloud','displayname','nextcloud'),(2,'nextcloud','address',''),(3,'nextcloud','website',''),(4,'nextcloud','email',''),(5,'nextcloud','phone',''),(6,'nextcloud','twitter',''),(7,'nextcloud','organisation',''),(8,'nextcloud','role',''),(9,'nextcloud','headline',''),(10,'nextcloud','biography',''),(11,'nextcloud','profile_enabled','1'),(12,'user1','displayname','user1'),(13,'user1','address',''),(14,'user1','website',''),(15,'user1','email',''),(16,'user1','phone',''),(17,'user1','twitter',''),(18,'user1','organisation',''),(19,'user1','role',''),(20,'user1','headline',''),(21,'user1','biography',''),(22,'user1','profile_enabled','1');
/*!40000 ALTER TABLE `oc_accounts_data` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_activity`
--

DROP TABLE IF EXISTS `oc_activity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_activity` (
  `activity_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `timestamp` int(11) NOT NULL DEFAULT 0,
  `priority` int(11) NOT NULL DEFAULT 0,
  `type` varchar(255) DEFAULT NULL,
  `user` varchar(64) DEFAULT NULL,
  `affecteduser` varchar(64) NOT NULL,
  `app` varchar(32) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `subjectparams` longtext NOT NULL,
  `message` varchar(255) DEFAULT NULL,
  `messageparams` longtext DEFAULT NULL,
  `file` varchar(4000) DEFAULT NULL,
  `link` varchar(4000) DEFAULT NULL,
  `object_type` varchar(255) DEFAULT NULL,
  `object_id` bigint(20) NOT NULL DEFAULT 0,
  PRIMARY KEY (`activity_id`),
  KEY `activity_user_time` (`affecteduser`,`timestamp`),
  KEY `activity_filter_by` (`affecteduser`,`user`,`timestamp`),
  KEY `activity_filter` (`affecteduser`,`type`,`app`,`timestamp`),
  KEY `activity_object` (`object_type`,`object_id`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_activity`
--

LOCK TABLES `oc_activity` WRITE;
/*!40000 ALTER TABLE `oc_activity` DISABLE KEYS */;
INSERT INTO `oc_activity` VALUES (1,1689001695,30,'addressbook','nextcloud','system','dav','addressbook_add','{\"actor\":\"nextcloud\",\"addressbook\":{\"id\":1,\"uri\":\"system\",\"name\":\"system\"}}','','[]','','','addressbook',1),(2,1689001695,30,'card','nextcloud','system','dav','card_add','{\"actor\":\"nextcloud\",\"addressbook\":{\"id\":1,\"uri\":\"system\",\"name\":\"system\"},\"card\":{\"id\":\"user1\",\"name\":\"user1\"}}','','[]','','','addressbook',1),(3,1689001695,30,'calendar','nextcloud','system','dav','calendar_add','{\"actor\":\"nextcloud\",\"calendar\":{\"id\":1,\"uri\":\"contact_birthdays\",\"name\":\"Contact birthdays\"}}','','[]','','','calendar',1),(4,1689001712,30,'file_created','user1','user1','files','created_self','[{\"152\":\"\\/Documents\"}]','','[]','/Documents','http://localhost:3456/index.php/apps/files/?dir=/','files',152),(5,1689001712,30,'file_created','user1','user1','files','created_self','[{\"153\":\"\\/Documents\\/Nextcloud flyer.pdf\"}]','','[]','/Documents/Nextcloud flyer.pdf','http://localhost:3456/index.php/apps/files/?dir=/Documents','files',153),(6,1689001712,30,'file_created','user1','user1','files','created_self','[{\"154\":\"\\/Documents\\/Example.md\"}]','','[]','/Documents/Example.md','http://localhost:3456/index.php/apps/files/?dir=/Documents','files',154),(7,1689001712,30,'file_created','user1','user1','files','created_self','[{\"155\":\"\\/Documents\\/Welcome to Nextcloud Hub.docx\"}]','','[]','/Documents/Welcome to Nextcloud Hub.docx','http://localhost:3456/index.php/apps/files/?dir=/Documents','files',155),(8,1689001712,30,'file_created','user1','user1','files','created_self','[{\"156\":\"\\/Documents\\/Readme.md\"}]','','[]','/Documents/Readme.md','http://localhost:3456/index.php/apps/files/?dir=/Documents','files',156),(9,1689001712,30,'file_created','user1','user1','files','created_self','[{\"157\":\"\\/Nextcloud Manual.pdf\"}]','','[]','/Nextcloud Manual.pdf','http://localhost:3456/index.php/apps/files/?dir=/','files',157),(10,1689001712,30,'file_created','user1','user1','files','created_self','[{\"158\":\"\\/Nextcloud.png\"}]','','[]','/Nextcloud.png','http://localhost:3456/index.php/apps/files/?dir=/','files',158),(11,1689001712,30,'file_created','user1','user1','files','created_self','[{\"159\":\"\\/Templates\"}]','','[]','/Templates','http://localhost:3456/index.php/apps/files/?dir=/','files',159),(12,1689001712,30,'file_created','user1','user1','files','created_self','[{\"160\":\"\\/Templates\\/Product plan.md\"}]','','[]','/Templates/Product plan.md','http://localhost:3456/index.php/apps/files/?dir=/Templates','files',160),(13,1689001712,30,'file_created','user1','user1','files','created_self','[{\"161\":\"\\/Templates\\/Letter.odt\"}]','','[]','/Templates/Letter.odt','http://localhost:3456/index.php/apps/files/?dir=/Templates','files',161),(14,1689001712,30,'file_created','user1','user1','files','created_self','[{\"162\":\"\\/Templates\\/Meeting notes.md\"}]','','[]','/Templates/Meeting notes.md','http://localhost:3456/index.php/apps/files/?dir=/Templates','files',162),(15,1689001712,30,'file_created','user1','user1','files','created_self','[{\"163\":\"\\/Templates\\/Elegant.odp\"}]','','[]','/Templates/Elegant.odp','http://localhost:3456/index.php/apps/files/?dir=/Templates','files',163),(16,1689001712,30,'file_created','user1','user1','files','created_self','[{\"164\":\"\\/Templates\\/SWOT analysis.whiteboard\"}]','','[]','/Templates/SWOT analysis.whiteboard','http://localhost:3456/index.php/apps/files/?dir=/Templates','files',164),(17,1689001712,30,'file_created','user1','user1','files','created_self','[{\"165\":\"\\/Templates\\/Expense report.ods\"}]','','[]','/Templates/Expense report.ods','http://localhost:3456/index.php/apps/files/?dir=/Templates','files',165),(18,1689001712,30,'file_created','user1','user1','files','created_self','[{\"166\":\"\\/Templates\\/Simple.odp\"}]','','[]','/Templates/Simple.odp','http://localhost:3456/index.php/apps/files/?dir=/Templates','files',166),(19,1689001712,30,'file_created','user1','user1','files','created_self','[{\"167\":\"\\/Templates\\/Invoice.odt\"}]','','[]','/Templates/Invoice.odt','http://localhost:3456/index.php/apps/files/?dir=/Templates','files',167),(20,1689001712,30,'file_created','user1','user1','files','created_self','[{\"168\":\"\\/Templates\\/Impact effort matrix.whiteboard\"}]','','[]','/Templates/Impact effort matrix.whiteboard','http://localhost:3456/index.php/apps/files/?dir=/Templates','files',168),(21,1689001712,30,'file_created','user1','user1','files','created_self','[{\"169\":\"\\/Templates\\/Diagram & table.ods\"}]','','[]','/Templates/Diagram & table.ods','http://localhost:3456/index.php/apps/files/?dir=/Templates','files',169),(22,1689001712,30,'file_created','user1','user1','files','created_self','[{\"170\":\"\\/Templates\\/Readme.md\"}]','','[]','/Templates/Readme.md','http://localhost:3456/index.php/apps/files/?dir=/Templates','files',170),(23,1689001712,30,'file_created','user1','user1','files','created_self','[{\"171\":\"\\/Reasons to use Nextcloud.pdf\"}]','','[]','/Reasons to use Nextcloud.pdf','http://localhost:3456/index.php/apps/files/?dir=/','files',171),(24,1689001712,30,'file_created','user1','user1','files','created_self','[{\"172\":\"\\/Nextcloud intro.mp4\"}]','','[]','/Nextcloud intro.mp4','http://localhost:3456/index.php/apps/files/?dir=/','files',172),(25,1689001712,30,'file_created','user1','user1','files','created_self','[{\"173\":\"\\/Photos\"}]','','[]','/Photos','http://localhost:3456/index.php/apps/files/?dir=/','files',173),(26,1689001712,30,'file_created','user1','user1','files','created_self','[{\"174\":\"\\/Photos\\/Frog.jpg\"}]','','[]','/Photos/Frog.jpg','http://localhost:3456/index.php/apps/files/?dir=/Photos','files',174),(27,1689001712,30,'file_created','user1','user1','files','created_self','[{\"175\":\"\\/Photos\\/Nextcloud community.jpg\"}]','','[]','/Photos/Nextcloud community.jpg','http://localhost:3456/index.php/apps/files/?dir=/Photos','files',175),(28,1689001712,30,'file_created','user1','user1','files','created_self','[{\"176\":\"\\/Photos\\/Library.jpg\"}]','','[]','/Photos/Library.jpg','http://localhost:3456/index.php/apps/files/?dir=/Photos','files',176),(29,1689001712,30,'file_created','user1','user1','files','created_self','[{\"177\":\"\\/Photos\\/Birdie.jpg\"}]','','[]','/Photos/Birdie.jpg','http://localhost:3456/index.php/apps/files/?dir=/Photos','files',177),(30,1689001712,30,'file_created','user1','user1','files','created_self','[{\"178\":\"\\/Photos\\/Toucan.jpg\"}]','','[]','/Photos/Toucan.jpg','http://localhost:3456/index.php/apps/files/?dir=/Photos','files',178),(31,1689001712,30,'file_created','user1','user1','files','created_self','[{\"179\":\"\\/Photos\\/Vineyard.jpg\"}]','','[]','/Photos/Vineyard.jpg','http://localhost:3456/index.php/apps/files/?dir=/Photos','files',179),(32,1689001712,30,'file_created','user1','user1','files','created_self','[{\"180\":\"\\/Photos\\/Steps.jpg\"}]','','[]','/Photos/Steps.jpg','http://localhost:3456/index.php/apps/files/?dir=/Photos','files',180),(33,1689001712,30,'file_created','user1','user1','files','created_self','[{\"181\":\"\\/Photos\\/Readme.md\"}]','','[]','/Photos/Readme.md','http://localhost:3456/index.php/apps/files/?dir=/Photos','files',181),(34,1689001712,30,'file_created','user1','user1','files','created_self','[{\"182\":\"\\/Photos\\/Gorilla.jpg\"}]','','[]','/Photos/Gorilla.jpg','http://localhost:3456/index.php/apps/files/?dir=/Photos','files',182),(35,1689001712,30,'calendar','user1','user1','dav','calendar_add_self','{\"actor\":\"user1\",\"calendar\":{\"id\":2,\"uri\":\"personal\",\"name\":\"Personal\"}}','','[]','','','calendar',2),(36,1689001712,30,'addressbook','user1','user1','dav','addressbook_add_self','{\"actor\":\"user1\",\"addressbook\":{\"id\":2,\"uri\":\"contacts\",\"name\":\"Contacts\"}}','','[]','','','addressbook',2);
/*!40000 ALTER TABLE `oc_activity` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_activity_mq`
--

DROP TABLE IF EXISTS `oc_activity_mq`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_activity_mq` (
  `mail_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `amq_timestamp` int(11) NOT NULL DEFAULT 0,
  `amq_latest_send` int(11) NOT NULL DEFAULT 0,
  `amq_type` varchar(255) NOT NULL,
  `amq_affecteduser` varchar(64) NOT NULL,
  `amq_appid` varchar(32) NOT NULL,
  `amq_subject` varchar(255) NOT NULL,
  `amq_subjectparams` longtext DEFAULT NULL,
  `object_type` varchar(255) DEFAULT NULL,
  `object_id` bigint(20) NOT NULL DEFAULT 0,
  PRIMARY KEY (`mail_id`),
  KEY `amp_user` (`amq_affecteduser`),
  KEY `amp_latest_send_time` (`amq_latest_send`),
  KEY `amp_timestamp_time` (`amq_timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_activity_mq`
--

LOCK TABLES `oc_activity_mq` WRITE;
/*!40000 ALTER TABLE `oc_activity_mq` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_activity_mq` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_addressbookchanges`
--

DROP TABLE IF EXISTS `oc_addressbookchanges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_addressbookchanges` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `uri` varchar(255) DEFAULT NULL,
  `synctoken` int(10) unsigned NOT NULL DEFAULT 1,
  `addressbookid` bigint(20) NOT NULL,
  `operation` smallint(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `addressbookid_synctoken` (`addressbookid`,`synctoken`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_addressbookchanges`
--

LOCK TABLES `oc_addressbookchanges` WRITE;
/*!40000 ALTER TABLE `oc_addressbookchanges` DISABLE KEYS */;
INSERT INTO `oc_addressbookchanges` VALUES (1,'Database:user1.vcf',1,1,1);
/*!40000 ALTER TABLE `oc_addressbookchanges` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_addressbooks`
--

DROP TABLE IF EXISTS `oc_addressbooks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_addressbooks` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `principaluri` varchar(255) DEFAULT NULL,
  `displayname` varchar(255) DEFAULT NULL,
  `uri` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `synctoken` int(10) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `addressbook_index` (`principaluri`,`uri`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_addressbooks`
--

LOCK TABLES `oc_addressbooks` WRITE;
/*!40000 ALTER TABLE `oc_addressbooks` DISABLE KEYS */;
INSERT INTO `oc_addressbooks` VALUES (1,'principals/system/system','system','system','System addressbook which holds all users of this instance',2),(2,'principals/users/user1','Contacts','contacts',NULL,1);
/*!40000 ALTER TABLE `oc_addressbooks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_appconfig`
--

DROP TABLE IF EXISTS `oc_appconfig`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_appconfig` (
  `appid` varchar(32) NOT NULL DEFAULT '',
  `configkey` varchar(64) NOT NULL DEFAULT '',
  `configvalue` longtext DEFAULT NULL,
  PRIMARY KEY (`appid`,`configkey`),
  KEY `appconfig_config_key_index` (`configkey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_appconfig`
--

LOCK TABLES `oc_appconfig` WRITE;
/*!40000 ALTER TABLE `oc_appconfig` DISABLE KEYS */;
INSERT INTO `oc_appconfig` VALUES ('accessibility','enabled','yes'),('accessibility','installed_version','1.9.0'),('accessibility','types',''),('activity','enabled','yes'),('activity','installed_version','2.15.0'),('activity','types','filesystem'),('backgroundjob','lastjob','5'),('bruteforcesettings','enabled','yes'),('bruteforcesettings','installed_version','2.4.0'),('bruteforcesettings','types',''),('circles','enabled','yes'),('circles','installed_version','23.0.0'),('circles','loopback_tmp_scheme','http'),('circles','types','filesystem,dav'),('cloud_federation_api','enabled','yes'),('cloud_federation_api','installed_version','1.6.0'),('cloud_federation_api','types','filesystem'),('comments','enabled','yes'),('comments','installed_version','1.13.0'),('comments','types','logging'),('contactsinteraction','enabled','yes'),('contactsinteraction','installed_version','1.4.0'),('contactsinteraction','types','dav'),('core','installed.bundles','[\"CoreBundle\"]'),('core','installedat','1689001659.6307'),('core','lastcron','1689001717'),('core','lastupdatedat','1689001659.632'),('core','oc.integritycheck.checker','{\"core\":{\"INVALID_HASH\":{\".htaccess\":{\"expected\":\"54cf22f44b5e273d6ca00a13843a803df163891451a2289ca91d088aa9d8230175791937c69ab8728d89206008adeaf2fd836dc47d5543494ac04bb4c318ccde\",\"current\":\"cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e\"}},\"FILE_MISSING\":{\".user.ini\":{\"expected\":\"4843b3217e91f8536cb9b52700efb20300290292cf6286f92794d4cec99df286afeb7dd6c91b1be20bc55eda541eef230a5c5e7dcd46c189edd0ed1e80c6d3f5\",\"current\":\"\"}}}}'),('core','public_files','files_sharing/public.php'),('core','public_webdav','dav/appinfo/v1/publicwebdav.php'),('core','theming.variables','b92d206521717ac032f8aa58d3c7ff2f'),('core','vendor','nextcloud'),('dashboard','enabled','yes'),('dashboard','installed_version','7.3.0'),('dashboard','types',''),('dav','enabled','yes'),('dav','installed_version','1.21.0'),('dav','types','filesystem'),('federatedfilesharing','enabled','yes'),('federatedfilesharing','installed_version','1.13.0'),('federatedfilesharing','types',''),('federation','enabled','yes'),('federation','installed_version','1.13.0'),('federation','types','authentication'),('files','enabled','yes'),('files','installed_version','1.18.0'),('files','types','filesystem'),('files_pdfviewer','enabled','yes'),('files_pdfviewer','installed_version','2.4.0'),('files_pdfviewer','types',''),('files_rightclick','enabled','yes'),('files_rightclick','installed_version','1.2.0'),('files_rightclick','types',''),('files_sharing','enabled','yes'),('files_sharing','installed_version','1.15.0'),('files_sharing','types','filesystem'),('files_trashbin','enabled','yes'),('files_trashbin','installed_version','1.13.0'),('files_trashbin','types','filesystem,dav'),('files_versions','enabled','yes'),('files_versions','installed_version','1.16.0'),('files_versions','types','filesystem,dav'),('files_videoplayer','enabled','yes'),('files_videoplayer','installed_version','1.12.0'),('files_videoplayer','types',''),('firstrunwizard','enabled','yes'),('firstrunwizard','installed_version','2.12.0'),('firstrunwizard','types','logging'),('logreader','enabled','yes'),('logreader','installed_version','2.8.0'),('logreader','types',''),('lookup_server_connector','enabled','yes'),('lookup_server_connector','installed_version','1.11.0'),('lookup_server_connector','types','authentication'),('nextcloud_announcements','enabled','yes'),('nextcloud_announcements','installed_version','1.12.0'),('nextcloud_announcements','types','logging'),('notifications','enabled','yes'),('notifications','installed_version','2.11.1'),('notifications','types','logging'),('oauth2','enabled','yes'),('oauth2','installed_version','1.11.0'),('oauth2','types','authentication'),('password_policy','enabled','yes'),('password_policy','installed_version','1.13.0'),('password_policy','types','authentication'),('photos','enabled','yes'),('photos','installed_version','1.5.0'),('photos','types',''),('privacy','enabled','yes'),('privacy','installed_version','1.7.0'),('privacy','types',''),('provisioning_api','enabled','yes'),('provisioning_api','installed_version','1.13.0'),('provisioning_api','types','prevent_group_restriction'),('recommendations','enabled','yes'),('recommendations','installed_version','1.2.0'),('recommendations','types',''),('serverinfo','cached_count_filecache','225'),('serverinfo','cached_count_storages','3'),('serverinfo','enabled','yes'),('serverinfo','installed_version','1.13.0'),('serverinfo','types',''),('settings','enabled','yes'),('settings','installed_version','1.5.0'),('settings','types',''),('sharebymail','enabled','yes'),('sharebymail','installed_version','1.13.0'),('sharebymail','types','filesystem'),('support','enabled','yes'),('support','installed_version','1.6.0'),('support','types','session'),('survey_client','enabled','yes'),('survey_client','installed_version','1.11.0'),('survey_client','types',''),('systemtags','enabled','yes'),('systemtags','installed_version','1.13.0'),('systemtags','types','logging'),('text','enabled','yes'),('text','installed_version','3.4.0'),('text','types','dav'),('theming','enabled','yes'),('theming','installed_version','1.14.0'),('theming','types','logging'),('twofactor_backupcodes','enabled','yes'),('twofactor_backupcodes','installed_version','1.12.0'),('twofactor_backupcodes','types',''),('updatenotification','enabled','yes'),('updatenotification','installed_version','1.13.0'),('updatenotification','types',''),('user_status','enabled','yes'),('user_status','installed_version','1.3.1'),('user_status','types',''),('viewer','enabled','yes'),('viewer','installed_version','1.7.0'),('viewer','types',''),('weather_status','enabled','yes'),('weather_status','installed_version','1.3.0'),('weather_status','types',''),('workflowengine','enabled','yes'),('workflowengine','installed_version','2.5.0'),('workflowengine','types','filesystem');
/*!40000 ALTER TABLE `oc_appconfig` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_authorized_groups`
--

DROP TABLE IF EXISTS `oc_authorized_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_authorized_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` varchar(200) NOT NULL,
  `class` varchar(200) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `admindel_groupid_idx` (`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_authorized_groups`
--

LOCK TABLES `oc_authorized_groups` WRITE;
/*!40000 ALTER TABLE `oc_authorized_groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_authorized_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_authtoken`
--

DROP TABLE IF EXISTS `oc_authtoken`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_authtoken` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `uid` varchar(64) NOT NULL DEFAULT '',
  `login_name` varchar(255) NOT NULL DEFAULT '',
  `password` longtext DEFAULT NULL,
  `name` longtext NOT NULL,
  `token` varchar(200) NOT NULL DEFAULT '',
  `type` smallint(5) unsigned DEFAULT 0,
  `remember` smallint(5) unsigned DEFAULT 0,
  `last_activity` int(10) unsigned DEFAULT 0,
  `last_check` int(10) unsigned DEFAULT 0,
  `scope` longtext DEFAULT NULL,
  `expires` int(10) unsigned DEFAULT NULL,
  `private_key` longtext DEFAULT NULL,
  `public_key` longtext DEFAULT NULL,
  `version` smallint(5) unsigned NOT NULL DEFAULT 1,
  `password_invalid` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `authtoken_token_index` (`token`),
  KEY `authtoken_last_activity_idx` (`last_activity`),
  KEY `authtoken_uid_index` (`uid`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_authtoken`
--

LOCK TABLES `oc_authtoken` WRITE;
/*!40000 ALTER TABLE `oc_authtoken` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_authtoken` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_bruteforce_attempts`
--

DROP TABLE IF EXISTS `oc_bruteforce_attempts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_bruteforce_attempts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `action` varchar(64) NOT NULL DEFAULT '',
  `occurred` int(10) unsigned NOT NULL DEFAULT 0,
  `ip` varchar(255) NOT NULL DEFAULT '',
  `subnet` varchar(255) NOT NULL DEFAULT '',
  `metadata` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `bruteforce_attempts_ip` (`ip`),
  KEY `bruteforce_attempts_subnet` (`subnet`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_bruteforce_attempts`
--

LOCK TABLES `oc_bruteforce_attempts` WRITE;
/*!40000 ALTER TABLE `oc_bruteforce_attempts` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_bruteforce_attempts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_calendar_invitations`
--

DROP TABLE IF EXISTS `oc_calendar_invitations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_calendar_invitations` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `uid` varchar(255) NOT NULL,
  `recurrenceid` varchar(255) DEFAULT NULL,
  `attendee` varchar(255) NOT NULL,
  `organizer` varchar(255) NOT NULL,
  `sequence` bigint(20) unsigned DEFAULT NULL,
  `token` varchar(60) NOT NULL,
  `expiration` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `calendar_invitation_tokens` (`token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_calendar_invitations`
--

LOCK TABLES `oc_calendar_invitations` WRITE;
/*!40000 ALTER TABLE `oc_calendar_invitations` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_calendar_invitations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_calendar_reminders`
--

DROP TABLE IF EXISTS `oc_calendar_reminders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_calendar_reminders` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `calendar_id` bigint(20) NOT NULL,
  `object_id` bigint(20) NOT NULL,
  `is_recurring` smallint(6) DEFAULT NULL,
  `uid` varchar(255) NOT NULL,
  `recurrence_id` bigint(20) unsigned DEFAULT NULL,
  `is_recurrence_exception` smallint(6) NOT NULL,
  `event_hash` varchar(255) NOT NULL,
  `alarm_hash` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL,
  `is_relative` smallint(6) NOT NULL,
  `notification_date` bigint(20) unsigned NOT NULL,
  `is_repeat_based` smallint(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `calendar_reminder_objid` (`object_id`),
  KEY `calendar_reminder_uidrec` (`uid`,`recurrence_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_calendar_reminders`
--

LOCK TABLES `oc_calendar_reminders` WRITE;
/*!40000 ALTER TABLE `oc_calendar_reminders` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_calendar_reminders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_calendar_resources`
--

DROP TABLE IF EXISTS `oc_calendar_resources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_calendar_resources` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `backend_id` varchar(64) DEFAULT NULL,
  `resource_id` varchar(64) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `displayname` varchar(255) DEFAULT NULL,
  `group_restrictions` varchar(4000) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `calendar_resources_bkdrsc` (`backend_id`,`resource_id`),
  KEY `calendar_resources_email` (`email`),
  KEY `calendar_resources_name` (`displayname`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_calendar_resources`
--

LOCK TABLES `oc_calendar_resources` WRITE;
/*!40000 ALTER TABLE `oc_calendar_resources` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_calendar_resources` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_calendar_resources_md`
--

DROP TABLE IF EXISTS `oc_calendar_resources_md`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_calendar_resources_md` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `resource_id` bigint(20) unsigned NOT NULL,
  `key` varchar(255) NOT NULL,
  `value` varchar(4000) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `calendar_resources_md_idk` (`resource_id`,`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_calendar_resources_md`
--

LOCK TABLES `oc_calendar_resources_md` WRITE;
/*!40000 ALTER TABLE `oc_calendar_resources_md` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_calendar_resources_md` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_calendar_rooms`
--

DROP TABLE IF EXISTS `oc_calendar_rooms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_calendar_rooms` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `backend_id` varchar(64) DEFAULT NULL,
  `resource_id` varchar(64) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `displayname` varchar(255) DEFAULT NULL,
  `group_restrictions` varchar(4000) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `calendar_rooms_bkdrsc` (`backend_id`,`resource_id`),
  KEY `calendar_rooms_email` (`email`),
  KEY `calendar_rooms_name` (`displayname`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_calendar_rooms`
--

LOCK TABLES `oc_calendar_rooms` WRITE;
/*!40000 ALTER TABLE `oc_calendar_rooms` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_calendar_rooms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_calendar_rooms_md`
--

DROP TABLE IF EXISTS `oc_calendar_rooms_md`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_calendar_rooms_md` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `room_id` bigint(20) unsigned NOT NULL,
  `key` varchar(255) NOT NULL,
  `value` varchar(4000) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `calendar_rooms_md_idk` (`room_id`,`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_calendar_rooms_md`
--

LOCK TABLES `oc_calendar_rooms_md` WRITE;
/*!40000 ALTER TABLE `oc_calendar_rooms_md` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_calendar_rooms_md` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_calendarchanges`
--

DROP TABLE IF EXISTS `oc_calendarchanges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_calendarchanges` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `uri` varchar(255) DEFAULT NULL,
  `synctoken` int(10) unsigned NOT NULL DEFAULT 1,
  `calendarid` bigint(20) NOT NULL,
  `operation` smallint(6) NOT NULL,
  `calendartype` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `calid_type_synctoken` (`calendarid`,`calendartype`,`synctoken`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_calendarchanges`
--

LOCK TABLES `oc_calendarchanges` WRITE;
/*!40000 ALTER TABLE `oc_calendarchanges` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_calendarchanges` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_calendarobjects`
--

DROP TABLE IF EXISTS `oc_calendarobjects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_calendarobjects` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `calendardata` longblob DEFAULT NULL,
  `uri` varchar(255) DEFAULT NULL,
  `calendarid` bigint(20) unsigned NOT NULL,
  `lastmodified` int(10) unsigned DEFAULT NULL,
  `etag` varchar(32) DEFAULT NULL,
  `size` bigint(20) unsigned NOT NULL,
  `componenttype` varchar(8) DEFAULT NULL,
  `firstoccurence` bigint(20) unsigned DEFAULT NULL,
  `lastoccurence` bigint(20) unsigned DEFAULT NULL,
  `uid` varchar(255) DEFAULT NULL,
  `classification` int(11) DEFAULT 0,
  `calendartype` int(11) NOT NULL DEFAULT 0,
  `deleted_at` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `calobjects_index` (`calendarid`,`calendartype`,`uri`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_calendarobjects`
--

LOCK TABLES `oc_calendarobjects` WRITE;
/*!40000 ALTER TABLE `oc_calendarobjects` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_calendarobjects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_calendarobjects_props`
--

DROP TABLE IF EXISTS `oc_calendarobjects_props`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_calendarobjects_props` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `calendarid` bigint(20) NOT NULL DEFAULT 0,
  `objectid` bigint(20) unsigned NOT NULL DEFAULT 0,
  `name` varchar(64) DEFAULT NULL,
  `parameter` varchar(64) DEFAULT NULL,
  `value` varchar(255) DEFAULT NULL,
  `calendartype` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `calendarobject_index` (`objectid`,`calendartype`),
  KEY `calendarobject_name_index` (`name`,`calendartype`),
  KEY `calendarobject_value_index` (`value`,`calendartype`),
  KEY `calendarobject_calid_index` (`calendarid`,`calendartype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_calendarobjects_props`
--

LOCK TABLES `oc_calendarobjects_props` WRITE;
/*!40000 ALTER TABLE `oc_calendarobjects_props` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_calendarobjects_props` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_calendars`
--

DROP TABLE IF EXISTS `oc_calendars`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_calendars` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `principaluri` varchar(255) DEFAULT NULL,
  `displayname` varchar(255) DEFAULT NULL,
  `uri` varchar(255) DEFAULT NULL,
  `synctoken` int(10) unsigned NOT NULL DEFAULT 1,
  `description` varchar(255) DEFAULT NULL,
  `calendarorder` int(10) unsigned NOT NULL DEFAULT 0,
  `calendarcolor` varchar(255) DEFAULT NULL,
  `timezone` longtext DEFAULT NULL,
  `components` varchar(64) DEFAULT NULL,
  `transparent` smallint(6) NOT NULL DEFAULT 0,
  `deleted_at` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `calendars_index` (`principaluri`,`uri`),
  KEY `cals_princ_del_idx` (`principaluri`,`deleted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_calendars`
--

LOCK TABLES `oc_calendars` WRITE;
/*!40000 ALTER TABLE `oc_calendars` DISABLE KEYS */;
INSERT INTO `oc_calendars` VALUES (1,'principals/system/system','Contact birthdays','contact_birthdays',1,NULL,0,'#E9D859',NULL,'VEVENT',0,NULL),(2,'principals/users/user1','Personal','personal',1,NULL,0,'#0082c9',NULL,'VEVENT',0,NULL);
/*!40000 ALTER TABLE `oc_calendars` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_calendarsubscriptions`
--

DROP TABLE IF EXISTS `oc_calendarsubscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_calendarsubscriptions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `uri` varchar(255) DEFAULT NULL,
  `principaluri` varchar(255) DEFAULT NULL,
  `displayname` varchar(100) DEFAULT NULL,
  `refreshrate` varchar(10) DEFAULT NULL,
  `calendarorder` int(10) unsigned NOT NULL DEFAULT 0,
  `calendarcolor` varchar(255) DEFAULT NULL,
  `striptodos` smallint(6) DEFAULT NULL,
  `stripalarms` smallint(6) DEFAULT NULL,
  `stripattachments` smallint(6) DEFAULT NULL,
  `lastmodified` int(10) unsigned DEFAULT NULL,
  `synctoken` int(10) unsigned NOT NULL DEFAULT 1,
  `source` longtext DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `calsub_index` (`principaluri`,`uri`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_calendarsubscriptions`
--

LOCK TABLES `oc_calendarsubscriptions` WRITE;
/*!40000 ALTER TABLE `oc_calendarsubscriptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_calendarsubscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_cards`
--

DROP TABLE IF EXISTS `oc_cards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_cards` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `addressbookid` bigint(20) NOT NULL DEFAULT 0,
  `carddata` longblob DEFAULT NULL,
  `uri` varchar(255) DEFAULT NULL,
  `lastmodified` bigint(20) unsigned DEFAULT NULL,
  `etag` varchar(32) DEFAULT NULL,
  `size` bigint(20) unsigned NOT NULL,
  `uid` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cards_abid` (`addressbookid`),
  KEY `cards_abiduri` (`addressbookid`,`uri`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_cards`
--

LOCK TABLES `oc_cards` WRITE;
/*!40000 ALTER TABLE `oc_cards` DISABLE KEYS */;
INSERT INTO `oc_cards` VALUES (1,1,'BEGIN:VCARD\r\nVERSION:3.0\r\nPRODID:-//Sabre//Sabre VObject 4.3.5//EN\r\nUID:user1\r\nFN:user1\r\nN:user1;;;;\r\nCLOUD:user1@localhost:3456\r\nEND:VCARD\r\n','Database:user1.vcf',1689001695,'a55324d6c312f8fc9a86dc02c6a87635',141,'user1');
/*!40000 ALTER TABLE `oc_cards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_cards_properties`
--

DROP TABLE IF EXISTS `oc_cards_properties`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_cards_properties` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `addressbookid` bigint(20) NOT NULL DEFAULT 0,
  `cardid` bigint(20) unsigned NOT NULL DEFAULT 0,
  `name` varchar(64) DEFAULT NULL,
  `value` varchar(255) DEFAULT NULL,
  `preferred` int(11) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `card_contactid_index` (`cardid`),
  KEY `card_name_index` (`name`),
  KEY `card_value_index` (`value`),
  KEY `cards_prop_abid` (`addressbookid`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_cards_properties`
--

LOCK TABLES `oc_cards_properties` WRITE;
/*!40000 ALTER TABLE `oc_cards_properties` DISABLE KEYS */;
INSERT INTO `oc_cards_properties` VALUES (1,1,1,'UID','user1',0),(2,1,1,'FN','user1',0),(3,1,1,'N','user1;;;;',0),(4,1,1,'CLOUD','user1@localhost:3456',0);
/*!40000 ALTER TABLE `oc_cards_properties` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_circles_circle`
--

DROP TABLE IF EXISTS `oc_circles_circle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_circles_circle` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `unique_id` varchar(31) NOT NULL,
  `name` varchar(127) NOT NULL,
  `display_name` varchar(127) DEFAULT '',
  `sanitized_name` varchar(127) DEFAULT '',
  `instance` varchar(255) DEFAULT '',
  `config` int(10) unsigned DEFAULT NULL,
  `source` int(10) unsigned DEFAULT NULL,
  `settings` longtext DEFAULT NULL,
  `description` longtext DEFAULT NULL,
  `creation` datetime DEFAULT NULL,
  `contact_addressbook` int(10) unsigned DEFAULT NULL,
  `contact_groupname` varchar(127) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UNIQ_8195F548E3C68343` (`unique_id`),
  KEY `IDX_8195F548D48A2F7C` (`config`),
  KEY `IDX_8195F5484230B1DE` (`instance`),
  KEY `IDX_8195F5485F8A7F73` (`source`),
  KEY `IDX_8195F548C317B362` (`sanitized_name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_circles_circle`
--

LOCK TABLES `oc_circles_circle` WRITE;
/*!40000 ALTER TABLE `oc_circles_circle` DISABLE KEYS */;
INSERT INTO `oc_circles_circle` VALUES (1,'RrKdiyn8u36XKm4RhfzaaxJimiPbhq4','user:nextcloud:RrKdiyn8u36XKm4RhfzaaxJimiPbhq4','nextcloud','','',1,1,'[]','','2023-07-10 15:07:45',0,''),(2,'yKQi2Xq3P6dLOTL8qNno7ii4Suoa3Xf','app:circles:yKQi2Xq3P6dLOTL8qNno7ii4Suoa3Xf','Circles','','',8193,10001,'[]','','2023-07-10 15:07:45',0,''),(3,'qnhYsqNOgHbPiOSP8CAIcRybhO419oW','user:user1:qnhYsqNOgHbPiOSP8CAIcRybhO419oW','user1','','',1,1,'[]','','2023-07-10 15:08:15',0,'');
/*!40000 ALTER TABLE `oc_circles_circle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_circles_event`
--

DROP TABLE IF EXISTS `oc_circles_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_circles_event` (
  `token` varchar(63) DEFAULT NULL,
  `event` longtext DEFAULT NULL,
  `result` longtext DEFAULT NULL,
  `instance` varchar(255) DEFAULT NULL,
  `interface` int(11) NOT NULL DEFAULT 0,
  `severity` int(11) DEFAULT NULL,
  `retry` int(11) DEFAULT NULL,
  `status` int(11) DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  `creation` bigint(20) DEFAULT NULL,
  UNIQUE KEY `UNIQ_1C1814105F37A13B4230B1DE` (`token`,`instance`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_circles_event`
--

LOCK TABLES `oc_circles_event` WRITE;
/*!40000 ALTER TABLE `oc_circles_event` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_circles_event` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_circles_member`
--

DROP TABLE IF EXISTS `oc_circles_member`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_circles_member` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `single_id` varchar(31) DEFAULT NULL,
  `circle_id` varchar(31) NOT NULL,
  `member_id` varchar(31) DEFAULT NULL,
  `user_id` varchar(127) NOT NULL,
  `user_type` smallint(6) NOT NULL DEFAULT 1,
  `instance` varchar(255) NOT NULL DEFAULT '',
  `invited_by` varchar(31) DEFAULT NULL,
  `level` smallint(6) NOT NULL,
  `status` varchar(15) DEFAULT NULL,
  `note` longtext DEFAULT NULL,
  `cached_name` varchar(255) DEFAULT '',
  `cached_update` datetime DEFAULT NULL,
  `contact_id` varchar(127) DEFAULT NULL,
  `contact_meta` longtext DEFAULT NULL,
  `joined` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `circles_member_cisiuiutil` (`circle_id`,`single_id`,`user_id`,`user_type`,`instance`,`level`),
  KEY `circles_member_cisi` (`circle_id`,`single_id`),
  KEY `IDX_25C66A49E7A1254A` (`contact_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_circles_member`
--

LOCK TABLES `oc_circles_member` WRITE;
/*!40000 ALTER TABLE `oc_circles_member` DISABLE KEYS */;
INSERT INTO `oc_circles_member` VALUES (1,'yKQi2Xq3P6dLOTL8qNno7ii4Suoa3Xf','yKQi2Xq3P6dLOTL8qNno7ii4Suoa3Xf','yKQi2Xq3P6dLOTL8qNno7ii4Suoa3Xf','circles',10000,'',NULL,9,'Member','[]','Circles','2023-07-10 15:07:45','',NULL,'2023-07-10 15:07:45'),(2,'RrKdiyn8u36XKm4RhfzaaxJimiPbhq4','RrKdiyn8u36XKm4RhfzaaxJimiPbhq4','RrKdiyn8u36XKm4RhfzaaxJimiPbhq4','nextcloud',1,'','yKQi2Xq3P6dLOTL8qNno7ii4Suoa3Xf',9,'Member','[]','nextcloud','2023-07-10 15:07:45','',NULL,'2023-07-10 15:07:45'),(3,'qnhYsqNOgHbPiOSP8CAIcRybhO419oW','qnhYsqNOgHbPiOSP8CAIcRybhO419oW','qnhYsqNOgHbPiOSP8CAIcRybhO419oW','user1',1,'','yKQi2Xq3P6dLOTL8qNno7ii4Suoa3Xf',9,'Member','[]','user1','2023-07-10 15:08:15','',NULL,'2023-07-10 15:08:15');
/*!40000 ALTER TABLE `oc_circles_member` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_circles_membership`
--

DROP TABLE IF EXISTS `oc_circles_membership`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_circles_membership` (
  `circle_id` varchar(31) NOT NULL,
  `single_id` varchar(31) NOT NULL,
  `level` int(10) unsigned NOT NULL,
  `inheritance_first` varchar(31) NOT NULL,
  `inheritance_last` varchar(31) NOT NULL,
  `inheritance_depth` int(10) unsigned NOT NULL,
  `inheritance_path` longtext NOT NULL,
  UNIQUE KEY `UNIQ_8FC816EAE7C1D92B70EE2FF6` (`single_id`,`circle_id`),
  KEY `IDX_8FC816EAE7C1D92B` (`single_id`),
  KEY `circles_membership_ifilci` (`inheritance_first`,`inheritance_last`,`circle_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_circles_membership`
--

LOCK TABLES `oc_circles_membership` WRITE;
/*!40000 ALTER TABLE `oc_circles_membership` DISABLE KEYS */;
INSERT INTO `oc_circles_membership` VALUES ('RrKdiyn8u36XKm4RhfzaaxJimiPbhq4','RrKdiyn8u36XKm4RhfzaaxJimiPbhq4',9,'RrKdiyn8u36XKm4RhfzaaxJimiPbhq4','RrKdiyn8u36XKm4RhfzaaxJimiPbhq4',1,'[\"RrKdiyn8u36XKm4RhfzaaxJimiPbhq4\"]'),('qnhYsqNOgHbPiOSP8CAIcRybhO419oW','qnhYsqNOgHbPiOSP8CAIcRybhO419oW',9,'qnhYsqNOgHbPiOSP8CAIcRybhO419oW','qnhYsqNOgHbPiOSP8CAIcRybhO419oW',1,'[\"qnhYsqNOgHbPiOSP8CAIcRybhO419oW\"]'),('yKQi2Xq3P6dLOTL8qNno7ii4Suoa3Xf','yKQi2Xq3P6dLOTL8qNno7ii4Suoa3Xf',9,'yKQi2Xq3P6dLOTL8qNno7ii4Suoa3Xf','yKQi2Xq3P6dLOTL8qNno7ii4Suoa3Xf',1,'[\"yKQi2Xq3P6dLOTL8qNno7ii4Suoa3Xf\"]');
/*!40000 ALTER TABLE `oc_circles_membership` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_circles_mount`
--

DROP TABLE IF EXISTS `oc_circles_mount`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_circles_mount` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `mount_id` varchar(31) NOT NULL,
  `circle_id` varchar(31) NOT NULL,
  `single_id` varchar(31) NOT NULL,
  `token` varchar(63) DEFAULT NULL,
  `parent` int(11) DEFAULT NULL,
  `mountpoint` longtext DEFAULT NULL,
  `mountpoint_hash` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `circles_mount_cimipt` (`circle_id`,`mount_id`,`parent`,`token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_circles_mount`
--

LOCK TABLES `oc_circles_mount` WRITE;
/*!40000 ALTER TABLE `oc_circles_mount` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_circles_mount` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_circles_mountpoint`
--

DROP TABLE IF EXISTS `oc_circles_mountpoint`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_circles_mountpoint` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `mount_id` varchar(31) NOT NULL,
  `single_id` varchar(31) NOT NULL,
  `mountpoint` longtext DEFAULT NULL,
  `mountpoint_hash` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `circles_mountpoint_ms` (`mount_id`,`single_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_circles_mountpoint`
--

LOCK TABLES `oc_circles_mountpoint` WRITE;
/*!40000 ALTER TABLE `oc_circles_mountpoint` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_circles_mountpoint` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_circles_remote`
--

DROP TABLE IF EXISTS `oc_circles_remote`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_circles_remote` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `type` varchar(15) NOT NULL DEFAULT 'Unknown',
  `interface` int(11) NOT NULL DEFAULT 0,
  `uid` varchar(20) DEFAULT NULL,
  `instance` varchar(127) DEFAULT NULL,
  `href` varchar(254) DEFAULT NULL,
  `item` longtext DEFAULT NULL,
  `creation` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UNIQ_F94EF834230B1DE` (`instance`),
  KEY `IDX_F94EF83539B0606` (`uid`),
  KEY `IDX_F94EF8334F8E741` (`href`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_circles_remote`
--

LOCK TABLES `oc_circles_remote` WRITE;
/*!40000 ALTER TABLE `oc_circles_remote` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_circles_remote` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_circles_share_lock`
--

DROP TABLE IF EXISTS `oc_circles_share_lock`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_circles_share_lock` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `item_id` varchar(31) NOT NULL,
  `circle_id` varchar(31) NOT NULL,
  `instance` varchar(127) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UNIQ_337F52F8126F525E70EE2FF6` (`item_id`,`circle_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_circles_share_lock`
--

LOCK TABLES `oc_circles_share_lock` WRITE;
/*!40000 ALTER TABLE `oc_circles_share_lock` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_circles_share_lock` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_circles_token`
--

DROP TABLE IF EXISTS `oc_circles_token`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_circles_token` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `share_id` int(11) DEFAULT NULL,
  `circle_id` varchar(31) DEFAULT NULL,
  `single_id` varchar(31) DEFAULT NULL,
  `member_id` varchar(31) DEFAULT NULL,
  `token` varchar(31) DEFAULT NULL,
  `password` varchar(31) DEFAULT NULL,
  `accepted` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sicisimit` (`share_id`,`circle_id`,`single_id`,`member_id`,`token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_circles_token`
--

LOCK TABLES `oc_circles_token` WRITE;
/*!40000 ALTER TABLE `oc_circles_token` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_circles_token` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_collres_accesscache`
--

DROP TABLE IF EXISTS `oc_collres_accesscache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_collres_accesscache` (
  `user_id` varchar(64) NOT NULL,
  `collection_id` bigint(20) NOT NULL DEFAULT 0,
  `resource_type` varchar(64) NOT NULL DEFAULT '',
  `resource_id` varchar(64) NOT NULL DEFAULT '',
  `access` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`user_id`,`collection_id`,`resource_type`,`resource_id`),
  KEY `collres_user_res` (`user_id`,`resource_type`,`resource_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_collres_accesscache`
--

LOCK TABLES `oc_collres_accesscache` WRITE;
/*!40000 ALTER TABLE `oc_collres_accesscache` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_collres_accesscache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_collres_collections`
--

DROP TABLE IF EXISTS `oc_collres_collections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_collres_collections` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_collres_collections`
--

LOCK TABLES `oc_collres_collections` WRITE;
/*!40000 ALTER TABLE `oc_collres_collections` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_collres_collections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_collres_resources`
--

DROP TABLE IF EXISTS `oc_collres_resources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_collres_resources` (
  `collection_id` bigint(20) NOT NULL,
  `resource_type` varchar(64) NOT NULL,
  `resource_id` varchar(64) NOT NULL,
  PRIMARY KEY (`collection_id`,`resource_type`,`resource_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_collres_resources`
--

LOCK TABLES `oc_collres_resources` WRITE;
/*!40000 ALTER TABLE `oc_collres_resources` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_collres_resources` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_comments`
--

DROP TABLE IF EXISTS `oc_comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_comments` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `parent_id` bigint(20) unsigned NOT NULL DEFAULT 0,
  `topmost_parent_id` bigint(20) unsigned NOT NULL DEFAULT 0,
  `children_count` int(10) unsigned NOT NULL DEFAULT 0,
  `actor_type` varchar(64) NOT NULL DEFAULT '',
  `actor_id` varchar(64) NOT NULL DEFAULT '',
  `message` longtext DEFAULT NULL,
  `verb` varchar(64) DEFAULT NULL,
  `creation_timestamp` datetime DEFAULT NULL,
  `latest_child_timestamp` datetime DEFAULT NULL,
  `object_type` varchar(64) NOT NULL DEFAULT '',
  `object_id` varchar(64) NOT NULL DEFAULT '',
  `reference_id` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `comments_parent_id_index` (`parent_id`),
  KEY `comments_topmost_parent_id_idx` (`topmost_parent_id`),
  KEY `comments_object_index` (`object_type`,`object_id`,`creation_timestamp`),
  KEY `comments_actor_index` (`actor_type`,`actor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_comments`
--

LOCK TABLES `oc_comments` WRITE;
/*!40000 ALTER TABLE `oc_comments` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_comments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_comments_read_markers`
--

DROP TABLE IF EXISTS `oc_comments_read_markers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_comments_read_markers` (
  `user_id` varchar(64) NOT NULL DEFAULT '',
  `object_type` varchar(64) NOT NULL DEFAULT '',
  `object_id` varchar(64) NOT NULL DEFAULT '',
  `marker_datetime` datetime DEFAULT NULL,
  PRIMARY KEY (`user_id`,`object_type`,`object_id`),
  KEY `comments_marker_object_index` (`object_type`,`object_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_comments_read_markers`
--

LOCK TABLES `oc_comments_read_markers` WRITE;
/*!40000 ALTER TABLE `oc_comments_read_markers` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_comments_read_markers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_dav_cal_proxy`
--

DROP TABLE IF EXISTS `oc_dav_cal_proxy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_dav_cal_proxy` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `owner_id` varchar(64) NOT NULL,
  `proxy_id` varchar(64) NOT NULL,
  `permissions` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `dav_cal_proxy_uidx` (`owner_id`,`proxy_id`,`permissions`),
  KEY `dav_cal_proxy_ipid` (`proxy_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_dav_cal_proxy`
--

LOCK TABLES `oc_dav_cal_proxy` WRITE;
/*!40000 ALTER TABLE `oc_dav_cal_proxy` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_dav_cal_proxy` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_dav_shares`
--

DROP TABLE IF EXISTS `oc_dav_shares`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_dav_shares` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `principaluri` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `access` smallint(6) DEFAULT NULL,
  `resourceid` bigint(20) unsigned NOT NULL,
  `publicuri` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `dav_shares_index` (`principaluri`,`resourceid`,`type`,`publicuri`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_dav_shares`
--

LOCK TABLES `oc_dav_shares` WRITE;
/*!40000 ALTER TABLE `oc_dav_shares` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_dav_shares` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_direct_edit`
--

DROP TABLE IF EXISTS `oc_direct_edit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_direct_edit` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `editor_id` varchar(64) NOT NULL,
  `token` varchar(64) NOT NULL,
  `file_id` bigint(20) NOT NULL,
  `user_id` varchar(64) DEFAULT NULL,
  `share_id` bigint(20) DEFAULT NULL,
  `timestamp` bigint(20) unsigned NOT NULL,
  `accessed` tinyint(1) DEFAULT 0,
  `file_path` varchar(4000) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `IDX_4D5AFECA5F37A13B` (`token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_direct_edit`
--

LOCK TABLES `oc_direct_edit` WRITE;
/*!40000 ALTER TABLE `oc_direct_edit` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_direct_edit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_directlink`
--

DROP TABLE IF EXISTS `oc_directlink`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_directlink` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` varchar(64) DEFAULT NULL,
  `file_id` bigint(20) unsigned NOT NULL,
  `token` varchar(60) DEFAULT NULL,
  `expiration` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `directlink_token_idx` (`token`),
  KEY `directlink_expiration_idx` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_directlink`
--

LOCK TABLES `oc_directlink` WRITE;
/*!40000 ALTER TABLE `oc_directlink` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_directlink` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_federated_reshares`
--

DROP TABLE IF EXISTS `oc_federated_reshares`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_federated_reshares` (
  `share_id` bigint(20) NOT NULL,
  `remote_id` varchar(255) DEFAULT '',
  PRIMARY KEY (`share_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_federated_reshares`
--

LOCK TABLES `oc_federated_reshares` WRITE;
/*!40000 ALTER TABLE `oc_federated_reshares` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_federated_reshares` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_file_locks`
--

DROP TABLE IF EXISTS `oc_file_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_file_locks` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `lock` int(11) NOT NULL DEFAULT 0,
  `key` varchar(64) NOT NULL,
  `ttl` int(11) NOT NULL DEFAULT -1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `lock_key_index` (`key`),
  KEY `lock_ttl_index` (`ttl`)
) ENGINE=InnoDB AUTO_INCREMENT=150 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_file_locks`
--

LOCK TABLES `oc_file_locks` WRITE;
/*!40000 ALTER TABLE `oc_file_locks` DISABLE KEYS */;
INSERT INTO `oc_file_locks` VALUES (1,0,'files/88790cb8f3a37547e4c0fca189e0e2f4',1689005265),(2,0,'files/e8db58c3b1f6fac1ee5efd68180420be',1689005265),(3,0,'files/98b6b322871fb678202e9d153c133785',1689005266),(4,0,'files/4f83468e16976380dcc50acdb6a33182',1689005266),(5,0,'files/c013d1bc5237b7245c568528d231f8cd',1689005266),(6,0,'files/199c46e9011dded53210fea22d187f86',1689005266),(7,0,'files/69cce4f41223e59877864cd2f5a5f427',1689005266),(8,0,'files/e320fec3b7d0685c76631db8c3a846d7',1689005266),(9,0,'files/c0a0eefa6717980dba94ec623867707e',1689005266),(10,0,'files/52a0e202ea1fd4c91206a5b28590aea6',1689005266),(11,0,'files/7d6ba46f4675b0ba1850f5bb1aae9b84',1689005266),(12,0,'files/d25ebf2fe089cb6758cfdba2abac3d94',1689005266),(13,0,'files/dadcf35a54f6fe030aa0d384b7edafb1',1689005266),(14,0,'files/df99368d575ebf2a9f603aec41a24a40',1689005266),(15,0,'files/0d0a05325b10e0dd280eb94f83ada048',1689005266),(16,0,'files/0fe435e3177f01a87b237c70d86bc255',1689005266),(17,0,'files/9481e4ade838517e594886255a009c3b',1689005266),(18,0,'files/38d3fc13a505a341da34815c5ccc8b3d',1689005313),(19,0,'files/cb35e3f48784928928ce38d055ec2d2c',1689005266),(20,0,'files/b1b8a449265909e326c33a6437ae0303',1689005266),(21,0,'files/f864f80c4445752c4568ed53ea32d52a',1689005266),(22,0,'files/3ce48c51eb866a24e4f505fa5b515a80',1689005266),(23,0,'files/577a361a721c414a46648c17c209f951',1689005266),(24,0,'files/47dbe21bf588026eeb20615e4794b825',1689005266),(25,0,'files/a5f24dec9223eaa6349f75e5b8215d2d',1689005266),(26,0,'files/26659d593f13f7bd6369e4b1fef980e8',1689005266),(27,0,'files/e8d08bbbd898a304dacfa937a07337d9',1689005266),(28,0,'files/2a3a7ec27159ff63e452b7c118eba174',1689005266),(32,0,'files/c21e9f220b7a91d3ce3dc38fc679db63',1689005266),(33,0,'files/a0e26c73a6388dd048c128d936927182',1689005266),(34,0,'files/9f6eb22a372246a0753c3017c90c8209',1689005266),(35,0,'files/8168fb47786255ef447a91fc46e7e765',1689005266),(36,0,'files/8eef417d2fa6c55bf255245e949df8d0',1689005266),(37,0,'files/cf46efa8cb8821ff5d284a8fd86cdf3c',1689005266),(38,0,'files/2dbbda79432cd527bc9683e1cc30f8a5',1689005266),(39,0,'files/24b81ecb91e63f2ec8aa0b72622e5571',1689005266),(42,0,'files/a420bc4f8f2e695bd9c0a47be69b079d',1689005266),(43,0,'files/0678baf1197a6b7344143d447025dc72',1689005295),(44,0,'files/a572fb9479205ecfd2020963d12a53f2',1689005295),(45,0,'files/62864750bf115474a055f5b659f96eff',1689005312),(46,0,'files/277ba453261b0e3ed24aff4b4e13bf1a',1689005313),(47,0,'files/d597ce54dc654eb1a26386435a22cee0',1689005313),(50,0,'files/cda7105db66cd614dda32f900db670be',1689005312),(51,0,'files/16271b04df9ceafd293d16917aa6cceb',1689005313),(52,0,'files/1942740edea924c49b45604d208dcf43',1689005312),(53,0,'files/dffaf7383cd8de8a9fce2066b5be247b',1689005313),(54,0,'files/d3fb855cc6d5aeae85456c30e0dc3aee',1689005312),(55,0,'files/136d1d99b2fa220e73091ad4b87ffeb8',1689005312),(56,0,'files/24d067d1e0593f08e82933c5c4014013',1689005313),(57,0,'files/a1a635492892739049c210256095e492',1689005313),(58,0,'files/64d370ca594ea229b604e876c47a4478',1689005312),(59,0,'files/ec94a33cb3a83dd9663ead0129244cb1',1689005312),(60,0,'files/eea02c87e38e69d3f0aa8636728acfe8',1689005312),(61,0,'files/d69983223f1903b3d0aa0d764d22616e',1689005312),(62,0,'files/4fb936bb8ec2f39612de18da541d8505',1689005312),(63,0,'files/35456e3767d5dc7163d693ea128db9f6',1689005312),(64,0,'files/c1770bdcc6395b59745b07db247d059f',1689005312),(65,0,'files/9546bee9b8c9c5e257e344b383c99207',1689005312),(66,0,'files/954d8fee7a64b0249cc93ddfa616d1fe',1689005312),(67,0,'files/aa471b193a1325948cbe9f5b033daf8a',1689005312),(68,0,'files/7ce1da63cb52406791a0393a15eee5de',1689005312),(69,0,'files/4509ba7db986fa83eb0044ea6d145e83',1689005312),(70,0,'files/ddf3e8b8a941107bb1714365c0ffaac3',1689005312),(71,0,'files/561864b0dcd0db7ba39f5604974c1ecf',1689005312),(72,0,'files/4e541da0cdc0dbeb55a52560e4443388',1689005312),(73,0,'files/fa4e7046e2d47c94b43650dd9221db5b',1689005312),(74,0,'files/147198d67dd43ea6b78d87afc2e33efd',1689005312),(75,0,'files/f2438716918b90877144433f6ff739a5',1689005312),(76,0,'files/6aa38e9709fbd104d3c4486b888b08f5',1689005312),(77,0,'files/a596e513b6e6e4fc413a021081f2bdf8',1689005312),(78,0,'files/d9555fc13ddc0519c533e779442b4b10',1689005312),(79,0,'files/94726daa1fa5b19101477f26f256d006',1689005312),(81,0,'files/0f9ccb618b912952a4b3cac661a727de',1689005312),(82,0,'files/deff030d89604e40fd77d0086b7b4c67',1689005312),(111,0,'files/7d3fdded2483c20f37eb06afc6a493f8',1689005313),(112,0,'files/4775dd1965c4be5c3ad011c9164ec682',1689005313),(113,0,'files/44418b6d05ede870c96d670a6e0861dc',1689005313),(114,0,'files/e8d1cdbdc649def08f60475b6459c379',1689005313),(115,0,'files/07ca25df6c2ff19944f9e9ca492a77bb',1689005313),(116,0,'files/42673810f14b285bba05b6f0836ff7bf',1689005313),(117,0,'files/ba1c42817e73fe714ccc1653c28c9243',1689005313),(118,0,'files/a1ba24df381e9cbf98c46cf4ed6caf64',1689005313),(120,0,'files/3b8f225d3e0a37462955506c7abe5124',1689005313),(121,0,'files/ec15a239fd47d753d574178d58f1f74c',1689005313),(123,0,'files/d4eafca0440dcc6085dbb8f67a2ef2a1',1689005313),(124,0,'files/a2729ebe50cbe301b6b0cd6a665b39cc',1689005313),(126,0,'files/80c00c407def7316f1c2ff12791f3ea4',1689005313),(127,0,'files/7daf8d88f4d04b92d295357cfcfd6500',1689005313),(129,0,'files/f551fcfd958abe7cb9a62554a513b8f6',1689005313),(130,0,'files/3b0355197ae4592591d5c33c86de890c',1689005313),(131,0,'files/ede569b33c7eb457725b370f4a77164b',1689005313),(132,0,'files/fb881fad26205152e3e7f6cb530fef56',1689005313),(133,0,'files/e1432b87f47f76e09f69cf8afc6859d8',1689005313),(134,0,'files/6b27a5b8dd0610dd38e37f984936d27b',1689005313),(135,0,'files/58aeb2d6f172beffe4926a2d2db9928f',1689005313),(136,0,'files/7ef94d51dfb1ab39cbc094ef9e0738c3',1689005313),(137,0,'files/0c31ef25b87fedbe5f6ca7af21ada17e',1689005313),(139,0,'files/773f21b42c25cdaa898ca46a4b7805da',1689005313),(140,0,'files/12296c09404cdcda8650f220976670b5',1689005313),(142,0,'files/c76d3a4f37e84b02f3f4c33ddc092101',1689005313),(143,0,'files/52eff0b9c019b5ee13e5c39e4a17df4d',1689005313);
/*!40000 ALTER TABLE `oc_file_locks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_filecache`
--

DROP TABLE IF EXISTS `oc_filecache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_filecache` (
  `fileid` bigint(20) NOT NULL AUTO_INCREMENT,
  `storage` bigint(20) NOT NULL DEFAULT 0,
  `path` varchar(4000) DEFAULT NULL,
  `path_hash` varchar(32) NOT NULL DEFAULT '',
  `parent` bigint(20) NOT NULL DEFAULT 0,
  `name` varchar(250) DEFAULT NULL,
  `mimetype` bigint(20) NOT NULL DEFAULT 0,
  `mimepart` bigint(20) NOT NULL DEFAULT 0,
  `size` bigint(20) NOT NULL DEFAULT 0,
  `mtime` bigint(20) NOT NULL DEFAULT 0,
  `storage_mtime` bigint(20) NOT NULL DEFAULT 0,
  `encrypted` int(11) NOT NULL DEFAULT 0,
  `unencrypted_size` bigint(20) NOT NULL DEFAULT 0,
  `etag` varchar(40) DEFAULT NULL,
  `permissions` int(11) DEFAULT 0,
  `checksum` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`fileid`),
  UNIQUE KEY `fs_storage_path_hash` (`storage`,`path_hash`),
  KEY `fs_parent_name_hash` (`parent`,`name`),
  KEY `fs_storage_mimetype` (`storage`,`mimetype`),
  KEY `fs_storage_mimepart` (`storage`,`mimepart`),
  KEY `fs_storage_size` (`storage`,`size`,`fileid`),
  KEY `fs_id_storage_size` (`fileid`,`storage`,`size`),
  KEY `fs_mtime` (`mtime`),
  KEY `fs_size` (`size`),
  KEY `fs_storage_path_prefix` (`storage`,`path`(64))
) ENGINE=InnoDB AUTO_INCREMENT=226 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_filecache`
--

LOCK TABLES `oc_filecache` WRITE;
/*!40000 ALTER TABLE `oc_filecache` DISABLE KEYS */;
INSERT INTO `oc_filecache` VALUES (1,1,'','d41d8cd98f00b204e9800998ecf8427e',-1,'',2,1,-1,1689001661,1689001661,0,0,'64ac1ebd42898',23,''),(2,1,'appdata_ochqgyn6kk53','8ab55d3b507195092d6a874dca251fcc',1,'appdata_ochqgyn6kk53',2,1,0,1689001666,1689001666,0,0,'64ac1ebd4284c',31,''),(3,1,'appdata_ochqgyn6kk53/appstore','d57be2db082d6b0b22241b9a4f0969cf',2,'appstore',2,1,0,1689001662,1689001662,0,0,'64ac1ebd4461c',31,''),(4,1,'appdata_ochqgyn6kk53/appstore/apps.json','919db21432d683c25caaece8e283c940',3,'apps.json',4,3,2122435,1689001662,1689001662,0,0,'7a1c1da0c1d742dddcc56a436b2de55e',27,''),(5,2,'','d41d8cd98f00b204e9800998ecf8427e',-1,'',2,1,23087106,1689001663,1689001663,0,0,'64ac1ebfe869c',23,''),(6,2,'files','45b963397aa40d4a0063e0d85e4fe7a1',5,'files',2,1,23087106,1689001663,1689001663,0,0,'64ac1ebfe869c',31,''),(7,2,'files/Documents','0ad78ba05b6961d92f7970b2b3922eca',6,'Documents',2,1,400389,1689001663,1689001663,0,0,'64ac1ebfceb69',31,''),(8,2,'files/Documents/Nextcloud flyer.pdf','9c5b4dc7182a7435767708ac3e8d126c',7,'Nextcloud flyer.pdf',5,3,374008,1689001663,1689001663,0,0,'3adf63565bab136d0c9f8c736c0b3852',27,''),(9,2,'files/Documents/Example.md','efe0853470dd0663db34818b444328dd',7,'Example.md',7,6,1095,1689001663,1689001663,0,0,'460dc0d1f0e3d8b20ed39b3f5a143801',27,''),(10,2,'files/Documents/Welcome to Nextcloud Hub.docx','b44cb84f22ceddc4ca2826e026038091',7,'Welcome to Nextcloud Hub.docx',8,3,25150,1689001663,1689001663,0,0,'8ad8f712650282f7d411c3bae517b7c0',27,''),(11,2,'files/Documents/Readme.md','51ec9e44357d147dd5c212b850f6910f',7,'Readme.md',7,6,136,1689001663,1689001663,0,0,'3ea46296cd49e47e37ad345018cebbaa',27,''),(12,2,'files/Nextcloud Manual.pdf','2bc58a43566a8edde804a4a97a9c7469',6,'Nextcloud Manual.pdf',5,3,11858081,1689001663,1689001663,0,0,'95c1bc4ea6bb9e955889453c5a3db3ea',27,''),(13,2,'files/Nextcloud.png','2bcc0ff06465ef1bfc4a868efde1e485',6,'Nextcloud.png',10,9,50598,1689001663,1689001663,0,0,'9e26f2a54ed7814a14e6b4ac32760dd1',27,''),(14,2,'files/Templates','530b342d0b8164ff3b4754c2273a453e',6,'Templates',2,1,181914,1689001663,1689001663,0,0,'64ac1ebfdd2c4',31,''),(15,2,'files/Templates/Product plan.md','a9fbf58bf31cebb8143f7ad3a5205633',14,'Product plan.md',7,6,573,1689001663,1689001663,0,0,'a92104276951f1bd147913feeb0d9820',27,''),(16,2,'files/Templates/Letter.odt','15545ade0e9863c98f3a5cc0fbf2836a',14,'Letter.odt',11,3,15961,1689001663,1689001663,0,0,'29b0f3d70822393b546aa052bcc22f17',27,''),(17,2,'files/Templates/Meeting notes.md','c0279758bb570afdcdbc2471b2f16285',14,'Meeting notes.md',7,6,326,1689001663,1689001663,0,0,'b54463e5006f099f79e12bcd7d7fd5cb',27,''),(18,2,'files/Templates/Elegant.odp','f3ec70ed694c0ca215f094b98eb046a7',14,'Elegant.odp',12,3,14316,1689001663,1689001663,0,0,'2276d10da3eba930a74c094ac0bd2b0c',27,''),(19,2,'files/Templates/SWOT analysis.whiteboard','3fd0e44b3e6f0e7144442ef6fc71a663',14,'SWOT analysis.whiteboard',13,3,38605,1689001663,1689001663,0,0,'86a2a7efbc2a9a33c2e796e9d3b8f96e',27,''),(20,2,'files/Templates/Expense report.ods','d0a4025621279b95d2f94ff4ec09eab3',14,'Expense report.ods',14,3,13441,1689001663,1689001663,0,0,'eac4de01629b9342035be6cacbd05cd6',27,''),(21,2,'files/Templates/Simple.odp','a2c90ff606d31419d699b0b437969c61',14,'Simple.odp',12,3,14810,1689001663,1689001663,0,0,'17d72a2f8373d870843edf1f54bdba4f',27,''),(22,2,'files/Templates/Invoice.odt','40fdccb51b6c3e3cf20532e06ed5016e',14,'Invoice.odt',11,3,17276,1689001663,1689001663,0,0,'67814f1ae2a3c66fe6a1f0dab36e9143',27,''),(23,2,'files/Templates/Impact effort matrix.whiteboard','c5e3b589ec8f9dd6afdebe0ac6feeac8',14,'Impact effort matrix.whiteboard',13,3,52674,1689001663,1689001663,0,0,'0d7cd1543bfd889e1892d8c931f7be8b',27,''),(24,2,'files/Templates/Diagram & table.ods','0a89f154655f6d4a0098bc4e6ca87367',14,'Diagram & table.ods',14,3,13378,1689001663,1689001663,0,0,'6f45b4ae70db3387ea980ca1257a7710',27,''),(25,2,'files/Templates/Readme.md','71fa2e74ab30f39eed525572ccc3bbec',14,'Readme.md',7,6,554,1689001663,1689001663,0,0,'8362a1940bd8906070f53d99c503252b',27,''),(26,2,'files/Reasons to use Nextcloud.pdf','418b19142a61c5bef296ea56ee144ca3',6,'Reasons to use Nextcloud.pdf',5,3,976625,1689001663,1689001663,0,0,'94b4ef2bfd45473fd42d4b1f7e068c0c',27,''),(27,2,'files/Nextcloud intro.mp4','e4919345bcc87d4585a5525daaad99c0',6,'Nextcloud intro.mp4',16,15,3963036,1689001663,1689001663,0,0,'92611afad878a3142049b293dd7b4ba5',27,''),(28,2,'files/Photos','d01bb67e7b71dd49fd06bad922f521c9',6,'Photos',2,1,5656463,1689001663,1689001663,0,0,'64ac1ebfe869c',31,''),(29,2,'files/Photos/Frog.jpg','d6219add1a9129ed0c1513af985e2081',28,'Frog.jpg',17,9,457744,1689001663,1689001663,0,0,'10e78aafac7c5c17097db649c84fb680',27,''),(30,2,'files/Photos/Nextcloud community.jpg','b9b3caef83a2a1c20354b98df6bcd9d0',28,'Nextcloud community.jpg',17,9,797325,1689001663,1689001663,0,0,'29c81111a0a32600788106ed8b51f71f',27,''),(31,2,'files/Photos/Library.jpg','0b785d02a19fc00979f82f6b54a05805',28,'Library.jpg',17,9,2170375,1689001663,1689001663,0,0,'a6ea09b567fb391b783e1ada76c7813c',27,''),(32,2,'files/Photos/Birdie.jpg','cd31c7af3a0ec6e15782b5edd2774549',28,'Birdie.jpg',17,9,593508,1689001663,1689001663,0,0,'722bc71704395807a3efd9cf66a515b7',27,''),(33,2,'files/Photos/Toucan.jpg','681d1e78f46a233e12ecfa722cbc2aef',28,'Toucan.jpg',17,9,167989,1689001663,1689001663,0,0,'faa6de993c3ed10a4cf5a469e11aa01f',27,''),(34,2,'files/Photos/Vineyard.jpg','14e5f2670b0817614acd52269d971db8',28,'Vineyard.jpg',17,9,427030,1689001663,1689001663,0,0,'a256f347e8b8935d0ce9f77b123beb8a',27,''),(35,2,'files/Photos/Steps.jpg','7b2ca8d05bbad97e00cbf5833d43e912',28,'Steps.jpg',17,9,567689,1689001663,1689001663,0,0,'1a8ef8073a4fbf1522f06dcc63f2e818',27,''),(36,2,'files/Photos/Readme.md','2a4ac36bb841d25d06d164f291ee97db',28,'Readme.md',7,6,150,1689001663,1689001663,0,0,'c7dae6b73b3128472577b8c4150c76ec',27,''),(37,2,'files/Photos/Gorilla.jpg','6d5f5956d8ff76a5f290cebb56402789',28,'Gorilla.jpg',17,9,474653,1689001663,1689001663,0,0,'e381f332eea915f8fe9b5923f505a38e',27,''),(38,1,'appdata_ochqgyn6kk53/js','8ff4e712f7047deffc8b3ed4caf33c95',2,'js',2,1,0,1689001665,1689001665,0,0,'64ac1ec1371e0',31,''),(39,1,'appdata_ochqgyn6kk53/js/core','67603c118d851c9f099a71832ba015fb',38,'core',2,1,0,1689001665,1689001665,0,0,'64ac1ec13807c',31,''),(40,1,'appdata_ochqgyn6kk53/js/core/merged-template-prepend.js','913b2947202702c13aa3f71655003d91',39,'merged-template-prepend.js',18,3,11904,1689001665,1689001665,0,0,'4f190b48c3d0af631ff4bfbc45e56b17',27,''),(41,1,'appdata_ochqgyn6kk53/js/core/merged-template-prepend.js.deps','84af9e029809c7af9450bba81ebc851d',39,'merged-template-prepend.js.deps',13,3,246,1689001665,1689001665,0,0,'8713d20dfe15cbe866a3825176b3fdc9',27,''),(42,1,'appdata_ochqgyn6kk53/js/core/merged-template-prepend.js.gzip','2f35279ff3d1fb10202f4d2a5bc9d0f7',39,'merged-template-prepend.js.gzip',19,3,3039,1689001665,1689001665,0,0,'2f127f4160c83fbf3c5a01eaef36bf22',27,''),(43,1,'appdata_ochqgyn6kk53/js/files','5c03818ba7e6b16e6d79c6dc27ebd09c',38,'files',2,1,0,1689001665,1689001665,0,0,'64ac1ec13a8c0',31,''),(44,1,'appdata_ochqgyn6kk53/js/files/merged-index.js','f8c3db593e3a90ca66fdcaa3623b279e',43,'merged-index.js',18,3,419382,1689001665,1689001665,0,0,'7d2e0af3f51e82de1aab58cba1890088',27,''),(45,1,'appdata_ochqgyn6kk53/js/files/merged-index.js.deps','1bca8bef2d67facb7ab552a0916084e6',43,'merged-index.js.deps',13,3,2024,1689001665,1689001665,0,0,'70f2f94780d87f603f3c7415a778ca47',27,''),(46,1,'appdata_ochqgyn6kk53/js/files/merged-index.js.gzip','a8fd1ae62cd1b61429e1e48414754e04',43,'merged-index.js.gzip',19,3,94876,1689001665,1689001665,0,0,'b859264d6523f52d24743e163a234a31',27,''),(47,1,'appdata_ochqgyn6kk53/js/activity','f58efd22602fe79e2ebc4d05fd81ea0a',38,'activity',2,1,0,1689001665,1689001665,0,0,'64ac1ec141537',31,''),(48,1,'appdata_ochqgyn6kk53/js/activity/activity-sidebar.js','2321f3756e92efa30b276e22e2ca21f2',47,'activity-sidebar.js',18,3,1131414,1689001665,1689001665,0,0,'8ad1323e1e1257c1da42c588e768b6dc',27,''),(49,1,'appdata_ochqgyn6kk53/js/activity/activity-sidebar.js.deps','86ed29c3b5cd17267bd3c38b478e4cf3',47,'activity-sidebar.js.deps',13,3,427,1689001665,1689001665,0,0,'8584f9cff871186bdf9f659cf213f69b',27,''),(50,1,'appdata_ochqgyn6kk53/js/activity/activity-sidebar.js.gzip','e79695d29f182fd3c4d7264e8afb5610',47,'activity-sidebar.js.gzip',19,3,319706,1689001665,1689001665,0,0,'51c36aa0fabfb6400e7c5bda93a1e6cf',27,''),(51,1,'appdata_ochqgyn6kk53/css','a7893c933f4f75cec013973d06800ac0',2,'css',2,1,0,1689001712,1689001712,0,0,'64ac1ec14b4c7',31,''),(52,1,'appdata_ochqgyn6kk53/css/icons','8adc9afeb94dce4f8d8b308d6da872a4',51,'icons',2,1,0,1689001665,1689001665,0,0,'64ac1ec14c103',31,''),(53,1,'appdata_ochqgyn6kk53/css/core','4816367b3dff10acaf18fdd2b8fe2fea',51,'core',2,1,0,1689001665,1689001665,0,0,'64ac1ec14e6ef',31,''),(54,1,'appdata_ochqgyn6kk53/css/icons/icons-vars.css','26f273b2fe8315486e2400a2aa30cf18',52,'icons-vars.css',20,6,158895,1689001712,1689001712,0,0,'d373dc2337f9868f550154c4f97cb3f9',27,''),(55,1,'appdata_ochqgyn6kk53/css/icons/icons-list.template','ec2cf4b95d2f720ced7b57a671429014',52,'icons-list.template',13,3,18698,1689001712,1689001712,0,0,'729520396a735ef3252685a7da4976d9',27,''),(56,1,'appdata_ochqgyn6kk53/css/core/8f4e-66df-server.css','891676ea9e27b1a4b4b2f090037b7468',53,'8f4e-66df-server.css',20,6,139679,1689001665,1689001665,0,0,'28c2f3c89419ee0a5abd6715f639adfc',27,''),(57,1,'appdata_ochqgyn6kk53/css/core/8f4e-66df-server.css.deps','f94de2b6f50b1d3a4633922c2a980848',53,'8f4e-66df-server.css.deps',13,3,759,1689001665,1689001665,0,0,'66af3b1214c2742cc5e8d798449b6169',27,''),(58,1,'appdata_ochqgyn6kk53/css/core/8f4e-66df-server.css.gzip','e62e55dc8c931d1e43a8c3e47474db0c',53,'8f4e-66df-server.css.gzip',19,3,19905,1689001665,1689001665,0,0,'ed31514cc2084a91a9f3addbd4b4b5ee',27,''),(59,1,'appdata_ochqgyn6kk53/css/core/8f4e-66df-css-variables.css','75ec24b073722af0d6fab5c8971ef79b',53,'8f4e-66df-css-variables.css',20,6,1820,1689001665,1689001665,0,0,'99128323dc6a7243deb6b1ecbd69eae8',27,''),(60,1,'appdata_ochqgyn6kk53/css/core/8f4e-66df-css-variables.css.deps','abfc46fdac8b93a4cbd471345209f2aa',53,'8f4e-66df-css-variables.css.deps',13,3,176,1689001665,1689001665,0,0,'5b58df5e65d8bfe374931fe57e1d5466',27,''),(61,1,'appdata_ochqgyn6kk53/css/core/8f4e-66df-css-variables.css.gzip','9570cc579cb42da2c7ba640abf595170',53,'8f4e-66df-css-variables.css.gzip',19,3,692,1689001665,1689001665,0,0,'f2b7ab702865216319522f85878bddce',27,''),(62,1,'appdata_ochqgyn6kk53/css/files','3052f31a93ccace95c37c308cd86d6bb',51,'files',2,1,0,1689001665,1689001665,0,0,'64ac1ec1636f3',31,''),(63,1,'appdata_ochqgyn6kk53/css/files/94d2-66df-merged.css','a6256a03fa6c0adbc7956834d3137850',62,'94d2-66df-merged.css',20,6,29781,1689001665,1689001665,0,0,'a280abb1817f89664b60b0787ac165f7',27,''),(64,1,'appdata_ochqgyn6kk53/css/files/94d2-66df-merged.css.deps','d8debfba57a888ff503f9cf61a57edf4',62,'94d2-66df-merged.css.deps',13,3,480,1689001665,1689001665,0,0,'4027abf431b385825244d56566e3ba99',27,''),(65,1,'appdata_ochqgyn6kk53/css/files/94d2-66df-merged.css.gzip','a6525029e4202120838fb65bb93c7d7e',62,'94d2-66df-merged.css.gzip',19,3,5826,1689001665,1689001665,0,0,'f58f95e1e5fd2db7aecef95a2d96c427',27,''),(66,1,'appdata_ochqgyn6kk53/css/text','93f26fc79b38a39b24c531bf2ba662a7',51,'text',2,1,0,1689001665,1689001665,0,0,'64ac1ec169b8c',31,''),(67,1,'appdata_ochqgyn6kk53/css/text/1321-66df-icons.css','9592364e3f5705189f2a9d7d651fadca',66,'1321-66df-icons.css',20,6,2851,1689001665,1689001665,0,0,'7f393886d48c3bffe4e146538bda60ff',27,''),(68,1,'appdata_ochqgyn6kk53/css/text/1321-66df-icons.css.deps','658f3d54eea2ec70f5c4a464191431f9',66,'1321-66df-icons.css.deps',13,3,174,1689001665,1689001665,0,0,'c56667bd773a8be848710aea070f4032',27,''),(69,1,'appdata_ochqgyn6kk53/css/text/1321-66df-icons.css.gzip','6481b0eaf7e4aa9233b0ffc527fbe885',66,'1321-66df-icons.css.gzip',19,3,437,1689001665,1689001665,0,0,'26de1fcf65c67591823349edbcdd78b9',27,''),(70,1,'appdata_ochqgyn6kk53/css/files_sharing','ca23733877da42e50d71008545064cd2',51,'files_sharing',2,1,0,1689001665,1689001665,0,0,'64ac1ec16dff9',31,''),(71,1,'appdata_ochqgyn6kk53/css/files_sharing/d71e-66df-icons.css','eec05f6c4de2ed9930c47e0dd7f53f58',70,'d71e-66df-icons.css',20,6,174,1689001665,1689001665,0,0,'79969868580c78640687debb1783a025',27,''),(72,1,'appdata_ochqgyn6kk53/css/files_sharing/d71e-66df-icons.css.deps','37b4b462a7e10e0b869b6d61e132987a',70,'d71e-66df-icons.css.deps',13,3,183,1689001665,1689001665,0,0,'2283b5e44f621ff93de603ee3f3a1b67',27,''),(73,1,'appdata_ochqgyn6kk53/css/files_sharing/d71e-66df-icons.css.gzip','866908f88141225833c086007e63817e',70,'d71e-66df-icons.css.gzip',19,3,102,1689001665,1689001665,0,0,'0fa725c79355370f4f434dadea018ed7',27,''),(74,1,'appdata_ochqgyn6kk53/css/activity','80194c4ef093ce0902d738a74b175d75',51,'activity',2,1,0,1689001665,1689001665,0,0,'64ac1ec171782',31,''),(75,1,'appdata_ochqgyn6kk53/css/activity/96db-66df-style.css','becd1fec698b07262d638f306a69c125',74,'96db-66df-style.css',20,6,3353,1689001665,1689001665,0,0,'511a246cdb106f659e6185f311bc014b',27,''),(76,1,'appdata_ochqgyn6kk53/css/activity/96db-66df-style.css.deps','aabc5c9cf9a4faeff8caa77fff322190',74,'96db-66df-style.css.deps',13,3,178,1689001665,1689001665,0,0,'dd6ac35048d3d68561a8bc887e8ccca3',27,''),(77,1,'appdata_ochqgyn6kk53/css/activity/96db-66df-style.css.gzip','56291a7b68915957b9a4b6ae0f077df8',74,'96db-66df-style.css.gzip',19,3,1108,1689001665,1689001665,0,0,'91232855d4a2c68e1363360ffcb5f559',27,''),(78,1,'appdata_ochqgyn6kk53/css/notifications','3034a5bec57b0ee84b48fc1fd85d7209',51,'notifications',2,1,0,1689001665,1689001665,0,0,'64ac1ec175966',31,''),(79,1,'appdata_ochqgyn6kk53/css/notifications/7a5a-66df-styles.css','26af28edd3ca17a904c36da60c5bf1ba',78,'7a5a-66df-styles.css',20,6,3783,1689001665,1689001665,0,0,'d7e6817b621e98a86857bda895542cdc',27,''),(80,1,'appdata_ochqgyn6kk53/css/notifications/7a5a-66df-styles.css.deps','64fa0faf26c9eb412ff760188c4a2522',78,'7a5a-66df-styles.css.deps',13,3,184,1689001665,1689001665,0,0,'6752eb8e91f8def04e4e185b6593b3f6',27,''),(81,1,'appdata_ochqgyn6kk53/css/notifications/7a5a-66df-styles.css.gzip','c284a2d3eddb2fb28c198d0bd207d47a',78,'7a5a-66df-styles.css.gzip',19,3,953,1689001665,1689001665,0,0,'e78b04b3a205bbf80886cb5e65a94b3a',27,''),(82,1,'appdata_ochqgyn6kk53/css/user_status','9263153ae6104c8311d6c4e448803f6a',51,'user_status',2,1,0,1689001665,1689001665,0,0,'64ac1ec179cf3',31,''),(83,1,'appdata_ochqgyn6kk53/css/user_status/54ac-66df-user-status-menu.css','b11753d0fc8806a4dfa4fa581bc7fc96',82,'54ac-66df-user-status-menu.css',20,6,1039,1689001665,1689001665,0,0,'8f5b86c1a52258cbbff5e1eac41ff38d',27,''),(84,1,'appdata_ochqgyn6kk53/css/user_status/54ac-66df-user-status-menu.css.deps','32b7c2b9a3b3b4187d3d7da7fd601a64',82,'54ac-66df-user-status-menu.css.deps',13,3,192,1689001665,1689001665,0,0,'fa7fe34383ea09c963f47a5053d1afdd',27,''),(85,1,'appdata_ochqgyn6kk53/css/user_status/54ac-66df-user-status-menu.css.gzip','5c06cb47fc3c9b4051f02477ba801cc3',82,'54ac-66df-user-status-menu.css.gzip',19,3,240,1689001665,1689001665,0,0,'de028625898b87c6835f7ecf651e0bac',27,''),(86,1,'appdata_ochqgyn6kk53/avatar','825a8b491b5ff32e5f5267888cd84bd0',2,'avatar',2,1,0,1689001695,1689001695,0,0,'64ac1ec1b28e6',31,''),(87,1,'appdata_ochqgyn6kk53/avatar/nextcloud','effa42766c3655e50c5bc1d55f295605',86,'nextcloud',2,1,0,1689001665,1689001665,0,0,'64ac1ec1b403c',31,''),(88,1,'appdata_ochqgyn6kk53/avatar/nextcloud/avatar.png','9524c665ddfb9594a52664d6c2b92789',87,'avatar.png',10,9,13551,1689001665,1689001665,0,0,'80ab3f88aeedc761566d20447468d7c8',27,''),(89,1,'appdata_ochqgyn6kk53/avatar/nextcloud/generated','3ff2eb7a8e6e99bbd0e9d3878919fa2f',87,'generated',13,3,0,1689001665,1689001665,0,0,'2f766515a83ba7901e7c7a513944d702',27,''),(90,1,'appdata_ochqgyn6kk53/avatar/nextcloud/avatar.32.png','4e925c2431d7b0da141b1bbe74ce1cb8',87,'avatar.32.png',10,9,335,1689001665,1689001665,0,0,'0a4e531e2c1d36f19a0e211eda294776',27,''),(91,1,'appdata_ochqgyn6kk53/preview','0f7445f454c9c8752d3c6c3145ccbb35',2,'preview',2,1,0,1689001666,1689001666,0,0,'64ac1ec21e6cf',31,''),(92,1,'appdata_ochqgyn6kk53/preview/c','48907bfe7cd8a3cac4e58bbd9fd2ffc9',91,'c',2,1,-1,1689001666,1689001666,0,0,'64ac1ec220dbe',31,''),(93,1,'appdata_ochqgyn6kk53/preview/c/5','ce1d62b75e68fa2cfc12ec8d4cdbb4e3',92,'5',2,1,-1,1689001666,1689001666,0,0,'64ac1ec220a1d',31,''),(94,1,'appdata_ochqgyn6kk53/preview/c/5/1','85e0e8e038e96ed623696a6e5f8e8291',93,'1',2,1,-1,1689001666,1689001666,0,0,'64ac1ec220658',31,''),(95,1,'appdata_ochqgyn6kk53/preview/c/5/1/c','ab99fb7e59826e98d2d1768274b02402',94,'c',2,1,-1,1689001666,1689001666,0,0,'64ac1ec2200a0',31,''),(96,1,'appdata_ochqgyn6kk53/preview/c/5/1/c/e','a49a965ae83957c82bfd611d22f38c3a',95,'e',2,1,-1,1689001666,1689001666,0,0,'64ac1ec21fd6f',31,''),(97,1,'appdata_ochqgyn6kk53/preview/c/5/1/c/e/4','ad384bf0ae9d9cd1ab6f0fa094d335d5',96,'4',2,1,-1,1689001666,1689001666,0,0,'64ac1ec21fa48',31,''),(98,1,'appdata_ochqgyn6kk53/preview/c/5/1/c/e/4/1','14ebdd72ec6a454385ee3379d34798c0',97,'1',2,1,-1,1689001666,1689001666,0,0,'64ac1ec21f714',31,''),(99,1,'appdata_ochqgyn6kk53/theming','2698ebb25430c0accd165224cca9c03e',2,'theming',2,1,0,1689001666,1689001666,0,0,'64ac1ec222b53',31,''),(100,1,'appdata_ochqgyn6kk53/preview/c/5/1/c/e/4/1/13','25249a3b707c1ba114bd97bd668e2b8e',98,'13',2,1,0,1689001666,1689001666,0,0,'64ac1ec21f3d7',31,''),(101,1,'appdata_ochqgyn6kk53/theming/0','17d7d1fb65804bfc60a1c10210df16f1',99,'0',2,1,0,1689001666,1689001666,0,0,'64ac1ec223b46',31,''),(102,1,'appdata_ochqgyn6kk53/theming/0/icon-core-filetypes_folder.svg','feb10010e83e08a0ea7f1200064a8b4b',101,'icon-core-filetypes_folder.svg',21,9,255,1689001666,1689001666,0,0,'34d02b0a61ad765ab7be21684d7b1ed3',27,''),(103,1,'appdata_ochqgyn6kk53/preview/c/5/1/c/e/4/1/13/500-500-max.png','a8814151f8a965d0065381c94ca2db55',100,'500-500-max.png',10,9,50545,1689001666,1689001666,0,0,'eef0d5a2ca633528a1715019786ae968',27,''),(104,1,'appdata_ochqgyn6kk53/theming/0/icon-core-filetypes_image.svg','2c2a03b0915160f68ff3f4ca287173cc',101,'icon-core-filetypes_image.svg',21,9,352,1689001666,1689001666,0,0,'047d4aef4272c8197062d7eb1e5b1eee',27,''),(105,1,'appdata_ochqgyn6kk53/preview/c/5/1/c/e/4/1/13/256-256-crop.png','e26487b9e55a67337b28aa9078b9280a',100,'256-256-crop.png',10,9,24388,1689001666,1689001666,0,0,'23d0b88fff5442874087874da18f0f53',27,''),(106,1,'appdata_ochqgyn6kk53/theming/0/icon-core-filetypes_video.svg','e3aa7b4a89c120d75e374c388d6bed41',101,'icon-core-filetypes_video.svg',21,9,277,1689001666,1689001666,0,0,'c475523339e1bb6d07498b87b43ee295',27,''),(107,1,'appdata_ochqgyn6kk53/theming/0/icon-core-filetypes_application-pdf.svg','3bc72de5c45abb45c8db6dd0ae68cebf',101,'icon-core-filetypes_application-pdf.svg',21,9,1054,1689001666,1689001666,0,0,'0bff58065d964225708fb0cb37a24210',27,''),(108,1,'appdata_ochqgyn6kk53/theming/0/icon-core-filetypes_text.svg','99714a34086e7dd1046d898aa53e557a',101,'icon-core-filetypes_text.svg',21,9,295,1689001666,1689001666,0,0,'e4c575eee3c6471954336a8f6ea6443b',27,''),(109,1,'appdata_ochqgyn6kk53/theming/0/icon-core-filetypes_x-office-document.svg','a1cad7aa0fec374dbae16821f6fd4d35',101,'icon-core-filetypes_x-office-document.svg',21,9,295,1689001666,1689001666,0,0,'2a389e5738a09bc3d4eaa721990b0c59',27,''),(110,1,'appdata_ochqgyn6kk53/preview/4','f3a007a45c6dee71b01ec501b71edef8',91,'4',2,1,-1,1689001666,1689001666,0,0,'64ac1ec240468',31,''),(111,1,'appdata_ochqgyn6kk53/preview/4/5','64e3da3c9f4c1a2a70e1e867ab838866',110,'5',2,1,-1,1689001666,1689001666,0,0,'64ac1ec2400f5',31,''),(112,1,'appdata_ochqgyn6kk53/preview/4/5/c','acc2c3797f9a0a003ee8e63830c8e5a2',111,'c',2,1,-1,1689001666,1689001666,0,0,'64ac1ec23fdd1',31,''),(113,1,'appdata_ochqgyn6kk53/preview/4/5/c/4','300901119e8a36d0017f954cc2ffb1b3',112,'4',2,1,-1,1689001666,1689001666,0,0,'64ac1ec23fabc',31,''),(114,1,'appdata_ochqgyn6kk53/preview/4/5/c/4/8','3c14a303b0896fa9f884f4f35fdd28af',113,'8',2,1,-1,1689001666,1689001666,0,0,'64ac1ec23f784',31,''),(115,1,'appdata_ochqgyn6kk53/preview/4/5/c/4/8/c','d9f7fb444749d47f19fe074182352b8a',114,'c',2,1,-1,1689001666,1689001666,0,0,'64ac1ec23f420',31,''),(116,1,'appdata_ochqgyn6kk53/preview/4/5/c/4/8/c/c','99b29775f7069e4880eafa711f1fa359',115,'c',2,1,-1,1689001666,1689001666,0,0,'64ac1ec23f0c1',31,''),(117,1,'appdata_ochqgyn6kk53/preview/4/5/c/4/8/c/c/9','52e169cf7a2c74372f4d0f5e8181685c',116,'9',2,1,0,1689001666,1689001666,0,0,'64ac1ec23ed2c',31,''),(118,1,'appdata_ochqgyn6kk53/preview/6','168e62618976dc425f951733a735f04a',91,'6',2,1,-1,1689001666,1689001666,0,0,'64ac1ec245442',31,''),(119,1,'appdata_ochqgyn6kk53/preview/6/5','3ef61fb9ee05972a8b80b4ab504ae9f5',118,'5',2,1,-1,1689001666,1689001666,0,0,'64ac1ec245076',31,''),(120,1,'appdata_ochqgyn6kk53/preview/6/5/1','0c1f48eef8e51d2d8743c8cde044e475',119,'1',2,1,-1,1689001666,1689001666,0,0,'64ac1ec244c65',31,''),(121,1,'appdata_ochqgyn6kk53/preview/6/5/1/2','8a8cd421474a242ddb46b6e5fb61e596',120,'2',2,1,-1,1689001666,1689001666,0,0,'64ac1ec2447ca',31,''),(122,1,'appdata_ochqgyn6kk53/preview/6/5/1/2/b','7c013ac4e9f5b74f6cedfafb87dbaeb5',121,'b',2,1,-1,1689001666,1689001666,0,0,'64ac1ec244456',31,''),(123,1,'appdata_ochqgyn6kk53/preview/6/5/1/2/b/d','e2ac7a3e561744e6e3b4a30303e8ddcc',122,'d',2,1,-1,1689001666,1689001666,0,0,'64ac1ec24412b',31,''),(124,1,'appdata_ochqgyn6kk53/preview/6/5/1/2/b/d/4','b9ad13523747df388652b66bf0fe8a06',123,'4',2,1,-1,1689001666,1689001666,0,0,'64ac1ec243b04',31,''),(125,1,'appdata_ochqgyn6kk53/preview/6/5/1/2/b/d/4/11','282952b8e5f39a387789bb06474b105e',124,'11',2,1,0,1689001666,1689001666,0,0,'64ac1ec243687',31,''),(126,1,'appdata_ochqgyn6kk53/preview/c/5/1/c/e/4/1/13/64-64-crop.png','d523b33ab8e6df0424fd05eae1f8a558',100,'64-64-crop.png',10,9,3895,1689001666,1689001666,0,0,'fe27529f8d9f2801a6b96786daa570d7',27,''),(127,1,'appdata_ochqgyn6kk53/preview/9','804fa0c3e50355c93b6bde810c4e50eb',91,'9',2,1,-1,1689001666,1689001666,0,0,'64ac1ec24e1b9',31,''),(128,1,'appdata_ochqgyn6kk53/preview/9/b','c95df313e7826dd0a40fc518831b3835',127,'b',2,1,-1,1689001666,1689001666,0,0,'64ac1ec24ddcc',31,''),(129,1,'appdata_ochqgyn6kk53/preview/9/b/f','eb471247d4c163ebe54b6eb564bddf1a',128,'f',2,1,-1,1689001666,1689001666,0,0,'64ac1ec24d9e8',31,''),(130,1,'appdata_ochqgyn6kk53/preview/9/b/f/3','d873318da3dde3eca3c29d11d2b8e00f',129,'3',2,1,-1,1689001666,1689001666,0,0,'64ac1ec24d5fd',31,''),(131,1,'appdata_ochqgyn6kk53/preview/9/b/f/3/1','99ecb32ed4384b45afae36eaabb27bbf',130,'1',2,1,-1,1689001666,1689001666,0,0,'64ac1ec24d1ec',31,''),(132,1,'appdata_ochqgyn6kk53/preview/9/b/f/3/1/c','c57dde2269632d4376f17b844da877aa',131,'c',2,1,-1,1689001666,1689001666,0,0,'64ac1ec24cddb',31,''),(133,1,'appdata_ochqgyn6kk53/preview/9/b/f/3/1/c/7','2ccde2fd9e51afcdecb8035c929b8aef',132,'7',2,1,-1,1689001666,1689001666,0,0,'64ac1ec24c9d0',31,''),(134,1,'appdata_ochqgyn6kk53/preview/9/b/f/3/1/c/7/15','756f1f7842c3429d488526d12984041b',133,'15',2,1,0,1689001666,1689001666,0,0,'64ac1ec24c43c',31,''),(135,1,'appdata_ochqgyn6kk53/preview/6/5/1/2/b/d/4/11/4096-4096-max.png','92b99e698d268f1ba98f80a1fe2ebc64',125,'4096-4096-max.png',10,9,36685,1689001666,1689001666,0,0,'be328d8ffe7698e2bf769c3b0e293d5f',27,''),(136,1,'appdata_ochqgyn6kk53/preview/4/5/c/4/8/c/c/9/4096-4096-max.png','cdd9add67dc68642c4708fa0ebba4639',117,'4096-4096-max.png',10,9,192851,1689001666,1689001666,0,0,'eea9462c41d868fb5149749aae744e38',27,''),(137,1,'appdata_ochqgyn6kk53/preview/9/b/f/3/1/c/7/15/4096-4096-max.png','dff6f507fab56212246f8cbae2df6802',134,'4096-4096-max.png',10,9,68696,1689001666,1689001666,0,0,'41772edf4a7c7015669e04b61a1f2255',27,''),(138,1,'appdata_ochqgyn6kk53/preview/6/5/1/2/b/d/4/11/64-64-crop.png','a49f62b37c28666ab35bd674e542dc4f',125,'64-64-crop.png',10,9,931,1689001666,1689001666,0,0,'0ceb3688f70ae6772659c572f6e4edba',27,''),(139,1,'appdata_ochqgyn6kk53/preview/4/5/c/4/8/c/c/9/64-64-crop.png','9c6543ca122d010bbc2cd69dc2ba99d5',117,'64-64-crop.png',10,9,3668,1689001666,1689001666,0,0,'2df4b0f8dc770d139ece014ab0b07368',27,''),(140,1,'appdata_ochqgyn6kk53/preview/9/b/f/3/1/c/7/15/64-64-crop.png','1ae69e76e71fb7240e324db8896765da',134,'64-64-crop.png',10,9,1601,1689001666,1689001666,0,0,'5ae30b4dbe7d53a158b720a67fb1fe6c',27,''),(141,1,'appdata_ochqgyn6kk53/css/settings','bd843b16cca71b4e654c84a24baf0474',51,'settings',2,1,0,1689001675,1689001675,0,0,'64ac1ecb8ffa7',31,''),(142,1,'appdata_ochqgyn6kk53/css/settings/35c3-66df-settings.css','f46c69cfac7f89c3e77d1a41bafcce4d',141,'35c3-66df-settings.css',20,6,33527,1689001675,1689001675,0,0,'0cbe795d8542a229c3d7ed347f5713ad',27,''),(143,1,'appdata_ochqgyn6kk53/css/settings/35c3-66df-settings.css.deps','0141ce9a25322fad31448e816989ef38',141,'35c3-66df-settings.css.deps',13,3,181,1689001675,1689001675,0,0,'5a341c18b0957e8a1a7dfdab208ab61e',27,''),(144,1,'appdata_ochqgyn6kk53/css/settings/35c3-66df-settings.css.gzip','ab025badae14a6974d1e926495044c33',141,'35c3-66df-settings.css.gzip',19,3,6123,1689001675,1689001675,0,0,'0f6fb135bb958c572649f69a95af598e',27,''),(145,1,'appdata_ochqgyn6kk53/avatar/user1','0b8f66a3d6d6353bf8c9c41bae47ebf7',86,'user1',2,1,0,1689001695,1689001695,0,0,'64ac1edfac5a7',31,''),(146,1,'appdata_ochqgyn6kk53/avatar/user1/avatar.png','7f1f4ebd77845a14d63f7ea2aedd3d12',145,'avatar.png',10,9,11053,1689001695,1689001695,0,0,'db224d2a1a150279488d363a14414ead',27,''),(147,1,'appdata_ochqgyn6kk53/avatar/user1/generated','d195232c9a288c483b6ed70e4d3391e9',145,'generated',13,3,0,1689001695,1689001695,0,0,'d54c78bd34be885f1b6a48da910b0e4b',27,''),(148,3,'','d41d8cd98f00b204e9800998ecf8427e',-1,'',2,1,23087106,1689001712,1689001712,0,0,'64ac1ef05285e',23,''),(149,1,'appdata_ochqgyn6kk53/avatar/user1/avatar.32.png','3ea9115bf864e45ffc0652128cbed041',145,'avatar.32.png',10,9,321,1689001695,1689001695,0,0,'6d0901ff9fff48b70607e4dc83f2af35',27,''),(150,3,'cache','0fea6a13c52b4d4725368f24b045ca84',148,'cache',2,1,0,1689001712,1689001712,0,0,'64ac1ef00089e',31,''),(151,3,'files','45b963397aa40d4a0063e0d85e4fe7a1',148,'files',2,1,23087106,1689001712,1689001712,0,0,'64ac1ef05285e',31,''),(152,3,'files/Documents','0ad78ba05b6961d92f7970b2b3922eca',151,'Documents',2,1,400389,1689001712,1689001712,0,0,'64ac1ef012a1f',31,''),(153,3,'files/Documents/Nextcloud flyer.pdf','9c5b4dc7182a7435767708ac3e8d126c',152,'Nextcloud flyer.pdf',5,3,374008,1689001712,1689001712,0,0,'72b4c9ea227f2724f7e8af2df82c00f3',27,''),(154,3,'files/Documents/Example.md','efe0853470dd0663db34818b444328dd',152,'Example.md',7,6,1095,1689001712,1689001712,0,0,'d9b86fbe994b6dd28a7c05a831732542',27,''),(155,3,'files/Documents/Welcome to Nextcloud Hub.docx','b44cb84f22ceddc4ca2826e026038091',152,'Welcome to Nextcloud Hub.docx',8,3,25150,1689001712,1689001712,0,0,'8d6c068b698dcf656f63b76d5432414a',27,''),(156,3,'files/Documents/Readme.md','51ec9e44357d147dd5c212b850f6910f',152,'Readme.md',7,6,136,1689001712,1689001712,0,0,'ff7a23f45a4623a764003767c13f0850',27,''),(157,3,'files/Nextcloud Manual.pdf','2bc58a43566a8edde804a4a97a9c7469',151,'Nextcloud Manual.pdf',5,3,11858081,1689001712,1689001712,0,0,'53faf7f5893cc179b7f2486a79c88fa3',27,''),(158,3,'files/Nextcloud.png','2bcc0ff06465ef1bfc4a868efde1e485',151,'Nextcloud.png',10,9,50598,1689001712,1689001712,0,0,'4f79312f0081cf969cccc3f1f722cd4e',27,''),(159,3,'files/Templates','530b342d0b8164ff3b4754c2273a453e',151,'Templates',2,1,181914,1689001712,1689001712,0,0,'64ac1ef03622e',31,''),(160,3,'files/Templates/Product plan.md','a9fbf58bf31cebb8143f7ad3a5205633',159,'Product plan.md',7,6,573,1689001712,1689001712,0,0,'e1a34d5bb27366076dca89e0bc43b2e4',27,''),(161,3,'files/Templates/Letter.odt','15545ade0e9863c98f3a5cc0fbf2836a',159,'Letter.odt',11,3,15961,1689001712,1689001712,0,0,'17929efb14deba13bcf46a4ea560d4ac',27,''),(162,3,'files/Templates/Meeting notes.md','c0279758bb570afdcdbc2471b2f16285',159,'Meeting notes.md',7,6,326,1689001712,1689001712,0,0,'9875f1968ebb39d20b7c67364cc8852a',27,''),(163,3,'files/Templates/Elegant.odp','f3ec70ed694c0ca215f094b98eb046a7',159,'Elegant.odp',12,3,14316,1689001712,1689001712,0,0,'d14ec3e59c2d4d6b049ca64604c8d06b',27,''),(164,3,'files/Templates/SWOT analysis.whiteboard','3fd0e44b3e6f0e7144442ef6fc71a663',159,'SWOT analysis.whiteboard',13,3,38605,1689001712,1689001712,0,0,'4fb85df34a7c462ddd8544798eedc396',27,''),(165,3,'files/Templates/Expense report.ods','d0a4025621279b95d2f94ff4ec09eab3',159,'Expense report.ods',14,3,13441,1689001712,1689001712,0,0,'7518453beccbc433eb4313d9b59d3c68',27,''),(166,3,'files/Templates/Simple.odp','a2c90ff606d31419d699b0b437969c61',159,'Simple.odp',12,3,14810,1689001712,1689001712,0,0,'f32b0c5637fff916672335d63db87411',27,''),(167,3,'files/Templates/Invoice.odt','40fdccb51b6c3e3cf20532e06ed5016e',159,'Invoice.odt',11,3,17276,1689001712,1689001712,0,0,'b12c448230af7d8816517cd5271d2ff9',27,''),(168,3,'files/Templates/Impact effort matrix.whiteboard','c5e3b589ec8f9dd6afdebe0ac6feeac8',159,'Impact effort matrix.whiteboard',13,3,52674,1689001712,1689001712,0,0,'0ce4de78348ecf7fb12ee1f3ffd5a662',27,''),(169,3,'files/Templates/Diagram & table.ods','0a89f154655f6d4a0098bc4e6ca87367',159,'Diagram & table.ods',14,3,13378,1689001712,1689001712,0,0,'1c526438e86185252def33941f1f8c31',27,''),(170,3,'files/Templates/Readme.md','71fa2e74ab30f39eed525572ccc3bbec',159,'Readme.md',7,6,554,1689001712,1689001712,0,0,'8b3374f0cf7537cf9e66cb207dcc9c1d',27,''),(171,3,'files/Reasons to use Nextcloud.pdf','418b19142a61c5bef296ea56ee144ca3',151,'Reasons to use Nextcloud.pdf',5,3,976625,1689001712,1689001712,0,0,'6bdec4f5cc63fce42b4c1811f128b6c8',27,''),(172,3,'files/Nextcloud intro.mp4','e4919345bcc87d4585a5525daaad99c0',151,'Nextcloud intro.mp4',16,15,3963036,1689001712,1689001712,0,0,'7f80218b3fa0443530610c4f89e8dd4f',27,''),(173,3,'files/Photos','d01bb67e7b71dd49fd06bad922f521c9',151,'Photos',2,1,5656463,1689001712,1689001712,0,0,'64ac1ef05285e',31,''),(174,3,'files/Photos/Frog.jpg','d6219add1a9129ed0c1513af985e2081',173,'Frog.jpg',17,9,457744,1689001712,1689001712,0,0,'c96cd42bffa901c12d27e2084c846150',27,''),(175,3,'files/Photos/Nextcloud community.jpg','b9b3caef83a2a1c20354b98df6bcd9d0',173,'Nextcloud community.jpg',17,9,797325,1689001712,1689001712,0,0,'9ead1890a73c98a33ac0b0c01c569249',27,''),(176,3,'files/Photos/Library.jpg','0b785d02a19fc00979f82f6b54a05805',173,'Library.jpg',17,9,2170375,1689001712,1689001712,0,0,'dc2a0836b52b959754309d177749b09a',27,''),(177,3,'files/Photos/Birdie.jpg','cd31c7af3a0ec6e15782b5edd2774549',173,'Birdie.jpg',17,9,593508,1689001712,1689001712,0,0,'5505c2954dd866139bf91b674c530411',27,''),(178,3,'files/Photos/Toucan.jpg','681d1e78f46a233e12ecfa722cbc2aef',173,'Toucan.jpg',17,9,167989,1689001712,1689001712,0,0,'f665a1c466503826e0ee1155e7743b10',27,''),(179,3,'files/Photos/Vineyard.jpg','14e5f2670b0817614acd52269d971db8',173,'Vineyard.jpg',17,9,427030,1689001712,1689001712,0,0,'c316e98dfd86a5fb1cff02465833246f',27,''),(180,3,'files/Photos/Steps.jpg','7b2ca8d05bbad97e00cbf5833d43e912',173,'Steps.jpg',17,9,567689,1689001712,1689001712,0,0,'78a7566857ac37b9c76d16d472fe1279',27,''),(181,3,'files/Photos/Readme.md','2a4ac36bb841d25d06d164f291ee97db',173,'Readme.md',7,6,150,1689001712,1689001712,0,0,'6c4fd8fbe719910e38fc0ac6023661dc',27,''),(182,3,'files/Photos/Gorilla.jpg','6d5f5956d8ff76a5f290cebb56402789',173,'Gorilla.jpg',17,9,474653,1689001712,1689001712,0,0,'8e9811bf11e63877c755be5ec7194569',27,''),(183,1,'appdata_ochqgyn6kk53/css/dashboard','2531d88b606da7f01f3cedecef5a984e',51,'dashboard',2,1,0,1689001712,1689001712,0,0,'64ac1ef072991',31,''),(184,1,'appdata_ochqgyn6kk53/css/dashboard/baf6-66df-dashboard.css','2d996a129a0ba17455d2d9a7b6b6b284',183,'baf6-66df-dashboard.css',20,6,2070,1689001712,1689001712,0,0,'cc55396be72cd0c1f49edccaf43d1665',27,''),(185,1,'appdata_ochqgyn6kk53/css/dashboard/baf6-66df-dashboard.css.deps','96f964469f4fd4c283643f652d89cbf8',183,'baf6-66df-dashboard.css.deps',13,3,183,1689001712,1689001712,0,0,'f08c5c4c5800b49b2f8044bb6a342599',27,''),(186,1,'appdata_ochqgyn6kk53/css/dashboard/baf6-66df-dashboard.css.gzip','03812c20bc1252730d759453ac02d19b',183,'baf6-66df-dashboard.css.gzip',19,3,602,1689001712,1689001712,0,0,'6e12b61b268dd70cc7a9598aad5db7a2',27,''),(187,1,'appdata_ochqgyn6kk53/preview/1','3f0a1f3c3e88d3924f2f2e8baf87815a',91,'1',2,1,-1,1689001713,1689001713,0,0,'64ac1ef138140',31,''),(188,1,'appdata_ochqgyn6kk53/preview/1/d','0b05ba5d772adfbd90203a0df250c073',187,'d',2,1,-1,1689001713,1689001713,0,0,'64ac1ef137dbe',31,''),(189,1,'appdata_ochqgyn6kk53/preview/1/d/7','a0b4cba2db624d4847e7fc2898e557c5',188,'7',2,1,-1,1689001713,1689001713,0,0,'64ac1ef1379a6',31,''),(190,1,'appdata_ochqgyn6kk53/preview/1/d/7/f','97ead8fb0af6d8350e166e994b9b26e3',189,'f',2,1,-1,1689001713,1689001713,0,0,'64ac1ef13753f',31,''),(191,1,'appdata_ochqgyn6kk53/preview/1/d/7/f/7','ecb807624bd41c4bc422e7d439f2f1d7',190,'7',2,1,-1,1689001713,1689001713,0,0,'64ac1ef1370e9',31,''),(192,1,'appdata_ochqgyn6kk53/preview/1/d/7/f/7/a','5cfb78191e608aac31a7b8622120cffd',191,'a',2,1,-1,1689001713,1689001713,0,0,'64ac1ef136ca6',31,''),(193,1,'appdata_ochqgyn6kk53/preview/1/d/7/f/7/a/b','2ec67afa5201c7e2927db87880a972ea',192,'b',2,1,-1,1689001713,1689001713,0,0,'64ac1ef13685a',31,''),(194,1,'appdata_ochqgyn6kk53/preview/1/d/7/f/7/a/b/154','6385da06464f5cfb08ab9b882a8349cd',193,'154',2,1,0,1689001713,1689001713,0,0,'64ac1ef1363a1',31,''),(195,1,'appdata_ochqgyn6kk53/preview/0','926a7be4c63de38661b459efd07452f2',91,'0',2,1,-1,1689001713,1689001713,0,0,'64ac1ef13ce7e',31,''),(196,1,'appdata_ochqgyn6kk53/preview/0/6','4431983c155a3aae2b6ca21377548071',195,'6',2,1,-1,1689001713,1689001713,0,0,'64ac1ef13c8f3',31,''),(197,1,'appdata_ochqgyn6kk53/preview/0/6/4','8fa73712a8300c82657c358ddab9dbdc',196,'4',2,1,-1,1689001713,1689001713,0,0,'64ac1ef13c339',31,''),(198,1,'appdata_ochqgyn6kk53/preview/0/6/4/0','caeff8776ab83ce9d19b6d0d6523a1dc',197,'0',2,1,-1,1689001713,1689001713,0,0,'64ac1ef13bd84',31,''),(199,1,'appdata_ochqgyn6kk53/preview/0/6/4/0/9','080350293d8bc9fc4471895ef7241a68',198,'9',2,1,-1,1689001713,1689001713,0,0,'64ac1ef13b7dc',31,''),(200,1,'appdata_ochqgyn6kk53/preview/0/6/4/0/9/6','3cf52c742c0395df231f405c79761ccd',199,'6',2,1,-1,1689001713,1689001713,0,0,'64ac1ef13b234',31,''),(201,1,'appdata_ochqgyn6kk53/preview/0/6/4/0/9/6/6','064cdc8a2663ad4f4e90fd534c799fc7',200,'6',2,1,-1,1689001713,1689001713,0,0,'64ac1ef13ac50',31,''),(202,1,'appdata_ochqgyn6kk53/preview/0/6/4/0/9/6/6/158','864d4a8a47bdfb74110e6f1e4aaaa3dc',201,'158',2,1,0,1689001713,1689001713,0,0,'64ac1ef13a8d8',31,''),(203,1,'appdata_ochqgyn6kk53/preview/0/6/4/0/9/6/6/158/500-500-max.png','dc23819cde3677f304cd7f79e9f7f364',202,'500-500-max.png',10,9,50545,1689001713,1689001713,0,0,'189e17199824ab1830bac7c45114c55d',27,''),(204,1,'appdata_ochqgyn6kk53/preview/0/6/4/0/9/6/6/158/64-64-crop.png','675e0726cf3bc24f0e1d016d27c7f5af',202,'64-64-crop.png',10,9,3895,1689001713,1689001713,0,0,'217cabe37dde64db7787e7425f082842',27,''),(205,1,'appdata_ochqgyn6kk53/preview/b','71ef2c83ae89c892ef36a7df051ae4d2',91,'b',2,1,-1,1689001713,1689001713,0,0,'64ac1ef146a52',31,''),(206,1,'appdata_ochqgyn6kk53/preview/b/7','85c5d9743ed0b168c818108d338d1c14',205,'7',2,1,-1,1689001713,1689001713,0,0,'64ac1ef146611',31,''),(207,1,'appdata_ochqgyn6kk53/preview/b/7/3','1557f497e884ab44b14375857096111b',206,'3',2,1,-1,1689001713,1689001713,0,0,'64ac1ef1461ff',31,''),(208,1,'appdata_ochqgyn6kk53/preview/b/7/3/c','795d450a4f46b1647f86314c23413d1d',207,'c',2,1,-1,1689001713,1689001713,0,0,'64ac1ef145e0a',31,''),(209,1,'appdata_ochqgyn6kk53/preview/b/7/3/c/e','9c1f653dd5ab135db3b8eda8054e6cb2',208,'e',2,1,-1,1689001713,1689001713,0,0,'64ac1ef1459b5',31,''),(210,1,'appdata_ochqgyn6kk53/preview/b/7/3/c/e/3','b4b6f1474471ebd130726a69c0a70fbb',209,'3',2,1,-1,1689001713,1689001713,0,0,'64ac1ef1455dc',31,''),(211,1,'appdata_ochqgyn6kk53/preview/b/7/3/c/e/3/9','1fa8f095ab45a27e2c37abd02e02a618',210,'9',2,1,-1,1689001713,1689001713,0,0,'64ac1ef1451fc',31,''),(212,1,'appdata_ochqgyn6kk53/preview/b/7/3/c/e/3/9/160','fe15582866917836a2d1f8996da289cc',211,'160',2,1,0,1689001713,1689001713,0,0,'64ac1ef144de5',31,''),(213,1,'appdata_ochqgyn6kk53/preview/1/c','ee6bc3d74c9291c9fd7b582230e9c5e0',187,'c',2,1,-1,1689001713,1689001713,0,0,'64ac1ef14b89a',31,''),(214,1,'appdata_ochqgyn6kk53/preview/1/c/9','cb63f6c73f35b8fa0cb34512d6e48816',213,'9',2,1,-1,1689001713,1689001713,0,0,'64ac1ef14b11f',31,''),(215,1,'appdata_ochqgyn6kk53/preview/1/c/9/a','562e27cb5973638dedbdab13b2a2df55',214,'a',2,1,-1,1689001713,1689001713,0,0,'64ac1ef14a9e7',31,''),(216,1,'appdata_ochqgyn6kk53/preview/1/c/9/a/c','d692c813813d8d214266be1d68074203',215,'c',2,1,-1,1689001713,1689001713,0,0,'64ac1ef14a29a',31,''),(217,1,'appdata_ochqgyn6kk53/preview/1/c/9/a/c/0','533a95cca9f4fe7554ef04db4dd4fb97',216,'0',2,1,-1,1689001713,1689001713,0,0,'64ac1ef149b69',31,''),(218,1,'appdata_ochqgyn6kk53/preview/1/c/9/a/c/0/1','b2adff91b2f94e2b46e65638ecb5a8a3',217,'1',2,1,-1,1689001713,1689001713,0,0,'64ac1ef149609',31,''),(219,1,'appdata_ochqgyn6kk53/preview/1/c/9/a/c/0/1/156','fc10324a9ceb7e4cd457faba542859e9',218,'156',2,1,0,1689001713,1689001713,0,0,'64ac1ef1491c3',31,''),(220,1,'appdata_ochqgyn6kk53/preview/1/d/7/f/7/a/b/154/4096-4096-max.png','1e601c895571202d61727a479935d957',194,'4096-4096-max.png',10,9,192851,1689001713,1689001713,0,0,'4f2ee8c5fb0b9c67021fc323a9a8996b',27,''),(221,1,'appdata_ochqgyn6kk53/preview/b/7/3/c/e/3/9/160/4096-4096-max.png','d0fd850b2e9a081b9ecdb548fb34eb0d',212,'4096-4096-max.png',10,9,68696,1689001713,1689001713,0,0,'ff3d46b16057a2ded2ead813aa77f53b',27,''),(222,1,'appdata_ochqgyn6kk53/preview/1/c/9/a/c/0/1/156/4096-4096-max.png','0a18983b746da5db8b6ab9a6114831ef',219,'4096-4096-max.png',10,9,36685,1689001713,1689001713,0,0,'99a670ad5eef1d2f53bd7ead05fe8a6c',27,''),(223,1,'appdata_ochqgyn6kk53/preview/1/d/7/f/7/a/b/154/64-64-crop.png','72ffe90f17260adc021906e154bc4dd8',194,'64-64-crop.png',10,9,3668,1689001713,1689001713,0,0,'e69483a0e0f91477f8efb53e484b5315',27,''),(224,1,'appdata_ochqgyn6kk53/preview/b/7/3/c/e/3/9/160/64-64-crop.png','743e1bdd2a13fd1e3fc313da05ef614e',212,'64-64-crop.png',10,9,1601,1689001713,1689001713,0,0,'b54ed7c70d53d580c7f77b7cc6a4f740',27,''),(225,1,'appdata_ochqgyn6kk53/preview/1/c/9/a/c/0/1/156/64-64-crop.png','595063e33763d0f5a45adb163d6f591e',219,'64-64-crop.png',10,9,931,1689001713,1689001713,0,0,'10bb7aed9160d65190cb36365bba1b5b',27,'');
/*!40000 ALTER TABLE `oc_filecache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_filecache_extended`
--

DROP TABLE IF EXISTS `oc_filecache_extended`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_filecache_extended` (
  `fileid` bigint(20) unsigned NOT NULL,
  `metadata_etag` varchar(40) DEFAULT NULL,
  `creation_time` bigint(20) NOT NULL DEFAULT 0,
  `upload_time` bigint(20) NOT NULL DEFAULT 0,
  PRIMARY KEY (`fileid`),
  KEY `fce_ctime_idx` (`creation_time`),
  KEY `fce_utime_idx` (`upload_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_filecache_extended`
--

LOCK TABLES `oc_filecache_extended` WRITE;
/*!40000 ALTER TABLE `oc_filecache_extended` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_filecache_extended` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_files_trash`
--

DROP TABLE IF EXISTS `oc_files_trash`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_files_trash` (
  `auto_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `id` varchar(250) NOT NULL DEFAULT '',
  `user` varchar(64) NOT NULL DEFAULT '',
  `timestamp` varchar(12) NOT NULL DEFAULT '',
  `location` varchar(512) NOT NULL DEFAULT '',
  `type` varchar(4) DEFAULT NULL,
  `mime` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`auto_id`),
  KEY `id_index` (`id`),
  KEY `timestamp_index` (`timestamp`),
  KEY `user_index` (`user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_files_trash`
--

LOCK TABLES `oc_files_trash` WRITE;
/*!40000 ALTER TABLE `oc_files_trash` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_files_trash` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_flow_checks`
--

DROP TABLE IF EXISTS `oc_flow_checks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_flow_checks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `class` varchar(256) NOT NULL DEFAULT '',
  `operator` varchar(16) NOT NULL DEFAULT '',
  `value` longtext DEFAULT NULL,
  `hash` varchar(32) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `flow_unique_hash` (`hash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_flow_checks`
--

LOCK TABLES `oc_flow_checks` WRITE;
/*!40000 ALTER TABLE `oc_flow_checks` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_flow_checks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_flow_operations`
--

DROP TABLE IF EXISTS `oc_flow_operations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_flow_operations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `class` varchar(256) NOT NULL DEFAULT '',
  `name` varchar(256) DEFAULT '',
  `checks` longtext DEFAULT NULL,
  `operation` longtext DEFAULT NULL,
  `entity` varchar(256) NOT NULL DEFAULT 'OCA\\WorkflowEngine\\Entity\\File',
  `events` longtext NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_flow_operations`
--

LOCK TABLES `oc_flow_operations` WRITE;
/*!40000 ALTER TABLE `oc_flow_operations` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_flow_operations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_flow_operations_scope`
--

DROP TABLE IF EXISTS `oc_flow_operations_scope`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_flow_operations_scope` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `operation_id` int(11) NOT NULL DEFAULT 0,
  `type` int(11) NOT NULL DEFAULT 0,
  `value` varchar(64) DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `flow_unique_scope` (`operation_id`,`type`,`value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_flow_operations_scope`
--

LOCK TABLES `oc_flow_operations_scope` WRITE;
/*!40000 ALTER TABLE `oc_flow_operations_scope` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_flow_operations_scope` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_group_admin`
--

DROP TABLE IF EXISTS `oc_group_admin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_group_admin` (
  `gid` varchar(64) NOT NULL DEFAULT '',
  `uid` varchar(64) NOT NULL DEFAULT '',
  PRIMARY KEY (`gid`,`uid`),
  KEY `group_admin_uid` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_group_admin`
--

LOCK TABLES `oc_group_admin` WRITE;
/*!40000 ALTER TABLE `oc_group_admin` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_group_admin` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_group_user`
--

DROP TABLE IF EXISTS `oc_group_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_group_user` (
  `gid` varchar(64) NOT NULL DEFAULT '',
  `uid` varchar(64) NOT NULL DEFAULT '',
  PRIMARY KEY (`gid`,`uid`),
  KEY `gu_uid_index` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_group_user`
--

LOCK TABLES `oc_group_user` WRITE;
/*!40000 ALTER TABLE `oc_group_user` DISABLE KEYS */;
INSERT INTO `oc_group_user` VALUES ('admin','nextcloud');
/*!40000 ALTER TABLE `oc_group_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_groups`
--

DROP TABLE IF EXISTS `oc_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_groups` (
  `gid` varchar(64) NOT NULL DEFAULT '',
  `displayname` varchar(255) NOT NULL DEFAULT 'name',
  PRIMARY KEY (`gid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_groups`
--

LOCK TABLES `oc_groups` WRITE;
/*!40000 ALTER TABLE `oc_groups` DISABLE KEYS */;
INSERT INTO `oc_groups` VALUES ('admin','admin');
/*!40000 ALTER TABLE `oc_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_jobs`
--

DROP TABLE IF EXISTS `oc_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `class` varchar(255) NOT NULL DEFAULT '',
  `argument` varchar(4000) NOT NULL DEFAULT '',
  `last_run` int(11) DEFAULT 0,
  `last_checked` int(11) DEFAULT 0,
  `reserved_at` int(11) DEFAULT 0,
  `execution_duration` int(11) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `job_class_index` (`class`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_jobs`
--

LOCK TABLES `oc_jobs` WRITE;
/*!40000 ALTER TABLE `oc_jobs` DISABLE KEYS */;
INSERT INTO `oc_jobs` VALUES (1,'OCA\\Files_Sharing\\DeleteOrphanedSharesJob','null',1689001665,1689001665,0,0),(2,'OCA\\Files_Sharing\\ExpireSharesJob','null',1689001675,1689001675,0,0),(3,'OCA\\Files_Sharing\\BackgroundJob\\FederatedSharesDiscoverJob','null',1689001706,1689001706,0,0),(4,'OCA\\Federation\\SyncJob','null',1689001713,1689001713,0,0),(5,'OCA\\ServerInfo\\Jobs\\UpdateStorageStats','null',1689001717,1689001717,0,0),(6,'OCA\\Files_Versions\\BackgroundJob\\ExpireVersions','null',0,1689001659,0,0),(7,'OCA\\UserStatus\\BackgroundJob\\ClearOldStatusesBackgroundJob','null',0,1689001659,0,0),(8,'OCA\\Notifications\\BackgroundJob\\GenerateUserSettings','null',0,1689001659,0,0),(9,'OCA\\Notifications\\BackgroundJob\\SendNotificationMails','null',0,1689001659,0,0),(10,'OCA\\Files_Trashbin\\BackgroundJob\\ExpireTrash','null',0,1689001660,0,0),(11,'OCA\\WorkflowEngine\\BackgroundJobs\\Rotate','null',0,1689001660,0,0),(12,'OCA\\Files\\BackgroundJob\\ScanFiles','null',0,1689001660,0,0),(13,'OCA\\Files\\BackgroundJob\\DeleteOrphanedItems','null',0,1689001660,0,0),(14,'OCA\\Files\\BackgroundJob\\CleanupFileLocks','null',0,1689001660,0,0),(15,'OCA\\Files\\BackgroundJob\\CleanupDirectEditingTokens','null',0,1689001660,0,0),(16,'OCA\\Support\\BackgroundJobs\\CheckSubscription','null',0,1689001660,0,0),(17,'OCA\\NextcloudAnnouncements\\Cron\\Crawler','null',0,1689001660,0,0),(18,'OCA\\Circles\\Cron\\Maintenance','null',0,1689001660,0,0),(19,'OCA\\ContactsInteraction\\BackgroundJob\\CleanupJob','null',0,1689001660,0,0),(20,'OCA\\Text\\Cron\\Cleanup','null',0,1689001660,0,0),(21,'OCA\\DAV\\BackgroundJob\\CleanupDirectLinksJob','null',0,1689001660,0,0),(22,'OCA\\DAV\\BackgroundJob\\UpdateCalendarResourcesRoomsBackgroundJob','null',0,1689001660,0,0),(23,'OCA\\DAV\\BackgroundJob\\CleanupInvitationTokenJob','null',0,1689001660,0,0),(24,'OCA\\DAV\\BackgroundJob\\EventReminderJob','null',0,1689001660,0,0),(25,'OCA\\DAV\\BackgroundJob\\CalendarRetentionJob','null',0,1689001660,0,0),(26,'OCA\\Activity\\BackgroundJob\\EmailNotification','null',0,1689001660,0,0),(27,'OCA\\Activity\\BackgroundJob\\ExpireActivities','null',0,1689001660,0,0),(28,'OCA\\Activity\\BackgroundJob\\DigestMail','null',0,1689001660,0,0),(29,'OCA\\UpdateNotification\\Notification\\BackgroundJob','null',0,1689001660,0,0),(30,'OC\\Authentication\\Token\\DefaultTokenCleanupJob','null',0,1689001663,0,0),(31,'OC\\Log\\Rotate','null',0,1689001663,0,0),(32,'OC\\Preview\\BackgroundCleanupJob','null',0,1689001663,0,0),(33,'OCA\\FirstRunWizard\\Notification\\BackgroundJob','{\"uid\":\"nextcloud\"}',0,1689001665,0,0),(34,'OCA\\FirstRunWizard\\Notification\\BackgroundJob','{\"uid\":\"user1\"}',0,1689001712,0,0);
/*!40000 ALTER TABLE `oc_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_known_users`
--

DROP TABLE IF EXISTS `oc_known_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_known_users` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `known_to` varchar(255) NOT NULL,
  `known_user` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ku_known_to` (`known_to`),
  KEY `ku_known_user` (`known_user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_known_users`
--

LOCK TABLES `oc_known_users` WRITE;
/*!40000 ALTER TABLE `oc_known_users` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_known_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_login_flow_v2`
--

DROP TABLE IF EXISTS `oc_login_flow_v2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_login_flow_v2` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `timestamp` bigint(20) unsigned NOT NULL,
  `started` smallint(5) unsigned NOT NULL DEFAULT 0,
  `poll_token` varchar(255) NOT NULL,
  `login_token` varchar(255) NOT NULL,
  `public_key` text NOT NULL,
  `private_key` text NOT NULL,
  `client_name` varchar(255) NOT NULL,
  `login_name` varchar(255) DEFAULT NULL,
  `server` varchar(255) DEFAULT NULL,
  `app_password` varchar(1024) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `poll_token` (`poll_token`),
  UNIQUE KEY `login_token` (`login_token`),
  KEY `timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_login_flow_v2`
--

LOCK TABLES `oc_login_flow_v2` WRITE;
/*!40000 ALTER TABLE `oc_login_flow_v2` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_login_flow_v2` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_migrations`
--

DROP TABLE IF EXISTS `oc_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_migrations` (
  `app` varchar(255) NOT NULL,
  `version` varchar(255) NOT NULL,
  PRIMARY KEY (`app`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_migrations`
--

LOCK TABLES `oc_migrations` WRITE;
/*!40000 ALTER TABLE `oc_migrations` DISABLE KEYS */;
INSERT INTO `oc_migrations` VALUES ('activity','2006Date20170808154933'),('activity','2006Date20170808155040'),('activity','2006Date20170919095939'),('activity','2007Date20181107114613'),('activity','2008Date20181011095117'),('activity','2010Date20190416112817'),('activity','2011Date20201006132544'),('activity','2011Date20201006132545'),('activity','2011Date20201006132546'),('activity','2011Date20201006132547'),('activity','2011Date20201207091915'),('circles','0022Date20220526111723'),('circles','0022Date20220526113601'),('circles','0022Date20220703115023'),('contactsinteraction','010000Date20200304152605'),('core','13000Date20170705121758'),('core','13000Date20170718121200'),('core','13000Date20170814074715'),('core','13000Date20170919121250'),('core','13000Date20170926101637'),('core','14000Date20180129121024'),('core','14000Date20180404140050'),('core','14000Date20180516101403'),('core','14000Date20180518120534'),('core','14000Date20180522074438'),('core','14000Date20180626223656'),('core','14000Date20180710092004'),('core','14000Date20180712153140'),('core','15000Date20180926101451'),('core','15000Date20181015062942'),('core','15000Date20181029084625'),('core','16000Date20190207141427'),('core','16000Date20190212081545'),('core','16000Date20190427105638'),('core','16000Date20190428150708'),('core','17000Date20190514105811'),('core','18000Date20190920085628'),('core','18000Date20191014105105'),('core','18000Date20191204114856'),('core','19000Date20200211083441'),('core','20000Date20201109081915'),('core','20000Date20201109081918'),('core','20000Date20201109081919'),('core','20000Date20201111081915'),('core','21000Date20201120141228'),('core','21000Date20201202095923'),('core','21000Date20210119195004'),('core','21000Date20210309185126'),('core','21000Date20210309185127'),('core','22000Date20210216080825'),('core','23000Date20210721100600'),('core','23000Date20210906132259'),('core','23000Date20210930122352'),('dav','1004Date20170825134824'),('dav','1004Date20170919104507'),('dav','1004Date20170924124212'),('dav','1004Date20170926103422'),('dav','1005Date20180413093149'),('dav','1005Date20180530124431'),('dav','1006Date20180619154313'),('dav','1006Date20180628111625'),('dav','1008Date20181030113700'),('dav','1008Date20181105104826'),('dav','1008Date20181105104833'),('dav','1008Date20181105110300'),('dav','1008Date20181105112049'),('dav','1008Date20181114084440'),('dav','1011Date20190725113607'),('dav','1011Date20190806104428'),('dav','1012Date20190808122342'),('dav','1016Date20201109085907'),('dav','1017Date20210216083742'),('dav','1018Date20210312100735'),('federatedfilesharing','1010Date20200630191755'),('federatedfilesharing','1011Date20201120125158'),('federation','1010Date20200630191302'),('files','11301Date20191205150729'),('files_sharing','11300Date20201120141438'),('files_sharing','21000Date20201223143245'),('files_sharing','22000Date20210216084241'),('files_trashbin','1010Date20200630192639'),('notifications','2004Date20190107135757'),('notifications','2010Date20210218082811'),('notifications','2010Date20210218082855'),('notifications','2011Date20210930134607'),('oauth2','010401Date20181207190718'),('oauth2','010402Date20190107124745'),('privacy','100Date20190217131943'),('text','010000Date20190617184535'),('text','030001Date20200402075029'),('text','030201Date20201116110353'),('text','030201Date20201116123153'),('twofactor_backupcodes','1002Date20170607104347'),('twofactor_backupcodes','1002Date20170607113030'),('twofactor_backupcodes','1002Date20170919123342'),('twofactor_backupcodes','1002Date20170926101419'),('twofactor_backupcodes','1002Date20180821043638'),('user_status','0001Date20200602134824'),('user_status','0002Date20200902144824'),('user_status','1000Date20201111130204'),('user_status','2301Date20210809144824'),('workflowengine','2000Date20190808074233'),('workflowengine','2200Date20210805101925');
/*!40000 ALTER TABLE `oc_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_mimetypes`
--

DROP TABLE IF EXISTS `oc_mimetypes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_mimetypes` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `mimetype` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `mimetype_id_index` (`mimetype`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_mimetypes`
--

LOCK TABLES `oc_mimetypes` WRITE;
/*!40000 ALTER TABLE `oc_mimetypes` DISABLE KEYS */;
INSERT INTO `oc_mimetypes` VALUES (3,'application'),(18,'application/javascript'),(4,'application/json'),(13,'application/octet-stream'),(5,'application/pdf'),(12,'application/vnd.oasis.opendocument.presentation'),(14,'application/vnd.oasis.opendocument.spreadsheet'),(11,'application/vnd.oasis.opendocument.text'),(8,'application/vnd.openxmlformats-officedocument.wordprocessingml.document'),(19,'application/x-gzip'),(1,'httpd'),(2,'httpd/unix-directory'),(9,'image'),(17,'image/jpeg'),(10,'image/png'),(21,'image/svg+xml'),(6,'text'),(20,'text/css'),(7,'text/markdown'),(15,'video'),(16,'video/mp4');
/*!40000 ALTER TABLE `oc_mimetypes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_mounts`
--

DROP TABLE IF EXISTS `oc_mounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_mounts` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `storage_id` bigint(20) NOT NULL,
  `root_id` bigint(20) NOT NULL,
  `user_id` varchar(64) NOT NULL,
  `mount_point` varchar(4000) NOT NULL,
  `mount_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mounts_user_root_index` (`user_id`,`root_id`),
  KEY `mounts_storage_index` (`storage_id`),
  KEY `mounts_root_index` (`root_id`),
  KEY `mounts_mount_id_index` (`mount_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_mounts`
--

LOCK TABLES `oc_mounts` WRITE;
/*!40000 ALTER TABLE `oc_mounts` DISABLE KEYS */;
INSERT INTO `oc_mounts` VALUES (1,2,5,'nextcloud','/nextcloud/',NULL),(2,3,148,'user1','/user1/',NULL);
/*!40000 ALTER TABLE `oc_mounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_notifications`
--

DROP TABLE IF EXISTS `oc_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_notifications` (
  `notification_id` int(11) NOT NULL AUTO_INCREMENT,
  `app` varchar(32) NOT NULL,
  `user` varchar(64) NOT NULL,
  `timestamp` int(11) NOT NULL DEFAULT 0,
  `object_type` varchar(64) NOT NULL,
  `object_id` varchar(64) NOT NULL,
  `subject` varchar(64) NOT NULL,
  `subject_parameters` longtext DEFAULT NULL,
  `message` varchar(64) DEFAULT NULL,
  `message_parameters` longtext DEFAULT NULL,
  `link` varchar(4000) DEFAULT NULL,
  `icon` varchar(4000) DEFAULT NULL,
  `actions` longtext DEFAULT NULL,
  PRIMARY KEY (`notification_id`),
  KEY `oc_notifications_app` (`app`),
  KEY `oc_notifications_user` (`user`),
  KEY `oc_notifications_timestamp` (`timestamp`),
  KEY `oc_notifications_object` (`object_type`,`object_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_notifications`
--

LOCK TABLES `oc_notifications` WRITE;
/*!40000 ALTER TABLE `oc_notifications` DISABLE KEYS */;
INSERT INTO `oc_notifications` VALUES (1,'firstrunwizard','nextcloud',1689001665,'app','groupfolders','apphint-groupfolders','[]','','[]','','','[]'),(2,'firstrunwizard','nextcloud',1689001665,'app','social','apphint-social','[]','','[]','','','[]'),(3,'firstrunwizard','nextcloud',1689001665,'app','notes','apphint-notes','[]','','[]','','','[]'),(4,'firstrunwizard','nextcloud',1689001665,'app','deck','apphint-deck','[]','','[]','','','[]'),(5,'firstrunwizard','nextcloud',1689001665,'app','tasks','apphint-tasks','[]','','[]','','','[]');
/*!40000 ALTER TABLE `oc_notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_notifications_pushhash`
--

DROP TABLE IF EXISTS `oc_notifications_pushhash`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_notifications_pushhash` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` varchar(64) NOT NULL,
  `token` int(11) NOT NULL DEFAULT 0,
  `deviceidentifier` varchar(128) NOT NULL,
  `devicepublickey` varchar(512) NOT NULL,
  `devicepublickeyhash` varchar(128) NOT NULL,
  `pushtokenhash` varchar(128) NOT NULL,
  `proxyserver` varchar(256) NOT NULL,
  `apptype` varchar(32) NOT NULL DEFAULT 'unknown',
  PRIMARY KEY (`id`),
  UNIQUE KEY `oc_npushhash_uid` (`uid`,`token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_notifications_pushhash`
--

LOCK TABLES `oc_notifications_pushhash` WRITE;
/*!40000 ALTER TABLE `oc_notifications_pushhash` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_notifications_pushhash` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_notifications_settings`
--

DROP TABLE IF EXISTS `oc_notifications_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_notifications_settings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(64) NOT NULL,
  `batch_time` int(11) NOT NULL DEFAULT 0,
  `last_send_id` bigint(20) NOT NULL DEFAULT 0,
  `next_send_time` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `notset_user` (`user_id`),
  KEY `notset_nextsend` (`next_send_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_notifications_settings`
--

LOCK TABLES `oc_notifications_settings` WRITE;
/*!40000 ALTER TABLE `oc_notifications_settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_notifications_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_oauth2_access_tokens`
--

DROP TABLE IF EXISTS `oc_oauth2_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_oauth2_access_tokens` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `token_id` int(11) NOT NULL,
  `client_id` int(11) NOT NULL,
  `hashed_code` varchar(128) NOT NULL,
  `encrypted_token` varchar(786) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `oauth2_access_hash_idx` (`hashed_code`),
  KEY `oauth2_access_client_id_idx` (`client_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_oauth2_access_tokens`
--

LOCK TABLES `oc_oauth2_access_tokens` WRITE;
/*!40000 ALTER TABLE `oc_oauth2_access_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_oauth2_access_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_oauth2_clients`
--

DROP TABLE IF EXISTS `oc_oauth2_clients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_oauth2_clients` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `redirect_uri` varchar(2000) NOT NULL,
  `client_identifier` varchar(64) NOT NULL,
  `secret` varchar(64) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `oauth2_client_id_idx` (`client_identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_oauth2_clients`
--

LOCK TABLES `oc_oauth2_clients` WRITE;
/*!40000 ALTER TABLE `oc_oauth2_clients` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_oauth2_clients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_preferences`
--

DROP TABLE IF EXISTS `oc_preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_preferences` (
  `userid` varchar(64) NOT NULL DEFAULT '',
  `appid` varchar(32) NOT NULL DEFAULT '',
  `configkey` varchar(64) NOT NULL DEFAULT '',
  `configvalue` longtext DEFAULT NULL,
  PRIMARY KEY (`userid`,`appid`,`configkey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_preferences`
--

LOCK TABLES `oc_preferences` WRITE;
/*!40000 ALTER TABLE `oc_preferences` DISABLE KEYS */;
INSERT INTO `oc_preferences` VALUES ('nextcloud','avatar','generated','true'),('nextcloud','core','lang','en'),('nextcloud','core','templateDirectory','Templates/'),('nextcloud','firstrunwizard','apphint','18'),('nextcloud','firstrunwizard','show','0'),('nextcloud','login','lastLogin','1689001663'),('user1','activity','configured','yes'),('user1','avatar','generated','true'),('user1','core','lang','en'),('user1','core','templateDirectory','Templates/'),('user1','core','timezone','Europe/Oslo'),('user1','dashboard','firstRun','0'),('user1','files','quota','default'),('user1','firstrunwizard','show','0'),('user1','login','lastLogin','1689001711'),('user1','password_policy','failedLoginAttempts','0');
/*!40000 ALTER TABLE `oc_preferences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_privacy_admins`
--

DROP TABLE IF EXISTS `oc_privacy_admins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_privacy_admins` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `displayname` varchar(64) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_privacy_admins`
--

LOCK TABLES `oc_privacy_admins` WRITE;
/*!40000 ALTER TABLE `oc_privacy_admins` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_privacy_admins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_profile_config`
--

DROP TABLE IF EXISTS `oc_profile_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_profile_config` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(64) NOT NULL,
  `config` longtext NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_profile_config`
--

LOCK TABLES `oc_profile_config` WRITE;
/*!40000 ALTER TABLE `oc_profile_config` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_profile_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_properties`
--

DROP TABLE IF EXISTS `oc_properties`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_properties` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `userid` varchar(64) NOT NULL DEFAULT '',
  `propertypath` varchar(255) NOT NULL DEFAULT '',
  `propertyname` varchar(255) NOT NULL DEFAULT '',
  `propertyvalue` longtext NOT NULL,
  PRIMARY KEY (`id`),
  KEY `property_index` (`userid`),
  KEY `properties_path_index` (`userid`,`propertypath`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_properties`
--

LOCK TABLES `oc_properties` WRITE;
/*!40000 ALTER TABLE `oc_properties` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_properties` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_ratelimit_entries`
--

DROP TABLE IF EXISTS `oc_ratelimit_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_ratelimit_entries` (
  `hash` varchar(128) NOT NULL,
  `delete_after` datetime NOT NULL,
  KEY `ratelimit_hash` (`hash`),
  KEY `ratelimit_delete_after` (`delete_after`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_ratelimit_entries`
--

LOCK TABLES `oc_ratelimit_entries` WRITE;
/*!40000 ALTER TABLE `oc_ratelimit_entries` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_ratelimit_entries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_recent_contact`
--

DROP TABLE IF EXISTS `oc_recent_contact`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_recent_contact` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `actor_uid` varchar(64) NOT NULL,
  `uid` varchar(64) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `federated_cloud_id` varchar(255) DEFAULT NULL,
  `card` longblob NOT NULL,
  `last_contact` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `recent_contact_actor_uid` (`actor_uid`),
  KEY `recent_contact_id_uid` (`id`,`actor_uid`),
  KEY `recent_contact_uid` (`uid`),
  KEY `recent_contact_email` (`email`),
  KEY `recent_contact_fed_id` (`federated_cloud_id`),
  KEY `recent_contact_last_contact` (`last_contact`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_recent_contact`
--

LOCK TABLES `oc_recent_contact` WRITE;
/*!40000 ALTER TABLE `oc_recent_contact` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_recent_contact` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_schedulingobjects`
--

DROP TABLE IF EXISTS `oc_schedulingobjects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_schedulingobjects` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `principaluri` varchar(255) DEFAULT NULL,
  `calendardata` longblob DEFAULT NULL,
  `uri` varchar(255) DEFAULT NULL,
  `lastmodified` int(10) unsigned DEFAULT NULL,
  `etag` varchar(32) DEFAULT NULL,
  `size` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `schedulobj_principuri_index` (`principaluri`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_schedulingobjects`
--

LOCK TABLES `oc_schedulingobjects` WRITE;
/*!40000 ALTER TABLE `oc_schedulingobjects` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_schedulingobjects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_share`
--

DROP TABLE IF EXISTS `oc_share`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_share` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `share_type` smallint(6) NOT NULL DEFAULT 0,
  `share_with` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `uid_owner` varchar(64) NOT NULL DEFAULT '',
  `uid_initiator` varchar(64) DEFAULT NULL,
  `parent` bigint(20) DEFAULT NULL,
  `item_type` varchar(64) NOT NULL DEFAULT '',
  `item_source` varchar(255) DEFAULT NULL,
  `item_target` varchar(255) DEFAULT NULL,
  `file_source` bigint(20) DEFAULT NULL,
  `file_target` varchar(512) DEFAULT NULL,
  `permissions` smallint(6) NOT NULL DEFAULT 0,
  `stime` bigint(20) NOT NULL DEFAULT 0,
  `accepted` smallint(6) NOT NULL DEFAULT 0,
  `expiration` datetime DEFAULT NULL,
  `token` varchar(32) DEFAULT NULL,
  `mail_send` smallint(6) NOT NULL DEFAULT 0,
  `share_name` varchar(64) DEFAULT NULL,
  `password_by_talk` tinyint(1) DEFAULT 0,
  `note` longtext DEFAULT NULL,
  `hide_download` smallint(6) DEFAULT 0,
  `label` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `item_share_type_index` (`item_type`,`share_type`),
  KEY `file_source_index` (`file_source`),
  KEY `token_index` (`token`),
  KEY `share_with_index` (`share_with`),
  KEY `parent_index` (`parent`),
  KEY `owner_index` (`uid_owner`),
  KEY `initiator_index` (`uid_initiator`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_share`
--

LOCK TABLES `oc_share` WRITE;
/*!40000 ALTER TABLE `oc_share` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_share` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_share_external`
--

DROP TABLE IF EXISTS `oc_share_external`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_share_external` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `parent` bigint(20) DEFAULT -1,
  `share_type` int(11) DEFAULT NULL,
  `remote` varchar(512) NOT NULL,
  `remote_id` varchar(255) DEFAULT '',
  `share_token` varchar(64) NOT NULL,
  `password` varchar(64) DEFAULT NULL,
  `name` varchar(64) NOT NULL,
  `owner` varchar(64) NOT NULL,
  `user` varchar(64) NOT NULL,
  `mountpoint` varchar(4000) NOT NULL,
  `mountpoint_hash` varchar(32) NOT NULL,
  `accepted` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sh_external_mp` (`user`,`mountpoint_hash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_share_external`
--

LOCK TABLES `oc_share_external` WRITE;
/*!40000 ALTER TABLE `oc_share_external` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_share_external` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_storages`
--

DROP TABLE IF EXISTS `oc_storages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_storages` (
  `numeric_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `id` varchar(64) DEFAULT NULL,
  `available` int(11) NOT NULL DEFAULT 1,
  `last_checked` int(11) DEFAULT NULL,
  PRIMARY KEY (`numeric_id`),
  UNIQUE KEY `storages_id_index` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_storages`
--

LOCK TABLES `oc_storages` WRITE;
/*!40000 ALTER TABLE `oc_storages` DISABLE KEYS */;
INSERT INTO `oc_storages` VALUES (1,'local::/var/www/html/data/',1,NULL),(2,'home::nextcloud',1,NULL),(3,'home::user1',1,NULL);
/*!40000 ALTER TABLE `oc_storages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_storages_credentials`
--

DROP TABLE IF EXISTS `oc_storages_credentials`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_storages_credentials` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user` varchar(64) DEFAULT NULL,
  `identifier` varchar(64) NOT NULL,
  `credentials` longtext DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `stocred_ui` (`user`,`identifier`),
  KEY `stocred_user` (`user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_storages_credentials`
--

LOCK TABLES `oc_storages_credentials` WRITE;
/*!40000 ALTER TABLE `oc_storages_credentials` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_storages_credentials` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_systemtag`
--

DROP TABLE IF EXISTS `oc_systemtag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_systemtag` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL DEFAULT '',
  `visibility` smallint(6) NOT NULL DEFAULT 1,
  `editable` smallint(6) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `tag_ident` (`name`,`visibility`,`editable`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_systemtag`
--

LOCK TABLES `oc_systemtag` WRITE;
/*!40000 ALTER TABLE `oc_systemtag` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_systemtag` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_systemtag_group`
--

DROP TABLE IF EXISTS `oc_systemtag_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_systemtag_group` (
  `systemtagid` bigint(20) unsigned NOT NULL DEFAULT 0,
  `gid` varchar(255) NOT NULL,
  PRIMARY KEY (`gid`,`systemtagid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_systemtag_group`
--

LOCK TABLES `oc_systemtag_group` WRITE;
/*!40000 ALTER TABLE `oc_systemtag_group` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_systemtag_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_systemtag_object_mapping`
--

DROP TABLE IF EXISTS `oc_systemtag_object_mapping`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_systemtag_object_mapping` (
  `objectid` varchar(64) NOT NULL DEFAULT '',
  `objecttype` varchar(64) NOT NULL DEFAULT '',
  `systemtagid` bigint(20) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`objecttype`,`objectid`,`systemtagid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_systemtag_object_mapping`
--

LOCK TABLES `oc_systemtag_object_mapping` WRITE;
/*!40000 ALTER TABLE `oc_systemtag_object_mapping` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_systemtag_object_mapping` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_text_documents`
--

DROP TABLE IF EXISTS `oc_text_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_text_documents` (
  `id` bigint(20) unsigned NOT NULL,
  `current_version` bigint(20) unsigned DEFAULT 0,
  `last_saved_version` bigint(20) unsigned DEFAULT 0,
  `last_saved_version_time` bigint(20) unsigned NOT NULL,
  `last_saved_version_etag` varchar(64) DEFAULT '',
  `base_version_etag` varchar(64) DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_text_documents`
--

LOCK TABLES `oc_text_documents` WRITE;
/*!40000 ALTER TABLE `oc_text_documents` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_text_documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_text_sessions`
--

DROP TABLE IF EXISTS `oc_text_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_text_sessions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` varchar(64) DEFAULT NULL,
  `guest_name` varchar(64) DEFAULT NULL,
  `color` varchar(7) DEFAULT NULL,
  `token` varchar(64) NOT NULL,
  `document_id` bigint(20) NOT NULL,
  `last_contact` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `rd_session_token_idx` (`token`),
  KEY `ts_docid_lastcontact` (`document_id`,`last_contact`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_text_sessions`
--

LOCK TABLES `oc_text_sessions` WRITE;
/*!40000 ALTER TABLE `oc_text_sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_text_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_text_steps`
--

DROP TABLE IF EXISTS `oc_text_steps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_text_steps` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `document_id` bigint(20) unsigned NOT NULL,
  `session_id` bigint(20) unsigned NOT NULL,
  `data` longtext NOT NULL,
  `version` bigint(20) unsigned DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `rd_steps_did_idx` (`document_id`),
  KEY `rd_steps_version_idx` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_text_steps`
--

LOCK TABLES `oc_text_steps` WRITE;
/*!40000 ALTER TABLE `oc_text_steps` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_text_steps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_trusted_servers`
--

DROP TABLE IF EXISTS `oc_trusted_servers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_trusted_servers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` varchar(512) NOT NULL,
  `url_hash` varchar(255) NOT NULL DEFAULT '',
  `token` varchar(128) DEFAULT NULL,
  `shared_secret` varchar(256) DEFAULT NULL,
  `status` int(11) NOT NULL DEFAULT 2,
  `sync_token` varchar(512) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `url_hash` (`url_hash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_trusted_servers`
--

LOCK TABLES `oc_trusted_servers` WRITE;
/*!40000 ALTER TABLE `oc_trusted_servers` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_trusted_servers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_twofactor_backupcodes`
--

DROP TABLE IF EXISTS `oc_twofactor_backupcodes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_twofactor_backupcodes` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(64) NOT NULL DEFAULT '',
  `code` varchar(128) NOT NULL,
  `used` smallint(6) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `twofactor_backupcodes_uid` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_twofactor_backupcodes`
--

LOCK TABLES `oc_twofactor_backupcodes` WRITE;
/*!40000 ALTER TABLE `oc_twofactor_backupcodes` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_twofactor_backupcodes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_twofactor_providers`
--

DROP TABLE IF EXISTS `oc_twofactor_providers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_twofactor_providers` (
  `provider_id` varchar(32) NOT NULL,
  `uid` varchar(64) NOT NULL,
  `enabled` smallint(6) NOT NULL,
  PRIMARY KEY (`provider_id`,`uid`),
  KEY `twofactor_providers_uid` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_twofactor_providers`
--

LOCK TABLES `oc_twofactor_providers` WRITE;
/*!40000 ALTER TABLE `oc_twofactor_providers` DISABLE KEYS */;
INSERT INTO `oc_twofactor_providers` VALUES ('backup_codes','nextcloud',0),('backup_codes','user1',0);
/*!40000 ALTER TABLE `oc_twofactor_providers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_user_status`
--

DROP TABLE IF EXISTS `oc_user_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_user_status` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` varchar(255) NOT NULL,
  `status` varchar(255) NOT NULL,
  `status_timestamp` int(10) unsigned NOT NULL,
  `is_user_defined` tinyint(1) DEFAULT NULL,
  `message_id` varchar(255) DEFAULT NULL,
  `custom_icon` varchar(255) DEFAULT NULL,
  `custom_message` longtext DEFAULT NULL,
  `clear_at` int(10) unsigned DEFAULT NULL,
  `is_backup` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_status_uid_ix` (`user_id`),
  KEY `user_status_clr_ix` (`clear_at`),
  KEY `user_status_tstmp_ix` (`status_timestamp`),
  KEY `user_status_iud_ix` (`is_user_defined`,`status`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_user_status`
--

LOCK TABLES `oc_user_status` WRITE;
/*!40000 ALTER TABLE `oc_user_status` DISABLE KEYS */;
INSERT INTO `oc_user_status` VALUES (1,'nextcloud','online',1689001665,0,NULL,NULL,NULL,NULL,0),(2,'user1','online',1689001712,0,NULL,NULL,NULL,NULL,0);
/*!40000 ALTER TABLE `oc_user_status` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_user_transfer_owner`
--

DROP TABLE IF EXISTS `oc_user_transfer_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_user_transfer_owner` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `source_user` varchar(64) NOT NULL,
  `target_user` varchar(64) NOT NULL,
  `file_id` bigint(20) NOT NULL,
  `node_name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_user_transfer_owner`
--

LOCK TABLES `oc_user_transfer_owner` WRITE;
/*!40000 ALTER TABLE `oc_user_transfer_owner` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_user_transfer_owner` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_users`
--

DROP TABLE IF EXISTS `oc_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_users` (
  `uid` varchar(64) NOT NULL DEFAULT '',
  `displayname` varchar(64) DEFAULT NULL,
  `password` varchar(255) NOT NULL DEFAULT '',
  `uid_lower` varchar(64) DEFAULT '',
  PRIMARY KEY (`uid`),
  KEY `user_uid_lower` (`uid_lower`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_users`
--

LOCK TABLES `oc_users` WRITE;
/*!40000 ALTER TABLE `oc_users` DISABLE KEYS */;
INSERT INTO `oc_users` VALUES ('nextcloud',NULL,'3|$argon2id$v=19$m=65536,t=4,p=1$aEFTWUMzU2hHWWtmbkxpRw$DuXXlS37CylnOuVbOEFOUD8k8KsVV1VPc6UdcZlofsI','nextcloud'),('user1',NULL,'3|$argon2id$v=19$m=65536,t=4,p=1$MW1EYzI0TjZKMnNnUWhaQQ$V99znBZa6doW2SAkaAMjVYVoNVAH2Y6Z3UtRT2KYSsg','user1');
/*!40000 ALTER TABLE `oc_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_vcategory`
--

DROP TABLE IF EXISTS `oc_vcategory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_vcategory` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `uid` varchar(64) NOT NULL DEFAULT '',
  `type` varchar(64) NOT NULL DEFAULT '',
  `category` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `uid_index` (`uid`),
  KEY `type_index` (`type`),
  KEY `category_index` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_vcategory`
--

LOCK TABLES `oc_vcategory` WRITE;
/*!40000 ALTER TABLE `oc_vcategory` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_vcategory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_vcategory_to_object`
--

DROP TABLE IF EXISTS `oc_vcategory_to_object`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_vcategory_to_object` (
  `objid` bigint(20) unsigned NOT NULL DEFAULT 0,
  `categoryid` bigint(20) unsigned NOT NULL DEFAULT 0,
  `type` varchar(64) NOT NULL DEFAULT '',
  PRIMARY KEY (`categoryid`,`objid`,`type`),
  KEY `vcategory_objectd_index` (`objid`,`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_vcategory_to_object`
--

LOCK TABLES `oc_vcategory_to_object` WRITE;
/*!40000 ALTER TABLE `oc_vcategory_to_object` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_vcategory_to_object` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_webauthn`
--

DROP TABLE IF EXISTS `oc_webauthn`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_webauthn` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` varchar(64) NOT NULL,
  `name` varchar(64) NOT NULL,
  `public_key_credential_id` varchar(255) NOT NULL,
  `data` longtext NOT NULL,
  PRIMARY KEY (`id`),
  KEY `webauthn_uid` (`uid`),
  KEY `webauthn_publicKeyCredentialId` (`public_key_credential_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_webauthn`
--

LOCK TABLES `oc_webauthn` WRITE;
/*!40000 ALTER TABLE `oc_webauthn` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_webauthn` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oc_whats_new`
--

DROP TABLE IF EXISTS `oc_whats_new`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oc_whats_new` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `version` varchar(64) NOT NULL DEFAULT '11',
  `etag` varchar(64) NOT NULL DEFAULT '',
  `last_check` int(10) unsigned NOT NULL DEFAULT 0,
  `data` longtext NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `version` (`version`),
  KEY `version_etag_idx` (`version`,`etag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPRESSED;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oc_whats_new`
--

LOCK TABLES `oc_whats_new` WRITE;
/*!40000 ALTER TABLE `oc_whats_new` DISABLE KEYS */;
/*!40000 ALTER TABLE `oc_whats_new` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2023-07-10 15:09:07
