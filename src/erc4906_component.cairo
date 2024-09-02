// SPDX-License-Identifier: MIT

#[starknet::interface]
pub trait IERC4906Helper<TContractState> {
    fn set_base_token_uri(ref self: TContractState, token_uri: ByteArray);
}

#[starknet::component]
pub mod ERC4906Component {
    use openzeppelin::token::erc721::erc721::ERC721Component::InternalTrait;
    use openzeppelin::access::ownable::interface::IOwnable;
    use starknet::{ContractAddress, get_caller_address};
    use openzeppelin::access::ownable::OwnableComponent;
    use openzeppelin::introspection::src5::SRC5Component::InternalTrait as SRC5InternalTrait;
    use openzeppelin::introspection::src5::SRC5Component::SRC5;
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::token::erc721::ERC721Component;

    #[storage]
    struct Storage {}

    #[event]
    #[derive(Drop, PartialEq, starknet::Event)]
    pub enum Event {
        MetadataUpdate: MetadataUpdate,
        BatchMetadataUpdate: BatchMetadataUpdate,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct MetadataUpdate {
        #[key]
        pub token_id: u256,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct BatchMetadataUpdate {
        #[key]
        pub from_token_id: u256,
        #[key]
        pub to_token_id: u256,
    }

    #[embeddable_as(ERC4906HelperImpl)]
    pub impl ERC4906Helper<
        TContractState,
        +HasComponent<TContractState>,
        +SRC5Component::HasComponent<TContractState>,
        +Drop<TContractState>,
        impl ERC721: ERC721Component::HasComponent<TContractState>,
        impl Ownable: OwnableComponent::HasComponent<TContractState>,
    > of super::IERC4906Helper<ComponentState<TContractState>> {
        fn set_base_token_uri(ref self: ComponentState<TContractState>, token_uri: ByteArray) {
            let caller = get_caller_address();
            let mut ownable = get_dep_component!(@self, Ownable);

            assert(caller == ownable.owner(), 'ERC4906: must be owner');

            let mut erc721_comp = get_dep_component_mut!(ref self, ERC721);

            // Write the new base token URI
            erc721_comp._set_base_uri(token_uri);

            let u256_max = core::integer::BoundedInt::max();

            // Emit event after base metadata is updated
            self.emit(BatchMetadataUpdate { from_token_id: 0, to_token_id: u256_max });
        }
    }

    #[generate_trait]
    pub impl ERC4906HelperInternal<
        TContractState, +HasComponent<TContractState>,
    > of IERC4906HelperInternal<TContractState> {
        fn _emit_metadata_update(ref self: ComponentState<TContractState>, token_id: u256) {
            // Emit event after metadata of a token is updated
            self.emit(MetadataUpdate { token_id: token_id });
        }

        fn _emit_batch_metadata_update(
            ref self: ComponentState<TContractState>, fromTokenId: u256, toTokenId: u256
        ) {
            // Emit event after metadata of a batch of tokens is updated
            self.emit(BatchMetadataUpdate { from_token_id: fromTokenId, to_token_id: toTokenId });
        }
    }
}

