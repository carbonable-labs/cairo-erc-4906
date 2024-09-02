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

use super::utils::{deploy, TOKEN_1, OWNER, OTHER_BASE_URI};

// External deps

use openzeppelin::utils::serde::SerializedAppend;
use snforge_std as snf;
use snforge_std::{ContractClassTrait, spy_events};

// Starknet deps

use starknet::{ContractAddress, contract_address_const};

#[test]
fn test_set_token_uri() {
    let contract_address = deploy();
    let erc721_meta = IERC721MetadataDispatcher { contract_address };
    let erc4906 = IERC4906HelperDispatcher { contract_address };

    let mut spy = spy_events();

    assert(
        erc721_meta.token_uri(TOKEN_1) == "https://api.example.com/v1/1", 'Wrong init token uri'
    );

    snf::start_cheat_caller_address(contract_address, OWNER());
    erc4906.set_base_token_uri(OTHER_BASE_URI());

    assert(erc721_meta.token_uri(TOKEN_1) == "https://api.example.com/v2/1", 'Wrong token uri');

    let u256_max = ~0_u256;

    let expected_batch_metadata_update = ERC4906Component::Event::BatchMetadataUpdate(
        ERC4906Component::BatchMetadataUpdate { from_token_id: 0, to_token_id: u256_max }
    );

    spy.assert_emitted(@array![(contract_address, expected_batch_metadata_update)]);
}
