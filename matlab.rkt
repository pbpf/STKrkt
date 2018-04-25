#lang racket
;
(require racket/udp
         racket/gui)

(provide myframe%)


(define myframe%(class 
  frame%
  (super-new)
  (init-field wudp rudp[readcallback displayln])
  (field [to-send #"s"]
         [timegap 0.2]
         [buff (make-bytes 100)]
         [writetd #f]
         [readtd #f]
         [id #f])
   (define/public(stopall)
     (set! to-send #"e")
     (sleep 1)
     (when id
       (when writetd (kill-thread writetd))
       (when readtd (kill-thread readtd))))
   (define/public(startsend)
     (set! writetd (thread (lambda()
                          (let loop()
                            (udp-send wudp to-send)
                            (sleep timegap)
                            (loop))))))
   (define/public(startread)
     (set! readtd(thread (lambda()
          (let loop()
            (define-values(a b c)(udp-receive!*	 rudp buff))
            (when a (readcallback id (subbytes buff 0  (- a 2))))
            (loop)
            )))))
  (define/public(set-id! ids)
    (set! id ids))
  (define/override(on-subwindow-char	receiver event)
    (begin0(or (send this on-menu-char event)
               (send this on-system-menu-char event)
               (send this on-traverse-char event))
           (let[(code(send  event get-key-code))]
            ; (write code)
            ; (newline)
             (case code
               [(#\a)(set! to-send #"p")];推进
               [(#\s)(set! to-send #"b")];反向推进
               [(#\e)(set! to-send #"e")];停止
               [(release)(set! to-send #"s")];停止推进
               [else (void)]))))))
;(define main(new myframe%[label "a"][width 500][height 500][wudp udp1][rudp udp2]))
;(send main show #t)
;6768799.7,355657.7,6778137.0