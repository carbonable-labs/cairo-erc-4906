// External deps

use openzeppelin::utils::serde::SerializedAppend;
use snforge_std as snf;
use snforge_std::ContractClassTrait;

// Starknet deps

use starknet::{ContractAddress, contract_address_const};

// Constants
fn NAME() -> ByteArray {
    "NAME"
}

fn SYMBOL() -> ByteArray {
    "SYMBOL()"
}
fn BASE_URI() -> ByteArray {
    "https://api.example.com/v1/"
}
pub fn OTHER_BASE_URI() -> ByteArray {
    "https://api.example.com/v2/"
}
pub fn OTHER() -> ContractAddress {
    contract_address_const::<'OTHER()'>()
}
pub fn OWNER() -> ContractAddress {
    contract_address_const::<'OWNER()'>()
}


// Deploys an ERC4906 Preset contract.
pub fn deploy() -> ContractAddress {
    let contract = snf::declare("ERC4906Preset").expect('Declaration failed');

    let mut calldata: Array<felt252> = array![];
    calldata.append_serde(NAME());
    calldata.append_serde(SYMBOL());
    calldata.append_serde(BASE_URI());
    calldata.append_serde(OWNER());

    let (contract_address, _) = contract.deploy(@calldata).expect('Deployment failed');

    contract_address
}
