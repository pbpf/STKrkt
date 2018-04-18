#lang racket
;STK base test
(require "stkbase.rkt"
         rackunit
         rackunit/gui)

;open cnn close test
(define (test-open-cnn-close)
  (define cfg (Initcnn))
  (define-values(id fg)(OpenSTK "localhost:5001"))
  (define fgc (CloseSTK id))
  (Shutdowncnn)
   (test-suite
      "open cnn close test"
(test-case "open cnn"
(check-equal? cfg 0 "open cnn ok"))

(test-case "open stk2"
(check-equal? fg 0 "openstk fg success"))
(test-case "open stk2"
(check-not-equal?  id #"" "openstk fg success ok"))


(test-case "close stk"
(check-equal? fgc 0))


  ))

;---------------------

(module+ test
  (test/gui
   (test-open-cnn-close)))