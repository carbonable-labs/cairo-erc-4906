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

use super::super::utils::{deploy, OWNER, OTHER_BASE_URI, TOKEN_1};

// External deps

use openzeppelin::utils::serde::SerializedAppend;
use snforge_std as snf;
use snforge_std::{ContractClassTrait};

// Starknet deps

use starknet::{ContractAddress, contract_address_const};

#[test]
fn test_initialization() {
    let contract_address = deploy();
    let erc721_meta = IERC721MetadataDispatcher { contract_address };
    let erc4906 = IERC4906HelperDispatcher { contract_address };

    snf::start_cheat_caller_address(contract_address, OWNER());
    erc4906.set_base_token_uri(OTHER_BASE_URI());

    assert(erc721_meta.token_uri(TOKEN_1) == "https://api.example.com/v2/1", 'Wrong token uri');
}
