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

use super::super::utils::deploy;

// External deps

use openzeppelin::utils::serde::SerializedAppend;
use snforge_std as snf;
use snforge_std::{ContractClassTrait};

// Starknet deps

use starknet::{ContractAddress, contract_address_const};

// TODO: Deprecated test. Should use the internal function _emit_metadata_update and emit MetadataUpdate when updating a single token
fn test_metadata_update() {
    // let contract_address = deploy();

    let u256_max = ~0_u256;

    MetadataUpdate { token_id: u256_max };
    return ();
}
