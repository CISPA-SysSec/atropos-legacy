CREATE TABLE `phpwcms_address` (
  `address_id` int(11) NOT NULL AUTO_INCREMENT,
  `address_key` varchar(255) NOT NULL DEFAULT '',
  `address_email` text NOT NULL,
  `address_name` text NOT NULL,
  `address_verified` int(1) NOT NULL DEFAULT '0',
  `address_tstamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `address_subscription` blob NOT NULL,
  `address_iddetail` int(11) NOT NULL DEFAULT '0',
  `address_url1` varchar(255) NOT NULL DEFAULT '',
  `address_url2` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`address_id`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_ads_campaign` (
  `adcampaign_id` int(11) NOT NULL AUTO_INCREMENT,
  `adcampaign_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `adcampaign_changed` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `adcampaign_status` int(1) NOT NULL DEFAULT '0',
  `adcampaign_title` varchar(255) NOT NULL DEFAULT '',
  `adcampaign_comment` text NOT NULL,
  `adcampaign_datestart` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `adcampaign_dateend` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `adcampaign_maxview` int(11) NOT NULL DEFAULT '0',
  `adcampaign_maxclick` int(11) NOT NULL DEFAULT '0',
  `adcampaign_maxviewuser` int(11) NOT NULL DEFAULT '0',
  `adcampaign_curview` int(11) NOT NULL DEFAULT '0',
  `adcampaign_curclick` int(11) NOT NULL DEFAULT '0',
  `adcampaign_curviewuser` int(11) NOT NULL DEFAULT '0',
  `adcampaign_type` int(11) NOT NULL DEFAULT '0',
  `adcampaign_place` int(11) NOT NULL DEFAULT '0',
  `adcampaign_data` mediumtext NOT NULL,
  PRIMARY KEY (`adcampaign_id`),
  KEY `adcampaign_status` (`adcampaign_status`,`adcampaign_datestart`,`adcampaign_dateend`,`adcampaign_type`,`adcampaign_place`),
  KEY `adcampaign_maxview` (`adcampaign_maxview`,`adcampaign_maxclick`,`adcampaign_maxviewuser`),
  KEY `adcampaign_curview` (`adcampaign_curview`,`adcampaign_curclick`,`adcampaign_curviewuser`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_ads_formats` (
  `adformat_id` int(11) NOT NULL AUTO_INCREMENT,
  `adformat_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `adformat_changed` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `adformat_status` int(1) NOT NULL DEFAULT '0',
  `adformat_title` varchar(25) NOT NULL DEFAULT '',
  `adformat_width` int(5) NOT NULL DEFAULT '0',
  `adformat_height` int(5) NOT NULL DEFAULT '0',
  `adformat_comment` text NOT NULL,
  PRIMARY KEY (`adformat_id`),
  KEY `adformat_status` (`adformat_status`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_ads_place` (
  `adplace_id` int(11) NOT NULL AUTO_INCREMENT,
  `adplace_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `adplace_changed` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `adplace_status` int(1) NOT NULL DEFAULT '0',
  `adplace_title` varchar(255) NOT NULL DEFAULT '',
  `adplace_format` int(11) NOT NULL DEFAULT '0',
  `adplace_width` int(11) NOT NULL DEFAULT '0',
  `adplace_height` int(11) NOT NULL DEFAULT '0',
  `adplace_prefix` varchar(255) NOT NULL DEFAULT '',
  `adplace_suffix` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`adplace_id`),
  KEY `adplace_status` (`adplace_status`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_ads_tracking` (
  `adtracking_id` int(11) NOT NULL AUTO_INCREMENT,
  `adtracking_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `adtracking_campaignid` int(11) NOT NULL DEFAULT '0',
  `adtracking_ip` varchar(30) NOT NULL DEFAULT '',
  `adtracking_cookieid` varchar(50) NOT NULL DEFAULT '',
  `adtracking_countclick` int(11) NOT NULL DEFAULT '0',
  `adtracking_countview` int(11) NOT NULL DEFAULT '0',
  `adtracking_useragent` varchar(255) NOT NULL DEFAULT '',
  `adtracking_ref` text NOT NULL,
  `adtracking_catid` int(11) NOT NULL DEFAULT '0',
  `adtracking_articleid` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`adtracking_id`),
  KEY `adtracking_campaignid` (`adtracking_campaignid`,`adtracking_ip`,`adtracking_countclick`,`adtracking_countview`),
  KEY `adtracking_cookieid` (`adtracking_cookieid`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_article` (
  `article_id` int(11) NOT NULL AUTO_INCREMENT,
  `article_cid` int(11) NOT NULL DEFAULT '0',
  `article_tid` int(11) NOT NULL DEFAULT '0',
  `article_uid` int(11) NOT NULL DEFAULT '0',
  `article_tstamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `article_username` varchar(255) NOT NULL DEFAULT '',
  `article_title` text NOT NULL,
  `article_alias` varchar(1000) NOT NULL DEFAULT '',
  `article_keyword` text NOT NULL,
  `article_public` int(1) NOT NULL DEFAULT '1',
  `article_deleted` int(1) NOT NULL DEFAULT '0',
  `article_begin` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `article_end` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `article_aktiv` int(1) NOT NULL DEFAULT '0',
  `article_subtitle` text NOT NULL,
  `article_summary` mediumtext NOT NULL,
  `article_redirect` text NOT NULL,
  `article_sort` int(11) NOT NULL DEFAULT '0',
  `article_notitle` int(1) NOT NULL DEFAULT '0',
  `article_hidesummary` int(1) NOT NULL DEFAULT '0',
  `article_image` blob NOT NULL,
  `article_created` varchar(14) NOT NULL DEFAULT '',
  `article_cache` varchar(10) NOT NULL DEFAULT '0',
  `article_nosearch` char(1) NOT NULL DEFAULT '0',
  `article_nositemap` int(1) NOT NULL DEFAULT '0',
  `article_aliasid` int(11) NOT NULL DEFAULT '0',
  `article_headerdata` int(1) NOT NULL DEFAULT '0',
  `article_morelink` int(1) NOT NULL DEFAULT '1',
  `article_noteaser` int(1) unsigned NOT NULL DEFAULT '0',
  `article_pagetitle` varchar(2000) NOT NULL DEFAULT '',
  `article_paginate` int(1) NOT NULL DEFAULT '0',
  `article_serialized` blob NOT NULL,
  `article_priorize` int(5) NOT NULL DEFAULT '0',
  `article_norss` int(1) NOT NULL DEFAULT '1',
  `article_archive_status` int(1) NOT NULL DEFAULT '1',
  `article_menutitle` varchar(2000) NOT NULL DEFAULT '',
  `article_description` text NOT NULL,
  `article_lang` varchar(255) NOT NULL DEFAULT '',
  `article_lang_type` varchar(255) NOT NULL DEFAULT '',
  `article_lang_id` int(11) unsigned NOT NULL DEFAULT '0',
  `article_opengraph` int(1) unsigned NOT NULL DEFAULT '1',
  `article_canonical` varchar(2000) NOT NULL DEFAULT '',
  `article_meta` mediumtext NOT NULL,
  PRIMARY KEY (`article_id`),
  KEY `article_aktiv` (`article_aktiv`),
  KEY `article_public` (`article_public`),
  KEY `article_deleted` (`article_deleted`),
  KEY `article_nosearch` (`article_nosearch`),
  KEY `article_begin` (`article_begin`),
  KEY `article_end` (`article_end`),
  KEY `article_cid` (`article_cid`),
  KEY `article_tstamp` (`article_tstamp`),
  KEY `article_priorize` (`article_priorize`),
  KEY `article_sort` (`article_sort`),
  KEY `article_alias` (`article_alias`),
  KEY `article_archive_status` (`article_archive_status`),
  KEY `article_lang` (`article_lang`),
  KEY `article_lang_type` (`article_lang_type`),
  KEY `article_lang_id` (`article_lang_id`),
  KEY `article_noteaser` (`article_noteaser`),
  KEY `article_opengraph` (`article_opengraph`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_articlecat` (
  `acat_id` int(11) NOT NULL AUTO_INCREMENT,
  `acat_name` text NOT NULL,
  `acat_title` varchar(2000) NOT NULL DEFAULT '',
  `acat_info` text NOT NULL,
  `acat_public` int(1) NOT NULL DEFAULT '1',
  `acat_tstamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `acat_aktiv` int(1) NOT NULL DEFAULT '0',
  `acat_uid` int(11) NOT NULL DEFAULT '0',
  `acat_trash` int(1) NOT NULL DEFAULT '0',
  `acat_struct` int(11) NOT NULL DEFAULT '0',
  `acat_sort` int(11) NOT NULL DEFAULT '0',
  `acat_alias` varchar(1000) NOT NULL DEFAULT '',
  `acat_hidden` int(1) NOT NULL DEFAULT '0',
  `acat_template` int(11) NOT NULL DEFAULT '0',
  `acat_ssl` int(1) NOT NULL DEFAULT '0',
  `acat_regonly` int(1) NOT NULL DEFAULT '0',
  `acat_topcount` int(11) NOT NULL DEFAULT '0',
  `acat_redirect` text NOT NULL,
  `acat_order` int(2) NOT NULL DEFAULT '0',
  `acat_cache` varchar(10) NOT NULL DEFAULT '',
  `acat_nosearch` char(1) NOT NULL DEFAULT '',
  `acat_nositemap` int(1) NOT NULL DEFAULT '0',
  `acat_permit` text NOT NULL,
  `acat_maxlist` int(11) NOT NULL DEFAULT '0',
  `acat_cntpart` varchar(255) NOT NULL DEFAULT '',
  `acat_pagetitle` varchar(2000) NOT NULL DEFAULT '',
  `acat_paginate` int(1) NOT NULL DEFAULT '0',
  `acat_overwrite` varchar(255) NOT NULL DEFAULT '',
  `acat_archive` int(1) NOT NULL DEFAULT '0',
  `acat_class` varchar(255) NOT NULL DEFAULT '',
  `acat_keywords` varchar(255) NOT NULL DEFAULT '',
  `acat_cpdefault` int(10) unsigned NOT NULL DEFAULT '0',
  `acat_lang` varchar(255) NOT NULL DEFAULT '',
  `acat_lang_type` varchar(255) NOT NULL DEFAULT '',
  `acat_lang_id` int(11) unsigned NOT NULL DEFAULT '0',
  `acat_disable301` int(1) unsigned NOT NULL DEFAULT '0',
  `acat_opengraph` int(1) unsigned NOT NULL DEFAULT '1',
  `acat_canonical` varchar(2000) NOT NULL DEFAULT '',
  `acat_breadcrumb` int(1) unsigned NOT NULL DEFAULT '0',
  `acat_onepage` int(1) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`acat_id`),
  KEY `acat_struct` (`acat_struct`),
  KEY `acat_sort` (`acat_sort`),
  KEY `acat_alias` (`acat_alias`),
  KEY `acat_archive` (`acat_archive`),
  KEY `acat_lang` (`acat_lang`),
  KEY `acat_lang_type` (`acat_lang_type`),
  KEY `acat_lang_id` (`acat_lang_id`),
  KEY `acat_opengraph` (`acat_opengraph`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_articlecontent` (
  `acontent_id` int(11) NOT NULL AUTO_INCREMENT,
  `acontent_aid` int(11) NOT NULL DEFAULT '0',
  `acontent_uid` int(11) NOT NULL DEFAULT '0',
  `acontent_created` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `acontent_tstamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `acontent_title` text NOT NULL,
  `acontent_text` mediumtext NOT NULL,
  `acontent_type` int(10) NOT NULL DEFAULT '0',
  `acontent_sorting` int(11) NOT NULL DEFAULT '0',
  `acontent_image` text NOT NULL,
  `acontent_files` text NOT NULL,
  `acontent_visible` int(1) NOT NULL DEFAULT '0',
  `acontent_subtitle` text NOT NULL,
  `acontent_before` varchar(10) NOT NULL DEFAULT '',
  `acontent_after` varchar(10) NOT NULL DEFAULT '',
  `acontent_top` int(1) NOT NULL DEFAULT '0',
  `acontent_redirect` text NOT NULL,
  `acontent_html` mediumtext NOT NULL,
  `acontent_trash` int(1) NOT NULL DEFAULT '0',
  `acontent_alink` text NOT NULL,
  `acontent_media` mediumtext NOT NULL,
  `acontent_form` mediumtext NOT NULL,
  `acontent_newsletter` mediumtext NOT NULL,
  `acontent_block` varchar(200) NOT NULL DEFAULT 'CONTENT',
  `acontent_anchor` int(1) NOT NULL DEFAULT '0',
  `acontent_template` varchar(255) NOT NULL DEFAULT '',
  `acontent_spacer` int(1) NOT NULL DEFAULT '0',
  `acontent_tid` int(11) NOT NULL DEFAULT '0',
  `acontent_livedate` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `acontent_killdate` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `acontent_module` varchar(255) NOT NULL DEFAULT '',
  `acontent_comment` text NOT NULL,
  `acontent_paginate_page` int(5) NOT NULL DEFAULT '0',
  `acontent_paginate_title` varchar(2000) NOT NULL DEFAULT '',
  `acontent_category` varchar(255) NOT NULL DEFAULT '',
  `acontent_granted` int(11) NOT NULL DEFAULT '0',
  `acontent_tab` varchar(2000) NOT NULL DEFAULT '',
  `acontent_lang` varchar(255) NOT NULL DEFAULT '',
  `acontent_attr_class` varchar(255) NOT NULL DEFAULT '',
  `acontent_attr_id` varchar(255) NOT NULL DEFAULT '',
  `acontent_setting` mediumtext,
  `acontent_type_setting` varchar(20) NOT NULL DEFAULT '',
  PRIMARY KEY (`acontent_id`),
  KEY `acontent_aid` (`acontent_aid`),
  KEY `acontent_sorting` (`acontent_sorting`),
  KEY `acontent_type` (`acontent_type`),
  KEY `acontent_livedate` (`acontent_livedate`,`acontent_killdate`),
  KEY `acontent_paginate` (`acontent_paginate_page`),
  KEY `acontent_granted` (`acontent_granted`),
  KEY `acontent_lang` (`acontent_lang`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_cache` (
  `cache_id` int(11) NOT NULL AUTO_INCREMENT,
  `cache_hash` varchar(50) NOT NULL DEFAULT '',
  `cache_uri` text NOT NULL,
  `cache_cid` int(11) NOT NULL DEFAULT '0',
  `cache_aid` int(11) NOT NULL DEFAULT '0',
  `cache_timeout` varchar(20) NOT NULL DEFAULT '0',
  `cache_isprint` int(1) NOT NULL DEFAULT '0',
  `cache_changed` int(14) DEFAULT NULL,
  `cache_use` int(1) NOT NULL DEFAULT '0',
  `cache_searchable` int(1) NOT NULL DEFAULT '0',
  `cache_page` longtext NOT NULL,
  `cache_stripped` longtext NOT NULL,
  PRIMARY KEY (`cache_id`),
  KEY `cache_hash` (`cache_hash`),
  FULLTEXT KEY `cache_stripped` (`cache_stripped`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_calendar` (
  `calendar_id` int(11) NOT NULL AUTO_INCREMENT,
  `calendar_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `calendar_changed` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `calendar_status` int(1) NOT NULL DEFAULT '0',
  `calendar_start` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `calendar_end` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `calendar_allday` int(1) NOT NULL DEFAULT '0',
  `calendar_range` int(1) NOT NULL DEFAULT '0',
  `calendar_range_start` date NOT NULL DEFAULT '0000-00-00',
  `calendar_range_end` date NOT NULL DEFAULT '0000-00-00',
  `calendar_title` varchar(255) NOT NULL DEFAULT '',
  `calendar_where` varchar(255) NOT NULL DEFAULT '',
  `calendar_teaser` text NOT NULL,
  `calendar_text` mediumtext NOT NULL,
  `calendar_tag` varchar(255) NOT NULL DEFAULT '',
  `calendar_object` longtext NOT NULL,
  `calendar_refid` varchar(1000) NOT NULL DEFAULT '',
  `calendar_lang` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`calendar_id`),
  KEY `calendar_status` (`calendar_status`),
  KEY `calendar_start` (`calendar_start`),
  KEY `calendar_end` (`calendar_end`),
  KEY `calendar_tag` (`calendar_tag`),
  KEY `calendar_refid` (`calendar_refid`),
  KEY `calendar_range` (`calendar_range`),
  KEY `calendar_lang` (`calendar_lang`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_categories` (
  `cat_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `cat_type` varchar(255) NOT NULL DEFAULT '',
  `cat_pid` int(11) NOT NULL DEFAULT '0',
  `cat_status` int(1) NOT NULL DEFAULT '0',
  `cat_createdate` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `cat_changedate` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `cat_name` varchar(255) NOT NULL DEFAULT '',
  `cat_info` text NOT NULL,
  `cat_sort` int(11) NOT NULL DEFAULT '0',
  `cat_opengraph` int(1) unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`cat_id`),
  KEY `cat_type` (`cat_type`,`cat_status`),
  KEY `cat_pid` (`cat_pid`),
  KEY `cat_sort` (`cat_sort`),
  KEY `cat_opengraph` (`cat_opengraph`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_chat` (
  `chat_id` int(11) NOT NULL AUTO_INCREMENT,
  `chat_uid` int(11) NOT NULL DEFAULT '0',
  `chat_name` varchar(30) NOT NULL DEFAULT '',
  `chat_tstamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `chat_text` varchar(255) NOT NULL DEFAULT '',
  `chat_cat` int(5) NOT NULL DEFAULT '0',
  PRIMARY KEY (`chat_id`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_content` (
  `cnt_id` int(11) NOT NULL AUTO_INCREMENT,
  `cnt_pid` int(11) NOT NULL DEFAULT '0',
  `cnt_created` int(11) NOT NULL DEFAULT '0',
  `cnt_changed` int(11) NOT NULL DEFAULT '0',
  `cnt_status` int(1) NOT NULL DEFAULT '0',
  `cnt_type` varchar(255) NOT NULL DEFAULT '',
  `cnt_module` varchar(255) NOT NULL DEFAULT '',
  `cnt_group` int(11) NOT NULL DEFAULT '0',
  `cnt_owner` int(11) NOT NULL DEFAULT '0',
  `cnt_livedate` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `cnt_killdate` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `cnt_archive_status` int(11) NOT NULL DEFAULT '0',
  `cnt_sort` int(11) NOT NULL DEFAULT '0',
  `cnt_prio` int(11) NOT NULL DEFAULT '0',
  `cnt_alias` varchar(255) NOT NULL DEFAULT '',
  `cnt_name` varchar(255) NOT NULL DEFAULT '',
  `cnt_title` varchar(255) NOT NULL DEFAULT '',
  `cnt_subtitle` varchar(255) NOT NULL DEFAULT '',
  `cnt_editor` varchar(255) NOT NULL DEFAULT '',
  `cnt_place` varchar(255) NOT NULL DEFAULT '',
  `cnt_teasertext` text NOT NULL,
  `cnt_text` text NOT NULL,
  `cnt_lang` varchar(10) NOT NULL DEFAULT '',
  `cnt_object` text NOT NULL,
  `cnt_opengraph` int(1) unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`cnt_id`),
  KEY `cnt_livedate` (`cnt_livedate`),
  KEY `cnt_killdate` (`cnt_killdate`),
  KEY `cnt_module` (`cnt_module`),
  KEY `cnt_type` (`cnt_type`),
  KEY `cnt_group` (`cnt_group`),
  KEY `cnt_owner` (`cnt_owner`),
  KEY `cnt_alias` (`cnt_alias`),
  KEY `cnt_pid` (`cnt_pid`),
  KEY `cnt_sort` (`cnt_sort`),
  KEY `cnt_prio` (`cnt_prio`),
  KEY `cnt_opengraph` (`cnt_opengraph`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_country` (
  `country_id` int(4) NOT NULL AUTO_INCREMENT,
  `country_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `country_iso` char(2) NOT NULL DEFAULT '',
  `country_iso3` char(3) NOT NULL DEFAULT '',
  `country_isonum` int(11) NOT NULL DEFAULT '0',
  `country_continent_code` char(2) NOT NULL DEFAULT '',
  `country_name` varchar(255) NOT NULL DEFAULT '',
  `country_name_de` varchar(255) NOT NULL DEFAULT '',
  `country_continent` varchar(255) NOT NULL DEFAULT '',
  `country_continent_de` varchar(255) NOT NULL DEFAULT '',
  `country_region` varchar(255) NOT NULL DEFAULT '',
  `country_region_de` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`country_id`),
  UNIQUE KEY `country_iso` (`country_iso`),
  UNIQUE KEY `country_name` (`country_name`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_crossreference` (
  `cref_id` int(11) NOT NULL AUTO_INCREMENT,
  `cref_type` varchar(255) NOT NULL DEFAULT '',
  `cref_module` varchar(255) NOT NULL DEFAULT '',
  `cref_rid` int(11) NOT NULL DEFAULT '0',
  `cref_int` int(11) NOT NULL DEFAULT '0',
  `cref_str` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`cref_id`),
  KEY `cref_type` (`cref_type`),
  KEY `cref_rid` (`cref_rid`),
  KEY `cref_int` (`cref_int`),
  KEY `cref_str` (`cref_str`),
  KEY `cref_module` (`cref_module`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_file` (
  `f_id` int(11) NOT NULL AUTO_INCREMENT,
  `f_pid` int(11) NOT NULL DEFAULT '0',
  `f_uid` int(11) NOT NULL DEFAULT '0',
  `f_kid` int(2) NOT NULL DEFAULT '0',
  `f_is_variation` int(11) NOT NULL DEFAULT '0',
  `f_order` int(11) NOT NULL DEFAULT '0',
  `f_trash` int(1) NOT NULL DEFAULT '0',
  `f_aktiv` int(1) NOT NULL DEFAULT '0',
  `f_public` int(1) NOT NULL DEFAULT '0',
  `f_tstamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `f_name` varchar(255) NOT NULL DEFAULT '',
  `f_cat` varchar(255) NOT NULL DEFAULT '',
  `f_created` int(11) NOT NULL DEFAULT '0',
  `f_changed` int(11) NOT NULL DEFAULT '0',
  `f_size` int(15) unsigned NOT NULL DEFAULT '0',
  `f_type` varchar(200) NOT NULL DEFAULT '',
  `f_ext` varchar(50) NOT NULL DEFAULT '',
  `f_svg` int(1) unsigned NOT NULL DEFAULT '0',
  `f_image_width` varchar(20) NOT NULL DEFAULT '',
  `f_image_height` varchar(20) NOT NULL DEFAULT '',
  `f_shortinfo` varchar(1000) NOT NULL DEFAULT '',
  `f_longinfo` text NOT NULL,
  `f_keywords` varchar(1000) NOT NULL DEFAULT '',
  `f_hash` varchar(255) NOT NULL DEFAULT '',
  `f_dlstart` int(11) NOT NULL DEFAULT '0',
  `f_dlfinal` int(11) NOT NULL DEFAULT '0',
  `f_refid` int(11) NOT NULL DEFAULT '0',
  `f_copyright` varchar(1000) NOT NULL DEFAULT '',
  `f_tags` varchar(1000) NOT NULL DEFAULT '',
  `f_granted` int(11) NOT NULL DEFAULT '0',
  `f_gallerystatus` int(1) NOT NULL DEFAULT '0',
  `f_vars` blob NOT NULL,
  `f_sort` int(11) NOT NULL DEFAULT '0',
  `f_title` varchar(1000) NOT NULL DEFAULT '',
  `f_alt` varchar(1000) NOT NULL DEFAULT '',
  PRIMARY KEY (`f_id`),
  KEY `f_granted` (`f_granted`),
  KEY `f_sort` (`f_sort`),
  KEY `f_pid` (`f_pid`),
  KEY `f_is_variation` (`f_is_variation`),
  FULLTEXT KEY `f_name` (`f_name`),
  FULLTEXT KEY `f_shortinfo` (`f_shortinfo`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_filecat` (
  `fcat_id` int(11) NOT NULL AUTO_INCREMENT,
  `fcat_name` varchar(255) NOT NULL DEFAULT '',
  `fcat_aktiv` int(1) NOT NULL DEFAULT '0',
  `fcat_deleted` int(1) NOT NULL DEFAULT '0',
  `fcat_needed` int(1) NOT NULL DEFAULT '0',
  `fcat_sort` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`fcat_id`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_filekey` (
  `fkey_id` int(11) NOT NULL AUTO_INCREMENT,
  `fkey_cid` int(11) NOT NULL DEFAULT '0',
  `fkey_name` varchar(255) NOT NULL DEFAULT '',
  `fkey_aktiv` int(1) NOT NULL DEFAULT '0',
  `fkey_deleted` int(1) NOT NULL DEFAULT '0',
  `fkey_sort` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`fkey_id`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_formresult` (
  `formresult_id` int(11) NOT NULL AUTO_INCREMENT,
  `formresult_pid` int(11) NOT NULL DEFAULT '0',
  `formresult_createdate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `formresult_ip` varchar(50) NOT NULL DEFAULT '',
  `formresult_content` mediumblob NOT NULL,
  PRIMARY KEY (`formresult_id`),
  KEY `formresult_pid` (`formresult_pid`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_formtracking` (
  `formtracking_id` int(11) NOT NULL AUTO_INCREMENT,
  `formtracking_hash` varchar(50) NOT NULL DEFAULT '',
  `formtracking_ip` varchar(20) NOT NULL DEFAULT '',
  `formtracking_created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `formtracking_sentdate` varchar(20) NOT NULL DEFAULT '',
  `formtracking_sent` int(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`formtracking_id`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_glossary` (
  `glossary_id` int(11) NOT NULL AUTO_INCREMENT,
  `glossary_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `glossary_changed` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `glossary_title` text NOT NULL,
  `glossary_tag` varchar(255) NOT NULL DEFAULT '',
  `glossary_keyword` varchar(255) NOT NULL DEFAULT '',
  `glossary_text` mediumtext NOT NULL,
  `glossary_highlight` int(1) NOT NULL DEFAULT '0',
  `glossary_object` mediumtext NOT NULL,
  `glossary_status` int(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`glossary_id`),
  KEY `glossary_status` (`glossary_status`),
  KEY `glossary_tag` (`glossary_tag`),
  KEY `glossary_keyword` (`glossary_keyword`),
  KEY `glossary_highlight` (`glossary_highlight`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_guestbook` (
  `guestbook_id` int(11) NOT NULL AUTO_INCREMENT,
  `guestbook_cid` int(11) NOT NULL DEFAULT '0',
  `guestbook_msg` text NOT NULL,
  `guestbook_name` text NOT NULL,
  `guestbook_email` text NOT NULL,
  `guestbook_created` int(11) NOT NULL DEFAULT '0',
  `guestbook_trashed` int(1) NOT NULL DEFAULT '0',
  `guestbook_url` text NOT NULL,
  `guestbook_show` int(1) NOT NULL DEFAULT '0',
  `guestbook_ip` varchar(20) NOT NULL DEFAULT '',
  `guestbook_useragent` varchar(255) NOT NULL DEFAULT '',
  `guestbook_image` varchar(255) NOT NULL DEFAULT '',
  `guestbook_imagename` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`guestbook_id`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_keyword` (
  `keyword_id` int(11) NOT NULL AUTO_INCREMENT,
  `keyword_name` varchar(255) NOT NULL DEFAULT '',
  `keyword_created` varchar(14) NOT NULL DEFAULT '',
  `keyword_trash` int(1) NOT NULL DEFAULT '0',
  `keyword_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `keyword_description` text NOT NULL,
  `keyword_link` varchar(255) NOT NULL DEFAULT '',
  `keyword_sort` int(11) NOT NULL DEFAULT '0',
  `keyword_important` int(1) NOT NULL DEFAULT '0',
  `keyword_abbr` varchar(10) NOT NULL DEFAULT '',
  PRIMARY KEY (`keyword_id`),
  KEY `keyword_abbr` (`keyword_abbr`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_language` (
  `lang_id` varchar(255) NOT NULL DEFAULT '',
  `lang_html` int(1) NOT NULL DEFAULT '1',
  `lang_type` int(1) NOT NULL DEFAULT '0',
  `EN` text NOT NULL,
  `DE` text NOT NULL,
  `BG` text NOT NULL,
  `CA` text NOT NULL,
  `CZ` text NOT NULL,
  `DA` text NOT NULL,
  `EE` text NOT NULL,
  `ES` text NOT NULL,
  `FI` text NOT NULL,
  `FR` text NOT NULL,
  `GR` text NOT NULL,
  `HU` text NOT NULL,
  `IT` text NOT NULL,
  `LT` text NOT NULL,
  `NL` text NOT NULL,
  `NO` text NOT NULL,
  `PL` text NOT NULL,
  `PT` text NOT NULL,
  `RO` text NOT NULL,
  `SE` text NOT NULL,
  `SK` text NOT NULL,
  `VN` text NOT NULL,
  PRIMARY KEY (`lang_id`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_log` (
  `log_id` int(11) NOT NULL AUTO_INCREMENT,
  `log_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `log_type` varchar(50) NOT NULL DEFAULT '',
  `log_ip` varchar(30) NOT NULL DEFAULT '',
  `log_user_agent` varchar(255) NOT NULL DEFAULT '',
  `log_user_id` int(11) NOT NULL DEFAULT '0',
  `log_user_name` varchar(255) NOT NULL DEFAULT '',
  `log_referrer_id` int(11) NOT NULL DEFAULT '0',
  `log_referrer_url` text NOT NULL,
  `log_data1` varchar(255) NOT NULL DEFAULT '',
  `log_data2` varchar(255) NOT NULL DEFAULT '',
  `log_data3` varchar(255) NOT NULL DEFAULT '',
  `log_msg` text NOT NULL,
  PRIMARY KEY (`log_id`),
  KEY `log_referrer_id` (`log_referrer_id`),
  KEY `log_type` (`log_type`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_log_seo` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `create_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `domain` varchar(255) NOT NULL DEFAULT '',
  `query` varchar(255) NOT NULL DEFAULT '',
  `pos` int(11) NOT NULL DEFAULT '0',
  `referrer` text NOT NULL,
  `hash` char(32) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `hash` (`hash`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_map` (
  `map_id` int(11) NOT NULL AUTO_INCREMENT,
  `map_cid` int(11) NOT NULL DEFAULT '0',
  `map_x` int(5) NOT NULL DEFAULT '0',
  `map_y` int(5) NOT NULL DEFAULT '0',
  `map_title` text NOT NULL,
  `map_zip` varchar(255) NOT NULL DEFAULT '',
  `map_city` text NOT NULL,
  `map_deleted` int(1) NOT NULL DEFAULT '0',
  `map_entry` text NOT NULL,
  `map_vars` text NOT NULL,
  PRIMARY KEY (`map_id`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_message` (
  `msg_id` int(11) NOT NULL AUTO_INCREMENT,
  `msg_pid` int(11) NOT NULL DEFAULT '0',
  `msg_uid` int(11) NOT NULL DEFAULT '0',
  `msg_tstamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `msg_subject` varchar(150) NOT NULL DEFAULT '',
  `msg_text` blob NOT NULL,
  `msg_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `msg_read` tinyint(1) NOT NULL DEFAULT '0',
  `msg_to` blob NOT NULL,
  `msg_from` int(11) NOT NULL DEFAULT '0',
  `msg_from_del` int(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`msg_id`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_newsletter` (
  `newsletter_id` int(11) NOT NULL AUTO_INCREMENT,
  `newsletter_created` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `newsletter_lastsending` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `newsletter_subject` text NOT NULL,
  `newsletter_changed` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `newsletter_vars` mediumblob NOT NULL,
  `newsletter_trashed` int(1) NOT NULL DEFAULT '0',
  `newsletter_active` int(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`newsletter_id`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_newsletterqueue` (
  `queue_id` int(11) NOT NULL AUTO_INCREMENT,
  `queue_created` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `queue_changed` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `queue_status` int(11) NOT NULL DEFAULT '0',
  `queue_pid` int(11) NOT NULL DEFAULT '0',
  `queue_rid` int(11) NOT NULL DEFAULT '0',
  `queue_errormsg` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`queue_id`),
  KEY `nlqueue` (`queue_pid`,`queue_status`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_pagelayout` (
  `pagelayout_id` int(11) NOT NULL AUTO_INCREMENT,
  `pagelayout_name` varchar(255) NOT NULL DEFAULT '',
  `pagelayout_default` int(1) NOT NULL DEFAULT '0',
  `pagelayout_var` mediumblob NOT NULL,
  `pagelayout_trash` int(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`pagelayout_id`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_profession` (
  `prof_id` int(4) NOT NULL AUTO_INCREMENT,
  `prof_name` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`prof_id`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_redirect` (
  `rid` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `changed` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `id` bigint(20) unsigned NOT NULL DEFAULT '0',
  `aid` bigint(20) unsigned NOT NULL DEFAULT '0',
  `alias` varchar(255) NOT NULL DEFAULT '',
  `link` varchar(255) NOT NULL DEFAULT '',
  `views` bigint(20) unsigned NOT NULL DEFAULT '0',
  `active` int(1) unsigned NOT NULL DEFAULT '0',
  `shortcut` int(1) unsigned NOT NULL DEFAULT '0',
  `type` varchar(255) NOT NULL DEFAULT '',
  `code` varchar(255) NOT NULL DEFAULT '',
  `target` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`rid`),
  KEY `id` (`id`,`aid`,`alias`),
  KEY `active` (`active`),
  KEY `link` (`link`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_shop_orders` (
  `order_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `order_number` varchar(20) NOT NULL DEFAULT '',
  `order_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `order_name` varchar(255) NOT NULL DEFAULT '',
  `order_firstname` varchar(255) NOT NULL DEFAULT '',
  `order_email` varchar(255) NOT NULL DEFAULT '',
  `order_net` float NOT NULL DEFAULT '0',
  `order_gross` float NOT NULL DEFAULT '0',
  `order_payment` varchar(255) NOT NULL DEFAULT '',
  `order_data` mediumtext NOT NULL,
  `order_status` varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`order_id`),
  KEY `order_number` (`order_number`,`order_status`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_shop_products` (
  `shopprod_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `shopprod_createdate` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `shopprod_changedate` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `shopprod_status` int(1) unsigned NOT NULL DEFAULT '0',
  `shopprod_uid` int(10) unsigned NOT NULL DEFAULT '0',
  `shopprod_ordernumber` varchar(255) NOT NULL DEFAULT '',
  `shopprod_model` varchar(255) NOT NULL DEFAULT '',
  `shopprod_name1` varchar(255) NOT NULL DEFAULT '',
  `shopprod_name2` varchar(255) NOT NULL DEFAULT '',
  `shopprod_tag` varchar(255) NOT NULL DEFAULT '',
  `shopprod_vat` float unsigned NOT NULL DEFAULT '0',
  `shopprod_netgross` int(1) unsigned NOT NULL DEFAULT '0',
  `shopprod_price` float NOT NULL DEFAULT '0',
  `shopprod_maxrebate` float NOT NULL DEFAULT '0',
  `shopprod_description0` text NOT NULL,
  `shopprod_description1` text NOT NULL,
  `shopprod_description2` text NOT NULL,
  `shopprod_description3` text NOT NULL,
  `shopprod_var` mediumtext NOT NULL,
  `shopprod_category` varchar(255) NOT NULL DEFAULT '',
  `shopprod_weight` float NOT NULL DEFAULT '0',
  `shopprod_color` varchar(255) NOT NULL DEFAULT '',
  `shopprod_size` varchar(255) NOT NULL DEFAULT '',
  `shopprod_listall` int(1) unsigned DEFAULT '0',
  `shopprod_special_price` text NOT NULL,
  `shopprod_track_view` int(11) NOT NULL DEFAULT '0',
  `shopprod_lang` varchar(255) NOT NULL DEFAULT '',
  `shopprod_overwrite_meta` int(1) NOT NULL DEFAULT '1',
  `shopprod_opengraph` int(1) unsigned NOT NULL DEFAULT '1',
  `shopprod_unit` varchar(100) NOT NULL DEFAULT '',
  `shopprod_inventory` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`shopprod_id`),
  KEY `shopprod_status` (`shopprod_status`),
  KEY `category` (`shopprod_category`),
  KEY `tag` (`shopprod_tag`),
  KEY `all` (`shopprod_listall`),
  KEY `shopprod_track_view` (`shopprod_track_view`),
  KEY `shopprod_lang` (`shopprod_lang`),
  KEY `shopprod_opengraph` (`shopprod_opengraph`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_subscription` (
  `subscription_id` int(11) NOT NULL AUTO_INCREMENT,
  `subscription_name` text NOT NULL,
  `subscription_info` blob NOT NULL,
  `subscription_active` int(1) NOT NULL DEFAULT '0',
  `subscription_lang` varchar(100) NOT NULL DEFAULT '',
  `subscription_tstamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`subscription_id`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_sysvalue` (
  `sysvalue_key` varchar(255) NOT NULL DEFAULT '',
  `sysvalue_group` varchar(255) NOT NULL DEFAULT '',
  `sysvalue_lastchange` int(11) NOT NULL DEFAULT '0',
  `sysvalue_status` int(1) NOT NULL DEFAULT '0',
  `sysvalue_vartype` varchar(255) NOT NULL DEFAULT '',
  `sysvalue_value` mediumtext NOT NULL,
  PRIMARY KEY (`sysvalue_key`),
  KEY `sysvalue_group` (`sysvalue_group`),
  KEY `sysvalue_status` (`sysvalue_status`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_template` (
  `template_id` int(11) NOT NULL AUTO_INCREMENT,
  `template_type` int(11) NOT NULL DEFAULT '1',
  `template_name` varchar(255) NOT NULL DEFAULT '',
  `template_default` int(1) NOT NULL DEFAULT '0',
  `template_var` mediumblob NOT NULL,
  `template_trash` int(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`template_id`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_user` (
  `usr_id` int(11) NOT NULL AUTO_INCREMENT,
  `usr_login` varchar(30) NOT NULL DEFAULT '',
  `usr_pass` varchar(255) NOT NULL DEFAULT '',
  `usr_email` varchar(150) NOT NULL DEFAULT '',
  `usr_tstamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `usr_rechte` tinyint(4) NOT NULL DEFAULT '0',
  `usr_admin` tinyint(1) NOT NULL DEFAULT '0',
  `usr_avatar` varchar(50) NOT NULL DEFAULT '',
  `usr_aktiv` int(1) NOT NULL DEFAULT '0',
  `usr_name` varchar(100) NOT NULL DEFAULT '',
  `usr_var_structure` blob NOT NULL,
  `usr_var_publicfile` blob NOT NULL,
  `usr_var_privatefile` blob NOT NULL,
  `usr_lang` varchar(50) NOT NULL DEFAULT '',
  `usr_wysiwyg` int(2) NOT NULL DEFAULT '0',
  `usr_fe` int(1) NOT NULL DEFAULT '0',
  `usr_vars` mediumtext NOT NULL,
  PRIMARY KEY (`usr_id`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_userdetail` (
  `detail_id` int(11) NOT NULL AUTO_INCREMENT,
  `detail_regkey` varchar(255) NOT NULL DEFAULT '',
  `detail_pid` int(11) NOT NULL DEFAULT '0',
  `detail_formid` int(11) NOT NULL DEFAULT '0',
  `detail_tstamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `detail_title` varchar(255) NOT NULL DEFAULT '',
  `detail_salutation` varchar(255) NOT NULL DEFAULT '',
  `detail_firstname` varchar(255) NOT NULL DEFAULT '',
  `detail_lastname` varchar(255) NOT NULL DEFAULT '',
  `detail_company` varchar(255) NOT NULL DEFAULT '',
  `detail_street` varchar(255) NOT NULL DEFAULT '',
  `detail_add` varchar(255) NOT NULL DEFAULT '',
  `detail_city` varchar(255) NOT NULL DEFAULT '',
  `detail_zip` varchar(255) NOT NULL DEFAULT '',
  `detail_region` varchar(255) NOT NULL DEFAULT '',
  `detail_country` varchar(255) NOT NULL DEFAULT '',
  `detail_fon` varchar(255) NOT NULL DEFAULT '',
  `detail_fax` varchar(255) NOT NULL DEFAULT '',
  `detail_mobile` varchar(255) NOT NULL DEFAULT '',
  `detail_signature` varchar(255) NOT NULL DEFAULT '',
  `detail_prof` varchar(255) NOT NULL DEFAULT '',
  `detail_notes` blob NOT NULL,
  `detail_public` int(1) NOT NULL DEFAULT '1',
  `detail_aktiv` int(1) NOT NULL DEFAULT '1',
  `detail_newsletter` int(11) NOT NULL DEFAULT '0',
  `detail_website` varchar(255) NOT NULL DEFAULT '',
  `detail_userimage` varchar(255) NOT NULL DEFAULT '',
  `detail_gender` varchar(255) NOT NULL DEFAULT '',
  `detail_birthday` date NOT NULL DEFAULT '0000-00-00',
  `detail_varchar1` varchar(255) NOT NULL DEFAULT '',
  `detail_varchar2` varchar(255) NOT NULL DEFAULT '',
  `detail_varchar3` varchar(255) NOT NULL DEFAULT '',
  `detail_varchar4` varchar(255) NOT NULL DEFAULT '',
  `detail_varchar5` varchar(255) NOT NULL DEFAULT '',
  `detail_text1` text NOT NULL,
  `detail_text2` text NOT NULL,
  `detail_text3` text NOT NULL,
  `detail_text4` text NOT NULL,
  `detail_text5` text NOT NULL,
  `detail_email` varchar(255) NOT NULL DEFAULT '',
  `detail_login` varchar(255) NOT NULL DEFAULT '',
  `detail_password` varchar(255) NOT NULL DEFAULT '',
  `userdetail_lastlogin` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `detail_int1` bigint(20) NOT NULL DEFAULT '0',
  `detail_int2` bigint(20) NOT NULL DEFAULT '0',
  `detail_int3` bigint(20) NOT NULL DEFAULT '0',
  `detail_int4` bigint(20) NOT NULL DEFAULT '0',
  `detail_int5` bigint(20) NOT NULL DEFAULT '0',
  `detail_float1` double NOT NULL DEFAULT '0',
  `detail_float2` double NOT NULL DEFAULT '0',
  `detail_float3` double NOT NULL DEFAULT '0',
  `detail_float4` double NOT NULL DEFAULT '0',
  `detail_float5` double NOT NULL DEFAULT '0',
  PRIMARY KEY (`detail_id`),
  KEY `detail_pid` (`detail_pid`),
  KEY `detail_formid` (`detail_formid`),
  KEY `detail_password` (`detail_password`),
  KEY `detail_aktiv` (`detail_aktiv`),
  KEY `detail_regkey` (`detail_regkey`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_usergroup` (
  `group_id` int(11) NOT NULL AUTO_INCREMENT,
  `group_name` varchar(200) NOT NULL DEFAULT '',
  `group_member` mediumtext NOT NULL,
  `group_value` longblob NOT NULL,
  `group_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `group_trash` int(1) NOT NULL DEFAULT '0',
  `group_active` int(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`group_id`),
  KEY `group_member` (`group_member`(255))
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE `phpwcms_userlog` (
  `userlog_id` int(11) NOT NULL AUTO_INCREMENT,
  `logged_user` varchar(30) NOT NULL DEFAULT '',
  `logged_username` varchar(100) NOT NULL DEFAULT '',
  `logged_start` int(11) unsigned NOT NULL DEFAULT '0',
  `logged_change` int(11) unsigned NOT NULL DEFAULT '0',
  `logged_in` int(1) NOT NULL DEFAULT '0',
  `logged_ip` varchar(24) NOT NULL DEFAULT '',
  `logged_section` int(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`userlog_id`)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

INSERT INTO `phpwcms_ads_formats` (`adformat_id`, `adformat_created`, `adformat_changed`, `adformat_status`, `adformat_title`, `adformat_width`, `adformat_height`, `adformat_comment`) VALUES(1, '2007-03-19 22:30:42', '2007-03-19 22:30:42', 1, 'Leaderboard', 728, 90, '');

INSERT INTO `phpwcms_ads_formats` (`adformat_id`, `adformat_created`, `adformat_changed`, `adformat_status`, `adformat_title`, `adformat_width`, `adformat_height`, `adformat_comment`) VALUES(2, '2007-03-19 22:30:42', '2007-03-19 22:30:42', 1, 'Banner', 468, 60, '');

INSERT INTO `phpwcms_ads_formats` (`adformat_id`, `adformat_created`, `adformat_changed`, `adformat_status`, `adformat_title`, `adformat_width`, `adformat_height`, `adformat_comment`) VALUES(3, '2007-03-19 22:30:42', '2007-03-19 22:30:42', 1, 'Small Square', 200, 200, '');

INSERT INTO `phpwcms_ads_formats` (`adformat_id`, `adformat_created`, `adformat_changed`, `adformat_status`, `adformat_title`, `adformat_width`, `adformat_height`, `adformat_comment`) VALUES(4, '2007-03-19 22:30:42', '2007-03-19 22:30:42', 1, 'Square', 250, 250, '');

INSERT INTO `phpwcms_ads_formats` (`adformat_id`, `adformat_created`, `adformat_changed`, `adformat_status`, `adformat_title`, `adformat_width`, `adformat_height`, `adformat_comment`) VALUES(5, '2007-03-19 22:30:42', '2007-03-19 22:30:42', 1, 'Medium Rectangle', 300, 250, '');

INSERT INTO `phpwcms_ads_formats` (`adformat_id`, `adformat_created`, `adformat_changed`, `adformat_status`, `adformat_title`, `adformat_width`, `adformat_height`, `adformat_comment`) VALUES(6, '2007-03-19 22:30:42', '2007-03-19 22:30:42', 1, 'Large Rectangle', 336, 280, '');

INSERT INTO `phpwcms_ads_formats` (`adformat_id`, `adformat_created`, `adformat_changed`, `adformat_status`, `adformat_title`, `adformat_width`, `adformat_height`, `adformat_comment`) VALUES(7, '2007-03-19 22:30:42', '2007-03-19 22:30:42', 1, 'Skyscraper', 120, 600, '');

INSERT INTO `phpwcms_ads_formats` (`adformat_id`, `adformat_created`, `adformat_changed`, `adformat_status`, `adformat_title`, `adformat_width`, `adformat_height`, `adformat_comment`) VALUES(8, '2007-03-19 22:30:42', '2007-03-19 22:30:42', 1, 'Wide Skyscraper', 160, 600, '');

INSERT INTO `phpwcms_ads_formats` (`adformat_id`, `adformat_created`, `adformat_changed`, `adformat_status`, `adformat_title`, `adformat_width`, `adformat_height`, `adformat_comment`) VALUES(10, '2007-03-19 22:30:42', '2007-03-19 22:30:42', 1, 'Half Banner', 234, 60, '');

INSERT INTO `phpwcms_ads_formats` (`adformat_id`, `adformat_created`, `adformat_changed`, `adformat_status`, `adformat_title`, `adformat_width`, `adformat_height`, `adformat_comment`) VALUES(11, '2007-03-19 22:30:42', '2007-03-19 22:30:42', 1, 'Square Button', 125, 125, '');

INSERT INTO `phpwcms_ads_formats` (`adformat_id`, `adformat_created`, `adformat_changed`, `adformat_status`, `adformat_title`, `adformat_width`, `adformat_height`, `adformat_comment`) VALUES(12, '2007-03-19 22:30:42', '2007-03-19 22:30:42', 1, 'Small Rectangle', 180, 150, '');

INSERT INTO `phpwcms_ads_formats` (`adformat_id`, `adformat_created`, `adformat_changed`, `adformat_status`, `adformat_title`, `adformat_width`, `adformat_height`, `adformat_comment`) VALUES(13, '2007-03-19 22:30:42', '2007-03-19 22:30:42', 1, 'Vertical Banner', 120, 240, '');

INSERT INTO `phpwcms_ads_formats` (`adformat_id`, `adformat_created`, `adformat_changed`, `adformat_status`, `adformat_title`, `adformat_width`, `adformat_height`, `adformat_comment`) VALUES(14, '2007-03-19 22:30:42', '2007-03-19 22:30:42', 1, 'Mini Square', 120, 120, '');

INSERT INTO `phpwcms_ads_formats` (`adformat_id`, `adformat_created`, `adformat_changed`, `adformat_status`, `adformat_title`, `adformat_width`, `adformat_height`, `adformat_comment`) VALUES(15, '2007-03-19 22:30:42', '2007-03-19 22:30:42', 1, 'Medium Scyscraper', 120, 450, '');

INSERT INTO `phpwcms_ads_formats` (`adformat_id`, `adformat_created`, `adformat_changed`, `adformat_status`, `adformat_title`, `adformat_width`, `adformat_height`, `adformat_comment`) VALUES(16, '2007-03-19 22:30:42', '2007-03-19 22:30:42', 1, 'Micro Bar', 88, 31, '');

INSERT INTO `phpwcms_ads_formats` (`adformat_id`, `adformat_created`, `adformat_changed`, `adformat_status`, `adformat_title`, `adformat_width`, `adformat_height`, `adformat_comment`) VALUES(17, '2007-03-19 22:30:42', '2007-03-19 22:30:42', 1, 'Vertical Rectangle', 240, 400, '');

INSERT INTO `phpwcms_ads_formats` (`adformat_id`, `adformat_created`, `adformat_changed`, `adformat_status`, `adformat_title`, `adformat_width`, `adformat_height`, `adformat_comment`) VALUES(18, '2007-03-19 22:30:42', '2007-03-19 22:30:42', 1, 'Vertical Button', 120, 90, '');

INSERT INTO `phpwcms_ads_formats` (`adformat_id`, `adformat_created`, `adformat_changed`, `adformat_status`, `adformat_title`, `adformat_width`, `adformat_height`, `adformat_comment`) VALUES(19, '2007-03-19 22:30:42', '2007-03-19 22:30:42', 1, 'Half Mini Square', 120, 60, '');

INSERT INTO `phpwcms_ads_formats` (`adformat_id`, `adformat_created`, `adformat_changed`, `adformat_status`, `adformat_title`, `adformat_width`, `adformat_height`, `adformat_comment`) VALUES(20, '2007-03-19 22:30:42', '2007-03-19 22:30:42', 1, 'Half Page Ad', 300, 600, '');

INSERT INTO `phpwcms_ads_formats` (`adformat_id`, `adformat_created`, `adformat_changed`, `adformat_status`, `adformat_title`, `adformat_width`, `adformat_height`, `adformat_comment`) VALUES(21, '2007-03-19 22:30:42', '2007-03-19 22:30:42', 1, 'Universal Flash Layer', 400, 400, '');

INSERT INTO `phpwcms_ads_formats` (`adformat_id`, `adformat_created`, `adformat_changed`, `adformat_status`, `adformat_title`, `adformat_width`, `adformat_height`, `adformat_comment`) VALUES(22, '2007-03-19 22:30:42', '2007-03-19 22:30:42', 1, 'PopUp', 250, 300, '');

INSERT INTO `phpwcms_ads_formats` (`adformat_id`, `adformat_created`, `adformat_changed`, `adformat_status`, `adformat_title`, `adformat_width`, `adformat_height`, `adformat_comment`) VALUES(23, '2007-03-19 22:30:42', '2007-03-19 22:30:42', 1, 'Target Button', 120, 150, '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(1, '0000-00-00 00:00:00', 'AF', 'AFG', 4, 'AS', 'Afghanistan, Islamic Republic of', 'Afghanistan', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(2, '0000-00-00 00:00:00', 'AL', 'ALB', 8, 'EU', 'Albania, Republic of', 'Albanien', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(3, '0000-00-00 00:00:00', 'DZ', 'DZA', 12, 'AF', 'Algeria, People''s Democratic Republic of', 'Algerien', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(4, '0000-00-00 00:00:00', 'AS', 'ASM', 16, 'OC', 'American Samoa', 'Amerikanisch Samoa', 'Oceania', 'Ozeanien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(5, '0000-00-00 00:00:00', 'AD', 'AND', 20, 'EU', 'Andorra, Principality of', 'Andorra', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(6, '0000-00-00 00:00:00', 'AO', 'AGO', 24, 'AF', 'Angola, Republic of', 'Angola', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(7, '0000-00-00 00:00:00', 'AI', 'AIA', 660, 'NA', 'Anguilla', 'Anguilla', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(8, '0000-00-00 00:00:00', 'AQ', 'ATA', 10, 'AN', 'Antarctica (the territory South of 60 deg S)', 'Antarktis', 'Antarctica', 'Antarktis', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(9, '0000-00-00 00:00:00', 'AG', 'ATG', 28, 'NA', 'Antigua and Barbuda', 'Antigua und Barbuda', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(10, '0000-00-00 00:00:00', 'AR', 'ARG', 32, 'SA', 'Argentina, Argentine Republic', 'Argentinien', 'South America', 'Südamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(11, '0000-00-00 00:00:00', 'AM', 'ARM', 51, 'AS', 'Armenia, Republic of', 'Armenien', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(12, '0000-00-00 00:00:00', 'AW', 'ABW', 533, 'NA', 'Aruba', 'Aruba', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(13, '0000-00-00 00:00:00', 'AU', 'AUS', 36, 'OC', 'Australia, Commonwealth of', 'Australien', 'Oceania', 'Ozeanien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(14, '0000-00-00 00:00:00', 'AT', 'AUT', 40, 'EU', 'Austria, Republic of', 'Österreich', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(15, '0000-00-00 00:00:00', 'AZ', 'AZE', 31, 'AS', 'Azerbaijan, Republic of', 'Aserbaidschan', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(16, '0000-00-00 00:00:00', 'BS', 'BHS', 44, 'NA', 'Bahamas, Commonwealth of the', 'Bahamas', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(17, '0000-00-00 00:00:00', 'BH', 'BHR', 48, 'AS', 'Bahrain, Kingdom of', 'Bahrain', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(18, '0000-00-00 00:00:00', 'BD', 'BGD', 50, 'AS', 'Bangladesh, People''s Republic of', 'Bangladesch', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(19, '0000-00-00 00:00:00', 'BB', 'BRB', 52, 'NA', 'Barbados', 'Barbados', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(20, '0000-00-00 00:00:00', 'BY', 'BLR', 112, 'EU', 'Belarus, Republic of', 'Belarus', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(21, '0000-00-00 00:00:00', 'BE', 'BEL', 56, 'EU', 'Belgium, Kingdom of', 'Belgien', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(22, '0000-00-00 00:00:00', 'BZ', 'BLZ', 84, 'NA', 'Belize', 'Belize', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(23, '0000-00-00 00:00:00', 'BJ', 'BEN', 204, 'AF', 'Benin, Republic of', 'Benin', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(24, '0000-00-00 00:00:00', 'BM', 'BMU', 60, 'NA', 'Bermuda', 'Bermuda', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(25, '0000-00-00 00:00:00', 'BT', 'BTN', 64, 'AS', 'Bhutan, Kingdom of', 'Bhutan', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(26, '0000-00-00 00:00:00', 'BO', 'BOL', 68, 'SA', 'Bolivia, Republic of', 'Bolivien', 'South America', 'Südamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(27, '0000-00-00 00:00:00', 'BA', 'BIH', 70, 'EU', 'Bosnia and Herzegovina', 'Bosnien und Herzegowina', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(28, '0000-00-00 00:00:00', 'BW', 'BWA', 72, 'AF', 'Botswana, Republic of', 'Botsuana', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(29, '0000-00-00 00:00:00', 'BV', 'BVT', 74, 'AN', 'Bouvet Island (Bouvetoya)', 'Bouvet-Insel', 'Antarctica', 'Antarktis', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(30, '0000-00-00 00:00:00', 'BR', 'BRA', 76, 'SA', 'Brazil, Federative Republic of', 'Brasilien', 'South America', 'Südamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(31, '0000-00-00 00:00:00', 'IO', 'IOT', 86, 'AS', 'British Indian Ocean Territory (Chagos Archipelago)', 'Britisches Territorium Im Indischen Ozean', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(32, '0000-00-00 00:00:00', 'BN', 'BRN', 96, 'AS', 'Brunei Darussalam', 'Brunei Darussalam', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(33, '0000-00-00 00:00:00', 'BG', 'BGR', 100, 'EU', 'Bulgaria, Republic of', 'Bulgarien', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(34, '0000-00-00 00:00:00', 'BF', 'BFA', 854, 'AF', 'Burkina Faso', 'Burkina Faso', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(35, '0000-00-00 00:00:00', 'BI', 'BDI', 108, 'AF', 'Burundi, Republic of', 'Burundi', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(36, '0000-00-00 00:00:00', 'KH', 'KHM', 116, 'AS', 'Cambodia, Kingdom of', 'Kambodscha', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(37, '0000-00-00 00:00:00', 'CM', 'CMR', 120, 'AF', 'Cameroon, Republic of', 'Kamerun', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(38, '0000-00-00 00:00:00', 'CA', 'CAN', 124, 'NA', 'Canada', 'Kanada', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(39, '0000-00-00 00:00:00', 'CV', 'CPV', 132, 'AF', 'Cape Verde, Republic of', 'Kap Verde', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(40, '0000-00-00 00:00:00', 'KY', 'CYM', 136, 'NA', 'Cayman Islands', 'Kaimaninseln', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(41, '0000-00-00 00:00:00', 'CF', 'CAF', 140, 'AF', 'Central African Republic', 'Zentralafrikanische Republik', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(42, '0000-00-00 00:00:00', 'TD', 'TCD', 148, 'AF', 'Chad, Republic of', 'Tschad', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(43, '0000-00-00 00:00:00', 'CL', 'CHL', 152, 'SA', 'Chile, Republic of', 'Chile', 'South America', 'Südamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(44, '0000-00-00 00:00:00', 'CN', 'CHN', 156, 'AS', 'China, People''s Republic of', 'China', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(45, '0000-00-00 00:00:00', 'CX', 'CXR', 162, 'AS', 'Christmas Island', 'Weihnachtsinsel', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(46, '0000-00-00 00:00:00', 'CC', 'CCK', 166, 'AS', 'Cocos (Keeling) Islands', 'Kokosinseln (Keelingsinseln)', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(47, '0000-00-00 00:00:00', 'CO', 'COL', 170, 'SA', 'Colombia, Republic of', 'Kolumbien', 'South America', 'Südamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(48, '0000-00-00 00:00:00', 'KM', 'COM', 174, 'AF', 'Comoros, Union of the', 'Komoren', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(49, '0000-00-00 00:00:00', 'CG', 'COG', 178, 'AF', 'Congo, Republic of the', 'Kongo', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(50, '0000-00-00 00:00:00', 'CD', 'COD', 180, 'AF', 'Congo, Democratic Republic of the', 'Kongo, Demokratische Republik', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(51, '0000-00-00 00:00:00', 'CK', 'COK', 184, 'OC', 'Cook Islands', 'Cook-Inseln', 'Oceania', 'Ozeanien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(52, '0000-00-00 00:00:00', 'CR', 'CRI', 188, 'NA', 'Costa Rica, Republic of', 'Costa Rica', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(53, '0000-00-00 00:00:00', 'CI', 'CIV', 384, 'AF', 'Cote d''Ivoire, Republic of', 'Côte D''Ivoire', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(54, '0000-00-00 00:00:00', 'HR', 'HRV', 191, 'EU', 'Croatia, Republic of', 'Kroatien', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(55, '0000-00-00 00:00:00', 'CU', 'CUB', 192, 'NA', 'Cuba, Republic of', 'Kuba', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(56, '0000-00-00 00:00:00', 'CY', 'CYP', 196, 'AS', 'Cyprus, Republic of', 'Zypern', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(57, '0000-00-00 00:00:00', 'CZ', 'CZE', 203, 'EU', 'Czech Republic', 'Tschechische Republik', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(58, '0000-00-00 00:00:00', 'DK', 'DNK', 208, 'EU', 'Denmark, Kingdom of', 'Dänemark', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(59, '0000-00-00 00:00:00', 'DJ', 'DJI', 262, 'AF', 'Djibouti, Republic of', 'Dschibuti', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(60, '0000-00-00 00:00:00', 'DM', 'DMA', 212, 'NA', 'Dominica, Commonwealth of', 'Dominica', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(61, '0000-00-00 00:00:00', 'DO', 'DOM', 214, 'NA', 'Dominican Republic', 'Dominikanische Republik', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(63, '0000-00-00 00:00:00', 'EC', 'ECU', 218, 'SA', 'Ecuador, Republic of', 'Ecuador', 'South America', 'Südamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(64, '0000-00-00 00:00:00', 'EG', 'EGY', 818, 'AF', 'Egypt, Arab Republic of', 'Ägypten', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(65, '0000-00-00 00:00:00', 'SV', 'SLV', 222, 'NA', 'El Salvador, Republic of', 'El Salvador', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(66, '0000-00-00 00:00:00', 'GQ', 'GNQ', 226, 'AF', 'Equatorial Guinea, Republic of', 'Äquatorialguinea', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(67, '0000-00-00 00:00:00', 'ER', 'ERI', 232, 'AF', 'Eritrea, State of', 'Eritrea', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(68, '0000-00-00 00:00:00', 'EE', 'EST', 233, 'EU', 'Estonia, Republic of', 'Estland', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(69, '0000-00-00 00:00:00', 'ET', 'ETH', 231, 'AF', 'Ethiopia, Federal Democratic Republic of', 'Äthiopien', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(70, '0000-00-00 00:00:00', 'FK', 'FLK', 238, 'SA', 'Falkland Islands (Malvinas)', 'Falkland-Inseln (Malvinen)', 'South America', 'Südamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(71, '0000-00-00 00:00:00', 'FO', 'FRO', 234, 'EU', 'Faroe Islands', 'Färöer', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(72, '0000-00-00 00:00:00', 'FJ', 'FJI', 242, 'OC', 'Fiji, Republic of the Fiji Islands', 'Fidschi', 'Oceania', 'Ozeanien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(73, '0000-00-00 00:00:00', 'FI', 'FIN', 246, 'EU', 'Finland, Republic of', 'Finnland', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(74, '0000-00-00 00:00:00', 'FR', 'FRA', 250, 'EU', 'France, French Republic', 'Frankreich', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(75, '0000-00-00 00:00:00', 'GF', 'GUF', 254, 'SA', 'French Guiana', 'Französisch Guayana', 'South America', 'Südamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(76, '0000-00-00 00:00:00', 'PF', 'PYF', 258, 'OC', 'French Polynesia', 'Französisch Polynesien', 'Oceania', 'Ozeanien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(77, '0000-00-00 00:00:00', 'TF', 'ATF', 260, 'AN', 'French Southern Territories', 'Französische Südgebiete', 'Antarctica', 'Antarktis', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(78, '0000-00-00 00:00:00', 'GA', 'GAB', 266, 'AF', 'Gabon, Gabonese Republic', 'Gabun', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(79, '0000-00-00 00:00:00', 'GM', 'GMB', 270, 'AF', 'Gambia, Republic of the', 'Gambia', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(80, '0000-00-00 00:00:00', 'GE', 'GEO', 268, 'AS', 'Georgia', 'Georgien', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(81, '0000-00-00 00:00:00', 'DE', 'DEU', 276, 'EU', 'Germany, Federal Republic of', 'Deutschland', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(82, '0000-00-00 00:00:00', 'GH', 'GHA', 288, 'AF', 'Ghana, Republic of', 'Ghana', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(83, '0000-00-00 00:00:00', 'GI', 'GIB', 292, 'EU', 'Gibraltar', 'Gibraltar', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(84, '0000-00-00 00:00:00', 'GR', 'GRC', 300, 'EU', 'Greece, Hellenic Republic', 'Griechenland', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(85, '0000-00-00 00:00:00', 'GL', 'GRL', 304, 'NA', 'Greenland', 'Grönland', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(86, '0000-00-00 00:00:00', 'GD', 'GRD', 308, 'NA', 'Grenada', 'Grenada', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(87, '0000-00-00 00:00:00', 'GP', 'GLP', 312, 'NA', 'Guadeloupe', 'Guadeloupe', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(88, '0000-00-00 00:00:00', 'GU', 'GUM', 316, 'OC', 'Guam', 'Guam', 'Oceania', 'Ozeanien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(89, '0000-00-00 00:00:00', 'GT', 'GTM', 320, 'NA', 'Guatemala, Republic of', 'Guatemala', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(90, '0000-00-00 00:00:00', 'GN', 'GIN', 324, 'AF', 'Guinea, Republic of', 'Guinea', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(91, '0000-00-00 00:00:00', 'GW', 'GNB', 624, 'AF', 'Guinea-Bissau, Republic of', 'Guinea-Bissau', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(92, '0000-00-00 00:00:00', 'GY', 'GUY', 328, 'SA', 'Guyana, Co-operative Republic of', 'Guyana', 'South America', 'Südamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(93, '0000-00-00 00:00:00', 'HT', 'HTI', 332, 'NA', 'Haiti, Republic of', 'Haiti', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(94, '0000-00-00 00:00:00', 'HM', 'HMD', 334, 'AN', 'Heard Island and McDonald Islands', 'Heard und McDonald', 'Antarctica', 'Antarktis', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(95, '0000-00-00 00:00:00', 'VA', 'VAT', 336, 'EU', 'Holy See (Vatican City State)', 'Vatikanstadt, Staat (Heiliger Stuhl)', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(96, '0000-00-00 00:00:00', 'HN', 'HND', 340, 'NA', 'Honduras, Republic of', 'Honduras', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(97, '0000-00-00 00:00:00', 'HK', 'HKG', 344, 'AS', 'Hong Kong, Special Administrative Region of China', 'Hongkong', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(98, '0000-00-00 00:00:00', 'HU', 'HUN', 348, 'EU', 'Hungary, Republic of', 'Ungarn', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(99, '0000-00-00 00:00:00', 'IS', 'ISL', 352, 'EU', 'Iceland, Republic of', 'Island', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(100, '0000-00-00 00:00:00', 'IN', 'IND', 356, 'AS', 'India, Republic of', 'Indien', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(101, '0000-00-00 00:00:00', 'ID', 'IDN', 360, 'AS', 'Indonesia, Republic of', 'Indonesien', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(102, '0000-00-00 00:00:00', 'IR', 'IRN', 364, 'AS', 'Iran, Islamic Republic of', 'Iran (Islamische Republik)', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(103, '0000-00-00 00:00:00', 'IQ', 'IRQ', 368, 'AS', 'Iraq, Republic of', 'Irak', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(104, '0000-00-00 00:00:00', 'IE', 'IRL', 372, 'EU', 'Ireland', 'Irland', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(105, '0000-00-00 00:00:00', 'IL', 'ISR', 376, 'AS', 'Israel, State of', 'Israel', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(106, '0000-00-00 00:00:00', 'IT', 'ITA', 380, 'EU', 'Italy, Italian Republic', 'Italien', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(107, '0000-00-00 00:00:00', 'JM', 'JAM', 388, 'NA', 'Jamaica', 'Jamaika', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(108, '0000-00-00 00:00:00', 'JP', 'JPN', 392, 'AS', 'Japan', 'Japan', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(109, '0000-00-00 00:00:00', 'JO', 'JOR', 400, 'AS', 'Jordan, Hashemite Kingdom of', 'Jordanien', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(110, '0000-00-00 00:00:00', 'KZ', 'KAZ', 398, 'AS', 'Kazakhstan, Republic of', 'Kasachstan', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(111, '0000-00-00 00:00:00', 'KE', 'KEN', 404, 'AF', 'Kenya, Republic of', 'Kenia', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(112, '0000-00-00 00:00:00', 'KI', 'KIR', 296, 'OC', 'Kiribati, Republic of', 'Kiribati', 'Oceania', 'Ozeanien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(113, '0000-00-00 00:00:00', 'KP', 'PRK', 408, 'AS', 'Korea, Democratic People''s Republic of', 'Korea, Demokratische Volksrepublik', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(114, '0000-00-00 00:00:00', 'KR', 'KOR', 410, 'AS', 'Korea, Republic of', 'Korea, Republik', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(115, '0000-00-00 00:00:00', 'KW', 'KWT', 414, 'AS', 'Kuwait, State of', 'Kuwait', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(116, '0000-00-00 00:00:00', 'KG', 'KGZ', 417, 'AS', 'Kyrgyz Republic', 'Kirgisistan', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(117, '0000-00-00 00:00:00', 'LA', 'LAO', 418, 'AS', 'Lao People''s Democratic Republic', 'Laos, Demokratische Volksrepublik', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(118, '0000-00-00 00:00:00', 'LV', 'LVA', 428, 'EU', 'Latvia, Republic of', 'Lettland', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(119, '0000-00-00 00:00:00', 'LB', 'LBN', 422, 'AS', 'Lebanon, Lebanese Republic', 'Libanon', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(120, '0000-00-00 00:00:00', 'LS', 'LSO', 426, 'AF', 'Lesotho, Kingdom of', 'Lesotho', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(121, '0000-00-00 00:00:00', 'LR', 'LBR', 430, 'AF', 'Liberia, Republic of', 'Liberia', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(122, '0000-00-00 00:00:00', 'LY', 'LBY', 434, 'AF', 'Libyan Arab Jamahiriya', 'Libysch-Arabische Dschamahirija', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(123, '0000-00-00 00:00:00', 'LI', 'LIE', 438, 'EU', 'Liechtenstein, Principality of', 'Liechtenstein', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(124, '0000-00-00 00:00:00', 'LT', 'LTU', 440, 'EU', 'Lithuania, Republic of', 'Litauen', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(125, '0000-00-00 00:00:00', 'LU', 'LUX', 442, 'EU', 'Luxembourg, Grand Duchy of', 'Luxembourg', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(126, '0000-00-00 00:00:00', 'MO', 'MAC', 446, 'AS', 'Macao, Special Administrative Region of China', 'Macau', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(127, '0000-00-00 00:00:00', 'MK', 'MKD', 807, 'EU', 'Macedonia, the former Yugoslav Republic of', 'Mazedonien, Ehemalige Jugoslawische Republik', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(128, '0000-00-00 00:00:00', 'MG', 'MDG', 450, 'AF', 'Madagascar, Republic of', 'Madagaskar', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(129, '0000-00-00 00:00:00', 'MW', 'MWI', 454, 'AF', 'Malawi, Republic of', 'Malawi', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(130, '0000-00-00 00:00:00', 'MY', 'MYS', 458, 'AS', 'Malaysia', 'Malaysia', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(131, '0000-00-00 00:00:00', 'MV', 'MDV', 462, 'AS', 'Maldives, Republic of', 'Malediven', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(132, '0000-00-00 00:00:00', 'ML', 'MLI', 466, 'AF', 'Mali, Republic of', 'Mali', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(133, '0000-00-00 00:00:00', 'MT', 'MLT', 470, 'EU', 'Malta, Republic of', 'Malta', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(134, '0000-00-00 00:00:00', 'MH', 'MHL', 584, 'OC', 'Marshall Islands, Republic of the', 'Marshallinseln', 'Oceania', 'Ozeanien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(135, '0000-00-00 00:00:00', 'MQ', 'MTQ', 474, 'NA', 'Martinique', 'Martinique', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(136, '0000-00-00 00:00:00', 'MR', 'MRT', 478, 'AF', 'Mauritania, Islamic Republic of', 'Mauretanien', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(137, '0000-00-00 00:00:00', 'MU', 'MUS', 480, 'AF', 'Mauritius, Republic of', 'Mauritius', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(138, '0000-00-00 00:00:00', 'YT', 'MYT', 175, 'AF', 'Mayotte', 'Mayotte', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(139, '0000-00-00 00:00:00', 'MX', 'MEX', 484, 'NA', 'Mexico, United Mexican States', 'Mexiko', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(140, '0000-00-00 00:00:00', 'FM', 'FSM', 583, 'OC', 'Micronesia, Federated States of', 'Mikronesien, Föderierte Staaten Von', 'Oceania', 'Ozeanien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(141, '0000-00-00 00:00:00', 'MD', 'MDA', 498, 'EU', 'Moldova, Republic of', 'Moldau, Republik', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(142, '0000-00-00 00:00:00', 'MC', 'MCO', 492, 'EU', 'Monaco, Principality of', 'Monaco', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(143, '0000-00-00 00:00:00', 'MN', 'MNG', 496, 'AS', 'Mongolia', 'Mongolei', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(144, '0000-00-00 00:00:00', 'MS', 'MSR', 500, 'NA', 'Montserrat', 'Montserrat', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(145, '0000-00-00 00:00:00', 'MA', 'MAR', 504, 'AF', 'Morocco, Kingdom of', 'Marokko', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(146, '0000-00-00 00:00:00', 'MZ', 'MOZ', 508, 'AF', 'Mozambique, Republic of', 'Mosambik', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(147, '0000-00-00 00:00:00', 'MM', 'MMR', 104, 'AS', 'Myanmar, Union of', 'Myanmar', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(148, '0000-00-00 00:00:00', 'NA', 'NAM', 516, 'AF', 'Namibia, Republic of', 'Namibia', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(149, '0000-00-00 00:00:00', 'NR', 'NRU', 520, 'OC', 'Nauru, Republic of', 'Nauru', 'Oceania', 'Ozeanien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(150, '0000-00-00 00:00:00', 'NP', 'NPL', 524, 'AS', 'Nepal, State of', 'Nepal', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(151, '0000-00-00 00:00:00', 'NL', 'NLD', 528, 'EU', 'Netherlands, Kingdom of the', 'Niederlande', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(152, '0000-00-00 00:00:00', 'AN', 'ANT', 530, 'NA', 'Netherlands Antilles', 'Niederländische Antillen', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(153, '0000-00-00 00:00:00', 'NC', 'NCL', 540, 'OC', 'New Caledonia', 'Neukaledonien', 'Oceania', 'Ozeanien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(154, '0000-00-00 00:00:00', 'NZ', 'NZL', 554, 'OC', 'New Zealand', 'Neuseeland', 'Oceania', 'Ozeanien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(155, '0000-00-00 00:00:00', 'NI', 'NIC', 558, 'NA', 'Nicaragua, Republic of', 'Nicaragua', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(156, '0000-00-00 00:00:00', 'NE', 'NER', 562, 'AF', 'Niger, Republic of', 'Niger', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(157, '0000-00-00 00:00:00', 'NG', 'NGA', 566, 'AF', 'Nigeria, Federal Republic of', 'Nigeria', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(158, '0000-00-00 00:00:00', 'NU', 'NIU', 570, 'OC', 'Niue', 'Niue', 'Oceania', 'Ozeanien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(159, '0000-00-00 00:00:00', 'NF', 'NFK', 574, 'OC', 'Norfolk Island', 'Norfolk-Insel', 'Oceania', 'Ozeanien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(160, '0000-00-00 00:00:00', 'MP', 'MNP', 580, 'OC', 'Northern Mariana Islands, Commonwealth of the', 'Nördliche Marianen', 'Oceania', 'Ozeanien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(161, '0000-00-00 00:00:00', 'NO', 'NOR', 578, 'EU', 'Norway, Kingdom of', 'Norwegen', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(162, '0000-00-00 00:00:00', 'OM', 'OMN', 512, 'AS', 'Oman, Sultanate of', 'Oman', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(163, '0000-00-00 00:00:00', 'PK', 'PAK', 586, 'AS', 'Pakistan, Islamic Republic of', 'Pakistan', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(164, '0000-00-00 00:00:00', 'PW', 'PLW', 585, 'OC', 'Palau, Republic of', 'Palau', 'Oceania', 'Ozeanien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(165, '0000-00-00 00:00:00', 'PS', 'PSE', 275, 'AS', 'Palestinian Territory, Occupied', 'Palästina', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(166, '0000-00-00 00:00:00', 'PA', 'PAN', 591, 'NA', 'Panama, Republic of', 'Panama', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(167, '0000-00-00 00:00:00', 'PG', 'PNG', 598, 'OC', 'Papua New Guinea, Independent State of', 'Papua-Neuguinea', 'Oceania', 'Ozeanien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(168, '0000-00-00 00:00:00', 'PY', 'PRY', 600, 'SA', 'Paraguay, Republic of', 'Paraguay', 'South America', 'Südamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(169, '0000-00-00 00:00:00', 'PE', 'PER', 604, 'SA', 'Peru, Republic of', 'Peru', 'South America', 'Südamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(170, '0000-00-00 00:00:00', 'PH', 'PHL', 608, 'AS', 'Philippines, Republic of the', 'Philippinen', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(171, '0000-00-00 00:00:00', 'PN', 'PCN', 612, 'OC', 'Pitcairn Islands', 'Pitcairn', 'Oceania', 'Ozeanien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(172, '0000-00-00 00:00:00', 'PL', 'POL', 616, 'EU', 'Poland, Republic of', 'Polen', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(173, '0000-00-00 00:00:00', 'PT', 'PRT', 620, 'EU', 'Portugal, Portuguese Republic', 'Portugal', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(174, '0000-00-00 00:00:00', 'PR', 'PRI', 630, 'NA', 'Puerto Rico, Commonwealth of', 'Puerto Rico', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(175, '0000-00-00 00:00:00', 'QA', 'QAT', 634, 'AS', 'Qatar, State of', 'Katar', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(176, '0000-00-00 00:00:00', 'RE', 'REU', 638, 'AF', 'Reunion', 'Réunion', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(177, '0000-00-00 00:00:00', 'RO', 'ROU', 642, 'EU', 'Romania', 'Rumänien', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(178, '0000-00-00 00:00:00', 'RU', 'RUS', 643, 'EU', 'Russian Federation', 'Russische Föderation', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(179, '0000-00-00 00:00:00', 'RW', 'RWA', 646, 'AF', 'Rwanda, Republic of', 'Ruanda', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(180, '0000-00-00 00:00:00', 'SH', 'SHN', 654, 'AF', 'Saint Helena', 'St. Helena', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(181, '0000-00-00 00:00:00', 'KN', 'KNA', 659, 'NA', 'Saint Kitts and Nevis, Federation of', 'Saint Kitts und Nevis', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(182, '0000-00-00 00:00:00', 'LC', 'LCA', 662, 'NA', 'Saint Lucia', 'Santa Lucia', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(183, '0000-00-00 00:00:00', 'PM', 'SPM', 666, 'NA', 'Saint Pierre and Miquelon', 'Saint-Pierre und Miquelon', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(184, '0000-00-00 00:00:00', 'VC', 'VCT', 670, 'NA', 'Saint Vincent and the Grenadines', 'Saint Vincent und die Grenadinen', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(185, '0000-00-00 00:00:00', 'WS', 'WSM', 882, 'OC', 'Samoa, Independent State of', 'Samoa', 'Oceania', 'Ozeanien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(186, '0000-00-00 00:00:00', 'SM', 'SMR', 674, 'EU', 'San Marino, Republic of', 'San Marino', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(187, '0000-00-00 00:00:00', 'ST', 'STP', 678, 'AF', 'Sao Tome and Principe, Democratic Republic of', 'São Tomé und Príncipe', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(188, '0000-00-00 00:00:00', 'SA', 'SAU', 682, 'AS', 'Saudi Arabia, Kingdom of', 'Saudi-Arabien', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(189, '0000-00-00 00:00:00', 'SN', 'SEN', 686, 'AF', 'Senegal, Republic of', 'Senegal', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(190, '0000-00-00 00:00:00', 'SC', 'SYC', 690, 'AF', 'Seychelles, Republic of', 'Seychellen', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(191, '0000-00-00 00:00:00', 'SL', 'SLE', 694, 'AF', 'Sierra Leone, Republic of', 'Sierra Leone', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(192, '0000-00-00 00:00:00', 'SG', 'SGP', 702, 'AS', 'Singapore, Republic of', 'Singapur', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(193, '0000-00-00 00:00:00', 'SK', 'SVK', 703, 'EU', 'Slovakia (Slovak Republic)', 'Slowakei (Slowakische Republik)', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(194, '0000-00-00 00:00:00', 'SI', 'SVN', 705, 'EU', 'Slovenia, Republic of', 'Slowenien', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(195, '0000-00-00 00:00:00', 'SB', 'SLB', 90, 'OC', 'Solomon Islands', 'Salomonen', 'Oceania', 'Ozeanien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(196, '0000-00-00 00:00:00', 'SO', 'SOM', 706, 'AF', 'Somalia, Somali Republic', 'Somalia', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(197, '0000-00-00 00:00:00', 'ZA', 'ZAF', 710, 'AF', 'South Africa, Republic of', 'Südafrika', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(198, '0000-00-00 00:00:00', 'GS', 'SGS', 239, 'AN', 'South Georgia and the South Sandwich Islands', 'Südgeorgien und Südliche Sandwichinseln', 'Antarctica', 'Antarktis', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(199, '0000-00-00 00:00:00', 'ES', 'ESP', 724, 'EU', 'Spain, Kingdom of', 'Spanien', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(200, '0000-00-00 00:00:00', 'LK', 'LKA', 144, 'AS', 'Sri Lanka, Democratic Socialist Republic of', 'Sri Lanka', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(201, '0000-00-00 00:00:00', 'SD', 'SDN', 736, 'AF', 'Sudan, Republic of', 'Sudan', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(202, '0000-00-00 00:00:00', 'SR', 'SUR', 740, 'AF', 'Suriname, Republic of', 'Suriname', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(203, '0000-00-00 00:00:00', 'SJ', 'SJM', 744, 'EU', 'Svalbard & Jan Mayen Islands', 'Svalbard und Jan Mayen', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(204, '0000-00-00 00:00:00', 'SZ', 'SWZ', 748, 'AF', 'Swaziland, Kingdom of', 'Swasiland', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(205, '0000-00-00 00:00:00', 'SE', 'SWE', 752, 'EU', 'Sweden, Kingdom of', 'Schweden', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(206, '0000-00-00 00:00:00', 'CH', 'CHE', 756, 'EU', 'Switzerland, Swiss Confederation', 'Schweiz', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(207, '0000-00-00 00:00:00', 'SY', 'SYR', 760, 'AS', 'Syrian Arab Republic', 'Syrien, Arabische Republik', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(208, '0000-00-00 00:00:00', 'TW', 'TWN', 158, 'AS', 'Taiwan', 'Taiwan (China)', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(209, '0000-00-00 00:00:00', 'TJ', 'TJK', 762, 'AS', 'Tajikistan, Republic of', 'Tadschikistan', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(210, '0000-00-00 00:00:00', 'TZ', 'TZA', 834, 'AF', 'Tanzania, United Republic of', 'Tansania, Vereinigte Republik', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(211, '0000-00-00 00:00:00', 'TH', 'THA', 764, 'AS', 'Thailand, Kingdom of', 'Thailand', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(212, '0000-00-00 00:00:00', 'TG', 'TGO', 768, 'AF', 'Togo, Togolese Republic', 'Togo', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(213, '0000-00-00 00:00:00', 'TK', 'TKL', 772, 'OC', 'Tokelau', 'Tokelau', 'Oceania', 'Ozeanien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(214, '0000-00-00 00:00:00', 'TO', 'TON', 776, 'OC', 'Tonga, Kingdom of', 'Tonga', 'Oceania', 'Ozeanien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(215, '0000-00-00 00:00:00', 'TT', 'TTO', 780, 'NA', 'Trinidad and Tobago, Republic of', 'Trinidad und Tobago', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(216, '0000-00-00 00:00:00', 'TN', 'TUN', 788, 'AF', 'Tunisia, Tunisian Republic', 'Tunesien', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(217, '0000-00-00 00:00:00', 'TR', 'TUR', 792, 'AS', 'Turkey, Republic of', 'Türkei', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(218, '0000-00-00 00:00:00', 'TM', 'TKM', 795, 'AS', 'Turkmenistan', 'Turkmenistan', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(219, '0000-00-00 00:00:00', 'TC', 'TCA', 796, 'NA', 'Turks and Caicos Islands', 'Turks- und Caicosinseln', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(220, '0000-00-00 00:00:00', 'TV', 'TUV', 798, 'OC', 'Tuvalu', 'Tuvalu', 'Oceania', 'Ozeanien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(221, '0000-00-00 00:00:00', 'UG', 'UGA', 800, 'AF', 'Uganda, Republic of', 'Uganda', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(222, '0000-00-00 00:00:00', 'UA', 'UKR', 804, 'EU', 'Ukraine', 'Ukraine', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(223, '0000-00-00 00:00:00', 'AE', 'ARE', 784, 'AS', 'United Arab Emirates', 'Vereinigte Arabische Emirate', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(224, '0000-00-00 00:00:00', 'GB', 'GBR', 826, 'EU', 'United Kingdom of Great Britain & Northern Ireland', 'United Kingdom', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(225, '0000-00-00 00:00:00', 'US', 'USA', 840, 'NA', 'United States of America', 'Vereinigte Staaten', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(226, '0000-00-00 00:00:00', 'UM', 'UMI', 581, 'OC', 'United States Minor Outlying Islands', 'Kleinere entlegene Inseln der Vereinigten Staaten', 'Oceania', 'Ozeanien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(227, '0000-00-00 00:00:00', 'UY', 'URY', 858, 'SA', 'Uruguay, Eastern Republic of', 'Uruguay', 'South America', 'Südamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(228, '0000-00-00 00:00:00', 'UZ', 'UZB', 860, 'AS', 'Uzbekistan, Republic of', 'Usbekistan', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(229, '0000-00-00 00:00:00', 'VU', 'VUT', 548, 'OC', 'Vanuatu, Republic of', 'Vanuatu', 'Oceania', 'Ozeanien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(230, '0000-00-00 00:00:00', 'VE', 'VEN', 862, 'SA', 'Venezuela, Bolivarian Republic of', 'Venezuela', 'South America', 'Südamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(231, '0000-00-00 00:00:00', 'VN', 'VNM', 704, 'AS', 'Vietnam, Socialist Republic of', 'Vietnam', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(232, '0000-00-00 00:00:00', 'VG', 'VGB', 92, 'NA', 'British Virgin Islands', 'Jungferninseln (Britische)', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(233, '0000-00-00 00:00:00', 'VI', 'VIR', 850, 'NA', 'United States Virgin Islands', 'Jungferninseln (Amerikanische)', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(234, '0000-00-00 00:00:00', 'WF', 'WLF', 876, 'OC', 'Wallis and Futuna', 'Wallis und Futuna', 'Oceania', 'Ozeanien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(235, '0000-00-00 00:00:00', 'EH', 'ESH', 732, 'AF', 'Western Sahara', 'Westsahara', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(236, '0000-00-00 00:00:00', 'YE', 'YEM', 887, 'AS', 'Yemen', 'Jemen', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(237, '0000-00-00 00:00:00', 'YU', 'YUG', 891, 'EU', 'Yugoslavia', 'Jugoslawien', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(238, '0000-00-00 00:00:00', 'ZM', 'ZMB', 894, 'AF', 'Zambia, Republic of', 'Sambia', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(239, '0000-00-00 00:00:00', 'ZW', 'ZWE', 716, 'AF', 'Zimbabwe, Republic of', 'Simbabwe', 'Africa', 'Afrika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(240, '0000-00-00 00:00:00', 'AX', 'ALA', 248, 'EU', 'Åland Islands', 'Åland Inseln', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(241, '0000-00-00 00:00:00', 'GG', 'GGY', 831, 'EU', 'Guernsey, Bailiwick of', 'Guernsey, Vogtei', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(242, '0000-00-00 00:00:00', 'IM', 'IMN', 833, 'EU', 'Isle of Man', 'Insel Man', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(243, '0000-00-00 00:00:00', 'JE', 'JEY', 832, 'EU', 'Jersey, Bailiwick of', 'Jersey, Vogtei', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(244, '0000-00-00 00:00:00', 'ME', 'MNE', 499, 'EU', 'Montenegro, Republic of', 'Montenegro', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(245, '0000-00-00 00:00:00', 'BL', 'BLM', 652, 'NA', 'Saint Barthelemy', 'Sankt Bartholomäus', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(246, '0000-00-00 00:00:00', 'MF', 'MAF', 663, 'NA', 'Saint Martin', 'Saint-Martin', 'North America', 'Nordamerika', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(247, '0000-00-00 00:00:00', 'RS', 'SRB', 688, 'EU', 'Serbia, Republic of', 'Serbien', 'Europe', 'Europa', '', '');

INSERT INTO `phpwcms_country` (`country_id`, `country_updated`, `country_iso`, `country_iso3`, `country_isonum`, `country_continent_code`, `country_name`, `country_name_de`, `country_continent`, `country_continent_de`, `country_region`, `country_region_de`) VALUES(248, '0000-00-00 00:00:00', 'TL', 'TLS', 626, 'AS', 'Timor-Leste, Democratic Republic of', 'Osttimor (Timor-Leste)', 'Asia', 'Asien', '', '');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(1, 'academic');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(2, 'accountant');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(3, 'actor');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(4, 'administrative services department manager');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(5, 'administrator');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(6, 'administrator, IT');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(7, 'agricultural advisor');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(8, 'air steward');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(9, 'air-conditioning installer or mechanic');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(10, 'aircraft service technician');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(11, 'ambulance driver (non paramedic)');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(12, 'animal carer (not in farms)');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(13, 'animator');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(14, 'arable farm manager, field crop or vegetable');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(15, 'arable farmer, field crop or vegetable');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(16, 'architect');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(17, 'architect, landscape');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(18, 'artist');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(19, 'asbestos removal worker');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(20, 'assembler');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(21, 'assembly team leader');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(22, 'assistant');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(23, 'author');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(24, 'baker');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(25, 'bank clerk (back-office)');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(26, 'beauty therapist');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(27, 'beverage production process controller');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(28, 'biologist');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(29, 'blogger');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(30, 'boring machine operator');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(31, 'bricklayer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(32, 'builder');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(33, 'butcher');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(34, 'car mechanic');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(35, 'career counsellor');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(36, 'caretaker');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(37, 'carpenter');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(38, 'charge nurse');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(39, 'check-out operator');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(40, 'chef');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(41, 'child-carer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(42, 'civil engineering technician');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(43, 'civil servant');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(44, 'cleaning supervisor');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(45, 'clerk');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(46, 'climatologist');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(47, 'cloak room attendant');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(48, 'cnc operator');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(49, 'comic book writer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(50, 'community health worker');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(51, 'company director');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(52, 'computer programmer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(53, 'confectionery maker');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(54, 'construction operative');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(55, 'cook');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(56, 'cooling or freezing installer or mechanic');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(57, 'critic');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(58, 'database designer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(59, 'decorator');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(60, 'dental hygienist');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(61, 'dental prosthesis technician');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(62, 'dentist');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(63, 'department store manager');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(64, 'designer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(65, 'designer, graphic');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(66, 'designer, industrial');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(67, 'designer, interface');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(68, 'designer, interior');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(69, 'designer, screen');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(70, 'designer, web');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(71, 'dietician');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(72, 'diplomat');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(73, 'director');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(74, 'display designer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(75, 'doctor');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(76, 'domestic housekeeper');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(77, 'economist');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(78, 'editor');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(79, 'education advisor');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(80, 'electrical engineer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(81, 'electrical mechanic or fitter');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(82, 'electrician');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(83, 'engineer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(84, 'engineering maintenance supervisor');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(85, 'estate agent');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(86, 'executive');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(87, 'executive secretary');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(88, 'farmer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(89, 'felt roofer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(90, 'filing clerk');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(91, 'film director');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(92, 'financial clerk');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(93, 'financial services manager');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(94, 'fire fighter');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(95, 'first line supervisor beverages workers');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(96, 'first line supervisor of cleaning workers');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(97, 'fisherman');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(98, 'fishmonger');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(99, 'flight attendant');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(100, 'floral arranger');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(101, 'food scientist');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(102, 'garage supervisor');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(103, 'garbage man');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(104, 'gardener, all other');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(105, 'general practitioner');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(106, 'geographer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(107, 'geologist');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(108, 'hairdresser');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(109, 'head groundsman');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(110, 'head teacher');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(111, 'horse riding instructor');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(112, 'hospital nurse');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(113, 'hotel manager');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(114, 'house painter');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(115, 'hr manager');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(116, 'it applications programmer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(117, 'it systems administrator');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(118, 'jeweller');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(119, 'journalist');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(120, 'judge');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(121, 'juggler');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(122, 'kitchen assistant');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(123, 'lathe setter-operator');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(124, 'lawyer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(125, 'lecturer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(126, 'legal secretary');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(127, 'lexicographer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(128, 'library assistant');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(129, 'local police officer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(130, 'logistics manager');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(131, 'machine tool operator');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(132, 'magician');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(133, 'makeup artist');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(134, 'manager');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(135, 'manager, all other health services');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(136, 'marketing manager');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(137, 'meat processing operator');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(138, 'mechanical engineering technician');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(139, 'medical laboratory technician');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(140, 'medical radiography equipment operator');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(141, 'metal moulder');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(142, 'metal production process operator');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(143, 'meteorologist');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(144, 'midwifery professional');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(145, 'miner');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(146, 'mortgage clerk');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(147, 'musical instrument maker');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(148, 'musician');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(149, 'non-commissioned officer armed forces');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(150, 'nurse');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(151, 'nursery school teacher');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(152, 'nursing aid');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(153, 'ophthalmic optician');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(154, 'optician');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(155, 'painter');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(156, 'payroll clerk');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(157, 'personal assistant');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(158, 'personal carer in an institution for the elderly');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(159, 'personal carer in an institution for the handicapped');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(160, 'personal carer in private homes');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(161, 'personnel clerk');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(162, 'pest controller');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(163, 'photographer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(164, 'physician assistant');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(165, 'pilot');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(166, 'pipe fitter');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(167, 'plant maintenance mechanic');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(168, 'plumber');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(169, 'police inspector');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(170, 'police officer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(171, 'policy advisor');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(172, 'politician');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(173, 'porter');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(174, 'post secondary education teacher');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(175, 'post sorting or distributing clerk');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(176, 'power plant operator');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(177, 'primary school head');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(178, 'primary school teacher');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(179, 'printer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(180, 'printing machine operator');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(181, 'prison officer / warder');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(182, 'product manager');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(183, 'professional gambler');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(184, 'project manager');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(185, 'programmer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(186, 'psychologist');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(187, 'puppeteer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(188, 'quality inspector, all other products');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(189, 'receptionist');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(190, 'restaurant cook');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(191, 'road paviour');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(192, 'roofer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(193, 'sailor');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(194, 'sales assistant, all other');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(195, 'sales or marketing manager');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(196, 'sales representative');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(197, 'sales support clerk');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(198, 'salesperson');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(199, 'scientist');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(200, 'seaman (armed forces)');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(201, 'secondary school manager');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(202, 'secondary school teacher');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(203, 'secretary');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(204, 'security guard');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(205, 'sheet metal worker');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(206, 'ship mechanic');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(207, 'shoe repairer, leather repairer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(208, 'shop assistant');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(209, 'sign language Interpreter');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(210, 'singer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(211, 'social media manager');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(212, 'socialphotographer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(213, 'software analyst');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(214, 'software developer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(215, 'software engineer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(216, 'soldier');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(217, 'solicitor');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(218, 'speech therapist');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(219, 'steel fixer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(220, 'stockman');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(221, 'structural engineer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(222, 'student');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(223, 'surgeon');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(224, 'surgical footwear maker');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(225, 'swimming instructor');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(226, 'system operator');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(227, 'tailor');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(228, 'tailor, seamstress');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(229, 'tax inspector');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(230, 'taxi driver');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(231, 'teacher');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(232, 'telephone operator');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(233, 'telephonist');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(234, 'theorist');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(235, 'tile layer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(236, 'translator');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(237, 'transport clerk');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(238, 'travel agency clerk');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(239, 'travel agent');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(240, 'truck driver long distances');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(241, 'trucker');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(242, 'TV cameraman');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(243, 'TV presenter');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(244, 'university professor');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(245, 'university researcher');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(246, 'vet');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(247, 'veterinary practitioner');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(248, 'vocational education teacher');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(249, 'waiter');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(250, 'waiting staff');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(251, 'web designer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(252, 'web developer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(253, 'webmaster');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(254, 'welder, all other');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(255, 'wood processing plant operator');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(256, 'writer');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(257, 'other');

INSERT INTO `phpwcms_profession` (`prof_id`, `prof_name`) VALUES(258, 'n/a');

INSERT INTO `phpwcms_template` VALUES (1, 1, 'Sample Template (very basic)', 1, 0x613a31343a7b733a343a226e616d65223b733a32383a2253616d706c652054656d706c61746520287665727920626173696329223b733a373a2264656661756c74223b693a313b733a363a226c61796f7574223b693a313b733a333a22637373223b613a313a7b693a303b733a31323a2266726f6e74656e642e637373223b7d733a383a2268746d6c68656164223b733a303a22223b733a383a226a736f6e6c6f6164223b733a303a22223b733a31303a2268656164657274657874223b733a303a22223b733a383a226d61696e74657874223b733a3637373a223c212d2d2076657279206261736963204449562062617365642074656d706c617465202d2d3e0d0a3c646976207374796c653d2270616464696e673a313070783b626f726465722d626f74746f6d3a31707820736f6c696420234343333330303b6d617267696e3a302030203132707820303b6261636b67726f756e642d636f6c6f723a234444444444443b223e0d0a3c68333e4d792073616d706c65206865616465723c2f68333e0d0a3c2f6469763e0d0a3c646976207374796c653d22706f736974696f6e3a72656c61746976653b746f703a2d313270783b666c6f61743a72696768743b70616464696e673a313070783b626f726465722d626f74746f6d3a31707820736f6c696420234343333330303b626f726465722d6c6566743a31707820736f6c696420234343333330303b6d617267696e3a302030203135707820313570783b6261636b67726f756e642d636f6c6f723a234444444444443b77696474683a31353070783b223e0d0a3c68363e6e617669676174696f6e3a3c2f68363e0d0a7b4e41565f4c4953545f554c3a502c307d0d0a3c2f6469763e0d0a3c70207374796c653d226d617267696e3a2030203020313070782030223e796f752061726520686572653a207b42524541444352554d427d3c2f703e0d0a7b434f4e54454e547d0d0a0d0a3c646976207374796c653d22626f726465722d746f703a31707820736f6c696420234343333330303b6d617267696e3a313570782030203020303b746578742d616c69676e3a63656e7465723b70616464696e673a3770783b223e0d0a636f707972696768742026636f70793b2032303037203c6120687265663d22687474703a2f2f7777772e70687077636d732e646522207461726765743d225f626c616e6b223e70687077636d732e64653c2f613e0d0a3c2f6469763e223b733a31303a22666f6f74657274657874223b733a303a22223b733a383a226c65667474657874223b733a303a22223b733a393a22726967687474657874223b733a303a22223b733a393a226572726f7274657874223b733a34323a223c68313e343034206572726f7220706167653c2f68313e0d0a3c703e4e6f20636f6e74656e743c2f703e223b733a31303a2266656c6f67696e75726c223b733a303a22223b733a323a226964223b693a313b7d, 0);

INSERT INTO `phpwcms_pagelayout` VALUES (1, 'Sample Pagelayout', 1, 0x613a36323a7b733a323a226964223b693a313b733a31313a226c61796f75745f6e616d65223b733a31373a2253616d706c6520506167656c61796f7574223b733a31343a226c61796f75745f64656661756c74223b693a313b733a31323a226c61796f75745f616c69676e223b693a303b733a31313a226c61796f75745f74797065223b693a303b733a31373a226c61796f75745f626f726465725f746f70223b733a303a22223b733a32303a226c61796f75745f626f726465725f626f74746f6d223b733a303a22223b733a31383a226c61796f75745f626f726465725f6c656674223b733a303a22223b733a31393a226c61796f75745f626f726465725f7269676874223b733a303a22223b733a31353a226c61796f75745f6e6f626f72646572223b693a313b733a31323a226c61796f75745f7469746c65223b733a393a22506167657469746c65223b733a31383a226c61796f75745f7469746c655f6f72646572223b693a343b733a31393a226c61796f75745f7469746c655f737061636572223b733a333a22207c20223b733a31343a226c61796f75745f6267636f6c6f72223b623a303b733a31343a226c61796f75745f6267696d616765223b733a303a22223b733a31353a226c61796f75745f6a736f6e6c6f6164223b733a303a22223b733a31363a226c61796f75745f74657874636f6c6f72223b623a303b733a31363a226c61796f75745f6c696e6b636f6c6f72223b623a303b733a31333a226c61796f75745f76636f6c6f72223b623a303b733a31333a226c61796f75745f61636f6c6f72223b623a303b733a31363a226c61796f75745f616c6c5f7769647468223b733a303a22223b733a31383a226c61796f75745f616c6c5f6267636f6c6f72223b623a303b733a31383a226c61796f75745f616c6c5f6267696d616765223b733a303a22223b733a31363a226c61796f75745f616c6c5f636c617373223b733a303a22223b733a32303a226c61796f75745f636f6e74656e745f7769647468223b733a303a22223b733a32323a226c61796f75745f636f6e74656e745f6267636f6c6f72223b623a303b733a32323a226c61796f75745f636f6e74656e745f6267696d616765223b733a303a22223b733a32303a226c61796f75745f636f6e74656e745f636c617373223b733a303a22223b733a31373a226c61796f75745f6c6566745f7769647468223b733a303a22223b733a31393a226c61796f75745f6c6566745f6267636f6c6f72223b623a303b733a31393a226c61796f75745f6c6566745f6267696d616765223b733a303a22223b733a31373a226c61796f75745f6c6566745f636c617373223b733a303a22223b733a31383a226c61796f75745f72696768745f7769647468223b733a303a22223b733a32303a226c61796f75745f72696768745f6267636f6c6f72223b623a303b733a32303a226c61796f75745f72696768745f6267696d616765223b733a303a22223b733a31383a226c61796f75745f72696768745f636c617373223b733a303a22223b733a32323a226c61796f75745f6c65667473706163655f7769647468223b733a303a22223b733a32343a226c61796f75745f6c65667473706163655f6267636f6c6f72223b623a303b733a32343a226c61796f75745f6c65667473706163655f6267696d616765223b733a303a22223b733a32323a226c61796f75745f6c65667473706163655f636c617373223b733a303a22223b733a32333a226c61796f75745f726967687473706163655f7769647468223b733a303a22223b733a32353a226c61796f75745f726967687473706163655f6267636f6c6f72223b623a303b733a32353a226c61796f75745f726967687473706163655f6267696d616765223b733a303a22223b733a32333a226c61796f75745f726967687473706163655f636c617373223b733a303a22223b733a32303a226c61796f75745f6865616465725f686569676874223b733a303a22223b733a32313a226c61796f75745f6865616465725f6267636f6c6f72223b623a303b733a32313a226c61796f75745f6865616465725f6267696d616765223b733a303a22223b733a31393a226c61796f75745f6865616465725f636c617373223b733a303a22223b733a32323a226c61796f75745f746f7073706163655f686569676874223b733a303a22223b733a32333a226c61796f75745f746f7073706163655f6267636f6c6f72223b623a303b733a32333a226c61796f75745f746f7073706163655f6267696d616765223b733a303a22223b733a32313a226c61796f75745f746f7073706163655f636c617373223b733a303a22223b733a32353a226c61796f75745f626f74746f6d73706163655f686569676874223b733a303a22223b733a32363a226c61796f75745f626f74746f6d73706163655f6267636f6c6f72223b623a303b733a32363a226c61796f75745f626f74746f6d73706163655f6267696d616765223b733a303a22223b733a32343a226c61796f75745f626f74746f6d73706163655f636c617373223b733a303a22223b733a32303a226c61796f75745f666f6f7465725f686569676874223b733a303a22223b733a32313a226c61796f75745f666f6f7465725f6267636f6c6f72223b623a303b733a32313a226c61796f75745f666f6f7465725f6267696d616765223b733a303a22223b733a31393a226c61796f75745f666f6f7465725f636c617373223b733a303a22223b733a31333a226c61796f75745f72656e646572223b693a323b733a31393a226c61796f75745f637573746f6d626c6f636b73223b733a303a22223b7d, 0);

INSERT INTO `phpwcms_user` VALUES (1,'admin','1c0b76fce779f78f51be339c49445c49','noreply@localhost:3456','2023-06-30 11:13:26',0,1,'',1,'Webmaster','','','','en',2,2,'');
INSERT INTO `phpwcms_user` VALUES (2,'user1','1c0b76fce779f78f51be339c49445c49','noreply@localhost:3456','2023-06-30 11:13:26',0,0,'',1,'user1','','','','en',2,2,'');