// SPDX-License-Identifier: MIT

#[starknet::interface]
pub trait IERC4906Helper<TContractState> { // TODO: remove pub keyword
    fn set_base_token_uri(ref self: TContractState, token_uri: ByteArray);
}

#[starknet::component]
pub mod ERC4906Component {
    use starknet::{ContractAddress, get_caller_address};
    use openzeppelin::token::erc721::ERC721Component;
    use openzeppelin::access::ownable::OwnableComponent;

    #[storage]
    struct Storage {}

    #[event]
    #[derive(Drop, PartialEq, starknet::Event)]
    pub enum Event {
        MetadataUpdate: MetadataUpdate,
        BatchMetadataUpdate: BatchMetadataUpdate,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct MetadataUpdate { // TODO: remove pub keyword
        #[key]
        pub token_uri: ByteArray, // Same here
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    struct BatchMetadataUpdate {
        #[key]
        from_token_id: u256,
        #[key]
        to_token_id: u256,
    }

    #[embeddable_as(ERC4906HelperImpl)]
    pub impl ERC4906Helper<
        TContractState,
        +HasComponent<TContractState>,
        +Drop<TContractState>,
        impl ERC721: ERC721Component::HasComponent<TContractState>,
        impl Ownable: OwnableComponent::HasComponent<TContractState>,
    > of super::IERC4906Helper<ComponentState<TContractState>> {
        fn set_base_token_uri(ref self: ComponentState<TContractState>, token_uri: ByteArray) {
            let caller = get_caller_address();
            let mut ownable = get_dep_component!(@self, Ownable);

            assert(caller == ownable.Ownable_owner.read(), 'not the owner');

            let mut erc721Comp = get_dep_component_mut!(ref self, ERC721);
            let new_token_uri = token_uri.clone();

            // Write the new base token URI
            erc721Comp.ERC721_base_uri.write(token_uri);

            // Emit event after base metadata is updated
            self.emit(MetadataUpdate { token_uri: new_token_uri });
        }
    }

    #[generate_trait]
    pub impl ERC4906HelperInternal<
        TContractState, +HasComponent<TContractState>,
    > of IERC4906HelperInternal<TContractState> {
        fn emitBatchMetadataUpdate(
            ref self: ComponentState<TContractState>, fromTokenId: u256, toTokenId: u256
        ) {
            // Emit event after metadata of a batch of tokens is updated
            self.emit(BatchMetadataUpdate { from_token_id: fromTokenId, to_token_id: toTokenId });
        }
    }
}

