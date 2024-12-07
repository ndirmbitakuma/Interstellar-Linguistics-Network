;; xenolinguistic-protocol contract

(define-data-var next-protocol-id uint u0)

(define-map protocols
  { protocol-id: uint }
  {
    creator: principal,
    name: (string-utf8 256),
    description: (string-utf8 1024),
    content: (string-utf8 4096),
    status: (string-ascii 20),
    collaborators: (list 10 principal)
  }
)

(define-public (create-protocol (name (string-utf8 256)) (description (string-utf8 1024)) (content (string-utf8 4096)))
  (let
    (
      (protocol-id (var-get next-protocol-id))
    )
    (map-set protocols
      { protocol-id: protocol-id }
      {
        creator: tx-sender,
        name: name,
        description: description,
        content: content,
        status: "active",
        collaborators: (list tx-sender)
      }
    )
    (var-set next-protocol-id (+ protocol-id u1))
    (ok protocol-id)
  )
)

(define-public (update-protocol (protocol-id uint) (name (string-utf8 256)) (description (string-utf8 1024)) (content (string-utf8 4096)))
  (let
    (
      (protocol (unwrap! (map-get? protocols { protocol-id: protocol-id }) (err u404)))
    )
    (asserts! (is-eq (get creator protocol) tx-sender) (err u403))
    (ok (map-set protocols
      { protocol-id: protocol-id }
      (merge protocol { name: name, description: description, content: content })
    ))
  )
)

(define-public (add-collaborator (protocol-id uint) (collaborator principal))
  (let
    (
      (protocol (unwrap! (map-get? protocols { protocol-id: protocol-id }) (err u404)))
    )
    (asserts! (is-eq (get creator protocol) tx-sender) (err u403))
    (asserts! (< (len (get collaborators protocol)) u10) (err u401))
    (ok (map-set protocols
      { protocol-id: protocol-id }
      (merge protocol { collaborators: (unwrap! (as-max-len? (append (get collaborators protocol) collaborator) u10) (err u401)) })
    ))
  )
)

(define-read-only (get-protocol (protocol-id uint))
  (map-get? protocols { protocol-id: protocol-id })
)

