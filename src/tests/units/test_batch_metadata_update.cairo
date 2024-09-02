use snforge_std::cheatcodes::events::EventSpyAssertionsTrait;
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
use super::super::utils::{deploy, OWNER, OTHER_BASE_URI};

// External deps

use openzeppelin::utils::serde::SerializedAppend;
use snforge_std as snf;
use snforge_std::{ContractClassTrait, spy_events};

// Starknet deps

use starknet::{ContractAddress, contract_address_const};

#[test]
fn test_batch_metadata_update() {
    let contract_address = deploy();
    let erc4906 = IERC4906HelperDispatcher { contract_address };

    let mut spy = spy_events();

    snf::start_cheat_caller_address(contract_address, OWNER());
    erc4906.set_base_token_uri(OTHER_BASE_URI());

    let u256_max = u256 {
        low: 0xffffffffffffffffffffffffffffffff_u128, high: 0xffffffffffffffffffffffffffffffff_u128
    };

    let expected_batch_metadata_update = ERC4906Component::Event::BatchMetadataUpdate(
        ERC4906Component::BatchMetadataUpdate { from_token_id: 0, to_token_id: u256_max }
    );

    spy.assert_emitted(@array![(contract_address, expected_batch_metadata_update)]);
}
