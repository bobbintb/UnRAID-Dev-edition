<?PHP
/* Copyright 2005-2023, Lime Technology
 * Copyright 2012-2023, Bergware International.
 * Copyright 2015-2021, Derek Macias, Eric Schultz, Jon Panozzo.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License version 2,
 * as published by the Free Software Foundation.
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 */
?>
<?
$docroot ??= ($_SERVER['DOCUMENT_ROOT'] ?: '/usr/local/emhttp');
require_once "$docroot/plugins/dynamix/include/Helpers.php";
require_once "$docroot/plugins/dynamix.vm.manager/include/libvirt_helpers.php";

// add translations
$_SERVER['REQUEST_URI'] = 'vms';
require_once "$docroot/webGui/include/Translations.php";

// get Ubuntu download archive
$ubuntu  = '/var/tmp/ubuntu-isos';
$archive = 'https://releases.ubuntu.com';
exec("wget -T10 -qO- $archive|grep -Po '\"\\K\d{2}\.\d{2}[^/]*'",$isos,$code);
echo "<script>console.log(" . json_encode($isos) . ");</script>";

if ($code==0 && count($isos)>1) {
  // delete obsolete entries
  foreach ($ubuntu_isos as $iso => $data) if (!in_array($iso,$isos)) unset($ubuntu_isos[$iso]);
  // add new entries
  foreach ($isos as $iso) {
    if (isset($ubuntu_isos[$iso])) continue;
    $ubuntu_isos[$iso]['name'] = "ubuntu-$iso-desktop-amd64.iso";
    $ubuntu_isos[$iso]['url'] = "$archive/$iso/ubuntu-$iso-desktop-amd64.iso";
    $ubuntu_isos[$iso]['size'] = 600*1024*1024; // assume 600 MB - adjusted once file is downloaded
    $ubuntu_isos[$iso]['md5'] = ''; // unused md5 - created once file is downloaded
  }
  // sort with newest version first
  uksort($ubuntu_isos,function($a,$b){return strnatcmp($b,$a);});
  // save obtained information to keep '$ubuntu_isos' up-to-date
  file_put_contents($ubuntu,serialize($ubuntu_isos));
} else @unlink($ubuntu);

$iso_dir = $domain_cfg['MEDIADIR'];
if (empty($iso_dir) || !is_dir($iso_dir)) {
  $iso_dir = '/mnt/user/isos/';
} else {
  $iso_dir = str_replace('//', '/', $iso_dir.'/');
}
$strMatch = '';
if (!empty($domain_cfg['MEDIADIR']) && !empty($domain_cfg['VIRTIOISO']) && dirname($domain_cfg['VIRTIOISO'])!='.' && is_file($domain_cfg['VIRTIOISO'])) $strMatch = 'manual';
foreach ($ubuntu_isos as $key => $value) {
  if (($domain_cfg['VIRTIOISO'] == $iso_dir.$value['name']) && is_file($iso_dir.$value['name'])) $strMatch = $value['name'];
  echo mk_option($strMatch, $value['name'], $value['name']);
 }
echo mk_option($strMatch, 'manual', _('Manual'));
?>
