// Contracts

use erc4906::erc4906_component::ERC4906Component;
use erc4906::erc4906_component::ERC4906Component::{Event, MetadataUpdate, BatchMetadataUpdate};

// Components

use erc4906::erc4906_component::{
    IERC4906Helper, IERC4906HelperDispatcher, IERC4906HelperDispatcherTrait
};
use openzeppelin::token::erc721::interface::{
    IERC721MetadataDispatcher, IERC721MetadataDispatcherTrait, IERC721Metadata
};

// External deps

use openzeppelin::utils::serde::SerializedAppend;
use snforge_std as snf;
use snforge_std::{ContractClassTrait};

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

pub const TOKEN_1: u256 = 1;
const TOKEN_10: u256 = 10;

// Deploys an ERC4906 Preset contract.
pub fn deploy() -> ContractAddress {
    let contract = snf::declare("ERC4906Preset").expect('Declaration failed');

    let token_ids = array![TOKEN_1, TOKEN_10];
    let mut calldata: Array<felt252> = array![];
    calldata.append_serde(NAME());
    calldata.append_serde(SYMBOL());
    calldata.append_serde(BASE_URI());
    calldata.append_serde(OTHER());
    calldata.append_serde(token_ids);
    calldata.append_serde(OWNER());

    let (contract_address, _) = contract.deploy(@calldata).expect('Deployment failed');

    contract_address
}
