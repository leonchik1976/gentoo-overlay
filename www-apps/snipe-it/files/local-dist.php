<?php
// Use only Manifest-verified local distfiles. Keep in sync with the generator.
$lock = json_decode(file_get_contents('composer.lock'), true, 512, JSON_THROW_ON_ERROR);
foreach ($lock['packages'] as &$package) {
    $dist = &$package['dist'];
    $name = str_replace('/', '-', $package['name']);
    $digest = substr(hash('sha256', $dist['url']), 0, 16);
    $archive = $argv[1].'/snipe-it-dep-'.$name.'-'.$digest.'.zip';
    if ($dist['type'] !== 'zip' || !is_file($archive)) {
        throw new RuntimeException('Missing or unsupported distfile: '.$archive);
    }
    $dist['url'] = 'file://'.$archive;
    // Prevent a failed archive extraction from falling back to a VCS download.
    unset($package['source']);
    unset($dist);
}
unset($package);
file_put_contents('composer.lock', json_encode($lock, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES)."\n");
