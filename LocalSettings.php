<?php

# Protect against web entry
if ( !defined( 'MEDIAWIKI' ) ) {
	exit;
}

$wgSitename = "mywiki";

$wgScriptPath = "";
$wgServer = "http://localhost";

$wgResourceBasePath = $wgScriptPath;
$wgLogo = "$wgResourceBasePath/resources/assets/wiki.png";

$wgEnableEmail = true;
$wgEnableUserEmail = true;

$wgEmergencyContact = "wiki@localhost";
$wgPasswordSender = "wiki@localhost";

$wgEnotifUserTalk = false;
$wgEnotifWatchlist = false;
$wgEmailAuthentication = true;

## Database settings
$wgDBtype = "postgres";
$wgDBserver = "postgres";
$wgDBname = "postgres";
$wgDBuser = "postgres";
$wgDBpassword = "enter";

# Postgres specific settings
$wgDBport = "5432";
$wgDBmwschema = "mediawiki";

## Shared memory settings
$wgMainCacheType = CACHE_NONE;
#$wgMainCacheType = CACHE_ANYTHING;
$wgMemCachedServers = [];

## To enable image uploads, make sure the 'images' directory
## is writable, then set this to true:
$wgEnableUploads = true;
#$wgUseImageMagick = true;
#$wgImageMagickConvertCommand = "/usr/bin/convert";

# InstantCommons allows wiki to use images from https://commons.wikimedia.org
$wgUseInstantCommons = true;

# Periodically send a pingback to https://www.mediawiki.org/ with basic data
# about this MediaWiki instance. The Wikimedia Foundation shares this data
# with MediaWiki developers to help guide future development efforts.
$wgPingback = true;

## If you use ImageMagick (or any other shell command) on a
## Linux server, this will need to be set to the name of an
## available UTF-8 locale
$wgShellLocale = "C.UTF-8";

## Set $wgCacheDirectory to a writable directory on the web server
## to make your wiki go slightly faster. The directory should not
## be publically accessible from the web.
#$wgCacheDirectory = "$IP/cache";

# Site language code, should be one of the list in ./languages/data/Names.php
$wgLanguageCode = "en";
$wgSecretKey = "c26299273afac9f1e6331d5abdac72d45504daeba128cdd9c59b16cbf61cc746";

# Changing this will log out all existing sessions.
$wgAuthenticationTokenVersion = "1";

# Site upgrade key. Must be set to a string (default provided) to turn on the
# web installer while LocalSettings.php is in place
$wgUpgradeKey = "62792754528a5db8";

## For attaching licensing metadata to pages, and displaying an
## appropriate copyright notice / icon. GNU Free Documentation
## License and Creative Commons licenses are supported so far.
$wgRightsPage = ""; # Set to the title of a wiki page that describes your license/copyright
$wgRightsUrl = "";
$wgRightsText = "";
$wgRightsIcon = "";

# Path to the GNU diff3 utility. Used for conflict resolution.
$wgDiff3 = "/usr/bin/diff3";

# The following permissions were set based on your choice in the installer
$wgGroupPermissions['*']['edit'] = false;
$wgGroupPermissions['*']['createaccount'] = true;
$wgGroupPermissions['*']['autocreateaccount'] = true;
$wgGroupPermissions['*']['editmyprivateinfo'] = true;
$wgGroupPermissions['*']['editmyoptions'] = true;
$wgGroupPermissions['*']['viewmyprivateinfo'] = true;
$wgGroupPermissions['*']['viewmywatchlist'] = true;
$wgGroupPermissions['*']['sendemail'] = true;



## Default skin: you can change the default skin. Use the internal symbolic
## names, ie 'vector', 'monobook':
$wgDefaultSkin = "vector";

$wgUseFileCache = true;
$wgFileCacheDirectory = "$IP/cache";

# Enabled skins.
# The following skins were automatically enabled:
wfLoadSkin( 'MonoBook' );
wfLoadSkin( 'Timeless' );
wfLoadSkin( 'Vector' );


wfLoadExtension( 'CategoryTree' );
wfLoadExtension( 'Cite' );
wfLoadExtension( 'CiteThisPage' );
wfLoadExtension( 'CodeEditor' );
wfLoadExtension( 'ConfirmEdit' );
wfLoadExtension( 'ImageMap' );
wfLoadExtension( 'Interwiki' );
wfLoadExtension( 'ParserFunctions' );
wfLoadExtension( 'WikiEditor' );
wfLoadExtension( 'MsUpload' );
wfLoadExtension( 'AuthMinetest' );

require_once "$IP/extensions/SimpleEmbed/SimpleEmbed.php";


wfLoadExtension( 'Scribunto' );
$wgScribuntoDefaultEngine = 'luastandalone';

wfLoadExtension( 'SyntaxHighlight_GeSHi' );

wfLoadExtension( 'MultimediaViewer' );
wfLoadExtension( 'SimpleBatchUpload' );
wfLoadExtension( 'TemplateStyles' );
wfLoadExtension( 'JavascriptSlideshow' );
wfLoadExtension( 'FontAwesome' );

$wgShowExceptionDetails = true;

//include "LocalSettings.secrets.php";
