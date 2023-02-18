# CooperCA

There are lots of guides on the internet to create, sign and validate certificates with OpenSSL.
Sadly, many of those miss out on important features like certificate chains or v3 extensions.
One guide I found very useful however, is Jamie Ngyuen's [OpenSSL Certificate Authority](https://jamielinux.com/docs/openssl-certificate-authority/index.html).
That's why I created this repository which is heavily influenced by the work of Jamie.

## Usage

Execute and follow the instructions:
```bash
docker run -it --rm -v some/local/directory:/ca rngcntr/cooper-ca
```
Your certificates, keys and all other generated data is stored persistantly in `some/local/directory` and can be re-used at any time.
