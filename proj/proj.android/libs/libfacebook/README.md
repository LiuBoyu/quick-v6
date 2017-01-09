# Facebook - 4.x

cd SPS-V6
keytool -exportcert -alias release -keystore SPS-V6.keystore | openssl sha1 -binary | openssl base64
