#|
 This file is a part of Trivial-Mimes
 (c) 2014 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(defsystem trivial-thumbnail
  :name "Trivial-Thumbnail"
  :version "1.1.0"
  :license "Artistic"
  :author "Nicolas Hafner <shinmera@tymoon.eu>"
  :maintainer "Nicolas Hafner <shinmera@tymoon.eu>"
  :description "Tiny library to create image thumbnails with imagemagick."
  :homepage "https://github.com/Shinmera/trivial-thumbnail"
  :serial T
  :components ((:file "thumbnail"))
  :depends-on (:uiop))
