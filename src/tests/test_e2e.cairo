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
use snforge_std::{
    CheatTarget, ContractClassTrait, EventSpy, SpyOn, cheatcodes::events::EventAssertions
};

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

// Deploys an ERC4906 Preset contract.
fn deploy() -> ContractAddress {
    let contract = snf::declare('ERC4906Preset');

    let token_ids = array![TOKEN_1, TOKEN_10];
    let mut calldata: Array<felt252> = array![];
    calldata.append_serde(NAME());
    calldata.append_serde(SYMBOL());
    calldata.append_serde(BASE_URI());
    calldata.append_serde(OTHER());
    calldata.append_serde(token_ids);
    calldata.append_serde(OWNER());

    let contract_address = contract.deploy(@calldata).unwrap();

    contract_address
}

#[test]
fn test_set_token_uri() {
    let contract_address = deploy();
    let erc721_meta = IERC721MetadataDispatcher { contract_address };
    let erc4906 = IERC4906HelperDispatcher { contract_address };

    let mut spy = snf::spy_events(SpyOn::One(contract_address));

    assert(
        erc721_meta.token_uri(TOKEN_1) == "https://api.example.com/v1/1", 'Wrong init token uri'
    );

    snf::start_prank(CheatTarget::One(contract_address), OWNER());
    erc4906.set_base_token_uri(OTHER_BASE_URI());

    assert(erc721_meta.token_uri(TOKEN_1) == "https://api.example.com/v2/1", 'Wrong token uri');

    let u256_max = ~0_u256;

    let expected_batch_metadata_update = BatchMetadataUpdate {
        from_token_id: 0, to_token_id: u256_max
    };

    spy
        .assert_emitted(
            @array![(contract_address, Event::BatchMetadataUpdate(expected_batch_metadata_update))]
        )
}
