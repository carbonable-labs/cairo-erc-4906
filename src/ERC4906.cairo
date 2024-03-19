// SPDX-License-Identifier: MIT

#[starknet::component]
pub mod ERC4906Component {
    use starknet::ContractAddress;
    use super::super::IERC4906;
    use super::super::constants;

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
        TContractState, +HasComponent<TContractState>
    > of IERC4906<ComponentState<TContractState>> {
        fn initializer(ref self: ComponentState<TContractState>) {
            ERC165.register_interface(constants::IERC4906_ID);
        }

        fn metadata_update(ref self: ComponentState<TContractState>, token_id: u256) {
            // @dev It fails token_id is not a valid Uint256.
            self.emit(MetadataUpdate { tokenId: token_id });
        }

        fn batch_metadata_update(
            ref self: ComponentState<TContractState>, from_token_id: u256, to_token_id: u256
        ) {
            self.emit(BatchMetadataUpdate { fromTokenId: from_token_id, toTokenId: to_token_id });
        }

        // @notice Set token uri.
        // @param token_id The token id for which the uri must be updated.
        // @param token_uri The new token uri.
        fn _set_token_uri(
            ref self: ComponentState<TContractState>, token_id: u256, token_uri: felt252
        ) {
            ERC721._set_token_uri(token_id, token_uri);
            metadata_update(token_id);
        }
    }
}

