;;;; todo.asd

(asdf:defsystem #:todo
  :description "Todo app"
  :author "Humberto Pinheiro <humbhenri@gmail.com>"
  :license "Public Domain"
  :depends-on (#:hunchentoot #:cl-ppcre #:cl-who #:local-time)
  :serial t
  :components ((:file "package")
               (:file "todo")))

