# SPS-V6

### 生成密钥(Android)

    key.store=SPS-V6.keystore
    key.alias=SPS-V6
    key.store.password=quickv6
    key.alias.password=quickv6

    keytool -genkey -keyalg RSA -keysize 1024 -validity 36500 -keystore SPS-V6.keystore -storepass quickv6 -alias SPS-V6 -keypass quickv6 < SPS-V6.txt
    keytool -list -v                                          -keystore SPS-V6.keystore -storepass quickv6 -alias SPS-V6 -keypass quickv6

## Git

    git config core.ignorecase false

