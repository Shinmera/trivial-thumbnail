#|
 This file is a part of Trivial-Mimes
 (c) 2014 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(defpackage #:trivial-thumbnail
  (:nicknames #:thumbnail #:org.tymoonnext.trivial-thumbnail)
  (:use #:cl)
  (:export
   #:*convert-bin*
   #:*mogrify-bin*
   #:convert
   #:mogrify
   #:create))
(in-package #:org.tymoonnext.trivial-thumbnail)

(defvar *convert-bin*
  #+unix "convert"
  #+windows "convert.exe"
  "String or pathname designating the location of the imagemagick CONVERT binary.")

(defvar *mogrify-bin*
  #+unix "mogrify"
  #+windows "mogrify.exe"
  "String or pathname designating the location of the imagemagick MOGRIFY binary.")

(defun binary-alternatives (binary-name)
  "Return a list of poissible alternative locations for the specified binary."
  (mapcar #'(lambda (path)
              (let ((path (merge-pathnames (make-pathname :name binary-name) path)))
                (if (wild-pathname-p path)
                    (first (uiop:directory-files path #p""))
                    path)))
          (list
           #+unix #p"/usr/bin/"
           #+unix #p"/usr/local/bin/"
           #+windows #p"C:/windows/system32/x.exe"
           #+windows #p"C:/Program Files/ImageMagick*/x.exe"
           #+windows #p"C:/Program Files (x86)/ImageMagick*/x.exe")))

(defun locate-binary (label &rest alternatives)
  "Iterates through the alternatives and, if one can be found by PROBE-FILE, sets the SYMBOL-VALUE of LABEL to that path.
Otherwise signals a WARNING."
  (let ((location (loop for alt in alternatives
                        thereis (and alt (probe-file alt)))))
    (if location
        (setf (symbol-value label) location)
        (warn "No binary for ~a found! Please adapt THUMBNAIL:~:*~a with the proper pathname if the commands don't work." label))))

(apply #'locate-binary '*convert-bin* (binary-alternatives "convert"))
(apply #'locate-binary '*mogrify-bin* (binary-alternatives "mogrify"))

(defun run-program (&rest argslist)
  "Wrapper around UIOP:RUN-PROGRAM that returns the string output of the command and
passes the argslist to UIOP:ESCAPE-COMMAND. Also accepts a pathname as the executable designator."
  (let ((args (if (pathnamep (first argslist))
                  (cons (uiop:native-namestring (first argslist)) (cdr argslist))
                  argslist)))
    (uiop:run-program (uiop:escape-command args) :output :string)))

(defun convert (in out &rest args)
  "Runs imagemagick's CONVERT on IN with the result to OUT using the command-line ARGS."
  (apply #'run-program
         *convert-bin*
         (uiop:native-namestring in)
         (append args
                 (list (uiop:native-namestring out)))))

(defun mogrify (in &rest args)
  "Runs imagemagick's MOGRIFY on IN using the command-line ARGS."
  (apply #'run-program
         *mogrify-bin*
         (append args
                 (list (uiop:native-namestring in)))))

(defun create (in out &key (width 150) (height 150) crop (quality 100) (preserve-gif T) (if-exists :error))
  "Creates a thumbnail of IN with the result to OUT.

IN           --- A pathname or string to the source image. Strings are parsed using 
                 UIOP:PARSE-NATIVE-NAMESTRING.
OUT          --- A pathname or string to the source image or NIL. If NIL, OUT is the
                 same as IN, with 'thumb-' prefixed to the pathname-name.
WIDTH        --- The width of the thumbnail in pixels.
HEIGHT       --- The height of the thumbnail in pixels.
CROP         --- How to create the thumbnail. Can be one of the following:
                 NIL     Scale the image, preserving the aspect ratio.
                 :WIDTH  Scale the image to HEIGHT and crop the width down to fit WIDTH.
                 :HEIGHT Scale the image to WIDTH and crop the height down to fit HEIGHT.
                 T       Crop the image width and height to fit WIDTH and HEIGHT.
QUALITY      --- Percentage for the quality to use (0-100).
PRESERVE-GIF --- Whether to run imagemagick with -coalesce, which preserves
                 GIF animations, but will take more time to compute.
IF-EXISTS    --- What to do if OUT exists. Can be one of the following:
                 NIL        Don't create a thumbnail and just return NIL.
                 :ERROR     Signal an error.
                 :WARN      Signal a warning.
                 :SUPERSEDE Overwrite the file.

Returns OUT."
  (when (stringp in) (setf in (uiop:parse-native-namestring in)))
  (when (stringp out) (setf out (uiop:parse-native-namestring out)))
  (when (null out) (setf out (make-pathname :name (format NIL "thumb-~a" (pathname-name in)) :defaults in)))

  (assert (and (uiop:file-pathname-p in)
               (uiop:file-exists-p in))
          () "IN must be a pathname designating an existing file.")
  (assert (uiop:file-pathname-p out)
          () "OUT must be a pathname designating a file.")
  (when (uiop:file-exists-p out)
    (ecase if-exists
      ((NIL) (return-from create NIL))
      (:ERROR (error "Thumbnail ~s already exists." (uiop:native-namestring out)))
      (:WARN (warn "Thumbnail ~s already exists." (uiop:native-namestring out)))
      (:SUPERSEDE)))
  
  (flet ((convert (&rest args)
           (apply #'convert in out
                  "-quality" (format NIL "~d%" quality)
                  (if preserve-gif "-coalesce" "")
                  args))
         (mogrify (&rest args)
           (apply #'mogrify out
                  "-quality" (format NIL "~d%" quality)
                  (if preserve-gif "-coalesce" "")
                  args)))
    (ecase crop
      ((NIL)
       (convert "-thumbnail" (format NIL "~dx~d" width height)))
      (:width
       (convert "-thumbnail" (format NIL "x~d" height))
       (mogrify "-gravity" "center" "-crop" (format NIL "~dx~d!+0+0" width height)))
      (:height
       (convert "-thumbnail" (format NIL "~d" width))
       (mogrify "-gravity" "center" "-crop" (format NIL "~dx~d!+0+0" width height)))
      ((T)
       (convert "-gravity" "center" "-crop" (format NIL "~dx~d!+0+0" width height))))
    out))
