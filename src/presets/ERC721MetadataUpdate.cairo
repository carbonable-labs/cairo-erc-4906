// SPDX-License-Identifier: MIT

#[starknet::contract]
mod ERC721MetadataUpdate {
    use openzeppelin::introspection::src5::SRC5Component::InternalTrait;
    use super::super::super::ERC4906::ERC4906Component;
    use super::super::super::constants;

    use openzeppelin::access::ownable::OwnableComponent;
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::token::erc721::ERC721Component;

    use starknet::ContractAddress;

    component!(path: ERC4906Component, storage: erc4906, event: erc4906Event);
    component!(path: ERC721Component, storage: erc721, event: erc721Event);
    component!(path: OwnableComponent, storage: ownable, event: ownableEvent);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);

    // ERC4906
    #[abi(embed_v0)]
    impl ERC4906Impl = ERC4906Component::ERC4906Impl<ContractState>;

    // ERC721Mixin
    #[abi(embed_v0)]
    impl ERC721MixinImpl = ERC721Component::ERC721MixinImpl<ContractState>;
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;

    // Ownable
    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc4906: ERC4906Component::Storage,
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
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
        recipient: ContractAddress,
        token_ids: Span<u256>,
        owner: ContractAddress
    ) {
        self._initialize(name, symbol, base_uri, recipient, token_ids, owner);
    }

    #[generate_trait]
    impl InitializerImpl of InitializerTrait {
        fn _initialize(
            ref self: ContractState,
            name: ByteArray,
            symbol: ByteArray,
            base_uri: ByteArray,
            recipient: ContractAddress,
            token_ids: Span<u256>,
            owner: ContractAddress
        ) {
            self.erc721.initializer(name, symbol, base_uri);
            self._mint_assets(recipient, token_ids);
            self.ownable._transfer_ownership(owner);
            self.src5.register_interface(constants::IERC4906_ID);
        }
    }

    #[generate_trait]
    impl IntImpl of IntTrait {
        /// Mints `token_ids` to `recipient`.
        fn _mint_assets(
            ref self: ContractState, recipient: ContractAddress, mut token_ids: Span<u256>
        ) {
            loop {
                if token_ids.len() == 0 {
                    break;
                }
                let id = *token_ids.pop_front().unwrap();

                self.erc721._mint(recipient, id);
            }
        }
    }
}
