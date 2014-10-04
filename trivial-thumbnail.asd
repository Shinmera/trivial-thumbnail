#|
 This file is a part of Trivial-Mimes
 (c) 2014 TymoonNET/NexT http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(defpackage #:org.tymoonnext.trivial-thumbnail.asd
  (:use #:cl #:asdf))
(in-package #:org.tymoonnext.trivial-thumbnail.asd)

(defsystem trivial-thumbnail
  :name "Trivial-Thumbnail"
  :version "1.0.0"
  :license "Artistic"
  :author "Nicolas Hafner <shinmera@tymoon.eu>"
  :maintainer "Nicolas Hafner <shinmera@tymoon.eu>"
  :description "Tiny library to create image thumbnails with imagemagick."
  :homepage "https://github.com/Shinmera/trivial-thumbnail"
  :serial T
  :components ((:file "thumbnail"))
  :depends-on ())
