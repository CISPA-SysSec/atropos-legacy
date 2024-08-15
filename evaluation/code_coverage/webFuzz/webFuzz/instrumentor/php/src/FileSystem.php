<?php

namespace App {

class CustomFilterIterator extends \RecursiveFilterIterator {
   public function accept() {
      global $___excludedFiles;
      foreach (($___excludedFiles ?? []) as $e)
         if ($e == $this->getPathname())
            return false;
      return true;
   }
}

class FileSystemException extends \Exception {};

class FileSystem {
   public static function makeFolderName($folderName, $suffix = "") {
      while ($folderName[-1] == "/")
         $folderName = \substr($folderName, 0, -1);

      $newFolderName = $folderName . $suffix;

      if (file_exists($newFolderName))
         throw new FileSystemException("Destination folder '$newFolderName' already exists.");
      
      return $newFolderName;
   }

   public static function copyFolderRecursive(string $src, $dst) {
      $out = system("cp -r ". $src . " " . $dst, $return_val);

      if ($return_val)
         throw new FileSystemException("Copy error ". $out);

      return $dst;
   }
   
   public static function getPhpFilesRecursive(string $rootDir, array $excludedFiles): array {
      global $___excludedFiles;
      $___excludedFiles = $excludedFiles;

      $dir = new \RecursiveDirectoryIterator($rootDir);
      $filter = new CustomFilterIterator($dir);
      $iterator = new \RecursiveIteratorIterator($filter);
      $files = new \RegexIterator($iterator, "/.*\.php$/", \RegexIterator::GET_MATCH);
      $fileList = array();
      foreach($files as $file) {
          $fileList = array_merge($fileList, $file);
      }
      return $fileList;
   }
}

}