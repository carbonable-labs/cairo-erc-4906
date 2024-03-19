// SPDX-License-Identifier: MIT

#[starknet::interface]
trait IERC4906<TContractState> {
    fn setTokenURI(ref self: TContractState, tokenId: u256, tokenURI: ByteArray);
    fn emitBatchMetadataUpdate(ref self: TContractState, fromTokenId: u256, toTokenId: u256);
}

#[starknet::component]
pub mod ERC4906Component {
    use starknet::ContractAddress;
    use super::super::constants;
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
    struct MetadataUpdate {
        #[key]
        tokenId: u256,
    }

    #[derive(Drop, PartialEq, starknet::Event)]
    struct BatchMetadataUpdate {
        #[key]
        fromTokenId: u256,
        #[key]
        toTokenId: u256,
    }

    #[embeddable_as(ERC4906Impl)]
    impl ERC4906<
        TContractState,
        +HasComponent<TContractState>,
        +Drop<TContractState>,
        impl ERC721: ERC721Component::HasComponent<TContractState>
    > of super::IERC4906<ComponentState<TContractState>> {
        fn setTokenURI(
            ref self: ComponentState<TContractState>, tokenId: u256, tokenURI: ByteArray
        ) {
            let mut erc721_comp = get_dep_component_mut!(ref self, ERC721);
            erc721_comp.ERC721_base_uri.write(tokenURI);

            self.emit(MetadataUpdate { tokenId: tokenId });
        }

        fn emitBatchMetadataUpdate(
            ref self: ComponentState<TContractState>, fromTokenId: u256, toTokenId: u256
        ) {
            self.emit(BatchMetadataUpdate { fromTokenId: fromTokenId, toTokenId: toTokenId });
        }
    }
}

