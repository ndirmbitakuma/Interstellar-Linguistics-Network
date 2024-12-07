;; et-signal-archive contract

(define-data-var next-signal-id uint u0)

(define-map signals
  { signal-id: uint }
  {
    submitter: principal,
    timestamp: uint,
    source: (string-utf8 256),
    data: (string-utf8 1024),
    analysis: (string-ascii 0),
    status: (string-ascii 20)
  }
)

(define-public (submit-signal (source (string-utf8 256)) (data (string-utf8 1024)))
  (let
    (
      (signal-id (var-get next-signal-id))
    )
    (map-set signals
      { signal-id: signal-id }
      {
        submitter: tx-sender,
        timestamp: block-height,
        source: source,
        data: data,
        analysis: "",
        status: "pending"
      }
    )
    (var-set next-signal-id (+ signal-id u1))
    (ok signal-id)
  )
)

(define-public (update-analysis (signal-id uint) (analysis (string-ascii 0)))
  (let
    (
      (signal (unwrap! (map-get? signals { signal-id: signal-id }) (err u404)))
    )
    (asserts! (is-eq (get submitter signal) tx-sender) (err u403))
    (ok (map-set signals
      { signal-id: signal-id }
      (merge signal { analysis: analysis, status: "analyzed" })
    ))
  )
)

(define-read-only (get-signal (signal-id uint))
  (map-get? signals { signal-id: signal-id })
)

