;;;load cl-match
;;;by Dan Bensen

(cl:in-package :cl-user)

;;; each file entry is a list of a pathname and filename
;;; lists starting with :serial are serially dependent

(cl:in-package :cl-user)

(let* ((root (make-pathname :name nil :type nil :version nil
			    :defaults (parse-namestring *load-truename*)))
       (main-list `(:serial
		    ((,root "pcl-unit-test") (,root "match"))
		    (,root "match-test"))))
(labels ((load-file (path name compiling)
	   (let* ((src (make-pathname :name name :type "lisp" :defaults path))
		  (fasl (compile-file-pathname src)))
	     (when (or compiling
		       (not (probe-file fasl))
		       (<= (file-write-date fasl) (file-write-date src))
		       (not (ignore-errors (load fasl) t)))
	       (setq compiling t)
	       (compile-file src)
	       (load fasl)))
	   compiling)
	 (load-serial (list compiling)
	   (dolist (sublist list compiling)
	     (when (load-list sublist compiling)
	       (setf compiling t))))
	 (load-list (list compiling-now)
	   (let ((car (car list)))
	     (cond ((eq car :serial) (load-serial   (cdr  list) compiling-now))
		   ((pathnamep car)  (load-file car (cadr list) compiling-now))
		   (compiling-now (dolist (sublist list t)
				    (load-list sublist t)))
		   (t (let (compiling-next)
			(dolist (sublist list compiling-next)
			  (when (load-list sublist nil)
			    (setf compiling-next t)))))))))
  (with-compilation-unit ()
    (load (merge-pathnames (make-pathname :name "load" :type "lisp"
					  :directory '(:relative "std"))
			   root))
    (load-list main-list nil))))
