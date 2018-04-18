#lang racket
;
(require "stkbase.rkt"
         ffi/unsafe)

;(define(New-Demo id)
;  (STKCmd id "New / Scenario Demo"))

(define(gen-Realtime-Position staname x y z)
  (format "Realtime */Satellite/~a SetLookAhead HoldCBFPosition ~a ~a ~a" staname x y z))
;相机位置 实时
(define(gen-RT obj op . parameters)
  (format "Realtime ~a ~a  ~a" obj op (string-join parameters " ")))

(define(gen-Position obj type coordinate . parameters)
  (format "SetPosition ~a ~a ~a ~a"
          obj type coordinate (string-join parameters " ")))

;;;;
;act AddArticulation
(define(gen-VO obj atname tranname starttime Duration  StartValue-end)
  (format "VO obj atname tranname starttime Duration  StartValue-end"))


(define(OpenSTK*)
  (Initcnn)
  (define-values (id fg)(OpenSTK "localhost:5001"))
  (if(= fg 0)
     id
     (error 'openstk "failed")))

;test
;(define id (OpenSTK*))
;(SetTimeOut id 50000)
;(define-values(info fg)(New-Demo id))
;(CloseSTK id)
;(Shutdowncnn)
  
