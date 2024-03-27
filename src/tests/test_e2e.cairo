// Contracts

use erc4906::ERC4906::ERC4906Component;
use erc4906::ERC4906::ERC4906Component::{Event, MetadataUpdate};

// Components

use erc4906::ERC4906::{IERC4906Helper, IERC4906HelperDispatcher, IERC4906HelperDispatcherTrait};
use openzeppelin::token::erc721::interface::{IERC721MetadataDispatcher, IERC721MetadataDispatcherTrait, IERC721Metadata};

// External deps

use openzeppelin::utils::serde::SerializedAppend;
use snforge_std as snf;
use snforge_std::{CheatTarget, ContractClassTrait, EventSpy, SpyOn, cheatcodes::events::EventAssertions};

// Starknet deps

use starknet::{ContractAddress, contract_address_const};

// Constants
fn NAME() -> ByteArray {
    "NAME"
}

fn SYMBOL() -> ByteArray {
    "SYMBOL"
}
fn BASE_URI() -> ByteArray {
    "https://api.example.com/v1/"
}
fn OTHER_BASE_URI() -> ByteArray {
    "https://api.example.com/v2/"
}
fn OTHER() -> ContractAddress {
    contract_address_const::<'OTHER'>()
}
fn OWNER() -> ContractAddress {
    contract_address_const::<'OWNER'>()
}
const TOKEN_1: u256 = 1;
const TOKEN_10: u256 = 10;

// Deploys an ERC721MetadaUpdate contract.
fn deploy() -> (ContractAddress, EventSpy) {
    let contract = snf::declare("ERC721MetadataUpdate");

    let token_ids = array![TOKEN_1, TOKEN_10];
    let mut calldata: Array<felt252> = array![];
    calldata.append_serde(NAME());
    calldata.append_serde(SYMBOL());
    calldata.append_serde(BASE_URI());
    calldata.append_serde(OTHER());
    calldata.append_serde(token_ids);
    calldata.append_serde(OWNER());

    let contract_address = contract.deploy(@calldata).unwrap();
    let mut spy = snf::spy_events(SpyOn::One(contract_address));

    (contract_address, spy)
}

#[test]
fn test_set_token_uri() {
    let (contract_address, mut spy) = deploy();
    let erc721_meta = IERC721MetadataDispatcher { contract_address };
    let erc4906 = IERC4906HelperDispatcher { contract_address };

    assert(erc721_meta.token_uri(TOKEN_1) == "https://api.example.com/v1/1", 'Wrong init token uri');

    snf::start_prank(CheatTarget::One(contract_address), OWNER());
    erc4906.set_base_token_uri(OTHER_BASE_URI());

    assert(erc721_meta.token_uri(TOKEN_1) == "https://api.example.com/v2/1", 'Wrong token uri');

    let expected_metadata_update = MetadataUpdate { token_uri: OTHER_BASE_URI() };
    spy.
        assert_emitted(
            @array![
                (contract_address, Event::MetadataUpdate(expected_metadata_update))
            ]
        )
}
