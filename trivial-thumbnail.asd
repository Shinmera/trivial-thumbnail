#|
 This file is a part of Trivial-Mimes
 (c) 2014 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(defsystem trivial-thumbnail
  :name "Trivial-Thumbnail"
  :version "1.1.0"
  :license "zlib"
  :author "Nicolas Hafner <shinmera@tymoon.eu>"
  :maintainer "Nicolas Hafner <shinmera@tymoon.eu>"
  :description "Tiny library to create image thumbnails with imagemagick."
  :homepage "https://Shinmera.github.io/trivial-thumbnail/"
  :bug-tracker "https://github.com/Shinmera/trivial-thumbnail/issues"
  :source-control (:git "https://github.com/Shinmera/trivial-thumbnail.git")
  :serial T
  :components ((:file "thumbnail"))
  :depends-on (:uiop))
