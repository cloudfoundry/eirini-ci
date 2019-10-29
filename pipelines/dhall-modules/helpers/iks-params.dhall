  λ(creds : ../types/iks-creds.dhall)
→ { IBMCLOUD_ACCOUNT = creds.account
  , IBMCLOUD_USER = creds.user
  , IBMCLOUD_PASSWORD = creds.password
  }
