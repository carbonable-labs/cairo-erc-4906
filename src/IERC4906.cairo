// SPDX-License-Identifier: MIT

#[starknet::interface]
trait IERC4906<TContractState> {
    fn setTokenURI(ref self: TContractState, tokenId: u256, tokenURI: felt252);
    fn emitBatchMetadataUpdate(ref self: TContractState, fromTokenId: u256, toTokenId: u256);
}
