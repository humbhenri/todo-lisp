;;;; todo.lisp

(in-package #:todo)

(defparameter *web-server* NIL)
(defparameter *server-port* 8080)
(defparameter *todos* (list))
(defparameter *default-directory*
  (pathname (directory-namestring #.(or *compile-file-truename*
                                        *load-truename*))))
(defparameter *css-path* (merge-pathnames "css/" *default-directory*))
(defparameter *js-path* (merge-pathnames "js/" *default-directory*))
(defparameter *img-path* (merge-pathnames "img/" *default-directory*))
(defparameter *autoid* 0)
  
(defun run ()
  (setf *web-server*
	(make-instance 'hunchentoot:easy-acceptor :port *server-port*))
  (push (create-folder-dispatcher-and-handler "/css/" *css-path*) *dispatch-table*)
  (push (create-folder-dispatcher-and-handler "/js/" *js-path*) *dispatch-table*)
  (push (create-folder-dispatcher-and-handler "/img/" *img-path*) *dispatch-table*)
  (hunchentoot:start *web-server*))

(defun quit ()
  (hunchentoot:stop *web-server*))

(defmacro defpage-easy-d (name title uri parameter-list docs &body body)
  "Generates the html page and includes a page template"
      `(define-easy-handler (,name :uri ,uri 
				   :default-request-type :both)
     ,parameter-list ,docs
        (page-template ,title
                ,@body)))

(defmacro page-template (title &body body)
  "c:/Users/humberto/lisp/todo/Generates the basic html page template with css"
  `(with-html-output-to-string (*standard-output* nil :prologue t :indent t)
     (:html
      (:head
       (:link :rel "stylesheet" :href "http://yui.yahooapis.com/pure/0.6.0/pure-min.css")
       (:link :rel "stylesheet" :type "text/css" :href "css/stylesheet.css")
       (:link :rel "stylesheet" :href "//maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css")
       (:script :type "text/javascript" :src "js/app.js")
       (:meta :http-equiv "Content-Type" 
              :content "text/html;charset=utf-8")
       (:title (str (format nil " ~a" ,title))))
      (:body :onload "onclickToggleDone()"
       (:div :id "container"
             (:div 
              (:div :id "content"
                    (str ,@body))))))))

(defpage-easy-d home-page "TODO" "/" ()
    "Handles base page."
    (with-html-output-to-string (*standard-output*)
      (htm 
       (:h1 "TODO")
       (:ul :class "pure-menu-list"
            (loop for item in (list-todos)
               do (with-slots (description done id) item
                    (htm (:li :class "pure-menu-item"
                              (:span :class (when done "done") (str description))
                              "&nbsp;&nbsp;"
                              (:input :type "checkbox"
                                      :id (concatenate 'string "done" (write-to-string id))
                                      :checked (when done "checked")))))))
       (:br)
       (:h3 "New TODO")
       (:form :action "newtodo" :class "pure-form"
              (:input :type "text" :name "description" :required "required" :class "pure-input-1-2")
              (:input :type "submit" :class "pure-button pure-button-primary")))))

(define-easy-handler (newtodo-page :uri "/newtodo" :default-request-type :both) ((description :parameter-type 'string))
  "Handle new todo submit"
  (setf *todos* (cons (make-instance 'todo-item :description description) *todos*))
  (redirect "/"))

(define-easy-handler (toggle-done-page :uri "/done" :default-request-type :both)
    ((id :parameter-type 'integer))
  "Toggle todo item done status"
  (let ((todo-item (find-todo-item-by-id id)))
    (setf (done todo-item) (not (done todo-item))))
  (redirect "/"))

(defclass todo-item ()
  ((id
    :initarg :id
    :initform (incf *autoid*)
    :reader id)
   (description
    :initarg :description
    :initform (error "Description must be informed")
    :reader description)
   (done
    :initarg :done
    :initform nil
    :accessor done)
   (created
    :initarg :created
    :initform (get-universal-time)
    :reader created)))

(defmethod print-object ((obj todo-item) out)
  (print-unreadable-object (obj out :type t)
    (format out "~s" (description obj))))

(defun list-todos ()
  *todos*)

(defun find-todo-item-by-id (id)
  (find-if #'(lambda (item) (equal id (id item))) *todos*))
