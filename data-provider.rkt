#lang racket
(require "stkcmd.rkt"
         "stkbase.rkt"
         racket/date)
(provide data-provider
         currnt-dstr)
(define(currnt-dstr)
  (string-join (drop-right(cdr (string-split(parameterize([date-display-format 'rfc2822])
                          (date->string(seconds->date (current-seconds) #f)#t)))) 1)))
;
(define (data-provider id  x y z)
  (let loop([x1 x])
    (sleep 1)
    (define-values (a b)(STKCmd id (format "SetPosition */Satellite/sat1 LLA ~s ~a ~a ~a" (currnt-dstr)
                       x1 y z )))
   ; (displayln (list a b))
    (loop (+ x1 1) )))
  ;(gen-Position "*/Satellite/sat1 LLA 