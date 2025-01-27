/**
* The standards for passports and any other travel documents, electronic or not,
* are defined in the ICAO (International Civil Aviation Organization) 9303 document available here: 
* https://www.icao.int/publications/pages/publication.aspx?docnum=9303
*/

/**
* The structure of the MRZ is well defined and standardized by the ICAO
* so the index will always be the same for every passport
* c.f. ICAO 9303-4, Appendix B
*/

// The following constants define the indices of the information
// we need to generate various proofs of identity from the MRZ
// The structure of the MRZ is slightly different between passports
// and ID cards so we need to define indices for both types

// Index for the country of issuance of the passport
global PASSPORT_MRZ_COUNTRY_INDEX: u32 = 2;
// Index for the three letter code of the country of citizenship
// Note that the first three letter code (index 2) in the MRZ is the country of issuance
// not citizenship. It is important to keep in mind for residence permits 
// where the issuing country differs from the citizenship country
global PASSPORT_MRZ_NATIONALITY_INDEX: u32 = 54;
// Index for the sex of the passport holder (M, F or < if unspecified)
global PASSPORT_MRZ_SEX_INDEX: u32 = 64;
// Index for the date of expiry (YYMMDD)
global PASSPORT_MRZ_EXPIRY_DATE_INDEX: u32 = 65;
// Index for the date of birth (YYMMDD) in TD1 (i.e. passport) MRZ
global PASSPORT_MRZ_BIRTHDATE_INDEX: u32 = 57;
// Index for the document number in the MRZ
global PASSPORT_MRZ_DOCUMENT_NUMBER_INDEX: u32 = 44;
// Index for the document type in the MRZ
global PASSPORT_MRZ_DOCUMENT_TYPE_INDEX: u32 = 0;
// Index for the name of the passport holder
global PASSPORT_MRZ_NAME_INDEX: u32 = 5;
// Length of the MRZ on a passport
global PASSPORT_MRZ_LENGTH: u32 = 88;

// Index for the country of issuance of the ID card
global ID_CARD_MRZ_COUNTRY_INDEX: u32 = 2;
// Note that the first three letter code (index 2) in the MRZ is the country of issuance
// not citizenship. It is important to keep in mind for residence permits 
// where the issuing country differs from the citizenship country
global ID_CARD_MRZ_NATIONALITY_INDEX: u32 = 45;
// Index for the sex of the passport holder (M, F or < if unspecified)
global ID_CARD_MRZ_SEX_INDEX: u32 = 37;
// Index for the date of expiry (YYMMDD)
global ID_CARD_MRZ_EXPIRY_DATE_INDEX: u32 = 38;
// Index for the date of birth (YYMMDD) in TD3 (i.e. ID cards) MRZ
global ID_CARD_MRZ_BIRTHDATE_INDEX: u32 = 30;
// Index for the document number in the MRZ
global ID_CARD_MRZ_DOCUMENT_NUMBER_INDEX: u32 = 5;
// Index for the document type in the MRZ
global ID_CARD_MRZ_DOCUMENT_TYPE_INDEX: u32 = 0;
// Index for the name of the passport holder
global ID_CARD_MRZ_NAME_INDEX: u32 = 60;
// Length of the MRZ on an ID card
global ID_CARD_MRZ_LENGTH: u32 = 90;

// ECDSA curves mapping
global ECDSA_CURVE_P256: u32 = 0;
global ECDSA_CURVE_P384: u32 = 1;
global ECDSA_CURVE_P521: u32 = 2;
global ECDSA_CURVE_BRAINPOOL_B256R1: u32 = 3;
global ECDSA_CURVE_BRAINPOOL_B256T1: u32 = 4;
global ECDSA_CURVE_BRAINPOOL_B384R1: u32 = 5;
global ECDSA_CURVE_BRAINPOOL_B384T1: u32 = 6;
global ECDSA_CURVE_BRAINPOOL_B512R1: u32 = 7;
global ECDSA_CURVE_BRAINPOOL_B512T1: u32 = 8;

pub struct RSA2048Info {
    // The modulus
    modulus: [u8; 256],
    // Data used to verify the signature
    // Generated by the pre-compute function in Rust
    // c.f. main.rs
    modulus_redc_param: [u8; 257],
    // The exponent
    exponent: u32,
    // The signature
    signature: [u8; 256],
}

pub struct RSA3072Info {
    // The modulus
    modulus: [u8; 384],
    // Data used to verify the signature
    // Generated by the pre-compute function in Rust
    // c.f. main.rs
    modulus_redc_param: [u8; 385],
    // The exponent
    exponent: u32,
    // The signature
    signature: [u8; 384],
}

pub struct RSA4096Info {
    // The modulus
    modulus: [u8; 512],
    // Data used to verify the signature
    // Generated by the pre-compute function in Rust
    // c.f. main.rs
    modulus_redc_param: [u8; 513],
    // The exponent
    exponent: u32,
    // The signature
    signature: [u8; 512],
}

pub struct ECDSAP256Info {
    pubkey_x: [u8; 32],
    pubkey_y: [u8; 32],
    signature: [u8; 64],
}

pub struct IDData {
    // Regroups the hashes of all the data groups plus some padding
    // at the start and in between each data group hashes
    e_content: [u8; 700],
    e_content_size: u32,
    // Where we can find e_content in the signed_attributes
    // It varies from document to document according to the length
    // of the padding at the start
    dg1_offset_in_e_content: u32,
    // Last 32 bytes: result of the hash of all the hashes of the data groups
    // Rest of the bytes: information about the signature algorithm, date, etc.
    signed_attributes: [u8; 200],
    signed_attributes_size: u32,
    // The DG1 contains the Machine Readable Zone (MRZ) of the document
    // The two lines at the bottom of the passport data page
    // or the three bottom lines on the rear of an ID card
    // 95 bytes for passports, 93 bytes for ID cards
    // Including 88 bytes of MRZ and 5 bytes of padding for passports
    // and 90 bytes of MRZ and 5 bytes of padding for ID cards
    dg1: [u8; 95],
}

pub struct DSCData {
    // The TBS certificate of the DSC
    // TBS stands for To Be Signed
    tbs_certificate: [u8; 1024],
    tbs_certificate_size: u32,
    // The index of the public key in the TBS certificate
    pubkey_index: u32,
}

pub struct DiscloseFlags {
    issuing_country: bool,
    nationality: bool,
    document_type: bool,
    document_number: bool,
    date_of_expiry: bool,
    date_of_birth: bool,
    sex: bool,
    name: bool,
}

pub struct DisclosedData {
    issuing_country: [u8; 3],
    nationality: [u8; 3],
    document_type: [u8; 2],
    document_number: [u8; 9],
    date_of_expiry: [u8; 6],
    date_of_birth: [u8; 6],  
    name: [u8; 39],
}

pub fn get_array_slice<let N: u32, let M: u32>(arr: [u8; N], start: u32, end: u32) -> [u8; M] {
    let mut slice = [0 as u8; M];
    for i in start..end {
        slice[i - start] = arr[i];
    }
    slice
}

// Reverse the bytes of an array so you can switch from
// big endian to little endian order and vice versa
pub fn reverse_bytes_array<let N: u32>(arr: [u8; N]) -> [u8; N] {
    let mut reversed_arr = [0 as u8; N];
    for i in 0..N {
        // Reverse
        reversed_arr[i] = arr[N - 1 - i];
    }
    reversed_arr
}

pub fn insert_into_array<let N: u32, let M: u32>(
    mut arr: [u8; N],
    sub_arr: [u8; M],
    index: u32
) -> [u8; N] {
    for i in index..index + M {
        arr[i] = sub_arr[i - index];
    }
    arr
}

pub fn dynamic_insert_into_array<let N: u32, let M: u32>(
    mut arr: [u8; N],
    sub_arr: [u8; M],
    index: u32,
    max_size: u32
) -> [u8; N] {
    for i in index..index + max_size {
        if i - index < M {
            arr[i] = sub_arr[i - index];
        }
    }
    arr
}

pub fn is_id_card(id_data: IDData) -> bool {
    // For passport, the last two bytes are 0
    // since the real length is 93 for passports 
    // while it is 95 for ID cards
    (id_data.dg1[93] != 0) & (id_data.dg1[94] != 0)
}

pub fn from_byte_be_to_fields<let NBytes: u32, let N: u32>(x: [u8; NBytes]) -> [Field; N] {
    let mut result = [0 as Field; N];

    let excess_bytes = N * 15 - NBytes;
    let final_limb_bytes = 15 - excess_bytes;
    let mut limb: Field = 0;
    let mut k = 0;
    for _j in 0..final_limb_bytes {
        limb *= 256;
        limb += x[k] as Field;
        k += 1;
    }
    result[N - 1] = limb;

    for i in 1..N {
        let mut limb: Field = 0;
        for _j in 0..15 {
            limb *= 256;
            limb += x[k] as Field;
            k += 1;
        }
        result[N - i - 1] = limb;
    }

    result
}

unconstrained pub fn __from_byte_be_to_fields<let NBytes: u32, let N: u32>(x: [u8; NBytes]) -> [Field; N] {
    from_byte_be_to_fields(x)
}

pub fn get_mrz_from_dg1(dg1: [u8; 95]) -> [u8; 90] {
    let mut mrz = [0 as u8; 90];
    for i in 0..90 {
        mrz[i] = dg1[i + 5];
    }
    mrz
}