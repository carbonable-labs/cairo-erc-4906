// SPDX-License-Identifier: MIT

#[starknet::interface]
trait IERC4906Helper<TContractState> {
    fn setBaseTokenURI(ref self: TContractState, tokenURI: ByteArray);
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
    struct MetadataUpdate {
        #[key]
        tokenURI: ByteArray,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    struct BatchMetadataUpdate {
        #[key]
        fromTokenId: u256,
        #[key]
        toTokenId: u256,
    }

    #[embeddable_as(ERC4906HelperImpl)]
    pub impl ERC4906Helper<
        TContractState,
        +HasComponent<TContractState>,
        +Drop<TContractState>,
        impl ERC721: ERC721Component::HasComponent<TContractState>,
        impl Ownable: OwnableComponent::HasComponent<TContractState>,
    > of super::IERC4906Helper<ComponentState<TContractState>> {
        fn setBaseTokenURI(ref self: ComponentState<TContractState>, tokenURI: ByteArray) {
            let caller = get_caller_address();
            let mut ownableComp = get_dep_component_mut!(ref self, Ownable);

            assert(caller == ownableComp.Ownable_owner.read(), 'not the owner');

            let mut erc721Comp = get_dep_component_mut!(ref self, ERC721);
            let newTokenURI = tokenURI.clone();

            // Write the new base token URI
            erc721Comp.ERC721_base_uri.write(tokenURI);

            // Emit event after base metadata is updated
            self.emit(MetadataUpdate { tokenURI: newTokenURI });
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
            self.emit(BatchMetadataUpdate { fromTokenId: fromTokenId, toTokenId: toTokenId });
        }
    }
}

