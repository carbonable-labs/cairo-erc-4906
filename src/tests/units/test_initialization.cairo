
use openzeppelin::token::erc721::interface::{
    IERC721MetadataDispatcher, IERC721MetadataDispatcherTrait
};

use erc4906::presets::erc4906_preset::{IPresetExternalDispatcher, IPresetExternalDispatcherTrait};
use erc4906::tests::utils::{deploy, OWNER, OTHER_BASE_URI};

use snforge_std::{start_cheat_caller_address};

#[test]
fn test_initialization() {
    let contract_address = deploy();
    let erc721_meta = IERC721MetadataDispatcher { contract_address };
    let nft = IPresetExternalDispatcher { contract_address };

    start_cheat_caller_address(contract_address, OWNER());
    nft.set_base_uri(OTHER_BASE_URI());

    assert(erc721_meta.token_uri(1) == "https://api.example.com/v2/1", 'Wrong token uri');
}
