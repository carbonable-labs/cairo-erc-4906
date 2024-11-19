// SPDX-License-Identifier: MIT

use starknet::ContractAddress;

#[starknet::interface]
pub trait IPresetExternal<TContractState> {
    fn mint_token(ref self: TContractState, recipient: ContractAddress) -> u256;
    fn set_base_uri(ref self: TContractState, base_uri: ByteArray);
    fn set_token_uri(ref self: TContractState, uri: ByteArray, token_id: u256);
}

#[starknet::contract]
pub mod ERC4906Preset {
    use starknet::ContractAddress;
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};

    use openzeppelin_access::ownable::OwnableComponent;
    use openzeppelin_introspection::src5::SRC5Component;
    use openzeppelin_token::erc721::{ERC721Component, ERC721HooksEmptyImpl};

    use erc4906::erc4906_component::ERC4906Component;


    component!(path: ERC4906Component, storage: erc4906, event: erc4906Event);
    component!(path: ERC721Component, storage: erc721, event: erc721Event);
    component!(path: OwnableComponent, storage: ownable, event: ownableEvent);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);

    // ERC721Mixin
    #[abi(embed_v0)]
    impl ERC721MixinImpl = ERC721Component::ERC721MixinImpl<ContractState>;
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;

    // Ownable
    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    // ERC4906
    impl ERC4906InternalImpl = ERC4906Component::InternalImpl<ContractState>;

    #[storage]
    pub struct Storage {
        #[substorage(v0)]
        erc4906: ERC4906Component::Storage,
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        pub next_token_id: u256,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        erc4906Event: ERC4906Component::Event,
        #[flat]
        erc721Event: ERC721Component::Event,
        #[flat]
        ownableEvent: OwnableComponent::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        name: ByteArray,
        symbol: ByteArray,
        base_uri: ByteArray,
        owner: ContractAddress
    ) {
        self.erc721.initializer(name, symbol, base_uri);
        self.ownable.initializer(owner);
        self.erc4906.initializer();
        self.erc721.mint(owner, 1);
        self.next_token_id.write(2);
    }

    #[abi(embed_v0)]
    impl ExternalImpl of super::IPresetExternal<ContractState> {
        fn mint_token(ref self: ContractState, recipient: ContractAddress) -> u256 {
            self.ownable.assert_only_owner();
            let token_id = self.next_token_id.read();
            self.erc721.mint(recipient, token_id);
            self.next_token_id.write(token_id + 1);
            token_id
        }

        fn set_base_uri(ref self: ContractState, base_uri: ByteArray) {
            self.ownable.assert_only_owner();
            self.erc721._set_base_uri(base_uri);
            self.erc4906._emit_batch_metadata_update(0, core::num::traits::Bounded::MAX);
        }

        fn set_token_uri(ref self: ContractState, uri: ByteArray, token_id: u256) {
            self.ownable.assert_only_owner();
            self.erc4906._emit_metadata_update(token_id);
        }
    }
}

