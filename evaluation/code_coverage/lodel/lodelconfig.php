<?php
/**
 * LODEL - Logiciel d'Édition ÉLectronique.
 * @license GPL 2 (http://www.gnu.org/licenses/gpl.html) See COPYING file
 * @authors See COPYRIGHT file
 */

/*
 Paramètres de base à renseigner lors de l'installation
*/

// Doit être commenté lors de la copie de ce fichier en lodelconfig.php
//exit();

// Cette clé n'est utilisée que lors de la phase d'installation
// Elle est générée par la commande suivante : cat /proc/sys/kernel/random/uuid
// Pour que l'installation soit possible il faut créer un fichier à la racine nommé d'après cette clé
// ex: cd /data/www/lodel && touch 03dde1bd-c6b6-4424-8618-c4488e30484a
// Une fois l'installation terminée il faut supprimer ce fichier afin de rendre l'exécution de l'installation impossible
$cfg['install_key'] = '03dde1bd-c6b6-4424-8618-c4488e30484a';

// Nom de la base de données
$cfg['database'] = 'lodel';
// Nom d'utilisateur
$cfg['dbusername'] = 'lodeluser';
// Mot de passe
$cfg['dbpasswd'] = 'p@ssw0rd';
// Hote de la base de données
$cfg['dbhost'] = '';
// driver mysql
$cfg['dbDriver'] = 'mysqli';

// Fuseaux horaires supportés : http://php.net/manual/fr/timezones.php
$cfg['timezone'] = 'Europe/Paris';
$cfg['locale'] = 'fr_FR.UTF8';

/*
 Fin des paramètres de base à renseigner lors de l'installation
*/

/*
 Paramètres dont la valeur par défaut devrait convenir dans la plupart des cas
*/

// Racine de lodel sur le systeme
$cfg['pathroot'] = '.';


// Base du site
// ATTENTION : $urlroot doit toujours se terminer par /, il ne peut etre vide
$cfg['urlroot'] = '/';


// Emplacement des scripts essentiels à Lodel,cette variable doit se terminer par / obligatoirement.
$cfg['home'] = './lodel/scripts/';

// Localisation des fichiers archive pour l'import de donnees
$cfg['importdir'] = '';

// Timeout pour les sessions en secondes
$cfg['timeout'] = 120*60;

// Timeout pour les cookies en secondes
$cfg['cookietimeout'] = 4*3600;


/*
 Fin des paramètres dont la valeur par défaut devrait convenir dans la plupart des cas
*/


/* 
 Paramètres du système de cache
*/

// La configuration par défaut écrit dans le répertoire tmp défini par l'OS
$cfg['cacheOptions'] = array(
        'driver'    => 'file',
        'prefix'    => 'lodel',
        'cache_dir'          => sys_get_temp_dir(),
        'default_expire'     => 3600,
);

// Exemple avec memcached, nécessite l'installation de l'extension php memcache
/*
$cfg['cacheOptions'] = array(
        'driver' => 'memcache',
        'prefix' => 'lodel',
        'default_expire'=> 3600*24,
        'compression' => FALSE, // Use Zlib compression (can cause issues with integers)
        'servers' => array(
                          array(
                               'host' => '127.0.0.1',  // Memcache Server
                               'port' => 11211,        // Memcache port number
                               'persistent' => FALSE,        // Persistent connection
                               'weight' => 1,
                               'timeout' => 1,
                               'retry_interval'   => 15,
                               'status'           => TRUE,
                               ),
                         ),
        'instant_death'=> TRUE, // Take server offline immediately on first fail (no retry)

);
*/

/* 
 Fin des paramètres du système de cache
*/


/*
 Paramètres avancés
*/

// Doit être conservé, indépendamment de la configuration du système de cache
$cfg['cacheDir'] = sys_get_temp_dir();

// version de Lodel
$cfg['version']="1.0";
// revision SVN de la release
$cfg['revision']="443X";


// URL contenant les fichiers communs partagés
// par exemple $shareurl="http://lodel.revues.org/share";
// la version sera ajoutee sur le dernier repertoire, donc la chaine ne doit pas se terminer par /
$cfg['shareurl']=$cfg['urlroot']."share";

// Repertoire contenant les fichiers communs partagés
// par exemple $sharedir="/var/www/lodel/share";
// ->a supprimer de ce fichier quand tous les lodel seront passe en versionning
$cfg['sharedir']="{$cfg['pathroot']}/share";

// contact bug. Adresse mail de la personne contactee automatiquement en cas de bug
$cfg['contactbug']="";

// Repertoire contenant le binaire de mysql
$cfg['mysqldir']="/usr/bin";

// LODEL n'utilise qu'une seule DB. Sinon, il utilise une DB principale plus une DB par site. "on" ou "" (ou "off")
$cfg['singledatabase']="off";

// Prefix pour les tables. Utile quand on utilise qu'une seule database pour plusieurs applications.
// Laisser un chaîne vide, la feature est cassée
// TODO la feature est cassée, à fixer ou à supprimer.
$cfg['tableprefix'] = "";

// Nom de la session (cookie)
$cfg['sessionname']="session{$cfg['database']}";

// Détection automatique de la langue de navigation
$cfg['detectlanguage'] = true;
// Choix par défaut de la langue de navigation
// $cfg['mainlanguageoption'] = 'options.metadonneessite.langueprincipale';


// type d'URL
$cfg['extensionscripts']="php";      // extension .php ou .html pour les scripts accessibles par les internautes
define("URI","id");               // /index.php?id=ID 
//define("URI","singleid");       // /ID (nécessite un rewrite dans la conf du serveur web)

// configuration d'OTX
$cfg['otxurl']="";
$cfg['otxusername']="";
$cfg['otxpasswd']="";
// repertoire temporaire d'extraction d'OTX
$cfg['tmpoutdir']="";
// taille maximum du fichier permis à l'upload pour OTX
$cfg['maxUploadFileSize'] = 10240000;

// configuration du proxy pour atteindre OTX
$cfg['proxyhost']="";
$cfg['proxyport']="8080";

 //tableau des types de fichiers acceptés à l'upload
$cfg['authorizedFiles'] = array( '.png', '.gif', '.jpg', '.jpeg', '.tif', '.doc', '.odt', '.ods', '.odp', '.pdf', '.ppt', '.sxw', '.xls', '.rtf', '.zip', '.gz', '.ps', '.ai', '.eps', '.swf', '.rar', '.mpg', '.mpeg', '.avi', '.asf', '.flv', '.wmv', '.docx', '.xlsx', '.pptx', '.mp3', '.mp4', '.ogg', '.xml');

// Types de fichiers autorisés à l'import par otx
$cfg['authorized_import'] = array('doc', 'docx', 'sxw', 'odt', 'rtf');


// lock les tables.
// Chez certains hebergeurs n'acceptent pas les LOCK

define("DONTUSELOCKTABLES",false);

// liste des sites dans lesquels on n'écrit pas
// utilisé pour les index externes
// exemple d'utilisation : $cfg['db_no_intrusion'] = array('mon_site' => true);
$cfg['db_no_intrusion'] = array();

////////////////////////////////////////////////////////////////////////////////////////
// config reserve au systeme de config automatique
// la presence de ces variables est obligatoire pour la configuration
$cfg['chooseoptions']="oui";
$cfg['includepath']=""; // pour les sites qui ont un include automatique (defini par php.ini)
$cfg['htaccess']="on";    //
$cfg['filemask']="0700";
$cfg['usesymlink']="oui";
$cfg['installoption']="2";
$cfg['installlang']="fr";
////////////////////////////////////////////////////////////////////////////////////////

$GLOBALS['cacheOptions'] = $cfg['cacheOptions'];
// debugMode : 0 = off, 1 = affichage simple des erreurs, 2 = affichage du debug backtrace, 3 = affichage du debug backtrace + arrêt du script
$cfg['debugMode']=0; 
// showPubErrMsg : affichage d'un message générique en cas d'erreur pour utilisateur non identifié 
$cfg['showPubErrMsg'] = false;
// dieOnErr : arrêt du script en cas d'erreur, indépendamment du debugMode
$cfg['dieOnErr'] = false;
$cfg['locale']="fr_FR.UTF8";
setlocale (LC_ALL,$cfg['locale']);
date_default_timezone_set($cfg['timezone']);
ignore_user_abort();


// securite
$currentdb="";
$cfg['currentdb']="";
$GLOBALS['currentdb'] = $cfg['currentdb'];

if (!$cfg['filemask']) {
	$cfg['filemask'] = 0700;
}

define ("NORECORDURL",1);
define ("INC_LODELCONFIG",1);
