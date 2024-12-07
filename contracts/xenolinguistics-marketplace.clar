;; xenolinguistics-marketplace contract

(define-data-var next-item-id uint u0)

(define-map items
  { item-id: uint }
  {
    seller: principal,
    name: (string-utf8 256),
    description: (string-utf8 1024),
    price: uint,
    item-type: (string-ascii 20),
    status: (string-ascii 20)
  }
)

(define-public (list-item (name (string-utf8 256)) (description (string-utf8 1024)) (price uint) (item-type (string-ascii 20)))
  (let
    (
      (item-id (var-get next-item-id))
    )
    (map-set items
      { item-id: item-id }
      {
        seller: tx-sender,
        name: name,
        description: description,
        price: price,
        item-type: item-type,
        status: "active"
      }
    )
    (var-set next-item-id (+ item-id u1))
    (ok item-id)
  )
)

(define-public (buy-item (item-id uint))
  (let
    (
      (item (unwrap! (map-get? items { item-id: item-id }) (err u404)))
    )
    (asserts! (is-eq (get status item) "active") (err u400))
    (try! (stx-transfer? (get price item) tx-sender (get seller item)))
    (ok (map-set items
      { item-id: item-id }
      (merge item { status: "sold" })
    ))
  )
)

(define-read-only (get-item (item-id uint))
  (map-get? items { item-id: item-id })
)

