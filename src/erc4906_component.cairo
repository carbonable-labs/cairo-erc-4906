// SPDX-License-Identifier: MIT

pub const IERC4906_ID: felt252 = 0x49064906; // TODO


#[starknet::component]
pub mod ERC4906Component {
    use openzeppelin_introspection::src5::SRC5Component::InternalTrait as SRC5InternalTrait;
    use openzeppelin_introspection::src5::SRC5Component::SRC5Impl;
    use openzeppelin_introspection::src5::SRC5Component;
    use super::IERC4906_ID;

    #[storage]
    pub struct Storage {}

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

    #[generate_trait]
    pub impl InternalImpl<
        TContractState,
        +HasComponent<TContractState>,
        impl SRC5: SRC5Component::HasComponent<TContractState>,
        +Drop<TContractState>
    > of InternalTrait<TContractState> {
        fn initializer(ref self: ComponentState<TContractState>) {
            let mut src5_component = get_dep_component_mut!(ref self, SRC5);
            src5_component.register_interface(IERC4906_ID);
        }

        fn _emit_metadata_update(ref self: ComponentState<TContractState>, token_id: u256,) {
            let event = Event::MetadataUpdate(MetadataUpdate { token_id });
            self.emit(event);
        }

        fn _emit_batch_metadata_update(
            ref self: ComponentState<TContractState>, from_token_id: u256, to_token_id: u256,
        ) {
            let event = Event::BatchMetadataUpdate(
                BatchMetadataUpdate { from_token_id, to_token_id }
            );
            self.emit(event);
        }
    }
}

