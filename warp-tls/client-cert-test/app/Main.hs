{-# LANGUAGE OverloadedStrings, RecordWildCards, NamedFieldPuns #-}
import Network.Wai
import Network.Wai.Handler.Warp
import Network.Wai.Handler.Warp.Internal (ServeConnection, serveDefault)
import Network.Wai.Handler.WarpTLS
import Network.HTTP.Types (status200)
import Blaze.ByteString.Builder (copyByteString)
import Data.Monoid
-- import Network.HTTP.Conduit

main = do
    putStrLn "https://localhost:3009/"
    --manager <- newManager def
    runServeTLS (tlsSettings  "certificate.pem" "key.pem")
        { tlsWantClientCert = True
        } (setPort 3009 defaultSettings) serveConn

serveConn :: ServeConnection
serveConn conn internalInfo sockAddr transport settings = do
  case transport of
    TLS { tlsClientCertificate = Just certChain } ->
      putStrLn $ "got TLS connection with client certificate: " <> show certChain
    TLS {..} ->
      putStrLn $ "got TLS connection without client certificate"
    _ ->
      putStrLn $ "got non-TLS connection"

  serveDefault app conn internalInfo sockAddr transport settings

app req f = f builderWithLen

builderWithLen = responseBuilder
  status200
  [ ("Content-Type", "text/plain")
  , ("Content-Length", "4")
  ]
  $ copyByteString "PONG"
