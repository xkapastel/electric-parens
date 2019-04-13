(define local (vau _ e e))

(define lambda
  (vau (parameters . body) call-site
    (wrap (eval (list* vau parameters () body) call-site))))
