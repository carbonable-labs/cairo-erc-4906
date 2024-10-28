// Contracts

use erc4906::erc4906_component::ERC4906Component::MetadataUpdate;

use starknet::{ContractAddress, contract_address_const};

// TODO: Deprecated test. Should use the internal function _emit_metadata_update and emit
// MetadataUpdate when updating a single token
fn test_metadata_update() {
    // let contract_address = deploy();

    let u256_max = ~0_u256;

    MetadataUpdate { token_id: u256_max };
    return ();
}
