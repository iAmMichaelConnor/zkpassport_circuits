# Passport Verifier

## Description

This project contains Noir circuits to generate Zero-Knowledge Proofs from the data contained within electronic passports.

## General FAQ

### What are electronic passports?

![Electronic Passport Chip Icon](https://wagmi-studio.fra1.cdn.digitaloceanspaces.com/ocelots/github-assets/epassport-icon.jpg)

If you have ever taken an international flight, chances are you have seen the little icon above at the airport or on your own passport. Any passport with this icon visible on it means it is an electronic passport equipped with an RFID chip. On this chip you will find the information visible on the data page of your passport along with a digital signature generated by the State that issued the passport.

### What does the chip contains?

The chip contains the data one can see on the data page of a passport (usually the second page), such as the photo, surname, given name(s), country of citizenship, date of birth, passport number, etc. Sometimes it will also contain other information such as fingerprints, iris scan, etc. But most importantly is the digital signature over the data of the passport. This can be used to verify the authenticity of the passport and the integrity of the data contained within.

### How can the digital signature be used to verify the integrity of the passport data?

The digital signature contained in the passport is over the data of the passport. This means that if anything is changed in the data after the passport issuance, then the verification of the digital signature against the data will fail. One can thus guarantee the integrity of the data this way.

### How can the digital signature be used to verify the authenticity of the passport?

Verifying the signature of the data can help us check its integrity but this does not guarantee the passport is authentic, anyone could sign the data and pretend to be the State that issued the passport. This is where enters the second step in the process. The public key corresponding to the private key used to sign the data (along with other information that forms what we call a certificate) is itself signed by the issuing State "master key". This private key is (hopefully) stored with extreme caution by the State, away from any prying eyes, and is what we call the trust anchor of the whole system. If anything is signed by this private key we can safely assume only the State could have done it (cryptography is generally based on quite a few assumptions, just got to make sure it's a good one). The associated public key is public knowledge, thus we can retrieve it and verify that the signature over the public key associated to the private key used to sign the data is indeed from the issuing State. If it is, then we can be sure the passport is authentic.

### How interoperable are electronic passports?

We all know international standards are not an easy thing to set in motion, but it turns out this is well standardized. The standard body for this is the International Civil Aviation Organization (ICAO) and it has set the standards for passports, both their physical layout and the way the chip's data is supposed to be organized and secured. This standard turns out to be respected by a large majority of countries around the world for their passports and even national IDs, residency cards or visas. The specifications for this standard are available on the ICAO website [here](https://www.icao.int/publications/pages/publication.aspx?docnum=9303).

### Wait, now I remember using my passport at an automated border control gate, does this use a similar process?

Yes, it is! The process leveraged by automated border control gates at airports is based on the electronic chip of passport and this signature verification process. This is why only passport with a chip can be used to go through them.

### How many countries have electronic passports?

![Countries with electronic passports](https://wagmi-studio.fra1.cdn.digitaloceanspaces.com/ocelots/github-assets/epassport-map.png)

As shown on the map above, there are over 140 countries issuing electronic passports around the world.

### Why use Zero-Knowledge Proofs?

Zero-Knowledge Proofs lets us prove the correct execution of a given program while keeping all or some of its inputs private. Here we can use it to prove that we correctly verified the digital signatures contained in the passport against the data that it contains, and then reveal only the information we want from this data. This way we can generate proofs relating to one's identity such as age, citizenship, personhood, and so on, with great confidence (as long as you trust the State that issued the passport) while keeping the rest of the data private.

### How easy is it to read the data from the passport chip?

It is actually quite easy, all you need is a device equipped with NFC, such as is the case with most smartphones nowadays.

### Could someone read my passport data without me knowing?

Not really, the communication with the chip is encrypted. To access the data of the chip you need a decryption key. That decryption key is derived from the data of the Machine Readable Zone (MRZ) which are the two lines at the bottom of the data page. Specifically, it is derived from the Document Number, the Date of Birth and the Date of Expiry contained within the MRZ. So the assumption of the protocol is that you have to open your passport and read the MRZ to access the data of the chip. So someone passing close to your passport with an NFC capable device will not be able to read the data of the chip without knowing the MRZ data. This is why the automated border control gates at airports require you to open your passport on the data page in order to initiate the communication with the chip.

### How to read the Machine Readable Zone (MRZ)?

The diagram below, taken from the ICAO specifications, summarizes in details how the MRZ is structured.

![Machine Readable Zone](https://wagmi-studio.fra1.cdn.digitaloceanspaces.com/ocelots/github-assets/mrz-structure.png)

### What other documents are covered by this standard?

The ICAO specifications apply to many other documents such as identity cards, residency cards, visas, and so on. Actually, the EU has decided in 2021 that every member State of the Union must issue identity card following this standard. So if you are a citizen of the EU and got a new identity card recently, chances are it is an electronic identity card. For example, French identity cards are now electronic and follow the ICAO specifications. They also switched from TD2 to TD1 format in the process. And so do residency cards such as the Titre de Séjour.

Note that depending on the format of the document, the structure of the MRZ will change. The structure shown in the previous answer is for passports, or more exactly for TD3 documents. The structure for identity cards, or TD1 documents, is spread on 3 lines instead of 2. There also exist TD2 documents which are in between the two, but as countries started to drop this format, the ICAO has decided to no longer maintain the specifications for them.

## Technical FAQ

### How does the signature verification process work?

If you are familiar with how SSL certificates are used and verified in order to established secure connections on the Internet, then you will find the process used by electronic passports quite similar. If not, then no worries, we will explain it here.

Akin to SSL certificates and many other protocols/systems, States and organizations issuing electronic passports rely on [X.509 certificates](https://datatracker.ietf.org/doc/html/rfc5280) to secure the system. These certificates contains a signature over the data that we desire to check the integrity of, along with the relevant information to be able to check that signature. Among this information, we can find the signature algorithm (RSA, ECDSA, EdDSA, DSA, etc.), the parameters of such algorithm (curve parameters, key size, etc.), the public key associated to the private key that was used to generate the signature, the issuer of the certificate, the validity period of the certificate, and some other policies and extensions.

When a State issues a new passport, it fills the electronic chip with the data associated to the person the passport will represent, seals the data and sign it with a private key that only the State will know. This signature is also stored in the passport chip. And the public key associated to this private key is packaged into an X.509 certificate called the Document Signer (or Signing) Certificate, also known more simply as DSC. This DSC is then added to the passport chip itself so readers of the chip can easily retrieve it later on. Note that a DSC can and most often will be used for multiple passports, i.e. the private key used to sign a given passport will be used to sign many other passports. However, they tend to rotate quickly and States will issue new DSCs every few weeks or months in general.

On top of the DSCs, each State has a single Certificate Authority called the Country Signing Certificate Authority (CSCA). This authority issues CSCA certificates that act as the trust anchors of the system, i.e. anything signed by the private key associated to the public key contained in a CSCA certificate can be trusted to have been signed by the State. And when the DSC is created, part of its content (including its public key) is signed by the CSCA certificate private key. This signature is then also included into the DSC. This way, we can check the signature over the data of the DSC by using the CSCA certificate public key. If the signature is valid, then we can be sure the DSC was signed by the CSCA certificate private key, and thus by the State.

These two certificates, CSCA certificate and DSC, forms what we call the chain of trust. We go from the passport data, check it against the signature from the DSC to make sure the data was not tampered with, then we retrieve the CSCA certificate and check the signature over the DSC against the public key of the CSCA certificate to make sure the DSC was indeed signed by the State. If all of this is valid, then we can be sure the passport was issued by the State and that the data contained within has not been tampered with.

The diagram below, taken from the ICAO, summarizes the process:

![Signature Verification Process](https://www.icao.int/Security/FAL/PKD/PublishingImages/PKDChain.jpg)

### How to retrieve the CSCA certificates?

You may have noticed that in the previous answer, we mentionned the DSC is stored in the passport chip itself, so it is easy to retrieve, but what about the CSCA certificates? Well, they are not in the passport chip, so we need to retrieve them from somewhere else. States will have agreements between them so they can be easily exchanged between them through trusted channels so that border controls can be sure they got the right CSCA certificates. Multiple States publish their CSCA certificates publicly on their websites, such as is the case for [France](https://ants.gouv.fr/csca) and [Germany](https://www.bsi.bund.de/EN/Themen/Oeffentliche-Verwaltung/Elektronische-Identitaeten/Public-Key-Infrastrukturen/CSCA/Root_Cert_Germany/Root_Certificate_node.html) for example. The ICAO also maintains a Master List of CSCA certificates of many different countries that can be found [here](https://www.icao.int/Security/FAL/PKD/Pages/icao-master-list.aspx). So getting the CSCA certificates is not as easy as the DSCs, but it not too hard either.

### How often do the CSCA certificates rotate?

The CSCA certificates are rotated every few years, usually between 3 and 5 years. The DSCs are rotated much more often, usually every few weeks or months. Note that in both cases they need to be valid for at least the period they were used to sign passports plus the maximum validity period of a passport, which is generally 5 or 10 years. So if passports are valid for 10 years and the CSCA certificate is rotated every 5 years, then the CSCA certificate needs to be valid for at least 15 years.

### Which signature algorithms are used?

Each State is free to choose whichever signature algorithm it wants among RSA, DSA and ECDSA. This part of the protocol is rather flexible and makes it so that in order to verify the signature over the data of the passport, we need to support different types of signature algorithms with different possible parameters. But the most common one by far, like in many other sectors on the Internet, is RSA. For example, French passports have DSCs using RSA with a key size of 2048 bits and CSCA certificates with a key size of 4096 bits. You will notice here than the DSCs have a smaller key size than that of the CSCA certificates, which is logical considering the central role CSCA certificates play in the system. There are only a few of them issued by each State, and they are used to sign many certificates, not just DSCs. So they need to be more secure than the DSCs. A potential compromised DSC is much less costly than a compromised CSCA certificate.

Apart from RSA, the ICAO allows States to also use ECDSA or DSA for their DSCs and CSCA certificates. ECDSA is the most common after RSA, and DSA is rarely used. Note that the ICAO recently added specifications for digital visas and digital entry/exit stamps to be included in the passport chip, and the signature algorithm that can be used for this is restricted to only ECDSA as many more certificates are needed to be stored in this part of the protocol, and ECDSA requires smaller key sizes than RSA for the same level of security. So this might push States to use ECDSA more often in the future for their DSCs and CSCA certificates.
