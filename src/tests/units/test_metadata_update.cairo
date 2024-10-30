use erc4906::erc4906_component::ERC4906Component;
use erc4906::presets::erc4906_preset::{IPresetExternalDispatcher, IPresetExternalDispatcherTrait};
use erc4906::tests::utils::{deploy, OWNER, OTHER, OTHER_BASE_URI};

// External deps
use snforge_std::cheatcodes::events::EventSpyAssertionsTrait;
use snforge_std::spy_events;
use snforge_std::start_cheat_caller_address;


#[test]
fn test_batch_metadata_update() {
    let contract_address = deploy();
    let nft = IPresetExternalDispatcher { contract_address };

    let mut spy = spy_events();

    start_cheat_caller_address(contract_address, OWNER());
    nft.set_base_uri(OTHER_BASE_URI());

    let u256_max: u256 = core::num::traits::Bounded::MAX;

    let expected_batch_metadata_update = ERC4906Component::Event::BatchMetadataUpdate(
        ERC4906Component::BatchMetadataUpdate { from_token_id: 0, to_token_id: u256_max }
    );

    spy.assert_emitted(@array![(contract_address, expected_batch_metadata_update)]);
}

#[test]
fn test_metadata_update() {
    let contract_address = deploy();
    let nft = IPresetExternalDispatcher { contract_address };

    let mut spy = spy_events();

    start_cheat_caller_address(contract_address, OWNER());
    let token_id = nft.mint_token(OTHER());
    nft.set_token_uri("https://api.example.com/v2/1", token_id);

    let expected_metadata_update = ERC4906Component::Event::MetadataUpdate(
        ERC4906Component::MetadataUpdate { token_id }
    );

    spy.assert_emitted(@array![(contract_address, expected_metadata_update)]);
}
