use erc4906::erc4906_component::{IERC4906HelperDispatcher, IERC4906HelperDispatcherTrait};
use openzeppelin::token::erc721::interface::{
    IERC721MetadataDispatcher, IERC721MetadataDispatcherTrait
};

use super::super::utils::{deploy, OWNER, OTHER_BASE_URI, TOKEN_1};

// External deps

use snforge_std as snf;


#[test]
fn test_initialization() {
    let contract_address = deploy();
    let erc721_meta = IERC721MetadataDispatcher { contract_address };
    let erc4906 = IERC4906HelperDispatcher { contract_address };

    snf::start_cheat_caller_address(contract_address, OWNER());
    erc4906.set_base_token_uri(OTHER_BASE_URI());

    assert(erc721_meta.token_uri(TOKEN_1) == "https://api.example.com/v2/1", 'Wrong token uri');
}
