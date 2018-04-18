#lang racket/base
(require ffi/unsafe
         ffi/unsafe/define
         ffi/unsafe/alloc)

(provide Initcnn
         OpenSTK
         SetProp
         CloseSTK
         SetTimeOut
         STKCmd
         SyncSTK
         CleanInfo
         Shutdowncnn
         Setmsgbuffer
         New-scenario
         New-Satellite
         (struct-out agtconreturninfo)
         )
         
(define-ffi-definer defineag (ffi-lib "AgConnect"))

; AgConInit call (AgConInit-base)
;(defineag Initbase (_fun -> _int ) #:c-id AgConInit)
;AgConInit with config file call (AgConInit-config *config-file-path*)
(defineag Initcnn (_fun [file : (_ptr i _string)= #f] -> _int ) #:c-id AgConInit)

(defineag OpenSTK (_fun [id : (_ptr o _bytes)]  [unused : _pointer = #f]   _string -> (fg : _int )->(values id fg))#:c-id AgConOpenSTK )

;AgConCloseSTK
(defineag CloseSTK(_fun (_ptr i _bytes)-> _int )#:c-id AgConCloseSTK)

;set time out

(defineag SetTimeOut(_fun _bytes _int -> _void) #:c-id AgConSetTimeout)


(define AgCRMHAHdrIdLen 6)
(define AgCRMHAHdrTypeLen 15)




  ;(for([i (in-range 0 len)])
(define _bytesvec1 (_array/list _byte (+ AgCRMHAHdrTypeLen 1)))
(define _bytesvec2 (_array/list _byte (+ AgCRMHAHdrIdLen 1)))
;(define-cpointer-type _byteslst _bytes)



;(define _bytes2 (make-ctype _bytesvec1 (for
(define-cstruct _agtconreturninfo
  ([hdrType _bytesvec1]
   [transId _bytesvec2]
   [numEntries _int]
   [returnList _pointer]))
(define(agtconreturninfo->racket af)
  (define len (agtconreturninfo-numEntries af))
  (hash 'hdrType (list->bytes (agtconreturninfo-hdrType af))
        'transId (list->bytes (agtconreturninfo-transId af))
        ;'numEntries len
        'returnList (cblock->list(agtconreturninfo-returnList af)_bytes
                                 len)))
(define(racket->agtconreturninfo rt)
  (define lst (hash-ref rt 'returnList))
  (list->agtconreturninfo
   (list  (bytes->list(hash-ref rt 'hdrType))
          (bytes->list(hash-ref rt 'transId))
    (length lst)
    (list->cblock lst _bytes (length lst)))))

(define _agt
  (make-ctype _agtconreturninfo
              racket->agtconreturninfo
              agtconreturninfo->racket))
#|
(define-cstruct _agtconreturninfo
  ([hdrType (_array _byte (+ AgCRMHAHdrTypeLen 1))]
   [transId (_array _byte (+ AgCRMHAHdrIdLen 1))]
   [numEntries _int]
   [returnList (_pointer (_pointer _byte))]))
|#
(defineag CleanInfo(_fun _pointer -> _void) #:c-id AgConCleanupReturnInfo  #:wrap (deallocator))

(defineag STKCmd (_fun (id name):: (id : _bytes) (name : _string) [info :(_ptr o _agtconreturninfo)] -> (fg : _int)-> (cond
                                                                                                                        [(= fg 0)(define inf1 (agtconreturninfo->racket info))
                                                                                                                                 (CleanInfo info)
                                                                                                                                 (values inf1 fg)]
                                                                                                                        [else (values '#hash((transId . #"\0\0\0\0\0\0\0") (returnList . ()) (hdrType . #"\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"))
                                                                                                                                      fg)]))
                                                                                                                        #:c-id AgConProcessSTKCmd)

;sync
(defineag SyncSTK (_fun _bytes [info : (_ptr o _agt)] -> (fg : _int) -> (values info fg)) #:c-id AgConGetAsync )
; 释放返回info


;AgConSetProperties
(define AgCConVerboseOn #x0001)
(define AgCConAckOn #x0002)
(define AgCConErrorOn #x0004)
(define AgCConAsyncOn #x0008)
(defineag SetProp (_fun _bytes _uint -> _void)#:c-id AgConSetProperties)

;AgConShutdownConnect

(defineag Shutdowncnn (_fun -> _void) #:c-id AgConShutdownConnect)

;AgUtMsgReserveBuffer
(defineag Setmsgbuffer (_fun _int -> _void) #:c-id AgUtMsgReserveBuffer)

;new scenario  新建场景
(define(New-scenario id name)
(STKCmd id (format "New / Scenario ~a" name))
)
;新建卫星
(define(New-Satellite id name)
(STKCmd id (format "New / */Satellite ~a" name)
))
;
                       #|
typedef struct AgTConReturnInfo
{
char hdrType[AgCRMHAHdrTypeLen+1];
char transId[AgCRMHAHdrIdLen+1];
int numEntries;
char **returnList;
} AgTConReturnInfo;|#
;test ok
;(Initcnn)
;(define-values(id fg)(OpenSTK "localhost:5001"))
;(define-values(info fg2)(New-Satellite id "sat5"))
;(thread (lambda()(define-values (s r)(STKCmd id  "Load / VDF \"D:\\Program Files\\AGI\\STK 11\\Data\\ExampleScenarios\\Intro_STK_Aircraft_Systems.vdf\""))(displayln r)))