; This aims to be a solution for:
; http://projecteuler.net/index.php?section=problems&id=5
(asdf:oos 'asdf:load-op :iterate)
(use-package :iterate)

(defun calc-seq-rank (n)
  (if (= n 1)
    0
    (1+ (calc-seq-rank (if (= 0 (mod n 2)) (/ n 2) (1+ (* 3 n)))))))

(defun myfind ()
  (iter (for i from 2 to 999999)
        (reducing (cons i (calc-seq-rank i))
                  by #'(lambda (m n) (if (> (cdr m) (cdr n)) m n))
                  initial-value (cons 1 0))))
