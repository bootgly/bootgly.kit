<?php
/*
 * --------------------------------------------------------------------------
 * Bootgly PHP Framework
 * Developed by Rodrigo Vieira (@rodrigoslayertech)
 * Copyright (c) 2023-present Bootgly and contributors
 * Licensed under MIT
 * --------------------------------------------------------------------------
 */

define('BOOTGLY_WORKING_BASE', __DIR__);
define('BOOTGLY_WORKING_DIR', BOOTGLY_WORKING_BASE . DIRECTORY_SEPARATOR);

// @ Autoboot the optional platforms (installed on demand by the project wizard):
// Platforms are self-contained (constants + autoloader, no Bootgly dependency) and
// must boot first — the Bootgly autoboot below routes projects that use them.
foreach (['Console', 'Web'] as $platform) {
   if (is_file(__DIR__ . "/{$platform}/autoboot.php") === true) {
      @include __DIR__ . "/{$platform}/autoboot.php";
   }
}

// @ Autoboot the Bootgly platform (git submodule) — the ONE framework delivery.
// Composer is per project: each project's vendor/autoload.php is loaded by the
// framework when that project boots.
$booted = (@include __DIR__ . '/Bootgly/autoboot.php');

if ($booted === false) {
   exit(1);
}
